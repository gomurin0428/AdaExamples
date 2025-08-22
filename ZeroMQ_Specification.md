# Adaコア実装 仕様書（ZEB: Zmq Excel Bridge Core）

本書は、**Excel/VBA から ZeroMQ を安全・簡単に扱うための COM コンポーネント**の“心臓部”として実装する **純Adaライブラリ**の仕様をまとめたものです。ここで定義する Ada コアは、COM や Excel に依存しない独立ライブラリとして設計し、のちに薄い COM アダプタを被せる前提です。

---

## 背景と目的

* 現場には Excel/VBA や VB6/Delphi などのレガシー資産が多く、そこから **軽量・ブローカレス**な ZeroMQ を使って外部サービス（Python 等）とやり取りしたいニーズがある。
* Excel は **STA（シングルスレッドアパートメント）**で再入禁止の性質が強く、**受信イベントの直列配送**と**落ちない・詰まらない**実装が必須。
* Ada は **境界チェック/契約/保護型オブジェクト/タスク**で、こうした要件に合う。
* 目的は、**運用ごと使えるメッセージング基盤**（再接続・スプール・メトリクス・鍵管理の土台）を **純Ada**で提供すること。

---

## スコープ（v1）

**含む**

* ZeroMQ 基本パターン：`PUB/SUB`, `PUSH/PULL`, `REQ`（`REP` はテスト用）
* 受信のイベント集約（直列配送）と内部リングバッファ
* 再接続（指数バックオフ）、HWM/タイムアウト等の主要オプション
* 送信側の **Store-and-Forward（スプール）**
* メトリクス（送受件数・ドロップ・再接続回数・スプール量）
* ロギング（重要イベント重視）
* Curve（libsodium）による暗号化サポート（オプション）

**除外**

* マルチパートの一般化（v1 は「トピック + 本文1フレーム」）
* JSON/MessagePack 等のスキーマ変換ヘルパ
* 複雑な監視 UI、クラスタ、サービス常駐（COM 側で対応予定）

---

## 全体アーキテクチャ（概観）

```
+---------------------------+        +------------------------+
|         ZEB.Core         |        |      COM Adapter       |  ← 後で載せる薄い層
|  (純Ada: この仕様の対象)   |        |   (Excel/VBA IDispatch) |
+---------------------------+        +------------------------+
    |           |     |
    |           |     +-- ZEB.Dispatch ・・・直列イベント配送（COMはここに接続）
    |           +-------- ZEB.Socket --- Rx/Txタスク・状態機械・再接続・スプール
    +------------------- ZEB.ZM -------- libzmq C FFI（生ポインタを隔離）
         ^     ^    ^    ^
       Types  Buffer Spool Metrics ...（下記モジュール群）
```

---

## モジュール構成（Ada 2022 パッケージ）

### 1) `ZEB.Types`

* 役割：公開型・列挙・時間型の定義（UTF-8 前提）
* 代表型：

  * `Payload_Kind = (Text, Bytes)`
  * `State = (Disconnected, Connecting, Connected, Backing_Off)`
  * `Message`（`Topic : String; Kind : Payload_Kind; Data : Bytes; Stamp : Monotonic`）
* ポリシー：**文字列はUTF-8**としてバイト列（`Bytes` = `Unsigned_8`配列）に保持可能

### 2) `ZEB.Errors`

* 役割：外向けの**結果型**とエラーコード
* 例：`Result(Ok : Boolean; Code : Error_Code; Detail : String)`
* 代表コード：`Timeout, Not_Connected, Invalid_Option, Curve_Key_Error, HWM_Exceeded, Spool_Overflow, ZMQ_EAGAIN`
* 方針：**運用エラーは戻り値**、**契約違反のみ例外**

### 3) `ZEB.Logging`

* 役割：軽量ロギング（同期/行バッファ、Log\_Level でフィルタ）
* API：`Set_Sink`, `Log(Level, String)` など（ファイル出力実装は差し替え可能）

### 4) `ZEB.Metrics`

* 役割：送受・ドロップ・再接続・スプール量等の**原子的カウンタ**
* 実装：保護型でインクリメント/スナップショット取得

### 5) `ZEB.Buffer`

* 役割：**固定長リングバッファ**（単Producer/単Consumer）
* 用途：`Rxリング`（受信→配送）、`Txリング`（API→送信）
* 契約：`Count <= Capacity`（**SPARKで証明可能形**を目標）

### 6) `ZEB.Spool`

* 役割：送信の Store-and-Forward（ジャーナル形式、サイズ上限、古い順削除）
* フォーマット：`MAGIC "ZEB0" | Flags | TopicLen | DataLen | Timestamp | Topic | Data`
* API：`Enable(Dir, Max_Bytes, Flush_Batch)`, `Enqueue_For_Resend`, `Next_Batch`, `Ack`

### 7) `ZEB.Retry`

* 役割：指数バックオフとジッタ計算
* API：`Next_Backoff(Try)`, `Reset`

### 8) `ZEB.Curve`（任意機能）

* 役割：CurveZMQ 鍵生成/検証（libsodium）
* API：`Generate(Pub_Z85, Sec_Z85)`, `Validate(Z85)`

### 9) `ZEB.Time`

* 役割：**単調時計**とタイムアウト補助（`Monotonic_Now`, `Elapsed`）

### 10) `ZEB.ZM`（libzmq バインディング層）

* 役割：**C FFI を隔離**し、安全な Ada 型に変換
* 対応：`Ctx_New/Destroy, Socket_New/Close, Bind/Connect, Setsockopt/Getsockopt, Send/Recv, Poll/Msg_*`
* 注意：**ヌル終端/サイズ/アライン**はここで完結させる

### 11) `ZEB.Config`

* 役割：ZMQ オプションの安全サブセット
* 例：`Snd_HWM, Rcv_HWM, Linger_ms, RcvTimeout_ms, SndTimeout_ms, Immediate, KeepAlive, Reconnect_Min/Max`

### 12) `ZEB.Dispatch`

* 役割：**直列イベント配送**（再入禁止）。コールバックIFを定義し、単一配送タスクから順次呼ぶ
* IF：

  * `On_Message(Message)`
  * `On_StateChange(State, Detail)`
  * `On_Error(Error_Code, Detail)`

### 13) `ZEB.Socket`

* 役割：ソケット抽象（状態機械 / Rx/Tx タスク / スプール / 再接続 / REQ 同期）
* 公開API（概略）

  * 作成/接続：`Create(Kind, Options)`, `Open(Endpoint, Connect|Bind)`, `Close`
  * 受信：`Start`, `Stop`, `Dequeue`（明示ポーリング用）
  * 送信：`Send(Message)`（PUB/PUSH/REQ）
  * REQ 同期：`Call(Req, Timeout, Reply)`
  * SUB：`Subscribe/Unsubscribe(Prefix)`
  * 状態/統計：`Get_State`, `Get_Stats`
  * スプール：`Enable_Spool(Dir, Max_Bytes, Flush_Batch)`

### 14) `ZEB.Secret` / `ZEB.Secret.DPAPI`（拡張）

* 役割：秘密鍵の読み出しIFと Windows DPAPI 実装（将来 COM 側から利用）

### 15) `ZEB.Supervisor`（任意）

* 役割：複数ソケットの一括停止・集計（将来拡張）

---

## データ型とエンコード

* **ワイヤ**：ZeroMQ フレームは「先頭=トピック（UTF-8）」「本文=バイト列（UTF-8文字列も可）」の2フレーム前提（v1）
* **内部保持**：`Message.Data` は `Bytes`。テキストは UTF-8 に限定
* **長さ制限**：Topic と Data の長さはそれぞれ 0〜数MB（HWM/スプール設定で制御）

---

## 状態遷移（`ZEB.Socket`）

```
Disconnected
   | Open() 成功
   v
Connecting --(connect失敗)--> Backing_Off --(再試行到来)--> Connecting
   | (接続確立)
   v
Connected --(I/Oエラー/切断検知)--> Backing_Off
   | Close()
   v
Disconnected
```

* `On_StateChange` は各遷移で通知（Detail にエラー/試行回数/バックオフ秒を入れる）

---

## 並行実行モデル

* **ソケットあたり 2 タスク**

  * **Rxタスク**：`zmq_recv`（ブロッキング or poll）→ `Rxリング`に積む
  * **Txタスク**：`Txリング`から `zmq_send`。送信失敗/未接続時はスプールに退避可
* **配送タスクは 1 本**（`ZEB.Dispatch`）：`Rxリング`から取り出して **直列**で `On_Message` 等を呼び出す
* **REQ 同期**：内部小さな状態機械で送→受を直列化、タイムアウトは `ZEB.Time` で監督

---

## スプール仕様（要点）

* **ファイル構造**：追記ログ（append-only）。クラッシュ後は「最後に完全に書けたレコード」まで復旧
* **上限**：`Max_Bytes` 超過時に**最古から切り詰め**（インデックスは簡易、復旧も O(n) 許容）
* **送出**：再接続後 `Flush_Batch` 件ずつ送信、成功分を `Ack` でコミット
* **対象**：`PUB/PUSH`（`REQ` は対象外）

---

## セキュリティ（Curve）

* **鍵形式**：Z85 文字列
* **適用**：`ZEB.Socket.Open` までに `Enable_Curve(...)` 相当の設定を完了
* **保管**：DPAPI 等の実装を `ZEB.Secret` に分離（後付け）

---

## ログ/メトリクス

* 重要イベント（接続/切断/バックオフ開始・終了/大量ドロップ/スプール切替）を INFO で記録
* メトリクスはスナップショット取得 API を提供（COM 側の `Stats` に対応）

---

## エラーモデル

* **原則**：API は `Result` を返し、失敗時は `Code/Detail` を埋める
* **例外**：契約違反（不正範囲のオプション、NULL ハンドル誤用など）のみ `raise`

---

## パフォーマンス目標（目安）

* ローカル TCP、短文テキスト：**5〜10万 msg/分**（ドロップなし時）
* REQ 往復遅延：**1〜5ms**（同一ホスト・非暗号）
* 目標は**安定性優先**。イベントハンドラが重い場合はドロップが発生し得る（メトリクスに反映）

---

## ビルドと依存

* コンパイラ：GNAT（Ada 2022）
* 依存：`libzmq 4.3.x`、Curve 使用時 `libsodium`
* ビルド：`gprbuild` もしくは `alr`（Alire）プロファイルを提供
* リンク：Windows 向けは動的リンク方針（配布・ライセンス要件に合わせて最終決定）
* 32/64bit：双方ビルド。FFI 宣言は `Interfaces.C` に準拠

---

## ライセンスと配布メモ

* **libzmq / libsodium のライセンス条件**に従うこと（静的/動的、告知義務、ソース提供方法などを法務で確定）
* Ada コア自体のライセンスは社内方針に合わせて選定（商用配布前提）

---

## テスト/検証計画

* **単体**：`ZEB.Buffer`（SPARK推奨）、`ZEB.Retry`、`ZEB.Spool`（クラッシュ復旧テスト含む）
* **結合**：`ZEB.Socket` の Open/Send/Recv/Backoff/Spool/Stats
* **シナリオ**：

  1. 回線断 5 分 → 再接続 → スプール完全送出
  2. HWM 超過 → ドロップ件数が増加
  3. Curve 有効で相互認証失敗 → 適切な `Error_Code`
  4. REQ タイムアウト → 正常復帰
* **負荷**：ローカルで 10万 msg/分・5分間、リーク/ハング無し
* **工具**：CLI テストハーネス（Sub/Pub/Req を操作、メトリクス表示）

---

## 実装優先度（マイルストーン）

1. **基盤**：`ZEB.ZM` 最小セット / `ZEB.Buffer` / `ZEB.Time`
2. **送受**：`ZEB.Socket`（Pub/Sub/Push/Pull）+ `ZEB.Dispatch`
3. **再接続**：`ZEB.Retry` 組み込み、`StateChange` 通知
4. **スプール**：`ZEB.Spool` を Tx 経路に統合
5. **REQ**：同期呼び出し（タイムアウト、相互排他）
6. **メトリクス/ログ**：収集としきい値ログ
7. **Curve**：鍵適用と最小テスト
8. **CLI**：デモ用ハーネス完成（受け入れ試験に使用）

---

## 受け入れ基準（Definition of Done, v1）

* Pub/Sub/Push/Pull/Req の基本シナリオが CLI で再現可能
* 切断〜再接続でクラッシュ/ハング無し、状態通知が正しい
* スプール ON で回線断中の送信が再接続後に完全送出
* HWM 超過でドロップ発生・メトリクス反映
* Curve 有効時のハンドシェイク失敗が検出/通知
* 主要モジュールの単体テスト合格（Buffer/Retry/Spool）

---

## リスクと対策

* **Excel 側の重い処理でイベント滞留** → 直列配送＋HWM＋ドロップ統計で“見える化”
* **FFI 由来の不具合** → C 境界は `ZEB.ZM` のみに閉じ込め、適切な境界テスト
* **スプール容量暴走** → 上限必須、古い順削除、メトリクス/警告ログ
* **ライセンス誤解** → 早期に配布形態を固定し法務レビュー

---

## 付録：代表 API（擬似シグネチャ）

* `Socket.Create(Kind, Options) -> Socket`
* `Open(Endpoint, Connect|Bind) -> Result`
* `Start()/Stop() -> Result`
* `Send(Message) -> Result`
* `Call(Req, Timeout, Reply out) -> Result`
* `Subscribe(Prefix)/Unsubscribe(Prefix) -> Result`
* `Enable_Spool(Dir, Max_Bytes, Flush_Batch)`
* `Get_State() -> State`
* `Get_Stats(out Stats)`

---

ここまでが**実装者向けの“何を作り、どのAdaモジュールで作るか”の合意ベース**です。次の一歩として、`ZEB.ZM` の最小 FFI マップと `ZEB.Buffer` の SPARK 仕様（不変条件）を先に固め、並行して CLI ハーネスの骨組みを用意すると開発が滑らかになります。

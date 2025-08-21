# AGENTS instructions for load_image

- ここではAda 2022を使用してください。
- ソースコードとテストはこのフォルダ内で完結させてください。
- 変更を加えたら `gprbuild -p -P load_image.gpr` を実行し、`./obj/test_load_image` でテストを実行してください。

## Struggles
- BMPヘッダのパディングとカラーテーブルの扱いに悩みましたが、仕様を読み解いて対応しました。

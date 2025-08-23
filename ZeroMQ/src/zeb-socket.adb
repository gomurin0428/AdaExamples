with ZEB.Types;
with ZEB.Errors;
with ZEB.Config;
with ZEB.Metrics;

package body ZEB.Socket is
   function Create(Kind : Kind_Type; Options : ZEB.Config.Options) return Socket is
      S : Socket := (Kind => Kind, Options => Options, State => ZEB.Types.Disconnected);
   begin
      return S;
   end Create;

   function Open(S : in out Socket; Endpoint : String; Connect_Mode : Boolean) return ZEB.Errors.Result is
      pragma Unreferenced(Endpoint, Connect_Mode);
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      S.State := ZEB.Types.Connected;
      return Res;
   end Open;

   function Start(S : in out Socket) return ZEB.Errors.Result is
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      S.State := ZEB.Types.Connected;
      return Res;
   end Start;

   function Stop(S : in out Socket) return ZEB.Errors.Result is
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      S.State := ZEB.Types.Disconnected;
      return Res;
   end Stop;

   function Send(S : in out Socket; Msg : ZEB.Types.Message) return ZEB.Errors.Result is
      pragma Unreferenced(S, Msg);
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      return Res;
   end Send;

   function Call(
      S      : in out Socket;
      Req    : ZEB.Types.Message;
      Timeout: Duration;
      Reply  : out ZEB.Types.Message
   ) return ZEB.Errors.Result is
      pragma Unreferenced(S, Timeout);
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      Reply := Req;
      return Res;
   end Call;

   function Subscribe(S : in out Socket; Prefix : String) return ZEB.Errors.Result is
      pragma Unreferenced(S, Prefix);
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      return Res;
   end Subscribe;

   function Unsubscribe(S : in out Socket; Prefix : String) return ZEB.Errors.Result is
      pragma Unreferenced(S, Prefix);
      Res : ZEB.Errors.Result;
   begin
      Res.Ok := True;
      return Res;
   end Unsubscribe;

   procedure Enable_Spool(S : in out Socket; Dir : String; Max_Bytes : Natural; Flush_Batch : Natural) is
      pragma Unreferenced(S, Dir, Max_Bytes, Flush_Batch);
   begin
      null;
   end Enable_Spool;

   function Get_State(S : Socket) return ZEB.Types.State is
   begin
      return S.State;
   end Get_State;

   procedure Get_Stats(S : Socket; Stats : out ZEB.Metrics.Stats) is
      pragma Unreferenced(S);
   begin
      ZEB.Metrics.Snapshot(Stats);
   end Get_Stats;
end ZEB.Socket;

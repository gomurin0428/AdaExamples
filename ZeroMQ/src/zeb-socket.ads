with ZEB.Types;
with ZEB.Errors;
with ZEB.Config;
with ZEB.Metrics;

package ZEB.Socket is
   type Kind_Type is (PUB, SUB, PUSH, PULL, REQ, REP);

   type Socket is limited private;

   function Create(Kind : Kind_Type; Options : ZEB.Config.Options) return Socket;
   function Open(S : in out Socket; Endpoint : String; Connect_Mode : Boolean) return ZEB.Errors.Result;
   function Start(S : in out Socket) return ZEB.Errors.Result;
   function Stop(S : in out Socket) return ZEB.Errors.Result;
   function Send(S : in out Socket; Msg : ZEB.Types.Message) return ZEB.Errors.Result;
   function Call(
      S      : in out Socket;
      Req    : ZEB.Types.Message;
      Timeout: Duration;
      Reply  : out ZEB.Types.Message
   ) return ZEB.Errors.Result;
   function Subscribe(S : in out Socket; Prefix : String) return ZEB.Errors.Result;
   function Unsubscribe(S : in out Socket; Prefix : String) return ZEB.Errors.Result;
   procedure Enable_Spool(S : in out Socket; Dir : String; Max_Bytes : Natural; Flush_Batch : Natural);
   function Get_State(S : Socket) return ZEB.Types.State;
   procedure Get_Stats(S : Socket; Stats : out ZEB.Metrics.Stats);
private
   type Socket is record
      Kind    : Kind_Type;
      Options : ZEB.Config.Options;
      State   : ZEB.Types.State := ZEB.Types.Disconnected;
   end record;
end ZEB.Socket;

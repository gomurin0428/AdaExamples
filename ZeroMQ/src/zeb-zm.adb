package body ZEB.ZM is
   function Ctx_New return Context is
      C : Context;
   begin
      return C;
   end Ctx_New;

   procedure Ctx_Destroy(Ctx : in out Context) is
      pragma Unreferenced(Ctx);
   begin
      null;
   end Ctx_Destroy;

   function Socket_New return Socket is
      S : Socket;
   begin
      return S;
   end Socket_New;

   procedure Socket_Close(S : in out Socket) is
      pragma Unreferenced(S);
   begin
      null;
   end Socket_Close;

   function Send(S : Socket; Data : String) return Boolean is
      pragma Unreferenced(S, Data);
   begin
      return True;
   end Send;

   function Recv(S : Socket) return String is
      pragma Unreferenced(S);
   begin
      return "";
   end Recv;
end ZEB.ZM;

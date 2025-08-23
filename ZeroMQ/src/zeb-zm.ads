package ZEB.ZM is
   type Context is limited private;
   type Socket  is limited private;

   function Ctx_New return Context;
   procedure Ctx_Destroy(Ctx : in out Context);

   function Socket_New return Socket;
   procedure Socket_Close(S : in out Socket);

   function Send(S : Socket; Data : String) return Boolean;
   function Recv(S : Socket) return String;
private
   type Context is null record;
   type Socket  is null record;
end ZEB.ZM;

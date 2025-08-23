with ZEB.Types;

package ZEB.Dispatch is
   type Handler is access procedure (Msg : ZEB.Types.Message);

   procedure Set_Handler(H : Handler);
   procedure Deliver(Msg : ZEB.Types.Message);
end ZEB.Dispatch;

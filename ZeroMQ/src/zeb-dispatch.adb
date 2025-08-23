with ZEB.Types;

package body ZEB.Dispatch is
   Current_Handler : Handler := null;

   procedure Set_Handler(H : Handler) is
   begin
      Current_Handler := H;
   end Set_Handler;

   procedure Deliver(Msg : ZEB.Types.Message) is
   begin
      if Current_Handler /= null then
         Current_Handler(Msg);
      end if;
   end Deliver;
end ZEB.Dispatch;

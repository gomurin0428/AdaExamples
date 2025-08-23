with ZEB.Types;

package ZEB.Spool is
   type Handle is limited private;

   procedure Enable(H : in out Handle; Dir : String; Max_Bytes : Natural; Flush_Batch : Natural);
   procedure Enqueue_For_Resend(H : in out Handle; Msg : ZEB.Types.Message);
   procedure Next_Batch(H : in out Handle; Batch_Size : Natural);
   procedure Ack(H : in out Handle; Count : Natural);
private
   type Handle is null record;
end ZEB.Spool;

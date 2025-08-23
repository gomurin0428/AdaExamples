with ZEB.Types;

package body ZEB.Spool is
   procedure Enable(H : in out Handle; Dir : String; Max_Bytes : Natural; Flush_Batch : Natural) is
      pragma Unreferenced(H, Dir, Max_Bytes, Flush_Batch);
   begin
      null;
   end Enable;

   procedure Enqueue_For_Resend(H : in out Handle; Msg : ZEB.Types.Message) is
      pragma Unreferenced(H, Msg);
   begin
      null;
   end Enqueue_For_Resend;

   procedure Next_Batch(H : in out Handle; Batch_Size : Natural) is
      pragma Unreferenced(H, Batch_Size);
   begin
      null;
   end Next_Batch;

   procedure Ack(H : in out Handle; Count : Natural) is
      pragma Unreferenced(H, Count);
   begin
      null;
   end Ack;
end ZEB.Spool;

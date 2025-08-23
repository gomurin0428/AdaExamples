package body ZEB.Retry is
   function Next_Backoff(Try : Natural) return Duration is
      pragma Unreferenced(Try);
   begin
      return 0.0;
   end Next_Backoff;

   procedure Reset is
   begin
      null;
   end Reset;
end ZEB.Retry;

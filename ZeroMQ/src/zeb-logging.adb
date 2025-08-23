package body ZEB.Logging is
   Current_Sink : Log_Sink := null;

   procedure Set_Sink(Sink : Log_Sink) is
   begin
      Current_Sink := Sink;
   end Set_Sink;

   procedure Log(Level : Log_Level; Message : String) is
   begin
      if Current_Sink /= null then
         Current_Sink(Level, Message);
      end if;
   end Log;
end ZEB.Logging;

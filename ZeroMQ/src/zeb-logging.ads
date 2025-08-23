package ZEB.Logging is
   type Log_Level is (Debug, Info, Warn, Error);
   type Log_Sink is access procedure (Level : Log_Level; Message : String);

   procedure Set_Sink(Sink : Log_Sink);
   procedure Log(Level : Log_Level; Message : String);
end ZEB.Logging;

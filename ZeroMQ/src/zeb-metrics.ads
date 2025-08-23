package ZEB.Metrics is
   type Stats is record
      Sent        : Natural := 0;
      Received    : Natural := 0;
      Dropped     : Natural := 0;
      Reconnects  : Natural := 0;
      Spool_Bytes : Natural := 0;
   end record;

   procedure Increment_Sent;
   procedure Increment_Received;
   procedure Increment_Dropped;
   procedure Increment_Reconnects;
   procedure Set_Spool_Bytes(Count : Natural);

   procedure Snapshot(S : out Stats);
end ZEB.Metrics;

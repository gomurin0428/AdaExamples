package body ZEB.Metrics is
   G_Stats : Stats;

   procedure Increment_Sent is
   begin
      G_Stats.Sent := G_Stats.Sent + 1;
   end Increment_Sent;

   procedure Increment_Received is
   begin
      G_Stats.Received := G_Stats.Received + 1;
   end Increment_Received;

   procedure Increment_Dropped is
   begin
      G_Stats.Dropped := G_Stats.Dropped + 1;
   end Increment_Dropped;

   procedure Increment_Reconnects is
   begin
      G_Stats.Reconnects := G_Stats.Reconnects + 1;
   end Increment_Reconnects;

   procedure Set_Spool_Bytes(Count : Natural) is
   begin
      G_Stats.Spool_Bytes := Count;
   end Set_Spool_Bytes;

   procedure Snapshot(S : out Stats) is
   begin
      S := G_Stats;
   end Snapshot;
end ZEB.Metrics;

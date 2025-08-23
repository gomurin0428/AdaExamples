package ZEB.Retry is
   function Next_Backoff(Try : Natural) return Duration;
   procedure Reset;
end ZEB.Retry;

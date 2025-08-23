with Ada.Real_Time; use Ada.Real_Time;

package body ZEB.Time is
   function Monotonic_Now return Ada.Real_Time.Time is
   begin
      return Clock;
   end Monotonic_Now;

   function Elapsed(Start : Ada.Real_Time.Time) return Duration is
   begin
      return To_Duration(Clock - Start);
   end Elapsed;
end ZEB.Time;

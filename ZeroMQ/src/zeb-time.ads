with Ada.Real_Time;

package ZEB.Time is
   function Monotonic_Now return Ada.Real_Time.Time;
   function Elapsed(Start : Ada.Real_Time.Time) return Duration;
end ZEB.Time;

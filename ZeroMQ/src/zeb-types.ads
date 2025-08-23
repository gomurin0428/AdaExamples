with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Real_Time; use Ada.Real_Time;

package ZEB.Types is
   type Payload_Kind is (Text, Bytes);
   type State is (Disconnected, Connecting, Connected, Backing_Off);

   type Message is record
      Topic : Unbounded_String;
      Kind  : Payload_Kind := Text;
      Data  : Unbounded_String;
      Stamp : Time := Time_First;
   end record;
end ZEB.Types;

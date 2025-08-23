with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package ZEB.Buffer is
   subtype Element is Unbounded_String;
   type Buffer (Capacity : Positive) is limited private;

   procedure Push(B : in out Buffer; Item : Element);
   function Pop(B : in out Buffer) return Element;
   function Is_Empty(B : Buffer) return Boolean;
private
   type Element_Array is array (Positive range <>) of Element;
   type Buffer (Capacity : Positive) is record
      Data  : Element_Array(1 .. Capacity);
      Head  : Natural := 1;
      Tail  : Natural := 1;
      Count : Natural := 0;
   end record;
end ZEB.Buffer;

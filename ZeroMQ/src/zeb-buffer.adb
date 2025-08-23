with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body ZEB.Buffer is
   procedure Push(B : in out Buffer; Item : Element) is
   begin
      if B.Count < B.Capacity then
         B.Data(B.Tail) := Item;
         B.Tail := (B.Tail mod B.Capacity) + 1;
         B.Count := B.Count + 1;
      end if;
   end Push;

   function Pop(B : in out Buffer) return Element is
      Result : Element := Null_Unbounded_String;
   begin
      if B.Count > 0 then
         Result := B.Data(B.Head);
         B.Head := (B.Head mod B.Capacity) + 1;
         B.Count := B.Count - 1;
      end if;
      return Result;
   end Pop;

   function Is_Empty(B : Buffer) return Boolean is
   begin
      return B.Count = 0;
   end Is_Empty;
end ZEB.Buffer;

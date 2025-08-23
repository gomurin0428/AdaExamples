with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body ZEB.Curve is
   procedure Generate(
      Pub_Z85 : out Unbounded_String;
      Sec_Z85 : out Unbounded_String
   ) is
   begin
      Pub_Z85 := Null_Unbounded_String;
      Sec_Z85 := Null_Unbounded_String;
   end Generate;

   function Validate(Key : String) return Boolean is
      pragma Unreferenced(Key);
   begin
      return False;
   end Validate;
end ZEB.Curve;

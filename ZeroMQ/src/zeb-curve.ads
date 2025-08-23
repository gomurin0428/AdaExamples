with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package ZEB.Curve is
   procedure Generate(
      Pub_Z85 : out Unbounded_String;
      Sec_Z85 : out Unbounded_String
   );
   function Validate(Key : String) return Boolean;
end ZEB.Curve;

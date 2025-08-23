with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package ZEB.Errors is
   type Error_Code is (
      Timeout,
      Not_Connected,
      Invalid_Option,
      Curve_Key_Error,
      HWM_Exceeded,
      Spool_Overflow,
      ZMQ_EAGAIN
   );

   type Result is record
      Ok     : Boolean := False;
      Code   : Error_Code := Timeout;
      Detail : Unbounded_String;
   end record;
end ZEB.Errors;

with Ada.Text_IO;
with Bmp;
use Bmp;

procedure Test_Bmp is
   Expected : constant Pixel_Array (1 .. 2, 1 .. 2) :=
     [ [0, 85],
       [170, 255] ];
   Width       : Natural;
   Height      : Natural;
   Data        : Pixel_Array_Access;
   Round_Trip  : Pixel_Array_Access;
begin
   Load_BMP ("sample.bmp", Width, Height, Data);
   Ada.Text_IO.Put_Line ("Width=" & Width'Image & " Height=" & Height'Image);
   if Data /= null then
      if Data.all /= Expected then
         raise Program_Error with "Data mismatch";
      end if;

      Save_BMP ("out.bmp", Width, Height, Data.all);
      Load_BMP ("out.bmp", Width, Height, Round_Trip);
      if Round_Trip = null or else Round_Trip.all /= Data.all then
         raise Program_Error with "Round-trip mismatch";
      end if;

      Ada.Text_IO.Put_Line ("First pixel=" & Integer (Data.all (1, 1))'Image);
   end if;
end Test_Bmp;

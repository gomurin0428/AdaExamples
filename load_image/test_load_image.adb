with Ada.Text_IO;
with Load_Image;
use type Load_Image.Pixel_Array_Access;

procedure Test_Load_Image is
   Width  : Natural;
   Height : Natural;
   Data   : Load_Image.Pixel_Array_Access;
begin
   Load_Image.Load_BMP ("sample.bmp", Width, Height, Data);
   Ada.Text_IO.Put_Line ("Width=" & Width'Image & " Height=" & Height'Image);
   if Data /= null then
      Ada.Text_IO.Put_Line ("First pixel=" & Integer(Data.all (1, 1))'Image);
   end if;
end Test_Load_Image;

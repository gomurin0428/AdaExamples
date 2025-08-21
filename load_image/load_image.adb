with Ada.Streams; use Ada.Streams;
with Ada.Streams.Stream_IO;

package body Load_Image is
   use Interfaces;

   function U32_LE (Arr : Stream_Element_Array; I : Stream_Element_Offset) return Unsigned_32 is
      (Unsigned_32 (Arr (I))
       or Shift_Left (Unsigned_32 (Arr (I + 1)), 8)
       or Shift_Left (Unsigned_32 (Arr (I + 2)), 16)
       or Shift_Left (Unsigned_32 (Arr (I + 3)), 24));

   function U16_LE (Arr : Stream_Element_Array; I : Stream_Element_Offset) return Unsigned_16 is
      (Unsigned_16 (Arr (I))
       or Shift_Left (Unsigned_16 (Arr (I + 1)), 8));

   procedure Load_BMP (Filename : String;
                      Width, Height : out Natural;
                      Data : out Pixel_Array_Access) is
      use Ada.Streams.Stream_IO;
      File : File_Type;
      Header : Stream_Element_Array (1 .. 54);
      Last   : Stream_Element_Offset;
   begin
      Width := 0;
      Height := 0;
      Data := null;

      Open (File, In_File, Filename);
      Read (File, Header, Last);
      if Character'Val (Integer (Header (1))) /= 'B'
        or else Character'Val (Integer (Header (2))) /= 'M'
      then
         raise Program_Error with "Not BMP";
      end if;

      declare
         Offset : constant Unsigned_32 := U32_LE (Header, 11);
         Bits   : constant Unsigned_16 := U16_LE (Header, 29);
      begin
         Width  := Natural (U32_LE (Header, 19));
         Height := Natural (U32_LE (Header, 23));
         if Bits /= 8 then
            raise Program_Error with "Only 8-bit supported";
         end if;
         if Offset > 54 then
            declare
               Skip : Stream_Element_Array (1 .. Stream_Element_Offset (Integer (Offset) - 54));
            begin
               Read (File, Skip, Last);
            end;
         end if;
      end;

      declare
         Row_Size : constant Stream_Element_Offset := Stream_Element_Offset (((Width + 3) / 4) * 4);
         Row      : Stream_Element_Array (1 .. Row_Size);
      begin
         Data := new Pixel_Array (1 .. Height, 1 .. Width);
         for Y in reverse 1 .. Height loop
            Read (File, Row, Last);
            for X in 1 .. Width loop
               Data (Y, X) := Unsigned_8 (Row (Stream_Element_Offset (X)));
            end loop;
         end loop;
      end;
      Close (File);
   end Load_BMP;
end Load_Image;

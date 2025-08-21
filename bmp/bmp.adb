with Ada.Streams; use Ada.Streams;
with Ada.Streams.Stream_IO;

package body Bmp is
   use Interfaces;

   function U32_LE (Arr : Stream_Element_Array; I : Stream_Element_Offset) return Unsigned_32 is
      (Unsigned_32 (Arr (I))
       or Shift_Left (Unsigned_32 (Arr (I + 1)), 8)
       or Shift_Left (Unsigned_32 (Arr (I + 2)), 16)
       or Shift_Left (Unsigned_32 (Arr (I + 3)), 24));

   function U16_LE (Arr : Stream_Element_Array; I : Stream_Element_Offset) return Unsigned_16 is
      (Unsigned_16 (Arr (I))
       or Shift_Left (Unsigned_16 (Arr (I + 1)), 8));

   procedure Set_U32_LE (Arr : in out Stream_Element_Array;
                         I   : Stream_Element_Offset;
                         V   : Unsigned_32) is
   begin
      Arr (I)     := Stream_Element (V and 16#FF#);
      Arr (I + 1) := Stream_Element (Shift_Right (V, 8) and 16#FF#);
      Arr (I + 2) := Stream_Element (Shift_Right (V, 16) and 16#FF#);
      Arr (I + 3) := Stream_Element (Shift_Right (V, 24) and 16#FF#);
   end Set_U32_LE;

   procedure Set_U16_LE (Arr : in out Stream_Element_Array;
                         I   : Stream_Element_Offset;
                         V   : Unsigned_16) is
   begin
      Arr (I)     := Stream_Element (V and 16#FF#);
      Arr (I + 1) := Stream_Element (Shift_Right (V, 8) and 16#FF#);
   end Set_U16_LE;

   procedure Load_BMP (Filename : String;
                      Width, Height : out Natural;
                      Data : out Pixel_Array_Access) is
      use Ada.Streams.Stream_IO;
      File   : File_Type;
      Header : Stream_Element_Array (1 .. 54);
      Last   : Stream_Element_Offset;
   begin
      Width  := 0;
      Height := 0;
      Data   := null;

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

   procedure Save_BMP (Filename : String;
                      Width, Height : Natural;
                      Data : Pixel_Array) is
      use Ada.Streams.Stream_IO;
      File    : File_Type;
      Header  : Stream_Element_Array (1 .. 54);
      Palette : Stream_Element_Array (1 .. 256 * 4);
      Row_Size : constant Stream_Element_Offset :=
        Stream_Element_Offset (((Width + 3) / 4) * 4);
      Row : Stream_Element_Array (1 .. Row_Size);
   begin
      Create (File, Out_File, Filename);

      Header := [others => 0];
      Header (1) := Stream_Element (Character'Pos ('B'));
      Header (2) := Stream_Element (Character'Pos ('M'));
      Set_U32_LE (Header, 3,
                  Unsigned_32 (54 + 256 * 4 + Integer (Row_Size) * Height));
      Set_U32_LE (Header, 11, Unsigned_32 (54 + 256 * 4));
      Set_U32_LE (Header, 15, Unsigned_32 (40));
      Set_U32_LE (Header, 19, Unsigned_32 (Width));
      Set_U32_LE (Header, 23, Unsigned_32 (Height));
      Set_U16_LE (Header, 27, Unsigned_16 (1));
      Set_U16_LE (Header, 29, Unsigned_16 (8));
      Set_U32_LE (Header, 31, Unsigned_32 (0));
      Set_U32_LE (Header, 35,
                  Unsigned_32 (Integer (Row_Size) * Height));
      Set_U32_LE (Header, 39, Unsigned_32 (0));
      Set_U32_LE (Header, 43, Unsigned_32 (0));
      Set_U32_LE (Header, 47, Unsigned_32 (256));
      Set_U32_LE (Header, 51, Unsigned_32 (0));
      Write (File, Header);

      for I in 0 .. 255 loop
         Palette (Stream_Element_Offset (I * 4 + 1)) := Stream_Element (I);
         Palette (Stream_Element_Offset (I * 4 + 2)) := Stream_Element (I);
         Palette (Stream_Element_Offset (I * 4 + 3)) := Stream_Element (I);
         Palette (Stream_Element_Offset (I * 4 + 4)) := 0;
      end loop;
      Write (File, Palette);

      for Y in reverse 1 .. Height loop
         for X in 1 .. Width loop
            Row (Stream_Element_Offset (X)) := Stream_Element (Data (Y, X));
         end loop;
         for X in Width + 1 .. Integer (Row_Size) loop
            Row (Stream_Element_Offset (X)) := 0;
         end loop;
         Write (File, Row);
      end loop;

      Close (File);
   end Save_BMP;
end Bmp;

with Interfaces;

package Bmp is
   --  8ビットグレイスケールBMPを読み書きする
   type Pixel_Array is array (Positive range <>, Positive range <>) of Interfaces.Unsigned_8;
   type Pixel_Array_Access is access Pixel_Array;

   procedure Load_BMP (Filename : String;
                      Width, Height : out Natural;
                      Data : out Pixel_Array_Access);

   procedure Save_BMP (Filename : String;
                      Width, Height : Natural;
                      Data : Pixel_Array);
end Bmp;

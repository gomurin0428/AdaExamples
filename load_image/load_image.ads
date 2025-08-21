with Interfaces;

package Load_Image is
   --  8ビットグレイスケールBMPを読み込む
   type Pixel_Array is array (Positive range <>, Positive range <>) of Interfaces.Unsigned_8;
   type Pixel_Array_Access is access Pixel_Array;

   procedure Load_BMP (Filename : String;
                      Width, Height : out Natural;
                      Data : out Pixel_Array_Access);
end Load_Image;

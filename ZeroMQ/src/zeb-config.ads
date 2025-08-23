package ZEB.Config is
   type Options is record
      Snd_HWM       : Natural := 0;
      Rcv_HWM       : Natural := 0;
      Linger_ms     : Natural := 0;
      RcvTimeout_ms : Natural := 0;
      SndTimeout_ms : Natural := 0;
      Immediate     : Boolean := False;
      KeepAlive     : Boolean := False;
      Reconnect_Min : Natural := 0;
      Reconnect_Max : Natural := 0;
   end record;
end ZEB.Config;

function r_now, mode, yr, mn, dy, hr, mi, se
  if ~keyword_set(mode) then mode = 0
  if keyword_set(yr) then begin
    if ~keyword_set(dy) then dy = 0
    if ~keyword_set(hr) then hr = 0
    if ~keyword_set(mi) then mi = 0
    if ~keyword_set(se) then se = 0
    bd = [yr, mn, dy, hr, mi, se]
  endif else begin
    bd = bin_date(systime())
  endelse
  case mode of
     1: s = string(bd[0:2], format='(I4.4,"-",I2.2,"-",I2.2                            )') ; yyyy-mm-dd
     2: s = string(bd[0:1], format='(I4.4,"-",I2.2                                     )') ; yyyy-mm
    11: s = string(bd[0:2], format='(I4.4,    I2.2,    I2.2                            )') ; yyyymmdd
    12: s = string(bd[0:1], format='(I4.4,    I2.2                                     )') ; yyyymm
    -1: s = string(bd[3:5], format='(                            I2.2,":",I2.2,":",I2.2)') ; hh:mm:ss
    -2: s = string(bd[3:4], format='(                            I2.2,":",I2.2         )') ; hh:mm
   -11: s = string(bd[3:5], format='(                            I2.2,    I2.2,    I2.2)') ; hhmmss
   -12: s = string(bd[3:4], format='(                            I2.2,    I2.2         )') ; hhmm
    10: s = string(bd[0:5], format='(I4.4,    I2.2,    I2.2,     I2.2,    I2.2,    I2.2)') ; yyyymmddhhmmss
  else: s = string(bd[0:5], format='(I4.4,"-",I2.2,"-",I2.2," ", I2.2,":",I2.2,":",I2.2)') ; yyyy-mm-dd hh:mm:ss
  endcase
  return, s
end

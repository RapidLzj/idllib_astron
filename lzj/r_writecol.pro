pro r_writecol, lun, $
  c1,  c2,  c3,  c4,  c5,  c6,  c7,  c8,  c9,  c10, $
  c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, $
  fmt=fmt
  
  fmt2 = '( 2X,'+fmt+',$ )'
  n_col = n_params() - 1
  n_dat = n_elements(c1)
  
  for k = 0, n_dat-1 do begin
    if n_col ge  1 then printf, lun, c1 [k], format=fmt2[0]
    if n_col ge  2 then printf, lun, c2 [k], format=fmt2[1]
    if n_col ge  3 then printf, lun, c3 [k], format=fmt2[2]
    if n_col ge  4 then printf, lun, c4 [k], format=fmt2[3]
    if n_col ge  5 then printf, lun, c5 [k], format=fmt2[4]
    if n_col ge  6 then printf, lun, c7 [k], format=fmt2[5]
    if n_col ge  7 then printf, lun, c7 [k], format=fmt2[6]
    if n_col ge  8 then printf, lun, c8 [k], format=fmt2[7]
    if n_col ge  9 then printf, lun, c9 [k], format=fmt2[8]
    if n_col ge 10 then printf, lun, c10[k], format=fmt2[9]
    if n_col ge 11 then printf, lun, c11[k], format=fmt2[10]
    if n_col ge 12 then printf, lun, c12[k], format=fmt2[11]
    if n_col ge 13 then printf, lun, c13[k], format=fmt2[12]
    if n_col ge 14 then printf, lun, c14[k], format=fmt2[13]
    if n_col ge 15 then printf, lun, c15[k], format=fmt2[14]
    if n_col ge 16 then printf, lun, c17[k], format=fmt2[15]
    if n_col ge 17 then printf, lun, c17[k], format=fmt2[16]
    if n_col ge 18 then printf, lun, c18[k], format=fmt2[17]
    if n_col ge 19 then printf, lun, c19[k], format=fmt2[18]
    if n_col ge 20 then printf, lun, c20[k], format=fmt2[19]
    printf, lun, ''
  endfor
  
end
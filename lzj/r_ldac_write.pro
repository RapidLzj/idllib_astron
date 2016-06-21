pro r_ldac_write, file, data, header, data2, data3, data4, data5, $
  silent=silent
  if n_params() ge 3 then begin
    ; create fits, write head and empty data
    mwrfits, 0, file, header, /create, silent=silent
    ; append ldac data (structure array)
    mwrfits, data, file, silent=silent
  endif else begin
    mwrfits, data, file, /create, silent=silent
  endelse
  ; append other data if present
  if n_params() ge 4 then mwrfits, data2, file, silent=silent
  if n_params() ge 5 then mwrfits, data3, file, silent=silent
  if n_params() ge 6 then mwrfits, data4, file, silent=silent
  if n_params() ge 7 then mwrfits, data5, file, silent=silent
end 
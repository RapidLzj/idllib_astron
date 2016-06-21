function r_ldac_read, file, header, data2, data3, data4, data5, ext=ext, $
  silent=silent
  ; read ldac data from fits written by ldac_write
  if ~keyword_set(ext) then ext = 1
  ; read data
  data = mrdfits(file, ext, silent=silent)
  ; read header
  if n_params() ge 2 then header = headfits(file)
  ; read extra data
  if n_params() ge 3 then data2 = mrdfits(file, ext+1, silent=silent)
  if n_params() ge 4 then data3 = mrdfits(file, ext+2, silent=silent)
  if n_params() ge 5 then data4 = mrdfits(file, ext+3, silent=silent)
  if n_params() ge 6 then data5 = mrdfits(file, ext+4, silent=silent)

  return, data
end
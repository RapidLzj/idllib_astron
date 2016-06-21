function r_sdss, imctra, imctdec, n_cata, fov, filename=filename, $
  silent=silent, maglimit=maglimit, refresh=refresh
  
  if ~keyword_set(fov) then fov = 1.25
  if ~keyword_set(n_cata) then n_cata = 1000
  silent = keyword_set(silent)
  if n_elements(maglimit) eq 0 then $
    maglimit = [8.0,20.0] $
  else if n_elements(maglimit) eq 1 then $
    maglimit = [maglimit, 20.0]
  if keyword_set(refresh) then file_delete, filename, /allow

  n_redo = 0

redo:
  n_redo++
  strra  = r_hms(imctra/15.0)
  strdec = r_hms(imctdec)
  ;scatcmd = 'scat -c ub1 -s m1 -hn 1500 -r I4 A A ' + strra + ' ' + strdec + ' J2000 > ' + filename
  extfov = fov / sqrt(2.0)  + 0.5  ; fov plus 0.5 bias
  n2 = n_cata * (maglimit[0] - 7.0)
  scatcmd = string(n2, extfov*3600, maglimit, strra, strdec, filename, $
    format='("scat -c sdss -s m1 -d -h -n ",I5," -r ",I5," -m ",F4.1,",",F4.1," ",A," ",A," J2000 > ",A)')
  if ~silent then print, scatcmd
  if ~ file_test(filename) then begin
    print, 'sdss SCATing....'
    spawn, scatcmd ;, lines
  endif

  line = '' & lines = line
  openr, lun, filename, /get_lun
  readf, lun, lines
  while not eof(lun) do begin readf, lun, line & lines = [lines, line] & endwhile
  free_lun, lun
    
  if n_elements(lines) le 4 then begin  ;file error, redo scat
    file_delete, filename
    if n_redo lt 3 then goto, redo else return, {radeg:0.0d, decdeg:0.0d}
  endif

  a=strsplit(lines[4],' ',/ex)
  nf= n_elements(a)
  cata1=create_struct(a[0],'')
   
  ;for i = 1 , 2 do $ 
  ;  cata1 = create_struct(cata1, a[i],'')
  for i = 1 , nf-1 do $  ;first col is catalog number, omitted 
    cata1 = create_struct(cata1, a[i], 0.0d)
  cata1 = create_struct(cata1, 'RADEG',0.0d, 'DECDEG',0.0d)

  k = 0
  cata = cata1
  for k = 5, n_elements(lines)-1 do begin
    a = strsplit(lines[k],' ',/ex) 
    for i = 0, nf-1 do cata1.(i) = a[i] 
    cata1.RADEG  = a[1] ; hms2dec(a[1]) * 15.0d
    cata1.DECDEG = a[2] ; hms2dec(a[2])
    cata = [cata, cata1]
  endfor
  cata = cata[1:*]

  ; remove catalog stars outside the area
  ra_scale = cos(imctdec * !pi / 180.0)
  ct_dis   = sqrt( ((cata.radeg-imctra)*ra_scale) ^ 2.0 + (cata.decdeg-imctdec) ^ 2.0)
  ix = where( ct_dis le extfov * sqrt(2.0) and cata.magb1 gt 7.5, nix)
  if nix eq 0 then begin  ;file error, redo scat
    file_delete, filename
    if n_redo lt 3 then goto, redo
    ix = 0
  endif 
  cata = cata[ix]
  
  ix = sort(cata.magu)
  nc = n_elements(cata)
  cata = cata[ix[0:(n_cata<nc)-1]]
  
  return, cata
end


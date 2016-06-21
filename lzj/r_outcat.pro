pro r_outcat, cat, lun, ixfield, fmt
  nix  = n_elements(ixfield)
  ncat = n_elements(cat)

  ; list all fields
  tags = tag_names(cat[0])
  fmtt = fmt
  for gg = 0, nix-1 do begin
    printf, lun, format='("#",I-2,2X,A-30,A-6)', gg+1, tags[ixfield[gg]], fmt[gg]
    fmtt[gg] = '(2x,A' + strn(fix(strmid(fmt[gg], 1))) + ',$)'
  endfor
  fmtt[0] = '(1x' + strmid(fmtt[0], 3)

  ; print header
  printf, lun, format='("#",$)'
  for gg = 0, nix-1 do begin
    printf, lun, strn(gg+1), format=fmtt[gg]
  endfor
  printf, lun, ''
  printf, lun, format='("#",$)'
  for gg = 0, nix-1 do begin
    printf, lun, tags[ixfield[gg]], format=fmtt[gg]
  endfor
  printf, lun, ''

  ; data
  fmt2 = '(2X,'+fmt+',$)'
  for ss = 0L, ncat-1 do begin
    for gg = 0, nix-1 do begin
      printf, lun, cat[ss].(ixfield[gg]), format=fmt2[gg]
    endfor
    printf, lun, ''
  endfor

end
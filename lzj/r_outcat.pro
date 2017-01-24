pro r_outcat, cat, lun, ixfield, fmt
  nix  = n_elements(ixfield)
  ncat = n_elements(cat)

  ; list all fields
  tags = ['SN', tag_names(cat[0])]
  fmtt = fmt ; format for header tag
  for gg = 0, nix-1 do begin
    printf, lun, format='("#",I-2,2X,A-30,A-15)', gg+1, tags[ixfield[gg]+1], fmt[gg]
    ;fmtt[gg] = '(2x,A' + strn(fix(strmid(fmt[gg], 1))) + ',$)' ; judge width of field
    sample = string(cat[0].(ixfield[gg]), format='('+fmt[gg]+')')
    fmtt[gg] = '(2x,A'+strn(strlen(sample))+',$)' ;20161129: judge length by sample
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
    printf, lun, tags[ixfield[gg]+1], format=fmtt[gg]
  endfor
  printf, lun, ''

  ; data
  fmt2 = '(2X,'+fmt+',$)'
  for ss = 0L, ncat-1 do begin
    for gg = 0, nix-1 do begin
      if ixfield[gg] ge 0 then begin
        printf, lun, cat[ss].(ixfield[gg]), format=fmt2[gg]
      endif else begin
        printf, lun, ss+1, format=fmt2[gg]
      endelse
    endfor
    printf, lun, ''
  endfor

end
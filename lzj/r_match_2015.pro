;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTION r_MATCH
; match stars by matching ad
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function r_match, u1, v1, mag1, u2, v2, mag2, $
  nmatch, id1, id2, dis12, $
  maxdis=maxdis, $         ; max distance of matching, in degree
  maxmag=maxmag, $         ; max mag difference, default 1.5 sigma
  matchlimit=matchlimit, $ ; match number limit, lower then limit will fail
  nosigma=nosigma, $       ; if set, donot check mag difference
  multimatch=multimatch    ; if set, donot check duplicate match
  
; input:  ra/dec/mag of 2 star lists
; output: matched star id
; optional input: max distance for match, default 1 as

  if ~keyword_set(maxdis) then maxdis = 1.0d / 3600.0d
  if ~keyword_set(maxmag) then maxmag = 0.5d
  if ~keyword_set(matchlimit) then matchlimit = 10
  nosigma = keyword_set(nosigma)
  multimatch = keyword_set(multimatch)
 
  n1 = n_elements(u1)
  n2 = n_elements(u2)

  ; leading virtual item
  id1 = [-1L] & id2 = [-1L] & dis12 = [0.0] & nmatch = 0L
  
  ; six: sort by v1, rix: reverse index from six back to original order
  six1 = sort(v1) & six2 = sort(v2)
  rix1 = lonarr(n1) & rix1[six1] = lindgen(n1) & rix2 = lonarr(n2) & rix2[six2] = lindgen(n2)
  u1s = u1[six1] & v1s = v1[six1] & mag1s = mag1[six1]
  u2s = u2[six2] & v2s = v2[six2] & mag2s = mag2[six2]
  
  uscale = cos(median(v1) * !pi / 180.0)
  ; from top, walk down. for [p1], [p2f:p2t] is dec near stars, find match in small range
  p2f = 0 & p2t = 0
  for p1 = 0, n1-1 do begin
    ; p2f walk down to the first item gt [p1]-dis, and p2t to first item gt [p1]+dis
    while p2f lt n2 && v2s[p2f] lt v1s[p1]-maxdis do p2f++
    while p2t lt n2 && v2s[p2t] le v1s[p1]+maxdis do p2t++
    ;;debug print, p1, p2f, p2t, v1s[p1],v2s[p2f:p2t-1]
    ; exit when p2f runout
    if p2f ge n2 then break
    ; p1 skip when no near star
    if p2t - p2f lt 1 then continue
    ; find real near stars, consider u1&u2
    dis = sqrt( ((u1s[p1] - u2s[p2f:p2t-1]) / uscale)^2.0 + (v1s[p1] - v2s[p2f:p2t-1])^2.0 )
    ;;debug print, dis
    ix2 = where(dis le maxdis, nix2)
    if nix2 gt 0 then begin
      id1 = [id1, replicate(p1, nix2)]
      id2 = [id2, p2f + ix2]
      dis12 = [dis12, dis[ix2]]
      nmatch += nix2
    endif ; nix2
  endfor
  ;;debug print, nmatch
  
  ; check match limit and remove leading virtual item
  if nmatch lt matchlimit then return, -1
  id1 = id1[1:*] & id2 = id2[1:*] & dis12 = dis12[1:*]
  
  ; return id from sorted to original
  id1 = rix1[id1] & id2 = rix2[id2]
  
  ; remove matches of too different mag
  if nosigma then begin ;no sigma exclude of mag
    ;res = sqrt( total(dis12^2) / nmatch / (nmatch-3>1) )
  endif else begin ; find most possible mag diff

    ; check mag difference, fit the curve of mag1 vs mag2, remove over 1.5 sigma
    mag_diff = mag2[id2] - mag1[id1]
    meanclip, mag_diff, mag_med, mag_std

    ix = where( abs(mag_diff - mag_med) lt 1.5*mag_std , nmatch)
    ;ix = where( abs(mag_diff - mag_med) lt maxmag , nmatch)
    id1 = id1[ix]
    id2 = id2[ix]
    dis12 = dis12[ix]
    
    if nmatch ge matchlimit then begin
    ;  ; remove distance above 3 sigma
    ;  meanclip, dis12, dismed, disstd
    ;  ix = where(dis12 le dismed + 3.0*disstd, nmatch)
    ;  id1 = id1[ix]
    ;  id2 = id2[ix]
    ;  dis12 = dis12[ix]
      
      ;res = sqrt( total(dis12^2) / nmatch / (nmatch-3>1) )
    endif else begin
      return, -3
    endelse
  endelse
  
  if ~ multimatch then begin
    ; remove multiple matched stars
    h1 = histogram(id1)
    w1 = where(h1 gt 1, nw1) + min(id1) ; id in id1 for multimatched
    for ww = 0, nw1-1 do begin
      ix1 = where(id1 eq w1[ww]) ; index in id1/2 for multimatched
      dis1 = r_distance( u1[w1[ww]], v1[w1[ww]], u2[id2[ix1]], v2[id2[ix1]] )
      rm1 = where(dis1 gt min(dis1)) ; index to remove, in ix1
      if rm1[0] eq -1 then rm1 = 0
      id1[ix1[rm1]] = -1 & id2[ix1[rm1]] = -1
    endfor
    id1 = id1[where(id1 gt -1)] & id2 = id2[where(id2 gt -1)]
    ; same op for id2 dup
    h2 = histogram(id2)
    w2 = where(h2 gt 1, nw2) + min(id2) ; id in id1 for multimatched
    for ww = 0, nw2-1 do begin
      ix2 = where(id2 eq w2[ww]) ; index in id1/2 for multimatched
      dis2 = r_distance( u2[w2[ww]], v2[w2[ww]], u1[id1[ix2]], v1[id1[ix2]])
      rm2 = (where(dis2 gt min(dis2)))[0] ; index to remove, in ix1
      if rm2[0] eq -1 then rm2 = 0
      id2[ix2[rm2]] = -1 & id1[ix2[rm2]] = -1
    endfor
    id1 = id1[where(id1 gt -1)] & id2 = id2[where(id2 gt -1)]
    
    nmatch = n_elements(id1)
  endif
  
  return, sqrt( total(dis12^2) / nmatch / (nmatch-3>1) )
end

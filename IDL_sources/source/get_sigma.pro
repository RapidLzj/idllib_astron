function get_sigma,im
  ix=where(finite(im) eq 1)
  image=im[ix]
  order=sort(image)
  y=image[order]
;  ix=where(y gt 0.)
;  if (ix[0] ne -1) then y=y[ix] else return,-1.

  xminlimit=0.15
  xmaxlimit=0.85

  xminlimit=xminlimit*n_elements(y)
  xmaxlimit=xmaxlimit*n_elements(y)

  xx=round([xminlimit,xmaxlimit])
  if (n_elements(y) gt 100) then sig=stddev(y[xx[0]:xx[1]],/double) else sig=-1.
return, sig
end
pro r_arrayinfo, a
  nd = size(a, /n_dim)
  ds = size(a, /dim)
  n = n_elements(a)
  t = typename(a)
  ix = where(finite(a, /nan), nnan)
  ix = where(finite(a, /inf), ninf)
  print, t, ds, n, min(a), max(a), mean(a), median(a), stddev(a), nnan, ninf, $
  format='(A10,'+strn(nd)+'("*",I),"=",I / F,"->",F,3x,F,1x,F,"+-",F, I," NaN ",I," Inf")'
end
function r_set_sub, a, b
  n = max(a)
  all = intarr(n+1)
  all[a] = 1
  all[b] = 0
  return, where(all eq 1)
end
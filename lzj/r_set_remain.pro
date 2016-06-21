function r_set_remain, a, n
  all = intarr(n)
  all[a] = 1
  b = where(all eq 0)
  return, b
end
function r_set_union, a, b
  k = [a[*], b[*]]
  p = uniq(k, sort(k))
  return, k[p]
end
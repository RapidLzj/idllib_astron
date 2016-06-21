function r_set_intersect, a, b
  ua = a[uniq(a, sort(a))]
  ub = b[uniq(b, sort(b))]
  ab = [ua, ub]
  ix = where(histogram(ab) gt 1, nix) + min(ab)
  if nix eq 0 then return, !values.f_nan else return, ix
end
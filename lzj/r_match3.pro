pro r_match3, a1, b1, a2, b2, a3, b3, $
  nmatch, id1, id2, id3, $
  maxdis=maxdis, xy=xy
  
  if ~ keyword_set(maxdis) then maxdis = 5.0 / 3600.0

  ; match 1 with 2/3
  r = r_match(a1, b1, 0, a2, b2, 0, nm12, id121, id122, dis12, maxdis=maxdis, /nosigma, xy=xy)
  r = r_match(a1, b1, 0, a3, b3, 0, nm13, id131, id133, dis13, maxdis=maxdis, /nosigma, xy=xy)

  ; find match between id121 and id131
  match, id121, id131, k2, k3
  
  ; final result
  id1 = id121[k2]
  id2 = id122[k2]
  id3 = id133[k3]
  nmatch = n_elements(id1)
end
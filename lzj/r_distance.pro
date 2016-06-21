; calc distance between two point (or point vector)
; approximate distance for within 1 deg area
; ra/dec 0/1 can be scalar or vector, if both are vectors, they must have same element count
function r_distance, ra0, dec0, ra1, dec1
  ra01 = abs(ra0-ra1)
  ra01 = min([ [ra01], [abs(ra01-360.0d)] ], dim=2)
  return, sqrt( (ra01 * cos(!dpi*dec1/180.0d))^2.0d + (dec0-dec1)^2.0d )
end

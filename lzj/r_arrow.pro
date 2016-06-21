pro r_arrow, x0, y0, x1, y1, arsize, arang, $
  linestyle=linestyle, color=color, thick=thick

  if ~ keyword_set(arang)  then arang = 30.0 / 180.0 * !pi
  if ~ keyword_set(arsize) then arsize = sqrt((x1-x0)^2.0+(y1-y0)^2.0)/20.0
  theta = atan(y1-y0, x1-x0)
  x2 = x1 - cos(theta + arang) * arsize
  x3 = x1 - cos(theta - arang) * arsize
  y2 = y1 - sin(theta + arang) * arsize
  y3 = y1 - sin(theta - arang) * arsize
  oplot, [x0, x1], [y0, y1], linestyle=linestyle, color=color, thick=thick
  oplot, [x1, x2], [y1, y2], linestyle=linestyle, color=color, thick=thick
  oplot, [x1, x3], [y1, y3], linestyle=linestyle, color=color, thick=thick
end


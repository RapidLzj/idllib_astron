pro r_diamond, ctx, cty, xsize, ysize, $
  linestyle=linestyle, color=color, thick=thick

  if ~ keyword_set(ysize) then ysize = xsize

  oplot, ctx + xsize / 2.0 * [0, 1, 0, -1, 0], cty + ysize / 2.0 * [1, 0, -1, 0, 1], $
    linestyle=linestyle, color=color, thick=thick

end


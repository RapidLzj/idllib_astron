pro r_box, ctx, cty, xsize, ysize, $
    linestyle=linestyle, color=color, thick=thick, $
    fill=fill, fcolor=fcolor

    if ~ keyword_set(ysize) then ysize = xsize

    xx = ctx + xsize / 2.0 * [1, 1, -1, -1, 1]
    yy = cty + ysize / 2.0 * [1, -1, -1, 1, 1]

    if keyword_set(fill) then begin
        r_default, fcolor, color
        polyfill, xx, yy, color=fcolor
    endif
    oplot, xx, yy, linestyle=linestyle, color=color, thick=thick
end


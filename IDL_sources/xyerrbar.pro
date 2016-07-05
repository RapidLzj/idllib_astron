Pro xyerrbar, x, y, down, up, left, right, Width = width, color=color
; down, up, left, right should be the location of the error bars,
;     not the size of the error bars.
; Modified from errplot.pro by Sungsoo Kim, 09/22/02

on_error,2                      ;Return to caller if an error occurs

w     = ((n_elements(width) eq 0) ? 0.01 : width) * $ ;Width of error bars
        (!x.window[1] - !x.window[0]) * !d.x_size * 0.5
color = ((n_elements(color) eq 0) ? !P.color : color)
n     = n_elements(x) ;# of pnts

for i=0,n-1 do begin            ;do each point.
    ;y-axis error bars
    xy0 = convert_coord(x[i], down[i], /DATA, /TO_DEVICE) ;get device coords
    xy1 = convert_coord(x[i], up[i], /DATA, /TO_DEVICE)
    plots, [xy0[0] + [-w, w,0], xy1[0] + [0, -w, w]], $
      [replicate(xy0[1],3), replicate(xy1[1],3)], $
      NOCLIP=!p.noclip, PSYM=0, color=color, /DEVICE

    ;x-axis error bars
    xy0 = convert_coord(left[i], y[i], /DATA, /TO_DEVICE) ;get device coords
    xy1 = convert_coord(right[i], y[i], /DATA, /TO_DEVICE)
    plots, [replicate(xy0[0],3), replicate(xy1[0],3)], $
      [xy0[1] + [-w, w,0], xy1[1] + [0, -w, w]], $
      NOCLIP=!p.noclip, PSYM=0, color=color, /DEVICE
endfor

end

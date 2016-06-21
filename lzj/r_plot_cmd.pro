pro r_plot_cmd, filename, title, colorindex, mag, $
    xtitle=xtitle, ytitle=ytitle, $
    xrange=xrange, yrange=yrange, xsize=xsize, ysize=ysize, $
    color=color, psym=psym

if strtrim(filename,2) ne '' then begin
    r_default, xsize, 15
    r_default, ysize, 20
    set_plot, 'ps'
    loadct, 39, /silent
    device,filename=filename,$
        /color,bits_per_pixel=16,xsize=xsize,ysize=ysize, $
        /encapsulated,yoffset=0,xoffset=0,/TT_FONT,/helvetica,/bold,font_size=12
endif else begin
    r_default, xsize, 500
    r_default, ysize, 800
    set_plot, 'x'
    window, 0, xsize=xsize, ysize=ysize
endelse

meanclip, colorindex, cmed, csig

r_default, xrange, [-5,5]*csig+cmed
r_default, yrange, [22,10]
r_default, psym, 1
;r_default, color, 0

plot, colorindex, mag, psym=psym, xrange=xrange, yrange=yrange, $
    xtitle=xtitle, ytitle=ytitle, $
    title=title, color=color

xyouts, xrange[0]+0.5, yrange[1]+2, n_elements(mag)

if strtrim(filename,2) ne '' then begin
    device, /close
    set_plot, 'x'
endif

end
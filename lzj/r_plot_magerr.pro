pro r_plot_magerr, filename, title, mag, err, err2, err3, err4, $
    xtitle=xtitle, ytitle=ytitle, $
    xrange=xrange, yrange=yrange, xsize=xsize, ysize=ysize, $
    color=color, psym=psym, ylog=ylog

if strtrim(filename,2) ne '' then begin
    r_default, xsize, 20
    r_default, ysize, 15
    set_plot, 'ps'
    loadct, 39, /silent
    device,filename=filename,$
        /color,bits_per_pixel=16,xsize=xsize,ysize=ysize, $
        /encapsulated,yoffset=0,xoffset=0,/TT_FONT,/helvetica,/bold,font_size=12
endif else begin
    r_default, xsize, 800
    r_default, ysize, 500
    set_plot, 'x'
    window, 0, xsize=xsize, ysize=ysize
endelse

meanclip, colorindex, cmed, csig

r_default, xrange, [10, 20]
r_default, yrange, [0,0.2]
r_default, psym, 1
r_default, color, [0, 50, 100, 150]

plot, mag, err, psym=psym, xrange=xrange, yrange=yrange, $
    xtitle=xtitle, ytitle=ytitle, $
    title=title, ylog=ylog, color=color[0]
if keyword_set(err2) then oplot, mag, err2, psym=psym, color=color[1]
if keyword_set(err3) then oplot, mag, err3, psym=psym, color=color[2]
if keyword_set(err4) then oplot, mag, err4, psym=psym, color=color[3]

if strtrim(filename,2) ne '' then begin
    device, /close
    set_plot, 'x'
endif

end
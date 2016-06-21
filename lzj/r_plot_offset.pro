pro r_plot_offset, filename, title, mag, offset, $
    xtitle=xtitle, ytitle=ytitle, $
    xrange=xrange, yrange=yrange, xsize=xsize, ysize=ysize, $
    color=color, psym=psym

if strtrim(filename,2) ne '' then begin
    r_default, xsize, 20
    r_default, ysize, 12
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

offstd = get_sigma(offset)
offmed = median(offset)
;meanclip, offset, offmed, offstd, sub=sub

r_default, xrange, [10,20]
r_default, yrange, [-10,10]*offstd+offmed
r_default, psym, 1
;r_default, color, 0

plot, mag, offset, psym=1, xrange=xrange, yrange=yrange, $
    xtitle=xtitle, ytitle=ytitle, $
    title=title, color=color
oplot, xrange, offmed+[0,0], color=50, thick=2
oplot, xrange, offmed+1.0*offstd+[0,0], color=50, linestyle=2
oplot, xrange, offmed-1.0*offstd+[0,0], color=50, linestyle=2
oplot, xrange, offmed+3.0*offstd+[0,0], color=50, linestyle=3
oplot, xrange, offmed-3.0*offstd+[0,0], color=50, linestyle=3

xyouts, xrange[0]+1, yrange[0]*0.1+yrange[1]*0.9, color=244, $
    string(offmed, offstd, n_elements(mag), $;n_elements(sub), $
    ;format='("offset: ",F6.3,"+-",F6.3," using ",I5,"/",I5," stars")')
    format='("offset: ",F6.3,"+-",F6.3," using ",I5," stars")')

x0 = floor(xrange[0]) & x1 = ceil(xrange[1])
offm = fltarr(x1-x0) & offs = fltarr(x1-x0)
for m = x0, x1-1 do begin
    if m lt (x0+x1)/2 then $
        ix = where(mag ge m and mag lt m+1 and abs(offset) lt 0.1, nix) $
    else $
        ix = where(mag ge m and mag lt m+1 and abs(offset) lt 0.5, nix)
    if nix gt 5 then begin
        ;offm = median(offset[ix])
        ;offs = stddev(offset[ix])
        ;offs = get_sigma(offset[ix])
        meanclip, offset[ix], m1, s1
        offm[m-x0] = m1
        offs[m-x0] = s1
        offss = string(s1, format='(F7.4)')
        ;oplot, m+[0,1],offm+[0,0],thick=3, color=250, linestyle=1
        ;oplot, m+[0,1],offm+offs+[0,0],thick=3, color=250, linestyle=2
        ;oplot, m+[0,1],offm-offs+[0,0],thick=3, color=250, linestyle=2
    endif else begin
        offs[m-x0] = 'nan'
        offss = '-'
    endelse
    xyouts, m, yrange[0]*0.8+yrange[1]*0.2, strn(nix)
    xyouts, m, yrange[0]*0.9+yrange[1]*0.1, offss
endfor

m = indgen(x1-x0)+x0+0.5
oplot, m, offm, color=88
oplot, m, offm - offs, color=254, thick=3
oplot, m, offm + offs, color=254, thick=3

if strtrim(filename,2) ne '' then begin
    device, /close
    set_plot, 'x'
endif

end
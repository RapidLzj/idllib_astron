pro compare_psf

restore,'sources1.dat'
restore,'sources.dat'
ix1=sort(sources.x)
ix2=sort(sources1.x)


x1=sources[ix1].x
x2=sources1[ix2].x
f1=sources[ix1].psf_flux
f2=sources1[ix2].psf_flux



plot,[1,10000],[0.8,1.2],/xlog,xrange=[1,10000],yrange=[0.8,1.2],xstyle=1,ystyle=1,/nodata




for i=0LL,n_elements(sources)-1LL do begin


R=abs(sources[i].x-sources1.x)+abs(sources[i].y-sources1.y)

ix=sort(R)

plots,sources[i].psf_flux,sources[i].psf_flux/sources1[ix[0]].psf_flux,psym=4
;print,sources[i].x,sources1[ix[0]].x
;a=''
;read,a

endfor




end

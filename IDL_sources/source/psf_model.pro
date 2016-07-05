pro psf_model,coor,image,psfsize,psf,_EXTRA = extra
data=read_ascii(coor)
im=readfits(image)
x0=reform(data.field1[0,*])
y0=reform(data.field1[1,*])


;restore,'L1641_3.6_sources_bs28ov8_long.dat'

;x0=sources.x
;y0=sources.y
;f0=sources.flux
;ix=reverse(sort(f0))
;x0=x0[100:200]
;y0=y0[100:200]


simple_psf_extract,x0,y0,im,psfsize,psf,psf_fwhm,_EXTRA = extra
return
end

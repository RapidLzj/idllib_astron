pro readfile

data=read_ascii('psf_phot.txt')

x0=reform(data.field1[0,*])
y0=reform(data.field1[1,*])
f0=reform(data.field1[2,*])

 skyrad=[10.0,15.0]
    apr=[3.0]
    badpix=[-10000,10000]
    phpadu=1.0
    image=readfits('L1641_subim.fits')
    aper,image,x0,y0,flux,errflux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent


plot,f0,f0/flux,psym=4,xrange=[0.5,2000],yrange=[0,3],/xlog
stop
end

pro create_psf_model,gain,skylevel,bias,exptime,psf_fwhm,psf_size,maxvalue,lsnr0=lsnr0,lflux0=lflux0

Ntimes=2.
badval=65000.
npix=round(psf_size*3)
npix=npix+1-(npix mod 2)
skylevel=skylevel+bias
c0=psf_fwhm/(2.*(alog(2.))^0.5)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;calculate the low SNR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

background=skylevel*gain
background=randomn(1000,npix,npix,poisson=background,/double)
background=background/gain
std=stddev(background,/double)
maxval=Ntimes*std/exp(-psf_fwhm^2./(c0^2d0))
print,maxval,psf_fwhm,std
max_time=30
temp_snr=fltarr(max_time)+!Values.F_NAN
temp_aper_flux=fltarr(max_time)+!Values.F_NAN
im=fltarr(npix,npix)

for num=0,max_time-1 do begin

xcen=npix/2
ycen=xcen

fcen=maxval*gain+skylevel*gain

seed=randomu(1000L+num,npix,npix)*(3200+10*num)
fcen=randomn(seed[xcen,ycen],poisson=flux,/double)



if fcen le badval*gain then begin

for i=0,npix-1 do begin
for j=0,npix-1 do begin

r=((i-xcen)^2.+(j-ycen)^2.)^0.5
flux=maxval*exp(-r^2./(c0^2d0))*gain+skylevel*gain

flux=randomn(seed[i,j],poisson=flux,/double)
im[i,j]=flux
endfor
endfor
im=im/gain
;fits_write,'model_psf.fits',im
skyrad=[2.5*psf_fwhm,5*psf_fwhm]
apr=[2.5*psf_fwhm]
badpix=[-10000.,100000.]
phpadu=gain
im=im-bias
aper,im,xcen,ycen,aper_flux,err_flux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent
temp_snr[num]=aper_flux/err_flux
temp_aper_flux[num]=aper_flux
endif

endfor


lsnr0=median(temp_snr,/even)
lflux0=median(temp_aper_flux,/even)
;print,lsnr0,lflux0


;fits_write,'model_psf.fits',im





end

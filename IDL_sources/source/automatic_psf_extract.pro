function get_sigma,im
  ix=where(finite(im) eq 1)
  image=im[ix]
  order=sort(image)
  y=image[order]
;  ix=where(y gt 0.)
;  if (ix[0] ne -1) then y=y[ix] else return,-1.

  xminlimit=0.15
  xmaxlimit=0.85

  xminlimit=xminlimit*n_elements(y)
  xmaxlimit=xmaxlimit*n_elements(y)

  xx=round([xminlimit,xmaxlimit])
  if (n_elements(y) gt 100) then sig=stddev(y[xx[0]:xx[1]]) else sig=-1.
return, sig
end


pro extract_psf,sources,image,psfsize,psf,_EXTRA = extra

im=image
x0=sources.x
y0=sources.y

simple_psf_extract,x0,y0,im,psfsize,psf,psf_fwhm,_EXTRA = extra
return
end


function sky_med,im,x0,y0,R1,R2

temp=im

lx=round(x0-R1)
ly=round(y0-R1)
ux=round(x0+R1)
uy=round(y0+R1)

temp[lx:ux,ly:uy]=!VALUES.F_NAN
lx=round(x0-R2)
ly=round(y0-R2)
ux=round(x0+R2)
uy=round(y0+R2)

sky=temp[lx:ux,ly:uy]
med=median(sky,/even)

return,med
end


pro ssf_write_region_file,new,fitsname,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer
  a=strsplit(fitsname,'.fits',/reg,/ex)
  regname=a[0]
  if not keyword_set(buffer) then buffer=0
  if keyword_set(boxsize) then regname=regname+'_bs'+strtrim(string(boxsize-2*buffer),2)
  if keyword_set(overlap) then regname=regname+'ov'+strtrim(string(overlap-2*buffer),2)
  regname=regname+'.reg'

  off=1. ;; offset to be added to x and y coordinates, typically 1.0 for stuff that has been extracted using idl, 0. for iraf/sextractor stuff.

  bs=13
  openw,lun,regname,/get_lun
  j=0l
  while (j lt (n_elements(new)-1)) do begin
;    adxy, hdrmos,res[j].RA,res[j].dec, x, y
    line='box('+strtrim(string(new[j].x+off,format='(f10.1)'),2)+','+$
                strtrim(string(new[j].y+off,format='(f10.1)'),2)+','+$
                strtrim(string(bs,format='(f10.1)'),2)+','+$
                strtrim(string(bs,format='(f10.1)'),2)+') # color=green'
    if ((finite(new[j].x) eq 1) and (finite(new[j].y) eq 1)) then $
    printf,lun,line
    j=j+1
  endwhile
  close,lun
  free_lun,lun
  print,'wrote: ',regname
end



pro automatic_psf_extract,image,sources,psf_fwhm,psf_size,psf_star_file=psf_star_file,psf,Nsigma=Nsigma


if not keyword_set(Nsigma) then Nsigma=3.0

im=image

found_stars=sources
x0=found_stars.x
y0=found_stars.y

nx=n_elements(im[*,0])
ny=n_elements(im[0,*])

skyrad=[3,7]
apr=[3.0]
badpix=[-100000d0,100000d0]
phpadu=1.0
aper,im,x0,y0,aper_flux,err_flux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent

;plot,x0,y0,psym=3
;ix=reverse(sort(aper_flux))
;x0=x0[ix]
;y0=y0[ix]
;aper_flux=aper_flux[ix]
;err_flux =err_flux[ix]


same_source_radius=psf_fwhm*3 ;; pixels
GROUP_roy, x0, y0, same_source_radius, NGROUP
numberofgroups=max(ngroup)
 one={x:0.,y:0.,n:0,flux:0.,err_flux:0.}
 
 new=replicate(one,numberofgroups)
 i=0l
  while (i lt (n_elements(new)-1)) do begin
    ix=where(ngroup eq i)
    if (ix[0] eq -1) then new[i].n=0 else $
    if (n_elements(ix) eq 1) then begin ;; only one star in this group
      new[i].x=x0[ix] & new[i].y=y0[ix] & new[i].flux=aper_flux[ix]
      new[i].err_flux=err_flux[ix] &new[i].n=n_elements(ix)
    endif else begin ;; multiple stars in this group
      new[i].x=0 & new[i].y=0 & new[i].flux=0 &new[i].err_flux=0
      new[i].n=n_elements(ix)
    endelse
    i=i+1
  endwhile
buffer=100
HSNR=50
LSNR=20
ix=where(new.n eq 1 and new.flux/new.err_flux ge LSNR and new.flux/new.err_flux le HSNR and new.x ge buffer $
         and new.x le nx-buffer and new.y ge buffer and new.y le ny-buffer)
;oplot,new[ix].x,new[ix].y,psym=4,color='0000FF'XL
;SNR=aper_flux/err_flux
;buffer=500
;ix=where(SNR ge 20 and x0 ge buffer and  x0 le nx-buffer and y0 ge buffer and $ 
;y0 le ny-buffer)
 
psf_sources=new[ix]
skyval=fltarr(n_elements(psf_sources))

R1=psf_fwhm*3
R2=psf_fwhm*5


im=image
skymed=median(im,/even)
std=get_sigma(im)

for i=0L,n_elements(psf_sources)-1L do begin
skyval[i]=sky_med(im,psf_sources[i].x,psf_sources[i].y,R1,R2)
endfor

ix=where(skyval le skymed+Nsigma*std)
psf_sources=psf_sources[ix]





ssf_write_region_file,psf_sources,psf_star_file

AVGTYPE=1  ;using median to get psf
extract_psf,psf_sources,im,psf_size,psf,AVGTYPE=AVGTYPE


end

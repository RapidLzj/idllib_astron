;@starfinder/
;@psf_extract
@stack_combine
@superpose_stars
@fitstars
@starfinder
@starlist

;@smart_estimate_background
;@smart_image_background
;@imdisp
@get_sigma
@psf_model


pro psf_phot
  data_directory='/disk1/fang/SPITZER_DATA_PBCD/SPITZER_DATA/original_IRAC_data/'
 
work_directory='/disk1/fang/SPITZER_DATA_PBCD/SPITZER_DATA/work_directory/joined_IRAC_mosaics/'
           fname='L1641subimg.fits'
  image=readfits(fname,hdr)    
 ;image=readfits('image.fits',hdr) 
 
  
 PSF_MODEL,'psf_3.6.txt','L1641_3.6_3sigma_median_long.fits',11,psf  
 
 
 
 ;psf=readfits('PSF_IRAC1.fits',hdr)
 
 
 
 siz=size(psf,/dim)
 ;maxval=max(psf)
 
 
 ;for i=0L,siz[0]-1L do begin
 ;for j=0L,siz[1]-1L do begin
 ;if psf[i,j] eq maxval then print,i,j 
 ;endfor
 ;endfor
 
 
 
 
 ;lx=4
 ;ux=siz[0]-5
 
 ;ly=4
 ;uy=siz[0]-5
  
 ;psf=psf[lx:ux,ly:uy]
 ;siz=size(psf,/dim)
 
 ;fxaddpar,hdr,'NAXIS1',siz[0]
 ;fxaddpar,hdr,'NAXIS2',siz[1]
 
 ; newx=siz[0]/5
 ; newy=siz[1]/5
   
 ; hcongrid,psf,hdr,newpsf,newhdr,newx,newy
 ; psf=newpsf
 

 
  
 ;maxval=max(psf)
 
; for i=0L,newx-1L do begin
; for j=0L,newy-1L do begin
; 
; if psf[i,j] eq maxval then begin
; x0=i
; y0=j
; break
; endif
  
; endfor
; endfor
 
; psf=psf[(x0-5):(x0+5),(y0-5):(y0+5)]
 
;  fits_write,'psf.fits',psf
; psf=psf/total(psf)
 
 ;fits_write,'psf.fits',psf

 threshold=[10.0,3.0]
 noise_std=[0.0112]
 min_correlation=0.7
 psf_fwhm=2.0
 back_box=9*psf_fwhm
 niter=3
 correl_mag=2
 
; minif=psf_fwhm/2

rel_thresh=1
deblend=1
;starfinder,image,psf,threshold,REL_THRESHOLD=rel_thresh,correl_mag=correl_mag,NOISE_STD=noise_std,min_correlation,BACK_BOX=back_box,/sky_median,/pre_smooth,INTERP_TYPE='I',$
;DEBLEND=deblend,N_ITER=niter,x,y,fluxes, sigma_x, sigma_y, sigma_f,correlation
  
starfinder, image, psf, BACK_BOX = back_box, $
 	               threshold, REL_THRESHOLD=rel_thresh, /PRE_SMOOTH, $
 	               NOISE_STD = noise_std, min_correlation, $
	               CORREL_MAG = correl_mag, INTERP_TYPE = 'I', $
	               DEBLEND = deblend, N_ITER = niter, $
	               x, y, fluxes, sx, sy, sf, c, STARS = stars
	         








   skyrad=[10.0,15.0]
    apr=[3.0]
    badpix=[-10000,10000]
    phpadu=1.0
    
    aper,image,x,y,aperflux,errflux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent
    plot,fluxes,aperflux,xrange=[0.5,500],yrange=[0.5,500],psym=4,/xlog,/ylog 

stop



  ;window,xsize=1000,ysize=500,retain=2  
  
  ; sigma=get_sigma(im)
  ; med=median(im)
  ; imby=bytscl(im,max=med+30*sigma,min=med-sigma)
  ; imdisp,imby,/axis   
  
   ;x0=fltarr(5)
   ;y0=fltarr(5)
   ;xs=fltarr(5)
   ;ys=fltarr(5)
  
   ;x0[0]=5888.8   
   ;y0[0]=1487.8
  
   ;x0[1]=6080.1   
   ;y0[1]=1544.0
  
   ;x0[2]=8902.9   
   ;y0[2]=997.0
  
   ;x0[3]=5718.0   
   ;y0[3]=765.2
  
   ;x0[4]=6228.9   
   ;y0[4]=994.2
  
  
  ;psf_size=10.0
  
  
  ;psf_extract,x0,y0,xs,ys,im,psf_size,psf,psf_fwhm,ITER = 0,/SKY_MEDIAN
  
;  psf_fwhm=2.0
;  step=20*psf_fwhm
;  starbox=6*psf_fwhm
  
;  restore,'L1641_3.6_sources_bs28ov8_long.dat'
;  starlist=sources
  
  
  
  
;  background=smart_estimate_background(im,step,starlist=starlist,starbox=starbox)
 
 
 
;  fits_write,'background.fits',background,hdr
  
  
;  fits_write,'star.fits',im-background,hdr
 
 
  ;print,psf_fwhm
  
  ;fits_write,'psf.fits',psf
 
  
  ;catalogue=work_directory+'found_sources/L1641_8.0_sources_bs28ov8_long.dat'
  
  ;restore,catalogue
  
  ;oplot,SOURCES.X,SOURCES.Y,psym=4,color='0000FF'XL
 
 
  ;x0= SOURCES.X
  ;y0= SOURCES.Y
  ;f0= SOURCES.FLUX
  ;fitstars,im,psf,x0,y0,f0,x,y,f,fit_err,sigma_x, sigma_y, sigma_f
 
 ;print,x
 
;  openw,1,'source.dat'
;  for i=0L,n_elements(x)-1L do begin
;  printf,1,x[i],y[i],f[i],fit_err[i],sigma_x[i],sigma_y[i],sigma_f[i]
;    endfor
;  close,1


end

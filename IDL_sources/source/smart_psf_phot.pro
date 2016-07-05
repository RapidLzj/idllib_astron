function psf_ssf_remove_multiple,res_x,res_y,res_psf_flux,res_psf_x_sigma,res_psf_y_sigma, $
          res_psf_flux_sigma,res_psf_correlation,res_aper_flux,res_aper_errflux,nearest_edge
  
  print,'number of stars found: ',n_elements(res_x)

  same_source_radius=1.0 ;; pixels

  GROUP_roy, res_X, res_Y, same_source_radius, NGROUP

  numberofgroups=max(ngroup+1)
 
one={x:0.,y:0.,n:0,psf_flux:0.,psf_x_sigma:0.,psf_y_sigma:0.,psf_flux_sigma:0.,psf_correlation:0.,aper_flux:0.,aper_errflux:0.,nearest_edge:0.}
  
  
  new=replicate(one,numberofgroups)
  i=0l
  while (i le (n_elements(new)-1)) do begin
    ix=where(ngroup eq i)
    if (ix[0] eq -1) then new[i].n=0 else $
    if (n_elements(ix) eq 1) then begin ;; only one star in this group
      new[i].x=res_x[ix] & new[i].y=res_y[ix] & new[i].psf_flux=res_psf_flux[ix]
      new[i].n=1
      new[i].psf_x_sigma=res_psf_x_sigma[ix]
      new[i].psf_y_sigma=res_psf_y_sigma[ix]
      new[i].psf_flux_sigma=res_psf_flux_sigma[ix]
      new[i].psf_correlation=res_psf_correlation[ix]
      new[i].aper_flux=res_aper_flux[ix]
      new[i].aper_errflux=res_aper_errflux[ix]
      new[i].nearest_edge=nearest_edge[ix]
    endif else begin ;; multiple stars in this group
     ix_max=reverse(sort(nearest_edge[ix])) 
      
      new[i].x=res_x[ix[ix_max[0]]] & new[i].y=res_y[ix[ix_max[0]]] & new[i].psf_flux=res_psf_flux[ix[ix_max[0]]]
      new[i].n=n_elements(ix)
      new[i].psf_x_sigma=res_psf_x_sigma[ix[ix_max[0]]]
      new[i].psf_y_sigma=res_psf_y_sigma[ix[ix_max[0]]]
      new[i].psf_flux_sigma=res_psf_flux_sigma[ix[ix_max[0]]]
      new[i].psf_correlation=res_psf_correlation[ix[ix_max[0]]]
      new[i].aper_flux=res_aper_flux[ix[ix_max[0]]]
      new[i].aper_errflux=res_aper_errflux[ix[ix_max[0]]]
      new[i].nearest_edge=nearest_edge[ix[ix_max[0]]]
    
    endelse
    i=i+1
  endwhile

help,new
  ix=where(new.n ge 1) & new=new[ix]
help,new

  return,new
end





function psf_ssf_determine_sigma,img,plotm=plotm
  ix=where(finite(img) eq 1 and img le 50000. and img ge -3000.) 
  med_val=median(img[ix])
  ix=where(finite(img) eq 1 and abs(img-med_val) le 1000. and img le 50000. and img ge -5000.)        
  im=img[ix]

  order=sort(im)
  y=im[order]

  xminlimit=0.20
  xmaxlimit=0.80

  xminlimit=xminlimit*n_elements(y)
  xmaxlimit=xmaxlimit*n_elements(y)

  xx=round([xminlimit,xmaxlimit])
  if (n_elements(y) gt 100) then sig=stddev(y[xx[0]:xx[1]],/double) else stop

  if (sig le 0) then print,'sig=',sig, "<=0. sth wrong"
  if (sig le 0) then sig=-1.
;  if (sig le 0) then stop

  if keyword_set(plotm) then begin
    yrange=[-40,60]*median(y)
    if (yrange[0] gt 0) then yrange=-yrange
    plot,y,yrange=yrange,title='standard deviation: '+string(sig)
    oplot,xminlimit*[1,1],[-1e10,1e10],line=2
    oplot,xmaxlimit*[1,1],[-1e10,1e10],line=2
    aa=''
    read,aa
  endif

  return,sig
end

function psf_ssf_get_sigmas,im,subims
  sigmas=fltarr(n_elements(subims))
  i=0l
  while (i le n_elements(subims)-1) do begin
    lim=im[subims[i].x1:subims[i].x2,subims[i].y1:subims[i].y2]
    sigmas[i]=psf_ssf_determine_sigma(lim)
    i=i+1
  endwhile
  return,sigmas
end



pro psf_ssf_write_subims_regfile,subims,fitsname,buffer=buffer,subims_regfile=regname
  a=strsplit(fitsname,'.fit',/reg,/ex)
  regname=a[0]+'_psf_fitting_subims.reg'

  if not keyword_set(buffer) then buffer=0

  off=1. ;; offset to be added to x and y coordinates, typically 1.0 for stuff that has been extracted using idl, 0. for iraf/sextractor stuff.

  openw,lun,regname,/get_lun
  printf,lun,'image'
  i=0l
  while (i le (n_elements(subims)-1)) do begin

    bsx=(subims[i].x2-subims[i].x1+1)
    x0=(subims[i].x2+subims[i].x1)/2.
    bsy=(subims[i].y2-subims[i].y1+1)
    y0=(subims[i].y2+subims[i].y1)/2.

    line='box('+strtrim(string(x0+off,format='(f10.1)'),2)+','+$
                strtrim(string(y0+off,format='(f10.1)'),2)+','+$
                strtrim(string(bsx-buffer*2,format='(f10.1)'),2)+','+$
                strtrim(string(bsy-buffer*2,format='(f10.1)'),2)+') # color=red'
    printf,lun,line

    line='box('+strtrim(string(x0+off,format='(f10.1)'),2)+','+$
                strtrim(string(y0+off,format='(f10.1)'),2)+','+$
                strtrim(string(1,format='(f10.1)'),2)+','+$
                strtrim(string(1,format='(f10.1)'),2)+') # color=red text={'+$
                strtrim(string(i),2)+'}'               
    printf,lun,line
    i=i+1
  endwhile
  close,lun
  free_lun,lun
  print,'wrote: ',regname
end

function psf_ssf_get_subims,nx,ny,boxsize,overlap
;; purpose: to get the pixel ranges 
  
  length=0
  x1=[0]
  x2=[boxsize-1]
  jx=1
  while (length lt (nx-1)) do begin
    x1=[x1,jx*(boxsize-overlap)-1]
    x2=[x2,((jx+1)*boxsize-jx*overlap-2)<(nx-1)]
    jx=jx+1
    length=max(x2)
  endwhile

  length=0
  y1=[0]
  y2=[boxsize-1]
  jy=1
  while (length lt (ny-1)) do begin
    y1=[y1,jy*(boxsize-overlap)-1]
    y2=[y2,((jy+1)*boxsize-jy*overlap-2)<(ny-1)]
    jy=jy+1
    length=max(y2)
  endwhile

 print,'number of sub-frames in [x,y] direction: ['+strtrim(string(jx),2)+','+strtrim(string(jy),2)+']'
 
  ntotal=1l*jx*jy
  one={x1:0,x2:0,y1:0,y2:0}
  res=replicate(one,ntotal)

  print,'total number of sub-frames: '+strtrim(string(ntotal),2)

  count=0l
  for i=0,jx-1 do begin
    for k=0,jy-1 do begin
       res[count].x1=x1[i]
       res[count].x2=x2[i]
       res[count].y1=y1[k]
       res[count].y2=y2[k]
       count=count+1l
    endfor
  endfor
  return,res
end



pro smart_psf_phot,infile,maxvalue,ini_psf_fwhm=ini_psf_fwhm,psf_fitting_size=psf_fitting_size,newsigma=newsigma,newpsf=newpsf,work_directory=work_directory,_extra=_extra

  if keyword_set(iframe) then plot_intermediate=1
  if not keyword_set(ini_psf_fwhm) then ini_psf_fwhm=10
  if not keyword_set(psf_fitting_size) then psf_fitting_size=61


   
  ;if not keyword_set(infile) then $
  ;infile=work_directory+'joined_IRAC_mosaics/'+field+'_'+band+'_3sigma_median_'+shortlong+'.fit'
 
;  infile=strsplit(infile,'.fit',/reg,/ex)
  hdr=headfits(infile)
  naxis=sxpar(hdr,'NAXIS')
  
  if (naxis eq 2) then begin
   im=readfits(infile,hdr)
  endif else if (naxis eq 0) then begin
   rdfits_struct,infile,stru
   IMAGETYP=sxpar(stru.hdr0,'IMAGETYP')
   naxis=sxpar(stru.hdr2,'NAXIS')
   hdr=stru.hdr2
   im=stru.im2
   print,"LBT data, using the second chip"
  endif  
  
 
 
  nx=fix(sxpar(hdr,'NAXIS1')) 
  ny=fix(sxpar(hdr,'NAXIS2'))
  EXPTIME=sxpar(hdr,'EXPTIME')

  psf_fitting_boxsize=fix(nx/6)
  psf_fitting_overlap=fix(psf_fitting_boxsize/7)
  psf_fitting_buffer=10
  
  
  skymed=median(im,/even)
;   im[0:50,0:ny-1]=skymed
;  im[nx-51:nx-1,0:ny-1]=skymed
 
  psf_fitting_subims=psf_ssf_get_subims(nx,ny,psf_fitting_boxsize,psf_fitting_overlap) 

 
 
  psf_ssf_write_subims_regfile,psf_fitting_subims,infile,buffer=psf_fitting_buffer,subims_regfile=subims_regfile
 
 ;if band ne '24' then begin 
 
 
 found_sources=strsplit(infile,'.fit',/reg,/ex) 
 found_sources=found_sources+'_sources*'+'_'+'.dat'
 file=file_search(found_sources) 
 
 if n_elements(file) eq 0 then begin
 print,'no files for stellar coordinates'
 return
 endif  else begin
 if n_elements(file) gt 1 then begin
  print,'there are '+strtrim(string(n_elements(file)),2)+' files for selection:'
 
  for i=0L,n_elements(file)-1L do begin
  print,i+1	
  print,file[i]
 endfor
  print,'Please select which one you want?'
 nn=0
  read,nn
  nn=nn-1L
  found_sources_coor=file[nn]
 endif else begin
  found_sources_coor=file[0]
 endelse
 endelse
 
 
 
 
 restore,found_sources_coor
 
 


;;;;;;;;;;;;;;;;;;;;;; ;extracting empirical psf ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; AVGTYPE=1  ;using median to get psf
 ; PSF_MODEL,'psf_3.6.txt','L1641_3.6_3sigma_median_long.fit',11,psf,AVGTYPE=AVGTYPE
 
 ;psf_star_file=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band+'_'+shortlong+'_psf_stars'
  
  psf_file=strsplit(infile,'.fit',/reg,/ex)
  psf_file=psf_file+'_ps'+strtrim(string(psf_fitting_size),2)+'_psf.fit' 
  psf_star_file=strsplit(infile,'.fit',/reg,/ex)
  psf_star_file=psf_star_file+'_ps'+strtrim(string(psf_fitting_size),2)+'_psf_star'
 

loop1: if keyword_set(newpsf) then begin
    
 ;  psf_star_file=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band+'_'+shortlong+'_ps'+strtrim(string(psf_fitting_size),2)+'_psf_star'

print,"                                                               " 
automatic_psf_extract,im,sources,ini_psf_fwhm,psf_fitting_size,maxvalue,psf,infile=infile,_extra=_extra 
print,"end of automatic_psf_extract at line 310 in smart_psf_phot.pro " 

    ;;ini_psf_fwhm and psf_fitting_size will be estimated from the images
  
  psf_file=strsplit(infile,'.fit',/reg,/ex)
  psf_file=psf_file+'_ps'+strtrim(string(psf_fitting_size),2)+'_psf.fit' 

  fits_write,psf_file,psf
   
 endif else begin
 if (strlen(file_search(psf_file)) ne 0) then  psf=readfits(psf_file) else begin
 print,'no psf image can be used to read!'
 print,'extracting the psf from the image!'
 newpsf=0
 goto,loop1
 endelse
 endelse
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;estimating sigma for each subimage;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
savefile=strsplit(infile,'.fit',/reg,/ex)+'_bs'+strtrim(string(psf_fitting_boxsize),2)+'ov'+strtrim(string(psf_fitting_overlap),2)+'_sigmas_psf_fitting.dat'

  
loop2:  if keyword_set(newsigma) then begin
 sigmas=psf_ssf_get_sigmas(im,psf_fitting_subims)
 save,sigmas,filename=savefile
 endif else begin
 
  if (strlen(file_search(savefile)) ne 0) then  restore,savefile else begin
      print,'  ERROR, background standard deviations of subfields have'
      print,'  not yet been determined. ';Please run'
     ; print,"smart_source_finder,band='"+band+"',/first"
      print,'estimating background standard deviations of subfields again!'
      newsigma=1
     goto,loop2
 endelse
 
 
 
 
 
 endelse 


;;;;;;;;;;;making psf fitting for stars in each subimage;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 psf_fwhm=fwhm(psf)
 hdr=headfits(infile)
  naxis=sxpar(hdr,'NAXIS')
  if (naxis eq 2) then begin
   im=readfits(infile,hdr)
  endif else if (naxis eq 0) then begin
   rdfits_struct,infile,stru
   IMAGETYP=sxpar(stru.hdr0,'IMAGETYP')
   naxis=sxpar(stru.hdr2,'NAXIS')
   hdr=stru.hdr2
   im=stru.im2
   print,"LBT data, using the second chip"
  endif

 
 xcoor   =sources.x
 ycoor   =sources.y
  
    skyrad=[2.5*ini_psf_fwhm,5*ini_psf_fwhm]
    apr=[2.5*ini_psf_fwhm]
 ;  badpix=[-10000.,1000000.]
    badpix=[-200.,maxvalue]
    phpadu=1.75
    
    
 
;aper,im,xcoor,ycoor,found_f0,err_flux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent
aper,im,xcoor,ycoor,found_f0,err_flux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux
 

 if keyword_set(iframe) then firstlast=[iframe,iframe] else  firstlast=[0,n_elements(psf_fitting_subims)-1]
 
 res_x=0. & res_y=0.   & res_psf_flux=0. &res_psf_x_sigma=0. &res_psf_y_sigma=0. &res_psf_flux_sigma=0. & res_psf_correlation=0. 
 
 res_aper_flux=0. &res_aper_errflux=0. 
 
 res_iframe=-1
  nearest_edge=0
 res_subfields=[-1,-1,-1,-1]
 





 for i=firstlast[0],firstlast[1] do begin
;  for i=58,58 do begin
 print,''
 print,'doing psf-fitting photometry toward subframe '+strtrim(string(i),2)+' of '+$
      strtrim(string(firstlast[1]-firstlast[0]),2)


print,"i=", i," sigmas[i]= ", sigmas[i]
 if sigmas[i] ne -1 then begin
 
 threshold=[5.0] 
 noise_std=sigmas[i]
 min_correlation=0.30
 back_box=9*psf_fwhm
 niter=1
 correl_mag=2
 bin_threshold=0.1
  
image=im[psf_fitting_subims[i].x1:psf_fitting_subims[i].x2,psf_fitting_subims[i].y1:psf_fitting_subims[i].y2]
ix=where(xcoor ge psf_fitting_subims[i].x1 and xcoor le psf_fitting_subims[i].x2 $
         and ycoor ge psf_fitting_subims[i].y1 and ycoor le psf_fitting_subims[i].y2 )
ix1=where(finite(image))
if (ix[0] ne -1 and ix1[0] ne -1) then begin

initial_x =xcoor[ix]-psf_fitting_subims[i].x1    
initial_y =ycoor[ix]-psf_fitting_subims[i].y1
initial_f0=found_f0[ix]  
 
ix=reverse(sort(initial_f0)) 
initial_x  =initial_x[ix]  
initial_y  =initial_y[ix]
initial_f0 =initial_f0[ix]

;psf=readfits('psf1.fit')
psf=psf/total(psf)

smart_starfinder,image,initial_x,initial_y,initial_f0,psf, BACK_BOX = back_box, $
 	               threshold, /REL_THRESHOLD,/PRE_SMOOTH,$
;                       BIN_THRESHOLD=bin_threshold,BIN_TOLERANCE=0.2,$
		       /sky_median,NOISE_STD = noise_std, min_correlation, $
	               CORREL_MAG = correl_mag, INTERP_TYPE = 'I', $
	               DEBLEND = deblend, N_ITER = niter, $
	               x, y, psf_flux, sx, sy, sf, c, STARS = stars
 


  star_ix=where(x ge 0) 
  
 if star_ix[0] ne -1  then begin
  x=x[star_ix]
  y=y[star_ix]
  psf_flux=psf_flux[star_ix]
  sx=sx[star_ix]
  sy=sy[star_ix]
  sf=sf[star_ix]
  c=c[star_ix]
  endif else begin
   x=0.
  y=0.
  psf_flux=0.
  sx=0.
  sy=0.
  sf=0.
  c=0.
  endelse
  
    ;im=readfits(infile,hdr)
    
   
    
;     skyrad=[2.5*ini_psf_fwhm,5*ini_psf_fwhm]
;    apr=[2.5*ini_psf_fwhm]
;    badpix=[-1000000.,1000000.]
;    phpadu=4.75
    
      
;aper,image,x,y,aper_flux,err_flux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent
;aper_flux=initial_f0[]

    
if ((x[0] ne 0.) and (y[0] ne 0.)) then ndetect=n_elements(x) else  ndetect=0   

if ndetect ge 1 then begin


MIN_EDGE=fltarr(ndetect)
x=x+psf_fitting_subims[i].x1 & y=y+psf_fitting_subims[i].y1



for istar=0LL,ndetect-1LL do begin
min_edge[istar]=min([min([x[istar]-psf_fitting_subims[i].x1,psf_fitting_subims[i].x2-x[istar]]),$
                min([y[istar]-psf_fitting_subims[i].y1,psf_fitting_subims[i].y2-y[istar]])])
endfor



res_x=[res_x,x] & res_y=[res_y,y] & res_psf_flux=[res_psf_flux,psf_flux]
res_psf_x_sigma=[res_psf_x_sigma,sx] &res_psf_y_sigma=[res_psf_y_sigma,sy]
res_psf_flux_sigma=[res_psf_flux_sigma,sf] & res_psf_correlation=[res_psf_correlation,c]
;res_aper_flux=[res_aper_flux,reform(aper_flux)] & res_aper_errflux=[res_aper_errflux,reform(err_flux)] 
;nearest_edge=[min_edge,nearest_edge]
nearest_edge=[nearest_edge,min_edge]
endif
endif 


endif
endfor


nx=n_elements(res_x)

res_x=res_x[1:nx-1] & res_y=res_y[1:nx-1] & res_psf_flux=res_psf_flux[1:nx-1]
res_psf_x_sigma=res_psf_x_sigma[1:nx-1] &res_psf_y_sigma=res_psf_y_sigma[1:nx-1]
res_psf_flux_sigma=res_psf_flux_sigma[1:nx-1] & res_psf_correlation=res_psf_correlation[1:nx-1]
nearest_edge=nearest_edge[1:nx-1]
  
    skyrad=[2.5*ini_psf_fwhm,5*ini_psf_fwhm]
    apr=[2.5*ini_psf_fwhm]
;    badpix=[-10000.,1000000.]
    badpix=[-200.,maxvalue]
    phpadu=1.75
 
aper,im,res_x,res_y,aper_flux,aper_errflux,sky,skyerr,phpadu,apr,skyrad,badpix,/flux,/silent
res_aper_flux=reform(aper_flux) &res_aper_errflux=reform(aper_errflux)


res_aper_flux=res_aper_flux/EXPTIME
res_aper_errflux=res_aper_errflux/EXPTIME
res_psf_flux=res_psf_flux/EXPTIME
res_psf_flux_sigma=res_psf_flux_sigma/EXPTIME


psf_fitting_sources=psf_ssf_remove_multiple(res_x,res_y,res_psf_flux,res_psf_x_sigma,res_psf_y_sigma,res_psf_flux_sigma,res_psf_correlation,res_aper_flux,res_aper_errflux,nearest_edge)



sources_file=strsplit(infile,'.fit',/reg,/ex)
sources_file=sources_file+'_ps'+strtrim(string(psf_fitting_size),2)+'_psf_fitting_sources.dat'

ix=where(finite(psf_fitting_sources.aper_flux) ne 1) 
psf_fitting_sources[ix].aper_flux=0.
psf_fitting_sources[ix].aper_errflux=0.

save,psf_fitting_sources,filename=sources_file
print,'wrote:'+sources_file



infile=strsplit(infile,'.fit',/reg,/ex)
infile=infile+'_ps'+strtrim(string(psf_fitting_size),2)+'_psf_fitting_sources'


ssf_write_region_file,psf_fitting_sources,infile,regname=regname,boxsize=psf_fitting_boxsize,overlap=psf_fitting_overlap,buffer=psf_fitting_buffer
print,psf_fitting_sources[0:3].x,psf_fitting_sources[0:3].y




end





@source/find_roy
@source/group_roy

function rgb,r,g,b
  result=1l*r+256l*g+256l^2*b
  return,result
end


pro ssf_put_cross,m,box=box
  if not keyword_set(box) then begin ;; draw a cross
    s=10 ;; size of cross
    sh=4 ;; size of central cut
    color=rgb(255,0,0)
    plots,[m[0]-s,m[0]-sh],[m[1],m[1]],/device,color=color
    plots,[m[0]+sh,m[0]+s],[m[1],m[1]],/device,color=color
    plots,[m[0],m[0]],[m[1]-s,m[1]-sh],/device,color=color
    plots,[m[0],m[0]],[m[1]+sh,m[1]+s],/device,color=color
  endif
  if keyword_set(box) then begin
    s=3
    color=rgb(255,0,0)
    plots,[m[0]-s,m[0]+s],[m[1]-s,m[1]-s],/device,color=color
    plots,[m[0]-s,m[0]+s],[m[1]+s,m[1]+s],/device,color=color
    plots,[m[0]-s,m[0]-s],[m[1]-s,m[1]+s],/device,color=color
    plots,[m[0]+s,m[0]+s],[m[1]-s,m[1]+s],/device,color=color
  endif
end

function ssf_get_subims,nx,ny,boxsize,overlap
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

function ssf_make_grid,npix
  im=fltarr(npix,npix)
  center=floor(npix/2)

  dummy=dindgen(npix)
  im1=im
  im2=im
  for i=0,npix-1 do begin
    im1[*,i]=dummy
    im2[i,*]=dummy
  endfor

  im1=im1-center
  im2=im2-center
  im=sqrt(im1^2.+im2^2.) ;; contains distance to center in pixels
  return,im
end

function ssf_make_grid2,npix
;; like ssf_make_grid, but center shifted by [-0.5,-0.5] pixels!
  im=fltarr(npix,npix)
  center=floor(npix/2)-0.5

  dummy=dindgen(npix)
  im1=im
  im2=im
  for i=0,npix-1 do begin
    im1[*,i]=dummy
    im2[i,*]=dummy
  endfor

  im1=im1-center
  im2=im2-center
  im=sqrt(im1^2.+im2^2.) ;; contains distance to center in pixels
  return,im
end



function ssf_make_psf,npix,fwhm
;; make a gaussian psf
  grid=ssf_make_grid(npix)
  sig=fwhm/2.355
  psf=exp(-grid^2/(2.*sig^2))
  psf=psf/total(psf)
  return,psf
end

function ssf_determine_sigma,im,plotm=plotm
  order=sort(im)
  y=im[order]
;  ix=where(y gt 0.)
;  if (ix[0] ne -1) then y=y[ix] else return,-1.

  xminlimit=0.15
  xmaxlimit=0.85

  xminlimit=xminlimit*n_elements(y)
  xmaxlimit=xmaxlimit*n_elements(y)

  xx=round([xminlimit,xmaxlimit])
  if (n_elements(y) gt 100) then sig=stddev(y[xx[0]:xx[1]]) else sig=-1.

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

function ssf_get_sigmas,im,subims
  sigmas=fltarr(n_elements(subims))
  i=0l
  while (i lt n_elements(subims)-1) do begin
    lim=im[subims[i].x1:subims[i].x2,subims[i].y1:subims[i].y2]
    sigmas[i]=ssf_determine_sigma(lim)
    i=i+1
  endwhile
  return,sigmas
end

function ssf_limit_sigmas,sigmas,nsigmax,plot_sig=plot_sig
  ix=where(sigmas gt 0.)
  minsigmas=min(sigmas[ix])
;  sigmas2=minsigmas>sigmas ;; take the smallest valid value as minimum
  sigmas2=median(sigmas)>sigmas ;; take the median value as minimum
  sigmas3=sigmas2<nsigmax*median(sigmas)

  if keyword_set(plot_sig) then begin
    order=sort(sigmas)
    plot,sigmas[order],yrange=[0,10.]*median(sigmas)
    oplot,sigmas3[order],line=2
    aa=''
    read,aa
  endif

  return,sigmas3
end

pro ssf_write_subims_regfile,subims,fitsname,buffer=buffer,subims_regfile=regname
  a=strsplit(fitsname,'.fits',/reg,/ex)
  regname=a[0]+'_subims.reg'

  if not keyword_set(buffer) then buffer=0

  off=1. ;; offset to be added to x and y coordinates, typically 1.0 for stuff that has been extracted using idl, 0. for iraf/sextractor stuff.

  openw,lun,regname,/get_lun
  i=0l
  while (i lt (n_elements(subims)-1)) do begin

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

function ssf_find_unique_iframes,iframes
  x=iframes & ix=where(x ge 0) & x=x[ix]
  order=sort(x) & x=x[order]
  res=x[0]
  j=0l
  i=0l
  if (n_elements(x) gt 1) then while (i lt (n_elements(x)-1)) do begin
    if (x[i] ne res[j]) then begin ;; found a new one
      res=[res,x[i]]
      j=j+1
    endif
    i=i+1
  endwhile
  return,res
end


function ssf_remove_multiple,res_x,res_y,res_flux,res_sharp,res_roundness,res_iframe,res_subfields
  print,'number of stars found: ',n_elements(res_x)

  same_source_radius=1.0 ;; pixels

  GROUP_roy, res_X, res_Y, same_source_radius, NGROUP

  numberofgroups=max(ngroup)
  one={x:0.,y:0.,flux:0.,sharp:0.,roundness:0.,n:0,iframe:-1,subfields:[-1,-1,-1,-1]}
  new=replicate(one,numberofgroups)
  i=0l
  while (i lt (n_elements(new)-1)) do begin
    ix=where(ngroup eq i)
    if (ix[0] eq -1) then new[i].n=0 else $
    if (n_elements(ix) eq 1) then begin ;; only one star in this group
      new[i].x=res_x[ix] & new[i].y=res_y[ix] & new[i].flux=res_flux[ix]
      new[i].sharp=res_sharp[ix] & new[i].roundness=res_roundness[ix] & new[i].n=1
      new[i].iframe=res_iframe[ix]
      new[i].subfields=res_subfields[*,ix[0]]
    endif else begin ;; multiple stars in this group
      new[i].x=mean(res_x[ix]) & new[i].y=mean(res_y[ix]) & new[i].flux=mean(res_flux[ix])
      new[i].sharp=mean(res_sharp[ix]) & new[i].roundness=mean(res_roundness[ix])
      new[i].n=n_elements(ix)
      new[i].iframe=res_iframe[ix[0]] ;; just take one
      new[i].subfields=res_subfields[*,ix[0]] ;; just take one
    endelse
    i=i+1
  endwhile

help,new
  ix=where(new.n ge 1) & new=new[ix]
help,new

  return,new
end

function ssf_find_possible_frames,x,y,subims
;; purpose: to find all the sub-images that cover the [x,y] position
  ix=where((x ge subims.x1) and (x le subims.x2) and $
           (y ge subims.y1) and (y le subims.y2))
  if (n_elements(ix) lt 4) then for i=0,4-n_elements(ix)-1 do ix=[ix,-1]

  if (n_elements(ix) ne 4) then stop
  return,ix
end

function filterm,im
  zoom=3
  filter_width_parameter=0.1

  nx=n_elements(im[*,0])

  grid=ssf_make_grid2(nx)
  grid=grid/(1.*nx/2.)

  x=(1.-grid)>0.
  filter=1.0/(1+(x/filter_width_parameter)^10)


  lowpass=fft(fft(im,1)*filter,-1)

  result=sqrt(real_part(lowpass)^2+imaginary(lowpass)^2)

;  erase
;  tvscl,rebin(im,zoom*nx,zoom*nx),0
;  tvscl,rebin(grid,zoom*nx,zoom*nx),1
;  tvscl,rebin(filter,zoom*nx,zoom*nx),2
;  tvscl,rebin(result,zoom*nx,zoom*nx),3
;stop

;  writefits,'result.fits',result
;  spawn,'ds9 result.fits -zoom 6 &'
;surface,result
;stop

  return,result
end


pro ssf_smart_source_finder,field=field,band=band,ds9=ds9,$
      first=first,iframe=iframe,$
      plot_sig=plot_sig,display_regions=display_regions,$
      work_directory=work_directory,$
      shortlong=shortlong,infile=infile,$
      low_pass_filter=low_pass_filter


  if not keyword_set(field) then field='L1641'
  if not keyword_set(band) then band='3.6'
  if not keyword_set(shortlong) then shortlong='long'
  if not keyword_set(work_directory) then work_directory='/disk1/fang/SPITZER_DATA_PBCD/SPITZER_DATA/work_directory/'

  if keyword_set(iframe) then plot_intermediate=1

  ;; all values in pixel:
  boxsize=64  ;; size of sub-box in pixels
  overlap=10  ;; size of the overlapping region in pixels
  buffer=2    ;; size of the buffer (cut away the edges to get rid of edge effects
  npix_psf=32 ;; size of the psf image (for smoothing)

;; ATTENTION:   
;; the actual source finding is done in sub-images that are boxsize-2*buffer
;; large (square).
   overlap=overlap+buffer*2 ;; make sure the "real" overlap is preserved


  sharplim=[0.2,1.0]
  roundlim=[-1.0,1.0]

  ;; By experiment, we found the following parameters to give reasonable
  ;; results for the 10.4 second exposures. This may still be tuned
 
  if (shortlong eq 'long') then begin

    if (field eq 'L1641') then begin
 
      if (band eq '3.6') then begin
        fwhm_smooth=3.0
        sigmas_highcut=1.5
        nsig_limslim=750.
;        nsig_limslim=15.
        fwhm=1.5
      endif

      if (band eq '4.5') then begin
        fwhm_smooth=5.0
        sigmas_highcut=1.5
        nsig_limslim=500.
        fwhm=1.5
      endif

      if (band eq '5.8') then begin
        fwhm_smooth=4.0
        sigmas_highcut=1.3
        nsig_limslim=100.
        fwhm=1.7
      endif


      if (band eq '8.0') then begin
        fwhm_smooth=4.0
        sigmas_highcut=1.3
        nsig_limslim=100.
        fwhm=1.7
      endif

    if (field eq 'L1641') then begin

    endif


  endif
endif




  


end

;pro
; smart_source_finder,data_directory=data_directory,$
;         work_directory=work_directory,field=field


 
;end








pro ssc_test_twochannel_combi,field=field
;; purpose: select only those sources which were detected in both the 3.6 and 4.5
;; micron mosaic.

  match_radius=1.0 ;; [pixel]

  if not keyword_set(field) then field='L1630'

  restore,'/disk2/fang/SPITZER_DATA/work_directory/joined_IRAC_mosaics/found_sources/'+field+'_3.6_sources_bs64ov16_long.dat'
  s1=sources & fp1=find_parameters & subims1=subims

  restore,'/disk2/fang/SPITZER_DATA/work_directory/joined_IRAC_mosaics/found_sources/'+field+'_4.5_sources_bs64ov16_long.dat'
  s2=sources & fp2=find_parameters & subims2=subims

;  if ((fp1.boxsize ne fp2.boxsize) or (fp1.overlap ne fp2.overlap)) then begin
;    print,'the two source lists were not extracted on the same sub-image grid!'
;    stop
;  endif


  ;; unique "first" sub-fields in s1:
  s1_first_subfields=reform(s1.subfields[0,*])
  s1_unique_fields=ssf_find_unique_iframes(s1_first_subfields)
  match=intarr(n_elements(s1)) ;; will keep track of which sources in s1 have a counterpart
  ;;in s2 within a distance of match_radius on the sky.
  

  for i=0,n_elements(s1_unique_fields)-1 do begin
      ;; we will search for matches to all sources seen in this sub-image in
      ;; the first image.

    print,'doing s1 subfield '+strtrim(string(i),2)+' of '$
      +strtrim(string(n_elements(s1_unique_fields)),2)

    iframe=s1_unique_fields[i]
    ix1=where(s1_first_subfields eq s1_unique_fields[i])
    x1=s1[ix1].x 
    y1=s1[ix1].y

    ;; get all the sub-images in subims2 that overlap with this subim1:
    xcorner=[subims1[iframe].x1,subims1[iframe].x2,subims1[iframe].x1,subims1[iframe].x2]
    ycorner=[subims1[iframe].y1,subims1[iframe].y1,subims1[iframe].y2,subims1[iframe].y2]
    iframe2=ssf_find_possible_frames(xcorner[0],ycorner[0],subims2)
    for j=1,3 do $
      iframe2=[iframe2,ssf_find_possible_frames(xcorner[j],ycorner[j],subims2)]
    ix=where(iframe2 ne -1)
    if (ix[0] ne -1) then begin
      iframe2=ssf_find_unique_iframes(iframe2) ;; we have all subims in the second image
      ;; that overlap with the current sub-image in the first image

      ;; get all sources that have been detected
      ;; (or might have been detected) in each of iframe2
      ixx2=where(s2.subfields eq iframe2[0])
      ix2=floor(ixx2/4)
      if (n_elements(iframe2) ge 2) then for qq=1,n_elements(iframe2)-1 do begin
        ixx2=where(s2.subfields eq iframe2[qq])
        ix2=[ix2,floor(ixx2/4)]
      endfor
      ix2=ssf_find_unique_iframes(ix2)

      x2=s2[ix2].x
      y2=s2[ix2].y

      ;; now check for each source [x1,y1] whether there is a source in
      ;; [x2,y2] within match_radius:
      for i1=0,n_elements(x1)-1 do begin
        dist=sqrt((x1[i1]-x2)^2+(y1[i1]-y2)^2)
        if (min(dist) le match_radius) then match[ix1[i1]]=1 ;; we have a match!
      endfor
    endif
  endfor

  ix=where(match eq 1)
  res=s1[ix]

  work_directory='/disk2/fang/SPITZER_DATA/work_directory/'
  infile=work_directory+'joined_IRAC_mosaics/'+field+'_combi_long.fits'
  ssf_write_region_file,res,infile,regname=regname,boxsize=64,overlap=16
  return
end

pro extract_all
;  ssf_smart_source_finder,field='L1630',band='3.6'
;  ssf_smart_source_finder,field='L1630',band='4.5'
;  ssc_test_twochannel_combi,field='L1630'

  ssf_smart_source_finder,field='L1641',band='3.6',/first
  ssf_smart_source_finder,field='L1641',band='4.5',/first
  ssc_test_twochannel_combi,field='L1641'
  
  spawn,'ds9 /home/fang/disk2/SPITZER_DATA/work_directory/joined_IRAC_mosaics/L1630_4.5_stack_long.fits -scale log -scale zmax -region L1630_combi_long_bs64ov16.reg &'

end


pro test_MIPS,first=first,iframe=iframe
;  ssf_smart_source_finder,field='L1641',infile='/home/boekel/temp/L1641_MIPS_24mu_stack.fits',band='24',/first

  ssf_smart_source_finder,field='L1641',band='24',infile='/home/fang/disk2/SPITZER_DATA/original_MIPS_data/r12647936/ch1/pbcd/SPITZER_M1_12647936_0000_5_E3250934_maic.fits',first=first,iframe=iframe

end

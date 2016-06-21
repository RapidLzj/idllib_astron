function rgb,r,g,b
  result=1l*r+256l*g+256l^2*b
  return,result
end

function sky_med,im,x0,y0,R1,R2

temp=im
ss=size(im,/dim)

lx=round(x0-R1) > 0
ly=round(y0-R1) > 0
ux=round(x0+R1) < ss[0]-1
uy=round(y0+R1) < ss[1]-1

temp[lx:ux,ly:uy]=!VALUES.F_NAN
lx=round(x0-R2) > 0
ly=round(y0-R2) > 0
ux=round(x0+R2) < ss[0]-1
uy=round(y0+R2) < ss[1]-1

sky=temp[lx:ux,ly:uy]
med=median(sky,/even)

return,med
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
;;like ssf_make_grid, but center shifted by [-0.5,-0.5] pixels!
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

function ssf_determine_sigma,img,plotm=plotm
  ix=where(finite(img) eq 1 and img le 50000. and img ge -3000.) 
  med_val=median(img[ix])
  ix=where(finite(img) eq 1 and abs(img-med_val) le 5000. and img le 50000. and img ge -5000.) 
  im=img[ix]

  order=sort(im)
  y=im[order]

  xminlimit=0.10
  xmaxlimit=0.90

  xminlimit=xminlimit*n_elements(y)
  xmaxlimit=xmaxlimit*n_elements(y)

  xx=round([xminlimit,xmaxlimit])
  if (n_elements(y) gt 100) then sig=stddev(y[xx[0]:xx[1]],/double) else stop   

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
  while (i le n_elements(subims)-1) do begin
    lim=im[subims[i].x1:subims[i].x2,subims[i].y1:subims[i].y2]
    sigmas[i]=ssf_determine_sigma(lim)
print,i,sigmas[i],subims[i]
    i=i+1
  endwhile
print,'i,sigmas,subims'
  return,sigmas
end

function ssf_limit_sigmas,sigmas,nsigmax,plot_sig=plot_sig
  ix=where(sigmas gt 0.)
  minsigmas=min(sigmas[ix])
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

pro remove_stars,im,sources,outim,rad,fwhm
if not keyword_set(fwhm) then fwmm=10.0
if not keyword_set(R1) then R1=1.0

outim=im & x=sources.x &y=sources.y & ss=size(im,/dim)
nx=ss[0] &ny=ss[1]

R1=rad*fwhm &   R2=5*fwhm
print,'in the process of removing stars'
for i=0L,n_elements(x)-1L do begin
x0=x[i] &y0=y[i]
lx=round(x0-R1) & ly=round(y0-R1) & ux=round(x0+R1) &uy=round(y0+R1)
if lx lt 0 then lx=0 & if ly lt 0 then ly=0
if ux gt nx-1 then ux=nx-1 & if uy gt ny-1 then uy=ny-1
med=sky_med(im,x0,y0,R1,R2)
for j=lx,ux do for k=ly,uy do $ 
  if(sqrt((j*1.0-x0)^2.+(k*1.0-y0)^2) le R1) then outim[j,k]=med
;outim[lx:ux,ly:uy]=!VALUES.F_NAN
;outim[lx:ux,ly:uy]=med
endfor
print,'end of removing stars'
end



pro ssf_write_subims_regfile,subims,fitsname,buffer=buffer,subims_regfile=regname,sigmas
  a=strsplit(fitsname,'.fit',/reg,/ex)
  regname=a[0]+'_subims.reg'

  if not keyword_set(buffer) then buffer=0

  off=1. ;; offset to be added to x and y coordinates, typically 1.0 for stuff that has been extracted using idl, 0. for iraf/sextractor stuff.

  openw,lun,regname,/get_lun
  printf,lun,'image'
  i=0l
  while (i le (n_elements(subims)-1)) do begin
;    lim=im[subims[i].x1:subims[i].x2,subims[i].y1:subims[i].y2]
;    sigma=ssf_determine_sigma(lim)


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
                strtrim(string(i),2)+' sigma='+strtrim(string(sigmas[i],format='(f10.1)'),2)+'}'               
    printf,lun,line
    i=i+1
  endwhile
  close,lun
  free_lun,lun
  print,'wrote: ',regname
end


pro ssf_write_region_file1,new,fitsname,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer
  a=strsplit(fitsname,'.fit',/reg,/ex)
  regname=a[0]
  if not keyword_set(buffer) then buffer=0
  if keyword_set(boxsize) then regname=regname+'_bs'+strtrim(string(boxsize-2*buffer),2)
  if keyword_set(overlap) then regname=regname+'ov'+strtrim(string(overlap-2*buffer),2)
  regname=regname+'1.reg'

  off=0. ;; offset to be added to x and y coordinates, typically 1.0 for stuff that has been extracted using idl, 0. for iraf/sextractor stuff.

  bs=4.0
  openw,lun,regname,/get_lun
  j=0l
  printf,lun,'image'
  while (j le (n_elements(new)-1)) do begin
     line='circle('+strtrim(string(new[j].x+1.3,format='(f10.1)'),2)+','+$
                    strtrim(string(new[j].y+1.3,format='(f10.1)'),2)+','+$
                    strtrim(string(bs,format='(f10.1)'),2)+') # color=red'
    if ((finite(new[j].x) eq 1) and (finite(new[j].y) eq 1)) then $
    printf,lun,line
    j=j+1
  endwhile
  close,lun
  free_lun,lun
  print,'wrote: ',regname
end


pro ssf_write_region_file,new,fitsname,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer
  a=strsplit(fitsname,'.fit',/reg,/ex)
  regname=a[0]
  if not keyword_set(buffer) then buffer=0
  if keyword_set(boxsize) then regname=regname+'_bs'+strtrim(string(boxsize-2*buffer),2)
  if keyword_set(overlap) then regname=regname+'ov'+strtrim(string(overlap-2*buffer),2)
  regname=regname+'.reg'

  off=0. ;; offset to be added to x and y coordinates, typically 1.0 for stuff that has been extracted using idl, 0. for iraf/sextractor stuff.

  bs=4.0
  openw,lun,regname,/get_lun
  j=0l
  printf,lun,'image'
  while (j le (n_elements(new)-1)) do begin
     line='circle('+strtrim(string(new[j].x+1.3,format='(f10.1)'),2)+','+$
                    strtrim(string(new[j].y+1.3,format='(f10.1)'),2)+','+$
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
  print,'number of stars found: ',n_elements(res_x), ", which will be grouped now"

  same_source_radius=1.0 ;; pixels
  same_source_radius=2.0 ;; pixels
  if (n_elements(res_x) eq 1) then begin
   new={x:res_x,y:res_y,flux:res_flux,sharp:res_sharp,roundness:res_roundness,n:1,iframe:res_iframe,subfields:res_subfields}
  endif else begin
  GROUP_roy, res_X, res_Y, same_source_radius, NGROUP

  numberofgroups=max(ngroup+1)
  one={x:0.,y:0.,flux:0.,sharp:0.,roundness:0.,n:0,iframe:-1,subfields:[-1,-1,-1,-1]}
  new=replicate(one,numberofgroups)
  i=0l
  while (i le (n_elements(new)-1)) do begin
    ix=where(ngroup eq i)
    if (ix[0] eq -1) then new[i].n=0 else $
    if (n_elements(ix) eq 1) then begin ;; only one star in this group
      new[i].x=res_x[ix] & new[i].y=res_y[ix] & new[i].flux=res_flux[ix]
      new[i].sharp=res_sharp[ix] & new[i].roundness=res_roundness[ix] & new[i].n=1
      new[i].iframe=res_iframe[ix]
      new[i].subfields=res_subfields[*,ix[0]]
    endif else begin ;; multiple stars in this group
     
     ; new[i].x=mean(res_x[ix]) & new[i].y=mean(res_y[ix]) & new[i].flux=mean(res_flux[ix])
     ; new[i].sharp=mean(res_sharp[ix]) & new[i].roundness=mean(res_roundness[ix])
       new[i].x=median(res_x[ix],/even) & new[i].y=median(res_y[ix],/even) & new[i].flux=median(res_flux[ix],/even)
       new[i].sharp=median(res_sharp[ix],/even) & new[i].roundness=median(res_roundness[ix],/even)
       new[i].n=n_elements(ix)
       new[i].iframe=res_iframe[ix[0]] ;; just take one
       new[i].subfields=res_subfields[*,ix[0]] ;; just take one
    
    
    endelse
    i=i+1
  endwhile

endelse

help,new
  ix=where(new.n ge 1) & new=new[ix]
help,new
  print,'end of ssf_remove_multiple'
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
  stop

  x=(1.-grid)>0.
  filter=1.0/(1+(x/filter_width_parameter)^10)


  lowpass=fft(fft(im,1)*filter,-1)

  result=sqrt(real_part(lowpass)^2+imaginary(lowpass)^2)

  erase
  tvscl,rebin(im,zoom*nx,zoom*nx),0
  tvscl,rebin(grid,zoom*nx,zoom*nx),1
  tvscl,rebin(filter,zoom*nx,zoom*nx),2
  tvscl,rebin(result,zoom*nx,zoom*nx),3
stop

;  writefits,'result.fit',result
;  spawn,'ds9 result.fit -zoom 6 &'
;surface,result
;stop

  return,result
end

pro  sub_findsources,im,subims,buffer,firstlast,fwhm,nsig,sharplim,roundlim,plot_intermediate,sources,highsig
  res_x=0. & res_y=0. & res_flux=0. & res_sharp=0. & res_roundness=0. & res_iframe=-1
  res_subfields=[-1,-1,-1,-1]
  for i=firstlast[0],firstlast[1] do begin
    print,'doing subframe '+strtrim(string(i),2)+' of '+$
      strtrim(string(firstlast[1]-firstlast[0]),2)

;; old code: no buffers and NaNs replaced by zeroes
;    lim=im[subims[i].x1:subims[i].x2,subims[i].y1:subims[i].y2]
;    lim2=lim & ix=where(finite(lim2) ne 1) ;; make a copy of lim, where we replace the NaN
;    if (ix[0] ne -1) then lim2[ix]=0. ;; values with zeros. For making smoothed image.

;; new code: buffers and NaNs replaced by median value:
    lim=im[subims[i].x1:subims[i].x2,subims[i].y1:subims[i].y2]
    lim2=lim & ix=where(finite(lim2) ne 1) ;; make a copy of lim, where we replace the NaN
    if (ix[0] ne -1) then lim2[ix]=median(lim[ix]) ;; values with zeros. For making smoothed image.

    ix=where(lim2 gt 0.)
    if (ix[0] ne -1) then begin ;; we have signal in this sub-image
;      slim=convolve(lim2,smooth_psf)
;      nxi=n_elements(lim[*,0]) & nyi=n_elements(lim[0,*])
;      lim=lim[buffer:nxi-1-buffer,buffer:nyi-1-buffer]
;      slim=slim[buffer:nxi-1-buffer,buffer:nyi-1-buffer]

;      limslim=lim-slim
       lim1=lim-median(lim)
       iy=where(abs(lim1) le 500.)
       if iy[0] eq -1 then stop
       limslim=lim1-median(lim1[iy])
print,median(lim1[iy])
;       limslim=lim-median(lim[where(finite(lim))])
      

      ;; apply a low-pass filter:
;      if keyword_set(low_pass_filter) then limslim=filterm(limslim)
      limslim_sig=ssf_determine_sigma(limslim,plotm=plotm) 
      if (limslim_sig gt highsig) then limslim_sig=highsig
        
;     nsig=5
     x=0. & y=0.
     
     hmin=limslim_sig*nsig
     print,limslim_sig,hmin,nsig

      find_roy,limslim,x,y,flux,sharp,roundness,hmin,fwhm,roundlim,sharplim,/silent
;       find,limslim,x,y,flux,sharp,roundness,hmin,fwhm,roundlim,sharplim,/silent
 ;      ix=where(x gt 0 and y gt 0 and flux gt 0) 
;       x=x[ix] & y=y[ix] & flux=flux[ix] & sharp=sharp[ix] & roundness=roundness[ix]

     if ((x[0] ne 0.) and (y[0] ne 0.)) then ndetect=n_elements(x) else $
        ndetect=0

      if keyword_set(plot_intermediate) then begin
        erase
        zoom=3
        nxp=n_elements(lim[*,0]) & nyp=n_elements(lim[0,*])
        ix=where(finite(limslim) ne 1) & if (ix[0] ne -1) then limslim[ix]=0.
        tvscl,rebin(alog(limslim),nxp*zoom,nyp*zoom),0
        tvscl,rebin(alog(limslim-min(limslim)+0.01*max(limslim)),nxp*zoom,nyp*zoom),1

        dispim=alog(lim2-min(lim2)+0.005*max(lim2))
        tvscl,rebin(dispim,n_elements(dispim[*,0])*zoom,n_elements(dispim[0,*])*zoom)
        if (ndetect ge 1) then for q=0,n_elements(x)-1 do $
          ssf_put_cross,zoom*([x[q],y[q]]+[buffer,buffer]),/box

        print,'i: ',i,',  sigma: ',limslim_sig
        print,'i: ',i,',  nsig: ',nsig
        print,'i: ',i,',  hmin: ',hmin
        writefits,'temp/lim.fit',lim & print,'wrote: temp/lim.fit'
        writefits,'temp/limslim.fit',limslim & print,'wrote: temp/limslim.fit'
      endif

      if (ndetect ne 0) then begin ;; we have detected source(s).
        x=x+subims[i].x1+buffer & y=y+subims[i].y1+buffer
        res_x=[res_x,x] & res_y=[res_y,y] & res_flux=[res_flux,flux]
        res_sharp=[res_sharp,sharp] & res_roundness=[res_roundness,roundness]
        res_iframe=[res_iframe,intarr(n_elements(x))+i]
        ;; now determine the possible subframes in which this source could
        ;; be detected: 
        for qqq=0,ndetect-1 do begin
          possible_frames=ssf_find_possible_frames(x[qqq],y[qqq],subims)
          res_subfields=[[res_subfields],[possible_frames]]
        end
      endif

    endif else print,'i: ',i,', no valid pixels in this sub-frame'

;    if (ndetect ge 1) then print,x,y
    aa=''
    if (keyword_set(plot_intermediate) and not keyword_set(iframe)) then read,aa
    if keyword_set(iframe) then stop
  endfor

  nsss=n_elements(res_x)
  if (nsss gt 1) then begin
  res_x=res_x[1:nsss-1] & res_y=res_y[1:nsss-1]
  res_flux=res_flux[1:nsss-1] & res_sharp=res_sharp[1:nsss-1]
  res_roundness=res_roundness[1:nsss-1]
  res_iframe=res_iframe[1:nsss-1]
  res_subfields=res_subfields[*,1:nsss-1]
  endif

;  save,res_x,res_y,res_flux,res_sharp,res_roundness,filename='res.dat'
  sources=ssf_remove_multiple(res_x,res_y,res_flux,res_sharp,res_roundness,res_iframe,res_subfields)
end
 pro combin_sources,sources1,sources,col
   print,'begin to combine two sources',n_elements(sources),n_elements(sources1)
   spawn,'date'
   src1=sources
   for i=0L,n_elements(sources1)-1L do begin 
     iy=where(abs(sources1[i].x-col) lt 30)
    if iy[0] ne -1 then begin 
     ix=where(abs(sources.x-sources1[i].x) lt 1.)
     if (ix[0] ne -1) then src=sources[ix] & is=ix[0]
;     if (is eq -1) then print,i,ix,min(abs(sources.x-sources1[i].x))
     if (is eq -1) then src1=[src1,sources1[i]]
     if (is ne -1) then begin 
       dis=sqrt((src.x-sources1[i].x)^2.+(src.y-sources1[i].y)^2.)
       if (min(dis) ge 1.4) then src1=[src1,sources1[i]] 
     endif
    endif
   endfor
   sources=src1
   print,'end of combining, the final number of sources is ', n_elements(src1)
   spawn,'date'
 end

 pro remove_sources,sources,ix
   new=sources
   new=[new[0:ix[0]],new[ix[n_elements(ix)-1]:n_elements(new)-1]]
;   print,ix[0],ix[n_elements(ix)-1]
;   for i=0,n_elements(ix)-1 do begin
;    new=[new[0:ix[i]-i],new[ix[i]+2-i:n_elements(new)-1]]
;   endfor
   sources=new
 end

pro ssf_smart_source_finder,infile,im=im,hdr=hdr,iframe=iframe,fwhm=fwhm,ccdchip=ccdchip,maxvalue=maxvalue
   plot_intermediate=0
  if keyword_set(iframe) then plot_intermediate=1
  if not keyword_set(fwhm) then fwhm=10.
  if not keyword_set(hdr) then hdr=headfits(infile)
  if not keyword_set(im) then begin
  naxis=sxpar(hdr,'NAXIS')
  if (naxis eq 2) then begin
   backgroundsubtract=1  ; means do not subtract background
   imori=readfits(infile,hdrori)
  endif else if (naxis eq 0) then begin
   rdfits_struct,infile,stru,/silent
   IMAGETYP=sxpar(stru.hdr0,'IMAGETYP')
   naxis=sxpar(stru.hdr1,'NAXIS')
   if (ccdchip eq 1) then  begin
     hdr=stru.hdr1
     im=stru.im1
   endif
   if (ccdchip eq 2) then  begin
     hdr=stru.hdr2
     im=stru.im2
   endif
   if (ccdchip eq 3) then  begin
     hdr=stru.hdr3
     im=stru.im3
   endif
   if (ccdchip eq 4) then  begin
     hdr=stru.hdr4
     im=stru.im4
   endif
   print,"LBT data, using the chip",ccdchip
  endif
 endif
  
  nx=fix(sxpar(hdr,'NAXIS1')) & ny=fix(sxpar(hdr,'NAXIS2'))
  imori=imori-median(imori)
  if backgroundsubtract eq 1 then im=imori
  colmed=dblarr(nx) & for j=0,nx-1 do colmed[j]=median(imori[j,*])
  badcol=where(colmed ge 10000.) 
  if (backgroundsubtract eq 0) then begin 
   averx=dblarr(nx) & avery=dblarr(ny)
   for i=0,nx-1 do averx[i]=median(im[i,*]) 
   for i=0,ny-1 do avery[i]=median(im[*,i]) 
   ix=where(averx le 5000.) &  med1=median(averx[ix]) 
   ix=where(avery le 5000.) &  med2=median(avery[ix])
   
   ixnew1=0&ixnew2=nx-1&iynew1=0&iynew2=ny-1

   ix=where((averx[0:100]-med1) le -200 or finite(averx) eq 0) 
   if (ix[0] ne -1) then if (abs(median(averx[200:300])-median(averx[ix])) gt 100) $
       then ixnew1=ix[n_elements(ix)-1]>0  

   ix=where((averx[nx-101:nx-1]-med1) le -200)
   if (ix[0] ne -1) then if (abs(median(averx[nx-300:nx-200])-median(averx[ix+nx-101])) gt 100 )$
      then ixnew2=ix[0]+nx-101 

   ix=where((avery[0:100]-med2) le -200) 
   if (ix[0] ne -1) then if (abs(median(avery[200:300])-median(avery[ix])) gt 100) $
      then iynew1=ix[n_elements(ix)-1]>0 

   ix=where((avery[ny-101:ny-1]-med2) le -200) 
   if (ix[0] ne -1) then if (abs(median(avery[ny-300:ny-200])-median(avery[ix+ny-101])) gt 100) $
         then iynew2=ix[0]+ny-101 
  print,ixnew1,ixnew2,iynew1,iynew2

   im=im[ixnew1:ixnew2,iynew1:iynew2]
   nx=ixnew2-ixnew1+1
   ny=iynew2-iynew1+1
   fxaddpar,hdr,'NAXIS1',nx
   fxaddpar,hdr,'NAXIS2',ny
   writefits,strsplit(infile,'.fit',/reg,/ex)+'1.fit',im,hdr
  endif
  ;im[0:50,0:ny-1]=!VALUES.F_NAN
  ;im[nx-51:nx-1,0:ny-1]=!VALUES.F_NAN
  

  ;; all values in pixel:
  boxsize=250  ;; size of sub-box in pixels
  overlap=50  ;; size of the overlapping region in pixels
  buffer=0    ;; size of the buffer (cut away the edges to get rid of edge effects
  npix_psf=20 ;; size of the psf image (for smoothing)
  boxsize=fix(nx/4)
  overlap=fix(boxsize/5)
  npix_psf=fwhm*30

;; ATTENTION:   
;; the actual source finding is done in sub-images that are boxsize-2*buffer
;; large (square).
   overlap=overlap+buffer*2 ;; make sure the "real" overlap is preserved

  sigmas_highcut=1.
  
  subims=ssf_get_subims(nx,ny,boxsize,overlap)

  ;; initialize result_variables:
  
;  sharplim=[-1.,2.0]
;  roundlim=[-2.0,2.0]
     sharplim=[0.2,1.0]
     roundlim=[-1.0,1.0]
     fwhm_smooth=fwhm*5
     nsig_limslim=5.
     im1=im   ;& iy=where(finite(im1)) & ix=where(im1 ge max(im1[iy])*0.9) & im1[ix]=!VALUES.F_NAN
;     writefits,strsplit(infile,'.fit',/reg,/ex)+'_nan.fit',im1,hdr
     
     sigmas=ssf_get_sigmas(im1,subims)
     ssf_write_subims_regfile,subims,infile,buffer=buffer,subims_regfile=subims_regfile,sigmas
     highsig=min(sigmas)*10.0
     if keyword_set(iframe) then firstlast=[iframe,iframe] else firstlast=[0,n_elements(subims)-1]
     sub_findsources,im1,subims,buffer,firstlast,fwhm,nsig_limslim,sharplim,roundlim,plot_intermediate,sources1,highsig
     ssf_write_region_file1,sources1,infile,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer
  if(backgroundsubtract ne 1) then begin 
     remove_stars,im,sources1,outim,3.0,fwhm
    writefits,strsplit(infile,'.fit',/reg,/ex)+'_removestars.fit',outim,hdr
    print,'convolving in process'
    smooth_psf=ssf_make_psf(npix_psf,fwhm_smooth)
    newim=convolve(outim,smooth_psf,FT_PSF = psf_FT)
    writefits,strsplit(infile,'.fit',/reg,/ex)+'_new.fit',newim,hdr
    newim=im-newim
    writefits,strsplit(infile,'.fit',/reg,/ex)+'_backsub.fit',newim,hdr
    im=newim
  endif   
;;; begin to find sources in the background-subtracted image

    sigmas=ssf_get_sigmas(im,subims)
    highsig=min(sigmas)*10.0
    ix=where(sigmas gt highsig) & if (ix[0] ne -1) then sigmas[ix]=highsig
    ssf_write_subims_regfile,subims,infile,buffer=buffer,subims_regfile=subims_regfile,sigmas
    maxvalue=55000.
;    sharplim=[-1.,2.0]
;    roundlim=[-2.0,2.0]
    sharplim=[0.2,1.0]
    roundlim=[-1.0,1.0]
    nsig_limslim=5.
    fwhm_smooth=fwhm*5
;   fwhm1=estimate_fwhm(im,fwhm1,maxvalue,ini_fwhm=fwhm,gain=1.75,fwhm_sig=fwhm_sig)
;   print,fwhm1,fwhm,maxvalue
;   fwhm=fwhm1
    firstlast=[0,n_elements(subims)-1]
;   firstlast=[35,40]
    sub_findsources,im,subims,buffer,firstlast,fwhm,nsig_limslim,sharplim,roundlim,plot_intermediate,sources,highsig
print,nsig_limslim
ix=sort(sources.x) & sources=sources[ix]
ix=sort(sources1.x) & sources1=sources1[ix]
;    combin_sources,sources1,sources,badcol
;print,badcol
;print,n_elements(sources)
ix=sort(sources.x) & sources=sources[ix]
    for kk=n_elements(badcol)-1,0,-1 do begin 
      ix=where(sources.x-badcol[kk] lt 1 and sources.x-badcol[kk] ge 0)
;      if (ix[0] ne -1) then print,kk,n_elements(ix),' sources should be removed'
      if (ix[0] ne -1) then remove_sources,sources,ix 
    endfor
find_parameters={boxsize:boxsize,overlap:overlap,npix_psf:npix_psf,sharplim:sharplim,$
                   roundlim:roundlim,fwhm_smooth:fwhm_smooth,sigmas_highcut:sigmas_highcut,$
                   nsig_limslim:nsig_limslim,fwhm:fwhm}
 
    edge=10
    ix=where(sources.x ge edge and sources.x lt nx-edge and sources.y ge edge and sources.y lt ny-edge)
    if (ix[0] ne -1) then   sources=sources[ix] else stop


  ix=where(sources.flux ge 2.0e4 and abs(sources.roundness) ge 1.0)
  if (ix[0] ne -1) then begin 
   sources1=sources[ix] 
;   ssf_write_region_file1,sources1,infile,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer
  endif
  ssf_write_region_file,sources,infile,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer
  
  fname=strsplit(infile,'.fit',/reg,/ex)
  outfile=fname+'_sources'
  outfile=outfile+'_bs'+strtrim(string(boxsize-2*buffer),2)
  outfile=outfile+'ov'+strtrim(string(overlap-2*buffer),2)
  outfile=outfile+'_'+'.dat'
  save,sources,find_parameters,subims,filename=outfile
  print,'wrote: ',outfile
  if keyword_set(ds9) then spawn,cmd
  return
end

;  spawn,'ds9 /home/fang/disk2/SPITZER_DATA/work_directory/joined_IRAC_mosaics/L1630_4.5_stack_long.fit -scale log -scale zmax -region L1630_combi_long_bs64ov16.reg &'


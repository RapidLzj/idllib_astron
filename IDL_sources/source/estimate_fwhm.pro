function estimate_fwhm,fname,psf_fwhm,maxvalue,gain=gain,ini_fwhm=ini_fwhm,fwhm_sig=fwhm_sig
 
  if not keyword_set(gain) then gain=1.5 ;;gain for LAICA 
  if not keyword_set(ini_fwhm) then ini_fwhm=8 ;;  
 

  im=readfits(fname,hdr,/noscale)
  ix=where(finite(im) ne 0) 
  img=im[ix] 
  if min(im) gt 30000. then begin
    print,"image is read improperly, should be subtracted by 32768.0"
    im=im-32768.0
    
  endif
  print,min(im),median(im),max(im)
  if min(im) gt 30000. then stop

  med=median(img,/even)
  if med gt 0 then  std=sqrt(med)/gain^0.5 else  std=5.
   
  nmax=3
  inter=0  
  

  
  while(inter le nmax) do begin
  
  ix=where(img ge med-3*std and img le med+3*std)  
  img=img[ix]
  std=stddev(img,/double)
  med=median(img,/even)
  inter+=1
  endwhile

  hmin=std*10.
  sharplim=[0.0,1.0]
  roundlim=[-2.0,2.0]
  if not keyword_set(ini_fwhm) then ini_fwhm=5.
  ;fwhm=ini_fwhm
  find_roy,im,x0,y0,flux,sharp,roundness,hmin,ini_fwhm,roundlim,sharplim,/sil

  npsf_fwhm=3.
  same_source_radius=ini_fwhm*npsf_fwhm 
  if n_elements(x0) gt 1 and total(x0) gt 1 and total(y0) gt 1 then $ 
    GROUP_roy, x0, y0, same_source_radius, NGROUP $ 
  else begin  
   psf_fwhm=-1.
   goto,labendoffwhm
  endelse
  numberofgroups=max(ngroup+1)
  one={x:0.,y:0.,n:0,flux:0.,err_flux:0.}
 
  new=replicate(one,numberofgroups)
  i=0l
  star_num=0l
  while (i lt (n_elements(new)-1)) do begin
    ix=where(ngroup eq i)
    if (ix[0] ne -1) then $
    if (n_elements(ix) eq 1) then begin ;; only one star in this group
      new[star_num].x=x0[ix] & new[star_num].y=y0[ix] 
      new[star_num].flux=flux[ix]
      star_num+=1
    ; print,x0[ix],y0[ix],format='(2f)'
     endif 
    
    i=i+1
  endwhile
   star_num=star_num
   new=new[0:star_num-1]

   ss=size(im,/dim)
   buffer=100
   ix=where(new.x ge buffer and new.x le ss[0]-buffer and new.y ge buffer and new.y le ss[1]-buffer)
   new=new[ix]

 
   maxvalue=maxvalue*0.9
 
   maxcen=fltarr(n_elements(new))
  
   
   for i=0L,n_elements(new)-1 do begin
   lx=round(new[i].x)-5 > 0
   ux=round(new[i].x)+5 < ss[0]-1
   ly=round(new[i].y)-5 > 0
   uy=round(new[i].y)+5 < ss[1]-1
   maxcen[i]=max(im[lx:ux,ly:uy])  
    endfor


    ix=where(maxcen le maxvalue)
    if ix[0] eq -1 then begin 
     psf_fwhm=-1.
     goto,labendoffwhm
    endif else new=new[ix]


;  star_fwhm=fltarr(n_elements(ix))
  xfwhm=fltarr(n_elements(ix)) 
  yfwhm=fltarr(n_elements(ix)) 
  
  for jj=0L,n_elements(ix)-1L do begin
  lx=round(new[jj].x)-same_source_radius > 0
  ux=round(new[jj].x)+same_source_radius < ss[0]-1
  ly=round(new[jj].y)-same_source_radius > 0
  uy=round(new[jj].y)+same_source_radius < ss[1]-1
  star_array=im[lx:ux,ly:uy]
  ;med=median(star_array,/even)
  ;star_array=star_array-med
  ;star_fwhm[jj]=fwhm(star_array)
  yfit=gauss2dfit(star_array,A) 
  xfwhm[jj]=2*sqrt(alog(2.))*A[2]&yfwhm[jj]=2*sqrt(alog(2.))*A[3]
 
  endfor
  ix=where(xfwhm ne 1. and yfwhm ne 1. and xfwhm/yfwhm ge 0.5 and xfwhm/yfwhm le 2.)
 
  ;fwhm=sqrt((xfwhm[ix]^2.+yfwhm[ix]^2.)/2.)
 
  sfwhm=sqrt(2.*xfwhm[ix]^2.*yfwhm[ix]^2./(xfwhm[ix]^2.+yfwhm[ix]^2.))

  ix=where(sfwhm gt 1.) 
  sfwhm=sfwhm[ix]
  psf_fwhm=median(sfwhm,/even)
 ; print,sfwhm
  if n_elements(ix) ge 2 then begin  

  std=stddev(sfwhm)  
 
  inter=0
  nmax=3
  
  while(inter le nmax) do begin
  
  ix=where(sfwhm ge psf_fwhm-3*std and sfwhm le psf_fwhm+3*std)  
  sfwhm=sfwhm[ix]
  psf_fwhm=median(sfwhm,/even)
  fwhm_sig=stddev(sfwhm)  
  inter+=1
  endwhile
 endif
labendoffwhm:
  return,psf_fwhm 
    

end


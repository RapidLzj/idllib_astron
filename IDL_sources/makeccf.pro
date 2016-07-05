@/home/wwang/soft/idl_7.0/iuedac/iuelib/pro/crscor.pro
@/home/wwang/soft/idl_7.0/iuedac/iuelib/pro/linfit.pro
pro speimg2matrix,img,hdr,flux,wave
     npix=size(img,/dim)
     wave=fltarr(npix)
     ipix=indgen(npix,/long)
     wave_beg=sxpar(hdr,'CRVAL1')
     pixe_beg=sxpar(hdr,'CRPIX1')
     disp=sxpar(hdr,'CDELT1')
     flux=img
     wave[ipix]=(ipix-pixe_beg)*disp+wave_beg
end
;;; now only for FEROS data
   pro makeccf,cho,spename1,spename2,mask 
    if not keyword_set(cho) then cho=1
    if not keyword_set(spename2) then spename2=spename1
    spe1=readfits(spename1,hdr1)
    speimg2matrix,spe1,hdr1,flux1,wave1
;    readcol,mask,left,right
    readcol,mask,nnn,posis
    print,n_elements(posis)
    left=[posis[0]<posis[1]] & right=[posis[1]>posis[1]]
    for i=1,n_elements(posis)/2-1 do begin 
     left=[left,posis[2*i]<posis[2*i+1]] 
     right=[right,posis[2*i]>posis[2*i+1]] 
    endfor
    if (cho eq 1) then begin 
     print,'the second spectrum is in fits format'
     spe2=readfits(spename2,hdr2)
     speimg2matrix,spe2,hdr2,flux2,wave2 
     flux2n=flux2
     flux2n[*]=0.0
     for i=0,n_elements(left)-1 do begin 
      ix=where(wave2 ge left[i] and wave2 le right[i])
      flux2n[ix]=flux2[ix] 
     endfor
     flux2=flux2n
    endif else begin
     print,'the second spectrum is in ascii format'
     readcol,spename2,wave2,flux2
    endelse
   crscor,wave1,flux1,wave2,flux2,wave1[0]+10,wave1[n_elements(wave1)-1]-10,delvel,vinc=5,CCF=ccf  
   end

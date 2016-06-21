function coor_extract,x1,x2

 num=n_elements(x1)
 res=fltarr(num)

 for i=0LL,num-1LL do begin
  if x1[i] eq 0. then begin
  res[i]=x2[i]
 endif else begin
  if x2[i] eq 0. then begin 
  res[i]=x1[i] 
  endif  else begin 
   res[i]=(x1[i]+x2[i])/2d0
   endelse
 endelse
 endfor
 return,res 
end




pro channel_combination, band,oldphot,channel_one,newphot
     
     phot=oldphot
     match_radius=1.5  
     ;channel_xcoor=coor_extract(channel_one.short.RA,channel_one.long.RA)
     ;channel_ycoor=coor_extract(channel_one.short.DEC,channel_one.long.DEC) 
     channel_xcoor=channel_one.coor.RA
     channel_ycoor=channel_one.coor.DEC
     

     ;RA=[channel_xcoor,phot.coords.RA]
     ;DEC=[channel_ycoor,phot.coords.DEC]
     ;ix=where()     

     minRA=min([channel_xcoor,phot.coords.RA])
     maxRA=max([channel_xcoor,phot.coords.RA])
     minDEC=min([channel_ycoor,phot.coords.DEC])
     maxDEC=max([channel_ycoor,phot.coords.DEC])

    

     nx=fix((maxRA-minRA)*3600.+5)
     ny=fix((maxDEC-minDEC)*3600+5)  
     


     boxsize=100
     overlap=10
 
   subim=ssf_get_subims(nx,ny,boxsize,overlap)
   band_name=['3.6','4.5','5.8','8.0']
   band_num=where(band_name eq band)
;   stop
  
 ; help,/str,phot
 ; help,/str,channel_one
  
  flag=intarr(n_elements(channel_one.short))
  
  
  for i=0LL,n_elements(subim)-1LL do begin
 ; print,'subimage'+string(i+1)
  ;print,i
  ix1=where(channel_xcoor ge subim[i].x1/3600d0+minRA and  channel_xcoor lt subim[i].x2/3600d0+minRA and channel_ycoor ge subim[i].y1/3600d0+minDEC and channel_ycoor lt subim[i].y2/3600d0+minDEC)
  ix2=where(phot.coords.RA ge subim[i].x1/3600d0+minRA and phot.coords.RA lt subim[i].x2/3600d0+minRA and phot.coords.DEC ge subim[i].y1/3600d0+minDEC and phot.coords.DEC lt subim[i].y2/3600d0+minDEC )
  ;print,subim[i].x1/3600d0+minRA,subim[i].x2/3600d0+minRA
  ;print, subim[i].y1/3600d0+minDEC,subim[i].y2/3600d0+minDEC
  ;print,n_elements(ix1),n_elements(ix2)
  ; if n_elements(ix1) ge 50 and n_elements(ix2) ge 50 then stop

   if ix1[0] ne -1 and ix2[0] ne -1 then begin
  for num=0L,n_elements(ix1)-1L do begin
  R=sqrt(((channel_xcoor[ix1[num]]-phot[ix2].coords.RA)*cos(!PI*channel_ycoor[ix1[num]]/180.))^2.+(channel_ycoor[ix1[num]]-phot[ix2].coords.DEC)^2.)*3600.
  ix=sort(R)
   ; print,R[ix[0]]
    if R[ix[0]] le match_radius then begin
     print,R[ix[0]] 
    phot[ix2[ix[0]]].(band_num).short=channel_one.short[ix1[num]]
    phot[ix2[ix[0]]].(band_num).long=channel_one.long[ix1[num]]
    phot[ix2[ix[0]]].detect[band_num]=1  
    phot[ix2[ix[0]]].flux[band_num]=flux_extract(band,channel_one.short[ix1[num]].psfflux,channel_one.long[ix1[num]].psfflux)
    phot[ix2[ix[0]]].errflux[band_num]=errflux_extract(band,channel_one.short[ix1[num]].psfflux,channel_one.long[ix1[num]].psfflux,$
                                                       channel_one.short[ix1[num]].psfflux_err,channel_one.long[ix1[num]].psfflux_err)
   
    ;xtemp=coor_extract(channel_one.short[ix1[num]].x,channel_one.long[ix1[num]].x)
    ;ytemp=coor_extract(channel_one.short[ix1[num]].y,channel_one.long[ix1[num]].y)
    ;phot[ix2[ix[0]]].coords.x=coor_extract(phot[ix2[ix[0]]].coords.x,xtemp)
    ;phot[ix2[ix[0]]].coords.y=coor_extract(phot[ix2[ix[0]]].coords.y,ytemp)
    flag[ix1[num]]=1
    endif
   endfor
  endif
  endfor


;stop

    ini_short={detect:0,x:0.,y:0.,RA:0d0,dec:0d0,psfflux:0.,psfflux_err:0.,correlation:0.,aperflux:0.,aperflux_err:0.,qual:''}
   ini_long=ini_short

  ch1={short:ini_short,long:ini_long}
  ch2=ch1 & ch3=ch1 & ch4=ch1

  coords={RA:0d0,dec:0d0,RAerr:0.,decerr:0.,x:0.,y:0.,xerr:0.,yerr:0.}

  ;ini_phot={ch1:ch1,ch2:ch2,ch3:ch3,ch4:ch4,$
  ;      detect:intarr(4),coords:coords,$
  ;      lam:fltarr(4),flux:fltarr(4)}
  ini_phot={ch1:ch1,ch2:ch2,ch3:ch3,ch4:ch4,$
        detect:intarr(4),coords:coords,$
        lam:fltarr(4),flux:fltarr(4),errflux:fltarr(4),mag:fltarr(4),errmag:fltarr(4),qual_flag:strarr(4)}


 ix=where(flag eq 0)
 temp_phot=replicate(ini_phot,n_elements(ix))
 
 
 print,'start to feed new stars into phot sturcture!!!'
 
 
 for num=0LL,n_elements(ix)-1LL do begin
    
    temp_phot[num].(band_num).short=channel_one.short[ix[num]]
    temp_phot[num].(band_num).long=channel_one.long[ix[num]]
    temp_phot[num].detect[band_num]=1  
    temp_phot[num].flux[band_num]=flux_extract(band,channel_one.short[ix[num]].psfflux,channel_one.long[ix[num]].psfflux)
    temp_phot[num].errflux[band_num]=errflux_extract(band,channel_one.short[ix[num]].psfflux,channel_one.long[ix[num]].psfflux,$
                                           channel_one.short[ix[num]].psfflux_err,channel_one.long[ix[num]].psfflux_err)
   
    if   channel_one.long[ix[num]].detect eq 1 then begin
      temp_phot[num].coords.RA=channel_one.long[ix[num]].RA
      temp_phot[num].coords.DEC=channel_one.long[ix[num]].DEC
    endif else begin
      temp_phot[num].coords.RA=channel_one.short[ix[num]].RA
      temp_phot[num].coords.DEC=channel_one.short[ix[num]].DEC
   endelse


  ;xtemp=coor_extract(channel_one.short[ix[num]].x,channel_one.long[ix[num]].x)
    ;ytemp=coor_extract(channel_one.short[ix[num]].y,channel_one.long[ix[num]].y)
    ;temp_phot[num].coords.x=xtemp
    ;temp_phot[num].coords.y=ytemp
  
 endfor
 
   phot=[phot,temp_phot]
 newphot=phot
 print,'finished feeding new stars into phot sturcture!!!'


end

function flux_extract,band,shortflux,longflux

if band eq '3.6' then uplimit=1000.0
if band eq '4.5' then uplimit=2000.0
if band eq '5.8' then uplimit=2000.0
if band eq '8.0' then uplimit=2000.0


if (shortflux gt uplimit or longflux eq 0.0) then flux=shortflux else flux=longflux

return,flux
end


function errflux_extract,band,shortflux,longflux,shortflux_err,longflux_err

if band eq '3.6' then uplimit=1200.0
if band eq '4.5' then uplimit=2000.0
if band eq '5.8' then uplimit=2000.0
if band eq '8.0' then uplimit=2000.0


if (shortflux gt uplimit or longflux eq 0.0) then errflux=shortflux_err else errflux=longflux_err

return,errflux
end



function two_exposure_combination,longdata,shortdata,hdrl,hdrs
   ix=where(longdata.psf_flux gt 0)
   longdata=longdata(ix)
   ix=where(shortdata.psf_flux gt 0)
   shortdata=shortdata(ix)
   
   
  
   xyad,hdrl,longdata.x,longdata.y,RA_long,DEC_long
   xyad,hdrs,shortdata.x,shortdata.y,RA_short,DEC_short
   
 
  
  ini_short={detect:0,x:0.,y:0.,RA:0d0,dec:0d0,psfflux:0.,psfflux_err:0.,correlation:0.,aperflux:0.,aperflux_err:0.,qual:''}
   ini_long=ini_short
 

   long=replicate(ini_long,n_elements(longdata))
   short=replicate(ini_short,n_elements(longdata))
   flag=intarr(n_elements(shortdata))
   
   for i=0LL,n_elements(long)-1LL do begin
      long[i].detect=1
      long[i].x=longdata[i].x
      long[i].y=longdata[i].y
      long[i].RA=RA_long[i]
      long[i].DEC=DEC_long[i]
      long[i].psfflux=longdata[i].psf_flux
      long[i].psfflux_err=longdata[i].psf_flux_sigma
      long[i].correlation=longdata[i].psf_correlation
      long[i].aperflux=longdata[i].aper_flux
      long[i].aperflux_err=longdata[i].aper_errflux
      long[i].qual=''
   endfor
   
 
   
   nx=max([max(long.x),max(short.x)])+5
   ny=max([max(long.y),max(short.y)])+5
   
  boxsize=64
  overlap=10
  
  
  
   subim=ssf_get_subims(nx,ny,boxsize,overlap)

   for i=0LL,n_elements(subim)-1LL do begin
   
 
    ix1=where(shortdata.x ge subim[i].x1 and shortdata.x lt subim[i].x2 and shortdata.y ge subim[i].y1 $  
              and shortdata.y lt subim[i].y2)
    
    ix2=where(longdata.x ge subim[i].x1 and longdata.x lt subim[i].x2 and longdata.y ge subim[i].y1 $  
              and longdata.y lt subim[i].y2)
    
    if ix1[0] ne -1 and ix2[0] ne -1 then begin
                  xlong=longdata[ix2].x
                  ylong=longdata[ix2].y
      
       
      
                  xshort=shortdata[ix1].x
                  yshort=shortdata[ix1].y
          psf_flux_short=shortdata[ix1].psf_flux   
      psf_flux_err_short=shortdata[ix1].psf_flux_sigma 
       correlation_short=shortdata[ix1].psf_correlation
          aperflux_short=shortdata[ix1].aper_flux
      sperflux_err_short=shortdata[ix1].aper_errflux  
	              RA=RA_short[ix1]
                     DEC=DEC_short[ix1]
		           
      for num=0L,n_elements(ix1)-1L do begin
        R=sqrt((xshort[num]-xlong)^2.0+(yshort[num]-ylong)^2.0)
        ix=sort(R)

        if R[ix[0]] le 1.0 then begin
	  short[ix2[ix[0]]].detect=1
	  short[ix2[ix[0]]].x=xshort[num]
          short[ix2[ix[0]]].y=yshort[num]
          short[ix2[ix[0]]].RA=RA[num]
          short[ix2[ix[0]]].DEC=DEC[num]
          short[ix2[ix[0]]].psfflux=psf_flux_short[num]
          short[ix2[ix[0]]].psfflux_err=psf_flux_err_short[num]
          short[ix2[ix[0]]].correlation=correlation_short[num]
          short[ix2[ix[0]]].aperflux=aperflux_short[num]
          short[ix2[ix[0]]].aperflux_err=sperflux_err_short[num]
          short[ix2[ix[0]]].qual=''
	  flag[ix1[num]]=1
	endif 
      endfor
    endif
  endfor
  
  
   ix=where(flag eq 0)
   
   temp_short=replicate(ini_short,n_elements(ix))
   temp_long=replicate(ini_long,n_elements(ix))
   for j=0LL,n_elements(ix)-1LL do begin
           temp_short[j].detect=1
	   temp_short[j].x=shortdata[ix[j]].x
           temp_short[j].y=shortdata[ix[j]].y
           temp_short[j].RA=RA_short[ix[j]]
           temp_short[j].DEC=DEC_short[ix[j]]
           temp_short[j].psfflux=shortdata[ix[j]].psf_flux
           temp_short[j].psfflux_err=shortdata[ix[j]].psf_flux_sigma
           temp_short[j].correlation=shortdata[ix[j]].psf_correlation
           temp_short[j].aperflux=shortdata[ix[j]].aper_flux
           temp_short[j].aperflux_err=shortdata[ix[j]].aper_errflux
           temp_short[j].qual=''
 
  endfor
  short=[short,temp_short]
  long=[long,temp_long]
  
  channel={short:short,long:long}
  coor={RA:0d0,DEC:0d0}
  coor=replicate(coor,n_elements(channel.short))
  for i=0,n_elements(channel.short)-1 do begin
    if channel.short[i].detect eq 1 then begin
       coor[i].RA=channel.short[i].RA 
       coor[i].DEC=channel.short[i].DEC
    endif else begin
        coor[i].RA=channel.long[i].RA 
        coor[i].DEC=channel.long[i].DEC 
    endelse
     
  endfor 

   channel={short:short,long:long,coor:coor}
 return,channel

end

pro wrap_data_structure,field=field,work_directory=work_directory,psf_size=psf_size, $
     create_channel_structure=create_channel_structure,create_phot=create_phot

  ini_short={detect:0,x:0.,y:0.,RA:0d0,dec:0d0,psfflux:0.,psfflux_err:0.,correlation:0.,aperflux:0.,aperflux_err:0.,qual:''}
   ini_long=ini_short

  ch1={short:ini_short,long:ini_long}
  ch2=ch1 & ch3=ch1 & ch4=ch1

  coords={RA:0d0,dec:0d0,RAerr:0.,decerr:0.,x:0.,y:0.,xerr:0.,yerr:0.}

  phot={ch1:ch1,ch2:ch2,ch3:ch3,ch4:ch4,$
        detect:intarr(4),coords:coords,$
        lam:fltarr(4),flux:fltarr(4),errflux:fltarr(4),mag:fltarr(4),errmag:fltarr(4),qual_flag:strarr(4)}


if not keyword_set(psf_size) then psf_size=13




;band=['3.6','4.5','5.8','8.0']


band=['3.6','4.5','5.8','8.0'] 
;;;;;;;;;;;;;;create channel structures;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(create_channel_structure) then begin

for i=0,n_elements(band)-1 do begin

shortfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band[i]$
            +'_short_ps'+strtrim(string(psf_size),2)+'_psf_fitting_sources.dat'
restore,shortfile

shortsources=psf_fitting_sources

longfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band[i]$
            +'_long_ps'+strtrim(string(psf_size),2)+'_psf_fitting_sources.dat'
restore,longfile
longsources=psf_fitting_sources
im=work_directory+'joined_IRAC_mosaics/'+field+'_'+band[i]$
            +'_short.fits'
hdrs=headfits(im)
im=work_directory+'joined_IRAC_mosaics/'+field+'_'+band[i]$
            +'_long.fits'
hdrl=headfits(im)

channel=two_exposure_combination(longsources,shortsources,hdrl,hdrs)
;im=work_directory+'joined_IRAC_mosaics/'+field+'_3.6'$
;            +'_long.fits'
;hdr=headfits(im)
;adxy,hdr,channel.short.RA,channel.short.DEC,x,y
;channel.short.x=x &channel.short.y=y
;adxy,hdr,channel.long.RA,channel.long.DEC,x,y
;channel.long.x=x &channel.long.y=y
infile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band[i]$
            +'_ps'+strtrim(string(psf_size),2)+'_channel_structure.dat'
save,channel,filename=infile
print,infile+' wrote!!'
endfor
endif


;;;;;;;;;;;;combining the channel structures;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
infile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band[0]$
            +'_ps'+strtrim(string(psf_size),2)+'_channel_structure.dat'
restore,infile
channel_one=channel

if keyword_set(create_phot) then begin
;;;;;;;;;;;;;initializing the phot structure;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
star_num=n_elements(channel.long)
phot.lam=[3.6,4.5,5.8,8.0]
phot=replicate(phot,star_num)


for i=0LL,star_num-1LL do begin
  phot[i].ch1.short=channel_one.short[i]
  phot[i].ch1.long=channel_one.long[i]
  phot[i].detect[0]=1  
  phot[i].flux[0]=flux_extract(band[0],channel_one.short[i].psfflux,channel_one.long[i].psfflux)
  phot[i].errflux[0]=errflux_extract(band[0],channel_one.short[i].psfflux,channel_one.long[i].psfflux,$
                     channel_one.short[i].psfflux_err,channel_one.long[i].psfflux_err)
  if  channel_one.long[i].detect eq 1 then begin
      phot[i].coords.RA=channel_one.long[i].RA
      phot[i].coords.DEC=channel_one.long[i].DEC 
   endif else begin
      phot[i].coords.RA=channel_one.short[i].RA
      phot[i].coords.DEC=channel_one.short[i].DEC 
   endelse
  ;phot[i].coords.x=coor_extract(channel_one.short[i].x,channel_one.long[i].x)
  ;phot[i].coords.y=coor_extract(channel_one.short[i].y,channel_one.long[i].y)
endfor

outfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_phot.dat'
save,phot,filename=outfile
print,outfile+' wrote!!!'



;;;;;;;;;;;;;;;feed channel into phot stucture;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 for j=1,n_elements(band)-1 do begin
;for j=1,1 do begin
outfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_phot.dat'
restore,outfile
oldphot=phot

print,band[j]+' feed into phot structure'

infile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_'+band[j]$
            +'_ps'+strtrim(string(psf_size),2)+'_channel_structure.dat'
restore,infile
channel_one=channel
help,/str,channel_one

channel_combination,band[j],oldphot,channel_one,newphot
phot=newphot


outfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_phot.dat'
save,phot,filename=outfile
print,outfile+' wrote!!!'

print,'stellar numbers='+n_elements(phot)
help,/str,phot

;a=''
;read,a
endfor


;;;;;;;;;;;;;;calculating the magnitude for each channels;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ix=where(phot.ch1.short.detect eq 1 or phot.ch1.long.detect eq 1)
phot[ix].mag[0]=17.30-2.5*alog10(phot[ix].flux[0])
phot[ix].errmag[0]=2.5*alog10((phot[ix].flux[0]+phot[ix].errflux[0])/phot[ix].flux[0])

ix=where(phot.ch2.short.detect eq 1 or phot.ch2.long.detect eq 1)
phot[ix].mag[1]=16.82-2.5*alog10(phot[ix].flux[1])
phot[ix].errmag[1]=2.5*alog10((phot[ix].flux[1]+phot[ix].errflux[1])/phot[ix].flux[1])


ix=where(phot.ch3.short.detect eq 1 or phot.ch3.long.detect eq 1)
phot[ix].mag[2]=16.33-2.5*alog10(phot[ix].flux[2])
phot[ix].errmag[2]=2.5*alog10((phot[ix].flux[2]+phot[ix].errflux[2])/phot[ix].flux[2])

ix=where(phot.ch4.short.detect eq 1 or phot.ch4.long.detect eq 1)
phot[ix].mag[3]=15.69-2.5*alog10(phot[ix].flux[3])
phot[ix].errmag[3]=2.5*alog10((phot[ix].flux[3]+phot[ix].errflux[3])/phot[ix].flux[3])

;;;;;;;;;;;;;;calculate the averaged RA, DEC, x, y and their errors;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

for i=0LL,n_elements(phot)-1LL do begin
detect=[phot[i].ch1.short.detect,phot[i].ch1.long.detect,phot[i].ch2.short.detect,phot[i].ch2.long.detect,$
        phot[i].ch3.short.detect,phot[i].ch3.long.detect,phot[i].ch4.short.detect,phot[i].ch4.long.detect]
    RA=[phot[i].ch1.short.RA,phot[i].ch1.long.RA,phot[i].ch2.short.RA,phot[i].ch2.long.RA,$
        phot[i].ch3.short.RA,phot[i].ch3.long.RA,phot[i].ch4.short.RA,phot[i].ch4.long.RA]
    DEC=[phot[i].ch1.short.DEC,phot[i].ch1.long.DEC,phot[i].ch2.short.DEC,phot[i].ch2.long.DEC,$
         phot[i].ch3.short.DEC,phot[i].ch3.long.DEC,phot[i].ch4.short.DEC,phot[i].ch4.long.DEC]
      x=[phot[i].ch1.short.x,phot[i].ch1.long.x,phot[i].ch2.short.x,phot[i].ch2.long.x,$
         phot[i].ch3.short.x,phot[i].ch3.long.x,phot[i].ch4.short.x,phot[i].ch4.long.x] 
      y=[phot[i].ch1.short.y,phot[i].ch1.long.y,phot[i].ch2.short.y,phot[i].ch2.long.y,$
         phot[i].ch3.short.y,phot[i].ch3.long.y,phot[i].ch4.short.y,phot[i].ch4.long.y]
	 
   ix=where(detect eq 1)
  if n_elements(ix) eq 1 then begin 
   phot[i].coords.RA=RA[ix]   
   phot[i].coords.DEC=DEC[ix]
   phot[i].coords.RAerr=0d0   
   phot[i].coords.DECerr=0d0 	  
 
   phot[i].coords.x=x[ix]   
   phot[i].coords.y=y[ix]
   phot[i].coords.xerr=0.0   
   phot[i].coords.yerr=0.0
   
   
   endif else begin
   phot[i].coords.RA=mean(RA[ix])   
   phot[i].coords.DEC=mean(DEC[ix])
   phot[i].coords.RAerr=stddev(RA[ix])   
   phot[i].coords.DECerr=stddev(DEC[ix]) 	  
 
   phot[i].coords.x=mean(x[ix])   
   phot[i].coords.y=mean(y[ix])
   phot[i].coords.xerr=stddev(x[ix])   
   phot[i].coords.yerr=stddev(y[ix]) 	  
   endelse 
   
endfor
outfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_phot.dat'
save,phot,filename=outfile
print,outfile+' wrote!!!'
endif


outfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_phot.dat'
restore,outfile
;;;;;;;;;;;;;;;calculate the quali_flag for each stars;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

uplimit=[1000,2000,2000,2000]
for i=0LL,n_elements(phot)-1LL do begin

for j=0,3 do begin

if phot[i].(j).short.detect eq 1 and  phot[i].(j).long.detect eq 1 then begin
if phot[i].(j).short.psfflux ge 100 and  phot[i].(j).short.psfflux le uplimit[j] then begin
ratio=phot[i].(j).short.psfflux/phot[i].(j).long.psfflux

if ratio ge 0.9 and ratio le 1.1 then begin 
  phot[i].qual_flag[j]='A' 
endif else begin
  if ratio ge 0.8 and ratio le 1.2 then phot[i].qual_flag[j]='B'
  if ratio lt 0.8 or ratio gt 1.2 then phot[i].qual_flag[j]='C'
endelse
endif
endif
endfor


endfor


outfile=work_directory+'joined_IRAC_mosaics/psf/'+field+'_phot.dat'
save,phot,filename=outfile
print,outfile+' wrote!!!'


end


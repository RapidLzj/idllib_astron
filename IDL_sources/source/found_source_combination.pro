
function combination_ssf_remove_multiple,res_x,res_y
  
  print,'number of stars found: ',n_elements(res_x)

  same_source_radius=1.0 ;; pixels

  GROUP_roy, res_X, res_Y, same_source_radius, NGROUP

  numberofgroups=max(ngroup)
  one={x:0.,y:0.,n:0}
  
  new=replicate(one,numberofgroups)
  i=0l
  while (i lt (n_elements(new)-1)) do begin
    ix=where(ngroup eq i)
    if (ix[0] eq -1) then new[i].n=0 else $
    if (n_elements(ix) eq 1) then begin ;; only one star in this group
      new[i].x=res_x[ix] & new[i].y=res_y[ix] 
      new[i].n=n_elements(ix)
    endif else begin ;; multiple stars in this group
      new[i].x=mean(res_x[ix]) & new[i].y=mean(res_y[ix]) 
      new[i].n=n_elements(ix)
    endelse
    i=i+1
  endwhile

;help,new
  ix=where(new.n ge 1) 
  if ix[0] ne -1 then   new=new[ix]
;help,new

  return,new
end



function two_data_combination,newdata,olddata
  
 nx=max([max(newdata.x),max(newdata.x)])+5
 ny=max([max(newdata.y),max(olddata.y)])+5

 boxsize=64
 overlap=10
 buffer=2
 subim=ssf_get_subims(nx,ny,boxsize,overlap) 
 
 xcoor=-1
 ycoor=-1
 
 for i=0LL,n_elements(subim)-1LL do begin
 
 ix1=where(newdata.x ge subim[i].x1 and newdata.x lt subim[i].x2 and newdata.y ge subim[i].y1 and newdata.y lt subim[i].y2)
 ix2=where(olddata.x ge subim[i].x1 and olddata.x lt subim[i].x2 and olddata.y ge subim[i].y1 and olddata.y lt subim[i].y2)

if ix1[0] ne -1 and ix2[0] ne -1 then begin
xnew=newdata[ix1].x
ynew=newdata[ix1].y

xold=olddata[ix2].x
yold=olddata[ix2].y

for num=0L,n_elements(ix1)-1L do begin
R=sqrt((xnew[num]-xold)^2.0+(ynew[num]-yold)^2.0)
ix=sort(R)

if R[ix[0]] ge 2.0 then begin
xcoor=[xnew[num],xcoor]
ycoor=[ynew[num],ycoor]
endif
endfor
endif
endfor

star_num=n_elements(xcoor)-2

newsources=combination_ssf_remove_multiple(xcoor[0:star_num],ycoor[0:star_num])

sources=[olddata,newsources]
return,sources
 
end



pro found_source_combination,work_directory,field,found=found,combination=combination



;;;;;;;;;;;;finding sources in IRAC images;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
band=['3.6','4.5','5.8','8.0']

shortlong=['long','short']



for i=0,n_elements(band)-1 do begin
boxsize=64
overlap=10
buffer=2

ssf_smart_source_finder_psf,work_directory=work_directory,$
          field=field,band=band[i],shortlong='long',boxsize=boxsize,overlap=overlap,$
          buffer=buffer 

for j=0,n_elements(shortlong)-1 do begin
  boxsize=64
overlap=10
buffer=2
if keyword_set(found) then $
  ssf_smart_source_finder,work_directory=work_directory,$
          field=field,band=band[i],shortlong=shortlong[j],boxsize=boxsize,overlap=overlap,$
          buffer=buffer

endfor
endfor


;;;;;;;;;;;;finding sources in mpis images;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;

                   
;;combining the sources on IRAC images at bands 3.6 and 4.5 with two exposure times;;;;;;;;;;;;;;;;;;;;;;;;;;

;band=['3.6','4.5']
;shortlong=['long','short']


;for j=0,n_elements(shortlong)-1 do begin
;boxsize=64
;overlap=10
;buffer=2

;if keyword_set(combination) then $
; two_channal_combination,work_directory,field,band,shortlong[j]
      
;endfor


;;combining the sources on IRAC images at band 4.5 and 5.8 with two exposure times;;;;;;;;;;;;;;;;;;;;;;;;

;band=['4.5','5.8']
;shortlong=['long','short']



;for j=0,n_elements(shortlong)-1 do begin

;boxsize=64
;overlap=10
;buffer=2

;if keyword_set(combination) then $
; two_channal_combination,work_directory,field,band,shortlong[j]
      
;endfor



;;;;;;;;combining the sources on IRAC images at band 5.8 and 8.0 with two exposure times;;;;;;;;;;;;;;;;;;;;;;;;;;

;band=['5.8','8.0']
;shortlong=['long','short']


;for j=0,n_elements(shortlong)-1 do begin
;boxsize=64
;overlap=10
;buffer=2

;if keyword_set(combination) then $
;two_channal_combination,work_directory,field,band,shortlong[j]
;endfor

end



;pro two_channal_combination,work_directory,field,band,shortlong,boxsize=boxsize,overlap=overlap,$
;      buffer=buffer

pro two_channal_combination,work_directory,field,band,shortlong      
 
 
  match_radius=1.0
  
  outfile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[0]+'_sources'
  outfile=outfile+'_bs*'+'ov*'+'_'+shortlong+'.dat'
  infile=file_search(outfile)
  if n_elements(infile) gt 1 then begin
      print,'Cannot determine which found_sources can be used!!'
      return
  endif
  restore,infile
  
  channel_one_sources=sources
 
  
  outfile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[1]+'_sources'
  outfile=outfile+'_bs*'+'ov*'+'_'+shortlong+'.dat'
  infile=file_search(outfile)
  if n_elements(infile) gt 1 then begin
   print,'Cannot determine which found_sources can be used!!'
   return
  endif
  restore,infile

  channel_two_sources=sources   

 nx=max([max(channel_one_sources.x),max(channel_two_sources.x)])+5
 ny=max([max(channel_one_sources.y),max(channel_two_sources.y)])+5

 
 boxsize=64
 overlap=10
 buffer=2
 overlap1=overlap   
 subim=ssf_get_subims(nx,ny,boxsize,overlap1) 

  outfile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[0]+'_sources'
  outfile=outfile+'_bs'+strtrim(string(boxsize-2*buffer),2)
  outfile=outfile+'ov'+strtrim(string(overlap),2)+'.fits'
 
 
 ssf_write_subims_regfile,subim,outfile


 
 xcoor=-1
 ycoor=-1
 
 for i=0LL,n_elements(subim)-1LL do begin
 
 ix1=where(channel_one_sources.x ge subim[i].x1 and channel_one_sources.x lt subim[i].x2 and channel_one_sources.y ge subim[i].y1 and channel_one_sources.y lt subim[i].y2)
 ix2=where(channel_two_sources.x ge subim[i].x1 and channel_two_sources.x lt subim[i].x2 and channel_two_sources.y ge subim[i].y1 and channel_two_sources.y lt subim[i].y2)

if ix1[0] ne -1 and ix2[0] ne -1 then begin
x_one_channel=channel_one_sources[ix1].x
y_one_channel=channel_one_sources[ix1].y

x_two_channel=channel_two_sources[ix2].x
y_two_channel=channel_two_sources[ix2].y

for num=0L,n_elements(ix1)-1L do begin
R=sqrt((x_one_channel[num]-x_two_channel)^2.0+(y_one_channel[num]-y_two_channel)^2.0)
ix=sort(R)

if R[ix[0]] le match_radius then begin
xcoor=[(x_one_channel[num]+x_two_channel[ix[0]])/2.0,xcoor]
ycoor=[(y_one_channel[num]+y_two_channel[ix[0]])/2.0,ycoor]
endif
endfor
endif
endfor

star_num=n_elements(xcoor)-2
sources=combination_ssf_remove_multiple(xcoor[0:star_num],ycoor[0:star_num])
newdata=sources

infile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[0]+'_'+band[1]+'_combination_'+shortlong+'_sources'
overlap=overlap+2*buffer 
ssf_write_region_file,sources,infile,regname=regname,boxsize=boxsize,overlap=overlap,buffer=buffer



if band[0] eq '3.6' and band[1] eq '4.5' then begin
infile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[0]+'_combination_'+shortlong+'_sources'
infile=infile+'.dat'
save,sources,filename=infile
print,infile+' wroted!!!'

infile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[1]+'_combination_'+shortlong+'_sources'
infile=infile+'.dat'
save,sources,filename=infile
print,infile+' wroted!!!'

endif else begin

    if band[1] ne '8.0' then begin
       infile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[1]+'_combination_'+shortlong+'_sources'
       infile=infile+'.dat'
       save,sources,filename=infile
       print,infile+' wroted!!!' 
    endif else begin
         ;;;;;;;;;;;For 8.0 micron, we also include all the stars found in 8.0 micron images;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         outfile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[1]+'_sources'
         outfile=outfile+'_bs*'+'ov*'+'_'+shortlong+'.dat'
         infile=file_search(outfile)
         restore,infile
	 
         outfile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[1]+'_combination_'+shortlong+'_sources'
         outfile=outfile+'.dat'
	 save,sources,filename=outfile
         print,outfile+' wroted!!!  
    endelse

  
  infile=work_directory+'joined_IRAC_mosaics/found_sources/'+field+'_'+band[0]+'_combination_'+shortlong+'_sources'
  infile=infile+'.dat'
  restore,infile
  olddata=sources


  sources=two_data_combination(newdata,olddata)

  save,sources,filename=infile
  print,infile+' wroted!!!' 
  endelse


end




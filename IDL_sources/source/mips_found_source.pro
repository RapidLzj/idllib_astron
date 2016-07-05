function initial_values,num,datatype

if datatype eq 'INT' then return,'intarr('+strtrim(string(num),2)+')'
if datatype eq 'STRING' then return, 'strarr('+strtrim(string(num),2)+')'
if datatype eq 'FLOAT' then return, 'fltarr('+strtrim(string(num),2)+')'
if datatype eq 'DOUBLE' then return, 'dblarr('+strtrim(string(num),2)+')'
if datatype eq 'LONG' then return, 'lonarr('+strtrim(string(num),2)+')'
if datatype eq 'BYTE' then return, 'bytarr('+strtrim(string(num),2)+')'
end


function create_mips_struct,phot_num,sources
tags=tag_names(sources)
values=strarr(n_elements(tags))

coords={RA:0d0,DEC:0d0,RA_err:0d0,DEC_err:0d0,x:0.,y:0.,x_err:0.,y_err:0.}
tempstr={Ndetect:0,m_psf_flux:0.,m_psf_flux_err:0.,coords:coords,detect:intarr(phot_num)}
for i=0,n_elements(tags)-1 do begin
siz=size(sources.(i),/structure)
tsiz=siz.type_name
values[i]=initial_values(phot_num,tsiz)
endfor


newstruct=struct_addtags(tempstr,tags,values)
newstruct=replicate(newstruct,n_elements(sources))
newstruct.detect[0]=1

for i=0LL,n_elements(sources)-1LL do begin
for j=0,n_elements(tags)-1 do begin
newstruct[i].(j+5)[0]=sources[i].(j)
endfor
endfor

for i=0LL,n_elements(newstruct)-1LL do begin
ix=where(newstruct[i].detect ne 0)
newstruct[i].coords.x=mean(newstruct[i].x[ix])
newstruct[i].coords.y=mean(newstruct[i].y[ix])
endfor

return,newstruct
end

function add_mips_struct,instruct,sources,column
 
 match_radius=1.5
 oldstruct=instruct
 
 newflag=intarr(n_elements(sources)) 
 for j=0LL,n_elements(sources)-1LL do begin
 R=sqrt((sources[j].x-oldstruct.coords.x)^2d0+(sources[j].y-oldstruct.coords.y)^2d0) 
 ix=sort(R)
 
 if R[ix[0]] le match_radius then begin
 oldstruct[ix[0]].detect[column]=1
 oldstruct[ix[0]].x[column]=sources[j].x
 oldstruct[ix[0]].y[column]=sources[j].y
 oldstruct[ix[0]].n[column]=sources[j].n
 oldstruct[ix[0]].PSF_FLUX[column]=sources[j].PSF_FLUX
 oldstruct[ix[0]].PSF_X_SIGMA[column]=sources[j].PSF_X_SIGMA
 oldstruct[ix[0]].PSF_Y_SIGMA[column]=sources[j].PSF_Y_SIGMA
 oldstruct[ix[0]].PSF_FLUX_SIGMA[column]=sources[j].PSF_FLUX_SIGMA
 oldstruct[ix[0]].PSF_CORRELATION[column]=sources[j].PSF_CORRELATION
 oldstruct[ix[0]].APER_FLUX[column]=sources[j].APER_FLUX
 oldstruct[ix[0]].APER_ERRFLUX[column]=sources[j].APER_ERRFLUX
 oldstruct[ix[0]].NEAREST_EDGE[column]=sources[j].NEAREST_EDGE
 endif else begin
 newflag[j]=1
 endelse
 endfor

 tempstruct=oldstruct[0]
 zero_struct,tempstruct
 ix=where(newflag eq 1)
 tempstruct=replicate(tempstruct,n_elements(ix))
 
 for j=0L,n_elements(ix)-1L do begin
 tempstruct[j].detect[column]=1
 tempstruct[j].x[column]=sources[ix[j]].x
 tempstruct[j].y[column]=sources[ix[j]].y
 tempstruct[j].n[column]=sources[ix[j]].n
 tempstruct[j].PSF_FLUX[column]=sources[ix[j]].PSF_FLUX
 tempstruct[j].PSF_X_SIGMA[column]=sources[ix[j]].PSF_X_SIGMA
 tempstruct[j].PSF_Y_SIGMA[column]=sources[ix[j]].PSF_Y_SIGMA
 tempstruct[j].PSF_FLUX_SIGMA[column]=sources[ix[j]].PSF_FLUX_SIGMA
 tempstruct[j].PSF_CORRELATION[column]=sources[ix[j]].PSF_CORRELATION
 tempstruct[j].APER_FLUX[column]=sources[ix[j]].APER_FLUX
 tempstruct[j].APER_ERRFLUX[column]=sources[ix[j]].APER_ERRFLUX
 tempstruct[j].NEAREST_EDGE[column]=sources[ix[j]].NEAREST_EDGE
 endfor
newstruct=[oldstruct,tempstruct]
return,newstruct
end








pro mips_found_source,work_directory,field,found=found,combination=combination,psffitting=psffitting	



;;;;;;;;;;;;finding sources in mips images;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

band='24'

infile=work_directory+'/joined_MIPS_mosaics/'+field+'_*'+'.fits'

files=file_search(infile)
fits_file=files
for j=0,n_elements(files)-1 do begin
boxsize=64
overlap=10
buffer=2
;print,files[j]

if keyword_set(found) then $
  ssf_smart_source_finder,work_directory=work_directory,$
          field=field,band=band,boxsize=boxsize,overlap=overlap,$
          buffer=buffer,infile=files[j]
psf_fitting_size=23
if keyword_set(psffitting) then $
  smart_psf_phot,work_directory=work_directory,$
      field=field,band=band,psf_fitting_size=psf_fitting_size,infile=files[j],ini_psf_fwhm=2.8,/newpsf,/newsigma


endfor

;field=['L1641']
irac_fits=work_directory+'/joined_IRAC_mosaics/'+field+'_3.6_3sigma_median_long.fits'
hdr=headfits(irac_fits)
if keyword_set(combination) then begin
datafile=work_directory+'/joined_MIPS_mosaics/psf/'+field+'*_ps'+strtrim(string(psf_fitting_size),2)+'_psf_fitting_sources.dat'
files=file_search(datafile)

phot_num=n_elements(files)


for i=0,n_elements(files)-1 do begin
restore,files[i]
mips_data=psf_fitting_sources
x0=mips_data.x
y0=mips_data.y


mips_fits=fits_file[i]
hdr1=headfits(mips_fits)
xyad,hdr1,x0,y0,RA,DEC
adxy,hdr,RA,DEC,x,y

mips_data.x=x &mips_data.y=y

if i eq 0 then begin
   newstruct=create_mips_struct(phot_num,mips_data) 
 endif  else begin
  newstruct=add_mips_struct(newstruct,mips_data,i)
endelse

endfor

for i=0LL,n_elements(newstruct)-1LL do begin
ix=where(newstruct[i].detect eq 1) 
newstruct[i].ndetect=n_elements(ix)

newstruct[i].coords.x=mean(newstruct[i].x[ix])
newstruct[i].coords.y=mean(newstruct[i].y[ix])
newstruct[i].M_PSF_FLUX=mean(newstruct[i].psf_flux[ix])

xx=newstruct[i].x[ix]
yy=newstruct[i].y[ix]
xyad,hdr,xx,yy,RA,DEC
newstruct[i].coords.RA=mean(RA)
newstruct[i].coords.RA=mean(DEC)

if n_elements(ix) ge 2 then begin
newstruct[i].coords.x_err=stddev(newstruct[i].x[ix])
newstruct[i].coords.y_err=stddev(newstruct[i].y[ix])
newstruct[i].coords.RA=stddev(RA)
newstruct[i].coords.RA=stddev(DEC)
newstruct[i].M_PSF_FLUX_err=stddev(newstruct[i].psf_flux[ix])
endif else begin
newstruct[i].coords.x_err=0.
newstruct[i].coords.y_err=0.
newstruct[i].coords.RA_err=0d0
newstruct[i].coords.RA_err=0d0
newstruct[i].M_PSF_FLUX_err=0.
endelse

endfor


phot_twomass_sdss_mips=combination_mips_phot(field,newstruct)

save,phot_twomass_sdss_mips,filename=field+'_phot_twomass_sdss_mips.dat'
endif

end

function combination_mips_phot,field,mips_struct

match_radius=1.5

zero_mips_struct=mips_struct[0]
zero_struct,zero_mips_struct




photfile=field+'_phot_twomass_sdss.dat'
restore,photfile

temp_mips_struct={mips_24m:zero_mips_struct}
temp_mips_struct=replicate(temp_mips_struct,n_elements(phot_twomass_sdss))

nx=max(phot_twomass_sdss.coords.x)
ny=max(phot_twomass_sdss.coords.y)
boxsize=120
overlap=20

subim=merger_get_subim(nx,ny,boxsize,overlap)

for i=0LL,n_elements(subim)-1LL do begin
ix1=where(phot_twomass_sdss.coords.x ge subim[i].x1 and phot_twomass_sdss.coords.x lt subim[i].x2 and $ 
          phot_twomass_sdss.coords.y ge subim[i].y1 and phot_twomass_sdss.coords.y lt subim[i].y2 )
ix2=where(mips_struct.coords.x ge subim[i].x1 and mips_struct.coords.x le subim[i].x2 and mips_struct.coords.y ge subim[i].y1 $
          and mips_struct.coords.y le subim[i].y2)
 
if  ix1[0] ne -1 and ix2[0] ne -1 then begin

for num=0L,n_elements(ix1)-1L do begin
R=sqrt((phot_twomass_sdss[ix1[num]].coords.x-mips_struct[ix2].coords.x)^2.0+(phot_twomass_sdss[ix1[num]].coords.y-mips_struct[ix2].coords.y)^2.0 )
ix3=sort(R)
if R[ix3[0]] le match_radius then temp_mips_struct[ix1[num]].mips_24m=mips_struct[ix2[ix3[0]]]
endfor

endif 
 
endfor

phot_twomass_sdss_mips=struct_combine(phot_twomass_sdss,temp_mips_struct)
return,phot_twomass_sdss_mips
end


pro merger_2mass_sdss_to_spitzer,work_directory,field,$
                sdss=file_sdss,twomass=file_twomass

file_phot=work_directory+'joined_IRAC_mosaics/'+'psf/'+field+'_phot.dat'
restore,file_phot


if keyword_set(file_sdss) then restore,file_sdss
if keyword_set(file_twomass) then restore,file_twomass


min_RA=min(phot.coords.RA)*3600d0
min_DEC=min(phot.coords.DEC)*3600d0
nx=max(phot.coords.RA)*3600d0-min_RA
ny=max(phot.coords.DEC)*3600d0-min_DEC

spitzer_RA=phot.coords.RA*3600d0
spitzer_DEC=phot.coords.DEC*3600d0


print,nx,ny



boxsize=120d0
overlap=20d0

subim=merger_get_subim(nx,ny,boxsize,overlap)
subim.x1=double(subim.x1)+min_RA
subim.x2=double(subim.x2)+min_RA

subim.y1=double(subim.y1)+min_DEC
subim.y2=double(subim.y2)+min_DEC


if keyword_set(file_twomass) then begin
zero_twomass=TWOMASS[0]
zero_struct,zero_twomass
zero_twomass=struct_addtags(zero_twomass,'detect','0')
;twomass_str=replicate(zero_twomass,n_elements(phot))

twomass_RA=twomass.RA*3600d0
twomass_DEC=twomass.DEC*3600d0



match_radius=2.
twomass_add_into_phot={twomass:zero_twomass}
twomass_add_into_phot=replicate(twomass_add_into_phot,n_elements(phot))

for i=0LL,n_elements(subim)-1LL do begin
ix1=where(spitzer_RA ge subim[i].x1 and  spitzer_RA le subim[i].x2 and $
         spitzer_DEC ge subim[i].y1 and spitzer_DEC le subim[i].y2 )
ix2=where(twomass_RA ge subim[i].x1 and  twomass_RA le subim[i].x2 and $
          twomass_DEC ge subim[i].y1 and twomass_DEC le subim[i].y2 )	


if ix1[0] ne -1 then begin
if ix2[0] ne -1 then begin

for j=0L,n_elements(ix1)-1L do begin
R=sqrt(((spitzer_RA[ix1[j]]-twomass_RA[ix2])*cos(spitzer_DEC[ix1[j]]*!PI/3600d0/180d0))^2d0+(spitzer_DEC[ix1[j]]-twomass_DEC[ix2])^2d0)
ix3=sort(R)
if R[ix3[0]] le match_radius then begin
new_twomass=struct_addtags(twomass[ix2[ix3[0]]],'detect','1')
;twomass_str[ix1[j]]=new_twomass
twomass_add_into_phot[ix1[j]].twomass=new_twomass
endif else begin
;twomass_str[ix1[j]]=zero_twomass
twomass_add_into_phot[ix1[j]].twomass=zero_twomass
endelse
endfor

endif else begin
for j=0L,n_elements(ix1)-1L do begin
;twomass_str[ix1[j]]=zero_twomass
twomass_add_into_phot[ix1[j]].twomass=zero_twomass
endfor
endelse

endif
endfor

;new_twomass={twomass:zero_twomass}
;for i=0LL,n_elements(phot)-1LL do begin
;one={twomass:twomass_str[i]}
;new_twomass=[new_twomass,one]
;print,i
;endfor


phot_twomass=struct_combine(phot,twomass_add_into_phot)
save,phot_twomass,filename=field+'_phot_twomass.dat'

endif


if keyword_set(file_sdss) then begin
zero_SDSS=LSDSS[0]
zero_struct,zero_SDSS
zero_SDSS=struct_addtags(zero_SDSS,'detect','0')

sdss_RA=LSDSS.RA*3600d0
sdss_DEC=LSDSS.DEC*3600d0



match_radius=2.
sdss_add_into_phot={sdss:zero_sdss}
sdss_add_into_phot=replicate(sdss_add_into_phot,n_elements(phot))

for i=0LL,n_elements(subim)-1LL do begin
ix1=where(spitzer_RA ge subim[i].x1 and  spitzer_RA le subim[i].x2 and $
         spitzer_DEC ge subim[i].y1 and spitzer_DEC le subim[i].y2 )
ix2=where(sdss_RA ge subim[i].x1 and  sdss_RA le subim[i].x2 and $
          sdss_DEC ge subim[i].y1 and sdss_DEC le subim[i].y2 )	


if ix1[0] ne -1 then begin
if ix2[0] ne -1 then begin

for j=0L,n_elements(ix1)-1L do begin
R=sqrt(((spitzer_RA[ix1[j]]-sdss_RA[ix2])*cos(spitzer_DEC[ix1[j]]*!PI/3600d0/180d0))^2d0+(spitzer_DEC[ix1[j]]-sdss_DEC[ix2])^2d0)
ix3=sort(R)
if R[ix3[0]] le match_radius then begin
new_sdss=struct_addtags(LSDSS[ix2[ix3[0]]],'detect','1')

sdss_add_into_phot[ix1[j]].sdss=new_sdss
endif else begin

sdss_add_into_phot[ix1[j]].sdss=zero_sdss
endelse
endfor

endif else begin
for j=0L,n_elements(ix1)-1L do begin

sdss_add_into_phot[ix1[j]].sdss=zero_sdss
endfor
endelse

endif
endfor



phot_twomass_sdss=struct_combine(phot_twomass,sdss_add_into_phot)
save,phot_twomass_sdss,filename=field+'_phot_twomass_sdss.dat'

endif



end


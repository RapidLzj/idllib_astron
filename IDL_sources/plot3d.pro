;+
;NAME:
;  PLOT3D
;PROCEDURE: plot3d, dat , latitude, longitude
;PURPOSE:  
;  Draws a series of 3d color plots, one plot per energy step.
;INPUT:
;  dat:  3d data structure.
;  latitude:  latitude of center of plot
;  longitude:  longitude of center of plot
;KEYWORDS:
;   EBINS:     Specifies energy bins to plot.
;   SUM_EBINS: Specifies how many bins to sum, starting with EBINS.  If
;              SUM_EBINS is a scaler, that number of bins is summed for
;              each bin in EBINS.  If SUM_EBINS is an array, then each
;              array element will hold the number of bins to sum starting
;              at each bin in EBINS.  In the array case, EBINS and SUM_EBINS
;              must have the same number of elements.
;   BNCENTER:  if > 0 then lat,lon set so that B direction is in center
;              if < 0 then lat,lon set so that -B direction is in center
;              ('magf' element must exist in dat structure. See "ADD_MAGF")
;   BINS:    bins to use for autoscaling.
;   SMOOTH:  smoothing parameter.  0=none,  2 is typical
;SEE ALSO:  "PLOT3D_OPTIONS" to see how to set other options.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)plot3d.pro	1.28 97/01/02
;-
pro plot3d,tbindata, latitude,longitude, $
   BINS=bins, $  
   TBINS=tbins,  $    
   BNCENTER=bncenter,  $
   LABELS=labs, $
   SMOOTH= smoth,     $
   EBINS=eb,        $
   SUM_EBINS=seb,        $
   PTLIMIT=plot_limits, $
   MAP= ptmap,      $  
   UNITS = units,   $
   STACK = stack,   $
   PROC3D = proc3d
   SAVE = save
@plot3d_com.pro
plot3d_options          ; Set Defaults

if(tbindata.valid eq 0) then begin
  print,'Invalid data'
  return
endif

if not keyword_set(units) then units='Eflux'
bindata = conv_units(tbindata,units)

str_element,bindata,'magf',value=magf

if keyword_set(magf) then begin
   xyz_to_polar,magf,theta=th,phi=phi
   bdir = [th,phi]
endif

str_element,bindata,'vsw',value=vsw


if n_elements(latitude)  eq 0 then latitude = latitude_3d
if n_elements(longitude) eq 0 then longitude = longitude_3d
if n_elements(smoth)     eq 0 then smoth = smooth_3d

if keyword_set(bncenter) and n_elements(bdir) eq 2 then begin
   latitude = bdir(0)
   longitude = bdir(1)
   if bncenter lt 0 then begin
      latitude = - latitude
      longitude = longitude + 180
   endif
endif

n_e = bindata.nenergy
nbins = bindata.nbins
if n_elements(bins) ne nbins then bins = replicate(1,bindata.nbins)
goodbins = where(bins,ngood)
badbins = where(bins eq 0,nbad)
if nbad ne 0 then bindata.data(*,badbins) = !values.f_nan

if keyword_set(triang_3d) then triang = 1

str_element,bindata,'map',value=ptmap
if keyword_set(ptmap) then begin
   np = dimen1(ptmap)
   ptmap = rotate(ptmap,7)  ; this line and the next should be removed when
   ptmap = rotate(ptmap,5)  ; the c-code is fixed
   ptmap = reverse(ptmap,2) ; assumes !order = 0
   message,'Using supplied mapping',/cont,/info
endif else begin
   ptmap = make_3dmap(bindata,64,32,bins=tbins) 
   ptmap = shift(ptmap,32,0)  ; map routine expects phi: -180 to 180
endelse



; handle ebins
if n_elements(eb) eq 0 then                $  ; undefined ebins
    start=indgen(n_e)                      $
else                                       $  ; scaler or 1-D ebins
    start=eb

; handle sum_ebins
if keyword_set(seb) eq 0 then              $  ; SUM_EBINS keyword not set
    seb=1                                  $
else begin
    if n_elements(seb) gt 1 and (n_elements(seb) ne n_elements(eb)) then begin
        message,'if SUM_EBINS is an array, it must have same dimensions'+ $
        ' as EBINS.'
    endif 
endelse

; get stop bins
    stop = start + seb - 1

n_p = dimen1(start)  ; number of plots

stacking= [ [1,1],   [1,1],   [1,2],   [2,2],   [2,2],   [2,3],   [2,3],  $
   [3,3],   [3,3],   [3,3],   [3,4],   [3,4],   [3,4],   [3,5],   [3,5],  $
   [3,5],   [4,4],   [4,5],   [4,5],   [4,5],   [4,5],   [5,5],   [5,5],  $
   [5,5],   [5,5],   [5,5],   [5,6],   [5,6],   [5,6],   [5,6],   [5,6],  $
   [6,6],   [6,6],   [6,6],   [6,6],   [6,6],   [6,6],   [6,7],   [6,7],  $
   [6,7],   [6,7],   [6,7],   [6,7],   [7,7],   [7,7],   [7,7],   [7,7],  $
   [7,7],   [7,7],   [7,7],   [7,8],   [7,8],   [7,8],   [7,8],   [7,8],  $
   [7,8],   [7,8],   [8,8],   [8,8],   [8,8],   [8,8],   [8,8],   [8,8],  $
   [8,8],   [8,8]]

if n_elements(stack) ne 2 then stack=stacking(*,n_p)

!p.multi=[0,stack(0),stack(1)]

charsize = !p.charsize 
!y.omargin = [1,4]
!x.omargin = [0,6]
if !p.multi(1) gt 2 or !p.multi(2) gt 2 then begin
;   charsize = !p.charsize *2
   !y.omargin = !y.omargin * 2
   !x.omargin = !x.omargin * 2
endif

xposmax = 0.
yposmax = 0.
yposmin = 1.



for plot_num=0,n_p-1 do begin
   e1 = start(plot_num)
   en1 = total(bindata.energy(e1,*))/n_elements(bindata.energy(e1,*))

   e2 = stop(plot_num)
   en2 = total(bindata.energy(e2,*))/n_elements(bindata.energy(e2,*))

   if e1 ne e2 then begin
     ttl = string(en1)+' - '+string(en2)+' eV'
   endif else begin
     ttl = strcompress(string(en1,format='(F12.1)')+' eV', $
           /remove_all)
   endelse
   ttl=strcompress(ttl)
   
nsteps = e2-e1+1

if keyword_set(triang) then begin
   data = total(bindata.data(e1:e2,*),1)  ; sum over energies
   range = minmax_range(data(goodbins),/pos)
   theta = total(bindata.theta(e1:e2,*),1)/nsteps
   phi = total(bindata.phi(e1:e2,*),1)/nsteps

   if keyword_set(tbins) then  ind = where(tbins ne 0)  $
   else ind = where(finite(theta) and finite(phi))

if ind(0) eq -1 then goto, contu
   data  = data(ind)
   theta = theta(ind)
   phi   = phi(ind)
;stop
   triangulate,phi,theta,fvalue=data,sphere=sphere,/degrees
;help,sphere,/st,x
;stop
   image = trigrid(data,sphere=sphere,[2.,2.],[-180.,-90.,178.,90.],/deg)
   image = bytescale(image,log=logscale_3d,/zero, range=range)

endif else begin
   data = total(bindata.data(e1:e2,*),1)  ; sum over energies
   range = minmax_range(data(goodbins))
   data = [!values.f_nan,data]
;   data = [0.,data]
   data = data(ptmap+1)                     ; make 2-dimensional
   if( keyword_set(smoth)) then begin
      dim = dimen(data) * 1*smoth   ; increase the dimensions
      data = rebin(data,dim(0),dim(1))
      data = smooth_periodic(data,smoth)
   endif

   image = bytescale(data,log=logscale_3d,/zero, range=range)

   image = congrid(image,360,180)  ; assumes  !order eq 0
endelse

   mapname = strlowcase(strmid(mapname_3d,0,3))
   map_set, latitude,longitude,0., /advance, /WHOLE_MAP, $
     MOLL  = mapname eq 'mol' ,     $
     CYLIN = mapname eq 'cyl' ,     $
     ORTHO = mapname eq 'ort' ,     $
     AITOFF= mapname eq 'ait' ,     $
     LAMBERT=mapname eq 'lam' ,     $
     GNOMIC =mapname eq 'gno' ,     $
     MERCATO=mapname eq 'mer' ,     $
     LIMIT=plot_limits        , $
     TITLE=ttl, $
     charsize = charsize, $
     XMARGIN=[1,1], YMARGIN=[1,1]

   new = map_image(image,sx,sy,xsize,ysize, $
      COMPRESS=compress_3d, BILIN=0)

;   new = map_patch(image,xstart=sx,ystart=sy,xsize=xsize,ysize=ysize)

   tv,new,sx,sy,xsize=xsize,ysize=ysize,order=0

   if n_elements(bdir) eq 2 then begin     ; draw mag field
      plots,bdir(1),bdir(0),psym=1
      plots,bdir(1)+180,-bdir(0),psym=4
   endif
   if n_elements(vsw) then begin
      xyz_to_polar,vsw,theta=th,phi=ph
      plots,ph,th,psym=2
   endif else  plots,179.99,0.,psym=2   ; draw the sun.


   if keyword_set(grid_3d) then map_grid,londel=grid_3d(0),latdel=grid_3d(1)

   str_element,opts,'plot3d_proc',value=proc3d
   str_element,bindata,'plot3d_proc',value=proc3d
   if keyword_set(proc3d) then begin
       proc = ''
       if ndimen(proc3d) eq 0 then proc=proc3d else begin
           if plot_num lt n_elements(proc3d) then proc = proc3d(plot_num)
       endelse
       if keyword_set(proc) then call_procedure,proc,bindata,en2,plot_num
   endif

   if keyword_set(labs) then begin
      lab=strcompress(indgen(nbins),/rem)
      colorcode = [!p.background,!p.color]
      xyouts,phi,theta,lab,align=.5,COLOR=colorcode(bins)
   endif

   ;map_grid,/label,latdel =45,londel=45,CHARSIZE=charsize
   ;map_continents
   if xposmax lt !x.window(1) then xposmax=!x.window(1)
   if yposmax lt !y.window(1) then yposmax=!y.window(1)
   if yposmin gt !y.window(1) then yposmin=!y.window(0)
   contu:
endfor

ttl = bindata.project_name+'  '+bindata.data_name
ttl =ttl+'!C'+ trange_str(bindata.time,bindata.end_time)
tcharsize = 1.25 * charsize
titleheight = tcharsize * !d.y_ch_size/!d.y_size
xyouts, 0.5,1.-titleheight,ttl,/normal,alignment=.5,charsize=tcharsize

time_stamp

!p.multi = 0
!y.omargin=0
!x.omargin=0

space = charsize * !d.x_ch_size/!d.x_size
pos =[xposmax+space,yposmin,xposmax+3*space,yposmax]
draw_color_scale,range = [0.,1.],pos=pos,chars=charsize

return
end



;+
;FUNCTION make_3dmap, dat,nx,ny
;PURPOSE:
;  Returns a 3d map using the theta's and phi's of a 3d structure.
;  This routine is primarily used by "PLOT3D".
;INPUT:  dat:  a 3d structure (see "3D_STRUCTURE" for more info).
;         nx:  x dimension of output array.
;         ny:  y dimension of output array.
;OUTPUT: A 2 dimensional array of bin values that reflect the mapping.
;KEYWORDS: 
;   HIGHEST:  force the highest bin number to prevail for overlapping bins.
;   BINS:     bins selection. Same keyword as in "PLOT3D"
;ASSUMPTIONS: theta +/- dtheta should be in the range:  -90 to +90.
;NOTES: if there are any overlapping bins, then the lowest bin number
;    will win, unless the HIGHEST keyword is set.
;WRITTEN BY:  Davin Larson,   96-2-8
;LAST MODIFICATION:	@(#)make_3dmap.pro	1.1 96/02/13
;-

function make_3dmap, dat,nx,ny,  bins=bins, highest=highest

if n_elements(nx) eq 0 then nx = 64
if n_elements(ny) eq 0 then ny = 32


phi = total(dat.phi,1,/nan)/total(finite(dat.phi),1)
theta = total(dat.theta,1,/nan)/total(finite(dat.theta),1)
;dphi = total(dat.dphi,1,/nan)/total(finite(dat.dphi),1)
;dtheta = total(dat.dtheta,1,/nan)/total(finite(dat.dtheta),1)
dphi = dat.dphi
dtheta = dat.dtheta

map = replicate(-1,nx,ny)

if keyword_set(bins) then begin
  i = where(bins,count)
  if count eq 0 then return,map
  phi = phi(i)
  theta = theta(i)
  dphi = dphi(i)
  dtheta = dtheta(i)
endif

;help,phi,theta,dphi,dtheta  ; phi,theta,dphi and dtheta should have the

nbins = n_elements(phi)

p1 = round((phi-dphi/2.)*nx/360.)
p2 = round((phi+dphi/2.)*nx/360.)-1
t1 = round((theta-dtheta/2.+90.)*ny/180.)
t2 = round((theta+dtheta/2.+90.)*ny/180.)-1
for b1=0,nbins-1 do  begin
   if keyword_set(highest) then b=b1 else b=nbins-b1-1
   p = indgen(p2(b)-p1(b)+1) + p1(b)
   p = (p+nx) mod nx             ; array of p indices
   map(p,t1(b):t2(b)) = b
endfor
return,map
end

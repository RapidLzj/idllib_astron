pro fit_test
psf_size=11
image=readfits('L1641_3.6_3sigma_median_long.fits',hdr)
psf_model=readfits('psf.fits')
data=read_ascii('psf_3.6.txt')
x0=reform(data.field1[0,*])
y0=reform(data.field1[1,*])


restore,'L1641_3.6_sources_bs28ov8_long.dat'

x0=sources.x
y0=sources.y
f0=sources.flux
ix=reverse(sort(f0))

x0=x0[ix]
y0=y0[ix]
f0=f0[ix]
x0=x0[200:500]
y0=y0[200:500]

for i=0L,n_elements(x0)-1L do begin

max=0.0
coor=[0,0]
for j1=round(x0[i]-psf_size/2),round(x0[i]+psf_size/2) do begin
for j2=round(y0[i]-psf_size/2),round(y0[i]+psf_size/2) do begin

if image[j1,j2] gt max then begin
max=image[j1,j2]
coor=[j1,j2]
endif


endfor
endfor

j1=coor[0]
j2=coor[1]
cut=image((j1-psf_size/2):(j1+psf_size/2),(j2-psf_size/2):(j2+psf_size/2))


plot,cut,psf_model,psym=4

a=''
read,a
endfor


end


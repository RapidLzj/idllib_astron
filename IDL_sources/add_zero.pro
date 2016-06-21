pro add_zero
zero=[17.3,16.82,16.33,15.69]
;pix=[1.221,1.213,1.222,1.220]*!PI/3600d0/180d0
pix=[0.000333333,0.000333333,0.000333333,0.000333333,0.000680556]*!PI/180d0
area=pix^2d0
zero_flux=[280.9,179.7,115.0,64.13,7.14]
zero_mag=2.5*alog10(zero_flux*1d-6/area)
print,zero_mag
restore,'L1641_allphot.dat'
p=L1641_allphot
ix=where(p.twomass.detect eq 1)
p=p[ix]

J=p.twomass.J[0]
H=p.twomass.H[0]
K=p.twomass.K[0]
sp1=zero_mag[0]-2.5*alog10(p.flux[0])
sp2=zero_mag[1]-2.5*alog10(p.flux[1])
sp3=zero_mag[2]-2.5*alog10(p.flux[2])
sp4=zero_mag[3]-2.5*alog10(p.flux[3])
mp1=zero_mag[4]-2.5*alog10(p.MIPS_24M.M_psf_flux)

stop
plot,K-mp1,J-H,psym=3

end

pro ct,l,ro,out
	N=2*l+1
	ctheta=dblarr(N,N)
	ccos=dblarr(N,N)
	csin=dblarr(N,N)
	out=dblarr(N,N)
	x=(findgen(101)/50.-1.)*ro
	phi=x*asin(ro)
;
		

	for i=0,N-1 do begin
		m=i-l

			y1=(-1)^abs(m)*legendre(l,abs(m),x)
		
		for j=0,N-1 do begin
			mp=j-l
			
				y2=(-1)^abs(mp)*legendre(l,abs(mp),x)
		
; apodization is mu=sin(theta)*cos(phi)
;			ctheta(i,j)=int_tabulated(x,y1*y2*(1-x^2))
; no apodization
			ctheta(i,j)=int_tabulated(x,y1*y2*sqrt(1-x^2))
		endfor
	endfor
	
	for i=0,N-1 do begin
		m=i-l
		z1=cos(m*phi)
		for j=0,N-1 do begin
			mp=j-l
			z2=cos(mp*phi)
; apodization is mu=cos(theta)*sin(phi)
;			ccos(i,j)=4.*int_tabulated(phi,z1*z2*cos(phi)^2)/3.141592654
; no apodization
			ccos(i,j)=4.*int_tabulated(phi,z1*z2*cos(phi))/3.141592654
		endfor
	endfor
	for i=0,N-1 do begin
		m=i-l
		z1=sin(m*phi)
		for j=0,N-1 do begin
			mp=j-l
			z2=sin(mp*phi)
; apodization is mu=cos(theta)*sin(phi)
;			csin(i,j)=4.*int_tabulated(phi,z1*z2*cos(phi)^2)/3.141592654
; no apodization
			csin(i,j)=4.*int_tabulated(phi,z1*z2*cos(phi))/3.141592654
		endfor
	endfor
	for m=-l,l do begin
		i=m+l
		for mp=-l,l do begin
			j=mp+l

			
			out(i,j)=((ctheta(i,j)*(ccos(i,j)+csin(i,j)))/(ctheta(i,i)*(ccos(i,i)+csin(i,i))))*(1.-(abs(m+mp) mod 2))

	

;			print,'crosstalk between',m,'and',mp,'=',(ccos(i,j)+csin(i,j)),out(i,j),i,j
			;out(j,i)=out(i,j)
		endfor
;		print,''
	endfor

;	print,out
end

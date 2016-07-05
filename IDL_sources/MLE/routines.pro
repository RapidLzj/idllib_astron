;************************************************

Function spectra11,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:3)=param(0:3)
	
	
	

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
	l=(N-1)/2
	paramline(0)=param(0)
	paramline(5)=peak(0)
	paramline(1)=param(1)-param(3)
	y=y+lorentzian(paramline,x)
	paramline(0)=param(5)
	paramline(5)=peak(2)
	paramline(1)=param(1)+param(3)
	y=y+lorentzian(paramline,x)


; The noise is added here only
	Neval=Neval+1
	return,y+exp(param(4))
end

;************************************************


Function spectram1,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:3)=param(0:3)
	
	

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
	l=(N-1)/2
	paramline(0)=param(0)
	paramline(5)=peak(0)
	paramline(1)=param(1)-param(3)
	y=lorentzian(paramline,x)



; The noise is added here only
	Neval=Neval+1
	return,y
end

;************************************************


Function spectrap1,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:3)=param(0:3)
	
	

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
	l=(N-1)/2
; when 2 different amplitudes	
;	paramline(0)=param(5)
	paramline(0)=param(0)
	paramline(5)=peak(2)
	paramline(1)=param(1)+param(3)
	y=lorentzian(paramline,x)


; The noise is added here only
	Neval=Neval+1
	return,y
end

;************************************************

Function spectra,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:3)=param(0:3)

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
	l=(N-1)/2
	for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param(1)+m*param(3)
			y=y+lorentzian(paramline,x)
		endif
	endfor

; The noise is added here only
	Neval=Neval+1
	return,y+exp(param(4))
end

;************************************************

Function spectra_ass,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise,assymmetry)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(8)

	paramline(0:3)=param(0:3)

	paramline(6)=ampli

	paramline(7)=param(5)

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
	l=(N-1)/2
	for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param(1)+m*param(3)
			y=y+lorentzian_rak(paramline,x)
		endif
	endfor

; The noise is added here only
	Neval=Neval+1
	return,y+exp(param(4))
end

;************************************************

Function spectra_rakesh,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,well,linewidth,splitting,noise,source_location,corr_noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(8)


	paramline(0:2)=param(0:2)
	paramline(3)=param(5)
	paramline(4)=param(6)


; Here we put the noise at 0

	if (N gt 1) then begin
		print,'Does not work yet for l>0'
		stop
	endif

	y=0.d0
	l=(N-1)/2
	for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
	;		paramline(1)=param(1)+m*param(3)
			y=y+rakeshi(paramline,x)
		endif
	endfor

; The noise is added here only
	Neval=Neval+1
	return,y+exp(param(4))
end


;************************************************

Function spectra_var,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude(l+1),frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	l=(N-1)/2
	paramline=dblarr(7)

	paramline(1:2)=param(l+1:l+2)

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
	
	for i=0,2*l,2 do begin
		m=i-l
		paramline(0)=param(i/2)
		paramline(5)=0.d0
		paramline(1)=param(l+1)+m*param(l+3)
		y=y+lorentzian(paramline,x)
	endfor

; The noise is added here only
	Neval=Neval+1
	return,y+exp(param(l+4))
end

;************************************************



;************************************************
; Compute theoretical profile for a superposition
; of degree 0 and 2
;************************************************

Function spectra02,param02,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	N02=N_elements(param02)

	paramline=fltarr(N02)

	paramline(*)=0.d0
	

	paramline(0:3)=param02(0:3)
;
	paramline(6)=ampli

; Assymetry
	
	if (N02 gt 7) then begin

		paramline(7:8)=param02(7:8)

	endif

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	for i=0,4 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param02(1)+m*param02(3)
			y=y+lorentzian(paramline,x)				
		endif
	endfor
;
; Compute l=0 spectra
;
	paramline(0:1)=param02(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian(paramline,x)



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param02(4))
end

;************************************************
; Compute theoretical profile for a superposition
; of degree 0 and 2
;************************************************

Function spectra02_slop,param02,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	N02=N_elements(param02)

	paramline=fltarr(N02)

	paramline(*)=0.d0
	

	paramline(0:3)=param02(0:3)
;
	paramline(6)=ampli



; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	for i=0,4 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param02(1)+m*param02(3)
			y=y+lorentzian(paramline,x)				
		endif
	endfor
;
; Compute l=0 spectra
;
	paramline(0:1)=param02(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian(paramline,x)



; The noise is added here only
	Neval=Neval+1

	return,y+exp(param02(4))*(1.+param02(7)*x/1000.)
end


;************************************************

Function spectra02_ass,param02,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	N02=N_elements(param02)

	paramline=fltarr(N02)

	paramline(*)=0.d0
	

	paramline(0:3)=param02(0:3)
;
	paramline(6)=ampli

; Assymetry
	
	if (N02 gt 7) then begin

		paramline(7)=param02(7)

	endif

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	for i=0,4 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param02(1)+m*param02(3)
			y=y+lorentzian_rak(paramline,x)				
		endif
	endfor
;
; Compute l=0 spectra
;
	paramline(0:1)=param02(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian_rak(paramline,x)



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param02(4))
end


;************************************************

Function spectra02_hh,param02,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	N02=N_elements(param02)

	paramline=fltarr(N02)

	paramline(*)=0.d0
	

	paramline(0:3)=param02(0:3)
;
	paramline(6)=ampli

; Assymetry
	
	if (N02 gt 7) then begin

		paramline(7)=param02(7)
		angle=!pi*param02(8)/180.

	endif

	zz=function_rot(2,angle)
	zz=zz^2
	amplitude_m=reform(zz(*,2))
	amplitude_m=amplitude_m/max(amplitude_m)


; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	for i=0,4 do begin
		m=i-l
		paramline(5)=alog(amplitude_m(i))
		paramline(1)=param02(1)+m*param02(3)
		y=y+lorentzian_rak(paramline,x)				
	endfor
;
; Compute l=0 spectra
;
	paramline(0:1)=param02(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian_rak(paramline,x)



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param02(4))
end



Function spectra02pix,param02,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	N02=N_elements(param02)

	paramline=fltarr(N02)

	paramline(*)=0.d0
	

	paramline(0:3)=param02(0:3)
;
	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	for m=-2,2,4 do begin
		paramline(5)=0.
		paramline(1)=param02(1)+m*param02(3)
		y=y+lorentzian(paramline,x)				
	endfor
	paramline(0)=param02(7)
	paramline(5)=0.
	paramline(1)=param02(1)
	y=y+lorentzian(paramline,x)
	
;
; Compute l=0 spectra
;
	paramline(0:1)=param02(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian(paramline,x)



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param02(4))
end




;************************************************



;************************************************
; Compute theoretical profile for a superposition
; of degree 1 and 3
;************************************************

Function spectra13,param13,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=3 spectra
;
;
	paramline=dblarr(9)

	paramline(0:3)=param13(0:3)
;
	paramline(6)=ampli

; Assymetry

	paramline(7:8)=param13(8:9)


; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=3
	for i=0,6 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param13(1)+m*param13(3)
			y=y+lorentzian(paramline,x)
		endif
	endfor
;
; Compute l=1 spectra
;
	paramline(0:1)=param13(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)

	l=1
	for i=0,1 do begin
		m=2*i-l
			paramline(1)=param13(6)+m*param13(7)
			y=y+lorentzian(paramline,x)
	endfor



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param13(4))
end

;************************************************

Function spectra13_ass,param13,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=3 spectra
;
;
	paramline=dblarr(9)

	paramline(0:3)=param13(0:3)
;
	paramline(6)=ampli

; Assymetry

	paramline(7)=param13(8)


; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=3
	for i=0,6 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param13(1)+m*param13(3)
			y=y+lorentzian_rak(paramline,x)
		endif
	endfor
;
; Compute l=1 spectra
;
	paramline(0:1)=param13(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)

	l=1
	for i=0,1 do begin
		m=2*i-l
			paramline(1)=param13(6)+m*param13(7)
			y=y+lorentzian_rak(paramline,x)
	endfor



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param13(4))
end

;************************************************


;************************************************

Function spectra13_hh,param13,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=3 spectra
;
;
	paramline=dblarr(9)

	paramline(0:3)=param13(0:3)
;
	paramline(6)=ampli

; Assymetry

	paramline(7)=param13(8)
	angle=!pi*param13(9)/180.

	zz=function_rot(3,angle)
	zz=zz^2
	amplitude_m3=reform(zz(*,3))
	amplitude_m3=amplitude_m3/max(amplitude_m3)

	zz=function_rot(1,angle)
	zz=zz^2
	amplitude_m1=reform(zz(*,1))
	amplitude_m1=amplitude_m1/max(amplitude_m1)



; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=3
	for i=0,6 do begin
		m=i-l
		paramline(5)=alog(amplitude_m3(i))
		paramline(1)=param13(1)+m*param13(3)
		y=y+lorentzian_rak(paramline,x)
	endfor
;
; Compute l=1 spectra
;
	paramline(0:1)=param13(5:6)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)

	l=1
	for i=0,2 do begin
		m=i-l
		paramline(5)=alog(amplitude_m1(i))
		paramline(1)=param13(6)+m*param13(7)
		y=y+lorentzian_rak(paramline,x)
	endfor



; The noise is added here only
	Neval=Neval+1
	return,y+exp(param13(4))
end

;************************************************

;************************************************

Function spectra_barban,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	N=N_elements(param)

	paramline=fltarr(N)

	paramline(*)=0.d0

	paramline(2)=param(6)
;
	paramline(6)=ampli

	paramline(7)=0.

	angle=!pi*param(7)/180.

	zz=function_rot(2,angle)
	zz=zz^2
	amplitude_m=reform(zz(*,2))
	amplitude_m=amplitude_m/max(amplitude_m)


; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	for i=0,4 do begin
		m=i-l
		paramline(0)=param(i)
		paramline(5)=0.
		paramline(1)=param(5)
		for j=1,3 do begin
			zz='p'+strtrim(j,1)
			s=call_function(zz,m*1.,l*1.)
			paramline(1)=paramline(1)+param(j+6)*l*s
		endfor
		y=y+lorentzian_rak(paramline,x)				
	endfor
;
; Compute l=0 spectra
;
	paramline(0:1)=param(11:12)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian_rak(paramline,x)

;
; Compute l=1 spectra
;
	l=1
	for i=0,2 do begin
		m=i-l
		paramline(0)=param(i+13)
		paramline(5)=0.
		paramline(1)=param(16)
		for j=1,2 do begin
			zz='p'+strtrim(j,1)
			s=call_function(zz,m*1.,l*1.)
			paramline(1)=paramline(1)+param(j+16)*l*s
		endfor
		y=y+lorentzian_rak(paramline,x)				
	endfor



;
; Add spurious modes
;
	paramline(0:1)=param(19:20)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=alog(1.d0)
	y=y+lorentzian_rak(paramline,x)

	paramline(0:1)=param(21:22)
	y=y+lorentzian_rak(paramline,x)
	


; The noise is added here only
	Neval=Neval+1
	return,y+exp(param(10))
end




;************************************************
; Compute theoretical profile for a given l
;************************************************

pro spectraltene,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	spectraltene,param,ampli,x,yout
; PURPOSE:
;	Compute the profiles of an m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, 2*l+1 noise,
;			 crosstalk)
;	ampli		give the amplitude of the alias at 11.57 microHz
;	x 		frequency of the points centered on zero (Npoints)
;	yout 		power spectra (Npoints, 2*degree+1)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	m,nu diagram of a given degree
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	definepeak,degree,peak,crossparam,cindex
;	N=2*degree+1
;	Nparam=3+2*N+cindex
;	param=dblarr(Nparam)
;	error=dblarr(Nparam)
;   
;   of course define xdata,param before calling the routine	
;	spectraltene,param,ampli,xdata,y
; LIMITATIONS:
;	Not portable enough. You need to call definepeak.pro before calling this routine
;	and to know the structure of your crosstalk.
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine definepeak.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)
	N=sqrt(N_elements(crossparam))
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum

	paramline=dblarr(7)
;
; common frequency
;	paramline(1)=param(0)
; common splitting
;	paramline(3)=param(1)
; common linewidth
	paramline(2)=param(2)
; alias amplitude (0.3 for LOI, 0.5 for LOWL)
	paramline(6)=ampli   

; Here we put the noise at 0
	paramline(4)=-10000.d0
;
;
	degree=(N-1)/2
;
	offampl=3+degree
	offnoise=offampl+N
;
; fake crosstalk here at 1.0
	paramline(5)=alog(1.d0)
; copy the input array
	yin=dblarr(Npoints,N)
	yout=yin
;
; 
; 1st for the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		paramline(0)=param(offampl+m)
		paramline(1)=param(0)+m*param(1)
		yin(*,i)=lorentzian(paramline,x(*))
;		lorentzianfast,paramline,x,yinter
;		yin(*,i)=lorentzianfast(paramline,x(*))
	endfor
	yout=yin
;
; then for the modes leaking into the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		for j=1,peak(0,i)-1 do begin
;
; m is the azimuthal order of the present peak
;
			mp=peak(j+1,i)
;
; amplitude of the m mode
			ct=abs(param(crossparam(m+degree,mp+degree)))
			yout(*,i)=yout(*,i)+exp(-ct)*yin(*,mp+degree)
		endfor
	endfor
;
; The noise is added here only
; noise on the mindex mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		yout(*,i)=yout(*,i)+exp(param(offnoise+m))
	endfor


	Neval=Neval+1
end


pro spectralnoise,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	spectralnoise,param,ampli,x,yout
; PURPOSE:
;	Compute the profiles of an m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, l+1 noise,
;			 crosstalkmode)
;	ampli		give the amplitude of the alias at 11.57 microHz
;	x 		frequency of the points centered on zero (Npoints)
;	yout 		power spectra (Npoints, 2*degree+1)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	m,nu diagram of a given degree
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	definepeak,degree,peak,crossparam,cindex
;	N=2*degree+1
;	Nparam=3+2*N+cindex
;	param=dblarr(Nparam)
;	error=dblarr(Nparam)
;   
;   of course define xdata,param before calling the routine	
;	spectraltene,param,ampli,xdata,y
; LIMITATIONS:
;	Not portable enough. You need to call definepeak.pro before calling this routine
;	and to know the structure of your crosstalk.
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine definepeak.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, October, 23, 1996
;	        CLose to spectraltene except that the noise is the same for |m|
;	Beta 2: Now the noise is the same for all m, October, 23, 1996
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)
	N=sqrt(N_elements(crossparam))
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum

	paramline=dblarr(7)
;
; common frequency
;	paramline(1)=param(0)
; common splitting
;	paramline(3)=param(1)
; common linewidth
	paramline(2)=param(2)
; alias amplitude (0.3 for LOI, 0.5 for LOWL)
	paramline(6)=ampli   
	Nparam=N_elements(param)
; Here we put the noise at 0
	paramline(4)=-10000.d0
;
;
	degree=(N-1)/2
;
	offampl=3+degree
	offnoise=offampl+N
;
; fake crosstalk here at 1.0
	paramline(5)=alog(1.d0)
; copy the input array
	yin=dblarr(Npoints,N)
	yout=yin
;
;
	if (degree gt 1) then begin
		L2=degree*(degree+1)
		norma=(-10.*degree^3+(6.*L2-2.)*degree)
	endif
;
; 
; 1st for the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		paramline(0)=param(offampl+m)
		paramline(1)=param(0)+m*param(1)
		if (degree gt 1) then begin
			paramline(1)=paramline(1)+degree*(-10.*m^3+(6.*L2-2.)*m)*param(Nparam-1)/norma
		endif
		yin(*,i)=lorentzian(paramline,x(*))
;		lorentzianfast,paramline,x,yinter
;		yin(*,i)=lorentzianfast(paramline,x(*))
	endfor
	yout=yin
;
; then for the modes leaking into the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		for j=1,peak(0,i)-1 do begin
;
; m is the azimuthal order of the present peak
;
			mp=peak(j+1,i)
;
; amplitude of the m mode
			ct=abs(param(crossparam(m+degree,mp+degree)-degree))
			yout(*,i)=yout(*,i)+exp(-ct)*yin(*,mp+degree)
		endfor
	endfor
;
; The noise is added here only
; noise on the mindex mode
;
;	for i=0,N-1 do begin
;		m=peak(1,i)
;		yout(*,i)=yout(*,i)+exp(param(offnoise+m))
;	endfor
;
; Now noise is the same for all m
;
	for i=0,N-1 do begin
		m=-abs(peak(1,i))
;		m=-degree
		yout(*,i)=yout(*,i)+exp(param(offnoise+m))
	endfor


	Neval=Neval+1
end


;************************************************
; Compute theoretical profile for a given l
;************************************************

pro spectralteneal,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	spectralteneal,param,ampli,x,yout
; PURPOSE:
;	Compute the profiles of an m,nu diagram of a given degree
;	and its higher degree aliases
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, 2*l+1 noise,
;			 crosstalk)
;	ampli		give the amplitude of the alias at 11.57 microHz
;	x 		frequency of the points centered on zero (Npoints)
;	yout 		power spectra (Npoints, 2*degree+1)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	m,nu diagram of a given degree
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	definepeak,degree,peak,crossparam,cindex
;	N=2*degree+1
;	Nparam=3+2*N+cindex
;	param=dblarr(Nparam)
;	error=dblarr(Nparam)
;   
;   of course define xdata,param before calling the routine	
;	spectraltene,param,ampli,xdata,y
; LIMITATIONS:
;	Not portable enough. You need to call definepeak.pro before calling this routine
;	and to know the structure of your crosstalk.
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine definepeak.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common multipletal,peakal
	common crossal,crossparamal
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)
	N=sqrt(N_elements(crossparam))
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum

	paramline=dblarr(7)

; common linewidth
	paramline(2)=param(2)
; alias amplitude (0.3 for LOI, 0.5 for LOWL)
	paramline(6)=ampli   

; Here we put the noise at 0
	paramline(4)=-10000.d0
;
;
	degree=(N-1)/2
;
	offampl=3+degree
	offnoise=offampl+N
;
; fake crosstalk here at 1.0
	paramline(5)=alog(1.d0)
; copy the input array
	yin=dblarr(Npoints,N)
	yout=yin
;
; 
; 1st for the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		paramline(0)=param(offampl+m)
		paramline(1)=param(0)+m*param(1)
		yin(*,i)=lorentzian(paramline,x(*))
;		lorentzianfast,paramline,x,yinter
;		yin(*,i)=lorentzianfast(paramline,x(*))
	endfor
	yout=yin
;
; then for the modes leaking into the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		for j=1,peak(0,i)-1 do begin
;
; m is the azimuthal order of the present peak
;
			mp=peak(j+1,i)
;
; amplitude of the m mode
			ct=abs(param(crossparam(m+degree,mp+degree)))
			yout(*,i)=yout(*,i)+exp(-ct)*yin(*,mp+degree)
		endfor
	endfor


;*****Now for the alias*******
;
	Nal=sqrt(N_elements(crossparamal))


	offal=offnoise+N


; common linewidth
	paramline(2)=param(2+offal)
; alias amplitude (0.3 for LOI, 0.5 for LOWL)
	paramline(6)=ampli   

; Here we put the noise at 0
	paramline(4)=-10000.d0
;
;
	degreeal=(Nal-1)/2
;
	offamplal=3+degreeal+offal
;
; fake crosstalk here at 1.0
	paramline(5)=alog(1.d0)
;
; copy the input array
	yinal=dblarr(Npoints,Nal)


;
; 
; 1st for the m mode
;
	for i=0,Nal-1 do begin
		m=peakal(1,i)
		paramline(0)=param(offamplal+m)
		paramline(1)=param(offal)+m*param(offal+1)
		yinal(*,i)=lorentzian(paramline,x(*))
;		lorentzianfast,paramline,x,yinter
;		yin(*,i)=lorentzianfast(paramline,x(*))
	endfor
;
; then for the modes leaking into the m mode
;
	for i=0,N-1 do begin
		m=peak(1,i)
		for j=1,peakal(0,i)-1 do begin
;
; m is the azimuthal order of the present peak
;
			mp=peakal(j+1,i)
;
; amplitude of the m mode
			ct=abs(param(crossparamal(m+degree,mp+degreeal)))
			yout(*,i)=yout(*,i)+exp(-ct)*yinal(*,mp+degreeal)
		endfor
	endfor

;
; The noise is added here only
; noise on the mindex mode
	for i=0,N-1 do begin
		m=peak(1,i)
		yout(*,i)=yout(*,i)+exp(param(offnoise+m))
	endfor
	Neval=Neval+1
end








pro crosstalk,param,x,Cout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	crosstalk 
; CALLING SEQUENCE:
;	crosstalk,param,xdata,Cout
; PURPOSE:
;	Compute the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, l+1 noise,
;			 crosstalkmode,crosstalknoise)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode and noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is also the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine peakLOI.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, October, 10, 1995
;	Beta 2: Return a crosstalk matrix for the real imag part, October, 22, 1996
;	Beta 3: Remoced a bug computing incorrectly the corr noise, October, 24, 1996
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)
	N=sqrt(N_elements(crossparam))
	Cout=dblarr(N,N,Npoints)
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum

	paramline=dblarr(7)
;
; common frequency
;	paramline(1)=param(0)
; common splitting
;	paramline(3)=param(1)
; common linewidth
	paramline(2)=param(2)
; alias amplitude (0.3 for LOI, 0.5 for LOWL, 0.1 for GONG)
	paramline(6)=ampli   

; Here we put the noise at 0
	paramline(4)=-10000.d0
;
;
	degree=(N-1)/2
;
	offampl=3+degree
	offnoise=offampl+N
;
; fake crosstalk here at 1.0
	paramline(5)=alog(1.d0)
; copy the input array
	yin=dblarr(Npoints,N)
	yout=yin
;
	ctnm=dblarr(N,N)
	ctnmnoise=dblarr(N,N)
	covnm=dblarr(N,N)
;
; 
; Auto crosstalk is one
	for i=0,N-1 do begin
		ctnm(i,i)=1.d0
		ctnmnoise(i,i)=1.d0
	endfor
;
	Nparam=N_elements(param)

	maxcross=max(crossparam)

	mincross=min(crossparam(where(crossparam gt 0)))

	sshift=maxcross-mincross+1

	for i=1,N-1 do begin
		m=peak(1,i)
		for j=1,peak(0,i)-1 do begin
			mp=peak(j+1,i)
			ctnm(i,mp+degree)=param(crossparam(m+degree,mp+degree)-degree)
			ctnm(2*degree-i,-mp+degree)=ctnm(i,mp+degree)
;			ctnm(mp+degree,i)=ctnm(i,mp+degree)
			ctnmnoise(i,mp+degree)=param(crossparam(m+degree,mp+degree)+sshift-degree)
			ctnmnoise(2*degree-i,-mp+degree)=ctnmnoise(i,mp+degree)
;			ctnmnoise(mp+degree,i)=ctnmnoise(i,mp+degree)
		endfor
	endfor

	if (degree gt 1) then begin
		L2=degree*(degree+1)
		norma=(-10.*degree^3+(6.*L2-2.)*degree)
	endif


	for i=0,N-1 do begin
		m=peak(1,i)
		paramline(0)=param(offampl+m)
		paramline(1)=param(0)+m*param(1)
		if (degree gt 1) then begin
			paramline(1)=paramline(1)+degree*(-10.*m^3+(6.*L2-2.)*m)*param(Nparam-1)/norma
		endif
		yin(*,i)=lorentzian(paramline,x(*))
	endfor
;

	for nn=0,N-1 do begin
		for mm=0,N-1 do begin
			Cout(nn,mm,0:Npoints-1)=0.
			for kk=0,N-1 do begin
				croisee=ctnm(nn,kk)*ctnm(mm,kk)
				if (croisee ne 0.) then begin
					Cout(nn,mm,0:Npoints-1)=temporary(Cout(nn,mm,0:Npoints-1))+croisee*temporary(yin(0:Npoints-1,kk))
				endif
			endfor
		endfor
	endfor	

;	for nn=1,N-1 do begin
;		for mm=nn-1,N-2 do begin
;			Cout(mm,nn,0:Npoints-1)=Cout(nn,mm,0:Npoints-1)
;		endfor
;	endfor	
	


;	for nn=0,N-1 do begin
;		m=-abs(peak(1,nn))
;			Cout(nn,nn,0:Npoints-1)=temporary(Cout(nn,nn,0:Npoints-1))+exp(param(offnoise+m))
;	endfor



	for nn=0,N-1 do begin
		m=-abs(peak(1,nn))
;		m=-degree
		for mm=0,N-1 do begin
			croisee=ctnmnoise(nn,mm)
			if (croisee ne 0.) then begin
				Cout(nn,mm,0:Npoints-1)=temporary(Cout(nn,mm,0:Npoints-1))+croisee*exp(param(offnoise+m))
			endif
		endfor
	endfor

	
	Neval=Neval+1
end

pro powerlg,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	powerlg 
; CALLING SEQUENCE:
;	powerlg,param,xdata,Cout
; PURPOSE:
;	Compute the diagonal of the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,linewidth,splitting_1,splitting_3,2*l+1 amplitudes, theta, phi(unused),
;			6 noises)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode plus noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is NOT the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	ctnm1		leakage matrix (2*l+1,2*l+1)
;	croiseen	noise covariance matrix (2*l+1,2*l+1,nb_bruit)
;	nb_bruit	number of pixel noise (typically 3 to 6)	
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, December 10, 1997
;	Beta 2: Gain 20% and factor 10 on mode and noise covariance, resp., TA Dec 16, 1997
;	Beta 3: Gain additional factor 2 on mode covariance, TA Dec 17, 1997
;------------------------------------------------------------------------------

	common speed,Neval
        common crosstalk,ctnm1
        common matbruit,croiseen
        common nb_bruit, nbbruit



N=N_elements(ctnm1(*,0))
degree=(N-1)/2
Npoints=N_elements(x)

Cout=dblarr(2*degree+1,2*degree+1,Npoints)

Nparam=N_elements(param)

a_i=dblarr(5)


;------------------------ donne des noms plus cools pour les parametres

ampli=dblarr(2*degree+1)
bruit=dblarr(6)

freq=param(0)
width=param(1)
a_i(0)=param(2)			;a1
a_i(2)=param(3)			;a3
ampli(0:2*degree)=param(4:2*degree+4)
theta=param(2*degree+5)
phi=param(2*degree+6) ; not used here

bruit(0:5)=exp(param(2*degree+7:2*degree+12))

a_i(1)=param(2*degree+13)	;a2
a_i(3)=param(2*degree+14)	;a4
a_i(4)=param(2*degree+15)	;a5

;------------------- noise
e=systime(1)
;Cout_noise=dblarr(2*degree+1,2*degree+1,Npoints)
;for ii=0,2*degree do begin
;for jj=0,2*degree do begin
;for p=0,nbbruit-1 do begin
;        Cout_noise(ii,jj,0:Npoints-1) = Cout_noise(ii,jj,0:Npoints-1) + croiseen(p,ii,jj)*bruit(p)^2
;endfor	
;endfor
;endfor
f=systime(1)
;print,'         Time for computing the noise covariance',f-e

;	print,Cout_noise(*,*,0)

;Cout_noise=dblarr(2*degree+1,2*degree+1,Npoints)

Cout_simple=dblarr(2*degree+1,2*degree+1)

for p=0,nbbruit-1 do begin
        Cout_simple(*,*) = Cout_simple(*,*) + reform(croiseen(p,*,*)*bruit(p)^2)
endfor	

Cout_noise=rebin(Cout_simple,2*degree+1,2*degree+1,Npoints)

;fff=systime(1)
;print,'         Time for computing the noise covariance',fff-f

;print,Cout_noise(*,*,0)



;-----------------compute variances
variance=dblarr(Npoints,2*degree+1)

paramline=dblarr(7)
; fake crosstalk here at 1.0
paramline(5)=0.d0

paramline(2)=width

maxp= 2*degree < 5

;aa=systime(1)

for i=0,2*degree do begin
        m=i-degree
        paramline(0)=ampli(i)
        paramline(1)=freq
	for icg=1,maxp do begin

	zz='p'+strtrim(icg,1)

	s=call_function(zz,m*1.,degree*1.)

		paramline(1)=paramline(1)+a_i(icg-1)*degree*s
	endfor

;	print,m,paramline(1)-freq
	

	variance(*,i)=lorentzian(paramline,x(*)) 
endfor

;aaa=systime(1)

;print,'      Time for computing the functions',aaa-aa

;read,blurp



	mat_rot=function_rot(degree,theta)

	rctnm=transpose(ctnm1 ## mat_rot)

;read,blurp



rrCout=dblarr(N,N,Npoints)
;g=systime(1)

;print,transpose(rctnm) ## rctnm

;print,rctnm




;for nn=0,N-1 do begin
;	for mm=0,N-1 do begin
;		for kk=0,N-1 do begin
;  			rrCout(nn,mm,0:Npoints-1) = rrCout(nn,mm,0:Npoints-1) + rctnm(nn,kk)*rctnm(mm,kk)*variance(0:Npoints-1,kk)
;
;  		endfor
;	endfor
;endfor		

;print,rrCout(*,*,Npoints/2)


gg=systime(1)
;print,'          Time for computing the mode covariance',gg-g


zz=dblarr(N,N)


;rrCout=dblarr(N,N,Npoints)
;
;	for i=0,Npoints-1 do begin
;		for j=0,N-1 do begin
;			zz(j,j)=variance(i,j)
;		endfor		
;		rrCout(*,*,i)=transpose(rctnm) ## (zz ## rctnm)
;	endfor


;print,rrCout(*,*,Npoints/2)


;ggg=systime(1)
;print,'          Time for computing the mode covariance',ggg-gg

zz=dblarr(N,N)

rctnmk=dblarr(N,N)

varki=dblarr(N,N,Npoints)

for k=0,N-1 do begin
	zz(*,*)=0.
	zz(k,k)=1.d0
	rctnmk=transpose(rctnm) ## (zz ## rctnm)
	rctnmki=rebin(rctnmk,N,N,Npoints)

	varki(0,0,*)=reform(variance(0:Npoints-1,k))

	varki=rebin(varki(0,0,*),N,N,Npoints)
	
	rrCout=rrCout+varki*rctnmki
	
endfor

;print,rrCout(*,*,Npoints/2)

;gggg=systime(1)
;print,'          Time for computing the mode covariance',gggg-ggg



;stop

;print,gg-e

rrCout=rrCout+Cout_noise



;Cout(0:2*degree,0:2*degree,*)=rrCout(0:2*degree,0:2*degree,*)

	yout=dblarr(Npoints,N)

for i=0,2*degree do begin
	yout(*,i)=reform(rrCout(i,i,*))	
endfor

Neval=Neval+1


end


pro powergong,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	powergong 
; CALLING SEQUENCE:
;	powergong,param,xdata,Cout
; PURPOSE:
;	Compute the diagonal of the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,linewidth,splitting_1,splitting_3,2*l+1 amplitudes, theta, phi(unused),
;			6 noises)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode plus noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is NOT the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	ctnm1		leakage matrix (2*l+1,2*l+1)
;	croiseen	noise covariance matrix (2*l+1,2*l+1,nb_bruit)
;	nb_bruit	number of pixel noise (typically 3 to 6)	
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, June 16, 1998
;		The leakage matrix is the identity matrix!
;------------------------------------------------------------------------------

	common speed,Neval
        common crosstalk,ctnm1
        common matbruit,croiseen
        common nb_bruit, nbbruit



N=N_elements(ctnm1(*,0))
degree=(N-1)/2
Npoints=N_elements(x)


Nparam=N_elements(param)

a_i=dblarr(5)


;------------------------ donne des noms plus cools pour les parametres

ampli=dblarr(2*degree+1)
bruit=dblarr(6)

freq=param(0)
width=param(1)
a_i(0)=param(2)			;a1
a_i(2)=param(3)			;a3
ampli(0:2*degree)=param(4:2*degree+4)
theta=param(2*degree+5)
phi=param(2*degree+6) ; not used here

bruit(0:5)=exp(param(2*degree+7:2*degree+12))

a_i(1)=param(2*degree+13)	;a2
a_i(3)=param(2*degree+14)	;a4
a_i(4)=param(2*degree+15)	;a5




;-----------------compute variances
variance=dblarr(Npoints,2*degree+1)

paramline=dblarr(7)
; fake crosstalk here at 1.0
paramline(5)=0.d0

paramline(2)=width

maxp= 2*degree < 5

;aa=systime(1)

for i=0,2*degree do begin
        m=i-degree
        paramline(0)=ampli(i)
        paramline(1)=freq
	for icg=1,maxp do begin

	zz='p'+strtrim(icg,1)

	s=call_function(zz,m*1.,degree*1.)

		paramline(1)=paramline(1)+a_i(icg-1)*degree*s
	endfor

;	print,m,paramline(1)-freq
	

	variance(*,i)=lorentzian(paramline,x(*))+bruit(abs(i-degree))^2
endfor







	yout=variance

Neval=Neval+1


end

pro powergong_real,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	powergong 
; CALLING SEQUENCE:
;	powergong,param,xdata,Cout
; PURPOSE:
;	Compute the diagonal of the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,linewidth,splitting_1,splitting_3,2*l+1 amplitudes, theta, phi(unused),
;			6 noises)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode plus noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is NOT the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	ctnm1		leakage matrix (2*l+1,2*l+1)
;	croiseen	noise covariance matrix (2*l+1,2*l+1,nb_bruit)
;	nb_bruit	number of pixel noise (typically 3 to 6)	
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, June 19, 1998
;		The leakage matrix is the identity matrix!
;		The linewidth of the mode varies with |m|
;------------------------------------------------------------------------------

	common speed,Neval
        common crosstalk,ctnm1
        common matbruit,croiseen
        common nb_bruit, nbbruit



N=N_elements(ctnm1(*,0))
degree=(N-1)/2
Npoints=N_elements(x)


Nparam=N_elements(param)

a_i=dblarr(5)


;------------------------ donne des noms plus cools pour les parametres

ampli=dblarr(2*degree+1)
bruit=dblarr(6)

freq=param(0)
width=param(1)			;unused!
a_i(0)=param(2)			;a1
a_i(2)=param(3)			;a3
ampli(0:2*degree)=param(4:2*degree+4)
theta=param(2*degree+5)
phi=param(2*degree+6) ; not used here

bruit(0:5)=exp(param(2*degree+7:2*degree+12))

a_i(1)=param(2*degree+13)	;a2
a_i(3)=param(2*degree+14)	;a4
a_i(4)=param(2*degree+15)	;a5




;-----------------compute variances
variance=dblarr(Npoints,2*degree+1)

paramline=dblarr(7)
; fake crosstalk here at 1.0
paramline(5)=0.d0

paramline(2)=width

maxp= 2*degree < 5

;aa=systime(1)

for i=0,2*degree do begin
        m=i-degree
	paramline(2)=param(2*degree+16+abs(m))		;linewidth varies with m
        paramline(0)=ampli(i)
        paramline(1)=freq
	for icg=1,maxp do begin

	zz='p'+strtrim(icg,1)

	s=call_function(zz,m*1.,degree*1.)

		paramline(1)=paramline(1)+a_i(icg-1)*degree*s
	endfor

;	print,m,paramline(1)-freq
	

	variance(*,i)=lorentzian(paramline,x(*))+bruit(abs(i-degree))^2
endfor







	yout=variance

Neval=Neval+1


end





pro crosstalklg,param,x,Cout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	crosstalk 
; CALLING SEQUENCE:
;	crosstalklg,param,xdata,Cout
; PURPOSE:
;	Compute the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,linewidth,splitting_1,splitting_3,2*l+1 amplitudes, theta, phi(unused),
;			6 noises)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode plus noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is NOT the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	ctnm1		leakage matrix (2*l+1,2*l+1)
;	croiseen	noise covariance matrix (2*l+1,2*l+1,nb_bruit)
;	nb_bruit	number of pixel noise (typically 3 to 6)	
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, October, 10, 1995
;	Beta 2: Laurent Gizon, March 27, 1997 taking into account pixel noise
;	      : and rotation matrices
;	Beta 3: TA April 8, 1997, do not use phi angle
;	Beta 4: Use ## operator instead of loop for matrix mult., TA April 8, 1997
;	Beta 5: Now fit also the a_i from i=1,5, TA April 23, 1997
;	Beta 6: Correct an integer bug in the p1's, TA May 14, 1997
;	Beta 7: Only up to a_5 is computed, TA May 15, 1997
;	Beta 8: Gain 20% and factor 10 on mode and noise covariance, resp., TA Dec 16, 1997
;	Beta 9: Gain additional factor 2 on mode covaraince, TA Dec 17, 1997
;	Beta 10: Add profile name to be more flexible, TA Jan 20, 1998
;	Beta 11: Correct bug for profile name, TA Feb 20, 1998
;------------------------------------------------------------------------------

	common speed,Neval
        common crosstalk,ctnm1
        common matbruit,croiseen
        common nb_bruit, nbbruit
	common profile,profilename



N=N_elements(ctnm1(*,0))
degree=(N-1)/2
Npoints=N_elements(x)

Cout=dblarr(2*degree+1,2*degree+1,Npoints)

Nparam=N_elements(param)

a_i=dblarr(5)


;------------------------ donne des noms plus cools pour les parametres

ampli=dblarr(2*degree+1)
bruit=dblarr(6)

freq=param(0)
width=param(1)
a_i(0)=param(2)			;a1
a_i(2)=param(3)			;a3
ampli(0:2*degree)=param(4:2*degree+4)
theta=param(2*degree+5)
phi=param(2*degree+6) ; not used here

bruit(0:5)=exp(param(2*degree+7:2*degree+12))

a_i(1)=param(2*degree+13)	;a2
a_i(3)=param(2*degree+14)	;a4
a_i(4)=param(2*degree+15)	;a5

if (profilename ne 'lorentzian') then begin
	assy=param(2*degree+16)		;assymmetry
	wassy=param(2*degree+17)
	paramline=dblarr(9)
	paramline(7)=assy
	paramline(8)=wassy
endif else begin
	paramline=dblarr(7)
endelse

;------------------- noise
;e=systime(1)
Cout_simple=dblarr(2*degree+1,2*degree+1)

for p=0,nbbruit-1 do begin
        Cout_simple(*,*) = Cout_simple(*,*) + reform(croiseen(p,*,*)*bruit(p)^2)
endfor	

Cout_noise=rebin(Cout_simple,2*degree+1,2*degree+1,Npoints)

f=systime(1)
;print,'         Time for computing the noise covariance',f-e

;-----------------compute variances
variance=dblarr(Npoints,2*degree+1)


; fake crosstalk here at 1.0
paramline(5)=0.d0

paramline(2)=width

maxp= 2*degree < 5

;aa=systime(1)

for i=0,2*degree do begin
        m=i-degree
        paramline(0)=ampli(i)
        paramline(1)=freq
	for icg=1,maxp do begin

	zz='p'+strtrim(icg,1)

	s=call_function(zz,m*1.,degree*1.)

		paramline(1)=paramline(1)+a_i(icg-1)*degree*s
	endfor 
	
	variance(*,i)=call_function(profilename,paramline,x(*))


endfor

;aaa=systime(1)

;print,'      Time for computing the functions',aaa-aa

;read,blurp



	mat_rot=function_rot(degree,theta)

	rctnm=transpose(ctnm1 ## mat_rot)

;read,blurp


;dd=systime(1)	
rrCout=dblarr(N,N,Npoints)
;g=systime(1)
;print,dd-g

;print,transpose(rctnm) ## rctnm

;print,rctnm

zz=dblarr(N,N)


rrCout=dblarr(N,N,Npoints)
;
;	for i=0,Npoints-1 do begin
;		for j=0,N-1 do begin
;			zz(j,j)=variance(i,j)
;		endfor		
;		rrCout(*,*,i)=transpose(rctnm) ## (zz ## rctnm)
;	endfor




;for nn=0,N-1 do begin
;	for mm=0,N-1 do begin
;		for kk=0,N-1 do begin
;  			rrCout(nn,mm,0:Npoints-1) = rrCout(nn,mm,0:Npoints-1) + rctnm(nn,kk)*rctnm(mm,kk)*variance(0:Npoints-1,kk)
;
;  		endfor
;	endfor
;endfor	

zz=dblarr(N,N)

rctnmk=dblarr(N,N)

varki=dblarr(N,N,Npoints)

for k=0,N-1 do begin
	zz(*,*)=0.
	zz(k,k)=1.d0
	rctnmk=transpose(rctnm) ## (zz ## rctnm)
	rctnmki=rebin(rctnmk,N,N,Npoints)

	varki(0,0,*)=reform(variance(0:Npoints-1,k))

	varki=rebin(varki(0,0,*),N,N,Npoints)
	
	rrCout=rrCout+varki*rctnmki
	
endfor	



;gg=systime(1)
;print,'          Time for computing the mode covariance',gg-g
;stop

;print,gg-e

rrCout=rrCout+Cout_noise



Cout(0:2*degree,0:2*degree,*)=rrCout(0:2*degree,0:2*degree,*)




Neval=Neval+1


end


pro crosstalklgm,param,x,Cout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	crosstalk 
; CALLING SEQUENCE:
;	crosstalklg,param,xdata,Cout
; PURPOSE:
;	Compute the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,l+1 linewidth,splitting_1,splitting_3,l+1 amplitudes, theta, phi(unused),
;			6 noises)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode plus noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is NOT the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	ctnm1		leakage matrix (2*l+1,2*l+1)
;	croiseen	noise covariance matrix (2*l+1,2*l+1,nb_bruit)
;	nb_bruit	number of pixel noise (typically 3 to 6)	
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, March 20, 2002
;------------------------------------------------------------------------------

	common speed,Neval
        common crosstalk,ctnm1
        common matbruit,croiseen
        common nb_bruit, nbbruit
	common profile,profilename



N=N_elements(ctnm1(*,0))
degree=(N-1)/2
Npoints=N_elements(x)

Cout=dblarr(2*degree+1,2*degree+1,Npoints)

Nparam=N_elements(param)

a_i=dblarr(5)


;------------------------ donne des noms plus cools pour les parametres

ampli=dblarr(2*degree+1)
bruit=dblarr(6)

freq=param(0)
width=[param(1),param(5+degree:2*degree+4)]
a_i(0)=param(2)			;a1
a_i(2)=param(3)			;a3
ampli(0:degree)=param(4:degree+4)
theta=param(2*degree+5)
phi=param(2*degree+6) ; not used here

bruit(0:5)=exp(param(2*degree+7:2*degree+12))

a_i(1)=param(2*degree+13)	;a2
a_i(3)=param(2*degree+14)	;a4
a_i(4)=param(2*degree+15)	;a5

if (profilename ne 'lorentzian') then begin
	assy=param(2*degree+16)		;assymmetry
	wassy=param(2*degree+17)
	paramline=dblarr(9)
	paramline(7)=assy
	paramline(8)=wassy
endif else begin
	paramline=dblarr(7)
endelse

;------------------- noise
;e=systime(1)
Cout_simple=dblarr(2*degree+1,2*degree+1)

for p=0,nbbruit-1 do begin
        Cout_simple(*,*) = Cout_simple(*,*) + reform(croiseen(p,*,*)*bruit(p)^2)
endfor	

Cout_noise=rebin(Cout_simple,2*degree+1,2*degree+1,Npoints)

f=systime(1)
;print,'         Time for computing the noise covariance',f-e

;-----------------compute variances
variance=dblarr(Npoints,2*degree+1)


; fake crosstalk here at 1.0
paramline(5)=0.d0



maxp= 2*degree < 5

;aa=systime(1)

for i=0,2*degree do begin
        m=i-degree
        paramline(0)=ampli(abs(m))
	paramline(2)=width(abs(m))
        paramline(1)=freq
	for icg=1,maxp do begin

	zz='p'+strtrim(icg,1)

	s=call_function(zz,m*1.,degree*1.)

		paramline(1)=paramline(1)+a_i(icg-1)*degree*s
	endfor 
	
	variance(*,i)=call_function(profilename,paramline,x(*))


endfor

;aaa=systime(1)

;print,'      Time for computing the functions',aaa-aa

;read,blurp



	mat_rot=function_rot(degree,theta)

	rctnm=transpose(ctnm1 ## mat_rot)

;read,blurp


;dd=systime(1)	
rrCout=dblarr(N,N,Npoints)
;g=systime(1)
;print,dd-g

;print,transpose(rctnm) ## rctnm

;print,rctnm

zz=dblarr(N,N)


rrCout=dblarr(N,N,Npoints)
;
;	for i=0,Npoints-1 do begin
;		for j=0,N-1 do begin
;			zz(j,j)=variance(i,j)
;		endfor		
;		rrCout(*,*,i)=transpose(rctnm) ## (zz ## rctnm)
;	endfor




;for nn=0,N-1 do begin
;	for mm=0,N-1 do begin
;		for kk=0,N-1 do begin
;  			rrCout(nn,mm,0:Npoints-1) = rrCout(nn,mm,0:Npoints-1) + rctnm(nn,kk)*rctnm(mm,kk)*variance(0:Npoints-1,kk)
;
;  		endfor
;	endfor
;endfor	

zz=dblarr(N,N)

rctnmk=dblarr(N,N)

varki=dblarr(N,N,Npoints)

for k=0,N-1 do begin
	zz(*,*)=0.
	zz(k,k)=1.d0
	rctnmk=transpose(rctnm) ## (zz ## rctnm)
	rctnmki=rebin(rctnmk,N,N,Npoints)

	varki(0,0,*)=reform(variance(0:Npoints-1,k))

	varki=rebin(varki(0,0,*),N,N,Npoints)
	
	rrCout=rrCout+varki*rctnmki
	
endfor	



;gg=systime(1)
;print,'          Time for computing the mode covariance',gg-g
;stop

;print,gg-e

rrCout=rrCout+Cout_noise



Cout(0:2*degree,0:2*degree,*)=rrCout(0:2*degree,0:2*degree,*)




Neval=Neval+1


end




pro crosstalkgong,param,x,Cout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	crosstalk 
; CALLING SEQUENCE:
;	crosstalkgong,param,xdata,Cout
; PURPOSE:
;	Compute the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,linewidth,splitting_1,splitting_3,2*l+1 amplitudes, theta, phi(unused),
;			6 noises)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode plus noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Derived from crosstalklg, 28 March 2002
;------------------------------------------------------------------------------

	common speed,Neval
        common crosstalk,ctnm1
        common matbruit,croiseen
        common nb_bruit, nbbruit
	common profile,profilename



N=N_elements(ctnm1(*,0))
degree=(N-1)/2
Npoints=N_elements(x)

Cout=dblarr(2*degree+1,2*degree+1,Npoints)

Nparam=N_elements(param)

a_i=dblarr(5)


;------------------------ donne des noms plus cools pour les parametres

ampli=dblarr(2*degree+1)
bruit=dblarr(nbbruit)

freq=param(0)
width=param(1)
a_i(0)=param(2)			;a1
a_i(2)=param(3)			;a3
ampli(0:degree)=param(4:degree+4)
theta=param(2*degree+5)
phi=param(2*degree+6) ; not used here

bruit=exp(param(2*degree+7:2*degree+7+nbbruit))

a_i(1)=param(2*degree+7+nbbruit)	;a2
a_i(3)=param(2*degree+7+nbbruit+1)	;a4
a_i(4)=param(2*degree+7+nbbruit+2)	;a5

if (profilename ne 'lorentzian') then begin
	assy=param(2*degree+7+nbbruit+3)		;assymmetry
	wassy=param(2*degree+7+nbbruit+4)
	paramline=dblarr(9)
	paramline(7)=assy
	paramline(8)=wassy
endif else begin
	paramline=dblarr(7)
endelse

;------------------- noise
;e=systime(1)
Cout_simple=dblarr(2*degree+1,2*degree+1)

for p=0,nbbruit-1 do begin
        Cout_simple(*,*) = Cout_simple(*,*) + reform(croiseen(p,*,*)*bruit(p)^2)
endfor	

Cout_noise=rebin(Cout_simple,2*degree+1,2*degree+1,Npoints)

f=systime(1)
;print,'         Time for computing the noise covariance',f-e

;-----------------compute variances
variance=dblarr(Npoints,2*degree+1)


; fake crosstalk here at 1.0
paramline(5)=0.d0

paramline(2)=width

maxp= 2*degree < 5

;aa=systime(1)

for i=0,2*degree do begin
        m=i-degree
        paramline(0)=ampli(degree-abs(m))
        paramline(1)=freq
	for icg=1,maxp do begin

	zz='p'+strtrim(icg,1)

	s=call_function(zz,m*1.,degree*1.)

		paramline(1)=paramline(1)+a_i(icg-1)*degree*s
	endfor 
	
	variance(*,i)=call_function(profilename,paramline,x(*))


endfor

;aaa=systime(1)

;print,'      Time for computing the functions',aaa-aa

;read,blurp



	mat_rot=function_rot(degree,theta)

	rctnm=transpose(ctnm1 ## mat_rot)

;read,blurp


;dd=systime(1)	
rrCout=dblarr(N,N,Npoints)
;g=systime(1)
;print,dd-g

;print,transpose(rctnm) ## rctnm

;print,rctnm

zz=dblarr(N,N)


rrCout=dblarr(N,N,Npoints)
;
;	for i=0,Npoints-1 do begin
;		for j=0,N-1 do begin
;			zz(j,j)=variance(i,j)
;		endfor		
;		rrCout(*,*,i)=transpose(rctnm) ## (zz ## rctnm)
;	endfor




;for nn=0,N-1 do begin
;	for mm=0,N-1 do begin
;		for kk=0,N-1 do begin
;  			rrCout(nn,mm,0:Npoints-1) = rrCout(nn,mm,0:Npoints-1) + rctnm(nn,kk)*rctnm(mm,kk)*variance(0:Npoints-1,kk)
;
;  		endfor
;	endfor
;endfor	

zz=dblarr(N,N)

rctnmk=dblarr(N,N)

varki=dblarr(N,N,Npoints)

for k=0,N-1 do begin
	zz(*,*)=0.
	zz(k,k)=1.d0
	rctnmk=transpose(rctnm) ## (zz ## rctnm)
	rctnmki=rebin(rctnmk,N,N,Npoints)

	varki(0,0,*)=reform(variance(0:Npoints-1,k))

	varki=rebin(varki(0,0,*),N,N,Npoints)
	
	rrCout=rrCout+varki*rctnmki
	
endfor	



;gg=systime(1)
;print,'          Time for computing the mode covariance',gg-g
;stop

;print,gg-e

rrCout=rrCout+Cout_noise



Cout(0:2*degree,0:2*degree,*)=rrCout(0:2*degree,0:2*degree,*)




Neval=Neval+1


end


Function pspectra,param,x
	common multiplet,peak
	common speed,Neval
	
;
; This computes the total p modes spectrum
;
; param=(nmodes,frequencies,splitting,linewidths,amplitudes,noisea,noiseb)
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	
	l=(N-1)/2
	
	Nx=N_elements(x)
	nmodes=param(0)

	
	Nxsmall=N_elements(x)/nmodes
	
	xsmall=x(0:Nxsmall-1)
	
	paramline=dblarr(7)

	paramline(6)=0.

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=x
	y(0:Nx-1)=0.
	
; Common linewidth
	paramline(2)=param(3)
	
; Here we loop on the nmodes
	for nn=0,nmodes-1 do begin
		for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(2)=param(nmodes+2+nn)
			paramline(0)=param(2*nmodes+2+nn)
			paramline(1)=param(nn+1)+m*param(nmodes+1)
			sbegin=nn*Nxsmall
			send=sbegin+Nxsmall-1
			y(sbegin:send)=y(sbegin:send)+lorentzian(paramline,xsmall)
		endif
	endfor

	endfor
; The noise is added here only
	Neval=Neval+1
;	print,param(23:26)
	for nn=0,nmodes-1 do begin
		sbegin=nn*Nxsmall
		send=sbegin+Nxsmall-1
		y(sbegin:send)=y(sbegin:send)+exp(param(3*nmodes+2+nn))
		;+nn*exp(param(3*nmodes+3))
	endfor
	return,y
end

;************************************************


Function gspectra,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
	common gfreq,frequse,Nmodes
	common entier,resol
	common orderlist,order,Nm
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
	Nx=N_elements(x)
	paramline=dblarr(7)

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0.d0
; Common linewidth
	paramline(2)=param(3)
; Here we loop on the degree
	for deg=0,2 do begin
		l=deg+1
; Here we loop on the frequencies
; works now only for l=1
		for j=0,Nm(deg)-1 do begin
; set amplitude for j-ieme mode
			paramline(0)=param(deg)
; set frequency
			for i=0,2*l do begin
				m=i-l
				if (peak(i,deg) NE -10000.d0) then begin
					paramline(5)=peak(i,deg)
		centralfreq=frequse(j,deg)+m*(1.-1./l/(l+1.))*exp(-abs(param(4)))
;
; take into account the fact that the g modes are unresolved
;
				kcen=round(centralfreq/resol)
				if (kcen ge 0) then begin
					if (kcen le Nx-1) then begin
						paramline(1)=resol*kcen		
						y=y+lorentzian(paramline,x)
					endif
				endif
				endif
			endfor
		endfor
	endfor
; The noise is added here only
	Neval=Neval+1
;	print,param(23:26)
	y=y+exp(param(5))+exp(param(6))*(x/param(8))^param(7)
	return,y
end

;************************************************




Function gspectraasymp,param,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
	common orderlist,order,Nm
	common degree,l
	common degreemax,dmax
;	common gfreq,frequse,Nmodes
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;

	frequse=dblarr(40,3)
	paramasym=param(0:3)
;
	for l=1,dmax do begin
		nin=order(0:Nm(l-1)-1,l-1)
		out=nin
		gmodesfreq,nin,paramasym,out
		frequse(0:Nm(l-1)-1,l-1)=out
;		print,nin,frequse
	endfor
;	
;
	paramline=dblarr(7)

	paramline(6)=ampli

; Here we put the noise at 0
	paramline(4)=-10000.d0
;
;	if (abs(param(8)) gt 1.0) then begin
;		param(8)=1.0
;	endif
	split=exp(-abs(param(8)))
	y=0.d0
; Common linewidth
	paramline(2)=param(7)
	width=0.127
; Here we loop on the degree
	for deg=0,dmax-1 do begin
		l=deg+1
; Here we loop on the frequencies
; works now only for l=1
		for j=0,Nm(deg)-1 do begin
; set amplitude for j-ieme mode
			paramline(0)=param(deg+4)
			
; set frequency
			for i=0,2*l do begin
				m=i-l
				if (peak(i,deg) NE -10000.d0) then begin
					paramline(5)=peak(i,deg)
						
					paramline(1)=frequse(j,deg)+m*(1.-1./l/(l+1.))*split
; Here we convert to an frequency bin
					paramline(1)=round(paramline(1)/width)*width

					y=y+lorentzian(paramline,x)
					
				endif
			endfor
		endfor
	endfor
; The noise is added here only
	Neval=Neval+1
;	
	y=y+exp(param(9))+exp(param(10))*(abs(x/param(12)))^param(11)
	return,y
end




;************************************************

pro gmodesfreq,x,param,outfreq
	common degree,l
	common Pnotc,Pnotmin,Pnotmax

	Pnot=(Pnotmax-Pnotmin)*exp(-abs(param(0)))+Pnotmin
;	print,Pnot
;
	tetanot=0.6*exp(-abs(param(1)))-0.4+(0.5)
;	print,tetanot

	V1=0.5*exp(-abs(param(2))*1.)
;	print,V1

	V2=exp(-abs(param(3))*1.)*7.0
;	print,V2
;
	Npoints=N_elements(x)
;
	a=dblarr(Npoints)
	b=dblarr(Npoints)
;
	ll=sqrt(l*(l+1.))
;	print,l,ll
;
	a=Pnot*(x+l/2.-0.25-tetanot)/ll
;
	b(0:Npoints-1)=Pnot*Pnot*(ll*ll*V1+V2)/ll/ll
;	print,ll*ll*V1+V2
;
	delta=a*a+4*b
	for i=0,Npoints-1 do begin 
		if (delta(i) lt 0) then begin
			delta(i)=a(i)*a(i)
			print,'negatif?'
		endif
	endfor	
	outfreq=(a+sqrt(delta))/2.
;	print,delta,a
;
	outfreq=1000000./60./outfreq
;	print,x,outfreq

;
;	print,Npoints
;	pder=findgen(Npoints,4)
;	pder=dblarr(Npoints,4)
end


;************************************************




;************************************************
; Compute (lorentzian) profile of one line
;************************************************

Function lorentzian,param,x

; This routine computes for a given  array x 
;
; the y profile :  k_A* A / ( 1 + (B-x+k_D*D)^2/C^2 )  + E
;
; remark : k_A and k_D are not variables in this routine
; k_D is for the azimutal order m

A   = exp(param(0)) 	; the amplitude
B   = param(1) 		; the central frequency of the m mode
C   = exp(param(2))/2. 	; the half linewidth
;D   = param(3) 		; the splitting
;E   = exp(param(4)) 	; the noise
k_A = exp(param(5)) 		; the crosstalk
alias=param(6)



; the value is computed in x
	z = 1. / ( 1.0d0 + ((B-x)/C)^2 )

	y = k_A * A * z 


;	if (alias ne 0.) then begin
;		y = y+alias*k_A * A / ( 1.0d0 + ((B-x-11.57)/C)^2 )
;		y = y+alias*k_A * A / ( 1.0d0 + ((B-x+11.57)/C)^2 )
;	endif
	

	return,y

end

;************************************************


Function lorentzian_ass,param,x

; This routine computes for a given  array x 
;
; the y ASSYMETRICAL profile derived from lorentzian
;
; remark : k_A is not variable in this routine


A   = exp(param(0)) 	; the amplitude
B   = param(1) 		; the central frequency of the m mode
C   = exp(param(2))/2. 	; the half linewidth
;D   = param(3) 		; the splitting
;E   = exp(param(4)) 	; the noise
k_A = exp(param(5)) 		; the crosstalk
alias=param(6)



; the value is computed in x
	z = 1. / ( 1.0d0 + ((B-x)/C)^2 )

	y = z 

	Basy = param(7)			; Amplitude of assymetry
;	wassy = param(8)

	zasy=1.-((Basy+B-x)/C)^2
		
	y = y * zasy

	y = k_A * A * (y - min(y))/(max(y)-min(y))	

	return, y 

end


Function lorentzian_rak,param,x

; This routine computes for a given  array x 
;
; the y ASSYMETRICAL profile derived from lorentzian
;
; remark : k_A is not variable in this routine


A   = exp(param(0)) 	; the amplitude
B   = param(1) 		; the central frequency of the m mode
C   = exp(param(2))/2. 	; the half linewidth
;D   = param(3) 		; the splitting
;E   = exp(param(4)) 	; the noise
k_A = exp(param(5)) 		; the crosstalk
alias=param(6)



; the value is computed in x
	z = 1. / ( 1.0d0 + ((B-x)/C)^2 )

	y = z 

	Basy = param(7)			; Amplitude of assymetry
;	wassy = param(8)

	zasy=(1.+(Basy*(x-B)/C))^2+Basy^2
		
	y = y * zasy

	y = k_A * A * y

;(y - min(y))/(max(y)-min(y))	

	return, y 

end


Function lorentzian_tt,param,x

; This routine computes for a given  array x 
;
; the y ASSYMETRICAL profile derived from lorentzian
;
; remark : k_A is not variable in this routine


A   = exp(param(0)) 	; the amplitude
B   = param(1) 		; the central frequency of the m mode
C   = exp(param(2))/2. 	; the half linewidth
;D   = param(3) 		; the splitting
;E   = exp(param(4)) 	; the noise
k_A = exp(param(5)) 		; the crosstalk
alias=param(6)



; the value is computed in x
	z = 1. / ( 1.0d0 + ((B-x)/C)^2 )

	y = z 

	Basy = param(7)			; Amplitude of assymetry
;	wassy = param(8)


	y=k_A * A * z * (1.+2. * Basy * sqrt(0.01) * (B-x)/C )


	return, y 

end


Function rakeshi,param,x

; This routine computes for a given  array x 
;
; the y profile :A* ( cos(k*rs) / ( k * cos(k*a)+k_1*sin(k*a)))2
;
; After Nigam et al, 1997
;
; remark : k_A and k_D are not variables in this routine
; k_D is for the azimutal order m

A   = exp(param(0)) 	; the amplitude
aa   = param(1)		;  the width of the well in sec (depends on l) (time to go from 0 to aa)
C   = exp(param(2))/2. 	; the half linewidth
rs   = param(3) 		; the location of the source in sec (time to go from 0 to rs)
; ra and aa are about 3680 sec depending on l
N_corr=param(4)
k_A = exp(param(5)) 		; the crosstalk


; the value is computed in x
;	y = k_A * A / ( 1.0d0 + ((B-x)/C)^2 ) 
	
	omega=2.d0*!pi*x*1d-06
	
	omega_c=2.d0*!pi*0.0055d0
	
	ri=complex(0.,1.d0)
	
	k=sqrt(omega^2+ri*omega*4.d0*!pi*C*1e-6)
	
	
	k_1=sqrt(omega_c^2-k^2)
	
	
	Num=(exp(ri*k*rs)+exp(-ri*k*rs))/2.d0
	
	Den1=(k+k_1/ri)*exp(ri*k*aa)/2.d0
	
	Den2=(k-k_1/ri)*exp(-ri*k*aa)/2.d0
	
	Den=Den1+Den2

	y=abs(N_corr+Num/Den)^2


	y=y/max(y(where((x gt 1500) and (x lt 5500))))

	y(0)=0.
			
	y=k_A*A*y

	return,y

end




pro peakLOI,degree,index
;------------------------------------------------------------------------------
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;	Beta 2: Add crosstalk for l=5, m=+/-1, June, 2, 1995
;	Beta 3: Correct crosstalk for l=2, m=0, November, 1995
;	Beta 4: Add l=6, July, 1996
;	Beta 5: Add l=7, July, 1996
;	Beta 6: Add l=8, Oct, 1996
;------------------------------------------------------------------------------
; peak is a common array that gives:
; on the first column the number of modes in an m spectrum
; on the subsequent columns the m's that have to included in
; the summation
;
; Example:
;	1 -5  0 0 0 0  (For m=-5, 1 peak at m=-5)
;       2 -4 -3 0 0 0  (For m=-3, 2 peaks at m=-4, m=-3)
;       0  0  0 0 0 0  (For m=-2, 0 peak) 
;       etc ...
; 
; Its dimension is (N+1,N)
;
	common multiplet,peak
	common cross,crossparam

	N=2*degree+1
;
	peak=dblarr(N+1,N)
;
; ***************For l=1**********************
;
	if (degree eq 1) then begin
;
; m=-1	
		peak([0,1,2],0)=[2,-1,1]
;
; m=0
		peak([0,1],1)=[1,0]
;
; m=+1
		peak([0,1,2],2)=[2,1,-1]
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree eq 2) then begin
;
; m=-2
		peak([0,1,2,3],0)=[3,-2,0,2]
;
; m=-1

		peak([0,1,2,3],1)=[3,-1,0,1]
;
; m=0
		peak([0,1,2,3],2)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2,3],3)=[3,1,-1,0]
;
; m=+2
		peak([0,1,2,3],4)=[3,2,-2,0]
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree eq 3) then begin
;
; m=-3
		peak([0,1],0)=[1,-3]

;
; m=-2
		peak([0,1,2,3],1)=[3,-2,0,2]
;
; m=-1
		peak([0,1,2],2)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],3)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],4)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],5)=[3,2,-2,0]
;
; m=+3
		peak([0,1],6)=[1,3]
;
	endif
; *********************************************
; **************For l=4***********************
	
	if (degree eq 4) then begin
;
; m=-4
		peak([0,1],0)=[1,-4]
;
; m=-3
		peak([0,1],1)=[1,-3]
;
; m=-2
		peak([0,1,2,3],2)=[3,-2,0,2]
;
; m=-1
		peak([0,1,2],3)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],4)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],5)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],6)=[3,2,-2,0]
;
; m=+3
		peak([0,1],7)=[1,3]
;
; m=+4
		peak([0,1],8)=[1,4]

;
	endif
; *********************************************
; **************For l=5***********************
	
	if (degree eq 5) then begin
;
; m=-5
		peak([0,1,2],0)=[2,-5,5]
;
; m=-4
		peak([0,1,2],1)=[2,-4,2]
;
; m=-3
		peak([0,1,2],2)=[2,-3,3]
;
; m=-2
		peak([0,1,2],3)=[2,-2,0]
;
; m=-1 
		peak([0,1,2,3,4],4)=[4,-1,-3,1,3]
;
; m=0
		peak([0,1,2,3],5)=[3,0,-2,2]
;
; m=+1 
		peak([0,1,2,3,4],6)=[4,1,-3,-1,3]
;
; m=+2
		peak([0,1,2],7)=[2,2,0]
;
; m=+3
		peak([0,1,2],8)=[2,3,-3]
;
; m=+4
		peak([0,1,2],9)=[2,4,-2]
;
; m=+5
		peak([0,1,2],10)=[2,5,-5]

;
	endif
; *********************************************

; **************For l=6***********************
	
	if (degree eq 6) then begin
;
; m=-6
		peak([0,1,2],0)=[2,-6,6]
;
; m=-5
		peak([0,1,2,3],1)=[3,-5,3,5]
;
; m=-4
		peak([0,1,2],2)=[2,-4,4]
;
; m=-3
		peak([0,1,2],3)=[2,-3,-1]
;
; m=-2 
		peak([0,1,2,3,4,5,6],4)=[6,-2,-6,-4,2,4,6]
;
; m=-1
		peak([0,1,2,3],5)=[3,-1,-3,1]
;
; m=0 
		peak([0,1,2,3],6)=[3,0,-4,4]
;
; m=+1
		peak([0,1,2,3],7)=[3,1,-1,3]
;
; m=+2
		peak([0,1,2,3,4,5,6],8)=[6,2,-6,-4,-2,4,6]
;
; m=+3
		peak([0,1,2],9)=[2,3,1]
;
; m=+4
		peak([0,1,2],10)=[2,4,-4]
;
; m=+5
		peak([0,1,2,3],11)=[3,5,-5,-3]
;
; m=+6
		peak([0,1,2],12)=[2,6,-6]

;
	endif
; *********************************************

; **************For l=7***********************
	
	if (degree eq 7) then begin
;
; m=-7
		peak([0,1,2],0)=[2,-7,7]
;
; m=-6
		peak([0,1,2,3],1)=[3,-6,-4,6]
;
; m=-5
		peak([0,1,2,3,4],2)=[4,-5,-3,3,5]
;
; m=-4
		peak([0,1,2],3)=[2,-4,-2]
;
; m=-3 
		peak([0,1,2,3,4,5,6],4)=[6,-3,-5,-1,3,5,7]
;
; m=-2
		peak([0,1,2,3],5)=[3,-2,0,2]
;
; m=-1 
		peak([0,1,2,3,4],6)=[4,-1,-3,1,5]
;
; m=0
		peak([0,1,2,3],7)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2,3,4],8)=[4,1,-5,-1,3]
;
; m=+2
		peak([0,1,2,3],9)=[3,2,-2,0]
;
; m=+3
		peak([0,1,2,3,4,5,6],10)=[6,3,-7,-5,-3,1,5]
;
; m=+4
		peak([0,1,2],11)=[2,4,2]
;
; m=+5
		peak([0,1,2,3,4],12)=[4,5,-5,-3,3]
;
; m=+6
		peak([0,1,2,3],13)=[3,6,-6,4]
;
; m=+7
		peak([0,1,2],14)=[2,7,-7]

;
	endif
; *********************************************

; **************For l=8***********************
;
	if (degree eq 8) then begin
;
; m=-8
		peak([0,1],0)=[1,-8]
;
; m=-7
		peak([0,1,2,3,4],1)=[4,-7,-5,5,7]
;
; m=-6
		peak([0,1],2)=[1,-6]
;
; m=-5
		peak([0,1,2,3,4,5],3)=[5,-5,-7,-3,5,7]
;
; m=-4 
		peak([0,1,2,3,4,5,6,7],4)=[7,-4,-6,-2,2,4,6,8]
;
; m=-3
		peak([0,1,2,3,4],5)=[4,-3,-5,-1,7]
;
; m=-2 
		peak([0,1,2,3,4,5],6)=[5,-2,-4,0,2,4]
;
; m=-1
		peak([0,1,2,3,4,5],7)=[5,-1,-3,1,3,7]
;
; m=0
		peak([0,1,2,3],8)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2,3,4,5],9)=[5,1,-7,-3,-1,3]
;
; m=+2
		peak([0,1,2,3,4,5],10)=[5,2,-4,-2,0,4]
;
; m=+3
		peak([0,1,2,3,4],11)=[4,3,-7,1,5 ]
;
; m=+4
		peak([0,1,2,3,4,5,6,7],12)=[7,4,-8,-6,-4,-2,2,6]
;
; m=+5
		peak([0,1,2,3,4,5],13)=[5,5,-7,-5,3,7]
;
; m=+6
		peak([0,1],14)=[1,6]
;
; m=+7
		peak([0,1,2,3,4],15)=[4,7,-7,-5,5]
;
; m=+8
		peak([0,1],16)=[1,8]

;
	endif

; *********************************************

;
;
; Here we decode peak for getting the number of crosstalk parameters
;
	cindex=0
; decode only for 1<=m<=l
; par symmetry the crosstalk parameters are the same
	for m=1,degree do begin
		cindex=cindex+peak(0,m+degree)-1
	endfor
; add the cindex for m=0
	cindex=cindex+(peak(0,degree)-1)/2
	index=cindex	
;
; Here a crosstalk matrix with the index of the crosstalk 
; parameters for given couple of (m,m') mode
	crossparam=dblarr(N,N)
	cstart=2*N+3
	for m=0,degree-1 do begin
		for i=0,peak(0,m)-2 do begin
			mp=peak(2+i,m)+degree
			crossparam(m,mp)=cstart
			crossparam(N-1-m,N-1-mp)=cstart
			cstart=cstart+1
		endfor
	endfor	
	m=degree
	for i=0,(peak(0,m)-3)/2 do begin
		mp=peak(2+i,m)+degree
		crossparam(m,mp)=cstart
		crossparam(N-1-m,N-1-mp)=cstart
		cstart=cstart+1
	endfor
end








pro peakIPHIR,degree
; peak is a common array that gives the amplitude distribution 
; in a multiplet
;
	common multiplet,peak
	if (degree GT 3) then begin
		print,'Please provide the amplitude distribution for the degree greater or equal to 4...you will now get rubbish...'
	endif
	N=2*degree+1
;
	peak=dblarr(N)
	peak(0)=1.

;
; ***************For l=1**********************
;
	if (degree eq 1) then begin
;
; m=-1	
		peak(0)=alog(1.)
;
; m=0
		peak(1)=-10000.d0
;
; m=+1
		peak(2)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree eq 2) then begin
;
; m=-2
		peak(0)=alog(1.)
;
; m=-1

		peak(1)=-10000.d0
;
; m=0
		peak(2)=alog(0.65)
;
; m=+1
		peak(3)=-10000.d0
;
; m=+2
		peak(4)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree eq 3) then begin
;
; m=-3
		peak(0)=alog(1.)

;
; m=-2
		peak(1)=-10000.d0
;
; m=-1
		peak(2)=alog(0.64)
;
; m=0
		peak(3)=-10000.d0
;
; m=+1
		peak(4)=alog(0.64)
;
; m=+2
		peak(5)=-10000.d0
;
; m=+3
		peak(6)=alog(1.)
;
	endif
; *********************************************
; **************For l=4***********************
	
	if (degree eq 4) then begin
;
; m=-4
		peak([0,1],0)=[1,-4]
;
; m=-3
		peak([0,1],1)=[1,-3]
;
; m=-2
		peak([0,1,2,3],2)=[3,-2,0,2]
;
; m=-1
		peak([0,1,2],3)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],4)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],5)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],6)=[3,2,-2,0]
;
; m=+3
		peak([0,1],7)=[1,3]
;
; m=+4
		peak([0,1],8)=[1,4]

;
	endif
; *********************************************
; **************For l=5***********************
	
	if (degree eq 5) then begin
;
; m=-5
		peak([0,1,2],0)=[2,-5,5]
;
; m=-4
		peak([0,1,2],1)=[2,-4,2]
;
; m=-3
		peak([0,1,2],2)=[2,-3,3]
;
; m=-2
		peak([0,1,2],3)=[2,-2,0]
;
; m=-1 
		peak([0,1],4)=[1,-1]
;
; m=0
		peak([0,1,2,3],5)=[3,0,-2,2]
;
; m=+1 
		peak([0,1],6)=[1,1]
;
; m=+2
		peak([0,1,2],7)=[2,2,0]
;
; m=+3
		peak([0,1,2],8)=[2,3,-3]
;
; m=+4
		peak([0,1,2],9)=[2,4,-2]
;
; m=+5
		peak([0,1,2],10)=[2,5,-5]

;
	endif
end


pro peakBISON,degree
; peak is a common array that gives the amplitude distribution 
; in a multiplet
;
	common multiplet,peak
	if (degree GT 3) then begin
		print,'Please provide the amplitude distribution for the degree greater or equal to 4...you will now get rubbish...'
	endif
	N=2*degree+1
;
	peak=dblarr(N)
	peak(0)=1.

;
; ***************For l=1**********************
;
	if (degree eq 1) then begin
;
; m=-1	
		peak(0)=alog(1.)
;
; m=0
		peak(1)=-10000.d0
;
; m=+1
		peak(2)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree eq 2) then begin
;
; m=-2
		peak(0)=alog(1.)
;
; m=-1

		peak(1)=-10000.d0
;
; m=0
		peak(2)=alog(0.41)
;
; m=+1
		peak(3)=-10000.d0
;
; m=+2
		peak(4)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree eq 3) then begin
;
; m=-3
		peak(0)=alog(1.)

;
; m=-2
		peak(1)=-10000.d0
;
; m=-1
		peak(2)=alog(0.19)
;
; m=0
		peak(3)=-10000.d0
;
; m=+1
		peak(4)=alog(0.19)
;
; m=+2
		peak(5)=-10000.d0
;
; m=+3
		peak(6)=alog(1.)
;
	endif
end



pro peakSIMU,degree
; peak is a common array that gives the amplitude distribution 
; in a multiplet
;
	common multiplet,peak
	if (degree GT 3) then begin
		print,'Please provide the amplitude distribution for the degree greater or equal to 4...you will now get rubbish...'
	endif
	N=2*degree+1
;
	peak=dblarr(N)
	peak(0)=1.

;
; ***************For l=1**********************
;
	if (degree eq 1) then begin
;
; m=-1	
		peak(0)=alog(1.)
;
; m=0
		peak(1)=-10000.d0
;
; m=+1
		peak(2)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree eq 2) then begin
;
; m=-2
		peak(0)=alog(1.)
;
; m=-1

		peak(1)=-10000.d0
;
; m=0
		peak(2)=alog(1.)
;
; m=+1
		peak(3)=-10000.d0
;
; m=+2
		peak(4)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree eq 3) then begin
;
; m=-3
		peak(0)=alog(1.)

;
; m=-2
		peak(1)=-10000.d0
;
; m=-1
		peak(2)=alog(1.0)
;
; m=0
		peak(3)=-10000.d0
;
; m=+1
		peak(4)=alog(1.0)
;
; m=+2
		peak(5)=-10000.d0
;
; m=+3
		peak(6)=alog(1.)
;
	endif
; *********************************************
; **************For l=4***********************
	
	if (degree eq 4) then begin
;
; m=-4
		peak([0,1],0)=[1,-4]
;
; m=-3
		peak([0,1],1)=[1,-3]
;
; m=-2
		peak([0,1,2,3],2)=[3,-2,0,2]
;
; m=-1
		peak([0,1,2],3)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],4)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],5)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],6)=[3,2,-2,0]
;
; m=+3
		peak([0,1],7)=[1,3]
;
; m=+4
		peak([0,1],8)=[1,4]

;
	endif
; *********************************************
; **************For l=5***********************
	
	if (degree eq 5) then begin
;
; m=-5
		peak([0,1,2],0)=[2,-5,5]
;
; m=-4
		peak([0,1,2],1)=[2,-4,2]
;
; m=-3
		peak([0,1,2],2)=[2,-3,3]
;
; m=-2
		peak([0,1,2],3)=[2,-2,0]
;
; m=-1 
		peak([0,1],4)=[1,-1]
;
; m=0
		peak([0,1,2,3],5)=[3,0,-2,2]
;
; m=+1 
		peak([0,1],6)=[1,1]
;
; m=+2
		peak([0,1,2],7)=[2,2,0]
;
; m=+3
		peak([0,1,2],8)=[2,3,-3]
;
; m=+4
		peak([0,1,2],9)=[2,4,-2]
;
; m=+5
		peak([0,1,2],10)=[2,5,-5]

;
	endif
end


pro peakIRIS,degree
; peak is a common array that gives the amplitude distribution 
; in a multiplet
;
	common multiplet,peak
	if (degree GT 3) then begin
		print,'Please provide the amplitude distribution for the degree greater or equal to 4...you will now get rubbish...'
	endif
	N=2*degree+1
;
	peak=dblarr(N)
	peak(0)=1.

;
; ***************For l=1**********************
;
	if (degree eq 1) then begin
;
; m=-1	
		peak(0)=alog(1.)
;
; m=0
		peak(1)=-10000.d0
;
; m=+1
		peak(2)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree eq 2) then begin
;
; m=-2
		peak(0)=alog(1.)
;
; m=-1

		peak(1)=-10000.d0
;
; m=0
		peak(2)=alog(1./1.25)
;
; m=+1
		peak(3)=-10000.d0
;
; m=+2
		peak(4)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree eq 3) then begin
;
; m=-3
		peak(0)=alog(1.)

;
; m=-2
		peak(1)=-10000.d0
;
; m=-1
		peak(2)=alog(1.0/1.25)
;
; m=0
		peak(3)=-10000.d0
;
; m=+1
		peak(4)=alog(1.0/1.25)
;
; m=+2
		peak(5)=-10000.d0
;
; m=+3
		peak(6)=alog(1.)
;
	endif
; *********************************************
; **************For l=4***********************
	
	if (degree eq 4) then begin
;
; m=-4
		peak([0,1],0)=[1,-4]
;
; m=-3
		peak([0,1],1)=[1,-3]
;
; m=-2
		peak([0,1,2,3],2)=[3,-2,0,2]
;
; m=-1
		peak([0,1,2],3)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],4)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],5)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],6)=[3,2,-2,0]
;
; m=+3
		peak([0,1],7)=[1,3]
;
; m=+4
		peak([0,1],8)=[1,4]

;
	endif
; *********************************************
; **************For l=5***********************
	
	if (degree eq 5) then begin
;
; m=-5
		peak([0,1,2],0)=[2,-5,5]
;
; m=-4
		peak([0,1,2],1)=[2,-4,2]
;
; m=-3
		peak([0,1,2],2)=[2,-3,3]
;
; m=-2
		peak([0,1,2],3)=[2,-2,0]
;
; m=-1 
		peak([0,1],4)=[1,-1]
;
; m=0
		peak([0,1,2,3],5)=[3,0,-2,2]
;
; m=+1 
		peak([0,1],6)=[1,1]
;
; m=+2
		peak([0,1,2],7)=[2,2,0]
;
; m=+3
		peak([0,1,2],8)=[2,3,-3]
;
; m=+4
		peak([0,1,2],9)=[2,4,-2]
;
; m=+5
		peak([0,1,2],10)=[2,5,-5]

;
	endif
end




pro peakgmodes,degree,m
; peak is a common array that gives the amplitude distribution 
; in a multiplet
;
	common multiplet,peak
	if (degree GT 2) then begin
		print,'Please provide the amplitude distribution for the degree greater or equal to 3...you will now get rubbish...'
	endif
	N=2*degree+1
;
	peak=dblarr(N,degree)
	peak(0)=1.
;
; ***************For l=1**********************
;
	if (degree GE 1) then begin
;
; m=-1	
		peak(0,0)=-10000.d0
;
; m=0
		peak(1,0)=-10000.d0
;
; m=+1
		peak(2,0)=-10000.d0

		peak(m+1,0)=alog(1.)

		
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree GE 2) then begin
;
; m=-2
		peak(0,1)=alog(1.)
;
; m=-1

		peak(1,1)=-10000.d0
;
; m=0
		peak(2,1)=alog(0.65)
;
; m=+1
		peak(3,1)=-10000.d0
;
; m=+2
		peak(4,1)=alog(1.)
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree GE 3) then begin
;
; m=-3
		peak(0,2)=alog(1.)

;
; m=-2
		peak(1,2)=-10000.d0
;
; m=-1
		peak(2,2)=alog(1.)
;
; m=0
		peak(3,2)=-10000.d0
;
; m=+1
		peak(4,2)=alog(1.)
;
; m=+2
		peak(5,2)=-10000.d0
;
; m=+3
		peak(6,2)=alog(1.)
;
	endif
; *********************************************
; **************For l=4***********************
	
	if (degree eq 40) then begin
;
; m=-4
		peak([0,1],0)=[1,-4]
;
; m=-3
		peak([0,1],1)=[1,-3]
;
; m=-2
		peak([0,1,2,3],2)=[3,-2,0,2]
;
; m=-1
		peak([0,1,2],3)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],4)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],5)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],6)=[3,2,-2,0]
;
; m=+3
		peak([0,1],7)=[1,3]
;
; m=+4
		peak([0,1],8)=[1,4]

;
	endif
; *********************************************
; **************For l=5***********************
	
	if (degree eq 50) then begin
;
; m=-5
		peak([0,1,2],0)=[2,-5,5]
;
; m=-4
		peak([0,1,2],1)=[2,-4,2]
;
; m=-3
		peak([0,1,2],2)=[2,-3,3]
;
; m=-2
		peak([0,1,2],3)=[2,-2,0]
;
; m=-1 
		peak([0,1],4)=[1,-1]
;
; m=0
		peak([0,1,2,3],5)=[3,0,-2,2]
;
; m=+1 
		peak([0,1],6)=[1,1]
;
; m=+2
		peak([0,1,2],7)=[2,2,0]
;
; m=+3
		peak([0,1,2],8)=[2,3,-3]
;
; m=+4
		peak([0,1,2],9)=[2,4,-2]
;
; m=+5
		peak([0,1,2],10)=[2,5,-5]

;
	endif
end


pro peakGONG,degree,index
;------------------------------------------------------------------------------
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;	Beta 2: Add crosstalk for l=5, m=+/-1, June, 2, 1995
;------------------------------------------------------------------------------
; peak is a common array that gives:
; on the first column the number of modes in an m spectrum
; on the subsequent columns the m's that have to included in
; the summation
;
; Example:
;	1 -5  0 0 0 0  (For m=-5, 1 peak at m=-5)
;       2 -4 -3 0 0 0  (For m=-3, 2 peaks at m=-4, m=-3)
;       0  0  0 0 0 0  (For m=-2, 0 peak) 
;       etc ...
; 
; Its dimension is (N+1,N)
;
	common multiplet,peak
	common cross,crossparam

	N=2*degree+1
;
	peak=dblarr(N+1,N)
;
; ***************For l=1**********************
;
	if (degree eq 1) then begin
;
; m=-1	
		peak([0,1,2],0)=[2,-1,1]
;
; m=0
		peak([0,1],1)=[1,0]
;
; m=+1
		peak([0,1,2],2)=[2,1,-1]
;
	endif
; ********************************************
;
; **************For l=2***********************
	
	if (degree eq 2) then begin
;
; m=-2
		peak([0,1,2,3],0)=[3,-2,0,2]
;
; m=-1

		peak([0,1,2],1)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],2)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],3)=[2,1,-1]
;
; m=+2
		peak([0,1,2,3],4)=[3,2,-2,0]
;
	endif
; ********************************************
;
; **************For l=3***********************
	
	if (degree eq 3) then begin
;
; m=-3
		peak([0,1,2],0)=[2,-3,-1]

;
; m=-2
		peak([0,1,2],1)=[2,-2,0]
;
; m=-1
		peak([0,1,2],2)=[2,-1,1]
;
; m=0
		peak([0,1,2,3],3)=[3,0,-2,2]
;
; m=+1
		peak([0,1,2],4)=[2,1,-1]
;
; m=+2
		peak([0,1,2],5)=[2,2,0]
;
; m=+3
		peak([0,1,2],6)=[2,3,1]
;
	endif
; *********************************************
; **************For l=4***********************
	
	if (degree eq 4) then begin
;
; m=-4
		peak([0,1,2,3,4,5],0)=[5,-4,-2,0,2,4]
;
; m=-3
		peak([0,1,2,3,4],1)=[4,-3,-1,1,3]
;
; m=-2
		peak([0,1,2,3,4,5],2)=[5,-2,-4,0,2,4]
;
; m=-1
		peak([0,1,2,3,4],3)=[4,-1,-3,1,3]
;
; m=0
		peak([0,1,2,3,4,5],4)=[5,0,-4,-2,2,4]
;
; m=+1
		peak([0,1,2,3,4],5)=[4,1,-3,-1,3]
;
; m=+2
		peak([0,1,2,3,4,5],6)=[5,2,-4,-2,0,4]
;
; m=+3
		peak([0,1,2,3,4],7)=[4,3,-3,-1,1]
;
; m=+4
		peak([0,1,2,3,4,5],8)=[5,4,-4,-2,0,2]

;
	endif
; *********************************************
; **************For l=5***********************
	
	if (degree eq 5) then begin
;
; m=-5
		peak([0,1,2],0)=[2,-5,5]
;
; m=-4
		peak([0,1,2],1)=[2,-4,2]
;
; m=-3
		peak([0,1,2],2)=[2,-3,3]
;
; m=-2
		peak([0,1,2],3)=[2,-2,0]
;
; m=-1 
		peak([0,1,2,3,4],4)=[4,-1,-3,1,3]
;
; m=0
		peak([0,1,2,3],5)=[3,0,-2,2]
;
; m=+1 
		peak([0,1,2,3,4],6)=[4,1,-3,-1,3]
;
; m=+2
		peak([0,1,2],7)=[2,2,0]
;
; m=+3
		peak([0,1,2],8)=[2,3,-3]
;
; m=+4
		peak([0,1,2],9)=[2,4,-2]
;
; m=+5
		peak([0,1,2],10)=[2,5,-5]

;
	endif
; *********************************************
;
;
; Here we decode peak for getting the number of crosstalk parameters
;
	cindex=0
; decode only for 1<=m<=l
; par symmetry the crosstalk parameters are the same
	for m=1,degree do begin
		cindex=cindex+peak(0,m+degree)-1
	endfor
; add the cindex for m=0
	cindex=cindex+(peak(0,degree)-1)/2
	index=cindex	
;
; Here a crosstalk matrix with the index of the crosstalk 
; parameters for given couple of (m,m') mode
	crossparam=dblarr(N,N)
	cstart=2*N+3
	for m=0,degree-1 do begin
		for i=0,peak(0,m)-2 do begin
			mp=peak(2+i,m)+degree
			crossparam(m,mp)=cstart
			crossparam(N-1-m,N-1-mp)=cstart
			cstart=cstart+1
		endfor
	endfor	
	m=degree
	for i=0,(peak(0,m)-3)/2 do begin
		mp=peak(2+i,m)+degree
		crossparam(m,mp)=cstart
		crossparam(N-1-m,N-1-mp)=cstart
		cstart=cstart+1
	endfor
end


;************************************************
; Compute theoretical profile for a superposition
; of degree 0 and 2
;************************************************

Function spectraSPM,paramSPM,x
	common alias,ampli
	common multiplet,peak
	common speed,Neval
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
;
; Compute l=2 spectra
;
;
	paramline=dblarr(7)
;
	paramline(6)=ampli
	paramline(2)=paramSPM(4)

; Here we put the noise at 0
	paramline(4)=-10000.d0

	y=0d0
	l=2
	ik=0
	for i=0,4 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(0)=paramSPM(ik)
			
			paramline(5)=peak(i)
			paramline(1)=paramSPM(3)+m*paramSPM(5)
			y=y+lorentzian(paramline,x)
			ik=ik+1
		endif
	endfor
;
; Compute l=0 spectra
;
	paramline(0:1)=paramSPM(7:8)

; Here we put the noise at 0 (again)
	paramline(4)=-10000.d0

	paramline(5)=0.d0
	y=y+lorentzian(paramline,x)



; The noise is added here only
	Neval=Neval+1
	return,y+exp(paramSPM(6))
end

;************************************************




;************************************************
; Compute theoretical profile for a given l for
; LOI and MDI
;************************************************

pro spectralphase02,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	spectralphase,param,ampli,x,yout
; PURPOSE:
;	Compute the profiles of an LOI,MDI diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, 2*l+1 noise,
;			 crosstalk)
;	ampli		give the amplitude of the alias at 11.57 microHz
;	x 		frequency of the points centered on zero (Npoints)
;	yout 		power spectra (Npoints, 2*degree+1)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	m,nu diagram of a given degree
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	definepeak,degree,peak,crossparam,cindex
;	N=2*degree+1
;	Nparam=3+2*N+cindex
;	param=dblarr(Nparam)
;	error=dblarr(Nparam)
;   
;   of course define xdata,param before calling the routine	
;	spectraltene,param,ampli,xdata,y
; LIMITATIONS:
;	Not portable enough. You need to call definepeak.pro before calling this routine
;	and to know the structure of your crosstalk.
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine definepeak.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, November 13, 1996
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)

	yout=dblarr(Npoints,2)
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,splitting,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum

	paramline=dblarr(7)
;
; Start with LOI l=2
;
;
; param=(amplitudeloi,frequency,linewidth,splitting,noiseloi)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:3)=param(0:3)

	paramline(6)=0.

; Here we put the noise at 0
	paramline(4)=-10000.d0

	l=(N-1)/2
	for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param(1)+m*param(3)
			yout(*,0)=yout(*,0)+lorentzian(paramline,x)
		endif
	endfor


;
; Continue with MDI l=2
;
;
	paramline(0)=param(5)
;	
	for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param(1)+m*param(3)
			yout(*,1)=yout(*,1)+lorentzian(paramline,x)
		endif
	endfor
;
; Now with LOI l=0
;
	paramline(0:1)=param(7:8)
	paramline(3)=0.

	yout(*,0)=yout(*,0)+lorentzian(paramline,x)

;
; Now with MDI l=0

	paramline(0)=param(9)

	yout(*,1)=yout(*,1)+lorentzian(paramline,x)


; The noise is added here only


	yout(*,0)=yout(*,0)+exp(param(4))


	yout(*,1)=yout(*,1)+exp(param(6))



	Neval=Neval+1

end

pro spectralphase1,param,x,yout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	spectralphase,param,ampli,x,yout
; PURPOSE:
;	Compute the profiles of an LOI,MDI diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, 2*l+1 noise,
;			 crosstalk)
;	ampli		give the amplitude of the alias at 11.57 microHz
;	x 		frequency of the points centered on zero (Npoints)
;	yout 		power spectra (Npoints, 2*degree+1)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	m,nu diagram of a given degree
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	definepeak,degree,peak,crossparam,cindex
;	N=2*degree+1
;	Nparam=3+2*N+cindex
;	param=dblarr(Nparam)
;	error=dblarr(Nparam)
;   
;   of course define xdata,param before calling the routine	
;	spectraltene,param,ampli,xdata,y
; LIMITATIONS:
;	Not portable enough. You need to call definepeak.pro before calling this routine
;	and to know the structure of your crosstalk.
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine definepeak.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, November 13, 1996
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)

	yout=dblarr(Npoints,2)
;
; This computes the idealized spectrum
;
; param=(amplitude,frequency,linewidth,noise)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum

	paramline=dblarr(7)
;
; Start with LOI l=2
;
;
; param=(amplitudeloi,frequency,linewidth,splitting,noiseloi)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:2)=param(0:2)

	paramline(6)=0.

; Here we put the noise at 0
	paramline(4)=-10000.d0

	paramline(5)=0.

	yout(*,0)=lorentzian(paramline,x)
;
; Continue with MDI l=2
;
;
	paramline(0)=param(4)
	yout(*,1)=lorentzian(paramline,x)

; The noise is added here only


	yout(*,0)=yout(*,0)+exp(param(3))


	yout(*,1)=yout(*,1)+exp(param(5))



	Neval=Neval+1

end



pro crosstalkphase1,param,x,Cout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	crosstalk 
; CALLING SEQUENCE:
;	crosstalk,param,xdata,Cout
; PURPOSE:
;	Compute the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, l+1 noise,
;			 crosstalkmode,crosstalknoise)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode and noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is also the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine peakLOI.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, November, 13, 1996
;	Beta 2: Add phase for the noise, March 11, 1997
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)

	Cout=dblarr(4,4,Npoints)


	paramline=dblarr(7)

	yout=dblarr(Npoints)

;
; Start with general profile
;
;
; param=(amplitudeloi,frequency,linewidth,noiseloi)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:2)=param(0:2)
	paramline(0)=0.

	paramline(6)=0.

; Here we put the noise at 0
	paramline(4)=-10000.d0

	paramline(5)=0.

	yout=lorentzian(paramline,x)

;
; Continue with MDI
;
;

; The noise is added here only



; between LOI r,i and LOI r,i

	Cout(0,0,*)=yout*exp(param(0))+exp(param(3))
	Cout(1,1,*)=Cout(0,0,*)


; between MDI r,i and MDI r,i
	
	Cout(2,2,*)=yout*exp(param(4))+exp(param(5))
	Cout(3,3,*)=Cout(2,2,*)


; between LOI r and MDI r

	Cout(0,2,*)=yout*sqrt(  exp(param(0))*exp(param(4))    )*cos(param(6))
	Cout(2,0,*)=Cout(0,2,*)

; between LOI r and MDI i

	Cout(0,3,*)=-yout*sqrt(exp(param(0))*exp(param(4)))*sin(param(6))
	Cout(3,0,*)=Cout(0,3,*)

; between LOI i and MDI r

	Cout(1,2,*)=-Cout(0,3,*)
	Cout(2,1,*)=Cout(1,2,*)

; between LOI i and MDI i
	
	Cout(1,3,*)=Cout(0,2,*)
	Cout(3,1,*)=Cout(1,3,*)
	
	
	Neval=Neval+1
end




pro crosstalkphase02,param,x,Cout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	crosstalk 
; CALLING SEQUENCE:
;	crosstalk,param,xdata,Cout
; PURPOSE:
;	Compute the covariance matrix of the m,nu diagram
; INPUTS:
;	param		input parameters in the following order
;			(frequency,splitting,linewidth,2*l+1 amplitudes, l+1 noise,
;			 crosstalkmode,crosstalknoise)
;	x 		frequency of the points centered on zero (Npoints)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	Cout 		Covariance matrix of the mode and noise
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;
; LIMITATIONS:
;	Here the crosstalk is assumed to be real (and signed).
;	It is the same for both the real and imaginary.
;	It is also the same for the signal and the noise
; COMMONS:
;	These many commons are needed to minimize the number of commons in the likelihood functions
;	
;	crossparam	It is a common array of (2*degree+1,2*degree+1) giving the index of the
;			crosstalk in param.  The crossparam array is to be created by
;			calling the routine peakLOI.pro
; 	peak 		It is a common array that gives on the first column the number of modes 
;			in an m spectrum on the subsequent columns the m's that have to included in
; 			the summation
; 	Neval 		for knowing how many times this procedure is called
; PROCEDURES USED:
;       
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, November, 13, 1996
;	Beta 2: Add phase for the noise, March 11, 1997
;------------------------------------------------------------------------------

	common multiplet,peak
	common cross,crossparam
	common speed,Neval
	common alias,ampli
	Npoints=N_elements(x)

	Cout=dblarr(4,4,Npoints)


	paramline=dblarr(7)

	yout2=dblarr(Npoints)
	yout0=dblarr(Npoints)

;
; Start with general profile
;
;
; param=(amplitudeloi,frequency,linewidth,splitting,noiseloi)
; peak represents the amplitude ratio of the lines
; N is the number of modes (max=2l+1) in a spectrum
	N=N_elements(peak)
	paramline=dblarr(7)

	paramline(0:3)=param(0:3)
	paramline(0)=0.

	paramline(6)=0.

; Here we put the noise at 0
	paramline(4)=-10000.d0

	l=(N-1)/2
	for i=0,N-1 do begin
		m=i-l
		if (peak(i) NE -10000.d0) then begin
			paramline(5)=peak(i)
			paramline(1)=param(1)+m*param(3)
			yout2=yout2+lorentzian(paramline,x)
		endif
	endfor


;
; Continue with l=0
;
;
	paramline(1)=param(8)
	paramline(3)=0.

	yout0=lorentzian(paramline,x)	


; The noise is added here only



; between LOI r,i and LOI r,i

	Cout(0,0,*)=yout2*exp(param(0))+yout0*exp(param(7))+exp(param(4))
	Cout(1,1,*)=Cout(0,0,*)


; between MDI r,i and MDI r,i
	
	Cout(2,2,*)=yout2*exp(param(5))+yout0*exp(param(9))+exp(param(6))
	Cout(3,3,*)=Cout(2,2,*)


; between LOI r and MDI r

	Cout(0,2,*)=yout2*sqrt(exp(param(0))*exp(param(5)))*cos(param(10))+yout0*sqrt(exp(param(7))*exp(param(9)))*cos(param(11))
	Cout(2,0,*)=Cout(0,2,*)

; between LOI r and MDI i

	Cout(0,3,*)=-yout2*sqrt(exp(param(0))*exp(param(5)))*sin(param(10))-yout0*sqrt(exp(param(7))*exp(param(9)))*sin(param(11))
	Cout(3,0,*)=Cout(0,3,*)

; between LOI i and MDI r

	Cout(1,2,*)=-Cout(0,3,*)
	Cout(2,1,*)=Cout(1,2,*)

; between LOI i and MDI i
	
	Cout(1,3,*)=Cout(0,2,*)
	Cout(3,1,*)=Cout(1,3,*)
	
	
	Neval=Neval+1
end

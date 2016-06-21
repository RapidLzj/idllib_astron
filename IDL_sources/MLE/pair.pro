;*******************************************************
; This is a demonstration program for fitting a 0-2 pair
; in an IPHIR spectrum
;
;
; degree	the degree of the multiplet
; wild 		string wild card for your file name
; istart	where to start the fit: 0 for Cen(0,degree)
; tol		tolerance for Powell, on a Sparc20 1d-08 is OK.
;		you may want to put a smaller value for a slower machine...
; printer	string to which you want your output. An empty string put the
;		output on your monitor
;
;
;*******************************************************
;
pro pair,wild,istart,tol,printer
	nn=N_params()
	if (nn LT 4) then begin
		print,''
		if (nn EQ 0) then begin
			wild=''
		  	read,'give the wid card of your file as a string= ',wild
			print,''
			nn=nn+1
		endif
		if (nn EQ 1) then begin
		     	read,'give the starting point for the fit= ',istart
			print,''
			istart=floor(istart)
			nn=nn+1
		endif
		if (nn EQ 2) then begin
		        read,'give tolerance for the Powell algorithm (1d-08 works well on a Sparc20...)= ',tol
			print,''
			nn=nn+1
		endif
		if (nn EQ 3) then begin
			printer=''
		        read,'give the printer output as a string (press return to redirect to your monitor)=',printer
		endif
        endif

;
;
; Reading the file ADAPT that to your own
;
;
	common alias,ampli
	i=0
	resol=1000000./336000./41.116727
	xxdata=27631.*resol+findgen(30000)*resol
	spectrum=dblarr(30000)
	openr,1,'IPHIR/'+wild+'.dat'
	while (not eof(1)) do begin
		readf,1,a,b,c,d,e,f,g,h,j,k
		spectrum(i)=a
		spectrum(i+1)=b
		spectrum(i+2)=c
		spectrum(i+3)=d
		spectrum(i+4)=e
		spectrum(i+5)=f
		spectrum(i+6)=g
		spectrum(i+7)=h
		spectrum(i+8)=j
		spectrum(i+9)=k
		i=i+10
	endwhile
	close,1
;
; Number of points. ADAPT to your own if needed
;
	Npoints=800
	ydata=dblarr(Npoints)
	central=dblarr(5,9)
; 	
	Central=[[2228,2362,2496,2629,2764,2898,3034,3169,3303],$
		 [2292.,2425.,2559.,2693.,2828.,2963.,3098.,3233.,3369.],$
		 [2352.34,2486.18,2619.61,2754.30,2889.35,3024.76,3160.16,3295.00,3430.77],$
		 [2408.11,2541.69,2676.03,2811.39,2947.01,3082.39,3217.82,3354.17,3489.78],$
		 [2458.34,2593.01,2728.66,2864.30,3000.14,3135.85,3271.52,3408.29,3544.29],$
		 [2506.18,2641.54,2777.33,2913.37,3049.78,3186.32,3322.71,3458.,3594.]]

	for i=istart,7 do begin
		Cen=(Central(i,2)+Central(i+1,0))/2.
;
; ADAPT the following statetment to your own
;
		Nstart=floor((Cen-2000)/resol)
;
;  ADAPT the following statetment to your own
;
		Freqstart=Nstart*resol+2000
		print,"*******************************************"
		print,""
		print,"Frequency of starting points=",Freqstart
		print,""
		print,"*******************************************"
;
;
;	
		window=Npoints*resol
		print,"Window size=",window
;
;  ADAPT the following statetment to your own
;
		ydata(0:Npoints-1)=spectrum(Nstart-Npoints/2:Nstart+Npoints/2-1)
;
;compute window
		xdata=(dindgen(Npoints)-Npoints/2)*resol
;
; Starting parameters.  ADAPT the following statetments to your own
;
		peakIPHIR,2
		param02=dblarr(7)
		error=dblarr(7)
		param02(0)=alog(1.)
		param02(1)=-5.
		param02(2)=alog(1.)
		param02(3)=0.4
		param02(4)=alog(0.1)
		param02(5)=alog(1.)
		param02(6)=+5.
		ampli=0.

	

		fitplotsingle,xdata,ydata,'spectra02',param02,error,tol,Freqstart,'IPHIR '+wild,printer

		
		param=param02

		print, "For l=2"
		print,"Frequency =",Freqstart+param(1),"+/-",error(1)
	
		print,""
		error1=exp(param(0)+error(0))-exp(param(0))
		error2=-exp(param(0)-error(0))+exp(param(0))
		print,"Amplitude=",exp(param(0)),"+",error1," -",error2



		print,""
		print,"For l=0"
		print,"Frequency =",Freqstart+param(6),"+/-",error(6)
	
		print,""
		error1=exp(param(5)+error(5))-exp(param(5))
		error2=-exp(param(5)-error(5))+exp(param(5))
		print,"Amplitude=",exp(param(5)),"+",error1," -",error2



		print,""
		error1=exp(param(2)+error(2))-exp(param(2))
		error2=-exp(param(2)-error(2))+exp(param(2))
		print,"Linewidth=",exp(param(2)),"+",error1," -",error2

		print,""
		print,"Splitting=",param(3),"+/-",error(3)
		print,""

		print,""
		error1=exp(param(4)+error(4))-exp(param(4))
		error2=-exp(param(4)-error(4))+exp(param(4))
		print,"Noise=",exp(param(4)),"+",error1," -",error2




	endfor
	
end









;*******************************************************
; This is a demonstration program for 0-2 pair of mode
; in a single spectrum
;
; The user is asked to provide
;
; A0,A2 amplitude, B0,B2 frequency, C linewidth, D splitting
; E noise, for the mode 
;
; and the degree
;
;*******************************************************
pro simu02,A2,B2,C,D,E,A0,B0
	nn=N_params()
	if (nn LT 7) then begin
		print,''
		if (nn EQ 0) then begin
			read,'give the amplitude of the l=2 mode= ',A2
			print,''
			nn=nn+1
		endif
		if (nn EQ 1) then begin
		  	read,'give the frequency of the l=2 mode= ',B2
			print,''
			nn=nn+1
		endif
		if (nn EQ 2) then begin
		     	read,'give the linewidth of the modes= ',C
			print,''
			nn=nn+1
		endif
		if (nn EQ 3) then begin
		        read,'give the splitting of the l=2 mode= ',D
			print,''
			nn=nn+1
		endif
		if (nn EQ 4) then begin
			printer=''
		        read,'give the background noise= ',E
			print,''
			nn=nn+1
		endif
		if (nn EQ 5) then begin
			read,'give the amplitude of the l=0 mode= ',A0
			print,''
			nn=nn+1
		endif
		if (nn EQ 6) then begin
		  	read,'give the frequency of the l=0 mode= ',B0
			print,''
			nn=nn+1
		endif
        endif

	Nparam=7
	param02=dblarr(Nparam)
	error=dblarr(Nparam)
	common data,xdata,ydata
	common multiplet,peak
	common alias,ampli
;
;compute window
	xdata=(dindgen(400)-200)*7d-02
;
;define line profile
	peakIPHIR,2
	param02(0)=alog(A2)
	param02(1)=B2
	param02(2)=alog(C)
	param02(3)=D
	param02(4)=alog(E)
	param02(5)=alog(A0)
	param02(6)=B0

	y=spectra02(param02,xdata)
;randomize test profile

	ydata=y*(randomn(seed,400)^2+randomn(seed,400)^2)/2.
	
	ampli=0.
	Freqstart=0.
	tol=0.00000001

	fitplotsingle,xdata,ydata,'spectra02',param02,error,tol,Freqstart,'Monte-carlo',''

		
	param=param02

	print, "For l=2"
	print,"Frequency =",param(1),"+/-",error(1)
	
	print,""
	error1=exp(param(0)+error(0))-exp(param(0))
	error2=-exp(param(0)-error(0))+exp(param(0))
	print,"Amplitude=",exp(param(0)),"+",error1," -",error2



	print,""
	print,"For l=0"
	print,"Frequency =",param(6),"+/-",error(6)
	
	print,""
	error1=exp(param(5)+error(5))-exp(param(5))
	error2=-exp(param(5)-error(5))+exp(param(5))
	print,"Amplitude=",exp(param(5)),"+",error1," -",error2



	print,""
	error1=exp(param(2)+error(2))-exp(param(2))
	error2=-exp(param(2)-error(2))+exp(param(2))
	print,"Linewidth=",exp(param(2)),"+",error1," -",error2

	print,""
	print,"Splitting=",param(3),"+/-",error(3)
	print,""

	print,""
	error1=exp(param(4)+error(4))-exp(param(4))
	error2=-exp(param(4)-error(4))+exp(param(4))
	print,"Noise=",exp(param(4)),"+",error1," -",error2

	
end

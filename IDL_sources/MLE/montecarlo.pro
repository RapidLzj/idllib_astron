pro montecarlo,degree,iterations,theta
        common crosstalk,ctnm1
        common matbruit,croiseen
	common speed,Neval
        common nb_bruit, nbbruit


	nn=N_params()
	if (nn LT 3) then begin
		print,''
		if (nn EQ 0) then begin
			read,'give the degree of the mode= ',degree
			print,''
			nn=nn+1
		endif
		if (nn EQ 1) then begin
		  	read,'give the number of iterations= ',iterations
			print,''
			nn=nn+1
		endif
		if (nn EQ 2) then begin
		  	read,'give the theta angle (or B angle) in radians= ',theta
			print,''
			nn=nn+1
		endif
        endif

	if (degree gt 3) then begin
		print,'We are so lazy that we stop fitting for degree gt than 3 :)'
		stop
	endif

;  montecarlo simulations

	phi=0.
       
	pi=4.d0*atan(1.d0)

	tol=0.000001
	
	nbbruit=3

	N=2*degree+1

	nom=strarr(10)

	nom(6)='/home/thierrya/SOHOlm/fmean_hdr.dat'


;----------------------------------lit les coefficients  u + i v
	u=dblarr(12,10,20)
	v=dblarr(12,10,20)	
	openr,1,nom(6)
	for il=0,degree do begin
             for im=0,il do begin
                  readf,1,c,d
                  for ipix=0,11 do begin
      		      readf,1,a,b
                      u(ipix,il,im+il)=a
                      v(ipix,il,im+il)=b   
                      u(ipix,il,-im+il)=a
                      v(ipix,il,-im+il)=-b
                  endfor
             endfor
        endfor
	close,1


;----------------------------------lit les coefficients  u + i v optimaux
	uo=dblarr(12,10,20)
	vo=dblarr(12,10,20)	
	openr,1,nom(6)
	for il=0,degree do begin
             for im=0,il do begin
                  readf,1,c,d
                  for ipix=0,11 do begin
      		      readf,1,a,b
                      uo(ipix,il,im+il)=a
                      vo(ipix,il,im+il)=b   
                      uo(ipix,il,-im+il)=a
                      vo(ipix,il,-im+il)=-b
                  endfor
             endfor
        endfor
	close,1


;-------------------------------------matrice de crosstalk non-tournee:
	ctnm1=dblarr(2*degree+1,2*degree+1)
;	for m0=0,2*degree do begin
;    		for mm=0,2*degree do begin
;        		for ipix=0,11 do begin
;           			ctnm1(m0,mm) = ctnm1(m0,mm) + uo(ipix,degree,m0)*u(ipix,degree,mm) + vo(ipix,degree,m0)*v(ipix,degree,mm)
;        		endfor	
;    		endfor
;	endfor

	if (degree eq 1) then begin
		ctnm1=[[1.0000000,0.0000000,0.47440148],$
       		       [0.0000000,1.0000000,0.0000000],$
      		       [0.47440148,0.0000000,1.0000000]]
	endif


	if (degree eq 2) then begin
		ctnm1=     [[1.0000000,0.0000000,-0.30791966,0.0000000,-0.21587904],$
       			    [0.0000000,1.0000000,0.0000000,0.57568890,0.0000000],$
     			    [-0.30791966,0.0000000,1.000000,0.0000000,-0.30791966],$
       			    [0.0000000,0.57568890,0.0000000,1.0000000,0.0000000],$
     			    [-0.21587904,0.0000000,-0.30791966,0.0000000,1.000000]]
	endif

	if (degree eq 3) then begin
		ctnm1=     [[0.99999999,0.0000000,-0.19631255,0.0000000,0.12230649,0.0000000,-0.0044199663],$
       			    [0.0000000,0.99999996,0.0000000,0.46915087,0.0000000,-0.19569330,0.0000000],$
     			    [-0.19631255,0.0000000,1.0000000,0.0000000,0.54446038,0.0000000,0.12230649],$
       			    [0.0000000,0.46915087,0.0000000,0.99999999,0.0000000,0.46915087,0.0000000],$
		            [0.12230649,0.0000000,0.54446038,0.0000000,1.0000000,0.0000000,-0.19631255],$
       			    [0.0000000,-0.19569330,0.0000000,0.46915087,0.0000000,0.99999996,0.0000000],$
   			    [-0.0044199663,0.0000000,0.12230649,0.0000000,-0.19631255,0.000000,0.99999999]]

	endif



	print,ctnm1

	


 ;------------------matrices de bruit, symetries est/ouest et nord/sud
croiseen=dblarr(3,2*degree+1,2*degree+1)


;	for p=0,2 do begin
;		for m0=0,2*degree do begin
;    			for mm0=0,2*degree do begin
;        			for pix=4*p,4*p+3 do begin
;              				croiseen(p,m0,mm0) = croiseen(p,m0,mm0) + uo(pix,degree,m0)*uo(pix,degree,mm0) + vo(pix,degree,m0)*vo(pix,degree,mm0) 
;        			endfor
;    			endfor
;		endfor
;	endfor


	if (degree eq 1) then begin
		croiseen(0,*,*)=[[0.21224671,0.0000000,0.13487199],$
       				 [0.0000000,0.79514712,0.0000000],$
      				 [0.13487199,0.0000000,0.21224671]]


		croiseen(1,*,*)=[[0.39219107,0.0000000,-0.0067406240],$
       			        [0.0000000,0.10157658,0.0000000],$
   			        [-0.0067406240,0.0000000,0.39219107]]

		croiseen(2,*,*)=[[0.39556222,0.0000000,0.34627012],$
       			        [0.0000000,0.10327632,0.0000000],$
     	 		        [0.34627012,0.0000000,0.39556222]]
	endif



	if (degree eq 2) then begin
		croiseen(0,*,*)=[[0.11884256,0.0000000,0.074548141,0.0000000,-0.022850152],$
       				 [0.0000000,0.67554667,0.0000000,0.43409183,0.0000000],$
     				 [0.074548141,0.0000000,0.11578885,0.0000000,0.074548141],$
       				 [0.0000000,0.43409183,0.0000000,0.67554667,0.0000000],$
    				 [-0.022850152,0.0000000,0.07454814,0.0000000,0.11884256]]

		croiseen(1,*,*)=[[0.43240182,0.0000000,0.0066632789,0.0000000,-0.43220182],$
   				 [0.0000000,0.16024433,0.0000000,-0.0021197529,0.0000000],$
    				 [0.0066632789,0.0000000,0.44398238,0.0000000,0.0066632789],$
   				 [0.0000000,-0.0021197529,0.0000000,0.16024433,0.0000000],$
     				 [-0.43220182,0.0000000,0.0066632789,0.0000000,0.43240182]]

		croiseen(2,*,*)=[[0.44875561,0.0000000,-0.38913108,0.0000000,0.23917292],$
       				 [0.0000000,0.16420904,0.0000000,0.14371682,0.0000000],$
     				 [-0.38913108,0.0000000,0.44022886,0.0000000,-0.38913108],$
       				 [0.0000000,0.14371682,0.0000000,0.16420904,0.0000000],$
      				 [0.23917292,0.0000000,-0.38913108,0.0000000,0.44875561]]
	endif


	if (degree eq 3) then begin
		croiseen(0,*,*)=[[0.057153304,0.0000000,0.10744330,0.0000000,-0.026827170,0.0000000,-0.049360456],$
       				 [0.0000000,0.51130636,0.0000000,0.18991484,0.0000000,-0.090963738,0.0000000],$
      				 [0.10744330,0.0000000,0.50161261,0.0000000,0.33235223,0.0000000,0.026827170],$
       				 [0.0000000,0.18991484,0.0000000,0.17161071,0.0000000,0.18991484,0.0000000],$
    				 [-0.026827170,0.0000000,0.33235223,0.0000000,0.50161261,0.0000000,0.10744330],$
       				 [0.0000000,-0.090963738,0.0000000,0.18991484,0.0000000,0.51130636,0.0000000],$
    				 [-0.049360456,0.0000000,-0.026827170,0.0000000,0.10744330,0.0000000,0.057153304]]

		croiseen(1,*,*)=[[0.45082782,0.0000000,0.0023511015,0.0000000,0.33564967,0.0000000,0.015844347],$
       				 [0.0000000,0.23817609,0.0000000,-0.0035930692,0.0000000,-0.23811337,0.0000000],$
    				 [0.0023511015,0.0000000,0.25009554,0.0000000,-0.0052887322,0.0000000,0.33564967],$
       				 [0.0000000,-0.0035930692,0.0000000,0.41165562,0.0000000,-0.0035930692,0.0000000],$
      				 [0.33564967,0.0000000,-0.0052887322,0.0000000,0.25009554,0.0000000,0.0023511015],$
       				 [0.0000000,-0.23811337,0.0000000,-0.0035930692,0.0000000,0.23817609,0.0000000],$
     				 [0.015844347,0.0000000,0.33564967,0.0000000,0.0023511015,0.0000000,0.45082782]]

		croiseen(2,*,*)=[[0.49201887,0.0000000,-0.30610696,0.0000000,-0.18651602,0.0000000,0.029096143],$
       				 [0.0000000,0.25051750,0.0000000,0.28282910,0.0000000,0.13338381,0.0000000],$
     			         [-0.30610696,0.0000000,0.24829187,0.0000000,0.21739688,0.0000000,-0.18651602],$
       				 [0.0000000,0.28282910,0.0000000,0.41673366,0.0000000,0.28282910,0.0000000],$
     				 [-0.18651602,0.0000000,0.21739688,0.0000000,0.24829187,0.0000000,-0.30610696],$
       				 [0.0000000,0.13338381,0.0000000,0.28282910,0.0000000,0.25051750,0.0000000],$
     				 [0.029096143,0.0000000,-0.18651602,0.0000000,-0.30610696,0.0000000,0.49201887]]

	endif




	print,reform(croiseen(0,*,*))

	print,'*****'

	print,reform(croiseen(1,*,*))

	print,'*****'

	print,reform(croiseen(2,*,*))

	print,'*****'


;-------------------------------- number of parameters
; 1 freq + 6 bruits + 1 largeur + 2 splits + 2*l+1 amplis 
; and 2 angles !

	Nparam=2*degree+13

;-------- add a dummy parameter
	Nparam=Nparam+1


	param=dblarr(Nparam)
	error=dblarr(Nparam)



;------------------- Here we set the fixed string 

	;  freq, width, a1 
	string='000'
	param(0)=0.2d0
	param(1)=-0.08d0
	param(2)=-0.410d0


;  a3
	if (degree gt 1) then begin
 		string=string+'0'
        	param(3)=-0.010d0
	endif else begin
        	string=string+'1'
        	param(3)=0.0d0
	endelse

; amplitudes
	for m=0,2*degree do begin
		string=string+'0'
	endfor

	if (degree eq 1) then begin
		param(4)=0.8d0
		param(5)=0.2d0
		param(6)=0.9d0
	endif


	if (degree eq 2) then begin
		param(4)=1.2d0
		param(5)=0.8d0
		param(6)=0.5d0
		param(7)=0.9d0
		param(8)=1.05d0
	endif


	if (degree eq 3) then begin
		param(4)=0.15d0
		param(5)=-0.20d0
		param(6)=-0.30d0
		param(7)=-0.60d0
		param(8)=-0.35d0
		param(9)=-0.25d0
		param(10)=0.10d0
	endif




;noise
	param(2*degree+7:2*degree+12)=-100.
	string_n='000111'

	param(2*degree+7)=-1.d0
	param(2*degree+8)=-0.8d0
	param(2*degree+9)=-1.5d0

;angles

	param(2*degree+5)=theta
	param(2*degree+6)=phi


	paramstart=param


;------------------- spectrum definition: resolution and window size

	npt=85680.
	resol=1000000./(2.*npt)/60.

	window=15.
	Npoints=floor(window/resol)
	Npoints=Npoints + Npoints mod 2

	xdata=(dindgen(Npoints)-Npoints/2)*resol



;------------------------ donne des noms plus cools pour les parametres

	ampli=dblarr(2*degree+1)
	bruit_mc=dblarr(6)

	freq=paramstart(0)
	width=paramstart(1)
	a1=paramstart(2)
	a3=paramstart(3)
	ampli(0:2*degree)=paramstart(4:2*degree+4)

	theta=paramstart(2*degree+5)
	phi=paramstart(2*degree+6)

	bruit_mc(0:5)=exp(paramstart(2*degree+7:2*degree+12))


;-----------------compute sqrt(variances) for the monte-carlo simulation

	yin=dblarr(Npoints,2*degree+1)

	paramline=dblarr(7)
; fake crosstalk here at 1.0
	paramline(5)=0.d0

	paramline(2)=width

	for i=0,2*degree do begin
        	m=i-degree
        	paramline(0)=ampli(i)
        	paramline(1)=freq+m*a1
        	if (degree gt 1) then begin
			L2=degree*(degree+1)
		     	norma=-10.*degree^2+(6.*L2-2.)
		   	paramline(1)=paramline(1) + m*a3*(-10.*m^2+6.*L2-2.)/norma
        	endif
		yin(*,i)=sqrt( lorentzian(paramline,xdata(*)) )
	endfor




;-----------------------------------rotation
	rctnm_mc=dblarr(2*degree+1,2*degree+1)

 	mat_rot=function_rot(degree,theta)
	for nn=0,degree*2 do begin
  		for mm=0,2*degree do begin
    			for kk=0,2*degree do begin
				rctnm_mc(nn,mm)=rctnm_mc(nn,mm)+ctnm1(nn,kk)*mat_rot(mm,kk)
                        endfor
   		endfor
	endfor




!p.multi=[0,2,2]


;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$mega loop
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$mega loop
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$mega loop

	afile=findfile('MC1a_'+strtrim(round(degree),1)+'s*')

	print,afile

	paramout=fltarr(N_elements(param),iterations)
	errorout=fltarr(N_elements(param),iterations)

	istart=0

	if (strlen(afile(0)) ne 0) then begin
		paramin=readfits(afile(0),hdr)
		errorin=readfits(afile(1))
		istart=N_elements(paramin)/N_elements(param)
		paramout(*,0:istart-1)=paramin
		errorout(*,0:istart-1)=errorin

		print, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
		print, hdr
		print, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
		print, ' already    ', istart, '  iterations....'
		print, ' only', iterations-istart, '  iterations left.'
		print, ' KEEP COOL -- BE PATIENT --'
		print, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'

	endif else begin

		afile='MC1a_'+strtrim(round(degree),1)+'s'

	endelse




	for iter=istart,iterations-1 do begin



;----------------- construit les spectres

  	
	rydata=dblarr(Npoints,N)
	iydata=dblarr(Npoints,N)
	ryin=dblarr(Npoints,N)
	iyin=dblarr(Npoints,N)
	rand1=randomn(seed,Npoints,N)
	rand2=randomn(seed,Npoints,N)
	ryin=yin*rand1/sqrt(2.)
	iyin=yin*rand2/sqrt(2.)


	for i=0,N-1 do begin
		for j=0,N-1 do begin
        		rydata(*,i)=rydata(*,i)+rctnm_mc(i,j)*ryin(*,j)
        		iydata(*,i)=iydata(*,i)+rctnm_mc(i,j)*iyin(*,j)
		endfor
	endfor


	randnoise_r=dblarr(Npoints,12)

	joe=randomn(seed,Npoints,12)
	for pix=0,2 do begin
		randnoise_r(*,4*pix)=joe(*,4*pix)*bruit_mc(pix)
		randnoise_r(*,4*pix+1)=joe(*,4*pix+1)*bruit_mc(pix)
        	randnoise_r(*,4*pix+2)=joe(*,4*pix+2)*bruit_mc(pix)
        	randnoise_r(*,4*pix+3)=joe(*,4*pix+3)*bruit_mc(pix)
	endfor


	randnoise_i=dblarr(Npoints,12)

	joe=randomn(seed,Npoints,12)

	for pix=0,2 do begin
		randnoise_i(*,4*pix)=joe(*,4*pix)*bruit_mc(pix)
		randnoise_i(*,4*pix+1)=joe(*,4*pix+1)*bruit_mc(pix)
        	randnoise_i(*,4*pix+2)=joe(*,4*pix+2)*bruit_mc(pix)
        	randnoise_i(*,4*pix+3)=joe(*,4*pix+3)*bruit_mc(pix)
	endfor


	ydata=dcomplexarr(Npoints,N)


	for mm=0,2*degree do begin
    		for pix=0,11 do begin
        		rydata(*,mm)=rydata(*,mm) + randnoise_r(*,pix)*uo(pix,degree,mm) + randnoise_i(*,pix)*vo(pix,degree,mm)
        		iydata(*,mm)=iydata(*,mm) - randnoise_r(*,pix)*vo(pix,degree,mm) + randnoise_i(*,pix)*uo(pix,degree,mm)
    		endfor
	endfor

		ydata=dcomplex(rydata,iydata)


;----------------------------------------- we fit 1 Euler angle
		startstring=string+'01'+string_n+'1'

		param=paramstart

		print, degree

		fitplot,xdata,ydata,'crosstalklg',param,error,degree,tol,3000.,'Monte-Carlo','',fixed=startstring,nodfp='10',/as

		print, error

		paramout(*,iter)=param
		errorout(*,iter)=error

		writefits,afile(0),paramout(*,0:iter)

		fxhmodify,afile(0),'Npts',npt,' nombre de points'
		fxhmodify,afile(0),'win',window,' Window'
		fxhmodify,afile(0),'Frequency',paramstart(0),' index 0'
		fxhmodify,afile(0),'Width',paramstart(1),' index 1, ln(width)'
		fxhmodify,afile(0),'a1',paramstart(2),' index 2'
		fxhmodify,afile(0),'a3',paramstart(3),' index 3'
	
		for mmm=0,2*degree do begin
  	  		fxhmodify,afile(0),'Ampli_'+strtrim(mmm,1),paramstart(4+mmm),' index '+strtrim(mmm+4,1)+', ln(ampli)'
		endfor

		fxhmodify,afile(0),'beta',paramstart(2*degree+5),' index '+strtrim(round(2*degree+5),1)+', B angle' 
		fxhmodify,afile(0),'gamma',paramstart(2*degree+6),' index '+strtrim(round(2*degree+6),1)+', P angle (not used)'
	
		for mmm=0,2 do begin
   	 		fxhmodify,afile(0),'bruit_'+strtrim(mmm,1),paramstart(2*degree+7+mmm),' index '+strtrim(round(2*degree+7+mmm),1)+', ln(noise)'
		endfor



		writefits,afile(0)+'_err',errorout(*,0:iter)





	endfor

end


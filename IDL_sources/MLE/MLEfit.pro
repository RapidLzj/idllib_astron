pro MLEfit,xinput,yinput,nfunc,param,error,tol,fixed=instring,nodfp=inalgo,corr=correlout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	MLEfit,xinput,yinput,nfunc,Modepeak,param,error,tol
; PURPOSE:
;	Minimize various Maximum Likelihood function for fitting. 
; INPUTS:
;	xinput 		frequency of the points centered on zero (Npoints)
;	yinput 		power spectra (Npoints, 2*degree+1)
;	nfunc is a parameter ranging from 0 to 2
;		nfunc=0 likelihood fit of a multiplet 	  (single spectrum)
;	  	nfunc=2 likelihood fit of an m,nu diagram (2*degree+1 spectrum)
;		nfunc=4 likelihood fit of the amplitude spectrum
; 	param 		starting parameters
;	tol		tolerance for the Powell algorithm and for dfp
;			tol=dblarr(2), tol(0) for powell, tol(1) for dfp
; OPTIONAL KEYWORDS:
; 	fixed		This is to give the fixed parameters as a string,
;			for example if param has 6 elements, 2 of those
;			elements can be fixed by setting instring='010010'
;       nodfp		This string is now used to choose the combinaison of algorithm
;			for convergence. Set it to '10' if you want both algorithm (Powell
;			and dfp).  Set it to '01' if you want only dfp
;			default is '11' Powell and dfp only, to '00' if you want no
;			minization just the hessian.
;					
;	/nopowell	If set do not look for the minimum using a shooting proc.
; OUTPUTS:
;	param 		fitted parameters
;	error		1-sigma error on the output parameters
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at fitplot.pro
; LIMITATIONS:
;	None ?
; COMMONS:
;	None
; PROCEDURES USED:
;       NR_Powell, NR_dfpmin, hessian
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;	Beta 2: TA, Removed nfunc=1 useless now, June, 13, 1995
;	Beta 3: TA, Add the fixed parameters stuff, June 13, 1995
;	Beta 4: TA, Add the /nodfp keyword, June 27, 1995
;	Beta 5: TA, Add the fixed parameters stuff for m,nu diagram, August 28, 1995
;	Beta 6: TA, Correct a bug ifixed is now always defined, August, 31, 1995
;	Beta 7: TA, Fit the amplitude now, October 18, 1995
;	Beta 8: TA, Fit the amplitude with fixed parameters, October 19, 1995
;	Beta 9: TA, Choice of algorithm combination, October 25, 1995
;	Beta 10: TA, Now fit phase, November 1996
;	Beta 11: TA, Return also the correlation matrix, August 1, 1997
;	Beta 12: TA, Pass Fmin as a common, quick and dirty, January 27, 1998
;	Beta 13: TA, Add new common for speeding things up, June 12, 1998
;	Beta 14: TA, When inalgo='00' no minization performed just hessian, September 30, 1998
;------------------------------------------------------------------------------
;
;
	common data,xdata,ydata
	common datar,ydatar,ydatar_t
	common datai,ydatai,ydatai_t
	common data2,ydata2
	common speed,Neval
	common fixedit,paramfixed,posnonfixed,posfixed
	common lmin,Fmin
	likelihoodname=strarr(9)
	dlikelihoodname=strarr(9)
	likelihoodname(0)='likelihood'
	likelihoodname(1)='likelihoodfixed'
	likelihoodname(2)='likelihoodlfast'
	likelihoodname(3)='likelihoodlfixed'
	likelihoodname(4)='likelihoodampl'
	likelihoodname(5)='likelihoodamplfixed'
	likelihoodname(6)='likelihoodchang'
	likelihoodname(7)='likelihoodphase'
	likelihoodname(8)='likelihoodphasefixed'	
	

	dlikelihoodname(0)='dlikelihood'
	dlikelihoodname(1)='dlikelihoodfixed'
	dlikelihoodname(2)='dlikelihoodlfast'
	dlikelihoodname(3)='dlikelihoodlfixed'
	dlikelihoodname(4)='dlikelihoodampl'
	dlikelihoodname(5)='dlikelihoodamplfixed'
	dlikelihoodname(6)='dlikelihoodchang'
	dlikelihoodname(7)='dlikelihoodphase'
	dlikelihoodname(8)='dlikelihoodphasefixed'
	
	Nparam=N_elements(param)
	paramvar=param
	Nvar=Nparam
;
;
; Here we set the combination of algorithms
	algopowell=1
	algodfp=1
	if (n_elements(inalgo) eq 1) then begin
	if (strlen(inalgo) eq 2) then begin
	print,'inalgo=',n_elements(inalgo),inalgo
		if (inalgo eq '10') then begin
			algopowell=1
			algodfp=0
		endif
		if (inalgo eq '01') then begin
			algopowell=0
			algodfp=1
		endif
		if (inalgo eq '00') then begin
			algopowell=0
			algodfp=0
		endif
	endif else begin
; Here to keep the compatibility with older programmes
			algopowell=1
			algodfp=0
	endelse
	endif

; Here we start decoding the fixed parameters string


	if (n_elements(instring) gt 0) then begin
; check if length of the string is the same as the number of elements
		if (strlen(instring) ne Nparam) then begin
			print,'Length of instring in MLEfit.pro does not match number of parameters'
			print,'Nparam,instring',Nparam,strlen(instring)
			stop
		endif
;
; start search for non-fixed parameters
;
		pos=0
		inonfixed=0
		posnonfixed=intarr(Nparam)
		while (pos lt Nparam) do begin
			result=strpos(instring,'0',pos)
			pos=result+1
			if (result eq -1) then begin
				pos=Nparam
				if (inonfixed eq 0) then begin
					print,'Are all parameters fixed?'
					stop
				endif
			endif else begin
				posnonfixed(inonfixed)=result
				inonfixed=inonfixed+1
			endelse
		endwhile
		print,posnonfixed(0:inonfixed-1)
		print,'inonfixed=',inonfixed
		Nvar=inonfixed
		paramvar=dblarr(inonfixed)
		paramvar(0:inonfixed-1)=param(posnonfixed(0:inonfixed-1))
		
;
; start search for fixed parameters
;
		ifixed=0
		if (Nvar lt Nparam) then begin
			pos=0
			posfixed=intarr(Nparam)
			while (pos lt Nparam) do begin
				result=strpos(instring,'1',pos)
				pos=result+1
				if (result eq -1) then begin
					pos=Nparam
				endif else begin
					posfixed(ifixed)=result
					ifixed=ifixed+1
				endelse
			endwhile
			print,posfixed(0:ifixed-1)
			print,'ifixed=',ifixed
			paramfixed=dblarr(ifixed)
			paramfixed(0:ifixed-1)=param(posfixed(0:ifixed-1))
			if (nfunc eq 0) then nfunc=1
			if (nfunc eq 2) then nfunc=3
			if (nfunc eq 4) then nfunc=5
			if (nfunc eq 7) then nfunc=8
		endif

	endif
			
			
;
;
	namefunc=likelihoodname(nfunc)	
	dnamefunc=dlikelihoodname(nfunc)
;	spawn,'date'
	Neval=0.
	Npoints=N_elements(xdata)
;
	xdata=xinput
	ydata=yinput

; ydata is complex then load common datar and common datai

	cc=size(ydata)
	
	print,'cc is ****************',cc
	

	if ((cc(3) eq 6) or (cc(3) eq 9)) then begin
		Print,'Creating new commons...'
		ydatar=double(ydata)
		ydatar_t=transpose(ydatar)
		ydatai=imaginary(ydata)
		ydatai_t=transpose(ydatai)
	endif
					
	


;	N=Nspectra
;
	Ntol=n_elements(tol)
	if (Ntol eq 1) then begin
		Ftol=tol
		Gtol=tol
	endif 
	if (Ntol eq 2) then begin
		Ftol=tol(0)
		Gtol=tol(1)
	endif
	if ((Ntol ne 1) and (Ntol ne 2)) then begin
		print,'tol does not have the right dimension (1 or 2)'
		stop
	endif
;
	Unit=dblarr(Nvar,Nvar)
	for i=0,Nvar-1 do begin
		Unit(i,i)=1.d0
	endfor
	print,namefunc,"     ",dnamefunc
;	
; minimize likelihood function
	print,paramvar
	npowell=0
	nn=0
	If (algopowell eq 1) then begin
		print,'We use the Powell algorithm'
		NR_POWELL, paramvar, Unit, Ftol, Fmin,namefunc,/double,iter=nn
		npowell=nn
		print,"N evaluation=",Neval
		print,"Powell finished, Fmin=",Fmin
		print,""
	endif

	print,paramvar
	
	If (algodfp eq 1) then begin
		print,'We use Newton-Raphson dfp algorithm'
		NR_DFPMIN, paramvar, Gtol, Fmin, namefunc,dnamefunc,/double,iter=nn
	endif
	ngradient=nn
;
	Fbef=Fmin
	Ftol=1d-08

	if ((algopowell eq 1) or (algodfp eq 1)) then begin
		print,""
		print,"Number of iterations=",npowell,ngradient
		print,""
		print,"Fmin=",Fmin
	endif else begin
		Print,'********** Warning! ************'
		Print,'** No minimization performed! **'
	endelse	

	
	correl=dblarr(Nvar,Nvar)
	correlout=dblarr(Nparam,Nparam)
;	spawn,'date'
	print,"N evaluation=",Neval
	print,Nvar
	hessian,namefunc,paramvar,correl
;
; Now return param and error after decoding paramvar and paramfixed
;
	if (n_elements(instring) gt 0) then begin
		for i=0,inonfixed-1 do begin
			param(posnonfixed(i))=paramvar(i)
			error(posnonfixed(i))=sqrt(correl(i,i))
		endfor
		if (n_elements(correlout) gt 0) then begin
		for i=0,inonfixed-1 do begin
			for j=0,inonfixed-1 do begin
				correlout(posnonfixed(i),posnonfixed(j))=correl(i,j)
			endfor
		endfor
		endif
		for i=0,ifixed-1 do begin
			param(posfixed(i))=paramfixed(i)
			error(posfixed(i))=0.
		endfor
		if (n_elements(correlout) gt 0) then begin
		for i=0,ifixed-1 do begin
			for j=0,ifixed-1 do begin
				correlout(posfixed(i),posfixed(j))=0.
			endfor
		endfor
		endif
	endif else begin
		for i=0,Nvar-1 do begin
			error(i)=sqrt(correl(i,i))
		endfor
		param=paramvar
		if (n_elements(correlout) gt 0) then begin
			correlout=correl
		endif
	endelse


end

pro MLEfitalias,xinput,yinput1,yinput2,nfunc,param,error,tol,fixed=instring,nodfp=inalgo,corr=correlout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	MLEfit,xinput,yinput,nfunc,Modepeak,param,error,tol
; PURPOSE:
;	Minimize various Maximum Likelihood function for fitting. 
; INPUTS:
;	xinput 		frequency of the points centered on zero (Npoints)
;	yinput1 		power spectra (Npoints, 2*degree+1)
;	yinput2 		power spectra (Npoints, 2*degreeal+1)
;	nfunc is a parameter ranging from 7 to 7
;		nfunc=7 likelihood fit of an m,nu diagram (2*degree+1 spectrum) and its alias
; 	param 		starting parameters
;	tol		tolerance for the Powell algorithm and for dfp
;			tol=dblarr(2), tol(0) for powell, tol(1) for dfp
; OPTIONAL KEYWORDS:
; 	fixed		This is to give the fixed parameters as a string,
;			for example if param has 6 elements, 2 of those
;			elements can be fixed by setting instring='010010'
;       nodfp		This string is now used to choose the combinaison of algorithm
;			for convergence. Set it to '10' if you want both algorithm (Powell
;			and dfp).  Set it to '01' if you want only dfp
;			default is '11' Powell and dfp only.
;					
;	/nopowell	If set do not look for the minimum using a shooting proc.
; OUTPUTS:
;	param 		fitted parameters
;	error		1-sigma error on the output parameters
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at fitplot.pro
; LIMITATIONS:
;	None ?
; COMMONS:
;	None
; PROCEDURES USED:
;       NR_Powell, NR_dfpmin, hessian
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, October 31, 1995
;------------------------------------------------------------------------------
;
;
	common data,xdata,ydata
	common data2,ydata2
	common speed,Neval
	common fixedit,paramfixed,posnonfixed,posfixed
	likelihoodname=strarr(9)
	dlikelihoodname=strarr(9)
	likelihoodname(7)='likelihoodlalias'
	likelihoodname(8)='likelihoodlaliasfixed'
	
	dlikelihoodname(7)='dlikelihoodlalias'
	dlikelihoodname(8)='dlikelihoodlaliasfixed'
	
	Nparam=N_elements(param)
	paramvar=param
	Nvar=Nparam

	if (nfunc lt 7) then begin
		Print,'Please for nfunc le 7 use MLEFIT.PRO'
		stop
	endif
;
;
; Here we set the combination of algorithms
	algopowell=1
	algodfp=1
	if (n_elements(inalgo) eq 1) then begin
	if (strlen(inalgo) eq 2) then begin
	print,'inalgo=',n_elements(inalgo),inalgo
		if (inalgo eq '10') then begin
			algopowell=1
			algodfp=0
		endif
		if (inalgo eq '01') then begin
			algopowell=0
			algodfp=1
		endif
	endif else begin
; Here to keep the compatibility with older programmes
			algopowell=1
			algodfp=0
	endelse
	endif

; Here we start decoding the fixed parameters string


	if (n_elements(instring) gt 0) then begin
; check if length of the string is the same as the number of elements
		if (strlen(instring) ne Nparam) then begin
			print,'Length of instring in MLEfit.pro does not match number of parameters'
			print,'Nparam,instring',Nparam,strlen(instring)
			stop
		endif
;
; start search for non-fixed parameters
;
		pos=0
		inonfixed=0
		posnonfixed=intarr(Nparam)
		while (pos lt Nparam) do begin
			result=strpos(instring,'0',pos)
			pos=result+1
			if (result eq -1) then begin
				pos=Nparam
				if (inonfixed eq 0) then begin
					print,'Are all parameters fixed?'
					stop
				endif
			endif else begin
				posnonfixed(inonfixed)=result
				inonfixed=inonfixed+1
			endelse
		endwhile
		print,posnonfixed(0:inonfixed-1)
		print,'inonfixed=',inonfixed
		Nvar=inonfixed
		paramvar=dblarr(inonfixed)
		paramvar(0:inonfixed-1)=param(posnonfixed(0:inonfixed-1))
		
;
; start search for fixed parameters
;
		ifixed=0
		if (Nvar lt Nparam) then begin
			pos=0
			posfixed=intarr(Nparam)
			while (pos lt Nparam) do begin
				result=strpos(instring,'1',pos)
				pos=result+1
				if (result eq -1) then begin
					pos=Nparam
				endif else begin
					posfixed(ifixed)=result
					ifixed=ifixed+1
				endelse
			endwhile
			print,posfixed(0:ifixed-1)
			print,'ifixed=',ifixed
			paramfixed=dblarr(ifixed)
			paramfixed(0:ifixed-1)=param(posfixed(0:ifixed-1))
			if (nfunc eq 7) then nfunc=8
		endif

	endif
			
			
;
;
	namefunc=likelihoodname(nfunc)	
	dnamefunc=dlikelihoodname(nfunc)
;	spawn,'date'
	Neval=0.
	Npoints=N_elements(xdata)
;
	xdata=xinput
	ydata=yinput1
	ydata2=yinput2
;	N=Nspectra
;
	Ntol=n_elements(tol)
	if (Ntol eq 1) then begin
		Ftol=tol
		Gtol=tol
	endif 
	if (Ntol eq 2) then begin
		Ftol=tol(0)
		Gtol=tol(1)
	endif
	if ((Ntol ne 1) and (Ntol ne 2)) then begin
		print,'tol does not have the right dimension (1 or 2)'
		stop
	endif
;
	Unit=dblarr(Nvar,Nvar)
	for i=0,Nvar-1 do begin
		Unit(i,i)=1.d0
	endfor
	print,namefunc,"     ",dnamefunc
;	
; minimize likelihood function
	print,paramvar
	npowell=0
	If (algopowell eq 1) then begin
		print,'We use the Powell algorithm'
		NR_POWELL, paramvar, Unit, Ftol, Fmin,namefunc,/double,iter=nn
		npowell=nn
		print,"N evaluation=",Neval
		print,"Powell finished, Fmin=",Fmin
		print,""
	endif

	print,paramvar
	
	If (algodfp eq 1) then begin
		print,'We use Newton-Raphson dfp algorithm'
		NR_DFPMIN, paramvar, Gtol, Fmin, namefunc,dnamefunc,/double,iter=nn
	endif
	ngradient=nn
;
	Fbef=Fmin
	Ftol=1d-08
	
	print,""
	print,"Number of iterations=",npowell,ngradient
	print,""
	print,"Fmin=",Fmin
		
	correl=dblarr(Nvar,Nvar)
	correlout=dblarr(Nparam,Nparam)
;	spawn,'date'
	print,"N evaluation=",Neval
	print,Nvar
	hessian,namefunc,paramvar,correl
;
; Now return param and error after decoding paramvar and paramfixed
;
	if (n_elements(instring) gt 0) then begin
		for i=0,inonfixed-1 do begin
			param(posnonfixed(i))=paramvar(i)
			error(posnonfixed(i))=sqrt(correl(i,i))
		endfor

		if (n_elements(correlout) gt 0) then begin
		for i=0,inonfixed-1 do begin
			for j=0,inonfixed-1 do begin
				correlout(posnonfixed(i),posnonfixed(j))=correl(i,j)
			endfor
		endfor
		endif		

		for i=0,ifixed-1 do begin
			param(posfixed(i))=paramfixed(i)
			error(posfixed(i))=0.
		endfor

		if (n_elements(correlout) gt 0) then begin
		for i=0,ifixed-1 do begin
			for j=0,ifixed-1 do begin
				correlout(posfixed(i),posfixed(j))=0.
			endfor
		endfor
		endif			
		endif else begin
		for i=0,Nvar-1 do begin
			error(i)=sqrt(correl(i,i))
		endfor
		if (n_elements(correlout) gt 0) then begin
		correlout=correl
		endif
		param=paramvar
	endelse
end




;************************************************
; Compute likelihood output
;************************************************

Function transfer,paramvar,xdata
	common fixedit,paramfixed,posnonfixed,posfixed
	common tofit,functionfit
	Nvar=N_elements(paramvar)
	Nfixed=N_elements(paramfixed)
	Ntotal=Nvar+Nfixed
	param=dblarr(Ntotal)
	param(posnonfixed(0:Nvar-1))=paramvar(0:Nvar-1)
	param(posfixed(0:Nfixed-1))=paramfixed(0:Nfixed-1)
	y=call_function(functionfit,param,xdata)
	return,y
end

;************************************************








;************************************************
; Compute likelihood output
;************************************************

Function likelihood,param
	common data,xdata,ydata
	common tofit,functionfit
	common pl,chisr,nplot
	y=call_function(functionfit,param,xdata)
	l=ydata/y+alog(y)
	return,total(l,/double)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihood,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.01) then begin
			h=0.01
		endif
		temp(i)=param(i)+h
		yp1=likelihood(temp)
		temp(i)=param(i)-h
		ym1=likelihood(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv
end

;************************************************

;************************************************
; Compute likelihood output
;************************************************

Function likelihoodfixed,param
	common data,xdata,ydata
	common tofit,functionfit
	common pl,chisr,nplot
	y=call_function('transfer',param,xdata)
	l=ydata/y+alog(y)
	return,total(l,/double)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihoodfixed,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.01) then begin
			h=0.01
		endif
		temp(i)=param(i)+h
		yp1=likelihoodfixed(temp)
		temp(i)=param(i)-h
		ym1=likelihoodfixed(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv
end

;************************************************




;************************************************
; Compute likelihood output for 2*l+1 spectra
;************************************************

Function likelihoodlfast,param
	common data,xdata,ydata
	common tofit,functionfit
; create an array dimensionned as xdata
; same for y
	y=ydata
	call_procedure,functionfit,param,xdata,y
	l=ydata/y+alog(y)
	return,total(total(l,/double),1,/double)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihoodlfast,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodlfast(temp)
		temp(i)=param(i)-h
		ym1=likelihoodlfast(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end


;************************************************
; Compute likelihood output for 2*l+1 spectra
;************************************************

Function likelihoodlfixed,paramvar
	common data,xdata,ydata
	common fixedit,paramfixed,posnonfixed,posfixed
	common tofit,functionfit
	Nvar=N_elements(paramvar)
	Nfixed=N_elements(paramfixed)
	Ntotal=Nvar+Nfixed
	param=dblarr(Ntotal)
	param(posnonfixed(0:Nvar-1))=paramvar(0:Nvar-1)
	param(posfixed(0:Nfixed-1))=paramfixed(0:Nfixed-1)

; create an array dimensionned as xdata
; same for y
	y=ydata
	call_procedure,functionfit,param,xdata,y
	l=ydata/y+alog(y)
	return,total(total(l,/double),1,/double)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihoodlfixed,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodlfixed(temp)
		temp(i)=param(i)-h
		ym1=likelihoodlfixed(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end

;************************************************
; Compute likelihood output for the amplitude
; spectra
;************************************************

Function likelihoodampl,param
	common data,xdata,ydata
	common tofit,functionfit
	Ndata=N_elements(xdata)
	Nmodes=N_elements(ydata)/Ndata
;
	Cenm=dblarr(Nmodes,Nmodes,Ndata)
;
	Denm=dblarr(Ndata)
;
; Call to compute covariance matrix
;
;
	call_procedure,functionfit,param,xdata,Cenm

	for i=0,Ndata-1 do begin		
		Denm(i)=abs(determ(Cenm(*,*,i),/double))
		test=Cenm(*,*,i)
		Cenm(*,*,i)=invert(test)
	endfor

	l=dblarr(Ndata)
;
	
	for i=0,Ndata-1 do begin

	l(i)=reform(transpose(double(ydata(i,*)))) ## (reform(Cenm(*,*,i)) ## double(reform(ydata(i,*))))
	
	l(i)=l(i)+reform(transpose(imaginary(ydata(i,*)))) ## (reform(Cenm(*,*,i)) ## imaginary(reform(ydata(i,*))))

	endfor
	


	l=l+alog(Denm)
	
	return,total(l,/double)
end

;************************************************
; Compute derivative of the likelihood output 
; for the amplitude spectra
;************************************************

Function dlikelihoodampl,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodampl(temp)
		temp(i)=param(i)-h
		ym1=likelihoodampl(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end

;************************************************
; Compute likelihood output for the amplitude
; spectra.  Fixed version
;************************************************



Function likelihoodamplfixed,paramvar
	common data,xdata,ydata
	common datar,ydatar,ydatar_t
	common datai,ydatai,ydatai_t
	common fixedit,paramfixed,posnonfixed,posfixed
	common tofit,functionfit
	Ndata=N_elements(xdata)
	Nmodes=N_elements(ydata)/Ndata
;
	Nvar=N_elements(paramvar)
	Nfixed=N_elements(paramfixed)
	Ntotal=Nvar+Nfixed
	param=dblarr(Ntotal)
	param(posnonfixed(0:Nvar-1))=paramvar(0:Nvar-1)
	param(posfixed(0:Nfixed-1))=paramfixed(0:Nfixed-1)

;
	Cenm=dblarr(Nmodes,Nmodes,Ndata)
;
	Denm=dblarr(Ndata)
;
; Call to compute covariance matrix
;
;
;	a=systime(1)

	call_procedure,functionfit,param,xdata,Cenm

	for i=0,Ndata-1 do begin
		Denm(i)=abs(determ(Cenm(*,*,i),/double))
	endfor

	for i=0,Ndata-1 do begin
		Cenm(*,*,i)=invert(reform(Cenm(*,*,i)),/double)
	endfor
	

	l=dblarr(Ndata)


	for i=0,Ndata-1 do begin

	uu=reform(Cenm(*,*,i))

	l(i)=reform(ydatar_t(*,i)) ## (uu ## reform(ydatar(i,*)))
	
	l(i)=l(i)+reform(ydatai_t(*,i)) ## (uu ## reform(ydatai(i,*)))

	endfor



;	d=systime(1)

;	print,'Time for computing the matrix multiplication',d-c

	l=l+alog(Denm)

	return,total(l,/double)

end

;************************************************
; Compute derivative of the likelihood output 
; for the amplitude spectra. Fixed version
;************************************************


Function dlikelihoodamplfixed,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodamplfixed(temp)
		temp(i)=param(i)-h
		ym1=likelihoodamplfixed(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end




;************************************************
; Compute likelihood output for 2*l+1 spectra
; and its alias
;************************************************

Function likelihoodlalias,param
	common data,xdata,ydata
	common data2,ydata2
	common tofit1,functionfit1
	common tofit2,functionfit2
; create an array dimensionned as xdata
; same for y
	y=ydata
	call_procedure,functionfit1,param,xdata,y1
	l=ydata/y1+alog(y1)
	l1=total(total(l,/double),1,/double)
;
	y=ydata2
	call_procedure,functionfit2,param,xdata,y2
	l=ydata2/y2+alog(y2)
	l2=total(total(l,/double),1,/double)
;
	return,total(l1+l2)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihoodlalias,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodlalias(temp)
		temp(i)=param(i)-h
		ym1=likelihoodlalias(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end


;************************************************
; Compute likelihood output for 2*l+1 spectra
;************************************************

Function likelihoodlaliasfixed,paramvar
	common data,xdata,ydata
	common data2,ydata2
	common fixedit,paramfixed,posnonfixed,posfixed
	common tofit1,functionfit1
	common tofit2,functionfit2
	Nvar=N_elements(paramvar)
	Nfixed=N_elements(paramfixed)
	Ntotal=Nvar+Nfixed
	param=dblarr(Ntotal)
	param(posnonfixed(0:Nvar-1))=paramvar(0:Nvar-1)
	param(posfixed(0:Nfixed-1))=paramfixed(0:Nfixed-1)

; create an array dimensionned as xdata
; same for y
	y=ydata
	call_procedure,functionfit1,param,xdata,y1
	l=ydata/y1+alog(y1)
	l1=total(total(l,/double),1,/double)
;
	y=ydata2
	call_procedure,functionfit2,param,xdata,y2
	l=ydata2/y2+alog(y2)
	l2=total(total(l,/double),1,/double)
;
	return,total(l1+l2)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihoodlaliasfixed,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodlaliasfixed(temp)
		temp(i)=param(i)-h
		ym1=likelihoodlaliasfixed(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end


;************************************************
; Compute likelihood output for the phase
; spectra (LOI and MDI combined)
;************************************************

Function likelihoodphase,param
	common data,xdata,ydata
	common tofit,functionfit
	Ndata=N_elements(xdata)


;
	Cenm=dblarr(4,4,Ndata)
;
	Denm=dblarr(Ndata)
;
; Call to compute covariance matrix
;
;
	call_procedure,functionfit,param,xdata,Cenm

	for i=0,Ndata-1 do begin		
		Denm(i)=abs(determ(Cenm(*,*,i),/double))
		test=Cenm(*,*,i)
		Cenm(*,*,i)=invert(test)
	endfor


	l=dblarr(Ndata)
;
	
	for i=0,Ndata-1 do begin

	l(i)=transpose(ydata(i,*)) ## Cenm(*,*,i) ## ydata(i,*)
	
	endfor

	l=l+alog(Denm)/2.d0
	
	
	return,total(l,/double)
end

;************************************************
; Compute derivative of the likelihood output 
; for the amplitude spectra
;************************************************

Function dlikelihoodphase,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodphase(temp)
		temp(i)=param(i)-h
		ym1=likelihoodphase(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end


;************************************************
; Compute likelihood output for the phase
; spectra (LOI and MDI combined)
;************************************************

Function likelihoodphasefixed,paramvar
	common data,xdata,ydata
	common tofit,functionfit
	common fixedit,paramfixed,posnonfixed,posfixed

	Ndata=N_elements(xdata)

;
	Nvar=N_elements(paramvar)
	Nfixed=N_elements(paramfixed)
	Ntotal=Nvar+Nfixed
	param=dblarr(Ntotal)
	param(posnonfixed(0:Nvar-1))=paramvar(0:Nvar-1)
	param(posfixed(0:Nfixed-1))=paramfixed(0:Nfixed-1)



;
	Cenm=dblarr(4,4,Ndata)
;
	Denm=dblarr(Ndata)
;
; Call to compute covariance matrix
;
;
	call_procedure,functionfit,param,xdata,Cenm

	for i=0,Ndata-1 do begin		
		Denm(i)=abs(determ(Cenm(*,*,i),/double))
		test=Cenm(*,*,i)
		Cenm(*,*,i)=invert(test)
	endfor


	l=dblarr(Ndata)
;
	
	for i=0,Ndata-1 do begin

	l(i)=transpose(ydata(i,*)) ## Cenm(*,*,i) ## ydata(i,*)
	
	endfor

	l=l+alog(Denm)/2.d0
	
	
	return,total(l,/double)
end

;************************************************
; Compute derivative of the likelihood output 
; for the amplitude spectra
;************************************************

Function dlikelihoodphasefixed,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.001) then begin
			h=0.001
		endif
		temp(i)=param(i)+h
		yp1=likelihoodphasefixed(temp)
		temp(i)=param(i)-h
		ym1=likelihoodphasefixed(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv

end







pro hessian,name,param,correl
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	hessian 
; CALLING SEQUENCE:
;	hessian,name,param,correl
; PURPOSE:
;	compute the hessian for a given Maximum Likelihood function
; INPUTS:
;	name 		name is a string representing the Maximum Likelihood function name
;	Ndim 		number of parameters
;	param 		where the Hessian is to be computed
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	correl		is the inverse of the correlation matrix
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at MLEfit.pro
; LIMITATIONS:
;	None?
; COMMONS:
;	None	
; PROCEDURES USED:
;       derivee2xy (call function name)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;------------------------------------------------------------------------------
;
; this procedure compute the inverse of the Hessian matrix
;
; Input:	name is a string reprensenting the function name
; 		Ndim is the number of parameters
; 		param is the input where the Hessian is to be computed
;
; Output:       correl is the correlation matrix
;
; compute the matrix elements
	Ndim=N_elements(param)
	temp=dblarr(Ndim,Ndim)
	for i=0,Ndim-1 do begin
		for j=i,Ndim-1 do begin
			temp(i,j)=derivee2xy(name,param,i,j)
			temp(j,i)=temp(i,j)
		endfor
	endfor
	correl=invert(temp)
end





Function derivee2xy,name,xparam,nx,ny
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	hessian 
; CALLING SEQUENCE:
;	yourarray=derivee2xy(name,param,i,j)
; PURPOSE:
;	compute partial derivative of a function with respect to its parameters
; INPUTS:
;	name 		name is a string representing the Maximum Likelihood function name
;	param 		where the Hessian is to be computed
;	i,j		pointer in the array param indicating to which the derivative are to be
;			taken (i.e. the i-ieme and j-ieme variables of param)
; OPTIONAL KEYWORDS:
; 	none
; OUTPUTS:
;	partial derivative
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at hessian.pro
; LIMITATIONS:
;	None?
; COMMONS:
;	None	
; PROCEDURES USED:
;       function name
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;	Beta 2: TS found an abs bug (Damn it!), November 7, 1996
;------------------------------------------------------------------------------

	temp=xparam
;
	if (nx EQ ny) then begin
;
; 2nd derivative with respect to the same nx-ieme
; variable
;
		h=abs(xparam(nx)*0.001d0)
		if (h LT 0.01) then begin
			h=0.01d0
		endif
;
		f00=call_function(name,temp)
;
		temp(nx)=xparam(nx)+h
		fp10=call_function(name,temp)
;
		temp(nx)=xparam(nx)-h
		fm10=call_function(name,temp)
;
		return,(fp10+fm10-2.d0*f00)/h^2

	endif else begin

;
; 2nd partial derivative with respect to the different
; variables

		hx=abs(xparam(nx)*0.001d0)
		hy=abs(xparam(ny)*0.001d0)
		if (hx LT 0.01) then begin
			hx=0.01d0
		endif
		if (hy LT 0.01) then begin
			hy=0.01d0
		endif
;
		temp(nx)=xparam(nx)+hx
		temp(ny)=xparam(ny)+hy
		fp1p1=call_function(name,temp)
;
		temp(nx)=xparam(nx)+hx
		temp(ny)=xparam(ny)-hy
		fp1m1=call_function(name,temp)
;
		temp(nx)=xparam(nx)-hx
		temp(ny)=xparam(ny)+hy
		fm1p1=call_function(name,temp)
;
		temp(nx)=xparam(nx)-hx
		temp(ny)=xparam(ny)-hy
		fm1m1=call_function(name,temp)

		return,(fp1p1+fm1m1-fp1m1-fm1p1)/4.d0/hx/hy
	endelse

end

;************************************************


;************************************************
; Compute likelihood output
;************************************************

Function likelihoodchang,param
	common data,xdata,ydata
	common tofit,functionfit
	common tofit1,functionfit1
	common pl,chisr,nplot
	y1=call_function(functionfit,param,xdata)
	y1=call_function(functionfit1,param,xdata)+y1
	Nxdata=N_elements(xdata)
	y2=dblarr(Nxdata)
	y2(0:Nxdata-1)=exp(param(4))
	
	l=(exp(-ydata/y1)-exp(-ydata/y2))/(y1-y2)

;	a=(y2-y1)
;	b=(y3-y1)
;	c=(y3-y2)

;	l=y1*exp(-ydata/y1)/a/b
	
;	l=l-y2*exp(-ydata/y2)/a/c
	
;	l=l+y3*exp(-ydata/y3)/b/c
	
	l=-alog(l)
;	plot,xdata,l
;	read,blurp
	return,total(l,/double)
end

;************************************************


;************************************************
; Compute derivative of likelihood output
;************************************************

Function dlikelihoodchang,param
	Nparam=N_elements(param)
	deriv=param
	temp=param
	for i=0,Nparam-1 do begin
		h=param(i)*0.001
		if (h LT 0.01) then begin
			h=0.01
		endif
		temp(i)=param(i)+h
		yp1=likelihoodchang(temp)
		temp(i)=param(i)-h
		ym1=likelihoodchang(temp)
		deriv(i)=(yp1-ym1)/2/h
	endfor
	return,deriv
end

;************************************************


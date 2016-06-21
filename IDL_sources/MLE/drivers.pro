pro fitplotsingle,xdata,ydata,funcname,param,error,tol,Freqstart,Dataname,printer,fixed=instring,nodfp=inalgo,startpl=startpl,corr=correlout,Themin=zmin

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOTSINGLE
; CALLING SEQUENCE:
;	fitplotsingle,xdata,ydata,funcname,param,error,tol,Freqstart,Dataname,printer,instring,/nodfp
; PURPOSE:
;	Plot ydata as a function of xdata on the screen or on a printer
;	and fit the data using Maximum Likelihood Estimators.  It plot the 
;       starting fit and then the output fit.
;	It works only for a single spectrum
; INPUTS:
;	xdata 		frequency of the points centered on zero (Npoints)
;	ydata 		power spectra (Npoints, 2*degree+1)
; 	funcname	name of the function of the full profile
;	param		starting parameter of the profile to be fitted (coherent with funcname)
;	tol		tolerance for the algorithms. tol=dblarr(2) tol(0) for powell, tol(1) for dfp
;	Freqstart	frequency of the mode (for printing only)
;	Dataname	name to be given to the data (LOI, LOWL, SOI, etc...)
;	printer		put your favorite printer name here.  An empty string (0 length) means
;			that you go to your x monitor
; OPTIONAL KEYWORDS:
; 	fixed		This is to give the fixed parameters as a string,
;			for example if param has 6 elements, 2 of those
;			elements can be fixed by setting instring='010010'
;	startpl		If set plot starting fit
; OUTPUTS:
;	param		fitted parameters
;	error		error matrix
;	Plot the spectra and the fit
;	Print the values of the fit (frequency, splitting,...) with their error bars
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at multi.pro for examples
; LIMITATIONS:
;	Print out sequence to your favorite printer may need to be adapted to your system
; COMMONS:
;	None
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, June,  1, 1995
;	Beta 2: TA, June, 6, 1995.  Made the routine more self consistent by
;		reducing the number of parameters to be called.
;		WARNING: Now you need to give the function to which you fit and
;			 the starting parameters for the fit.
;		Remove the print out sequence of the parameters and their errors
;	Beta 3: TA, June, 9, 1995. Remove parameters: degree and amplitude to make the
;		routine more general.  Degree was NOT use in the routines. amplitude 
;		is not passed as a common to the user defined function. 
;		For helioseismologists amplitude should be defined in the main program
;	Beta 4: TA, Add the fixed parameters stuff, June 13, 1995
;	Beta 5: TA, Choice of algorithm (powell or dfp, or both), November 4, 1995
;	Beta 6: TA, Now return the value of Fmin, January 30, 1998
;	Beta 7: TA, Add the return of the correlation matrix, September 30, 1998
;	Beta 8: TA, Plot fit in color, April 20, 2001
;------------------------------------------------------------------------------
	common tofit,functionfit
	common lmin,Fmin
	functionfit=funcname
;
	common speed,Neval
	Neval=0.
;
	y=ydata
;
	Nparam=N_elements(param)
	error=dblarr(Nparam)
;
;plot it
	if (strlen(printer) NE 0) then begin
		set_plot,'ps'
	endif else begin
		set_plot,'x'
	endelse
	plot,xdata,ydata,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data',xstyle=1
	print,"plotted"
	print,""
;fit data profile
;
	If (keyword_set(startpl)) then begin
		y=call_function(funcname,param,xdata)
		oplot,xdata,y
	endif
	nfunc=0
	print,n_elements(instring),n_elements(inalgo)
	if (n_elements(correlout) eq 0) then begin

	if (n_elements(instring) gt 0) then begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,nodfp=inalgo
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,/nodfp
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring
		endelse
	endif else begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,nodfp=inalgo
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,/nodfp
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol
		endelse
	endelse

	endif else begin
	
	if (n_elements(instring) gt 0) then begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,nodfp=inalgo,corr=correlout
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,/nodfp,corr=correlout
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,corr=correlout
		endelse
	endif else begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,nodfp=inalgo,corr=correlout
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,/nodfp,corr=correlout
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,corr=correlout
		endelse
	endelse

	endelse
;
; compute fit
	y=call_function(funcname,param,xdata)
;
	loadct,39
	oplot,xdata,y,color=150
;
	if (strlen(printer) NE 0) then begin
		device,/close
		psfile='idl.ps'
		spawn,/sh, 'lp -c -d '+printer+' ' + psfile
		set_plot,'x'
	endif

	If (n_elements(zmin) gt 0) then begin
		print,'Transfering data!'
		zmin=Fmin
	endif
end



pro fitplot,xdata,ydatain,funcname,param,error,degree,tol,Freqstart,Dataname,printer,fixed=instring,nodfp=inalgo,as=as,startpl=startpl,corr=correlout,nofit=nofit,Themin=Themin
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOT 
; CALLING SEQUENCE:
;	fitplot,xdata,ydata,funcname,param,error,amplitude,degree,tol,Freqstart,Dataname,printer,instring,/nodfp
; PURPOSE:
;	Plot ydata as a function of xdata on the screen or on a printer
;	and fit the data using Maximum Likelihood Estimators.  It plot the 
;       starting fit and then the output fit.
;	It works only for an m,nu diagram
; INPUTS:
;	xdata 		frequency of the points centered on zero (Npoints)
;	ydata 		power spectra (Npoints, 2*degree+1)
; 	funcname	name of the function of the full profile
;	param		starting parameter of the profile to be fitted (coherent with funcname)
;	degree		degree(sic)
;	tol		tolerance for the algorithms. tol=dblarr(2) tol(0) for powell, tol(1) for dfp
;	Freqstart	frequency of the mode (for printing only)
;	Dataname	string name to be given to the data (LOI, LOWL, SOI, etc...)
;	printer		string put your favorite printer name here.  An empty string (0 length) means
;			that you go to your x monitor
; OPTIONAL KEYWORDS:
; 	fixed		This is to give the fixed parameters as a string,
;			for example if param has 6 elements, 2 of those
;			elements can be fixed by setting instring='010010'
;	as		If set, we fit the amplitude spectrum instead
;			ydata is then complex
;	startpl		If set plot the starting fit
; OUTPUTS:
;	param		fitted parameters
;	error		error matrix
;	Plot the spectra and the fit
;	Print the values of the fit (frequency, splitting,...) with their error bars
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at tene.pro or steve.pro for examples
; LIMITATIONS:
;	Cannot handle single spectrum (yet)
;	Print out sequence to your favorite printer may need to be adapted to your system
; COMMONS:
;	None 
; PROCEDURES USED:
;       peakLOI, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, May, 29, 1995
;	Beta 2: remove wrong statetment for Degree=5, TA, June, 2, 1995
;	Beta 3: TA, June, 6, 1995.  Made the routine more self consistent by
;		reducing the number of parameters to be called.
;		WARNING: Now you need to give the function to which you fit and
;			 the starting parameters for the fit.
;		Remove the print out sequence of the parameters and their errors
;	Beta 4: TA, Add the fixed parameters stuff, August 25, 1995
;	Beta 5: TA, Choice of power or amplitude spectrum fitting, Ocotber 11, 1995
;	Beta 6: TA, Choice of algorithm (powell or dfp, or both), October 25, 1995
;	Beta 7: TA, Remove side effect ydatain is NOT touched
;	Beta 8: TA, Add startpl keyword, August 29, 1996
;	Beta 9: TA, Add the return of the correlation matrix, August 1, 1997
;	Beta 10: TA, Add nofit options if one want to see only the data, August 11, 1997
;	Beta 11: TA, Add the xtitle (Frequency in microHz), September 17, 1997
;	Beta 12: TA, Now return the minimum fitted, Fmin, February 3,
;	1998
;       Beta 13: TA, Now plot the guess when fitting amplitude,
;       October 18, 2001
;------------------------------------------------------------------------------
	common multiplet,peak
	common cross,crossparam
	common tofit,functionfit
	common lmin,Fmin
	functionfit=funcname
;
	common speed,Neval
	Npoints=N_elements(xdata)
	Neval=0.
;number of modes
	N=2*degree+1
;
	ydata=ydatain
	dim=size(ydata)
	print,dim
	y=ydata
;
	Nparam=N_elements(param)
	error=dblarr(Nparam)
	correlout=dblarr(Nparam,Nparam)
;
; set variable offset as a function of the maximum
;
	If (keyword_set(as)) then begin
		if (degree ne 0.5) then begin
			plotdata=abs(ydatain)^2
			nfunc=4
			print,'Perform fit on the amplitude spectra.'
		endif else begin
			nfunc=7
			print,'Perform fit on the amplitude spectra for the phase shift'
			ydata=dblarr(Npoints,4)
			ydata(*,0)=float(ydatain(*,0))
			ydata(*,1)=imaginary(ydatain(*,0))
			ydata(*,2)=float(ydatain(*,1))
			ydata(*,3)=imaginary(ydatain(*,1))
		endelse
	endif else begin
		if ((dim(3) eq 9) or (dim(3) eq 6))  then begin
			ydata=abs(ydatain)^2    ; input data are complex but as is not set
			plotdata=ydata
			nfunc=2
			print,'Perform fit on the power spectra with the input amplitude spectra'
		endif else begin
			plotdata=ydatain        ; input data are real and as is not set
			nfunc=2
			print,'Perform fit on the power spectra'
		endelse
	endelse
	
;plot it
	If (keyword_set(as)) then begin
		offsetr=max(abs(float(ydatain)))
		offseti=max(abs(imaginary(ydatain)))
		offset=1.1*max(offsetr,offseti)
		delta=4.*offset
		plotdata=dblarr(Npoints,2*N)
		for i=0,N-1 do begin
			plotdata(*,2*i)=float(ydatain(*,i))-delta*N/2.+4.*i*offset+offset
			plotdata(*,2*i+1)=imaginary(ydatain(*,i))-delta*N/2.+4.*i*offset+2.*offset+offset
		endfor
		ymin=-delta*N/2.
		ymax=delta*N/2.
	endif else begin
		offset=1.1*max(plotdata)
		for i=0,N-1 do begin
			plotdata(*,i)=plotdata(*,i)+offset*(i-degree)
		endfor
		ymin=-degree*offset
		ymax=+degree*offset+offset
	endelse
;
	if (strlen(printer) NE 0) then begin
		set_plot,'ps'
	endif else begin
		set_plot,'x'
	endelse

	loadct,39
	
	if (keyword_set(as)) then begin
		plot,xdata,plotdata(*,0),YRANGE=[ymin,ymax],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data',xtitle='Frequency (in !4l!6Hz)'
		for i=1,2*N-1 do begin
			oplot,xdata,plotdata(*,i)
		endfor
		print,'plot amplitude'
	endif else begin
		plot,xdata,plotdata(*,0),YRANGE=[ymin,ymax],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data',xtitle='Frequency (in !4l!6Hz)'
		for i=1,N-1 do begin
			oplot,xdata,plotdata(*,i)
		endfor
		print,'plot power'
	endelse
		print,"plotted"
	print,""
;
; compute starting fit
	call_procedure,funcname,param,xdata,y
        help,y
;
;
;plot it
	ploty=y
	if (not keyword_set(as)) then begin
		If (keyword_set(startpl)) then begin
                        Print,'plot starting guess'
			for i=0,N-1 do begin
				ploty(*,i)=ploty(*,i)+offset*(i-degree)
				oplot,xdata,ploty(*,i),color=150
			endfor
		endif
            endif else begin
                If (keyword_set(startpl)) then begin
                        Print,'plot starting guess'
			for i=0,N-1 do begin
				zz=sqrt(ploty(i,i,*))-delta*N/2.+4.*i*offset+offset
				oplot,xdata,zz,color=150
                                zz=-sqrt(ploty(i,i,*))-delta*N/2.+4.*i*offset+offset
                                oplot,xdata,zz,color=200
                                zz=sqrt(ploty(i,i,*))-delta*N/2.+4.*i*offset+2.*offset+offset
                                oplot,xdata,zz,color=150
                                zz=-sqrt(ploty(i,i,*))-delta*N/2.+4.*i*offset+2.*offset+offset
                                oplot,xdata,zz,color=200
                        endfor
		endif
        endelse        

;
; fit
;
	print,tol
	print,n_elements(instring),n_elements(inalgo)


	if (not keyword_set(nofit)) then begin
		print,'Fitting...'
	if (n_elements(correlout) eq 0) then begin

	if (n_elements(instring) gt 0) then begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,nodfp=inalgo
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,/nodfp
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring
		endelse
	endif else begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,nodfp=inalgo
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,/nodfp
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol
		endelse
	endelse

	endif else begin
	
	if (n_elements(instring) gt 0) then begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,nodfp=inalgo,corr=correlout
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,/nodfp,corr=correlout
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,corr=correlout
		endelse
	endif else begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,nodfp=inalgo,corr=correlout
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,/nodfp,corr=correlout
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,corr=correlout
		endelse
	endelse

	endelse

	

;
;
; compute fit
;	
		call_procedure,funcname,param,xdata,y
;
;plot output parameters
;
	ploty=y
		if (not keyword_set(as)) then begin
			for i=0,N-1 do begin
				ploty(*,i)=ploty(*,i)+offset*(i-degree)
				oplot,xdata,ploty(*,i),color=150
			endfor
		endif
	endif

	if (strlen(printer) NE 0) then begin
		device,/close
		psfile='idl.ps'
		spawn,/sh, 'lp -c -d '+printer+' ' + psfile
		set_plot,'x'
	endif

	If (n_elements(Themin) gt 0) then begin
		print,'Transfering data!'
		Themin=Fmin
	endif


end



pro fitplotnew,xdata,ydata,funcname,funcname1,param,error,tol,Freqstart,Dataname,printer,fixed=instring,nodfp=inalgo,startpl=startpl

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOTNEW
; CALLING SEQUENCE:
;	fitplotnew,xdata,ydata,funcname,funcname1,param,error,tol,Freqstart,Dataname,printer,instring,/nodfp
; PURPOSE:
;	Plot ydata as a function of xdata on the screen or on a printer
;	and fit the data using Maximum Likelihood Estimators.  It plot the 
;       starting fit and then the output fit.
;	It works only for a single spectrum
; INPUTS:
;	xdata 		frequency of the points centered on zero (Npoints)
;	ydata 		power spectra (Npoints, 2*degree+1)
; 	funcname	name of the function of the m=-1 profile
;	funcname1	name of the function of the m=+1 profile
;	param		starting parameter of the profile to be fitted (coherent with funcname)
;	tol		tolerance for the algorithms. tol=dblarr(2) tol(0) for powell, tol(1) for dfp
;	Freqstart	frequency of the mode (for printing only)
;	Dataname	name to be given to the data (LOI, LOWL, SOI, etc...)
;	printer		put your favorite printer name here.  An empty string (0 length) means
;			that you go to your x monitor
; OPTIONAL KEYWORDS:
; 	fixed		This is to give the fixed parameters as a string,
;			for example if param has 6 elements, 2 of those
;			elements can be fixed by setting instring='010010'
;	startpl		If set plot starting fit
; OUTPUTS:
;	param		fitted parameters
;	error		error matrix
;	Plot the spectra and the fit
;	Print the values of the fit (frequency, splitting,...) with their error bars
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at multi.pro for examples
; LIMITATIONS:
;	Print out sequence to your favorite printer may need to be adapted to your system
; COMMONS:
;	None
; PROCEDURES USED:
;       definepeak, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, Sptembre,  11, 1995
;------------------------------------------------------------------------------
	common tofit,functionfit
	common tofit1,functionfit1
	functionfit=funcname
	functionfit1=funcname1
;
	common speed,Neval
	Neval=0.
;
	y=ydata
;
	Nparam=N_elements(param)
	error=dblarr(Nparam)
;
;plot it
	if (strlen(printer) NE 0) then begin
		set_plot,'ps'
	endif else begin
		set_plot,'x'
	endelse
	plot,xdata,ydata,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data',xstyle=1
	print,"plotted"
	print,""
;fit data profile
;
	If (keyword_set(startpl)) then begin
		y=call_function(funcname,param,xdata)
		y=y+call_function(funcname1,param,xdata)
		oplot,xdata,y
	endif
	nfunc=6
	print,n_elements(instring),n_elements(inalgo)
	if (n_elements(instring) gt 0) then begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,nodfp=inalgo
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring,/nodfp
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol,fixed=instring
		endelse
	endif else begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,nodfp=inalgo
			endif else begin
				MLEfit,xdata,ydata,nfunc,param,error,tol,/nodfp
			endelse
		endif else begin
			MLEfit,xdata,ydata,nfunc,param,error,tol
		endelse
	endelse
;
; compute fit
	y=call_function(funcname,param,xdata)
	y=y+call_function(funcname1,param,xdata)
;
	oplot,xdata,y
;
	if (strlen(printer) NE 0) then begin
		device,/close
		psfile='idl.ps'
		spawn,/sh, 'lp -c -d '+printer+' ' + psfile
		set_plot,'x'
	endif
end


pro fitplotalias,xdata,ydatain1,ydatain2,funcname,param,error,degrees,tol,Freqstart,Dataname,printer,fixed=instring,nodfp=inalgo,as=as,startpl=startpl,corr=correlout
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	FITPLOTALIAS 
; CALLING SEQUENCE:
;	fitplotalias,xdata,ydatain1,ydatain2,funcname,param1,param2,error1,error2,degrees,tol,Freqstart,Dataname,printer,/nodfp
; PURPOSE:
;	Plot ydata as a function of xdata on the screen or on a printer
;	and fit the data using Maximum Likelihood Estimators.  It plot the 
;       starting fit and then the output fit for the alias
;	It works only for an m,nu diagram
; INPUTS:
;	xdata 		frequency of the points centered on zero (Npoints)
;	ydata 		power spectra (Npoints, 2*degree+1)
; 	funcname	name of the function of the full profile
;	param		starting parameter of the profile to be fitted (coherent with funcname)
;	degree		degree(sic)
;	tol		tolerance for the algorithms. tol=dblarr(2) tol(0) for powell, tol(1) for dfp
;	Freqstart	frequency of the mode (for printing only)
;	Dataname	string name to be given to the data (LOI, LOWL, SOI, etc...)
;	printer		string put your favorite printer name here.  An empty string (0 length) means
;			that you go to your x monitor
; OPTIONAL KEYWORDS:
; 	fixed		This is to give the fixed parameters as a string,
;			for example if param has 6 elements, 2 of those
;			elements can be fixed by setting instring='010010'
;	as		If set, we fit the amplitude spectrum instead
;			ydata is then complex
;	startpl		If set plot the starting fit
; OUTPUTS:
;	param		fitted parameters
;	error		error matrix
;	Plot the spectra and the fit
;	Print the values of the fit (frequency, splitting,...) with their error bars
; OPTIONAL OUTPUT:
;	none
; EXAMPLE:
;	Look at tene.pro or steve.pro for examples
; LIMITATIONS:
;	Cannot handle single spectrum (yet)
;	Print out sequence to your favorite printer may need to be adapted to your system
; COMMONS:
;	None 
; PROCEDURES USED:
;       peakLOI, spectraltene, MLEfit (calls NR_Powell, NR_dfpmin, hessian)
; MODIFICATION HISTORY:
;	Beta 1: WRITTEN, Thierry Appourchaux, October 30, 1996
;	Beta 2: Implemented in a dumb way the printing of the fitted data, November 1st, 1996
;------------------------------------------------------------------------------
	common multiplet1,peak1
	common cross1,crossparam1
	common tofit1,functionfit1
	common multiplet2,peak2
	common cross2,crossparam2
	common tofit2,functionfit2

	!p.multi=[0,2,1]

	functionfit1=funcname(0)
	functionfit2=funcname(1)
;
	common speed,Neval
	Npoints=N_elements(xdata)
	Neval=0.
;number of modes
	N=2*degrees+1
;
	ydata1=ydatain1
	ydata2=ydatain2
	dim=size(ydata1)
	print,dim
	y1=ydata1
;
	Nparam=N_elements(param)
	error=dblarr(Nparam)
	correlout=dblarr(Nparam,Nparam)
;
; set variable offset as a function of the maximum
;
	If (keyword_set(as)) then begin
		plotdata=abs(ydatain)^2
		nfunc=4
		print,'Perform fit on the amplitude spectra'
	endif else begin
		if ((dim(3) eq 9) or (dim(3) eq 6))  then begin
			ydata1=abs(ydatain1)^2    ; input data are complex but as is not set
			ydata2=abs(ydatain2)^2
			plotdata1=ydatain1
			plotdata2=ydatain2
			nfunc=2
			print,'Perform fit on the power spectra with the input amplitude spectra'
		endif else begin
			plotdata1=ydatain1       ; input data are real and as is not set
			plotdata2=ydatain2
			nfunc=7
			print,'Perform fit on the power spectra'
		endelse
	endelse
	
;plot it
	If (keyword_set(as)) then begin
		offsetr=max(abs(float(ydatain)))
		offseti=max(abs(imaginary(ydatain)))
		offset=max(offsetr,offseti)
		delta=4.*offset
		plotdata=dblarr(Npoints,2*N)
		for i=0,N-1 do begin
			plotdata(*,2*i)=float(ydatain(*,i))-delta*N/2.+4.*i*offset+offset
			plotdata(*,2*i+1)=imaginary(ydatain(*,i))-delta*N/2.+4.*i*offset+2.*offset+offset
		endfor
		ymin=-delta*N/2.
		ymax=delta*N/2.
	endif else begin
		offset1=max(plotdata1)
		for i=0,N(0)-1 do begin
			plotdata1(*,i)=plotdata1(*,i)+offset1*(i-degrees(0))
		endfor
		ymin1=-degrees(0)*offset1
		ymax1=+degrees(0)*offset1+offset1
		
		offset2=max(plotdata2)
		for i=0,N(1)-1 do begin
			plotdata2(*,i)=plotdata2(*,i)+offset2*(i-degrees(1))
		endfor
		ymin2=-degrees(1)*offset2
		ymax2=+degrees(1)*offset2+offset2

	endelse
;
	loadct,0
	
	if (keyword_set(as)) then begin
		plot,xdata,plotdata(*,0),YRANGE=[ymin,ymax],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data'
		for i=1,2*N-1 do begin
			oplot,xdata,plotdata(*,i)
		endfor
		print,'plot amplitude'
	endif else begin
		plot,xdata,plotdata1(*,0),YRANGE=[ymin1,ymax1],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1),xstyle=1
		for i=1,N(0)-1 do begin
			oplot,xdata,plotdata1(*,i)
		endfor
		print,'plot power'
	endelse
		print,"plotted"
	print,""
;
; compute starting fit

	call_procedure,funcname(0),param,xdata,y1
;
;
;plot it
	ploty1=y1
	if (not keyword_set(as)) then begin
		If (keyword_set(startpl)) then begin
			for i=0,N(0)-1 do begin
				ploty1(*,i)=ploty1(*,i)+offset1*(i-degrees(0))
				oplot,xdata,ploty1(*,i),color=150
			endfor
		endif
	endif
;
;
	if (keyword_set(as)) then begin
		plot,xdata,plotdata(*,0),YRANGE=[ymin,ymax],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1),xstyle=1
		for i=1,2*N-1 do begin
			oplot,xdata,plotdata(*,i)
		endfor
		print,'plot amplitude'
	endif else begin
		plot,xdata,plotdata2(*,0),YRANGE=[ymin2,ymax2],YSTYLE=1,TITLE=' from '+dataname+' data',xstyle=1
		for i=1,N(1)-1 do begin
			oplot,xdata,plotdata2(*,i)
		endfor

		print,'plot power'
	endelse
		print,"plotted"
	print,""

; compute starting fit
	call_procedure,funcname(1),param,xdata,y2
	ploty2=y2
	if (not keyword_set(as)) then begin
		If (keyword_set(startpl)) then begin
			for i=0,N(1)-1 do begin
				ploty2(*,i)=ploty2(*,i)+offset2*(i-degrees(1))
				oplot,xdata,ploty2(*,i),color=150
			endfor
		endif
	endif

;
; fit
;
	print,tol
	print,n_elements(instring),n_elements(inalgo)
	if (n_elements(instring) gt 0) then begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfitalias,xdata,ydata1,ydata2,nfunc,param,error,tol,fixed=instring,nodfp=inalgo,corr=correlout
			endif else begin
				MLEfitalias,xdata,ydata1,ydata2,nfunc,param,error,tol,fixed=instring,/nodfp,corr=correlout
			endelse
		endif else begin
			MLEfitalias,xdata,ydata1,ydata2,nfunc,param,error,tol,fixed=instring,corr=correlout
		endelse
	endif else begin
		if (n_elements(inalgo) gt 0) then begin
			if (strlen(inalgo) eq 2) then begin
				MLEfitalias,xdata,ydata1,ydata2,nfunc,param,error,tol,nodfp=inalgo,corr=correlout
			endif else begin
				MLEfitalias,xdata,ydata1,ydata2,nfunc,param,error,tol,/nodfp,corr=correlout
			endelse
		endif else begin
			MLEfitalias,xdata,ydata1,ydata2,nfunc,param,error,tol,corr=correlout
		endelse
	endelse

;plot it
	if (strlen(printer) NE 0) then begin
		set_plot,'ps'
		device,/landscape
	endif else begin
		set_plot,'x'
	endelse

	loadct,0
	
	if (keyword_set(as)) then begin
		plot,xdata,plotdata(*,0),YRANGE=[ymin,ymax],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data'
		for i=1,2*N-1 do begin
			oplot,xdata,plotdata(*,i)
		endfor
		print,'plot amplitude'
	endif else begin
		plot,xdata,plotdata1(*,0),YRANGE=[ymin1,ymax1],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1),xstyle=1
		for i=1,N(0)-1 do begin
			oplot,xdata,plotdata1(*,i)
		endfor
		print,'plot power'
	endelse
		print,"plotted"
	print,""
;
; compute fit

	call_procedure,funcname(0),param,xdata,y1
;
;
;plot it
	ploty1=y1
	if (not keyword_set(as)) then begin
		If (keyword_set(startpl)) then begin
			for i=0,N(0)-1 do begin
				ploty1(*,i)=ploty1(*,i)+offset1*(i-degrees(0))
				oplot,xdata,ploty1(*,i),color=150
			endfor
		endif
	endif
;
;
	if (keyword_set(as)) then begin
		plot,xdata,plotdata(*,0),YRANGE=[ymin,ymax],YSTYLE=1,TITLE='Fit for Frequency='+strtrim(Freqstart,1)+' from '+dataname+' data',xstyle=1
		for i=1,2*N-1 do begin
			oplot,xdata,plotdata(*,i)
		endfor
		print,'plot amplitude'
	endif else begin
		plot,xdata,plotdata2(*,0),YRANGE=[ymin2,ymax2],YSTYLE=1,TITLE=' from '+dataname+' data',xstyle=1
		for i=1,N(1)-1 do begin
			oplot,xdata,plotdata2(*,i)
		endfor

		print,'plot power'
	endelse
		print,"plotted"
	print,""

; compute fit
	call_procedure,funcname(1),param,xdata,y2
	ploty2=y2
	if (not keyword_set(as)) then begin
		If (keyword_set(startpl)) then begin
			for i=0,N(1)-1 do begin
				ploty2(*,i)=ploty2(*,i)+offset2*(i-degrees(1))
				oplot,xdata,ploty2(*,i),color=150
			endfor
		endif
	endif




	if (strlen(printer) NE 0) then begin
		device,/close
		psfile='idl.ps'
		spawn,/sh, 'lp -c -d '+printer+' ' + psfile
		set_plot,'x'
	endif


end

;********************************************************************
;
; Routine for fitting the SOHO LOI spectra
;
; degree is the degree (sic)
;
; wild is a string for various file name (i.e. 'new', 'old', etc...) 
;
; istart is the frequency number where should start the iteration
;
; tol is the tolerance for the Power algorithm
;
;*********************************************************************

pro fitgong,degree,wild,istart,tol,printer,window
        common crosstalk,ctnm1
        common matbruit,croiseen
	common speed,Neval
        common nb_bruit, nbbruit



	nn=N_params()
	if (nn LT 8) then begin
		print,''
		if (nn EQ 0) then begin
			read,'give the degree of the mode= ',degree
			print,''
			degree=floor(degree)
			nn=nn+1
		endif
		if (nn EQ 1) then begin
			wild=''
		  	read,'give the wid card of your file as a string= ',wild
			print,''
			nn=nn+1
		endif
		if (nn EQ 2) then begin
		     	read,'give the starting point for the fit= ',istart
			print,''
			istart=floor(istart)
			nn=nn+1
		endif
		if (nn EQ 3) then begin
		        read,'give tolerance for the Powell algorithm (1d-06 works well on a Sparc20...)= ',tol
			print,''
			nn=nn+1
		endif
		if (nn EQ 4) then begin
			printer=''
		        read,'give the printer output as a string (press return to redirect to your monitor)= ',printer
			print,''
			nn=nn+1
		endif
		if (nn EQ 5) then begin
		        read,'window size (in microHz) ',window
			print,''
			nn=nn+1
		endif
        endif
	Neval=0.

nbbruit=1


central=dblarr(5,9)

Central=[[0,1,2,3,4,5,6,7,8,0,10,11,12,13,14,15],$
		 [2021,2157,2292,2425,2559,2693,2828,2963.3,3098.7,3233.2,3368,3504,3640,3777,3914,4052],$
		 [2084,2217,2352,2486,2619,2754,2889,3024,3159,3295,3430,3567,3703,3838,3976,4113],$
		 [2138,2274,2408,2542,2676,2811,2947,3083,3218,3354,3490,3626,3761,3898,4035,4172],$
		 [2188,2324,2458,2593,2729,2864,3000,3136,3272,3408,3544,3682,3819,3958,4095,4232],$
		 [2235,2371,2506,2642,2777,2913,3050,3186,3323,3458,3594,3735,3872,4010,4151,4292],$
		 [2280,2416,2551,2687,2823,2960.69,3097.28,3234.04,3371,3508,3646,3784,3922,4061,4201,4342],$
		 [2322,2458,2594,2731,2868,3006,3143,3280,3417,3555,3693,3831,3970,4108,4249,4390]]


;**************** PLEASE ADAPT TO YOUR OWN ****************************
;*******************READING DATA FILE *********************************
;*********************DEFINE THE DATA AND THE XDATA *******************



wild='/home/thierrya/SOHOdata/specsoho'+wild 
		filename=wild+strtrim(degree,1)
		buffer=readfits(filename,zozo)
print, zozo
		Nfourier=N_elements(buffer)/(2*degree+1)/2
		resol=1000000./60./Nfourier/2.
		Npoints=floor(window/resol)
		Npoints=Npoints+ Npoints mod 2
		data=dcomplex(buffer(*,*,0),buffer(*,*,1))	
                data(*,0:degree-1)=conj(data(*,0:degree-1))


xdata=(dindgen(Npoints)-Npoints/2)*resol


;************************** END READ FILE AND STUFF *******************







;*************CROSSTALK MODE MATRICES**********************************
;**************** PLEASE ADAPT TO YOUR OWN ****************************
;****************THIS IS FOR THE LOI CASE******************************

	ctnm1=dblarr(2*degree+1,2*degree+1)

	ct,degree,0.9,ctnm1


	print,'Computed crosstalk is....'
	print,ctnm1
	print,'Go back and do some work...'
	print,'You better compute the crosstalk yourself!'



;************************** END MODE CROSSTALK ************************


;************** NOISE COVARAIANCE MATRICES ****************************
;**************** SAME AS THE MODE CROSSTALK **************************
;********PLEASE ADAPT TO YOU OWN **************************************

	croiseen=dblarr(nbbruit,2*degree+1,2*degree+1)

	croiseen=ctnm1



;*******END NOISE COVARIANCE*************************************



;-------------------------------- number of parameters
; 1 freq + 1 bruits + 1 largeur + 2 splits + 2*l+1 amplis 
; and 2 angles !

Nparam=2*degree+13

;-------- rajout d'un parametre pipo
Nparam=Nparam+1


param=dblarr(Nparam)
error=dblarr(Nparam)


;------------------- Here we set the fixed string 

;------- mode

;  freq, width, a1 
string='000'

;  a3
if (degree gt 1) then begin
 	string=string+'0'
endif else begin
        string=string+'1'
endelse

; amplitudes
for m=1,2*degree+1 do begin
	string=string+'0'
endfor

;------- noise

string_n='011111'

;--param pipo
param(Nparam-1)=0.



param(1)=alog(0.9)

param(4:2*degree+4)=-0.5

param(2*degree+7:2*degree+12)=-100.
if (nbbruit eq 3) then param(2*degree+7:2*degree+7+nbbruit-1)=-1.8
if (nbbruit eq 6) then param(2*degree+7:2*degree+7+nbbruit-1)=-2.5


;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$mega loop
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$mega loop
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$mega loop

if (degree eq 1) then filename='gong_1'
if (degree eq 2) then filename='gong_2'
if (degree eq 3) then filename='gong_3'

afile=findfile(filename+'*')


print,afile

longueur=N_elements(param)+1

pparamout=dblarr(longueur,30)
eerrorout=dblarr(longueur,30)
paramout=dblarr(longueur,30)
errorout=dblarr(longueur,30)
        
start=0

if (strlen(afile(0)) ne 0) then begin
	pparamin=readfits(afile(0))
	eerrorin=readfits(afile(1))

	start=N_elements(pparamin)/(N_elements(param)+1)

	pparamout(*,0:start-1)=pparamin
	eerrorout(*,0:start-1)=eerrorin


print, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'


endif









for ifreq=istart,15 do begin

	start=start+1



	param(0)=0.1


	param(2)=-0.410


	if (degree gt 1) then begin
         	param(3)=-0.010
	endif else begin
        	param(3)=0.
	endelse

	am=0.
	for i=0,2*degree do begin
      		am=am+exp(param(4+i))/(2.*degree+1.)
	endfor
	param(4:2*degree+4)=alog(am)

	br=0.
	for i=0,nbbruit-1 do begin
      		br=br+exp(param(2*degree+7+i))/(nbbruit*1.)
	endfor
	param(2*degree+7:2*degree+7+nbbruit-1)=alog(br)






	Cen=Central(ifreq,degree)

	Nstart=floor(Cen/resol)
	Freqstart=Nstart*resol

	print,"*******************************************"
	print,""
	print,"Central frequency ",Freqstart
	print,""
	print,"*******************************************"

	print,tol

	window=Npoints*resol
	print,"Window size=",window


	ydata=dcomplexarr(Npoints,2*degree+1)
	ydata(0:Npoints-1,*)=data(Nstart-Npoints/2:Nstart+Npoints/2-1,*)


;@@@@@@@@@@@@@@@@  we do not fit any Euler angle  
;
	startstring=string+'11'+string_n+'1'
;
	param(2*degree+5)=0.d0

	param(2*degree+6)=0.d0


	fitplot,xdata,ydata,'crosstalkgong',param,error,degree,tol,Freqstart,'LOI '+wild,printer,fixed=startstring,nodfp='10',/as


	print, param
	print, error

	pparamout(0:longueur-2,start-1)=param(0:longueur-2)
	pparamout(longueur-1,start-1)=ifreq
	eerrorout(0:longueur-2,start-1)=error(0:longueur-2)
	eerrorout(longueur-1,start-1)=ifreq
	pparamout(0,start-1)=param(0)+Freqstart


	writefits,filename+'_no',pparamout(*,0:start-1)
	writefits,filename+'_no_err',eerrorout(*,0:start-1)

endfor

end







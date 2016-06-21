pro sigma_filter_mean,array,unc_cube,cov_cube,weighted_average,coverage,Tint,Nsigma=Nsigma,Times=Times

if not keyword_set(Nsigma) then Nsigma=2.0
if not keyword_set(Times) then Times=1

ss=size(array,/dimension)

if n_elements(ss) ne 3 then begin
 print,'Array must have  3 dimensions'
 return
endif

nx=ss[0]
ny=ss[1]
nz=ss[2]

stack=median(array,dimension=3)



for i=0,Times-1 do begin

imstd=fltarr(nx,ny)
cover=fltarr(nx,ny)
	
	
	;;;;;;;;;;;;;;;;;;;;;calculate stddev for each pixel;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	for imosaic=0,nz-1 do begin
          imi=array[*,*,imosaic]
          ix=where(finite(imi) eq 1)
	  imstd[ix]=(imi[ix]-stack[ix])^2.0
	  cover[ix]=cover[ix]+1.0
        endfor	

	  imstd=sqrt(imstd/cover)
	
	;;;;;;;;;;;;;;;;;;;;;;;calculate good array for each pixel on each image;;;;;;;;;;;;;;;
	
        one={good:fltarr(nx,ny)}
        one.good=0
        good_cube=replicate(one,nz)
       
	low=stack-Nsigma*imstd
	 up=stack+Nsigma*imstd

        numerator  =fltarr(nx,ny)
	denominator=fltarr(nx,ny)
	coverage   =fltarr(nx,ny)
	
;;;;;;;;;;;;;;;;;calculate the weighted average for each pixel;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	for imosaic=0,nz-1 do begin
	
            imi=array[*,*,imosaic]
	  imcov=cov_cube[*,*,imosaic]
	   weight=1d0/(unc_cube[*,*,imosaic])^2.0
	  ix=where((finite(imi) eq 1) and (imi ge low) and (imi le up))   
	  good_cube[imosaic].good[ix]=1.0
	  ix1=where(finite(imi) eq 0)    
	 
	 weight[ix1]=0.0
	    imi[ix1]=0.0
	  imcov[ix1]=0.0
	
	  
	  array[*,*,imosaic]=array[*,*,imosaic]*good_cube[imosaic].good
	              weight=weight*good_cube[imosaic].good
	 
	 coverage=coverage+round(imcov)*good_cube[imosaic].good
	 numerator   = numerator  + imi*weight	   
	 denominator = denominator+ weight
	endfor	
 endfor
   weighted_average=numerator/denominator
   coverage=coverage*Tint 
  
 ;  outarray=array
end

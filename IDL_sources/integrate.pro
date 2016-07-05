function integrate,x,f
n=n_elements(x)
if(n_elements(f) ne n) then begin
   print,"Error in function integrate: x and f not equally long"
   stop 
endif
sign=2.d0*(x[n-1] gt x[0])-1.d0
int=0.d0
iact=0
if keyword_set(cons) then begin
   for i=1,n-1 do begin
      int=int+f[i-1]*(x[i]-x[i-1])
   endfor
endif else begin
   for i=1,n-1 do begin
      int=int+0.5d0*(f[i]+f[i-1])*(x[i]-x[i-1])
   endfor
endelse
return,int*sign
end

function integrate2,x,f,cumul=cumul,givecumul=givecumul
  n=n_elements(x)
  if(n_elements(f) ne n) then begin
     print,"Error in function integrate: x and f not equally long"
     stop 
  endif
  sign=2.d0*(x[n-1] gt x[0])-1.d0

  f_i=f[1:n-1]
  f_im1=f[0:n-2]
  x_i=x[1:n-1]
  x_im1=x[0:n-2]

  contritutions=0.5d0*(f_i+f_im1)*(x_i-x_im1)
  int=total(contritutions)

  if keyword_set(givecumul) then begin
    cumul=0.*contritutions
    cumul[0]=contritutions[0]
     for i=1,n-2 do cumul[i]=cumul[i-1]+contritutions[i]
  endif

  return,int*sign
end

pro test_m
  n=2^14
  x=dindgen(n)
  f=exp(-2*x/n)*cos(x/10.)

  k=64

  t1=systime(/seconds)
  for i=0,k do a=integrate(x,f)
  t2=systime(/seconds)
  for i=0,k do b=integrate2(x,f)
  t3=systime(/seconds)

  print,'difference: ',a-b
  print,'time required with for loop: ',t2-t1
  print,'time required using vector arithmic: ',t3-t2
end

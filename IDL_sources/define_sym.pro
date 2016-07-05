   pro define_sym,type,x,y
    if (type eq 'circle') then begin 
      y=cos(dindgen(40)*!pi/20.d0)
      x=sin(dindgen(40)*!pi/20.d0)
    endif
   end

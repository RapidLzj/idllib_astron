function remove_zero_value,data
  ss=size(data,/dim)
  if ss eq 0 then ss=1 
  name=strarr(ss)
  for i=0,ss[0]-1 do begin
     xx=strtrim(data[i],2)
     point_res=strpos(xx,'.')
    
     
     if point_res[0] ne -1 then begin
        strl=strlen(xx)    
        yy=strl
        for j=strl-1,point_res+2,-1 do begin
          if strmid(xx,j,1) eq '0' and strmid(xx,j-1,1) ne '0' then begin
             yy=j
             break
          endif 
         endfor        
                
       name[i]=strmid(xx,0,yy)                
     endif else begin
      name[i]=xx  
     endelse
    
  endfor
  return,name

end

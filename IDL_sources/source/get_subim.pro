function merger_get_subim,nx,ny,boxsize,overlap
;; purpose: to get the pixel ranges 
  
  length=0
  x1=0d0
  x2=0d0
  y1=0d0
  y2=0d0
  x1=[0d0]
  x2=[boxsize-1d0]
  jx=1
  while (length lt (nx-1)) do begin
    x1=[x1,jx*(boxsize-overlap)-1d0]
    x2=[x2,((jx+1d0)*boxsize-jx*overlap-2d0)<(nx-1)]
    jx=jx+1
    length=max(x2)
  endwhile

  length=0
  y1=[0LL]
  y2=[boxsize-1LL]
  jy=1
  while (length lt (ny-1)) do begin
    y1=[y1,jy*(boxsize-overlap)-1]
    y2=[y2,((jy+1)*boxsize-jy*overlap-2)<(ny-1)]
    jy=jy+1
    length=max(y2)
  endwhile

 print,'number of sub-frames in [x,y] direction: ['+strtrim(string(jx),2)+','+strtrim(string(jy),2)+']'
 
  ntotal=1l*jx*jy
  one={x1:0d0,x2:0d0,y1:0d0,y2:0d0}
  res=replicate(one,ntotal)

  print,'total number of sub-frames: '+strtrim(string(ntotal),2)

  count=0l
  for i=0,jx-1 do begin
    for k=0,jy-1 do begin
       res[count].x1=x1[i]
       res[count].x2=x2[i]
       res[count].y1=y1[k]
       res[count].y2=y2[k]
       count=count+1l
    endfor
  endfor
  return,res
end

pro test
mag=6
nshift=mag+1L-mag mod 2
one=make_array(nshift,value=1)
dx=((findgen(nshift)-nshift/2)/mag) #one
dy=one#((findgen(nshift)-nshift/2)/mag)
print,dx
end

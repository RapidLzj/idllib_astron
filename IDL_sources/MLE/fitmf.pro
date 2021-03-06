pro fitmf,A,B,C,D,E,degree
        nn=N_params()
; A amplitude , B frequency , C linewidth, D splitting
; E noise, degree 
;
        Neval=0
        resol=0.07
        readcol,'prae.lbt.izJK.3rd.DUSTY_20100526.CHECKED',type,name,ra1,$
        dec1,ra0,dec0,imag,ie,zmag,ze,jmag,je,kmag,ke,mass,teff,jabs,merr,terr,$
         format='a,a,d,d,a,a,d,d,d,d,d,d,d,d,d,d,d,d,d'
        ndata=20
        ydata=dblarr(ndata+1)*0.d0
        xdata=dblarr(ndata+1)
        mass_diff=max(mass)-min(mass)
        for i=0,ndata do xdata[i]=min(mass)+mass_diff/ndata*i 
        for i=0,ndata-1 do begin
          for k=0,n_elements(mass)-1 do begin
           if (mass[k] lt xdata[i+1] and mass[k] ge xdata[i]) then $
             ydata[i]=ydata[i]+1 
          endfor 
        endfor 
       i=ndata 
       for k=0,n_elements(mass)-1 do begin
           if (mass[k] ge xdata[i]) then ydata[i]=ydata[i]+1 
       endfor
       ydata=ydata/n_elements(mass)
       nw=100
;       lnL=dblarr(nw,nw)*0.d0
      plnL2pw1_1=sum(ydata)
      plnL2pw2_1=sum(ydata*alog(xdata))
       for i=0,ndata do begin
        lnL=lnL+ydata[i]*alog(
       endfor
stop
end

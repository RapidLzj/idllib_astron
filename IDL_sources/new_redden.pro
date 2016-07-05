function new_redden,lam,fnu,E_BminV,R=R,A_grey=A_grey,pars=pars
  ;; Returns reddened Fnu vector using formulae by Cardelli 1989,
  ;; lam in micron

  lam_V=0.55 ;; wavelength of V-band
  A_V=R*E_BminV
 
;; Cardelli 1989:
  x=1./lam
  y=x-1.82

  a_x=0.*lam
  b_x=0.*lam
;; for 0.3<=x<=1.1
;  index=where((x ge 0.3) and (x lt 1.1))
  index=where(x lt 1.1)
  if (index[0] ne -1) then begin
    a_x[index]=0.574*x[index]^1.61
    b_x[index]=-0.527*x[index]^1.61
  endif
;; for 1.1<=x<=3.3
  index=where((x ge 1.1) and (x lt 3.3))
  if (index[0] ne -1) then begin
    a_x[index]=1.+0.17699*y[index]-0.50447*y[index]^2.-0.02427*y[index]^3. $
               +0.72085*y[index]^4.+0.01979*y[index]^5. -0.77530*y[index]^6. $
               +0.32999*y[index]^7.
    b_x[index]=1.41338*y[index]+2.28305*y[index]^2.+1.07233*y[index]^3. $
             -5.38434*y[index]^4.-0.62251*y[index]^5.+5.30260*y[index]^6. $
             -2.09002*y[index]^7.
  endif
;; for 3.3<=x<=8.
;  index=where((x ge 3.3) and (x lt 8.0))
  index=where(x ge 3.3)
  if (index[0] ne -1) then begin
    a_x[index]=1.752-(0.316*x[index])-(0.104/((x[index]-4.67)^2.+0.341))
    b_x[index]=-3.090+(1.825*x[index])+(1.206/((x[index]-4.62)^2.+0.263))
  endif

  if keyword_set(pars) then if (pars.fiddle_grey ne '') then begin
    A_grey=0.
    A_grey=non_grey_redden(lam)
  endif

  A_lam=A_V*(a_x+(b_x/R))+A_grey


  fnu_unred=fnu*10.^(-0.4*A_lam)    ;Derive unreddened flux
  return,fnu_unred
end

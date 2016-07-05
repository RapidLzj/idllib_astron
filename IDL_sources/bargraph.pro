pro bargraph, YY, sigma=sigma,		$
	minbin=minbin, maxbin=maxbin, bin=bin, histo=histo,	$
	hatch=hatch, shade_color=shade_color, xrange=xrange, yrange=yrange, title=title,	$
	average=average, median=median, maximum=maximum,	$
	_extra=_extra, stat=stat, oplotx=oplotx

@compile_opt.pro			; On error, return to caller

;+
; NAME:
;	bargraph
; PURPOSE:
;	Plot bar graph
; CATEGORY:
;	Plotting
; CALLING SEQUENCE:
;	bargraph, Y, sigma=sigma,	$
;		minbin=minbin, maxbin=maxbin, bin=bin, histo=histo,	$
;		/hatch, xrange=xrange, yrange=yrange, title=title
;		/average, /median, /maximum
; INPUTS:
;	Y		array[n]; type: any numerical array
;				array to be plotted in bargraph
; OPTIONAL INPUTS:
;	sigma=sigma	scalar or array[n]; type: float
;				errors in Y-array
;				Ignored if /histo is set.
;				If sigma is not a scalar, but does not have the
;				same # elements as Y then it is ignored
;	/histo		if set the Y is passed through the IDL
;			histrogram function using keywords minbin, maxbin, bin
;	minbin		scalar; type: float; default: 0.0
;				minimum X-value = left edge of leftmost bin
;	bin		scalar; type: float; default: 1.0
;				bin width
;	maxbin		scalar; type: float
;				maximum Y-value, only used as keyword to
;				IDL histrogram function if /histo is set
;
;	/hatch		if set and nonzero, bins will be hatched
;	xrange=xrange	array[2]; type: float
;				xrange keyword to IDL plot command
;	yrange=yrange	array[2]; type: float
;				yrange keyword to IDL plot command
;	/average	if set, plot vertical line at position of average
;	/median		if set, plot vertical line at position of median
;	/maximum	if set, plot vertical line at position of maximum
;	title		scalar; type: string; default: value of bin width
;				title string
;	_extra=_extra	additional keywords passed to IDL plot command
; OPTIONAL OUTPUTS:
;	stat=stat	array[3]; type: float
;				positions of average, median and maximum
; CALLS:
;	statpos
; PROCEDURE:
; >	The number of bins is n_elements(Y)
; >	The bin edges are minbin+bin*indgen(n_elements(Y)+1)
; >	To plot a histogram of an array
;		bargraph,histogram(Y,min=25,max=350,bin=50),25,50
; MODIFICATION HISTORY:
;	AUG-1992, Paul Hick (UCSD/CASS)
;		Modification of HIST.PRO (Written Feb'91 by DMZ (ARC))
;	NOV-1992, Paul Hick (UCSD/CASS)
;		Added option to plot standard deviations
;	JAN-2000, Paul Hick (UCSD/CASS; pphick@ucsd.edu)
;		Minor modifications; added stat keyword
;-

hatch = keyword_set(hatch)
shade = n_elements(shade_color) ne 0
histo = keyword_set(histo)

if n_elements(minbin) eq 0 then minbin = 0.
if n_elements(   bin) eq 0 then    bin = 1.

case histo of
0: Y = YY
1: Y = histogram(YY,min=minbin,max=maxbin,bin=bin)
endcase

NY = n_elements(Y)
if NY eq 0 then message, 'Usage: bargraph, y'

isdev = not histo and n_elements(sigma) ne 0

if isdev then begin
	if n_elements(sigma) eq 1 then sigma = replicate(sigma[0], NY)

	isdev = n_elements(sigma) eq NY
	case isdev of
	0: message, 'Usage: bargraph, y, sigma=sigma (with same size arrays)'
	1: isdev = max(sigma) ne 0
	endcase
endif

Z = minbin+bin*findgen(NY+1)		; Bin edges

;-- set up plot window

if not keyword_set(title ) then title ='BIN WIDTH: '+string(bin,'(F6.2)')

xstyle = 1			; Exact scaling
if not keyword_set(xrange) then xrange = [min(Z),max(Z)]

ystyle = 1-keyword_set(yrange)		; Extend axis range, unless range specified
if ystyle eq 1 then begin
    p = where(xrange[0] le Z and Z le xrange[1])
    if isdev then yrange = [0,1.1*max(Y[p]+sigma[p])] else yrange = [0,1.1*max(Y[p])]
endif

;-- plot window for bar chart

if not keyword_set(oplotx) then	$
	plot, xrange, yrange, /nodata, xstyle=xstyle, ystyle=ystyle, $
		title=title, noclip=0, _extra=_extra

for i=0L,NY-1 do begin
	p = [Z[i]*[1,1],Z[i+1]*[1,1]]
	q = Y[i]*[0,1,1,0]
	oplot, p,q, noclip=0
	if shade ne 0 and Y[i] ne 0 then	$
		polyfill,p,q,color=shade_color ,noclip=0
	if hatch and Y[i] ne 0 then	$
		polyfill,p,q,spacing=hatch,orientation=([45,-45])[i mod 2] ,noclip=0
endfor

Yp = yrange[1]-0.025*(yrange[1]-yrange[0])
Xp = 0.01*(xrange[1]-xrange[0])

stat = minbin+bin*(statpos(Y)+0.5)

p = [keyword_set(AVERAGE), keyword_set(MEDIAN), keyword_set(MAXIMUM)]
if total(p) ne 0 then plotstat = where(p)

for i=0,n_elements(plotstat)-1 do begin
	q = plotstat[i]
	p = stat[q]
	oplot, p*[1,1], yrange, linestyle=2
	xyouts, p-Xp, Yp, (['AVERAGE','MEDIAN','MAXIMUM'])[q], orientation=90., align=1.
endfor

for i=0L,isdev*NY-1 do begin			; Plot errors
	p = 0.5*(Z[i]+Z[i+1])
	oplot, p*[1,1], Y[i]+sigma[i]*[-1,1], noclip=0
	dp = 0.15*(Z[i+1]-Z[i])
	q = Y[i]+sigma[i]
	oplot, p+dp*[-1,1], q*[1,1], noclip=0
	q = Y[i]-sigma[i]
	oplot, p+dp*[-1,1], [q,q], noclip=0
;	p = [Z[i]*[1,1],Z[i+1]*[1,1],Z[i]]
;	q = Y[i]+sigma[i]*[-1,1,1,-1,-1]
;	oplot, p,q, noclip=0
;	if Y[i] ne 0 and sigma[i] ne 0 then	$
;		polyfill,p,q,spacing=0.5*hatch,orientation=ORIENT(1-(i mod 2)),noclip=0
endfor

return  &  end


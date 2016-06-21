
function get_color_indx,color

;if data_type(color) eq 7 then begin
;  case strmid(color,1,0) of
;  'r': vecs = [255,0,0]
;endif


tvlct,r,g,b,/get
vecs = replicate(1.,n_elements(r)) # reform(color)
tbl = [[r],[g],[b]]
d = sqrt( total((vecs-tbl)^2,2) )
m = min(d,bin)
return,byte(bin)
end


;+
;FUNCTION:    get_colors
;PURPOSE:   returns a structure containing color pixel values
;INPUT:    none
;KEYWORDS:   
;   NOCOLOR:  forces all colors to !d.table_size-1.   
;
;Written by: Davin Larson    96-01-31
;FILE: get_colors.pro
;VERSION:  1.1
;LAST MODIFICATION: 96/08/09
;-
function  get_colors,colors=cols,array=array
@colors_com

magenta  = get_color_indx([1,0,1]*255)
red      = get_color_indx([1,0,0]*255)
yellow   = get_color_indx([1,1,0]*255)
green    = get_color_indx([0,1,0]*255)
cyan     = get_color_indx([0,1,1]*255)
blue     = get_color_indx([0,0,1]*255)
white    = get_color_indx([1,1,1]*255)
black    = get_color_indx([0,0,0]*255)

colors = [black,blue,cyan,green,yellow,red,magenta,white]
cols = colors

col = {black:black,blue:blue,cyan:cyan,green:green,yellow:yellow,red:red, $
  magenta:magenta,white:white}

if keyword_set(array) then return,colors else return,col
end





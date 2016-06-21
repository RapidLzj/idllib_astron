;+
; NAME:
;       CLIPSCL
;
; PURPOSE:
;
;       This is a utility routine to perform linear scaling (similar to BYTSCL)
;       on image arrays. If differs from BYTSCL only in that a user-specified
;       percentage of pixels can be clipped from the image histogram, prior to
;       scaling. By default, two percent of the pixels are clipped. Clipping
;       occurs at both ends of the image histogram.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Utilities
;
; CALLING SEQUENCE:
;
;       scaledImage = CLIPSCL(image, clipPercent)
;
; ARGUMENTS:
;
;       image:         The image to be scaled. Written for 2D images, but arrays
;                      of any size are treated alike.
;
;       clipPercent:   The percent of image clipping. Optional argument is set
;                      to 2 by default. Must be value between 0 and 49. Clipping
;                      occurs from both ends of image histogram, so a clip of 2
;                      linearly scales approximately 96% of the image histogram.
;                      Clipping percents are approximations only, and depend
;                      entirely on the distribution of pixels in the image. For
;                      interactive scaling, see XSTRETCH.
;
; INPUT KEYWORDS:
;
;
;       NEGATIVE:      If set, the "negative" of the result is returned.
;
;       OMAX:          The output image is scaled between OMIN and OMAX. The
;                      default value is 255.
;
;       OMIN:          The output image is scaled between OMIN and OMAX. The
;                      default value is 0.
; OUTPUT KEYWORDS:
;
;
;       THRESHOLD:     A two-element array containing the image thresholds for clipping.
;
; RETURN VALUE:
;
;       scaledImage:   The output, scaled into the range OMIN to OMAX. A byte array.
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLES:
;
;       LoadCT, 0                                            ; Gray-scale colors.
;       image = LoadData(22)                                 ; Load image.
;       TV, ClipScl(image, 4)
;
; RESTRICTIONS:
;
;     Requires SCALE_VECTOR from the Coyote Library:
;
;        http://www.dfanning.com/programs/scale_vector.pro
;
; MODIFICATION HISTORY:
;
;       Written by:  David W. Fanning, 6 September 2007.
;-
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2007 Fanning Software Consulting
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################
FUNCTION ClipScl, image, clip, $
   NEGATIVE=negative, $
   OMAX=maxOut, $
   OMIN=minOut, $
   THRESHOLD=threshold

   ; Return to caller on error.
   ;On_Error, 2
   Catch, theError
   IF theError NE 0 THEN BEGIN
      Catch, /Cancel
      void = Error_Message()
      RETURN, vector
   ENDIF

   ; Check arguments.
   IF N_Elements(image) EQ 0 THEN Message, 'Must pass IMAGE argument.'
   IF N_Elements(clip) EQ 0 THEN clip = 2 ELSE clip = 0 > clip < 48

   ; Check for underflow of values near 0. Yuck!
   curExcept = !Except
   !Except = 0
   i = Where(image GT -1e-35 AND image LT 1e-35, count)
   IF count GT 0 THEN image[i] = 0.0
   void = Check_Math()
   !Except = curExcept

   output = image

   ; Check keywords.
   IF N_Elements(maxOut) EQ 0 THEN maxOut = 255B ELSE maxout = 0 > Byte(maxOut) < 255
   IF N_Elements(minOut) EQ 0 THEN minOut = 0B ELSE minOut = 0 > Byte(minOut) < 255
   IF minOut GE maxout THEN Message, 'OMIN must be less than OMAX.'

   ; Calculate binsize.
   maxr = Max(image, MIN=minr, /NAN)
   range = maxr - minr
   IF Size(image, /TName) EQ 'BYTE' THEN binsize = 1.0 ELSE binsize = range / 1000.
   h = Histogram(image, BINSIZE=binsize, OMIN=omin, OMAX=omax)
   n = N_Elements(image)
   cumTotal = Total(h, /CUMULATIVE)
   minIndex = Value_Locate(cumTotal, n * (clip/100.))
   IF minIndex EQ -1 THEN minIndex = 0
   WHILE cumTotal[minIndex] EQ cumTotal[minIndex + 1] DO BEGIN
        minIndex = minIndex + 1
   ENDWHILE
   minThresh = minIndex * binsize + omin

   maxIndex  = Value_Locate(cumTotal, n * ((100-clip)/100.))
   WHILE cumTotal[maxIndex] EQ cumTotal[maxIndex - 1] DO BEGIN
       maxIndex = maxIndex - 1
   ENDWHILE
   maxThresh = maxIndex * binsize + omin

   ; Save the thresholds.
   threshold = [minThresh, maxThresh]

   ; Scale it into the thresholds.
   output = Temporary(output - (Min(output)))
   output = output * (Float(maxThresh)/Max(output)) + minThresh

   ; Scale it into the output values.
   output = Byte(Scale_Vector(Temporary(output), minOut, MaxOut))

   IF Keyword_Set(negative) THEN RETURN, 0B > (maxout - output + minOut) < 255B $
      ELSE RETURN, output

END

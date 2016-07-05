;+
; NAME:
;       SHAPEINFO
;
; PURPOSE:
;
;       The purpose of this program is allow the user to browse a very narrow
;       selection of shapefiles. Namely, those containing geographical shapes
;       in latitude and longitude coordinates. In other words, shapefiles
;       containing maps. File attributes are listed in the left-hand list
;       widget. Clicking on a file attribute, will list all the entity
;       attributes for that file attribute in the right-hand list. Clicking
;       an entity attribute with list the type of entity, and the X and Y
;       bounds of that entity (shown as LON and LAT, respectively), in the
;       statusbar at the bottom of the display.
;
;       Knowing the attribute and entity names of a shapefile will give
;       you insight into how to read and display the information in the file.
;       For examples, see the Coyote Library programs DrawCounties and DrawStates.

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

;       Utilities
;
; CALLING SEQUENCE:
;
;       ShapeInfo, shapefile
;
; ARGUMENTS:
;
;       shapefile:     The name of the input shapefile. If not provided, the user
;                      will be prompted to select a shapefile.
;
; KEYWORDS:
;
;     None.
;
; RESTRICTIONS:
;
;     It is assumed the shapefile contains 2D map information. The X and Y bounds of
;     each shapefile entity are reported as LON and LAT values, respectively.
;
;     Required Coyote Library programs:
;
;       CenterTLB
;       Error_Message
;
; EXAMPLE:
;
;       filename = Filepath(SubDir=['examples','data'], 'states.shp')
;       ShapeInfo, filename
;
; MODIFICATION HISTORY:
;
;       Written by David W. Fanning, 21 October 2006.
;-
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2006 Fanning Software Consulting
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
PRO ShapeInfo_Events, event

   ; Error handling.
   Catch, theError
   IF theError NE 0 THEN BEGIN
      Catch, /Cancel
      void = Error_Message()
      RETURN
   ENDIF

   ; Get the info structure.
   Widget_Control, event.top, Get_UValue=info

   ; Possible events identified by UVALUE.
   Widget_Control, event.id, Get_UValue=theEvent

   CASE theEvent OF

      ; User selected entity attribute. Get the particulars for this entity.
      'ENTITYLIST': BEGIN

         types = IntArr(N_Elements(*(*info).entities))
         bounds = FltArr(N_Elements(*(*info).entities))
         thisEntity = (*(*info).entities)[event.index]
         types = thisEntity.shape_type
         bounds = thisEntity.bounds
         typeIndex = Where((*info).typecode EQ types, count)
         IF count EQ 0 THEN BEGIN
            ok = Dialog_Message('Unknown type code: ' + types + ' Returning.')
            RETURN
         ENDIF
         space = String(Replicate(32B, 10))
         type = 'TYPE = ' + ((*info).shapetype[typeIndex])[0]
         lat = 'LAT = [' + StrTrim(bounds[1],2) + ', ' + StrTrim(bounds[5],2) + ']'
         lon = 'LON = [' + StrTrim(bounds[0],2) + ', ' + StrTrim(bounds[4],2) + ']'
         Widget_Control, (*info).statusbar, Set_Value=type[0] + space + lon + space + lat
         END

      ; User selected a file attribute. Get the entity attributes associated with this file attribute.
      'NAMELIST': BEGIN

         entityAttributes = StrArr(N_Elements(*(*info).entities))
         FOR j=0,N_Elements(*(*info).entities)-1 DO BEGIN
            thisEntity = (*(*info).entities)[j]
            entityAttributes[j] = StrUpCase(StrTrim((*thisEntity.attributes).(event.index), 2))
         ENDFOR
         Widget_Control, (*info).entityList, Set_Value=entityAttributes
         *(*info).entityAttributes = entityAttributes
         Widget_Control, (*info).statusbar, Set_Value=String(Replicate(32B, 150))
         END

      ; User wants to open new shapefile.
      'OPENFILE': BEGIN

         CD, CURRENT=thisDir, (*info).directory
         filename = Dialog_Pickfile(Title='Select Shapefile for Input...', Filter='*.shp')
         CD, thisDir
         IF filename EQ "" THEN RETURN
         (*info).directory = File_DirName(filename)

         ; Clean up current shapefile information.
         Heap_Free, (*info).entities
         Ptr_Free, (*info).entityAttributes
         Obj_Destroy, (*info).shapefile

         ; Create a new shapefile object
         shapefile = Obj_New('IDLffShape', filename)
         IF Obj_Valid(shapefile) EQ 0 THEN BEGIN
            Message, 'Specified file (' + File_Basename(filename) + $
                     ') does not appear to be a shapefile. Returning...'
         ENDIF

         ; Get the attribute names from the shape file.
         shapefile -> GetProperty, ATTRIBUTE_NAMES=theNames
         theNames = StrUpCase(StrTrim(theNames, 2))

         ; Get all the attribute pointers from the file. These are the entities.
         entities = Ptr_New(/Allocate_Heap)
         *entities = shapefile -> GetEntity(/All, /Attributes)

         ; Load the info structure.
         (*info).shapefile = shapefile
         (*info).entities = entities

         entityAttributes = StrArr(N_Elements(*(*info).entities))
         FOR j=0,N_Elements(*(*info).entities)-1 DO BEGIN
            thisEntity = (*(*info).entities)[j]
            entityAttributes[j] = StrUpCase(StrTrim((*thisEntity.attributes).(0), 2))
         ENDFOR
         Widget_Control, (*info).namelist, Set_List_Select=0
         (*info).entityAttributes = Ptr_New(entityAttributes)

         Widget_Control, (*info).nameList, Set_Value=theNames
         Widget_Control, (*info).entityList, Set_Value=entityAttributes
         Widget_Control, (*info).statusbar, Set_Value=String(Replicate(32B, 150))
         END

      'QUIT': Widget_Control, event.top, /Destroy

      ELSE: Print, 'Event not currently handled.

   ENDCASE


END ; -----------------------------------------------------------------------------------------


PRO ShapeInfo_Cleanup, tlb
   Widget_Control, tlb, Get_UValue=info
   Heap_Free, (*info).entities
   Ptr_Free, (*info).entityAttributes
   Obj_Destroy, (*info).shapefile
   Ptr_Free, info
END ; -----------------------------------------------------------------------------------------


PRO ShapeInfo, filename

   ; Error handling.
   Catch, theError
   IF theError NE 0 THEN BEGIN
      Catch, /Cancel
      void = Error_Message()
      RETURN
   ENDIF

   ; Ask the user to select file if one is not provided.
   IF N_Elements(filename) EQ 0 THEN BEGIN
      filename = Dialog_Pickfile(Title='Select Shapefile for Input...', Filter='*.shp')
      IF filename EQ "" THEN RETURN
   ENDIF

   ; Create a shapefile object
   shapefile = Obj_New('IDLffShape', filename)
   directory = File_DirName(filename)
   IF Obj_Valid(shapefile) EQ 0 THEN BEGIN
      Message, 'Specified file (' + File_Basename(filename) + $
               ') does not appear to be a shapefile. Returning...'
   ENDIF

   ; Get the attribute names from the shape file.
   shapefile -> GetProperty, ATTRIBUTE_NAMES=theNames
   theNames = StrUpCase(StrTrim(theNames, 2))

   ; Get all the attribute pointers from the file. These are the entities.
   entities = Ptr_New(/Allocate_Heap)
   *entities = shapefile -> GetEntity(/All, /Attributes)

   ; Create the widgets.
   tlb = Widget_Base(Title='ShapeFile Information', Column=1, MBAR=menuID)
   listBase = Widget_Base(tlb, Row=1, XPAD=0, YPAD=0, SPACE=0)

   ; Menubar
   fileID = Widget_Button(menuID, Value='File')
   button = Widget_Button(fileID, Value='Open New Shapefile', UVALUE='OPENFILE')
   button = Widget_Button(fileID, Value='Quit', UVALUE='QUIT')

   ; Shapefile Lists.
   nameBase = Widget_Base(listBase, Column=1)
   label = Widget_Label(nameBase, Value='File Attributes')
   nameList = Widget_List(nameBase, Value=theNames, YSize=25, XSIZE=50, UVALUE='NAMELIST')
   Widget_Control, nameList, Set_List_Select=0
   attIndex = 0

   ; Cycle through each entity and get the attribute
   entityAttributes = StrArr(N_Elements(*entities))
   entityTypes = IntArr(N_Elements(*entities))
   FOR j=0,N_Elements(*entities)-1 DO BEGIN
      thisEntity = (*entities)[j]
      entityAttributes[j] = StrUpCase(StrTrim((*thisEntity.attributes).(attIndex), 2))
      entityTypes[j] = thisEntity.shape_type
   ENDFOR

   ; Entity attribute list.
   nameBase = Widget_Base(listBase, Column=1)
   label = Widget_Label(nameBase, Value='Entity Attributes')
   entityList = Widget_List(nameBase, Value=entityAttributes, YSize=25,  XSIZE=50, UVALUE='ENTITYLIST')

   ; Entity statusbar widgets.
   infobase = Widget_Base(tlb, Row=1, XPAD=0, YPAD=0, SPACE=0)
   label = Widget_Label(infobase, Value='Entity Info: ')

   ; Size the statusbar appropriately.
   gb = Widget_Info(infobase, /Geometry)
   gl = Widget_Info(label, /Geometry)
   statusbar = Widget_Label(infobase,/Sunken_Frame, SCR_XSIZE=gb.scr_xsize-gl.scr_xsize, $
      Value=String(Replicate(32B, 150)))

   CenterTLB, tlb
   Widget_Control, tlb, /Realize

   ; Information to identify entity types.
   typecode = [ 1, 3, 5, 8, 11, 13, 15, 18, 21, 23, 25, 28, 31]
   shapetype = ['Point', 'Polyline', 'Polygon', 'MultiPoint', 'PointZ', 'PointLineZ', 'PolygonZ', $
                'MultiPointZ', 'PointM', 'PolyLineM', 'PolygonM', 'MultiPointM', 'MultiPatch']

   ; Create info structure and store it.
   info = Ptr_New({entities:entities, namelist:namelist, entitylist:entitylist, $
      entityAttributes:Ptr_New(entityAttributes, /No_Copy), shapefile:shapefile, $
      typecode:typecode, shapetype:shapetype, statusbar:statusbar, directory:directory}, /No_Copy)
   Widget_Control, tlb, Set_UValue=info

   ; Start it up.
   XManager, 'shapeinfo', tlb, Event_Handler='ShapeInfo_Events', $
      Cleanup='ShapeInfo_Cleanup', /No_Block

END ; -----------------------------------------------------------------------------------------

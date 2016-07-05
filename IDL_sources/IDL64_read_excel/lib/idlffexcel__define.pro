;+
; <Pro IDLffExcel>
;
;
; @File_Comments
;   Simple IDL-> Excel Example -- IDL reading from Excel
;
;   The following object definition is part of the IDL64_Read_Excel11.zip
;   archive that contains examples (Word, Excel, Spreadsheet) for how IDL 6.4
;   can host Microsoft Office Application Objects and a visual,
;   Spreadsheet Control.
;
;	http://www.ittvis.com/codebank/search.asp?FID=445
;
;   WARNING: Extreme care must be taken when using this
;	utility.  Misuse can crash IDL if care is not taked to correctly
;	define cell ranges.  Error checking is in place, but mixed datatype
;	errors occurring deep in the COM control are not trapped by this
;	prototype interface (yet).
;
; @Author
;   Paul Sommer
;   ITT, Technical Sales Engineer
;
; @Categories
;   com, word, excel, spreadsheed, document
;
; @Customer_ID
;   Open Source
;
; @History
;   05.06.07 Written
;
; @Modifications
;	07.25.07 Added GetAllDataFromCurrentWorksheet Method
;			 Changed GetData to GetRangeData Method Name
;
; @Requires
;
;   Licensed copy of Microsoft Office 2003
;   IDL 6.4 (Supports hosting COM Application Objects)
;	Previous versions of IDL require custom IDLmscomAx.dll
;	to be copied into IDL's bin.x86 directory.  Contact
;	the author of this tool if you need this dll.
;
; @Restrictions
;   Not supported by ITT Technical Support.  Use at your own risk.
;
; @Version
;   1.1
;-
;+
;  Init Method.
;
;	 @ param fileName {in}{required}{scalar string - fully qualified path to .xls file
;	 @ keyword:
;		SHEET Optional Excel Worksheet name. Default is "Sheet1"
;-
Function IDLffExcel::Init, fileName, sheet=sheet

	compile_opt hidden
	on_error, 2

	if (n_params() lt 1) then message, 'IDLffExcel::Init requires file name'

	; Use the IDL COM import bridge to init Excel Application Object
    self.oExcel = Obj_New("IDLcomIDispatch$PROGID$Excel_Application")
    if ~self.oExcel then return, -1

	; Get a reference to the Excel Workbook Collection Object
    self.oExcel->GetProperty, Workbooks=oWkBookCollection
	self.oWkBookCollection = oWkBookCollection

	self.fileName = fileName

	; Open the Excel data
    self.oWkBookData = self.oWkBookCollection->Open(self.fileName)

	; Get a reference to the sheets collection
    self.oWkBookData->GetProperty, Sheets=oSheetCollection
	self.oSheetCollection = oSheetCollection

	; Parmamerized property - props can return a value
    ; (this syntax used in collections) - Goofy COM...
    if (keyword_set(sheet)) then begin
    	self.oSheetCollection->GetProperty, sheet, Item=oSheet
    	self.oSheet = oSheet
    endif else begin
    	self.oSheetCollection->GetProperty, 'Sheet1', Item=oSheet
    	self.oSheet = oSheet
    endelse

	return, 1
End

;+
;  	GetData Method. Data from passed in range parameter
;
;  	@param inputRange {in}{required}{scalar or 2 element string array - 1 and
;		2D ranges supported} input
;
;	  Example:
;
;		oExcel = Obj_New("IDLffExcel", "myData.xls")
;		myData= oExcel->GetData("A1:A100" | ["P1:P100","S1:S100"])
;-
Function IDLffExcel::GetRangeData, inputRange

	compile_opt hidden
	on_error, 2

	if (obj_valid(self.oCellRange)) then Obj_Destroy, self.oCellRange

	if (size(inputRange, /dimensions) eq 2) then begin
		self.oSheet->GetProperty, inputRange[0], inputRange[1], range=oCellRange
    	self.oCellRange = oCellRange
	endif else begin
		self.oSheet->GetProperty, inputRange, range=oCellRange
    	self.oCellRange = oCellRange
	endelse

    self.oCellRange->GetProperty, value=myValues

	if (size(myValues, /type) eq 0) then begin ; undefined

		message, 'Invalid Range '+range+'? Mixed data types not supported.'+ $
		 ' Data must be numeric and contiguous.', /ioerror

	endif else return, myValues

End

;+
;  	GetAllDataFromCurrentWorksheet Method. Returns all valid, contiguous data
;		stored in currently selected worksheet
;
;	  Example:
;
;		oIDL_Excel = obj_new("IDLffExcel", fileName, SHEET='irreg_grid1')
;		data = oIDL_Excel->GetAllDataFromCurrentWorksheet()
;-
Function IDLffExcel::GetAllDataFromCurrentWorksheet

	compile_opt hidden
	on_error, 2

	if (obj_valid(self.oCellRange)) then Obj_Destroy, self.oCellRange

		self.oSheet->GetProperty, USEDRANGE=oUsedCells
		self.oCellRange = oUsedCells
		self.oCellRange->GetProperty, value=myValues

	if (size(myValues, /type) eq 0) then begin ; undefined

	    message, 'Invalid Range '+range+'? Mixed data types not supported.'+ $
	        ' Data must be numeric and contiguous.', /ioerror

	endif else begin

		; Rearrange into IDL column-major format so user doesn't have to
 		dims = size(myValues, /DIMENSIONS)
 		myValues = transpose(reform(temporary(myValues), dims[1], dims[0]))

		return, myValues

	endelse
End

;+
;  	Sets Properties on IDLffExcel Object
;
;	@Keyword:
;
;	   Sheet {in}{optional}{scalar string} input
;
;	   Example:
;
;	   oExcel = Obj_New("IDLffExcel", "myData.xls")
;	   oExcel->SetPropery, SHEET="Sheet2"
;-
Pro IDLffExcel::SetProperty, sheet=sheet, _extra=extra

	compile_opt hidden
	on_error, 2

	if (obj_valid(self.oSheet)) then Obj_Destroy, self.oSheet
	self.oSheetCollection->GetProperty, sheet, Item=oSheet
    self.oSheet = oSheet

End

; C L E A N  U P
Pro IDLffExcel::Cleanup
	; PURPOSE:  Cleans up self data when Obj_Destroy called from calling app

	compile_opt hidden
	on_error, 2

	; Do not prompt user to "save" as we're just reading data
    self.oWkBookData->SetProperty, saved=1
    self.oWkBookCollection->Close
    self.oExcel->Quit
    Obj_Destroy, [self.oSheet, self.oCellRange, self.oSheetCollection, $
    	self.oWkBookData, self.oWkBookCollection, self.oExcel]

End

;
; O B J  D E F I N E
Pro IDLffExcel__define

	define = {IDLffExcel, $
				fileName:"", $
				oExcel:Obj_New(), $
				oWkBookCollection:Obj_New(), $
				oWkBookData: Obj_New(), $
				oSheetCollection: Obj_New(), $
				oSheet: Obj_New(), $
				oCellRange: Obj_New() }

End
;-------------------------------------------------------------------------------
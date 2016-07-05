;+
; <Pro IDL_Write_Excel_Col>
;   The following procedure is part of the IDL64_Read_Excel11.zip
;   archive that contains examples (Word, Excel, Spreadsheet) for how IDL 6.4
;   can host Microsoft Office Application Objects and a visual,
;   Spreadsheet Control.
;
;	http://www.ittvis.com/codebank/search.asp?FID=445
;
; @File_Comments
;   Simple IDL-> Excel Example -- IDL Write data to Excel
;   Reading Exce data is also possible.  See example "IDL_Read_Excel.pro"
;		contained in this archive.
;
; @Keywords
;		FILENAME: String
;
; @Author
;   Paul Sommer
;   ITT, Technical Sales Engineer
;
; @Categories
;   com, word, excel, spreadsheed, document
;
; @Customer_ID
;   Raytheon
;
; @History
;   2.26.07 Written
;
; @Requires
;
;   Licensed copy of Microsoft Office 2003
;   IDL 6.3 with new IDLmscomAx.dll
;
; @Restrictions
;   Not supported by ITT Technical Support
;   (Prototype code only)
;
; @Version
;   1.0
;-
Pro IDL_Write_Excel_Col, FILENAME=FileName


	; Create an instance of an Excel Application Object
	oExcel = obj_new("IDLcomIDispatch$PROGID$Excel_Application")
	if ~oExcel then return

	; Set this property to 0 to hide the Excel Application
	oExcel->SetProperty, visible=1

	; Obtain a reference to the workbook object and add new
	oExcel->GetProperty, Workbooks=oWkbks
	oWkbks->Add

	oWkbks->GetProperty, 'Book1', Item=oBookData

 	; Get a reference to the sheets collection
  oBookData->GetProperty, Sheets=oSheets

  ; Parmamerized property - props can return a value
  ; (this syntax used in collections) - It's a COM detail.
  oSheets->GetProperty, 'Sheet1', Item=mySheetObj

	;  Obtain a reference to the range object with defined cell(s)
	mySheetObj -> GetProperty, 'A1', range = myRangeObj
	;myRangeObj->select
	; Set a value on the currently selected range
	myRangeObj->SetProperty, 'select', value='From IDL'

	; Done with this range
	;obj_destroy, myRangeObj

	; Make some test label data on the IDL side and predefine
	; a range for storage on the Excel side
	myLabels = ['IDL','Data','Processing','Is','Fun'] ; String array

	; Since we want to traverse across the cols, we will use
	; the knowledge that "A" is equal to an ASCII byte value of 65.
	; Therefore, "index 0" = "A" = (byte("A") - 65)
	; This for loop will add a lable for each col, A-Z (byte values 65-90)

	row = '1'
	label_index = 0

	;for i=65b, 90b do begin ; 65-90 = ASCII byte values, A-Z
	for i=65b, 69b do begin ; simple example A-E Cols

		; Define a range - we need a string literal therefore,
		; we use IDL's format keyword on the string function
		tmp = string(i)
		var_range = strcompress(tmp+row, /remove_all)
    	; Debugging print
		print, "Range ="+var_range
		mySheetObj -> GetProperty, var_range, range = myRangeObj

		; Might want to "select" if in GUI driven app calling this
		;myRangeObj->select

		; Set a value on the currently selected range
		myRangeObj->SetProperty, 'select', value=string(myLabels[label_index])
		obj_destroy, myRangeObj

		label_index++ ; increment the counter for label array

	endfor

	; Save the book1 data so not prompted by oExcel
	if ~(keyword_set(FileName)) then begin
		print, "Saving file to C:/testOut.xls"
		oBookData->SaveAs, "C:/testOut.xls"
	endif else begin
		print, "Saving file to "+FileName
		oBookData->SaveAs, FileName
	endelse

	; Close down our IDL Excel bridge and cleanup
	oWkbks->Close
	oExcel->Quit

	obj_destroy, [oExcel, myRangeObj, oSheets, $
							 mySheetObj, oWkbks, oBookData]

	print, 'Done writing to Excel..."

End
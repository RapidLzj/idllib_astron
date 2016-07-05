; TESTFILE = IDLffExcell_Demo.xls

	; You have to know what the data ranges are in the excel file
	; before using IDLffExcel.  This interface can not handle Excel
	; format cells (math function cells), etc.  Keep the cell ranges
	; to numeric data only.  Blank cells okay.


Pro Read_Excel_Object_Demo


	file = file_search("data/IDLffExcel_Demo.xls", /fully_qualify_path)
	if ~file then file = dialog_pickfile(filter="IDLffExcel_Demo.xls")
	if ~file then message,"IDLffExcel_Demo.xls' file not found"


	; Init the new obj - a file param is required, SHEET is optional
	; If a sheet is not named at init, the Excel default is used "Sheet1"
	oIDL_Excel = obj_new("IDLffExcel", file, sheet="Sheet1")

	; Let's get some data.  Range is a required paramter
	columnData = oIDL_Excel->GetRangeData("C7:C70")

	; Plot this new range of data and set up parent iTool for multiple plots
	iPlot, columnData, color=[0,0,255], view_title="Sheet1: Col C7:C70 1D Range", $
		 /no_saveprompt, view_grid=[2,2], title="IDLffExcel Demo", location=[0,0]

	; Index all the cells populated with numeric data (no strings!).  This is a
	; 2D range example - all cells bounded by these two ranages are captured
	columnData2 = oIDL_Excel->GetRangeData(["D7:D70","J7:J70"])

	; Plot 2D range as an image
	iImage, columnData2, color=[0,255,0], $
		view_title="Sheet1: Col:Row D7:D70,J7:J70 2D Range", $
		/view_next

	; Take a 1D profile of the 2D range and plot
	iplot, columnData2[1,*], color=[0,255,0], $
		view_title="Sheet1: Subset Col:Row D7:D70,J7:J70 2D Range", $
		/view_next

	; Next, let's try and switch sheets at runtime and grab a new range
	; of data
	oIDL_Excel->SetProperty, sheet="Sheet2"
	columnData3 = oIDL_Excel->GetRangeData("A1:A15")

	; Plot data out of sheet2
	iplot, columnData3, color=[255,0,0], $
		view_title="Sheet2: Col A1:A15 1D Range", $
		/view_next

	; Switch to to last sheet and get data
	oIDL_Excel->SetProperty, sheet="Sheet3"
	rowData = oIDL_Excel->GetRangeData("A1:M1")

	; Plot data out of sheet3
	iplot, rowData, color=[0,255,255], $
		view_title="Sheet3: Row A1:M1 1D Range", $
		/no_saveprompt, location=[640,500]

	; Destroy the object - you should not see any dangling obj refs
	; created internally by IDLffExcel object.
	obj_destroy, oIDL_Excel

End
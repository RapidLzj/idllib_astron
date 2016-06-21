Pro Read_Excel_Procedure_Demo

	file = file_search("data/IDLffExcel_Demo.xls", /fully_qualify_path)
		if ~file then return

	excelData = Read_Excel(file, "F7:F70")

	iPlot, excelData, view_title="Excel Range F7:F70"

End
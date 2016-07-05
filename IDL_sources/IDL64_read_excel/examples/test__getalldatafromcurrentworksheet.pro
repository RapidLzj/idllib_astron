Pro Test__GetAllDataFromCurrentWorksheet

	fileName = dialog_pickfile(filter="ascii_and_irreg_grid1.xls", title=$
	 	"Select sample data: data/ascii_and_irreg_grid1.xls data")

	oIDL_Excel = obj_new("IDLffExcel", fileName, SHEET='irreg_grid1')

	data = oIDL_Excel->GetAllDataFromCurrentWorksheet()

	print, data

	iPlot, data[0,*], view_grid=[3,1]
	iPlot, data[1,*], /view_next
	iPlot, data[2,*], /view_next

	obj_destroy, oIDL_Excel

End
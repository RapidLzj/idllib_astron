Function Read_Excel, fileName, range, sheet=sheet



	if ~(n_params(2)) then message, 'Syntax error: Check fileName, range params?'

	if ~(keyword_set(Sheet)) then Sheet="Sheet1"

	oIDL_Excel = obj_new("IDLffExcel", fileName, sheet=Sheet)
	data = oIDL_Excel->GetRangeData(range)

	obj_destroy, oIDL_Excel

	return, data

End
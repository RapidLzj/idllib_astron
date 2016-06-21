a = new Array();

a[1] = new Array("./idlffexcel__define.html", "idlffexcel__define.pro", "", "            File_Comments     Simple IDL  Excel Example   IDL reading from Excel       The following object definition is part of the IDL_MicrosoftOffice_64     archive that contains examples  Word  Excel  Spreadsheet  for how IDL 6 4     can host Microsoft Office Application Objects and a visual      Spreadsheet Control        WARNING: Extreme care must be taken when using this  utility   Misuse can crash IDL if care is not taked to correctly  define cell ranges   Error checking is in place  but mixed datatype  errors occurring deep in the COM control are not trapped by this  prototype interface  yet       Author     Paul Sommer     ITT  Technical Sales Engineer      Categories     com  word  excel  spreadsheed  document      Customer_ID     Raytheon      History     05 06 07 Written      Requires       Licensed copy of Microsoft Office 2003     IDL 6 4  Supports hosting COM Application Objects   Previous versions of IDL require custom IDLmscomAx dll  to be copied into IDL s bin x86 directory   Contact  the author of this tool if you need this dll       Restrictions     Not supported by ITT Technical Support   Use at your own risk       Prototype code only       Version     1 0        Init Method        param fileName  in required scalar string   fully qualified path to  xls file     keyword:  SHEET Optional Excel Worksheet name  Default is  Sheet1    Function IDLffExcel::Init  fileName  sheet sheet   compile_opt hidden  on_error  2   if  n_params  lt 1  then message   IDLffExcel::Init requires file name     Use the IDL COM import bridge to init Excel Application Object     self oExcel   Obj_New IDLcomIDispatch PROGID Excel_Application      if  self oExcel then return   1    Get a reference to the Excel Workbook Collection Object     self oExcel GetProperty  Workbooks oWkBookCollection  self oWkBookCollection   oWkBookCollection   self fileName   fileName    Open the Excel data     self oWkBookData   self oWkBookCollection Open self fileName     Get a reference to the sheets collection     self oWkBookData GetProperty  Sheets oSheetCollection  self oSheetCollection   oSheetCollection    Parmamerized property   props can return a value        this syntax used in collections    Goofy COM      if  keyword_set sheet  then begin      self oSheetCollection GetProperty  sheet  Item oSheet      self oSheet   oSheet     endif else begin      self oSheetCollection GetProperty   Sheet1  Item oSheet      self oSheet   oSheet     endelse   return  1 End        GetData Method  Data from passed in range parameter       param inputRange  in required scalar or 2 element string array   1 and  2D ranges supported  input      Example:    oExcel   Obj_New IDLffExcel   myData xls   myData  oExcel GetData A1:A100     P1:P100 S1:S100    Function IDLffExcel::GetData  inputRange   compile_opt hidden  on_error  2   if  obj_valid self oCellRange  then Obj_Destroy  self oCellRange   if  size inputRange   dimensions  eq 2  then begin   self oSheet GetProperty  inputRange 0  inputRange 1  range oCellRange      self oCellRange   oCellRange   endif else begin   self oSheet GetProperty  inputRange  range oCellRange      self oCellRange   oCellRange   endelse      self oCellRange GetProperty  value myValues   if  size myValues   type  eq 0  then begin   undefined   message   Invalid Range  range  Mixed data types not supported        Data must be numeric and contiguous   ioerror   endif else return  myValues  End        Sets Properties on IDLffExcel Object    Keyword:       Sheet  in optional scalar string  input       Example:       oExcel   Obj_New IDLffExcel   myData xls      oExcel SetPropery  SHEET Sheet2    Pro IDLffExcel::SetProperty  sheet sheet  _extra extra   compile_opt hidden  on_error  2   if  obj_valid self oSheet  then Obj_Destroy  self oSheet  self oSheetCollection GetProperty  sheet  Item oSheet     self oSheet   oSheet  End    C L E A N  U P Pro IDLffExcel::Cleanup   PURPOSE:  Cleans up self data when Obj_Destroy called from calling app   compile_opt hidden  on_error  2    Do not prompt user to  save  as we re just reading data     self oWkBookData SetProperty  saved 1     self oWkBookCollection Close     self oExcel Quit     Obj_Destroy   self oSheet  self oCellRange  self oSheetCollection         self oWkBookData  self oWkBookCollection  self oExcel   End      O B J  D E F I N E Pro IDLffExcel__define   define    IDLffExcel     fileName:     oExcel:Obj_New     oWkBookCollection:Obj_New     oWkBookData: Obj_New     oSheetCollection: Obj_New     oSheet: Obj_New     oCellRange: Obj_New     End  ");


var URL         = 0;
var FILENAME    = 1;
var DESCRIPTION = 2;
var CONTENTS    = 3;
var MATCH_TYPE  = 4;
var N_MATCHES   = 5;
var SCORE       = 6;
var i = 7;
var MATCHES     = 8;

var html;

var searchString;
var wildcard;
var invalidSearchString;
var origSearchString;
var styles = "<link rel=\"stylesheet\" type=\"text/css\" href=\"search.css\" />"

FILENAME_SCORE_ORDER    = 0;
URL_SCORE_ORDER         = 1;
DESCRIPTION_SCORE_ORDER = 2;
CONTENT_SCORE_ORDER     = 3;

SCORE_PER_TYPE = 15000;

var sortResultsByType = true;
var omitDescriptions = false;
var addMatchSummary = true;

var searchTitles = true;
var searchDescriptions = true;
var searchContent = true;

var footer = "";

function isAlnumAmp(ch) {
  if ((ch >= "a" && ch <= "z") || (ch == "&") ||(ch >= "A" && ch <= "Z") || (ch >= "0" && ch <="9")) {
    return true;
  } else {
    return false;
  }
}

function searchElement(fileNumber, matchType, upperSearchString) {
  var element = a[fileNumber][matchType].toUpperCase();
  var w, x, y;
  var z = 0;

  a[fileNumber][N_MATCHES] = 0;
  w = element.indexOf(upperSearchString);
  while (w >= 0){
    z = z + w + 1;
    if ((wildcard == -2) || (wildcard == -5)) {
      x = false;
    } else {
      if (w == 0) {
	x = false;
      } else {
	x = isAlnumAmp(element.charAt(w - 1));
      }
    }
    if ((wildcard == -3) || (wildcard == -5)) {
      y = false;
    } else {
      if (element.length - w == upperSearchString.length) {
	y = false;
      } else {
	y = isAlnumAmp(element.charAt(w + upperSearchString.length));
      }
    }
    if (!x && !y) {
      a[fileNumber][MATCHES + a[fileNumber][N_MATCHES]] = z - 1;
      a[fileNumber][N_MATCHES]++;
          }
    element = element.substring(w + 1, element.length);
    while (isAlnumAmp(element.charAt(0)) && element.length > 0) {
      element = element.substring(1, element.length);
      z++;
    }
    w = element.indexOf(upperSearchString);
  }
}

function searchFile(fileNumber, upperSearchString) {
  var matchIndex = -1, matchType;

  a[fileNumber][MATCH_TYPE] = -1;

  while (++matchIndex <= CONTENTS && a[fileNumber][MATCH_TYPE] == -1) {
    matchType = matchIndex == 0 ? FILENAME : (matchIndex == 1 ? DESCRIPTION : (matchIndex == 2 ? URL : CONTENTS));
    if ((matchType == FILENAME || matchType == URL) && !searchTitles) {
      continue;
    }

    if (matchType == DESCRIPTION && !searchDescriptions) {
      continue;
    }

    if (matchType == CONTENTS && !searchContent) {
      continue;
    }

    searchElement(fileNumber, matchType, upperSearchString);
    if (a[fileNumber][N_MATCHES] > 0) {
      a[fileNumber][MATCH_TYPE] = matchType;
    }
  }
}

function sortResults() {
  var fileNumber, t, tempScore, E;

  for (fileNumber = 1; fileNumber < a.length; fileNumber++) {
    a[fileNumber][i] = fileNumber;
  }

  if (sortResultsByType) {
    for (fileNumber = 1; fileNumber < a.length; fileNumber++) {
      if (a[fileNumber][MATCH_TYPE] == FILENAME) {
	a[fileNumber][SCORE] = (4 - FILENAME_SCORE_ORDER) * SCORE_PER_TYPE;
      } else if (a[fileNumber][MATCH_TYPE] == DESCRIPTION) {
	a[fileNumber][SCORE] = (4 - DESCRIPTION_SCORE_ORDER) * SCORE_PER_TYPE;
      } else if (a[fileNumber][MATCH_TYPE] == URL) {
	a[fileNumber][SCORE] = (4 - URL_SCORE_ORDER) * SCORE_PER_TYPE;
      } else {
	a[fileNumber][SCORE] = (4 - CONTENT_SCORE_ORDER) * SCORE_PER_TYPE + a[fileNumber][N_MATCHES];
      }
    }
    for (fileNumber = 2; fileNumber < a.length; fileNumber++) {
      tempScore = a[fileNumber][SCORE];
      E = a[fileNumber][i];
      for (t = fileNumber; t > 1 && tempScore > a[t-1][SCORE]; t--) {
	a[t][SCORE] = a[t-1][SCORE];
	a[t][i] = a[t-1][i];
      }
      a[t][SCORE] = tempScore;
      a[t][i] = E;
    }
  }
}

function putMatchSummary(fileNumber) {
  var pluralSuffix = a[fileNumber][N_MATCHES]==1 ? "" : "es";

  html += "";
  html += "<span class=\"match\">";
  if (a[fileNumber][MATCH_TYPE] == FILENAME) {
    html += " - matched title";
  } else {
    if (a[fileNumber][MATCH_TYPE] == DESCRIPTION) {
      html += " - matched description";
    } else {
      if (a[fileNumber][MATCH_TYPE] == URL) {
	html += " - matched URL";
      } else {
	html += " - " + a[fileNumber][N_MATCHES] + " match" + pluralSuffix + "";
      }
    }
  }
  html += "</span>";
}

function putMatchDescription(fileNumber, curMatch) {
  var matchLocation = a[fileNumber][MATCHES + curMatch - 1];
  var matchStart = matchLocation < 35 ? 0 : matchLocation - 35;
  var matchEnd = (matchLocation + 35 > a[fileNumber][CONTENTS].length) ? a[fileNumber][CONTENTS].length : matchLocation + 35;

  var Q = false;
  while ((matchStart >= 0) && !Q) {
    if (isAlnumAmp(a[fileNumber][CONTENTS].charAt(matchStart))) {
      matchStart--;
    } else {
      Q = true;
    }
  }
  matchStart++;

  Q = false;
  while ((matchEnd > matchLocation) && !Q) {
    if (isAlnumAmp(a[fileNumber][CONTENTS].charAt(matchEnd))) {
      matchEnd--;
    } else {
      Q = true;
    }
  }

  html += "<br>\".. " + a[fileNumber][CONTENTS].substring(matchStart, matchLocation);
  html += "<span class=\"foundString\">" + a[fileNumber][CONTENTS].substring(matchLocation, matchLocation + searchString.length) + "</span>";
  html += a[fileNumber][CONTENTS].substring(matchLocation + searchString.length, matchEnd) + " ..\"";
}

function putAllMatchDescriptions(fileNumber) {
  if (omitDescriptions == false) {
    var curMatch = 1;
    while ((curMatch < 4) && (curMatch <= a[fileNumber][N_MATCHES])) {
      putMatchDescription(fileNumber, curMatch);
      curMatch++;
    }
  }
}

function putFoundString(v, R) {
  html += v.substring(0, R);
  html += "<span class=\"foundString\">" + v.substring(R, R + searchString.length) + "</span>";
  html += v.substring(R + searchString.length, v.length);
}

function putItem(fileNumber, itemNumber) {
  html += "<p>" + itemNumber + ". ";
  html += "<a href=\"" + a[fileNumber][URL] + "\" target=\"file_frame\">" + a[fileNumber][FILENAME] + "</a>";

  if (a[fileNumber][MATCH_TYPE] == CONTENTS) {
    putAllMatchDescriptions(fileNumber);
  } else {
    html += "";
  }

  if (a[fileNumber][MATCH_TYPE] == DESCRIPTION) {
    html += "<span class=\"description\">";
    html += "<br>Description: ";
    html += "</span>";
    html += "";
    putFoundString(a[fileNumber][DESCRIPTION], a[fileNumber][MATCHES]);
  } else {
    if( a[fileNumber][DESCRIPTION].length > 0 ) {
      html += "<span class=\"description\">";
      html += "<br>Description: ";
      html += "</span>";
      html += "" + a[fileNumber][DESCRIPTION];
    } else {
    }
  }
  html += "<br>";
  html += "<span class=\"file\">";
  if (a[fileNumber][MATCH_TYPE] == URL) {
    putFoundString(a[fileNumber][URL], a[fileNumber][MATCHES]);
  } else {
    html += a[fileNumber][URL];
  }
  html += "</span>";
  if (addMatchSummary) {
    putMatchSummary(fileNumber);
  }
  html += "<br>";
}

function putResults() {
  var itemNumber = 0;

  if (!(invalidSearchString)) {
    for (var fileNumber = 1; fileNumber < a.length; fileNumber++) {
      if (a[a[fileNumber][i]][N_MATCHES] > 0) {
	putItem(a[fileNumber][i], ++itemNumber);
      }
    }
  } else {
    if (wildcard == -4) {
      html += "<p><span class=\"error\">ERROR:</span>&nbsp;The wildcard chararcter (*) must be at the beginning or end of the text.</p>";
    }
  }
}

function putHeader() {
  html += "<html><head><title>Search results for \"" + origSearchString + "\"</title>";
  html += styles;
  html += "</head><body>";
  html += "<h1>Search Results</h1>";
  html += "<div id=\"container\">";
  html += "<p>You searched for <span class=\"foundString\">" + origSearchString +".</span></p>";
}

function putFooter() {
  var nMatches = 0;

  if (!(invalidSearchString)) {
    for (var fileNumber = 1; fileNumber < a.length; fileNumber++) {
      if (a[fileNumber][N_MATCHES] > 0) {
	nMatches++;
      }
    }
  }

  if (nMatches == 0) {
    html += "<p>No pages matched your search.</p>";
  } else {
    var plural = nMatches == 1 ? "" : "s";
    html += "<p id=\"tagline\">" + nMatches + " page" + plural + " listed.</p>";
  }
  html += footer;
  html += "</div></body></html>";
}

function launchBrowser() {
  var htmlCode = html;

  iu = open("", "Object", "resizable=yes,scrollbars=yes,toolbar=no,menubar=no,location=no,directories=no,width=475,height=600");

  if ((navigator.appName.indexOf("Microsoft")!=-1) && (navigator.appVersion.indexOf("3.0") != -1)) {
    alert("Click to see results");
  }

  iu.document.open();
  iu.document.write(htmlCode);
  iu.document.close();
}

function replaceSpecialChars(str) {
  var returnStr = "";

  for (var index = 0; index < str.length; index++) {
    if (str.charAt(index) == "<") {
      returnStr += "&lt;";
    } else if (str.charAt(index) == ">") {
      returnStr += "&gt;";
    } else if (str.charAt(index) == "\"") {
      returnStr += "&quot;";
    } else {
      returnStr += str.charAt(index);
    }
  }
  return(returnStr);
}

function checkSearchString() {
  wildcard = searchString.indexOf("*");
  if (wildcard == 0) {
    wildcard = -2;
    invalidSearchString = false;
  } else if (wildcard == searchString.length -1) {
    wildcard = -3;
    invalidSearchString = false;
  } else if (wildcard > 0 ) {
    wildcard = -4;
    invalidSearchString = true;
  } else {
    invalidSearchString = false;
  }

  if (searchString.indexOf("*") != searchString.lastIndexOf("*")) {
    if (wildcard == -2) {
      if (searchString.lastIndexOf("*") == searchString.length - 1) {
	wildcard = -5;
      } else {
	wildcard = -4;
	invalidSearchString = true;
      }
    }
  }

  if ((wildcard == -2) || (wildcard == -5)) {
    searchString = searchString.substring(1, searchString.length);
  }

  if ((wildcard == -3) || (wildcard == -5)) {
    searchString = searchString.substring(0, searchString.length - 1);
  }
}

function toggleOmitDescriptions() {
  omitDescriptions = !omitDescriptions;
}

function toggleSortResults() {
  sortResultsByType = !sortResultsByType;
}

function toggleMatchSummary() {
  addMatchSummary = !addMatchSummary;
}

function toggleSearchTitles() {
  searchTitles = !searchTitles;
}

function toggleSearchDescriptions() {
  searchDescriptions = !searchDescriptions;
}

function toggleSearchContent() {
  searchContent = !searchContent;
}

function startsearch() {
  var upperSearchString;
  searchString = document.formSearch.txtSearch.value;

  if ((searchString.length > 0) && (searchString != "*")) {
    html = "";
    origSearchString = searchString;
    searchString = replaceSpecialChars(searchString);
    checkSearchString();
    upperSearchString = searchString.toUpperCase();
    if (!(invalidSearchString)) {
      for (var fileNumber = 1; fileNumber < a.length; fileNumber++) {
	searchFile(fileNumber, upperSearchString);
      }
      sortResults();
    }
    putHeader();
    putResults();
    putFooter();
    launchBrowser();
  }
}

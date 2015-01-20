-- Matlib Manager
-- v0.2a
-- 19/01/2015
-- onectin@onectin.fr
-- --------------------------
-- matlibManager.ms


-- Kill  any other window from MLM
try(DestroyDialog ::_MLM_matlibManager) catch()
try(DestroyDialog ::_MLM_matlibManager._MLM_preferences) catch()
try(DestroyDialog ::_MLM_matlibManager._MLM_about) catch()
try(DestroyDialog ::_MLM_matlibManager._MLM_manage) catch()
try(DestroyDialog ::_MLM_matlibManager._MLM_NewEditCat) catch()
try(DestroyDialog ::_MLM_matlibManager._MLM_DeleteCat) catch()
try(DestroyDialog ::_MLM_matlibManager._MLM_DeleteEntrie) catch()

-- Paths
_rootDir = (getDir #scene) + "\\"
_matLibDir = (getDir #matlib) + "\\"
_scriptDir = (getDir #userScripts) + "\\"
_macroDir = (getDir #userMacros) + "\\"

_MLM_dir = _scriptDir + "matlibManager\\"
_MLM_mainScript = _MLM_dir + "matlibManager.ms"
_MLM_prefFile = _MLM_dir + "preferences.ini"
_MLM_prefScript = _MLM_dir + "preferences.ms"
_MLM_aboutImage = _MLM_dir + "img\\about.jpg"
_MLM_icons = _MLM_dir + "img\\"

-- Check prefFile
_checkPrefFile = getFiles _MLM_prefFile

-- Variables #SCRIPT

-- Texts & Tooltips
_MLM_deleteEntryMsg01 = "There is an entry with this name."
_MLM_deleteEntryMsg02 = "Do you want to overwrite it ? "

-- Functions #HEADER
function FNmsgBox _message _type _overRide=false =
(
	if _type == "warning" do print (">>> WARNING: " + _message)
	if _type == "info" do print (">>> INFO: " + _message)
	if _type == "error" do print (">>> ERROR: " + _message)

	if _SET_PopUpWarning == true or _overRide == true do
	(
		messageBox _message beep:false title:"Matlib Manager"
	)
)

function FNtoString _array =
(
	_out = "#("
	for _item in _array do
	(
		_out = _out + (_item as string) + ", "
	)
	_outCount = _out.count
	_outCount = _outCount - 2
	_out =  substring _out 1 _outCount

	_out = _out + ")"

	return _out
)

function FNexportMat _currentCat _currentName =
(
	-- MAIN VAR
	_selection = getCurrentSelection()
	_nonShadedObj = #()
	_file = _currentName
	
	-- INFO FILE CONCATENATE
	_info = #()
	_infoFilePath = _SET_DatabaseFolder
	_infoFileName = _file + ".mlm"
	_infoFile = _infoFilePath + _currentCat + "\\" + _infoFileName
	
	
	-- MATLIB FILE CONCATENATE
	_matFilePath = _SET_MatlibFolder
	_matFileName = _file + ".mat"
	_matFile = _matFilePath + _matFileName
	
	-- CREATE MATLIB & INFOFILE
	-- On charge la TempLib
	loadDefaultMatLib()
	
	-- On vérifie qu'elle est vide
	for i = 1 to currentMaterialLibrary.count DO
	(
	deleteItem currentMaterialLibrary 1
	)
	
	-- On ajoute la selection courante à la TempLib et on sauve le infoFile
	for i in _selection do
	(
		if i.material != undefined then
		(
			append currentMaterialLibrary i.material
			_info = append _info #(i.material.name, i.name)
		)
		else
		(
			_nonShadedObj = append _nonShadedObj i.name
		)
	)
	
	-- CONCATANATE INFOS
	_strInfo = FNtoString _info 
	_strInfo = _matFile + "\n" + _strInfo

	-- SAVE INFOFILE
	if  (doesFileExist _infoFile) == false then
	(
		_tempCreate = createFile _infoFile
		flush _tempCreate
		close _tempCreate
	)
	else
	(
		deleteFile _infoFile
		_tempCreate = createFile _infoFile
		flush _tempCreate
		close _tempCreate
	)
	
	_tempOpen = openFile _infoFile mode:"r+"
	format _strInfo to:_tempOpen
	flush _tempOpen
	close _tempOpen
	
	
	if  (doesFileExist _matFile) == false do
	(
		_tempCreateMatF = createFile _matFile
		flush _tempCreateMatF
		close _tempCreateMatF
	)
	
	saveMaterialLibrary _matFile
)

-- Init
if _checkPrefFile.count == 0 then
(
	_message = "Can't find preference file:\n" + _MLM_prefScript + "\n\n Let's configure it !"
	FNmsgBox _message "info" true
	fileIn _MLM_prefScript
)
else
(
	global _SET_DatabaseFolder =			getIniSetting _MLM_prefFile "Paths" "database"
	global _SET_MatlibFolder =				getIniSetting _MLM_prefFile "Paths" "matlib"
	global _SET_Categories =				execute(getIniSetting _MLM_prefFile "Datas" "categories")
	global _SET_SepSym =					getIniSetting _MLM_prefFile "Datas" "separationSymbol"
	global _SET_NumDig =					execute(getIniSetting _MLM_prefFile "Datas" "numberOfDigits")
	global _SET_ExportMode =				execute(getIniSetting _MLM_prefFile "UI" "exportMode")
	global _SET_Appearance =				execute(getIniSetting _MLM_prefFile "UI" "appearance")
	global _SET_Icons =						execute(getIniSetting _MLM_prefFile "UI" "icons")
	global _SET_WinPositionRecord = 		execute(getIniSetting _MLM_prefFile "Window_Position" "save")
	global _SET_WinPositionPosition = 		execute(getIniSetting _MLM_prefFile "Window_Position" "position")
	global _SET_WindowState =				execute(getIniSetting _MLM_prefFile "Window_state" "save")
	global _SET_ExportToogle = 				execute(getIniSetting _MLM_prefFile "Window_state" "checkExport")
	global _SET_ImportToogle = 				execute(getIniSetting _MLM_prefFile "Window_state" "checkImport")
	global _SET_AutoClose =					execute(getIniSetting _MLM_prefFile "UI" "autoClose")
	global _SET_PopUpWarning =				execute(getIniSetting _MLM_prefFile "UI" "popupWarning")
)

-- UI
rollout _MLM_matlibManager "Matlib Manager - 0.2a" width:248 height:488
(
	checkbutton 	_UIbtnExport 	"EXPORT" 		pos:[8,8] 		width:112 	height:24 	checked:_SET_ExportToogle
	checkbutton 	_UIbtnImport 	"IMPORT" 		pos:[128,8] 	width:112 	height:24 	checked:_SET_ImportToogle

	groupBox 		_grpExport 		"EXPORT" 		pos:[8,40] 		width:232 	height:136
	label 			_lblExpName 	"Name:" 		pos:[16,59] 	width:56 	height:16
	editText 		_edtExpName 	"" 				pos:[72,56] 	width:160 	height:21
	label 			_lblExpCat 		"Categorie:" 	pos:[16,90] 	width:56 	height:16 	
	dropDownList 	_ddlExpCat 		"" 				pos:[75,88] 	width:158 	height:21 	items:_SET_Categories
	label 			_lblExpFrom 	"From:" 		pos:[16,119] 	width:56 	height:16
	radioButtons 	_rdoExpFrom 	"" 				pos:[73,120] 	width:146 	height:16 	labels:#("Scene", "Selection") columns:2 default:_SET_ExportMode
	button 			_btnExport 		"Export" 		pos:[16,144] 	width:216 	height:24
	
	groupBox 		_grpImport 		"IMPORT" 		pos:[8,184] 	width:232 	height:232
	label 			_lblImpCat 		"Categorie:" 	pos:[16,203] 	width:56 	height:16
	dropDownList 	_ddlImpCat 		"" 				pos:[74,201] 	width:158 	height:21 	items:_SET_Categories
	listBox 		_lbxImpMat 		"" 				pos:[16,232] 	width:216 	height:8
	editText 		_edtImpSearch 	"" 				pos:[13,344] 	width:219 	height:21
	button 			_btnImport 		"Import" 		pos:[16,376] 	width:216 	height:24
		
	button 			_btnSettings 	"Settings..." 	pos:[8,424] 	width:96 	height:24
	button 			_btnManage 		"Manage..." 	pos:[112,424] 	width:96 	height:24
	button 			_btnAbout 		"?" 			pos:[216,424] 	width:24 	height:24
	button 			_btnClose 		"Close" 		pos:[8,456] 	width:232 	height:24

	-- Fuctions #UI

	function FNmajUIicons =
	(
		if _SET_Icons == 1 then -- Dark
		(
			_iconsFile = _MLM_icons + "MLM_darkIcons.bmp"
			_icons2File = _MLM_icons + "MLM_darkIcons2.bmp"
		)
		else -- Bright
		(
			_iconsFile = _MLM_icons + "MLM_brightIcons.bmp"
			_icons2File = _MLM_icons + "MLM_brightIcons2.bmp"
		)

		if _SET_Appearance == 1 do -- Icons
		(
			_btnExport.images 		= #(_iconsFile,_iconsFile,32,2,18,2,1)
			_btnImport.images 		= #(_iconsFile,_iconsFile,32,3,19,3,1)
			_btnSettings.images 	= #(_icons2File,_icons2File,42,7,21,35,21)
			_btnManage.images 		= #(_icons2File,_icons2File,42,2,16,2,1)
			_btnAbout.images 		= #(_iconsFile,_iconsFile,32,8,24,8,1) 
			_btnClose.images 		= #(_iconsFile,_iconsFile,32,7,23,7,1)
		)
	)

	function FNhideExport _bool =
	(
		_grpExport.visible = _bool
		_lblExpName.visible = _bool
		_edtExpName.visible = _bool
		_lblExpCat.visible = _bool
		_ddlExpCat.visible = _bool
		_lblExpFrom.visible = _bool
		_rdoExpFrom.visible = _bool
		_btnExport.visible = _bool
	)

	function FNhideImport _bool =
	(
		_grpImport.visible = _bool
		_lblImpCat.visible = _bool
		_ddlImpCat.visible = _bool
		_lbxImpMat.visible = _bool
		_edtImpSearch.visible = _bool
		_btnImport.visible = _bool
	)

	function FNposImport _boolExport _boolImport =
	(
		if _boolExport == false and _boolImport == true then
		(
			_grpImport.pos		= [8,40] 
			_lblImpCat.pos		= [16,59]
			_ddlImpCat.pos		= [74,57]
			_lbxImpMat.pos		= [16,88]
			_edtImpSearch.pos	= [16,206]
			_btnImport.pos		= [16,232]
		)
		else
		(
			_grpImport.pos		= [8,184] 
			_lblImpCat.pos		= [16,203]
			_ddlImpCat.pos		= [74,201]
			_lbxImpMat.pos		= [16,232]
			_edtImpSearch.pos	= [16,346]
			_btnImport.pos		= [16,376]
		)
	)

	function FNposFooter _boolExport _boolImport =
	(
		if _boolExport == true and _boolImport == true do
		(
			_btnSettings.pos 	= [8,424] 
			_btnManage.pos 		= [112,424]
			_btnAbout.pos 		= [216,424]
			_btnClose.pos 		= [8,456]
		)

		if _boolExport == false and _boolImport == true do
		(
			_btnSettings.pos 	= [8,280]
			_btnManage.pos 		= [112,280]
			_btnAbout.pos 		= [216,280]
			_btnClose.pos 		= [8,312]
		)

		if _boolExport == true and _boolImport == false do
		(
			_btnSettings.pos 	= [8,184] 
			_btnManage.pos 		= [112,184]
			_btnAbout.pos 		= [216,184]
			_btnClose.pos 		= [8,216]
		)

		if _boolExport == false and _boolImport == false do
		(
			_btnSettings.pos 	= [8,40] 
			_btnManage.pos 		= [112,40]
			_btnAbout.pos 		= [216,40]
			_btnClose.pos 		= [8,72]
		)
	)

	function FNwinSize _boolExport _boolImport =
	(
		if _boolExport == true and _boolImport == true 		do (_MLM_matlibManager.height = 488)
		if _boolExport == false and _boolImport == true 	do (_MLM_matlibManager.height = 344)
		if _boolExport == true and _boolImport == false 	do (_MLM_matlibManager.height = 248)
		if _boolExport == false and _boolImport == false 	do (_MLM_matlibManager.height = 104)
	)

	function FNmajUIswitches =
	(
		FNhideExport (_UIbtnExport.state)
		FNhideImport (_UIbtnImport.state)
		FNposImport _UIbtnExport.state _UIbtnImport.state
		FNposFooter _UIbtnExport.state _UIbtnImport.state
		FNwinSize _UIbtnExport.state _UIbtnImport.state
	)

	-- Functions#Core

	function FNgetEntriesBySearch _value _cat =
	(
		_filesToLookIn = _SET_DatabaseFolder + _cat + "\\"
		_listDbDir = getFiles (_filesToLookIn + "*.mlm")
		_entriesFound = #()

		for i in _listDbDir do
		(
			_filterPath = filterstring i "\\"
			_filterPathCount = _filterPath.count
			_entryName = _filterPath[_filterPathCount]
			_tempCount = (_entryName.count - 4)
			_entryName = substring _entryName 1 _tempCount

			if _value != "" and _value != undefined then
			( 
				_searchBool = findString _entryName _value
				if _searchBool != undefined do _entriesFound = append _entriesFound _entryName
			)
			else (_entriesFound = append _entriesFound _entryName)
		)
		if _entriesFound.count < 1 then
		(
			return #()
		)
		else
		(
			return _entriesFound
		)
	)

	function FNcheckEmpty _value _cat =
	(
		_filesToLookIn = _SET_DatabaseFolder + _cat + "\\"
		_listDbDir = getFiles (_filesToLookIn + "*.mlm")
		_entriesFound = #()

		for i in _listDbDir do
		(
			_filterPath = filterstring i "\\"
			_filterPathCount = _filterPath.count
			_entryName = _filterPath[_filterPathCount]
			_tempCount = (_entryName.count - 4)
			_entryName = substring _entryName 1 _tempCount

			if _value != "" and _value != undefined then
			( 
				_searchBool = findString _entryName _value
				if _searchBool != undefined do _entriesFound = append _entriesFound _entryName
			)
			else (_entriesFound = append _entriesFound _entryName)
		)
		if _entriesFound.count < 1 then
		(
			return true
		)
		else
		(
			return false
		)
	)

	function FNimportMat _file =
	(
		local _file = openFile _file
		local _container = #()
		while not eof _file do
		(
			_readLine = readLine _file
			_container = append _container _readLine
			_objNotFound = #()
		)

		close _file
		_matPath = _container[1]
		_matDistrib = execute _container[2]

		loadMaterialLibrary _matPath
		
		for i in _matDistrib do
		(
			_sceneObj = $*
			_listObjsToMat = #()

			for obj in _sceneObj do
			(
				_sceneObjName = obj.name
				_entryObjName = i[2]

				
				_splitSymbol = _SET_SepSym
				_numberOfDigits = _SET_NumDig
				_totalAdddedSymbols = _splitSymbol.count + _numberOfDigits
				_totalSymbols = _sceneObjName.count
				_newCount = _totalSymbols - _totalAdddedSymbols

				_subString = substring _sceneObjName 1 _newCount


				if _entryObjName == _sceneObjName or _entryObjName == _subString do
				(
					_listObjsToMat = append _listObjsToMat obj
				)
			)
			if _listObjsToMat.count == 0 then
			(
				_objNotFound = append _objNotFound i[2]
			)
			else
			(
				for _objsMat in _listObjsToMat do
				(
					_objsMat.material = currentMaterialLibrary[i[1]]
				)
			)
		)
		return _objNotFound
	)

	function FNobjectNotFound _array =
	(
		_compteur = 0
		_msgText = "The following objets were not found in the scene:\n"
		for i in _array do
		(
			_compteur = _compteur + 1
			_msgText = _msgText + "- " + _array[_compteur] + "\n"
		)
		FNmsgBox _msgText "warning" false
	)

	function FNpreImportMat =
	(
		_successImport = false

		--_SET_DatabaseFolder
		--_SET_MatlibFolder

		_importPath = _SET_DatabaseFolder + _ddlImpCat.text + "\\" + _lbxImpMat.selected + ".mlm"
		_return = FNimportMat _importPath
		
		if _return[1] != undefined then
		(
			FNobjectNotFound _return
			_successImport = false
		)
		else
		(
			_successImport = true
		)
		
		if _SET_AutoClose == true and _successImport == true do Destroydialog _MLM_matlibManager
	)

	-- Internal UI
	rollout _MLM_about "About Matlib Manager" 	width:376 	height:380
	(
		bitmap 		bmp2 "Bitmap" 											pos:[8,8] 		width:360 	height:220 fileName:_MLM_aboutImage
		label 		lbl1 "Version: 0.2a (alpha)" 							pos:[128,240] 	width:104 	height:16
		label 		lbl2 "Release date: 01/21/2015" 						pos:[117,260] 	width:128 	height:16
		HyperLink	lbl3 "Licence: GNU/GPL v3" 								pos:[128,280] 	width:104 	height:16 address:"http://www.gnu.org/licenses/gpl-3.0.en.html"
		HyperLink 	lbl5 "Project page: www.onectin.fr/matlib-manager" 		pos:[69,300] 	width:224 	height:16 address:"http://www.onectin.fr/matlib-manager"
		label 		lbl6 "Contact: onectin@onectin.fr" 						pos:[110,320] 	width:144 	height:16
		button 		btn1 "Close" 											pos:[8,350] 	width:360 	height:24 tooltip:"Close"
		
		on _MLM_about open do
		(
			try(DestroyDialog ::_MLM_about) catch()
		)

		on btn1 pressed do destroyDialog _MLM_about
	)

	rollout _MLM_manage "Manage Matlib entries" width:560 height:480
	(
		listBox 		lbxCat 			"" 							pos:[8,24] 		width:96 	height:34 items:_SET_Categories
		MultilistBox 	lbxEntries	 	"" 							pos:[112,24] 	width:320 	height:32
		button 			btnOpenData	 	"Open data's location" 		pos:[440,24] 	width:112 	height:24
		button 			btnOpenMatlib	"Open matlib's location" 	pos:[440,56] 	width:112 	height:24
		button 			btnChangeCat 	"Change category to:" 		pos:[440,88] 	width:112 	height:24
		dropDownList 	ddlCatTarget 	"" 							pos:[440,120] 	width:112 	height:21 items:_SET_Categories
		button 			btnClose 		"Close" 					pos:[440,448] 	width:112 	height:24
		editText 		edtSearch 		"" 							pos:[108,450] 	width:324 	height:21
		label 			lblCat 			"Categories:" 				pos:[8,8] 		width:80 	height:16
		label 			lblEntries 		"Entries:" 					pos:[112,8] 	width:80 	height:16
		button 			btnRename		"Rename to:" 				pos:[440,152] 	width:112 	height:24
		editText 		edtRename 		"" 							pos:[437,180] 	width:115 	height:24
		button 			btnDel 			"Delete" 					pos:[440,216] 	width:112 	height:24

		function FNmajLbxEntries = lbxEntries.items = FNgetEntriesBySearch edtSearch.text lbxCat.selected

		function FNmajMainWin = _MLM_matlibManager._lbxImpMat.items = FNgetEntriesBySearch _MLM_matlibManager._edtImpSearch.text _MLM_matlibManager._ddlImpCat.text

		on _MLM_manage open do
		(
			FNmajLbxEntries()
		)

		on lbxCat selected state do
		(
			FNmajLbxEntries()
		)

		on btnChangeCat pressed do
		(
			_selectedEntries =  lbxEntries.selection
			for i in _selectedEntries do 
			(
				_currentName = lbxEntries.items[i]
				_currentCat = lbxCat.selected
				_newCat = ddlCatTarget.text
				_old = _SET_DatabaseFolder + _currentCat + "\\" + _currentName + ".mlm"
				_new = _SET_DatabaseFolder + _newCat + "\\" + _currentName + ".mlm"
				renameFile _old _new
			)

			FNmajLbxEntries()
			FNmajMainWin()
		)

		on btnRename pressed do
		(
			if edtRename.text == "" then
			(
				FNmsgBox "Name's field is empty." "error" false
			)
			else
			(
				_selectedEntries = lbxEntries.selection
	
				_selAsArray =  _selectedEntries as array
	
				if _selAsArray.count < 1 then
				(
					FNmsgBox "Nothing selected !" "error" false
				)
				else
				(
					if _selAsArray.count > 1 do
					(
						FNmsgBox "Multiple selection ! \n The operation will only affects the first selected entry." "info" false
					)
	
					_topSelection = lbxEntries.items.count
					for i in _selectedEntries do
					(
						if i < _topSelection do	_topSelection = i
					)
		
					_currentName = lbxEntries.items[_topSelection]
					_currentCat = lbxCat.selected
					
					_newName = edtRename.text
					
					_currentMatlibPath = _SET_MatlibFolder + _currentName + ".mat"
					_newMatlibPath = _SET_MatlibFolder + _newName + ".mat"
					
					_currentMlmPath = _SET_DatabaseFolder + _currentCat + "\\" + _currentName + ".mlm"
					_newMlmPath = _SET_DatabaseFolder + _currentCat + "\\" + _newName + ".mlm"
	
					local _currentMlmPathOp = openFile _currentMlmPath
					local _container = #()
					while not eof _currentMlmPathOp do
					(
						_readLine = readLine _currentMlmPathOp
						_container = append _container _readLine
					)
					close _currentMlmPathOp
	
					_container[1] = _newMatlibPath

					deleteFile _currentMlmPath
					_tempCreate = createFile _currentMlmPath
					flush _tempCreate
					close _tempCreate

					_toStr = execute(_container[2])

					_strLine2 = FNtoString _toStr
					_strInfo = _container[1] + "\n" + _strLine2
	
					_tempOpen = openFile _currentMlmPath mode:"r+"
					format _strInfo to:_tempOpen
					flush _tempOpen
					close _tempOpen

					renameFile _currentMatlibPath _newMatlibPath
					renameFile _currentMlmPath _newMlmPath

					edtRename.text = ""
					FNmajLbxEntries()
					FNmajMainWin()
				)
			)
		)

		on btnOpenData pressed do
		(
			_selectedEntries = lbxEntries.selection
			_selAsArray =  _selectedEntries as array
			if _selAsArray.count < 1 then
			(
				FNmsgBox "Nothing selected !" "error" false
			)
			else
			(
				if _selAsArray.count > 1 do
				(
					FNmsgBox "Multiple selection ! \n The operation will only affects the first selected entry." "info" false
				)

				_topSelection = lbxEntries.items.count
				for i in _selectedEntries do
				(
					if i < _topSelection do	_topSelection = i
				)

				_currentName = lbxEntries.items[_topSelection]
				_currentCat = lbxCat.selected

				_currentMlmPath = _SET_DatabaseFolder + _currentCat + "\\"

				shellLaunch "explorer.exe" _currentMlmPath
			)
		)

		on btnOpenMatlib pressed do
		(
			_selectedEntries = lbxEntries.selection
			_selAsArray =  _selectedEntries as array
			if _selAsArray.count < 1 then
			(
				FNmsgBox "Nothing selected !" "error" false
			)
			else
			(
				if _selAsArray.count > 1 do
				(
					FNmsgBox "Multiple selection ! \n The operation will only affects the first selected entry." "info" false
				)

				_topSelection = lbxEntries.items.count
				for i in _selectedEntries do
				(
					if i < _topSelection do	_topSelection = i
				)

				_currentName = lbxEntries.items[_topSelection]
				_currentCat = lbxCat.selected

				_currentMatlibPath = _SET_MatlibFolder

				shellLaunch "explorer.exe" _currentMatlibPath
			)
		)

		on btnDel pressed do
		(
			for i in lbxEntries.selection do
			(
				_currentName = lbxEntries.items[i]
				_currentCat = lbxCat.selected
				
				_currentMatlibPath = _SET_MatlibFolder + _currentName + ".mat"
				
				_currentMlmPath = _SET_DatabaseFolder + _currentCat + "\\" + _currentName + ".mlm"
				
				deleteFile _currentMatlibPath
				deleteFile _currentMlmPath
			)

			FNmajLbxEntries()
			FNmajMainWin()


		)

		on btnClose pressed do
		(
			destroyDialog _MLM_manage
		)

		on edtSearch changed value do
		(
			FNmajLbxEntries()
		)
	)

	rollout _MLM_DeleteEntrie "Delete Files ?" width:312 height:96
	(
		button 		btnDEL_Cancel 	"Cancel" 				pos:[216,64] 	width:88 	height:24
		button 		btnDEL_OverW 	"Overwrite" 			pos:[120,64] 	width:88 	height:24
		label 		lblDEL_Msg01 	_MLM_deleteEntryMsg01 	pos:[8,8] 		width:296 	height:24
		label 		lblDEL_Msg02 	_MLM_deleteEntryMsg02 	pos:[8,32] 		width:296 	height:24

		on btnDEL_Cancel pressed do
		(
			Destroydialog _MLM_DeleteEntrie
		)

		on btnDEL_OverW pressed do
		(
			FNexportMat _MLM_matlibManager._ddlExpCat.text _MLM_matlibManager._edtExpName.text
			_success = true
			if _SET_AutoClose == true and _success == true do Destroydialog _MLM_matlibManager
			_MLM_matlibManager._lbxImpMat.items = FNgetEntriesBySearch _MLM_matlibManager._edtImpSearch.text _MLM_matlibManager._ddlImpCat.text
			Destroydialog _MLM_DeleteEntrie
		)
	)

	-- UI triggers

	on _MLM_matlibManager open do
	(
		clearlistener()
		FNmajUIswitches()
		FNmajUIicons()
		_lbxImpMat.items = FNgetEntriesBySearch _edtImpSearch.text _ddlImpCat.text
	)

	on _UIbtnExport changed state do 
	(
		setIniSetting _MLM_prefFile "Window_state" "checkExport" (state as string)
		FNmajUIswitches()
	)
	
	on _UIbtnImport changed state do 
	(
		setIniSetting _MLM_prefFile "Window_state" "checkImport" (state as string)
		FNmajUIswitches()
	)

	on _UIbtnExport rightclick do 
	(
		setIniSetting _MLM_prefFile "Window_state" "checkExport" (true as string)
		setIniSetting _MLM_prefFile "Window_state" "checkImport" (false as string)
		_UIbtnExport.state = true
		_UIbtnImport.state = false
		FNmajUIswitches()
	)

	on _UIbtnImport rightclick do 
	(
		setIniSetting _MLM_prefFile "Window_state" "checkExport" (false as string)
		setIniSetting _MLM_prefFile "Window_state" "checkImport" (true as string)
		_UIbtnExport.state = false
		_UIbtnImport.state = true
		FNmajUIswitches()
	)

	on _MLM_matlibManager moved _pos do
    (
        setIniSetting _MLM_prefFile "Window_Position" "position" (_pos as string)
    )

    on _btnExport pressed do
    (
    	_currentName = _edtExpName.text
    	_currentCat = _ddlExpCat.text
		_success = false

		if _currentName == "" or _currentCat == "" then
		(
			FNmsgBox "Please select a category and/or set a name." "error" false
		)
		else
		(
			if _rdoExpFrom.state == 1 then -- From scene
			(
				select objects
				_tmpSel = selection as array
				if _tmpSel.count != 0 then 
				(
					_checkAlreadyExists = FNgetEntriesBySearch _currentName _currentCat
					_checkEmpty = FNcheckEmpty _currentName _currentCat

					if _checkAlreadyExists == #() or _checkEmpty == true then
					(
						FNexportMat _currentCat _currentName
						_success = true
					)
					else 
					(
						createDialog _MLM_DeleteEntrie
					)
				)
				else
				(
					FNmsgBox "Selection is empty: nothing to export." "error" false
				)
			)
			else -- From selection
			(
				_tmpSel = selection as array
				if _tmpSel.count != 0 then 
				(
					_checkAlreadyExists = FNgetEntriesBySearch _currentName _currentCat
					_checkEmpty = FNcheckEmpty _currentName _currentCat

					if _checkAlreadyExists == #() or _checkEmpty == true then
					(
						FNexportMat _currentCat _currentName
						_success = true
					)
					else 
					(
						createDialog _MLM_DeleteEntrie
					)
				)
				else
				(
					FNmsgBox "Scene is empty: nothing to export." "error" false
				)
			)			
		)
		if _SET_AutoClose == true and _success == true do Destroydialog _MLM_matlibManager
		_lbxImpMat.items = FNgetEntriesBySearch _edtImpSearch.text _ddlImpCat.text
    )

    on  _ddlImpCat selected state do
    (
    	_lbxImpMat.items = FNgetEntriesBySearch _edtImpSearch.text _ddlImpCat.text
    )

    on _edtImpSearch changed value do
    (
    	_lbxImpMat.items = FNgetEntriesBySearch value _ddlImpCat.text
    )

	on _btnImport pressed do
	(
		FNpreImportMat()
	)

	on _btnSettings pressed do fileIn _MLM_prefScript
	on _btnManage pressed do createDialog _MLM_manage
	on _btnAbout pressed do createDialog _MLM_about
	
	on _btnClose pressed do 
	(
		destroyDialog _MLM_matlibManager	
		destroyDialog _MLM_matlibManager
		destroyDialog _MLM_preferences
		destroyDialog _MLM_about
		destroyDialog _MLM_manage
	)
)

if _checkPrefFile.count != 0 do
(
	_rolloutPosition = execute(getIniSetting _MLM_prefFile "Window_Position" "position")
	if _SET_WinPositionRecord == true and (_rolloutPosition != undefined) do
	(
		createDialog _MLM_matlibManager 248 488 _rolloutPosition.x _rolloutPosition.y style:#(#style_border, #style_sysmenu ,#style_minimizebox, #style_titlebar)
	)
	if _SET_WinPositionRecord == false do
	(
		createDialog _MLM_matlibManager 248 488 style:#(#style_border, #style_sysmenu ,#style_minimizebox, #style_titlebar)
	)
)
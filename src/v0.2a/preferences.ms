-- Matlib Manager
-- v0.2a
-- 19/01/2015
-- onectin@onectin.fr
-- --------------------------
-- preferences.ms


-- Kill  any other window from MLM
try(DestroyDialog ::_MLM_matlibManager) catch()
try(DestroyDialog ::_MLM_preferences) catch()
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

-- Check prefFile
_checkPrefFile = getFiles _MLM_prefFile

-- Variables
_winLastPos = "[0,0]"
_winPos = [0,0]
_firstLaunch = false
_editStatus = "add"
_editName = ""

-- Texts & Tooltips
_MLM_deleteCatMsg01 = "Do you want to keep this category's entries ?"
_MLM_deleteCatMsg02 = "If you choose keep, the folder will be kept, but won't be available in the categories list. "
_MLM_TT_windowPos = "When checked, the main window's position will be saved, and the window will always appears on it's last place."
_MLM_TT_windowState = "When checked, the state of \"the EXPORT\" and \"IMPORT\" buttons will be saved."
_MLM_TT_popupWarn = "When checked, there are no errors/warning/info popups, all these informations are displayed in the maxscript listener (f11)"

-- Functions #HEADER
function FNmsgBox _message =
(
	messageBox _message beep:false title:"Matlib Manager"
)

-- preferences.ini
if _checkPrefFile.count == 0 then
(
	_firstLaunch = true

	global _SET_DatabaseFolder 			= ""
	global _SET_MatlibFolder			= ""
	global _SET_Categories 				= #()
	global _SET_SepSym 					= "_"
	global _SET_NumDig	 				= 3
	global _SET_ExportMode 				= 1
	global _SET_Appearance 				= 2
	global _SET_Icons 					= 1
	global _SET_WinPositionRecord 		= true
	global _SET_WinPositionPosition 	= [50,50]
	global _SET_WindowState 			= true
	global _SET_ExportToogle 			= true			
	global _SET_ImportToogle			= true
	global _SET_AutoClose 				= false
	global _SET_PopUpWarning			= true

	_oldMacroFile = _MLM_dir + "\\matlibManager.mcr"
	_newMacroFile = _macroDir + "\\matlibManager.mcr"
	deleteFile _newMacroFile
	copyFile _oldMacroFile _newMacroFile
	deleteFile _oldMacroFile
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
rollout _MLM_preferences "Matlib Manager - Settings" width:424 height:516
(
	groupBox 		grpPaths 			"Paths" 				pos:[8,8] 		width:408 	height:112
	label 			lblPathsDb 			"Database folder:" 		pos:[21,24] 	width:184 	height:16
	editText 		edtPathsDb 			"" 						pos:[16,40] 	width:320 	height:24
	button 			btnPathsDb 			"Browse..." 			pos:[344,40] 	width:64 	height:24
	label 			lblPathsMatlib 		"Matlib folder:" 		pos:[21,70] 	width:184 	height:16
	editText 		edtPathsMatlib 		"" 						pos:[16,86] 	width:320 	height:24
	button 			btnPathsMatlib 		"Browse..." 			pos:[344,86] 	width:64 	height:24
	
	groupBox 		grpCat 				"Categories" 			pos:[8,128] 	width:408 	height:136
	listBox 		lbxCat 				"" 						pos:[16,144] 	width:320 	height:8
	button 			btnCatAdd 			"Add..." 				pos:[344,144] 	width:64 	height:24
	button 			btnCatEdit 			"Edit..." 				pos:[344,176] 	width:64 	height:24
	button 			btnCatDel 			"Delete..." 			pos:[344,208] 	width:64 	height:24
	
	groupBox 		grpUi 				"UI" 					pos:[8,272] 	width:408 	height:126
	label 			lblUiExportMode 	"Default export mode:" 	pos:[16,288] 	width:136 	height:16
	radioButtons 	rdoUiExportMode 	"" 						pos:[16,304] 	width:91 	height:32 labels:#("From scene", "From selection") columns:1
	label 			lblUiAppearence 	"Appearance:" 			pos:[176,288] 	width:112 	height:16
	radioButtons 	rdoUiAppearance 	"" 						pos:[176,304] 	width:44	height:32 labels:#("Icon", "Text") columns:1
	label 			lblUiIcons 			"Icons:" 				pos:[328,288] 	width:72	height:16
	radioButtons 	rdoUiIcons 			"" 						pos:[328,304] 	width:46	height:32 labels:#("Dark", "Light") columns:1
	label 			lblUiWinPos 		"Save window position" 	pos:[32,352] 	width:120 	height:16 tooltip:_MLM_TT_windowPos
	checkbox 		chkUiWinPos 		"" 						pos:[16,352] 	width:16 	height:16 tooltip:_MLM_TT_windowPos
	label 			lblUiWinState 		"Save window state" 	pos:[192,352] 	width:120 	height:16 tooltip:_MLM_TT_windowState
	checkbox 		chkUiWinState 		"" 						pos:[176,352] 	width:16 	height:16 tooltip:_MLM_TT_windowState
	label 			lblUiAutoClose 		"Auto-close" 			pos:[344,352] 	width:64 	height:16
	checkbox 		chkUiAutoClose 		"" 						pos:[328,352] 	width:16 	height:16
	label 			lblUiPopupWarning	"Popup Warnings" 		pos:[32,374] 	width:120 	height:16 tooltip:_MLM_TT_popupWarn
	checkbox 		chkUiPopupWarning	"" 						pos:[16,374] 	width:16 	height:16 tooltip:_MLM_TT_popupWarn

	groupBox 		grpMultiObj 		"Replicated objects" 	pos:[8,406] 	width:408 	height:68
	label 			lblSepSym 			"Separation symbol:" 	pos:[16,424] 	width:120 	height:16
	label 			lblNumDig 			"Number of digits:" 	pos:[232,424] 	width:88 	height:16
	editText 		edtSepSym 			"" 						pos:[120,424] 	width:72 	height:16
	spinner 		spnNumDig 			"" 						pos:[336,424] 	width:72 	height:16 range:[0,10000,1] type:#integer
	label 			lblExample 			"Example:" 				pos:[16,448] 	width:120 	height:16
	editText 		edtExample 			"" 						pos:[120,448] 	width:288 	height:16 enabled:false
	
	button 			btnSave 			"Save" 					pos:[336,484] 	width:80 	height:24
	button 			btnCancel 			"Cancel" 				pos:[248,484] 	width:80 	height:24

	-- Fuctions #UI
	function FNmajExampleField =
	(
		_number = ""
		for i = 2 to spnNumDig.value do
		(
			_number = _number + "0"
		)

		_number = _number + "4"

		edtExample.text = " randomObject" + edtSepSym.text + _number
	)

	function FNsetSettings =
	(
		edtPathsDb.text					= _SET_DatabaseFolder
		edtPathsMatlib.text				= _SET_MatlibFolder
		lbxCat.items					= _SET_Categories
		rdoUiExportMode.state			= _SET_ExportMode
		rdoUiAppearance.state			= _SET_Appearance
		rdoUiIcons.state				= _SET_Icons
		chkUiWinPos.checked				= _SET_WinPositionRecord 
		chkUiWinState.checked			= _SET_WindowState
		chkUiAutoClose.checked			= _SET_AutoClose
		chkUiPopupWarning.checked 		= _SET_PopUpWarning
		edtSepSym.text 					= _SET_SepSym
		spnNumDig.value 				= _SET_NumDig
	)

	function FNsaveSettings =
	(
		_DatabaseFolder =			edtPathsDb.text
		_MatlibFolder =				edtPathsMatlib.text
		_Categories =				lbxCat.items
		_ExportMode =				rdoUiExportMode.state
		_Appearance =				rdoUiAppearance.state
		_Icons =					rdoUiIcons.state
		_WinPositionRecord = 		chkUiWinPos.checked
		_WinPositionPosition =		_SET_WinPositionPosition
		_WindowState =				chkUiWinState.checked
		_ExportToogle = 			_SET_ExportToogle
		_ImportToogle = 			_SET_ImportToogle
		_AutoClose =				chkUiAutoClose.checked
		_PopUpWarning =				chkUiPopupWarning.checked
		_SepSym = 					edtSepSym.text 	
		_NumDig = 					spnNumDig.value 

		setIniSetting _MLM_prefFile "Paths" "database" (_DatabaseFolder as string)
		setIniSetting _MLM_prefFile "Paths" "matlib" (_MatlibFolder as string)
		setIniSetting _MLM_prefFile "Datas" "categories" (_Categories as string)
		setIniSetting _MLM_prefFile "Datas" "separationSymbol" (_SepSym as string)
		setIniSetting _MLM_prefFile "Datas" "numberOfDigits" (_NumDig as string)
		setIniSetting _MLM_prefFile "UI" "exportMode" (_ExportMode as string)
		setIniSetting _MLM_prefFile "UI" "appearance" (_Appearance as string)
		setIniSetting _MLM_prefFile "UI" "icons" (_Icons as string)
		setIniSetting _MLM_prefFile "Window_Position" "save" (_WinPositionRecord as string)
		setIniSetting _MLM_prefFile "Window_Position" "position" (_WinPositionPosition as string)
		setIniSetting _MLM_prefFile "Window_state" "save" (_WindowState as string)
		setIniSetting _MLM_prefFile "Window_state" "checkExport" (_ExportToogle as string)
		setIniSetting _MLM_prefFile "Window_state" "checkImport" (_ImportToogle as string)
		setIniSetting _MLM_prefFile "UI" "autoClose" (_AutoClose as string)
		setIniSetting _MLM_prefFile "UI" "popupWarning" (_PopUpWarning as string)
	)

	function FNcheckSettings =
	(
		_checkDataBasePath = ((dotnetclass "System.IO.Directory").exists edtPathsDb.text)
		_checkMatlibPath = ((dotnetclass "System.IO.Directory").exists edtPathsMatlib.text)
		_checkCategories = lbxCat.items

		_valid = true

		_message = "The following issues have been encountered:\n\n"

		if _checkDataBasePath == false do
		(
			_message = _message + "- Database folder is invalid.\n"
			_valid = false
		)
		if _checkMatlibPath == false do
		(
			_message = _message + "- Matlib folder is invalid.\n"
			_valid = false
		)
		if _checkCategories.count == 0 do
		(
			_message = _message + "- At least one category must be created.\n"
			_valid = false
		)

		if _valid == false do FNmsgBox _message
		if _valid == true do return true
	)

	function FNrefreshCat =
	(
		lbxCat.items = _SET_Categories
	)

	function FNcheckCat =
	(
		_nonFoundDir = "The following directories haven't been found, so these categories have been deleted:\n"
		_errors = false
		for i in _SET_Categories do
		(
			_path = _SET_DatabaseFolder + i
			_chkPath = (dotnetclass "System.IO.Directory").exists _path
			if _chkPath == false do
			(
				_nonFoundDir = _nonFoundDir + "- " + i + ": " + _path + "\n"
				_deleteId = findItem _SET_Categories i
				deleteItem _SET_Categories _deleteId
				_errors = true
			)
		)
		if _errors == true do
		(
			setIniSetting _MLM_prefFile "Datas" "categories" (_SET_Categories as string)
			FNmsgBox _nonFoundDir
		)
	)

	-- Internal UI:
	rollout _MLM_DeleteCat "Delete Files ?" width:312 height:96
	(
		button 		btnDEL_Keep 	"Keep" 					pos:[216,64] 	width:88 	height:24
		button 		btnDEL_Del 		"Delete" 				pos:[120,64] 	width:88 	height:24
		label 		lblDEL_Msg01 	_MLM_deleteCatMsg01 	pos:[8,8] 		width:296 	height:24
		label 		lblDEL_Msg02 	_MLM_deleteCatMsg02 	pos:[8,32] 		width:296 	height:24

		on btnDEL_Keep pressed do
		(
			_editName = lbxCat.selected as string
	
			_deleteId = findItem _SET_Categories _editName
			deleteItem _SET_Categories _deleteId
			FNrefreshCat()
			setIniSetting _MLM_prefFile "Datas" "categories" (_SET_Categories as string)
			destroyDialog _MLM_DeleteCat

			_old = _SET_DatabaseFolder + _editName
			_new = _SET_DatabaseFolder + _editName + "_OLD"
			renameFile _old _new
		)

		on btnDEL_Del pressed do
		(
			_editName = lbxCat.selected as string
			_pathToDel = _SET_DatabaseFolder + _editName 
	
			_dos = "rmdir " + _pathToDel + "/S /Q"
			doscommand _dos
	
			_deleteId = findItem _SET_Categories _editName
			deleteItem _SET_Categories _deleteId
			FNrefreshCat()
			setIniSetting _MLM_prefFile "Datas" "categories" (_SET_Categories as string)
			destroyDialog _MLM_DeleteCat
		)
	)

	rollout _MLM_NewEditCat "New/Edit category" width:192 height:96
	(
		button 		btnNEC_Save 	"Save" 					pos:[96,64] 	width:88 	height:24
		editText 	edtNEC_Save 	"" 						pos:[4,32] 		width:179 	height:24 
		button 		btnNEC_Cancel 	"Cancel" 				pos:[8,64] 		width:80 	height:24
		label 		lblNEC_Txt 		"Categorie's name:" 	pos:[8,8] 		width:152 	height:16

		on _MLM_NewEditCat open do
		(
			if _editStatus == "edit" do edtNEC_Save.text = _editName
		)

		on btnNEC_Cancel pressed do destroyDialog _MLM_NewEditCat

		on btnNEC_Save pressed do
		(
			_currentName = edtNEC_Save.text

			_checkPreExist = findItem _SET_Categories _currentName
			if _checkPreExist != 0 then
			(
				FNmsgBox "There is already a category with this name."
			)
			else
			(			
				if _editStatus == "add" do
				(
					makeDir (_SET_DatabaseFolder + _currentName)
				)
	
				if _editStatus == "edit" do
				(
					_old = _SET_DatabaseFolder + _editName
					_new = _SET_DatabaseFolder + _currentName
					renameFile _old _new
					_deleteId = findItem _SET_Categories _editName
					deleteItem _SET_Categories _deleteId
					
				)
				_SET_Categories = append _SET_Categories _currentName
				setIniSetting _MLM_prefFile "Datas" "categories" (_SET_Categories as string)
				FNrefreshCat()
				destroyDialog _MLM_NewEditCat
			)
		)
	)

	-- UI triggers

	on _MLM_preferences open do
	(
		if _firstLaunch == true then
		(
			btnCancel.enabled = false
		)
		FNsetSettings()
		FNcheckCat()
		FNmajExampleField()
	)

	on btnPathsDb pressed do
	(
		_temp = getSavepath initialDir:_rootDir
		if _temp != undefined do edtPathsDb.text = _temp + "\\"
	)

	on btnPathsMatlib pressed do
	(
		_temp = getSavepath initialDir:_rootDir
		if _temp != undefined do edtPathsMatlib.text = _temp + "\\"
	)

	on btnCatAdd pressed do
	(
		_editStatus = "add"
		createDialog _MLM_NewEditCat
	)

	on btnCatEdit pressed do
	(
		_editStatus = "edit"
		_editName = lbxCat.selected
		createDialog _MLM_NewEditCat
	)

	on btnCatDel pressed do
	(
		_editName = lbxCat.selected as string
		--files = #()
		_pathToCheck = _SET_DatabaseFolder + _editName + "\\*.mlm"
		_pathToDel = _SET_DatabaseFolder + _editName 

		files = getFiles _pathToCheck
		if files.count == 0 then
		(
			_dos = "rmdir " + _pathToDel + "/S /Q"
			doscommand _dos

			_deleteId = findItem _SET_Categories _editName
			deleteItem _SET_Categories _deleteId
			FNrefreshCat()
		)
		else
		(
			createDialog _MLM_DeleteCat
		)
	)

	on edtSepSym changed value do FNmajExampleField()

	on spnNumDig changed value do FNmajExampleField()

	on btnSave pressed do
	(
		_check = FNcheckSettings()
		if _check == true do
		(
			FNsaveSettings()
			destroyDialog _MLM_NewEditCat
			destroyDialog _MLM_DeleteCat
			destroyDialog _MLM_preferences
			fileIn _MLM_mainScript
		)
	)

	on btnCancel pressed do
	(
		destroyDialog _MLM_NewEditCat
		destroyDialog _MLM_DeleteCat
		destroyDialog _MLM_preferences
		fileIn _MLM_mainScript
	)

)

createDialog _MLM_preferences
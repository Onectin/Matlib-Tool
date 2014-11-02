try(DestroyDialog ::nazboobMatExport) catch()

-- On cree les chemins de preferences du script
_prefFile = "W:\\__SYS\\SCRIPTS"
_prefDir = _prefFile + "\\_NZB_matApply"
_prefFile = _prefFile + "\\_NZB_matApply\\_NZB_preferences.nzb"

-- On prepare les valeurs par defaut
_maxRootDir = getDir #scene
_matLibDir = getDir #matlib
_maxRootDir = _maxRootDir + "\\"
_matLibDir = _matLibDir + "\\"
_defValues = #(_maxrootDir,_matLibDir,"false","2")

-- On verifie si le dossier de pref existe, sinon on le cree
_checkPrefPath = ((dotnetclass "System.IO.Directory").exists _prefDir)

if _checkPrefPath == false do makeDir _prefDir
	
_prstDir = _prefDir + "\presets\\"
_checkPrstPath = ((dotnetclass "System.IO.Directory").exists _prstDir)

if _checkPrstPath == false do makeDir _prstDir

-- On charge tous les presets
_presetPathCount = _prstDir.count + 1
_presetStrRequest = _prstDir + "*.nzp"
_presetFileList = getFiles _presetStrRequest
_presetNzbFilesList = #()

for i in _presetFileList do 
(
	_tempValue = substring i _presetPathCount -1
	_tempCount = _tempValue.count - 4
	_tempValue = substring _tempValue 1 _tempCount
	_presetNzbFilesList = append _presetNzbFilesList _tempValue
)
global _megArray = #()

for i in _presetNzbFilesList do
(
	tempArray = #()
	--tempArray = append tempArray i				-- Append 
	_presetPath = _prstDir + i + ".nzp"

	_tempOpenPrst = openFile _presetPath
	while not eof _tempOpenPrst do
	(
		_readPrstLine = readLine _tempOpenPrst
		tempArray = append tempArray _readPrstLine
	)
		
	_megArray = append _megArray tempArray
)



-- On verifie si le fichier de pref existe, sinon on le cree et on le remplit
while  (doesFileExist _prefFile) == false do
(
	_createPrefFile = createFile _prefFile
	flush _createPrefFile
	close _createPrefFile
	
	_tempOpenPref = openFile _prefFile mode:"r+"
	
	for i in _defValues do
	(
		i = i as string
		_insertValue = i + "\n"
		format _insertValue to:_tempOpenPref
	)
	flush _tempOpenPref
	close _tempOpenPref
)

-- On recupere les valeurs du fichier de pref
_readPrefFile = openFile _prefFile
_prefValues = #()

while not eof _readPrefFile do
(
	_readPrefLine = readLine _readPrefFile
	_prefValues = append _prefValues _readPrefLine
)
close _readPrefFile


-- On distribue les valeurs par defaut
global _defDbLibFolder = _prefValues[1] as string
global _defMatLibFolder = _prefValues[2] as string
global _defFrom = _prefValues[4] as integer
if _prefValues[3] == "true" then
(
	global _defAutoclose = true
)
else
(
	global _defAutoclose = false
)

global _fileName = "TEST"

-- FUNCTIONS --
fn FNtoString _array =
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

fn FNexportMat _FNdbPath _FNmatPath _FNfileName=
(
	-- MAIN VAR
	_selection = getCurrentSelection()
	_nonShadedObj = #()
	_file = _FNfileName --"TEST"
	
	-- INFO FILE CONCATENATE
	_info = #()
	_infoFilePath = _FNdbPath
	_infoFileName = _file + ".nzb"
	_infoFile = _infoFilePath + _infoFileName
	
	
	-- MATLIB FILE CONCATENATE
	_matFilePath = _FNmatPath
	_matFileName = _file + ".mat"
	_matFile = _matFilePath + "\\" + _matFileName
	
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
	--_strInfo = _info as string
	_strInfo = _matFile + "\n" + _strInfo
	--print _strInfo

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

rollout nazboobMatExport "NZB - Matlib exporter" width:504 height:400
(
	groupBox 		_grpExport 		"EXPORT" 					pos:[8,8] 		width:488 	height:184
	
	label 			_lblPreset		"Preset:" 					pos:[16,24] 	width:72 	height:16
	dropDownList 	_ddlMatPreset 	"" 							pos:[108,24] 	width:380 	height:21
	
	label 			_lblMatFolder	"Matlib folder:" 			pos:[16,60] 	width:72 	height:16
	editText 		_edtMatPath 	"" 							pos:[104,56] 	width:280 	height:24	bold:true	text:_defMatLibFolder
	button 			_btnMatExp	 	"Browse..." 				pos:[392,56] 	width:72 	height:24
	button 			_btnMatRst	 	"R" 						pos:[471,56] 	width:17 	height:24	tooltip:"Reset"
	
	label 			_lblDbFolder 	"Database folder:" 			pos:[16,92] 	width:88 	height:16
	editText 		_edtDbPath 		"" 							pos:[104,88] 	width:280 	height:24	bold:true	text:_defDbLibFolder
	button 			_btnDbExp	 	"Browse..." 				pos:[392,88] 	width:72 	height:24
	button 			_btnDbRst	 	"R" 						pos:[471,88] 	width:17 	height:24	tooltip:"Reset"
	
	label 			_lblFileName 	"Filename:" 				pos:[16,120] 	width:80 	height:16
	editText 		_edtFileName 	"" 							pos:[104,120] 	width:172 	height:24	
	button 			_btnSwitch	 	"<-" 						pos:[282,120] 	width:30 	height:24
	dropDownList 	_ddlFileName 	"" 							pos:[317,120] 	width:148 	height:21	enabled:false
	button 			_btnNameRfrsh 	"O" 						pos:[471,120] 	width:17 	height:24	tooltip:"Refresh from \"W:\PRODUCTION\_MATLIB\__DB__\\\""
	
	button 			_btnExport 		"EXPORT (from selection)" 	pos:[180,152] 	width:308 	height:32
	radiobuttons 	_rdoExportPreset "" 						pos:[16,160] 	width:100 	height:16	labels:#("From selection","All scene") default:_defFrom
	
	
	groupBox 		_grpImport 		"IMPORT" 					pos:[8,200] 	width:488 	height:158
	radiobuttons 	_rdoDbFile 		"" 							pos:[16,214] 	width:472 	height:16	labels:#("From Database:")
	dropDownList 	_ddlDefDbFolder	"" 							pos:[16,234] 	width:450 	height:40
	button 			_btnNDefRfrsh 	"O" 						pos:[471,232] 	width:17 	height:24	tooltip:"Refresh from \"W:\PRODUCTION\_MATLIB\__DB__\\\""
	
	radiobuttons 	_rdoCusFile 	"" 							pos:[16,262] 	width:472 	height:16	labels:#("Custom file:")	default:0
	label 			_lblCustDblib 	"Data file (.nzb):" 		pos:[16,284] 	width:472 	height:16	enabled:false
	editText 		_edtCustDbPath "" 							pos:[104,280] 	width:280 	height:24	bold:true	enabled:false
	button 			_btnCusDbExp 	"Explore..." 				pos:[392,280] 	width:96 	height:24	enabled:false
	button 			_btnImport	 	"IMPORT" 					pos:[16,318] 	width:368 	height:32
	button 			_btnImportAll 	"IMPORT ALL"				pos:[392,318] 	width:96 	height:32
	
	checkbox 		_chkAutoClose	"Auto-close"				pos:[316,370] 	width:80 	height:24	checked:_defAutoclose
	button 			_btnClose	 	"Close" 					pos:[396,368] 	width:100 	height:24
	button 			_btnPref	 	"Preferences..." 			pos:[8,368] 	width:100 	height:24
	button 			_btnMngDb	 	"Manage DB..." 				pos:[116,368] 	width:100 	height:24
	button 			_btnHelp	 	"?" 						pos:[224,368] 	width:24 	height:24
	
	
	fn FNgetdbList =
	(
		_TMPpath = _defDbLibFolder
		_TMPpathCount = _TMPpath.count + 1
		_TMPstrRequest = _TMPpath + "*.nzb"
		_TMPfileList = getFiles _TMPstrRequest
		_TMPnzbFilesList = #()

		for i in _TMPfileList do 
		(
			_tempValue = substring i _TMPpathCount -1
			_tempCount = _tempValue.count - 4
			_tempValue = substring _tempValue 1 _tempCount
			_TMPnzbFilesList = append _TMPnzbFilesList _tempValue
		)
		_ddlFileName.items = _TMPnzbFilesList
		_ddlDefDbFolder.items = _TMPnzbFilesList
		return _TMPnzbFilesList
	)
	
	fn FNimportMat _FNfile =
	(
		local _file = openFile _FNfile
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
		--print _matDistrib
		
		
		loadMaterialLibrary _matPath
		
		for i in _matDistrib do
		(
				print i[2]
				_sceneObj = $*
				_listObjsToMat = #()
				for obj in _sceneObj do
				(
					_sceneObjName = obj.name
					_breakSceneObj = filterstring _sceneObjName "_"
					_breakTargetObj = filterstring i[2] "_"

					if _breakSceneObj[2] == _breakTargetObj[2] do
					(
						_listObjsToMat = append _listObjsToMat obj
					)

					_sceneObjType = classof obj

					if _sceneObjType == VRayProxy do
					(
						_proxyPath = obj.filename
						_proxyPathBreak = filterstring _proxyPath "\\"
						_proxyNameFull = _proxyPathBreak[_proxyPathBreak.count]
						_proxyNameArr = filterstring _proxyNameFull "."
						_proxyName = _proxyNameArr[1]
						if _proxyName == i[2] do
						(
							_listObjsToMat = append _listObjsToMat obj
						)

					)
				)
				print _listObjsToMat

				for objsMat in _listObjsToMat do
				(
					objsMat.material = currentMaterialLibrary[i[1]]
				)
		)
		return _objNotFound
	)
	
	fn FNobjectNotFound _array =
	(
		_compteur = 0
		_msgText = "The following objets were not found in the scene:\n"
		for i in _array do
		(
			_compteur = _compteur + 1
			_msgText = _msgText + "- " + _array[_compteur] + "\n"
		)
		messageBox _msgText
	)
	
	on _btnHelp pressed do
	(
		messageBox "tut."
	)
	
	on nazboobMatExport open do
	(
		FNgetdbList()
		
		_newItems = #("Custom...")
		_goal = _megArray.count
		_goal = _goal * 4
		_compteur = 1
		_sousCompteur = 1
		--print _megArray
		while _compteur <= _goal do
		(
			_tempPrstArray = _megArray[_sousCompteur]
			_newItems = append _newItems _tempPrstArray[1]
			_compteur = _compteur + 4
			_sousCompteur = _sousCompteur + 1
		)
		_ddlMatPreset.items = _newItems
	)
	
	on _btnPref pressed do
	(
		fileIn "W:\__SYS\SCRIPTS\_NZB_matApplyPrefs.ms"
		Destroydialog nazboobMatExport
	)
	
	on _btnMngDb pressed do
	(
		rollout nazboobManage "Manage Database" width:384 height:240
		(
			listBox _lbxFiles ".nzb database" pos:[8,8] width:368 height:13
			button _btnDelete1 "Delete" pos:[8,208] width:104 height:24
			button _btnClose1 "Close" pos:[272,208] width:104 height:24
		
			fn FNgetdbListMng =
			(
				_TMPpath = _defDbLibFolder
				_TMPpathCount = _TMPpath.count + 1
				_TMPstrRequest = _TMPpath + "*.nzb"
				_TMPfileList = getFiles _TMPstrRequest
				_TMPnzbFilesList = #()

				for i in _TMPfileList do 
				(
					_tempValue = substring i _TMPpathCount -1
					_tempCount = _tempValue.count - 4
					_tempValue = substring _tempValue 1 _tempCount
					_TMPnzbFilesList = append _TMPnzbFilesList _tempValue
				)
				return _TMPnzbFilesList
			)
	
			on nazboobManage open do
			(
				_itemsLbx = FNgetdbListMng()
				_lbxFiles.items = _itemsLbx
			)
		
			on _btnClose1 pressed do
			(
				FNgetdbList()
				Destroydialog nazboobManage
			)
			
			on _btnDelete1 pressed do
			(
				if _lbxFiles.selection != 0 do
				(
				_nzbToDelete = ""
				_matToDelete = ""
				_nzbSelected = _lbxFiles.selected
				_nzbToDelete = _defDbLibFolder + _nzbSelected + ".nzb"
				local _file = openFile _nzbToDelete
				_matToDelete = readLine _file
				close _file
				
				deleteFile _matToDelete
				deleteFile _nzbToDelete
				
				_itemsLbx = FNgetdbListMng()
				_lbxFiles.items = _itemsLbx
				)
			)
		)
		createDialog nazboobManage

	)
	
	on _ddlMatPreset selected _preset do
	(
		if _preset == 1 then
		(
			_edtMatPath.text = _defMatLibFolder
			_edtDbPath.text = _defDbLibFolder
			_edtFileName.text = ""
		)
		else
		(
			_presetCorrection = _preset - 1 
			_currentSelPrst = _megArray[_presetCorrection]
		
			_edtMatPath.text = _currentSelPrst[2]
			_edtDbPath.text = _currentSelPrst[3]
			_edtFileName.text = _currentSelPrst[4]
		)
	
	)
	
	on _btnClose pressed do
	(
		Destroydialog nazboobMatExport
	)

	on _btnImportAll pressed do
	(
		_successImport = false
		for i in _ddlDefDbFolder.items do
		(
			print i
			_importPath = i
			_importPath = _defDbLibFolder + _importPath + ".nzb"
			_return = FNimportMat _importPath
			if _return[1] != undefined do FNobjectNotFound _return
			_successImport = true

		)
		if _chkAutoClose.checked == true and _successImport == true do Destroydialog nazboobMatExport
	)
	
	on _btnImport pressed do
	(
		_successImport = false
		if _rdoDbFile.state == 1 then
		(
			_importPath = _ddlDefDbFolder.selected
			_importPath = _defDbLibFolder + _importPath + ".nzb"
			_return = FNimportMat _importPath
			if _return[1] != undefined do FNobjectNotFound _return
			_successImport = true
		)
		else
		(
			_importPath = _edtCustDbPath.text
			if _importPath == undefined or _importPath == "" then
			(
				
				messageBox "Custom file is empty."
			)
			else
			(
				if doesFileExist _importPath == false then
				(
					messageBox "Custom file is invalid."
				)
				else
				(
					_return = FNimportMat edtCustDbPath.text
					FNobjectNotFound _return
					if _return[1] != undefined do FNobjectNotFound _return
					_successImport = true
				)
			)
			
		)
		if _chkAutoClose.checked == true and _successImport == true do Destroydialog nazboobMatExport
	)
	
	on _rdoExportPreset changed state do 
	(
		if state == 1 then
		(
			_btnExport.text = "EXPORT (from selection)"
		)
		else
		(
			_btnExport.text = "EXPORT (from scene)"
		)
	)
		
	on _btnCusDbExp pressed do
	(
		_temp = getOpenFileName fileName:_defDbLibFolder types:"Nazboob data(*.nzb)"
		if _temp != undefined do _edtCustDbPath.text = _temp
	)
	
	on _rdoDbFile changed state do 
	(
		if state == false then
		(
			_rdoCusFile.state = 1
			_rdoDbFile.state = 0
		)
		else
		(
			_rdoCusFile.state = 0
			_rdoDbFile.state = 1
			
			_ddlDefDbFolder.enabled = true
			_btnNDefRfrsh.enabled = true
			
			_edtCustDbPath.enabled = false
			_btnCusDbExp.enabled = false
			_lblCustDblib.enabled = false
		)
	)
	
	on _rdoCusFile changed state do 
	(
		if state == false then
		(
			_rdoCusFile.state = 0
			_rdoDbFile.state = 1
		)
		else
		(
			_rdoCusFile.state = 1
			_rdoDbFile.state = 0
			
			_ddlDefDbFolder.enabled = false
			_btnNDefRfrsh.enabled = false
			
			_edtCustDbPath.enabled = true
			_btnCusDbExp.enabled = true
			_lblCustDblib.enabled = true
		)
	)
	
	/*on nazboobMatExport open do
	(
		FNgetdbList()
	)*/
	
	on _btnNameRfrsh pressed do
	(
		FNgetdbList()
	)
	
	on _btnNDefRfrsh pressed do
	(
		FNgetdbList()
	)
	
	on _btnMatExp pressed do
	(
		_temp = getSavepath initialDir:_defMatLibFolder
		if _temp != undefined do _edtMatPath.text = _temp + "\\"
	)
	
	on _btnDbExp pressed do
	(
		_temp = getSavepath initialDir:_defDbLibFolder
		if _temp != undefined do _edtDbPath.text = _temp + "\\"
	)
	
	on _btnMatRst pressed do
	(
		_edtMatPath.text = _defMatLibFolder
	)
	
	on _btnDbRst pressed do
	(
		_edtDbPath.text = _defDbLibFolder
	)
	
	on _btnSwitch pressed do
	(
		if _ddlFileName.enabled == false then 
		(
			_ddlFileName.enabled = true
			_edtFileName.enabled = false
			_lblFileName.enabled = false
			_btnSwitch.text = "->"
		)
		else
		(
			_ddlFileName.enabled = false
			_edtFileName.enabled = true
			_lblFileName.enabled = true
			_btnSwitch.text = "<-"
		)
	)
	
	on _btnExport pressed do
	(
		_name = ""
		_success = false
		if _edtFileName.enabled == true then
		(
			_name = _edtFileName.text
		)
		else
		(
			_name = _ddlFileName.text
		)
		
		if _edtDbPath.text == "" or _edtMatPath.text == "" or _name == "" then
		(
			messageBox "At least one of the field is empty."
		)
		else
		(
			--((dotnetclass "System.IO.Directory").exists "D:\\temp")
			_checkDbPath = ((dotnetclass "System.IO.Directory").exists _edtDbPath.text)
			_checkMatPath = ((dotnetclass "System.IO.Directory").exists _edtMatPath.text)
			if _checkMatPath == false then
			(
				messageBox "Matlib folder doesn't exists."
			)
			else
			(
				if _checkDbPath == false then
				(
					messageBox "Database folder doesn't exists."
				)
				else
				(
					_dbLibFolder = _edtDbPath.text
					_matLibFolder = _edtMatPath.text
					_fileName = _name
					if _rdoExportPreset.state == 1 then
					(
						_tmpSel = selection as array
						if _tmpSel.count != 0 then 
						(
							FNexportMat _dbLibFolder _matLibFolder _fileName
							_success = true
						)
						else
						(
							messageBox "Selection is empty"
						)
					)
					else
					(
						select objects
						FNexportMat _dbLibFolder _matLibFolder _fileName
						_success = true
					)
					FNgetdbList()
				)
			)
		)
		if _chkAutoClose.checked == true and _success == true do Destroydialog nazboobMatExport
	)
)

createDialog nazboobMatExport 
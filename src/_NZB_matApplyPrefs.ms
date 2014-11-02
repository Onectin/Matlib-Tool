try(DestroyDialog ::nazboobMatExportPrefs) catch()

-- Default Max Dir
_maxRootDir = getDir #scene
_matLibDir = getDir #matlib
_maxRootDir = _maxRootDir + "\\"
_matLibDir = _matLibDir + "\\"

-- On recupere le fichier de prefs
_prefFile = "W:\\__SYS\\SCRIPTS"
_prefDir = _prefFile + "\\_NZB_matApply"
_prefFile = _prefFile + "\\_NZB_matApply\\_NZB_preferences.nzb"

-- On le scrute
_readPrefFile = openFile _prefFile
_prefValues = #()

while not eof _readPrefFile do
(
	_readPrefLine = readLine _readPrefFile
	_prefValues = append _prefValues _readPrefLine
)
close _readPrefFile



-- On verifie si le dossier de pref existe, sinon on le cree
_checkPrefPath = ((dotnetclass "System.IO.Directory").exists _prefDir)
_tmpPrstDir = _prefDir + "\presets\\"
_checkPrstPath = ((dotnetclass "System.IO.Directory").exists _tmpPrstDir)

if _checkPrefPath == false do makeDir _prefDir
if _checkPrstPath == false do makeDir _tmpPrstDir
	

global _currentFileName =""


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


fn FNcreatePreset prstName prstMatDir prstDbDir prstFileName=
(
	_valueArray = #(prstName,prstMatDir,prstDbDir,prstFileName)
	_prstFile = _prefDir + "\presets\\" + prstFileName + ".nzp"
	
	if  (doesFileExist _prstFile) == false do
	(
		_createPrstFile = createFile _prstFile
		flush _createPrstFile
		close _createPrstFile
	
		_tempOpenPrst = openFile _prstFile mode:"r+"
	
		for i in _valueArray do
		(
			i = i as string
			_insertValue = i + "\n"
			format _insertValue to:_tempOpenPrst
		)
		flush _tempOpenPrst
		close _tempOpenPrst
	)
)


rollout nazboobMatExportPrefs "Preferences" width:368 height:608
(
	groupBox grpDefPaths "Default Paths" pos:[8,8] width:352 height:168
	label lblDefDbPath "Default Database folder:" pos:[16,24] width:336 height:16
	editText edtDefDbPath "" pos:[16,40] width:264 height:24 text:_defDbLibFolder
	button btnDefDbPath "Browse..." pos:[288,40] width:64 height:24
	label lblDefMatPath "Default Matlib folder:" pos:[16,72] width:336 height:16
	editText edtDefMatPath "" pos:[16,88] width:264 height:24 text:_defMatLibFolder
	button btnDefMatPath "Browse..." pos:[288,88] width:64 height:24
	
	groupBox grpDefValues "Default values" pos:[16,120] width:336 height:48
	checkbox chkAutoClose "Auto-close when finished" pos:[24,137] width:192 height:24 checked:_defAutoclose
	radioButtons rdoExportFrom "" pos:[224,131] width:121 height:32 labels:#("Export from selection", "Export from scene") columns:1 default:_defFrom
	
	
	groupBox grpPresets "Presets" pos:[8,184] width:352 height:144
	listBox lbxPresets "" pos:[16,200] width:264 height:9
	button btnPresetAdd "Add" pos:[288,200] width:64 height:24
	button btnPresetDelete "Delete" pos:[288,232] width:64 height:24
	button btnPresetEdit "Edit" pos:[288,264] width:64 height:24
	
	
	groupBox grpEditPreset "Edit Preset" pos:[8,336] width:352 height:176 enabled:false
	label lblPresetName "Preset Name:" pos:[16,352] width:72 height:16 enabled:false
	editText edtPresetName "" pos:[88,352] width:264 height:24 enabled:false
	label lblMatFolder "Matlib folder:" pos:[16,384] width:64 height:16 enabled:false
	editText edtMatFolder "" pos:[88,384] width:192 height:24 enabled:false
	button btnBrowseMat "Browse..." pos:[288,384] width:64 height:24 enabled:false
	editText edtDbFolder "" pos:[88,416] width:192 height:24 enabled:false
	label lblDbFolder "DB folder:" pos:[16,416] width:64 height:16 enabled:false
	button btnBrowseDb "Browse..." pos:[288,416] width:64 height:24 enabled:false
	editText edtFileName "" pos:[88,448] width:264 height:24 enabled:false
	label lblFileName "File Name:" pos:[16,448] width:72 height:16 enabled:false
	button btnPresetSave "Save Preset" pos:[16,480] width:240 height:24 enabled:false
	button btnPresetCancel "Cancel" pos:[264,480] width:88 height:24 enabled:false
	
	
	groupBox grp5 "Preferences file" pos:[8,520] width:352 height:48 enabled:false
	editText edt7 "" pos:[16,536] width:264 height:24 enabled:false
	button btn12 "Browse..." pos:[288,536] width:64 height:24 enabled:false
	
	
	button btnSave "Save" pos:[8,576] width:96 height:24
	button btnSavenClose "Save and close" pos:[112,576] width:144 height:24
	button btnClose "Close" pos:[264,576] width:96 height:24
	
	on btnBrowseMat pressed do
	(
		_temp = getSavepath initialDir:_defMatLibFolder
		if _temp != undefined do edtMatFolder.text = _temp + "\\"
	)
	
	on btnBrowseDb pressed do
	(
		_temp = getSavepath initialDir:_defDbLibFolder
		if _temp != undefined do edtDbFolder.text = _temp + "\\"
	)
	
	fn FNgreyeditPreset _bool =
	(
		grpEditPreset.enabled = _bool
		lblPresetName.enabled = _bool
		edtPresetName.enabled = _bool
		lblMatFolder.enabled = _bool
		edtMatFolder.enabled = _bool
		btnBrowseMat.enabled = _bool
		edtDbFolder.enabled = _bool
		lblDbFolder.enabled = _bool
		btnBrowseDb.enabled = _bool
		edtFileName.enabled = _bool
		lblFileName.enabled = _bool
		btnPresetSave.enabled = _bool
		btnPresetCancel.enabled = _bool
	)
	
	fn FNgreyPresets _bool =
	(
		grpPresets.enabled = _bool
		lbxPresets.enabled = _bool
		btnPresetAdd.enabled = _bool
		btnPresetDelete.enabled = _bool
		btnPresetEdit.enabled = _bool
	)
		
	fn FNsave =
	(
		deleteFile _prefFile
		_tempPrefCreate = createFile _prefFile
		flush _tempPrefCreate
		close _tempPrefCreate
		
		_newDefDbPath = edtDefDbPath.text
		_newDefMatPath = edtDefMatPath.text
		_newDefAutoClose = chkAutoClose.checked as string
		_newDefExportFrom = rdoExportFrom.state as string
		
		
		_defValues = #(_newDefDbPath,_newDefMatPath,_newDefAutoClose,_newDefExportFrom)
		
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
	
	fn FNgetdbList =
	(
		_presetPath = _prefDir + "\presets\\"
		_presetPathCount = _presetPath.count + 1
		_presetStrRequest = _presetPath + "*.nzp"
		_presetFileList = getFiles _presetStrRequest
		_presetNzbFilesList = #()

		for i in _presetFileList do 
		(
			_tempValue = substring i _presetPathCount -1
			_tempCount = _tempValue.count - 4
			_tempValue = substring _tempValue 1 _tempCount
			_presetNzbFilesList = append _presetNzbFilesList _tempValue
		)
		return _presetNzbFilesList
	)
	
	on btnPresetAdd pressed do
	(
		FNgreyeditPreset true
		FNgreyPresets false
		edtMatFolder.text = _defMatLibFolder
		edtDbFolder.text = _defDbLibFolder
		btnPresetSave.text = "Save New Preset"
	)
	
	on btnPresetEdit pressed do
	(
		FNgreyeditPreset true
		FNgreyPresets false
		btnPresetSave.text = "Save Changed Preset"
		
		_prstSelected = lbxPresets.selected
		_prstToEdit = _prefDir + "\\presets\\" + _prstSelected + ".nzp"
		
		_readPrstFile = openFile _prstToEdit
		_prstValues = #()

		while not eof _readPrstFile do
		(
			_readPrstLine = readLine _readPrstFile
			_prstValues = append _prstValues _readPrstLine
		)
		flush _readPrstFile
		close _readPrstFile
		edtPresetName.text = _prstValues[1]
		edtMatFolder.text = _prstValues[2]
		edtDbFolder.text = _prstValues[3]
		edtFileName.text = _prstValues[4]
		
		_currentFileName = edtFileName.text
	)
	
	on btnPresetDelete pressed do
	(
		if lbxPresets.selection != 0 do
		(
			_prstSelected = lbxPresets.selected
			_prstToDel = _prefDir + "\\presets\\" + _prstSelected + ".nzp"
			--print _prstToDel
			deleteFile _prstToDel
		)
		_presetList = FNgetdbList()
		lbxPresets.items = _presetList
	)
	
	
	on btnPresetSave pressed do
	(
		if btnPresetSave.text == "Save New Preset" do
		(
			
			if edtPresetName.text == "" or edtMatFolder.text == "" or edtDbFolder.text == "" or edtFileName.text == "" then
			(
				messageBox "At least one field is empty."
			)
			else
			(
				_checkMatPath = ((dotnetclass "System.IO.Directory").exists edtMatFolder.text)
				_checkDbPath = ((dotnetclass "System.IO.Directory").exists edtDbFolder.text)

				if _checkMatPath == false then
				(
					messageBox "Matlib folder is invalid."
				)
				else
				(
					if _checkMatPath == false then
					(
						messageBox "Database folder is invalid."
					)
					else
					(
						FNcreatePreset edtPresetName.text edtMatFolder.text edtDbFolder.text edtFileName.text
						_presetList = FNgetdbList()
						lbxPresets.items = _presetList
						FNgreyeditPreset false
						FNgreyPresets true
						edtPresetName.text = ""
						edtMatFolder.text = ""
						edtDbFolder.text = ""
						edtFileName.text = ""
						btnPresetSave.text = "Save Preset"
					)
				)
			)
		)
		if btnPresetSave.text == "Save Changed Preset" do
		(
			
			if edtPresetName.text == "" or edtMatFolder.text == "" or edtDbFolder.text == "" or edtFileName.text == "" then
			(
				messageBox "At least one field is empty."
			)
			else
			(
				_checkMatPath = ((dotnetclass "System.IO.Directory").exists edtMatFolder.text)
				_checkDbPath = ((dotnetclass "System.IO.Directory").exists edtDbFolder.text)

				if _checkMatPath == false then
				(
					messageBox "Matlib folder is invalid."
				)
				else
				(
					if _checkMatPath == false then
					(
						messageBox "Database folder is invalid."
					)
					else
					(
				
						if _currentFileName != edtFileName.text then
						(
							_prstToDel = _prefDir + "\presets\\" + _currentFileName + ".nzp"
							deleteFile _prstToDel
							FNcreatePreset edtPresetName.text edtMatFolder.text edtDbFolder.text edtFileName.text
						)
						else
						(
							_prstToDel = _prefDir + "\presets\\" + edtFileName.text + ".nzp"
							deleteFile _prstToDel
							FNcreatePreset edtPresetName.text edtMatFolder.text edtDbFolder.text edtFileName.text
						)
						_presetList = FNgetdbList()
						lbxPresets.items = _presetList
						FNgreyeditPreset false
						FNgreyPresets true
						edtPresetName.text = ""
						edtMatFolder.text = ""
						edtDbFolder.text = ""
						edtFileName.text = ""
						btnPresetSave.text = "Save Preset"
					)
				)
			)
		)
	)
	
	on btnPresetCancel pressed do
	(
		FNgreyeditPreset false
		FNgreyPresets true
		edtPresetName.text = ""
		edtMatFolder.text = ""
		edtDbFolder.text = ""
		edtFileName.text = ""
		btnPresetSave.text = "Save Preset"
	)

	
	on nazboobMatExportPrefs open do
	(
		_presetList = FNgetdbList()
		lbxPresets.items = _presetList
	)
	
	on btnDefDbPath pressed do
	(
		_temp = getSavepath initialDir:_maxRootDir
		if _temp != undefined do edtDefDbPath.text = _temp + "\\"
	)
	
	on btnDefMatPath pressed do
	(
		_temp = getSavepath initialDir:_matLibDir
		if _temp != undefined do edtDefMatPath.text = _temp + "\\"
	)
	
	on btnSave pressed do
	(
		_checkDefMatPath = ((dotnetclass "System.IO.Directory").exists edtDefMatPath.text)
		_checkDefDbPath = ((dotnetclass "System.IO.Directory").exists edtDefDbPath.text)

		if _checkDefMatPath == false then
		(
			messageBox "Default Matlib folder is invalid."
		)
		else
		(
			if _checkDefDbPath == false then
			(
				messageBox "Default Database folder is invalid."
			)
			else
			(
				FNsave()
			)
		)
	)
	
	on btnSavenClose pressed do 
	(
		_checkDefMatPath = ((dotnetclass "System.IO.Directory").exists edtDefMatPath.text)
		_checkDefDbPath = ((dotnetclass "System.IO.Directory").exists edtDefDbPath.text)

		if _checkDefMatPath == false then
		(
			messageBox "Default Matlib folder is invalid."
		)
		else
		(
			if _checkDefDbPath == false then
			(
				messageBox "Default Database folder is invalid."
			)
			else
			(
				FNsave()
				fileIn "W:\__SYS\SCRIPTS\_NZB_matApply.ms"
				Destroydialog nazboobMatExportPrefs
			)
		)
	)
	
	on btnClose pressed do
	(
		fileIn "W:\__SYS\SCRIPTS\_NZB_matApply.ms"
		Destroydialog nazboobMatExportPrefs
	)
)

createDialog nazboobMatExportPrefs 
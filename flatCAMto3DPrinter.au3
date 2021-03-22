#CS
flatCAMto3DPrinter v1.0

by Ahmet Emin Dilben
ahmetemindilben.com.tr

Licensed under MIT LICENSE
#CE

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\logo.ico
#AutoIt3Wrapper_Res_Comment=FlatCAM to 3D Printer - G-CODE Adapter Program
#AutoIt3Wrapper_Res_Description=FlatCAM to 3D Printer - G-CODE Adapter Program
#AutoIt3Wrapper_Res_Fileversion=1000.0.0.7
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_CompanyName=ahmetemindilben.com.tr
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <FileConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region ### INSTALLING DATA FILES ###
Global $dataFileLocation = @MyDocumentsDir & "\flatCAMto3Dprinter"
DirCreate(@MyDocumentsDir & "\flatCAMto3Dprinter")
FileInstall("C:\changeBitGCODE.txt", $dataFileLocation & "\changeBitGCODE.txt")
FileInstall("C:\config.ini", $dataFileLocation & "\config.ini")
FileInstall("C:\deleteLines.txt", $dataFileLocation & "\deleteLines.txt")
FileInstall("C:\endGCODE.txt", $dataFileLocation & "\endGCODE.txt")
FileInstall("C:\english.lng", $dataFileLocation & "\english.lng")
FileInstall("C:\infoGCODE.txt", $dataFileLocation & "\infoGCODE.txt")
FileInstall("C:\logo_EN.jpg", $dataFileLocation & "\logo_EN.jpg")
FileInstall("C:\logo_TR.jpg", $dataFileLocation & "\logo_TR.jpg")
FileInstall("C:\startGCODE.txt", $dataFileLocation & "\startGCODE.txt")
FileInstall("C:\turkish.lng", $dataFileLocation & "\turkish.lng")
#EndRegion

#Region ### COLORS ###
Global $darkModeBkColor = "0x1B262C"
Global $darkModeTxtColor = "0xFFFFFF"
Global $darkModeButtonColor = "0x0F4C75"
Global $whiteModeBkColor = "0xF9F7F7"
Global $whiteModeTxtColor = "0x112D4E"
Global $whiteModeButtonColor = "0xDBE2EF"
#EndRegion ### COLORS ###

#Region ### DATA IMPORTS ###
Func importData()
	;SETTINGS
	Global $configIniLocation = @MyDocumentsDir & "\flatCAMto3Dprinter\config.ini"
	Global $dataLanguage = IniRead($configIniLocation, "SETTINGS", "language", "")
	Global $dataColor = IniRead($configIniLocation, "SETTINGS", "color", "")
	Global $dataExitProgramAfterconversion = IniRead($configIniLocation, "SETTINGS", "exitProgramAfterconversion", "")
	;CUSTOM G-CODE
	Global $dataDeleteLines = FileRead(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt")
	;ISOLATION ROUTING
	Global $dataIsolationConfirm = IniRead($configIniLocation, "ISOLATION", "confirm", "")
	Global $dataIsolationSpeed = IniRead($configIniLocation, "ISOLATION", "speed", "")
	Global $dataIsolationFirstCutZ = IniRead($configIniLocation, "ISOLATION", "firstCutZ", "")
	Global $dataIsolationSecondCutZconfirm = IniRead($configIniLocation, "ISOLATION", "secondCutZConfirm", "")
	Global $dataIsolationSecondCutZ = IniRead($configIniLocation, "ISOLATION", "secondCutZ", "")
	Global $dataIsolationThirdCutZconfirm = IniRead($configIniLocation, "ISOLATION", "thirdCutZConfirm", "")
	Global $dataIsolationThirdCutZ = IniRead($configIniLocation, "ISOLATION", "thirdCutZ", "")
	;DRILLING
	Global $dataDrillingConfirm = IniRead($configIniLocation, "DRILLING", "confirm", "")
	Global $dataDrillingSpeed = IniRead($configIniLocation, "DRILLING", "speed", "")
	Global $dataDrillingCutZ = IniRead($configIniLocation, "DRILLING", "cutZ", "")
	Global $dataDrillingChangeBitConfirm = IniRead($configIniLocation, "DRILLING", "changeBitConfirm", "")
	Global $dataDrillingBitChangePosition = IniRead($configIniLocation, "DRILLING", "bitChangePosition", "")
	;OUTPUT
	If IniRead($configIniLocation, "OUTPUT", "fileDir", "") = "" Then IniWrite($configIniLocation, "OUTPUT", "fileDir", @DesktopDir)
	Global $dataOutputLocation = IniRead($configIniLocation, "OUTPUT", "fileDir", "")
	Global $dataOutputFileName = IniRead($configIniLocation, "OUTPUT", "fileName", "")
EndFunc   ;==>importData
#EndRegion ### DATA IMPORTS ###

importData()

#Region ### LANGUAGE and COLOR MODE CHECK ###
If $dataLanguage = "English" Then
	Global $LANG_EN = IniReadSection(@MyDocumentsDir & "\flatCAMto3Dprinter\english.lng", "STRING")
	_ArrayColInsert($LANG_EN, 2)
	Global $LANG_GUI = $LANG_EN
	Global $logo = @MyDocumentsDir & "\flatCAMto3Dprinter\logo_EN.jpg"
EndIf
If $dataLanguage = "Turkish" Then
	Global $LANG_TR = IniReadSection(@MyDocumentsDir & "\flatCAMto3Dprinter\turkish.lng", "STRING")
	_ArrayColInsert($LANG_TR, 2)
	Global $LANG_GUI = $LANG_TR
	Global $logo = @MyDocumentsDir & "\flatCAMto3Dprinter\logo_TR.jpg"
EndIf


If $dataColor = "white" Then
	Global $bkColor = $whiteModeBkColor
	Global $txtColor = $whiteModeTxtColor
	Global $buttonColor = $whiteModeButtonColor
EndIf
If $dataColor = "dark" Then
	Global $bkColor = $darkModeBkColor
	Global $txtColor = $darkModeTxtColor
	Global $buttonColor = $darkModeButtonColor
EndIf
#EndRegion ### LANGUAGE and COLOR MODE CHECK ###

;Creating TEMP dir
If Not FileExists(@TempDir & '\flatCAMto3DprinterTEMP') Then DirCreate(@TempDir & '\flatCAMto3DprinterTEMP')
Global $tempDirectory = @TempDir & '\flatCAMto3DprinterTEMP'

;------------------------------------------------------ GUI's ------------------------------------------------------;
#Region ### START Koda GUI section ### Form=\main.kxf
Global $mainGUI = GUICreate($LANG_GUI[1][1], 611, 406, -1, -1)
$MenuItem1 = GUICtrlCreateMenu($LANG_GUI[2][1])
Global $MenuItemSettings = GUICtrlCreateMenuItem($LANG_GUI[3][1], $MenuItem1)
$MenuItem2 = GUICtrlCreateMenu($LANG_GUI[4][1])
Global $MenuItemHelp = GUICtrlCreateMenuItem($LANG_GUI[5][1], $MenuItem2)
$MenuItem3 = GUICtrlCreateMenu($LANG_GUI[6][1])
Global $MenuItemAbout = GUICtrlCreateMenuItem($LANG_GUI[7][1], $MenuItem3)
GUISetBkColor($bkColor)
GUICtrlCreatePic($logo, 152, 22, 305, 147)
GUICtrlCreateLabel("v1.0  |  ahmetemindilben.com.tr", 232, 170, 151, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateGroup("", 56, 208, 497, 70)
GUICtrlCreateLabel($LANG_GUI[8][1], 64, 224, 234, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $ButtonIsolationBrowse = GUICtrlCreateButton($LANG_GUI[9][1], 464, 224, 81, 20)
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
Global $EditIsolationFile = GUICtrlCreateEdit("", 296, 224, 161, 20, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_WANTRETURN))
GUICtrlSetData(-1, $LANG_GUI[10][1])
GUICtrlCreateLabel($LANG_GUI[11][1], 64, 248, 171, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $EditDrillingFile = GUICtrlCreateEdit("", 296, 248, 161, 20, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_WANTRETURN))
GUICtrlSetData(-1, $LANG_GUI[10][1])
Global $ButtonDrillingBrowse = GUICtrlCreateButton($LANG_GUI[9][1], 464, 248, 81, 20)
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $ButtonOptions = GUICtrlCreateButton($LANG_GUI[12][1], 125, 304, 160, 41)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
Global $ButtonConvert = GUICtrlCreateButton($LANG_GUI[13][1], 325, 304, 160, 41)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=\settings.kxf
Global $settingsGUI = GUICreate($LANG_GUI[14][1], 501, 364, -1, -1)
GUISetBkColor($bkColor)
GUICtrlCreateLabel($LANG_GUI[15][1], 196, 25, 107, 28)
GUICtrlSetFont(-1, 16, 800, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateGroup("", 69, 80, 361, 45)
GUICtrlCreateLabel($LANG_GUI[16][1], 157, 96, 78, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $ComboLanguageSelect = GUICtrlCreateCombo("English", 245, 96, 97, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Turkish")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 69, 136, 361, 45)
GUICtrlCreateLabel($LANG_GUI[17][1], 149, 152, 90, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $ComboColorSelect = GUICtrlCreateCombo("Dark", 245, 152, 97, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "White")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateLabel($LANG_GUI[18][1], 90, 208, 270, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $CheckboxExitAftConv = GUICtrlCreateCheckbox("", 344, 208, 25, 17)
GUICtrlCreateGroup("", 69, 192, 361, 45)
Global $ButtonSettingsSave = GUICtrlCreateButton($LANG_GUI[19][1], 197, 264, 105, 36)
GUICtrlSetFont(-1, 12, 800, 0, "arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
GUICtrlCreateLabel($LANG_GUI[20][1], 130, 312, 270, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=\about.kxf
$aboutGUI = GUICreate($LANG_GUI[21][1], 400, 312, -1, -1)
GUISetBkColor($bkColor)
GUICtrlCreatePic($logo, 48, 22, 305, 147)
GUICtrlSetTip(-1, "47")
GUICtrlCreateLabel("v1.0  |  ahmetemindilben.com.tr", 125, 170, 151, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateLabel("Licensed under MIT License", 117, 194, 166, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateLabel("Contact: me@ahmetemindilben.com.tr", 88, 226, 227, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateLabel($LANG_GUI[22][1], 22, 266, 355, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=\options.kxf
Global $optionsGUI = GUICreate($LANG_GUI[23][1], 831, 516, -1, -1)
GUISetBkColor($bkColor)
GUICtrlCreateLabel($LANG_GUI[24][1], 333, 17, 163, 28)
GUICtrlSetFont(-1, 16, 800, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateGroup("", 48, 50, 185, 313)
GUICtrlCreateLabel($LANG_GUI[25][1], 56, 66, 140, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $EditLinesDeleted = GUICtrlCreateEdit("", 56, 92, 169, 257)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 445, 50, 345, 44)
GUICtrlCreateLabel($LANG_GUI[26][1], 461, 66, 260, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $CheckboxIsolationRConfirm = GUICtrlCreateCheckbox("", 400, 66, 25, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 96, 537, 45)
GUICtrlCreateLabel($LANG_GUI[27][1], 285, 112, 365, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $InputIsolationSpeed = GUICtrlCreateInput("", 725, 65, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 50, 177, 44)
GUICtrlCreateLabel($LANG_GUI[30][1], 269, 66, 127, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $InputIsolationFirstCutZ = GUICtrlCreateInput("", 661, 111, 49, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 136, 537, 45)
GUICtrlCreateLabel($LANG_GUI[28][1], 285, 152, 388, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $CheckboxIsolationSecondCutConfirm = GUICtrlCreateCheckbox("", 677, 153, 25, 17)
Global $InputIsolationSecondCutZ = GUICtrlCreateInput("", 701, 151, 49, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 176, 537, 44)
GUICtrlCreateLabel($LANG_GUI[29][1], 293, 192, 369, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $CheckboxIsolationThirdCutConfirm = GUICtrlCreateCheckbox("", 669, 193, 25, 17)
Global $InputIsolationThirdCutZ = GUICtrlCreateInput("", 693, 191, 49, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 240, 113, 44)
GUICtrlCreateLabel($LANG_GUI[31][1], 269, 256, 61, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $CheckboxDrillingConfirm = GUICtrlCreateCheckbox("", 336, 256, 25, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 445, 240, 345, 44)
GUICtrlCreateLabel($LANG_GUI[32][1], 493, 256, 194, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $InputDrillingSpeed = GUICtrlCreateInput("", 693, 255, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 288, 537, 45)
GUICtrlCreateLabel($LANG_GUI[33][1], 357, 304, 205, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $InputDrillingHeight = GUICtrlCreateInput("", 581, 303, 49, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 336, 233, 44)
GUICtrlCreateLabel($LANG_GUI[34][1], 261, 352, 194, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $CheckboxChangeBitConfirm = GUICtrlCreateCheckbox("", 464, 352, 20, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 496, 336, 295, 44)
GUICtrlCreateLabel($LANG_GUI[35][1], 504, 352, 190, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $InputBitChangePos = GUICtrlCreateInput("", 696, 351, 81, 21)
GUICtrlCreateGroup("", 253, 392, 297, 45)
GUICtrlCreateLabel($LANG_GUI[36][1], 261, 408, 129, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $InputOutputFileName = GUICtrlCreateInput("", 392, 408, 105, 21)
GUICtrlCreateLabel(".gcode", 501, 408, 43, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 253, 432, 377, 45)
GUICtrlCreateLabel($LANG_GUI[37][1], 261, 448, 150, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $EditOutputFileDir = GUICtrlCreateEdit("", 416, 448, 145, 20, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_WANTRETURN))
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $ButtonOutputDirBrowse = GUICtrlCreateButton($LANG_GUI[9][1], 567, 448, 57, 20)
GUICtrlSetFont(-1, 8, 400, 0, "arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $ButtonOptionsSave = GUICtrlCreateButton($LANG_GUI[19][1], 661, 411, 129, 52)
GUICtrlSetFont(-1, 12, 800, 0, "arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
GUICtrlCreateLabel($LANG_GUI[38][1], 96, 392, 87, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
GUICtrlSetColor(-1, $txtColor)
Global $ButtonOptionsGithubRepo = GUICtrlCreateButton($LANG_GUI[39][1], 77, 419, 129, 36)
GUICtrlSetFont(-1, 9, 800, 0, "arial")
GUICtrlSetColor(-1, $txtColor)
GUICtrlSetBkColor(-1, $buttonColor)
GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###
;-----------------------------------------------------; GUI's ;-----------------------------------------------------;


While 1
	$aMsg = GUIGetMsg(1)
	Switch $aMsg[1]
		Case $mainGUI
			Switch $aMsg[0]
				Case $GUI_EVENT_CLOSE
					Exit
				Case $MenuItemSettings
					GUICtrlSetData($ComboLanguageSelect, $dataLanguage)
					GUICtrlSetData($ComboColorSelect, $dataColor)
					GUICtrlSetState($CheckboxExitAftConv, $dataExitProgramAfterconversion)
					GUISetState(@SW_HIDE, $mainGUI)
					GUISetState(@SW_SHOW, $settingsGUI)
				Case $MenuItemAbout
					GUISetState(@SW_HIDE, $mainGUI)
					GUISetState(@SW_SHOW, $aboutGUI)
				Case $ButtonIsolationBrowse
					$isolationFileBrowseMessage = $LANG_GUI[40][1]
					Global $selectedIsolationFile = FileOpenDialog($isolationFileBrowseMessage, @WindowsDir & "\", "G-CODE (*.gcode*)", $FD_FILEMUSTEXIST)
					If @error Then MsgBox(48, "Error", $LANG_GUI[41][1])
					GUICtrlSetData($EditIsolationFile, $selectedIsolationFile)
				Case $ButtonDrillingBrowse
					$drillingFileBrowseMessage = $LANG_GUI[42][1]
					Global $selectedDrillingFile = FileOpenDialog($drillingFileBrowseMessage, @WindowsDir & "\", "G-CODE (*.gcode*)", $FD_FILEMUSTEXIST)
					GUICtrlSetData($EditDrillingFile, $selectedDrillingFile)
				Case $ButtonOptions
					GUICtrlSetData($EditLinesDeleted, $dataDeleteLines)
					GUICtrlSetState($CheckboxIsolationRConfirm, $dataIsolationConfirm)
					GUICtrlSetData($InputIsolationSpeed, $dataIsolationSpeed)
					GUICtrlSetData($InputIsolationFirstCutZ, $dataIsolationFirstCutZ)
					GUICtrlSetState($CheckboxIsolationSecondCutConfirm, $dataIsolationSecondCutZconfirm)
					GUICtrlSetData($InputIsolationSecondCutZ, $dataIsolationSecondCutZ)
					GUICtrlSetState($CheckboxIsolationThirdCutConfirm, $dataIsolationThirdCutZconfirm)
					GUICtrlSetData($InputIsolationThirdCutZ, $dataIsolationThirdCutZ)
					GUICtrlSetState($CheckboxDrillingConfirm, $dataDrillingConfirm)
					GUICtrlSetData($InputDrillingSpeed, $dataDrillingSpeed)
					GUICtrlSetData($InputDrillingHeight, $dataDrillingCutZ)
					GUICtrlSetState($CheckboxChangeBitConfirm, $dataDrillingChangeBitConfirm)
					GUICtrlSetData($InputBitChangePos, $dataDrillingBitChangePosition)
					GUICtrlSetData($EditOutputFileDir, $dataOutputLocation)
					GUICtrlSetData($InputOutputFileName, $dataOutputFileName)
					GUISetState(@SW_HIDE, $mainGUI)
					GUISetState(@SW_SHOW, $optionsGUI)
				Case $ButtonConvert
					editAndMoveFiles()
					mergeFiles()
			EndSwitch
		Case $settingsGUI
			Switch $aMsg[0]
				Case $GUI_EVENT_CLOSE
					GUISetState(@SW_HIDE, $settingsGUI)
					GUISetState(@SW_SHOW, $mainGUI)
				Case $ButtonSettingsSave
					saveSettings()
			EndSwitch
		Case $aboutGUI
			Switch $aMsg[0]
				Case $GUI_EVENT_CLOSE
					GUISetState(@SW_HIDE, $aboutGUI)
					GUISetState(@SW_SHOW, $mainGUI)
			EndSwitch
		Case $optionsGUI
			Switch $aMsg[0]
				Case $GUI_EVENT_CLOSE
					GUISetState(@SW_HIDE, $optionsGUI)
					GUISetState(@SW_SHOW, $mainGUI)
				Case $ButtonOutputDirBrowse
					Local Const $outputDirBrowseMessage = $LANG_GUI[43][1]
					Global $selectedOutputDir = FileSelectFolder($outputDirBrowseMessage, "")
					GUICtrlSetData($EditOutputFileDir, $selectedOutputDir)
				Case $ButtonOptionsSave
					saveOptions()
				Case $ButtonOptionsGithubRepo
					ShellExecute("https://github.com/ahmetemindilben/turn3DprinterIntoCNC")
			EndSwitch
	EndSwitch
WEnd

Func saveOptions() ;Saving options to config.ini file
	FileDelete(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt")
	FileWrite(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", GUICtrlRead($EditLinesDeleted))
	IniWrite($configIniLocation, "ISOLATION", "confirm", GUICtrlRead($CheckboxIsolationRConfirm))
	IniWrite($configIniLocation, "ISOLATION", "speed", GUICtrlRead($InputIsolationSpeed))
	IniWrite($configIniLocation, "ISOLATION", "firstCutZ", GUICtrlRead($InputIsolationFirstCutZ))
	IniWrite($configIniLocation, "ISOLATION", "secondCutZConfirm", GUICtrlRead($CheckboxIsolationSecondCutConfirm))
	IniWrite($configIniLocation, "ISOLATION", "secondCutZ", GUICtrlRead($InputIsolationSecondCutZ))
	IniWrite($configIniLocation, "ISOLATION", "thirdCutZConfirm", GUICtrlRead($CheckboxIsolationThirdCutConfirm))
	IniWrite($configIniLocation, "ISOLATION", "thirdCutZ", GUICtrlRead($InputIsolationThirdCutZ))
	IniWrite($configIniLocation, "DRILLING", "confirm", GUICtrlRead($CheckboxDrillingConfirm))
	IniWrite($configIniLocation, "DRILLING", "speed", GUICtrlRead($InputDrillingSpeed))
	IniWrite($configIniLocation, "DRILLING", "cutZ", GUICtrlRead($InputDrillingHeight))
	IniWrite($configIniLocation, "DRILLING", "changeBitConfirm", GUICtrlRead($CheckboxChangeBitConfirm))
	IniWrite($configIniLocation, "DRILLING", "bitChangePosition", GUICtrlRead($InputBitChangePos))
	IniWrite($configIniLocation, "OUTPUT", "fileDir", GUICtrlRead($EditOutputFileDir))
	IniWrite($configIniLocation, "OUTPUT", "fileName", GUICtrlRead($InputOutputFileName))
	importData() ; for refreshing existing data in GUI
	MsgBox(64, $LANG_GUI[45][1], $LANG_GUI[44][1])
EndFunc   ;==>saveOptions

Func saveSettings() ;Saving settings to config.ini file
	IniWrite($configIniLocation, "SETTINGS", "language", GUICtrlRead($ComboLanguageSelect))
	IniWrite($configIniLocation, "SETTINGS", "color", GUICtrlRead($ComboColorSelect))
	IniWrite($configIniLocation, "SETTINGS", "exitProgramAfterconversion", GUICtrlRead($CheckboxExitAftConv))
	MsgBox(64, $LANG_GUI[46][1], $LANG_GUI[47][1])
EndFunc   ;==>saveSettings

Func editAndMoveFiles()
	FileDelete($tempDirectory) ;Cleaning temp dir
	FileCopy(@MyDocumentsDir & "\flatCAMto3Dprinter\infoGCODE.txt", $tempDirectory & "\0.txt", $FC_OVERWRITE) ;Copying top part of GCODE to User Documents Dir > flatCAMto3Dprinter
	_FileWriteToLine(@MyDocumentsDir & "\flatCAMto3Dprinter\infoGCODE.txt", 2, ";Generated Time: " & @HOUR & ":" & @MIN & ":" & @SEC & " - " & @MDAY & "/" & @MON & "/" & @YEAR, True) ;Adding generation time
	FileCopy(@MyDocumentsDir & "\flatCAMto3Dprinter\startGCODE.txt", $tempDirectory & "\1.txt", $FC_OVERWRITE) ; Copying custom start gcode file
	If $dataIsolationConfirm = "1" Then
		FileWrite($tempDirectory & "\2.txt", "G1 F" & $dataIsolationSpeed)
		FileCopy($selectedIsolationFile, $tempDirectory & "\3.txt", $FC_OVERWRITE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", "Z-1", "Z" & $dataIsolationFirstCutZ, $STR_NOCASESENSE) ;Adjusting CUT Z Height
		;I know I could do this part with an array loop. But code is already spaghetti enough, not worth the hassle.
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 1), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 2), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 3), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 4), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 5), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 6), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 7), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 8), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 9), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 10), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 11), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 12), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 13), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 14), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 15), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 16), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 17), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 18), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 19), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\3.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 20), "", $STR_NOCASESENSE)
		If $dataIsolationSecondCutZconfirm = "1" Then FileCopy($tempDirectory & "\3.txt", $tempDirectory & "\4.txt", $FC_OVERWRITE)
		If $dataIsolationSecondCutZconfirm = "1" Then _ReplaceStringInFile($tempDirectory & "\4.txt", "Z-1", "Z" & $dataIsolationSecondCutZ, $STR_NOCASESENSE)
		If $dataIsolationThirdCutZconfirm = "1" Then FileCopy($tempDirectory & "\3.txt", $tempDirectory & "\5.txt", $FC_OVERWRITE)
		If $dataIsolationThirdCutZconfirm = "1" Then _ReplaceStringInFile($tempDirectory & "\5.txt", "Z-1", "Z" & $dataIsolationThirdCutZ, $STR_NOCASESENSE)
	EndIf
	If $dataDrillingConfirm = "1" Then
		FileWrite($tempDirectory & "\7.txt", "G1 F" & $dataDrillingSpeed)
		FileCopy($selectedDrillingFile, $tempDirectory & "\8.txt", $FC_OVERWRITE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", "Z-1", "Z" & $dataDrillingCutZ, $STR_NOCASESENSE) ;Adjusting drill CUT Z Height
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 1), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 2), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 3), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 4), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 5), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 6), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 7), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 8), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 9), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 10), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 11), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 12), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 13), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 14), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 15), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 16), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 17), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 18), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 19), "", $STR_NOCASESENSE)
		_ReplaceStringInFile($tempDirectory & "\8.txt", FileReadLine(@MyDocumentsDir & "\flatCAMto3Dprinter\deleteLines.txt", 20), "", $STR_NOCASESENSE)
		If $dataDrillingChangeBitConfirm = "1" Then FileCopy(@MyDocumentsDir & "\flatCAMto3Dprinter\changeBitGCODE.txt", $tempDirectory & "\6.txt", $FC_OVERWRITE)
		If $dataDrillingChangeBitConfirm = "1" Then _FileWriteToLine(@MyDocumentsDir & "\flatCAMto3Dprinter\changeBitGCODE.txt", 3, $dataDrillingBitChangePosition, 1)
	EndIf
	FileCopy(@MyDocumentsDir & "\flatCAMto3Dprinter\endGCODE.txt", $tempDirectory & "\9.txt", $FC_OVERWRITE)
EndFunc   ;==>editAndMoveFiles

Func mergeFiles() ;Merging all txt part files into one gcode file
	$resultFile = $dataOutputLocation & "\" & $dataOutputFileName & ".gcode"
	If FileExists($resultFile) Then FileDelete($resultFile)
	$file = FileOpen($resultFile, 1)

	$FileList = _FileListToArray($tempDirectory, "*.txt")
	For $i = 1 To $FileList[0]
		$data = FileRead($tempDirectory & "\" & $FileList[$i])
		FileWrite($file, " " & @CRLF)
		FileWrite($file, $data & @CRLF)
	Next
	FileClose($file)
	MsgBox(64, $LANG_GUI[48][1], $LANG_GUI[49][1])
	ShellExecute($dataOutputLocation)
	If $dataExitProgramAfterconversion = "1" Then Exit
EndFunc   ;==>mergeFiles


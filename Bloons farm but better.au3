#include <misc.au3>
#include <Constants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <GUIConstantsEx.au3>
#include <GuiButton.au3>
#include <GDIPlus.au3>
#include <ScreenCapture.au3>
#include <File.au3>

HotKeySet("^!q", "Quit")
;HotKeySet("^!a", "handle_collection")

If True Then ;constants
	Opt("GUICloseOnESC", 0)
	Opt("SendKeyDownDelay", 20)
	Global $bx
	Global $by
	Global $towersarr[100][9]
	$picsize = 1
	$cutoff = 0.95

	Enum $INPUT, $WAITCLICK, $STRATEGIZING, $kEYLOGGING, $WAITLCLICK, $FOLLOWSTRAT, $LASTSTATE
	Enum $NAME, $SX, $SY, $READINGS
	Enum $NAMEneveruhsdaasdg, $CONTROLS, $CONTROLLIST
	Enum $PLACE, $UPGRADE, $SELL, $STARTROUND, $FULLSEND, $CHANGETARG, $REMOVEOB,$QUEUEABILITY
	Enum $TX, $TY, $TTYPE, $TSOLD, $TTOP, $TMID, $TBOT, $TTARG, $TCTRL
	$metastatcount = $LASTSTATE
	$pictureroot = ($picsize * 2 + 1)
	Global $metastates[$metastatcount][5][50]
	$metastates[$INPUT][$NAME][0] = "Waiting for input"
	$metastates[$WAITCLICK][$NAME][0] = "Waiting for right click"
	$metastates[$STRATEGIZING][$NAME][0] = "Strategizing"
	$metastates[$kEYLOGGING][$NAME][0] = "Waiting for keystroke"
	$metastates[$WAITLCLICK][$NAME][0] = "Waiting for left click"
	Global $states[200][5][$pictureroot * $pictureroot]
	global $targidtostring[4]
	$targidtostring[0]="first"
	$targidtostring[1]="last"
	$targidtostring[2]="close"
	$targidtostring[3]="strong"
	$states[0][$NAME][0] = "No idea"

	$littlex=107
	$littley=240
	$littlewidth=490-$littlex
	$littleheight=420-$littley
	$bigwidth=650
	$bigheight=510
	$micros=0
	$microat=0
	global $timer=0
	global $micro[40][2]
EndIf

If True Then ;initialize GUI and other variables
	global $StrArray
	global $stratname
	$fileheader = "bloonsdata"
	$defs = FileOpen($fileheader & "/def.txt", $FO_READ)
	$x=int(FileReadLine($defs))
	$y=int(FileReadLine($defs))
	$s=int(FileReadLine($defs))
	$towers = 0
	$guu = GUICreate("Bloons Farm", 500, 500, $x,$y)
	$stateGUI = GUICtrlCreateLabel("", 40, 40, 120, 20)
	$stalhkjsdhjkl = GUICtrlCreateLabel("State", 0, 40, 39, 20)
	$metastateGUI = GUICtrlCreateLabel("", 80, 20, 120, 20)
	$mstalhkjsdhjkl = GUICtrlCreateLabel("Meta State", 0, 20, 60, 20)
	;$INPUT screen
	$addstate = GUICtrlCreateButton("create state of name:", 40, 60)
	;$checkstate = GUICtrlCreateButton("check how close this screen is to that state", 40, 90)
	$checkallstates = GUICtrlCreateButton("blind check", 40, 90)
	$strategizebutton = GUICtrlCreateButton("strategize", 40, 150)

	;$simscore = GUICtrlCreateLabel("", 270, 90, 150, 20)



	$winlabel = GUICtrlCreateLabel("wins: 0", 10, 430, 200, 20)
	$resetlabel = GUICtrlCreateLabel("resets: 0", 10, 445, 200, 20)
	$collection_label = GUICtrlCreateLabel("collected: 0", 10, 460, 200, 20)
	$hotkeys = GUICtrlCreateLabel("QUIT: ctrl+alt+q", 0, 0)
	$runtime = GUICtrlCreateLabel("runtime: 0 min", 233, 400,2000)
	$initmoney = GUICtrlCreatebutton("", 80, 430,150,50,$BS_BITMAP)
	$currentmoney = GUICtrlCreatebutton("", 280, 430,150,50,$BS_BITMAP)


	$in = GUICtrlCreateInput("", 170, 63, 100, 20)
	$teststratin = GUICtrlCreateInput("", 130, 183, 100, 20)
	$teststratbutton = GUICtrlCreateButton("run strategy", 40, 180)
	$clipcoords = GUICtrlCreateButton("copy coords", 300, 10)
	$linkerin = GUICtrlCreateInput("", 130, 213, 100, 20)
	$farmbutton = GUICtrlCreateButton("farm", 40, 210)
	$newlinkerbutton = GUICtrlCreateButton("new linker", 260, 210)
	$appendlinkerbutton = GUICtrlCreateButton("write location (make sure state is correct)", 130, 240)

	$delable = GUICtrlCreateLabel("global delay", 330, 60)
	$delable2 = GUICtrlCreateLabel("(increase if tool inputs to bloons are not being recieved)", 240, 150)
	$delayin = GUICtrlCreateInput(String($s), 310, 90, 100, 20)
	$setdelaybutton = GUICtrlCreateButton("update", 340, 120)

	;strategize screen

	$abilityy=190
	$stratbuttonx=10
	$abilityx=$stratbuttonx
	$backbutton = GUICtrlCreateButton("back", $stratbuttonx, 60)
	$setfile = GUICtrlCreateButton("pick file to append to", $stratbuttonx, 90)
	$sfilein = GUICtrlCreateInput("", 160, 93, 100, 20)
	$dividerlabel2 = GUICtrlCreateLabel("----------------", $stratbuttonx, 115)
	$droptower = GUICtrlCreateButton("drop a tower", $stratbuttonx, 130)
	$unlockfile = GUICtrlCreateButton("unlock", 290, 90)
	;$readfile = GUICtrlCreateButton("read towers in", 350, 90)
	$towercounter = GUICtrlCreateLabel("Towers: ", 160, 120,100)
	$towershow = GUICtrlCreateButton("show me this tower", 160, 140)
	$useabilitybutton = GUICtrlCreateButton("use ability", $abilityx, $abilityy)
	$useabilitykeyin = GUICtrlCreateInput("", 57+$abilityx, $abilityy,20,25)
	$afterlabel = GUICtrlCreatelabel("after", 80+$abilityx, $abilityy+5)
	$useabilitydelayin = GUICtrlCreateInput("", 102+$abilityx, $abilityy,40,25)
	$secondslabel = GUICtrlCreatelabel("s", 145+$abilityx, $abilityy+5)
	$towermid = GUICtrlCreateButton("upgrade middle path", 280, 150)
	$towertop = GUICtrlCreateButton("upgrade top path", 280, 120)
	$towerbot = GUICtrlCreateButton("upgrade bottom path", 280, 180)
	$towersell = GUICtrlCreateButton("sell", 280, 210, 100)
	$targetleft = GUICtrlCreateButton("<", 170, 200)
	$targetlabel = GUICtrlCreateLabel("first", 200, 207,30)
	$targetright = GUICtrlCreateButton(">", 235, 200)
	$towerpick = GUICtrlCreateInput("", 160, 173, 100, 20)
	$upgradelabel = GUICtrlCreateLabel("This many times", 400, 130)
	$upgradetimesin = GUICtrlCreateInput("1", 392, 153, 100, 20)
	$toplabel = GUICtrlCreateLabel("0", 265, 123)
	$midlabel = GUICtrlCreateLabel("0", 265, 153)
	$botlabel = GUICtrlCreateLabel("0", 265, 183)
	$inround = GUICtrlCreateLabel("between rounds", 200, 20)
	$round_label = GUICtrlCreateInput("6", 300, 20)
	$removebutton = GUICtrlCreateButton("remove obstacle", $stratbuttonx, 160)
	$dividerlabel = GUICtrlCreateLabel("----------------", $stratbuttonx, 225)
	$sendroundbutton = GUICtrlCreateButton("send round", $stratbuttonx, 240)
	$retrylastbutton = GUICtrlCreateButton("retry", $stratbuttonx, 300)
	$sendallbutton = GUICtrlCreateButton("send all", $stratbuttonx, 370)
	$map = GUICtrlCreatebutton("", $littlex, $littley,$littlewidth,$littleheight,$BS_BITMAP)
	GUICtrlSetState($map, $GUI_DISABLE)

	;FOLLOWSTRAT screen
	$cancelstratbutton = GUICtrlCreateButton("CANCEL", 100, 100)



	$stratfile = -1
	$towerview = True
	$playing=False
	global $linker[100][3]
	$linkers=0
	$farming=false
	$farm_start_timer=Null



	WinSetOnTop($guu, "", $WINDOWS_ONTOP)
	GUISetState(@SW_SHOW, $guu)

	If True Then ; set up state switching

		If True Then ;set all to have no controls
			$i = 0
			While ($i < $LASTSTATE)
				$metastates[$i][$CONTROLS][0] = 0

				$i += 1
			WEnd
		EndIf

		If True Then ;$INPUT screen
			$this = $INPUT
			$metastates[$this][$CONTROLS][0] = 17
			$metastates[$this][$CONTROLLIST][0] = $addstate
			$metastates[$this][$CONTROLLIST][1] = $in
			;$metastates[$this][$CONTROLLIST][2] = $checkstate
			$metastates[$this][$CONTROLLIST][3] = $checkallstates
			$metastates[$this][$CONTROLLIST][4] = $strategizebutton
			;$metastates[$this][$CONTROLLIST][5] = $simscore
			$metastates[$this][$CONTROLLIST][6] = $teststratbutton
			$metastates[$this][$CONTROLLIST][7] = $teststratin
			$metastates[$this][$CONTROLLIST][8] = $clipcoords
			$metastates[$this][$CONTROLLIST][9] = $farmbutton
			$metastates[$this][$CONTROLLIST][10] = $linkerin
			$metastates[$this][$CONTROLLIST][11] = $newlinkerbutton
			$metastates[$this][$CONTROLLIST][12] = $appendlinkerbutton
			$metastates[$this][$CONTROLLIST][13] = $delayin
			$metastates[$this][$CONTROLLIST][14] = $delable
			$metastates[$this][$CONTROLLIST][15] = $setdelaybutton
			$metastates[$this][$CONTROLLIST][16] = $delable2

			$i = 0
			While ($i < $metastates[$this][$CONTROLS][0])
				GUICtrlSetState($metastates[$this][$CONTROLLIST][$i], $GUI_HIDE)

				$i += 1
			WEnd
		EndIf

		If True Then ;strategize screen
			$this = $STRATEGIZING
			$metastates[$this][$CONTROLS][0] = 35
 			$metastates[$this][$CONTROLLIST][0] = $backbutton
			$metastates[$this][$CONTROLLIST][1] = $droptower
			$metastates[$this][$CONTROLLIST][2] = $setfile
			$metastates[$this][$CONTROLLIST][3] = $sfilein
			$metastates[$this][$CONTROLLIST][4] = $unlockfile
			$metastates[$this][$CONTROLLIST][5] = $towershow
			$metastates[$this][$CONTROLLIST][6] = $towerpick
			;$metastates[$this][$CONTROLLIST][7] = $readfile
			$metastates[$this][$CONTROLLIST][8] = $towercounter
			$metastates[$this][$CONTROLLIST][9] = $towertop
			$metastates[$this][$CONTROLLIST][10] = $towermid
			$metastates[$this][$CONTROLLIST][11] = $towerbot
			$metastates[$this][$CONTROLLIST][12] = $towersell
			$metastates[$this][$CONTROLLIST][13] = $upgradetimesin
			$metastates[$this][$CONTROLLIST][14] = $upgradelabel
			$metastates[$this][$CONTROLLIST][15] = $toplabel
			$metastates[$this][$CONTROLLIST][16] = $midlabel
			$metastates[$this][$CONTROLLIST][17] = $botlabel
			$metastates[$this][$CONTROLLIST][18] = $inround
			$metastates[$this][$CONTROLLIST][19] = $sendallbutton
			$metastates[$this][$CONTROLLIST][20] = $sendroundbutton
			$metastates[$this][$CONTROLLIST][21] = $targetleft
			$metastates[$this][$CONTROLLIST][22] = $targetright
			$metastates[$this][$CONTROLLIST][23] = $targetlabel
			$metastates[$this][$CONTROLLIST][24] = $removebutton
			$metastates[$this][$CONTROLLIST][25] = $dividerlabel
			$metastates[$this][$CONTROLLIST][26] = $dividerlabel2
			$metastates[$this][$CONTROLLIST][27] = $map
			$metastates[$this][$CONTROLLIST][28] = $retrylastbutton
			$metastates[$this][$CONTROLLIST][29] = $useabilitybutton
			$metastates[$this][$CONTROLLIST][30] = $useabilitydelayin
			$metastates[$this][$CONTROLLIST][31] = $useabilitykeyin
			$metastates[$this][$CONTROLLIST][32] = $secondslabel
			$metastates[$this][$CONTROLLIST][33] = $afterlabel
			$metastates[$this][$CONTROLLIST][34] = $round_label


			$i = 0
			While ($i < $metastates[$this][$CONTROLS][0])
				GUICtrlSetState($metastates[$this][$CONTROLLIST][$i], $GUI_HIDE)

				$i += 1
			WEnd
		EndIf

		If True Then ;$FOLLOWSTRAT screen
			$this = $FOLLOWSTRAT
			$metastates[$this][$CONTROLS][0] = 1
			$metastates[$this][$CONTROLLIST][0] = $cancelstratbutton

			$i = 0
			While ($i < $metastates[$this][$CONTROLS][0])
				GUICtrlSetState($metastates[$this][$CONTROLLIST][$i], $GUI_HIDE)

				$i += 1
			WEnd
		EndIf

	EndIf
	;WinSetState($guu, "", @SW_hide)
	$writeout=""
	$hand = WinGetHandle("BloonsTD6")
	if @error <> 0 Then
		$writeout="bloons is not running"
		Quit()
	EndIf

	$state = ""
	$metastate = ""
	change_state(0)
	change_meta_state($INPUT)
	If True Then ;read in states from files
		$statecount = 1
		$search = FileFindFirstFile($fileheader & "/states/*")
		;ConsoleWrite("did search" & @CRLF)
		While True

			$FileName = FileFindNextFile($search)
			If @error Then ExitLoop
			;ConsoleWrite("loop, fname is " & String($FileName) & @CRLF)
			$fhand = FileOpen($fileheader & "/states/" & $FileName)
			$namein = StringSplit($FileName, ".")[1]
			$states[$statecount][$NAME][0] = $namein
			$states[$statecount][$SX][0] = FileReadLine($fhand)
			$states[$statecount][$SY][0] = FileReadLine($fhand)
			$num = 0
			$i = -$picsize
			While ($i < $picsize + 1)
				$j = -$picsize
				While ($j < $picsize + 1)

					$states[$statecount][$READINGS][$num] = Int(FileReadLine($fhand))
					$num += 1

					$j += 1
				WEnd
				$i += 1
			WEnd

			FileClose($fhand)
			;ConsoleWrite("added a state named " & $states[$statecount][$NAME][0] & @CRLF)
			$statecount += 1
		WEnd
		FileClose($search)
		ConsoleWrite("total states: " & $statecount & @CRLF)
	EndIf

	GUICtrlSetData($teststratin ,FileReadLine($defs))
	GUICtrlSetData($linkerin ,FileReadLine($defs))


	FileClose($defs)

	$betweenrnd=state_name_to_id("between")
	$fastgame=state_name_to_id("fast")
	$victoryworld=state_name_to_id("victory")
	$victory2=state_name_to_id("victory2")
	$defeat=state_name_to_id("defeat")
	$restart=state_name_to_id("restart")
	$menu=state_name_to_id("main menu")
	$continue=state_name_to_id("continue")
	$pop=state_name_to_id("in game popup")
	$claim=state_name_to_id("claim")
	$collect=state_name_to_id("collect")
	$waiting=false
	$finished=false
	$wins=0
	$resets=0
	$collections=0
	$premousex=0
	$premousey=0
	$prex=0
	$prey=0
EndIf

While 1 ;main loop
	Sleep($s)
	$bx = (WinGetPos($hand)[0])
	$by = (WinGetPos($hand)[1])
	$idMsg = GUIGetMsg()
	Switch $metastate
		Case $INPUT
			Switch $idMsg
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $addstate
					change_meta_state($WAITCLICK)
					await_mouse_click($fileheader & "/states/" & GUICtrlRead($in) & ".txt")
					change_meta_state($INPUT)
				Case $checkallstates
					blind_state_check(True)
				Case $strategizebutton
					wipe_towers()

					change_meta_state($STRATEGIZING)
					set_invisible()
					flip_r()
					flip_file_validity($setfile)
					flip_file_validity($sfilein)
				case $teststratbutton
					$stratfile = FileOpen($fileheader & "/strats/" & GUICtrlRead($teststratin) & ".txt", $FO_READ)
					If ($stratfile <> -1) Then
						$waiting=False
						$finished=False
						wipe_towers()
						change_meta_state($FOLLOWSTRAT)
					EndIf
				case $clipcoords
					change_meta_state($WAITCLICK)
					await_mouse_click(0,1)
					change_meta_state($INPUT)
				case $newlinkerbutton
					$linkerfile = FileOpen($fileheader & "/linkers/" & GUICtrlRead($linkerin) & ".txt", $FO_APPEND)
					$linkers=0

				case $appendlinkerbutton
					if $linkerfile <> -1 Then
						change_meta_state($WAITCLICK)
						await_mouse_click(0,2)
						change_meta_state($INPUT)
					EndIf

				case $farmbutton
					$stratfile = FileOpen($fileheader & "/strats/" & GUICtrlRead($teststratin) & ".txt", $FO_READ)
					$linkerfile = FileOpen($fileheader & "/linkers/" & GUICtrlRead($linkerin) & ".txt", $FO_READ)
					if $linkerfile <> -1 and $stratfile <> -1 Then
						ConsoleWrite("starting farming" & @CRLF)
						$fname=$fileheader & "/tempdata/init.bmp"
						snap($fname)
						_GUICtrlButton_SetImage($initmoney,$fname)
						$farm_start_timer=TimerInit()
						read_linker($linkerfile)
						$farming=true
						$wins=0
						$resets=0
					EndIf
				case $setdelaybutton
					$s=int(GUICtrlRead($delayin))




			EndSwitch
			if $farming Then

				click_play()
				follow_linker()
				While state_similarity($betweenrnd) < $cutoff
					sleep($s)
				WEnd

				sleep($s*10)
				$a=state_similarity($pop)

				if $a > $cutoff Then
					MouseMove($bx + 324, $by + 355, 0)
					MouseClick($MOUSE_CLICK_LEFT)
				EndIf
				sleep($s*50)
				ConsoleWrite("switching to gaming" & @CRLF)
				change_meta_state($FOLLOWSTRAT)
			EndIf
			;blind_state_check(False)
		Case $STRATEGIZING
			Switch $idMsg
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $backbutton
					change_meta_state($INPUT)
					flip_r()
					flip_file_validity($setfile)
					flip_file_validity($sfilein)
					wipe_towers(true)
				Case $droptower
					GUICtrlSetState($towershow,$GUI_FOCUS)
					change_meta_state($kEYLOGGING)
					$key = await_key_press()
					If ($key <> -1) Then
						$string = Chr($key)
						MouseMove($bx + 200, $by + 200, 0)
						Sleep(100)
						WinActivate($hand)
						Sleep(100)
						Send($string)
						change_meta_state($WAITLCLICK)
						await_tower_drop($key)
					EndIf
					change_meta_state($STRATEGIZING)
					set_invisible()
					most_recent_tower_to_ctrl()
				Case $setfile
					$stratname=$fileheader & "/strats/" & GUICtrlRead($sfilein) & ".txt"
					lock()
				Case $unlockfile
					unlock()
				Case $towershow
					store_mouse()
					$tow = Int(GUICtrlRead($towerpick))
					select_tower($tow)
					restore_mouse()
				Case $towersell
					store_mouse()
					sell_tower($tow)
					GUICtrlDelete($towersarr[$tow][$TCTRL])
					$towersarr[$tow][$TCTRL]=0
					restore_mouse()
				case $towertop
					store_mouse()
					upgrade_tower($tow,0,Int(GUICtrlRead($upgradetimesin)))
					restore_mouse()
				case $towermid
					store_mouse()
					upgrade_tower($tow,1,Int(GUICtrlRead($upgradetimesin)))
					restore_mouse()
				case $towerbot
					store_mouse()
					upgrade_tower($tow,2,Int(GUICtrlRead($upgradetimesin)))
					restore_mouse()
				case $sendroundbutton
					send_round()
				case $sendallbutton
					FileWriteLine($stratfile, String($FULLSEND))
					FileWriteLine($stratfile, "-------------------END OF FILE-----------------------")
					FileClose($stratfile)
					$stratfile = -1
					flip_r()
				case $targetleft
					store_mouse()
					change_target($tow,1,True)
					restore_mouse()
				case $targetright
					store_mouse()
					change_target($tow,0,True)
					restore_mouse()
				case $removebutton
					store_mouse()
					change_meta_state($WAITCLICK)
					await_mouse_click(-1,3)
					MouseClick($MOUSE_CLICK_LEFT)
					FileWriteLine($stratfile,String($REMOVEOB))
					FileWriteLine($stratfile,String($prex))
					FileWriteLine($stratfile,String($prey))
					Sleep(300)
					await_mouse_click(-1,3)
					MouseClick($MOUSE_CLICK_LEFT)
					FileWriteLine($stratfile,String($prex))
					FileWriteLine($stratfile,String($prey))
					change_meta_state($STRATEGIZING)
					restore_mouse()
				case $retrylastbutton
					retry_last_round()
				case $useabilitybutton
					$ability=GUICtrlRead($useabilitykeyin)
					$delay=Number(GUICtrlRead($useabilitydelayin))
					push_micro($ability,$delay,false)
			EndSwitch
			if True Then ; check if tower input refers to a real tower
				$tow = (GUICtrlRead($towerpick))
				If ($tow == "") Then
					$tow = -1
				EndIf

				$tow = Int($tow)
				;ConsoleWrite($tow & @CRLF)
				If ($tow >= 0 And $tow < $towers And $towersarr[$tow][3]) Then
					ensure_upgrade_labels()
					If (Not $towerview) Then
						set_visible()
					EndIf
				Else
					If ($towerview) Then
						set_invisible()
					EndIf
				EndIf
			EndIf
			if $playing Then ; check for making it out of round
				do_micro()
				if state_similarity($betweenrnd) > $cutoff Then
					GUICtrlSetData($inround,"between rounds")
					$playing=False
					reset_round()
				EndIf

			EndIf

		Case $FOLLOWSTRAT
			Switch $idMsg
				case $cancelstratbutton
					change_meta_state($INPUT)
					FileClose($stratfile)
			EndSwitch
			follow_strat()
	EndSwitch


WEnd

Func reset_round()
	$micros=0
EndFunc

Func push_micro($ability,$delay,$nowrite=True)
	$micro[$micros][0]=$ability
	$micro[$micros][1]=$delay
	$micros+=1
	if $nowrite then Return
	FileWriteLine($stratfile, String($QUEUEABILITY))
	FileWriteLine($stratfile, String($ability))
	FileWriteLine($stratfile, String($delay))
EndFunc

Func do_micro()
	if($microat<$micros) Then
		if(TimerDiff($timer)/1000>=$micro[$microat][1]) Then
			WinActivate($hand)
			Send($micro[$microat][0])
			$microat+=1
		EndIf

	EndIf
EndFunc

Func lock()
	$stratfile = FileOpen($stratname, $FO_APPEND)
	;ConsoleWrite("tried to open file, " & $stratfile & @CRLF)
	If ($stratfile <> -1) Then
		flip_r()
		wipe_towers()
		read_file()
	EndIf
EndFunc

Func unlock()
	FileClose($stratfile)
	$stratfile = -1
	flip_r()
	wipe_towers(true)
EndFunc

Func retry_last_round()
	WinActivate($hand)
	sleep($s)
	MouseMove($bx + 463, $by + 386,0)
	MouseClick($MOUSE_CLICK_LEFT)
	sleep($s)
	unlock() ;
	DeleteString($stratname)
	$old=GUICtrlRead($round_label)
	GUICtrlSetData($round_label,$old-1)
	lock()
EndFunc

Func DeleteString($sFileName)
    Local $FileHwnd

    If Not FileExists($sFileName) Then
        MsgBox(16, "Error", "File not exist")
        Exit
    EndIf

    _FileReadToArray($sFileName, $StrArray)
	while (UBound($StrArray)>1 and StringLeft($StrArray[UBound($StrArray)-1],5)<>"-----")
		_ArrayDelete($StrArray, UBound($StrArray)-1) ; delete any data up to the first ------------------------------------------
	WEnd
    _ArrayDelete($StrArray, UBound($StrArray)-1) ; delete first ------------------------------------------
    while (UBound($StrArray)>1 and StringLeft($StrArray[UBound($StrArray)-1],5)<>"-----")

		_ArrayDelete($StrArray, UBound($StrArray)-1) ; delete any data up to the next ------------------------------------------
	WEnd
    $FileHwnd = FileOpen($sFileName, 2)

    For $i = 1 To UBound($StrArray) -1
        FileWriteLine($FileHwnd, $StrArray[$i])
    Next

    FileClose($FileHwnd)
EndFunc

Func most_recent_tower_to_ctrl()
	$x=$towersarr[$towers-1][$TX]
	$y=$towersarr[$towers-1][$TY]
	$tarr=little_from_big($x,$y)
	$num=$towers-1
	$wid=7
	if($num>9) Then
		$wid=14
	EndIf
	$towersarr[$num][$TCTRL] = GUICtrlCreateLabel(String($num), $tarr[0], $tarr[1],$wid,14)
EndFunc

Func little_from_big($x,$y)
	$x/=$bigwidth
	$y/=$bigheight
	$x*=$littlewidth
	$y*=$littleheight
	$x+=$littlex
	$y+=$littley
	dim $ret[2]
	$ret[0]=$x-5
	$ret[1]=$y-5
	Return($ret)
EndFunc

Func remove_obstacle($x,$y,$x2,$y2)
	MouseMove($bx + 636, $by + 75, 0)
	Sleep($s)
	MouseClick($MOUSE_CLICK_LEFT)
	Sleep($s)
	MouseMove($bx + $x, $by + $y, 0)
	Sleep($s)
	MouseClick($MOUSE_CLICK_LEFT)
	Sleep(300)
	MouseMove($bx + $x2, $by + $y2, 0)
	Sleep($s)
	MouseClick($MOUSE_CLICK_LEFT)
EndFunc

Func change_target($tow, $alt=0,$write=False)
	select_tower($tow)
	Sleep($s)
	changeTargeting($alt)
	$pre=$towersarr[$tow][$TTARG]
	$post=targnumber($pre,$alt)
	$towersarr[$tow][$TTARG]=$post

	If $write Then
		GUICtrlSetData($targetlabel,$targidtostring[$post])
		FileWriteLine($stratfile, String($CHANGETARG))
		FileWriteLine($stratfile, String($tow))
		FileWriteLine($stratfile, String($alt))
	EndIf
EndFunc

func targnumber($pre,$alt)
	$mod=1
	if $alt Then
		$mod=-1
	EndIf

	$post=$pre+$mod
	if $post<0 Then
		$post=3
	ElseIf $post>3 Then
		$post=0
	EndIf
	Return($post)
EndFunc

Func store_mouse()
	$why=MouseGetPos()
	$premousex=$why[0]
	$premousey=$why[1]
EndFunc

func restore_mouse()
	MouseMove($premousex,$premousey,0)
EndFunc

Func changeTargeting($alt)
   if($alt) Then
	  send("{CTRLDOWN}")
	  sleep(10)
   endif
	  send("{TAB}")
	  sleep($s)
   if($alt) Then
	  send("{CTRLUP}")
	  sleep(10)
   endif
EndFunc

Func snap($fname,$x=508,$y=41,$x2=606,$y2=66)
   $boi=_ScreenCapture_Capture("", $bx + $x, $by + $y, $bx + $x2, $by + $y2)
   _ScreenCapture_SaveImage ( $fname, $boi)
EndFunc

Func read_linker($linkerfile)
	$linkers=0
	FileSetPos($linkerfile, 0, 0)
	While True
		$awaitstate = FileReadLine($linkerfile)
		$x = FileReadLine($linkerfile)
		$y = FileReadLine($linkerfile)
		;ConsoleWrite(@error == -1 & @CRLF)
		if @error == -1 Then
			Return
		EndIf
		;ConsoleWrite("state of name " & $awaitstate  & @CRLF)
		$linker[$linkers][0]=state_name_to_id($awaitstate)
		;ConsoleWrite("written in as " & $linker[$linkers][0]  & @CRLF)
		$linker[$linkers][1]=$x
		$linker[$linkers][2]=$y
		$linkers+=1
	WEnd

EndFunc

Func follow_linker()
	$linkerat=0
	while $linkerat<$linkers
		While state_similarity($linker[$linkerat][0]) < $cutoff
			sleep($s)
			If state_similarity($collect) > $cutoff Then
				MouseMove($bx + 347, $by + 332,0)
				Sleep($s)
				MouseClick($MOUSE_CLICK_LEFT)
				handle_collection()
				sleep($s*10)
			EndIf
		WEnd
		MouseMove($bx + $linker[$linkerat][1], $by + $linker[$linkerat][2], 0)
		Sleep($s)
		MouseClick($MOUSE_CLICK_LEFT)
		$linkerat+=1
		Sleep($s*3)
	WEnd
	sleep(500)


EndFunc


Func handle_collection()
	$i=28
	$end=634
	while($i<$end)
		MouseMove($bx + $i, $by + 270,0)
		Sleep($s)
		MouseClick($MOUSE_CLICK_LEFT)
		MouseClick($MOUSE_CLICK_LEFT)
		MouseClick($MOUSE_CLICK_LEFT)
		$i+=3
	WEnd
	sleep($s*10)
	While state_similarity($menu) < $cutoff
		Send("{ESC}")
		sleep($s*50)
	WEnd
	Sleep($s*20)
	$collections+=1
	guictrlsetdata($collection_label,"collected: " & $collections)
EndFunc

Func click_play()
	WinActivate($hand)
	sleep($s)
	$click=False
	$collection_moment=False
	While state_similarity($menu) < $cutoff
		if state_similarity($claim) > $cutoff Then
			MouseMove($bx + 326, $by + 402,0)
			Sleep($s)
			MouseClick($MOUSE_CLICK_LEFT)
			$click=True
			MouseMove($bx + 367, $by + 72, 0)
		EndIf
		If state_similarity($collect) > $cutoff Then
			MouseMove($bx + 347, $by + 332,0)
			Sleep($s)
			MouseClick($MOUSE_CLICK_LEFT)
			$collection_moment=True
		EndIf
		if $collection_moment Then
			handle_collection()
		EndIf
		if $click Then
			MouseClick($MOUSE_CLICK_LEFT)
		EndIf
		sleep($s)
	WEnd
	$fname=$fileheader & "/tempdata/current.bmp"
	snap($fname)
	_GUICtrlButton_SetImage($currentmoney,$fname)
	$str="runtime: " & (TimerDiff($farm_start_timer)/(1000*60))
	$str=StringSplit($str,".")[1] & " min"
	GUICtrlSetData($runtime,$str)
	MouseMove($bx + 277, $by + 455, 0)
	Sleep($s)
	MouseClick($MOUSE_CLICK_LEFT)
EndFunc

Func follow_strat()
	if not $waiting then
		if $finished Then
			send_round(False)
			$waiting=True
		Else
			$instruct = (FileReadLine($stratfile))
			if($instruct=="") Then
				ConsoleWrite("oh no" & @CRLF)
				Return
			EndIf
			$instruct=int($instruct)
			Switch $instruct
				case $PLACE
					$t = FileReadLine($stratfile)
					$x = FileReadLine($stratfile)
					$y = FileReadLine($stratfile)
					;ConsoleWrite("buying " & $t & " at " & String($x) & "," & String($y) & @CRLF)
					buyTowerHandler(Chr($t),$x,$y)
					add_tower($x,$y,$t)
				case $UPGRADE
					$t=FileReadLine($stratfile)
					$path=FileReadLine($stratfile)
					$times=FileReadLine($stratfile)
					upgrade_tower($t,$path,$times,false)
				case $SELL
					$t=FileReadLine($stratfile)
					sell_tower($t)
				case $CHANGETARG
					$t=FileReadLine($stratfile)
					$alt=FileReadLine($stratfile)
					change_target($t,$alt,False)
				case $REMOVEOB
					$x=int(FileReadLine($stratfile))
					$y=int(FileReadLine($stratfile))
					$x2=int(FileReadLine($stratfile))
					$y2=int(FileReadLine($stratfile))
					remove_obstacle($x,$y,$x2,$y2)
				case $QUEUEABILITY
					$abilitykey=FileReadLine($stratfile)
					$delay=number(FileReadLine($stratfile))
					push_micro($abilitykey,$delay)
				case $STARTROUND
					FileReadLine($stratfile)
					send_round(False)
					$waiting=True
				Case $FULLSEND
					send_round(False)
					$waiting=True
					$finished=True
			EndSwitch
		EndIf
	Else
		do_micro()
		MouseMove($bx + 636, $by + 75, 0)
		Sleep($s)
		MouseClick($MOUSE_CLICK_LEFT)
		if state_similarity($betweenrnd) > $cutoff Then
			$waiting=false
			reset_round()
		ElseIf state_similarity($defeat) > $cutoff Then

			if $resets<20 Then
				sleep(1000)
				$fname=$fileheader & "/tempdata/loss" & String($resets) & ".bmp"
				snap($fname,171,189,487,376)
			EndIf

			WinActivate($hand)
			MouseMove($bx + 324, $by + 374, 0)
			Sleep($s*5)

			MouseClick($MOUSE_CLICK_LEFT)
			While state_similarity($restart) < $cutoff
				sleep($s)
				$a=state_similarity($continue)
				;ConsoleWrite($a & @CRLF)
				if $a > $cutoff Then
					MouseMove($bx + 281, $by + 378, 0)
					MouseClick($MOUSE_CLICK_LEFT)
				EndIf
			WEnd
			MouseMove($bx + 396, $by + 347, 0)

			Sleep($s)
			MouseClick($MOUSE_CLICK_LEFT)
			wipe_towers()
			$waiting=False
			$finished=False
			FileSetPos($stratfile,0,$FILE_BEGIN)
			$resets+=1
			guictrlsetdata($resetlabel,"resets: " & $resets)

		ElseIf state_similarity($victoryworld) > $cutoff Then
			MouseMove($bx + 327, $by + 422, 0)
			Sleep($s)
			MouseClick($MOUSE_CLICK_LEFT)
			While state_similarity($victory2) < $cutoff
				sleep($s)
			WEnd
			MouseMove($bx + 233, $by + 396, 0)
			Sleep($s)
			MouseClick($MOUSE_CLICK_LEFT)
			change_meta_state($INPUT)
			wipe_towers()
			$waiting=False
			$finished=False
			$wins+=1
			guictrlsetdata($winlabel,"wins: " & $wins) ;850
			FileSetPos($stratfile,0,$FILE_BEGIN)
		EndIf


	EndIf

EndFunc

Func send_round($write=True)
	$microat=0
	$timer=TimerInit()
	WinActivate($hand)
	sleep($s)
	Send("{SPACE}")
	sleep($s)
	$loops=0
	While state_similarity($fastgame) < $cutoff
		Send("{SPACE}")
		sleep($s*20)
		if $loops>5 Then
			ExitLoop
		EndIf
		$loops+=1
	WEnd
	$playing=True
	GUICtrlSetData($inround,"mid round")
	If $write Then
		$old=GUICtrlRead($round_label)
		FileWriteLine($stratfile, String($STARTROUND))
		FileWriteLine($stratfile, "------------------------------------------" & " send round " & $old)
		GUICtrlSetData($round_label,$old+1)
	EndIf
EndFunc

Func ensure_upgrade_labels()
	$dis=GUICtrlRead($toplabel)
	$des=String($towersarr[$tow][$TTOP])
	if($dis<>$des) Then
		GUICtrlSetData($toplabel,$des)
	EndIf
	$dis=GUICtrlRead($midlabel)
	$des=String($towersarr[$tow][$TMID])
	if($dis<>$des) Then
		GUICtrlSetData($midlabel,$des)
	EndIf
	$dis=GUICtrlRead($botlabel)
	$des=String($towersarr[$tow][$TBOT])
	if($dis<>$des) Then
		GUICtrlSetData($botlabel,$des)
	EndIf
	$dis=GUICtrlRead($targetlabel)
	$des=$targidtostring[$towersarr[$tow][$TTARG]]
	if($dis<>$des) Then
		GUICtrlSetData($targetlabel,$des)
	EndIf
EndFunc

Func file_upgrade($tow,$path,$times=1)
	FileWriteLine($stratfile, String($UPGRADE))
	FileWriteLine($stratfile, String($tow))
	FileWriteLine($stratfile, String($path))
	FileWriteLine($stratfile, String($times))
EndFunc

Func upgrade_tower($tow,$path,$times=1,$write=True)
	select_tower($tow)
	Sleep($s)
	upgrade_selected($tow,$path,$times)
	if $write Then
		file_upgrade($tow,$path,$times)
	EndIf


EndFunc   ;==>upgrade_tower

Func state_name_to_id($namearg)
	$iter=0
	while $iter < $statecount
		if($states[$iter][$NAME][0]==$namearg) Then
			return($iter)
		EndIf
		$iter+=1
	WEnd
	Return(-1)
EndFunc

Func upgrade_selected($tow,$path,$n)
	if($n==0) Then
		return
	EndIf
	switch $path
		Case 0
			send(",")
			$towersarr[$tow][$TTOP]+=1
		case 1
			send(".")
			$towersarr[$tow][$TMID]+=1
		case 2
			send("/")
			$towersarr[$tow][$TBOT]+=1
	EndSwitch
	sleep($s)
	upgrade_selected($tow,$path,$n-1)
EndFunc

Func sell_tower($tow,$write=True)
	select_tower($tow)
	Sleep($s)
	Send("{BACKSPACE}")
	$towersarr[$tow][3] = False
	if $write then
		FileWriteLine($stratfile, String($SELL))
		FileWriteLine($stratfile, String($tow))
	EndIf
EndFunc   ;==>sell_tower

Func select_tower($tow)
	If $tow >= 0 And $tow < $towers And $towersarr[$tow][3] Then
		WinActivate($hand)
		MouseMove($bx + 636, $by + 75, 0)
		Sleep($s)
		MouseClick($MOUSE_CLICK_LEFT)
		Sleep($s*10)
		MouseMove($bx + $towersarr[$tow][0], $by + $towersarr[$tow][1], 0)
		Sleep($s)
		MouseClick($MOUSE_CLICK_LEFT)
		Sleep($s)
	EndIf
EndFunc   ;==>select_tower

Func add_tower($x, $y, $t)
	$towersarr[$towers][$TTYPE] = $t
	$towersarr[$towers][$TX] = $x
	$towersarr[$towers][$TY] = $y
	$towersarr[$towers][$TSOLD] = True
	$towersarr[$towers][$TTOP] = 0
	$towersarr[$towers][$TMID] = 0
	$towersarr[$towers][$TBOT] = 0
	$towersarr[$towers][$TTARG] = 0
	$towersarr[$towers][$TCTRL] = 0
	$towers += 1
	GUICtrlSetData($towercounter, "Towers: " & $towers)
EndFunc   ;==>add_tower

Func wipe_towers($hard=False)
	if $hard Then
		$it=0
		While $it<$towers
			if($towersarr[$it][$TCTRL] <> 0) Then
				GUICtrlDelete($towersarr[$it][$TCTRL])
				$towersarr[$it][$TCTRL]=0
			EndIf


			$it+=1
		WEnd
	EndIf
	$towers = 0
	GUICtrlSetData($towercounter, "Towers: " & $towers)
EndFunc   ;==>wipe_towers

Func read_file()
	ConsoleWrite("read invoked" & @CRLF)
	FileSetPos($stratfile, 0, 0)
	While True

		$instruct = (FileReadLine($stratfile))
		;ConsoleWrite($instruct)
		If ($instruct == $PLACE) Then

			$t = FileReadLine($stratfile)
			$x = FileReadLine($stratfile)
			$y = FileReadLine($stratfile)
			ConsoleWrite("found a tower to read in, it has type " & $t & ", and is placed at (" & $x & ", " & $y & ")" & @CRLF)
			add_tower($x, $y, $t)
			most_recent_tower_to_ctrl()
		ElseIf $instruct == $SELL Then

			$t = FileReadLine($stratfile)
			ConsoleWrite("tower " & $t & " was sold though" & @CRLF)
			$towersarr[$t][3] = False
			GUICtrlDelete($towersarr[$t][$TCTRL])
			$towersarr[$t][$TCTRL]=0
		ElseIf $instruct == $UPGRADE Then
			$t=FileReadLine($stratfile)
			$path=FileReadLine($stratfile)
			$times=FileReadLine($stratfile)
			ConsoleWrite("tower " & $t & " had its path " & $path & " upgraded " & $times & " time(s)" & @CRLF)
			$towersarr[$t][$path+4]+=$times
		ElseIf $instruct == $STARTROUND Then
			$line_with_round=FileReadLine($stratfile)
			$one_space=StringRight($line_with_round,5)
			$round_num=StringSplit($one_space," ")[2]
			GUICtrlSetData($round_label,$round_num+1)
		ElseIf $instruct == $CHANGETARG Then
			$tow=FileReadLine($stratfile)
			$alt=int(FileReadLine($stratfile))
			$pre=$towersarr[$tow][$TTARG]
			$post=targnumber($pre,$alt)
			$towersarr[$tow][$TTARG]=$post
		ElseIf $instruct == $REMOVEOB Then
			$x=int(FileReadLine($stratfile))
			$y=int(FileReadLine($stratfile))
			$x2=int(FileReadLine($stratfile))
			$y2=int(FileReadLine($stratfile))
		ElseIf $instruct == $FULLSEND Then
			ConsoleWrite("this file is already completed"  & @CRLF)
			FileClose($stratfile)
			$stratfile = -1
			flip_r()
			Return
		ElseIf $instruct==$QUEUEABILITY Then
			$x2=int(FileReadLine($stratfile))
			$y2=int(FileReadLine($stratfile))
		EndIf
		If @error == -1 Or @error == 1 Then
			ConsoleWrite("towers is now " & $towers & @CRLF)
			Return
		EndIf


	WEnd
EndFunc   ;==>read_file

Func set_visible()
	$towerview = True
	GUICtrlSetState($towertop, $GUI_SHOW)
	GUICtrlSetState($towermid, $GUI_SHOW)
	GUICtrlSetState($towerbot, $GUI_SHOW)
	GUICtrlSetState($towersell, $GUI_SHOW)
	GUICtrlSetState($upgradetimesin, $GUI_SHOW)
	GUICtrlSetState($upgradelabel, $GUI_SHOW)
	GUICtrlSetState($toplabel, $GUI_SHOW)
	GUICtrlSetState($midlabel, $GUI_SHOW)
	GUICtrlSetState($botlabel, $GUI_SHOW)
	GUICtrlSetState($targetlabel, $GUI_SHOW)
	GUICtrlSetState($targetleft, $GUI_SHOW)
	GUICtrlSetState($targetright, $GUI_SHOW)
	GUICtrlSetState($towershow, $GUI_SHOW)
EndFunc   ;==>set_visible

Func set_invisible()
	$towerview = False
	GUICtrlSetState($towertop, $GUI_HIDE)
	GUICtrlSetState($towermid, $GUI_HIDE)
	GUICtrlSetState($towerbot, $GUI_HIDE)
	GUICtrlSetState($towersell, $GUI_HIDE)
	GUICtrlSetState($upgradetimesin, $GUI_HIDE)
	GUICtrlSetState($upgradelabel, $GUI_HIDE)
	GUICtrlSetState($toplabel, $GUI_HIDE)
	GUICtrlSetState($midlabel, $GUI_HIDE)
	GUICtrlSetState($botlabel, $GUI_HIDE)
	GUICtrlSetState($targetlabel, $GUI_HIDE)
	GUICtrlSetState($targetleft, $GUI_HIDE)
	GUICtrlSetState($targetright, $GUI_HIDE)
	GUICtrlSetState($towershow, $GUI_HIDE)
EndFunc   ;==>set_invisible

Func flip_r()
	flip_file_validity($sfilein)
	flip_file_validity($droptower)
	flip_file_validity($unlockfile)
	flip_file_validity($towershow)
	flip_file_validity($towerpick)
	;flip_file_validity($readfile)
	flip_file_validity($setfile)
	flip_file_validity($towertop)
	flip_file_validity($towermid)
	flip_file_validity($towerbot)
	flip_file_validity($towersell)
	flip_file_validity($upgradetimesin)
	flip_file_validity($upgradelabel)
	flip_file_validity($toplabel)
	flip_file_validity($midlabel)
	flip_file_validity($botlabel)
	flip_file_validity($sendallbutton)
	flip_file_validity($sendroundbutton)
	flip_file_validity($removebutton)
	flip_file_validity($useabilitybutton)
	flip_file_validity($useabilitydelayin)
	flip_file_validity($useabilitykeyin)
	flip_file_validity($retrylastbutton)
EndFunc   ;==>flip_r

Func flip_file_validity($ctrl)
	$a = GUICtrlGetState($ctrl)
	;ConsoleWrite($a & @CRLF)
	If (BitAND($a, $GUI_DISABLE)) Then
		GUICtrlSetState($ctrl, $GUI_ENABLE)
	Else
		GUICtrlSetState($ctrl, $GUI_DISABLE)
	EndIf
EndFunc   ;==>flip_file_validity

Func buyTowerHandler($letter, $x, $y)
	ConsoleWrite("buying " & $letter & " at " & String($x) & "," & String($y) & @CRLF)
	WinActivate($hand)
	Sleep($s)
	MouseMove($x+$bx, $y+$by, 0)
	Sleep($s*3)
	Send($letter)
	Sleep($s*5)
	MouseClick($MOUSE_CLICK_LEFT)
EndFunc   ;==>buyTowerHandler

Func blind_state_check($print)
	$mostsimilar = 0
	$highestscore = 0
	$searched = 1
	While $searched < $statecount

		$sim = state_similarity($searched)
		If $print Then ConsoleWrite("State " & $states[$searched][$NAME][0] & " was found to be " & $sim & " similar" & @CRLF)
		If ($sim > $highestscore) Then
			$mostsimilar = $searched
			$highestscore = $sim
		EndIf

		$searched += 1
	WEnd
	If ($highestscore > $cutoff And $mostsimilar <> $state) Then
		If $print Then ConsoleWrite("Swapping to state " & $states[$mostsimilar][$NAME][0] & @CRLF)
		change_state($mostsimilar)
	EndIf
EndFunc   ;==>blind_state_check

Func change_state($newstate)
	$state = $newstate
	GUICtrlSetData($stateGUI, $states[$state][$NAME][0])
EndFunc   ;==>change_state

Func state_similarity($stateID)

	$x = $states[$stateID][$SX][0] + $bx
	$y = $states[$stateID][$SY][0] + $by
	$similarity = 0
	$checked = 0
	$i = -$picsize
	While ($i < $picsize + 1)
		$j = -$picsize
		While ($j < $picsize + 1)

			$colobserved = PixelGetColor($x + $i, $y + $j)
			$colorexpected = $states[$stateID][$READINGS][$checked]

			$similarity += pixel_similarity($colobserved, $colorexpected)
			If ($similarity < 1) Then
				;ConsoleWrite("Discrepancy: " & $colorexpected & " <- " & $colobserved & @CRLF)
			EndIf
			$checked += 1

			$j += 1
		WEnd
		$i += 1
	WEnd
	$similarity /= $checked
	Return ($similarity)
EndFunc   ;==>state_similarity

Func pixel_similarity($p1, $p2)
	$r1 = BitShift(BitAND($p1, 0xFF0000), 16)
	$g1 = BitShift(BitAND($p1, 0x00FF00), 8)
	$b1 = BitAND($p1, 0x0000FF)

	$r2 = BitShift(BitAND($p2, 0xFF0000), 16)
	$g2 = BitShift(BitAND($p2, 0x00FF00), 8)
	$b2 = BitAND($p2, 0x0000FF)

	$off = 0
	$off += Abs($r1 - $r2)
	$off += Abs($g1 - $g2)
	$off += Abs($b1 - $b2)
	;ConsoleWrite($off)
	;ConsoleWrite(@CRLF)
	$off /= 3.0
	$off /= 255.0
	$sim = 1 - $off
	;ConsoleWrite($sim)
	;ConsoleWrite(@CRLF)
	Return ($sim)
EndFunc   ;==>pixel_similarity

Func change_meta_state($newstate)
	$i = 0
	While ($i < $metastates[$metastate][$CONTROLS][0])
		GUICtrlSetState($metastates[$metastate][$CONTROLLIST][$i], $GUI_HIDE)

		$i += 1
	WEnd
	$metastate = $newstate
	$i = 0
	While ($i < $metastates[$metastate][$CONTROLS][0])
		GUICtrlSetState($metastates[$metastate][$CONTROLLIST][$i], $GUI_SHOW)

		$i += 1
	WEnd
	GUICtrlSetData($metastateGUI, $metastates[$metastate][$NAME][0])
EndFunc   ;==>change_meta_state

Func pic_no_mouse($fname, $x, $y)
	MouseMove(0, 0, 0)
	Sleep(10)
	write_pic($fname, $x, $y)
	MouseMove($x, $y, 0)
EndFunc   ;==>pic_no_mouse

Func write_pic($fname, $x, $y)
	$f = FileOpen($fname, $FO_APPEND)

	$states[$statecount][$NAME][0] = GUICtrlRead($in)
	FileWriteLine($f, String($x - $bx))
	$states[$statecount][$SX][0] = $x - $bx
	FileWriteLine($f, String($y - $by))
	$states[$statecount][$SY][0] = $y - $by

	$num = 0
	$i = -$picsize
	While ($i < $picsize + 1)
		$j = -$picsize
		While ($j < $picsize + 1)

			$col = PixelGetColor($x + $i, $y + $j)
			FileWriteLine($f, String($col))
			$states[$statecount][$READINGS][$num] = $col
			$num += 1

			$j += 1
		WEnd
		$i += 1
	WEnd
	FileClose($f)
	$statecount += 1
EndFunc   ;==>write_pic

Func await_mouse_click($fname,$alt=0)
	$lastmousedown = False
	While True
		If _IsPressed("1B") Then
			Return
		EndIf
		If _IsPressed("02") Then
			$mousedown = True
		Else
			$mousedown = False
		EndIf
		If $mousedown And Not $lastmousedown Then
			$t = MouseGetPos()
			if $alt==1 Then
				ClipPut("$bx + " & $t[0]-$bx & ", $by + " & $t[1]-$by)
				Return
			ElseIf $alt==2 Then
				FileWriteLine($linkerfile,$states[$state][$NAME][0])
				FileWriteLine($linkerfile,$t[0]-$bx)
				FileWriteLine($linkerfile,$t[1]-$by)
				Return
			ElseIf $alt==3 Then
				$why=MouseGetPos()
				$prex=$why[0]-$bx
				$prey=$why[1]-$by

				Return
			EndIf
			pic_no_mouse($fname, $t[0], $t[1])
			Return
		EndIf
	WEnd
	$lastmousedown = $mousedown
EndFunc   ;==>await_mouse_click

Func await_tower_drop($key)
	$lastmousedown = False
	While True
		If _IsPressed("1B") Then
			Return
		EndIf
		If _IsPressed("01") Then
			$mousedown = True
		Else
			$mousedown = False
		EndIf
		If $mousedown And Not $lastmousedown Then
			$t = MouseGetPos()
			FileWriteLine($stratfile, String($PLACE))
			FileWriteLine($stratfile, String($key))
			FileWriteLine($stratfile, $t[0] - $bx)
			FileWriteLine($stratfile, $t[1] - $by)
			add_tower($t[0] - $bx, $t[1] - $by, $key)

			Return
		EndIf
	WEnd
	$lastmousedown = $mousedown
EndFunc   ;==>await_tower_drop

Func await_key_press()
	$hDLL = DllOpen("user32.dll")
	$a = 65
	$z = 90

	While True
		If _IsPressed("1B", $hDLL) Then
			DllClose($hDLL)
			Return (-1)

		EndIf
		$let = $a
		While ($let <= $z)

			If _IsPressed(Hex($let), $hDLL) Then
				DllClose($hDLL)
				Return ($let + 32)
			EndIf
			$let += 1
		WEnd
		Sleep($s)
	WEnd



EndFunc   ;==>await_key_press




Func Quit()
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	if $writeout <> "" Then
		MsgBox($MB_SYSTEMMODAL, $writeout, "")
		Exit
	EndIf
	$defs = FileOpen($fileheader & "/def.txt", $FO_OVERWRITE )
	$temp=WinGetPos($guu)
	$y=$temp[1]
	$x=$temp[0]
	if($x==-32000) Then
		$x=200
		$y=200
	EndIf
	FileWriteLine($defs,$x)
	FileWriteLine($defs,$y)
	FileWriteLine($defs,$s)
	FileWriteLine($defs,GUICtrlRead($teststratin))
	FileWriteLine($defs,GUICtrlRead($linkerin))
	FileClose($defs)
	MsgBox($MB_SYSTEMMODAL, "Sayonara", "")
	Exit
EndFunc   ;==>Quit
;;;;;;;;;;;;;;;;;;;;;;;;;;

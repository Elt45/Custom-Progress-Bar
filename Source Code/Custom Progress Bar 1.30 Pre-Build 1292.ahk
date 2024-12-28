#Persistent
Gui, Add, Text, , Enter Title:
Gui, Add, Edit, vPackageTitle w300
Gui, Add, Text, , Enter Duration (seconds):
Gui, Add, Edit, vDuration w100
Gui, Add, Text, , Save .pbr file as:
Gui, Add, Edit, vOutputFilePath w300 ReadOnly
Gui, Add, Button, gBrowseOutput, Browse
Gui, Add, Button, gStart, Start
Gui, Add, Button, gCreateFile, Create .pbr File
Gui, Add, Text, , OR
Gui, Add, Text, , Select a .pbr file:
Gui, Add, Edit, vFilePath w300
Gui, Add, Button, gBrowse, Browse
Gui, Show, , Custom Progress Bar

Return

Browse:
    FileSelectFile, FilePath, 3,, Select a .pbr file, *.pbr
    if (FilePath != "")
        GuiControl, , FilePath, %FilePath%
Return

BrowseOutput:
    FileSelectFile, OutputFilePath, S32,, Save .pbr file as, *.pbr
    if (OutputFilePath != "")
        GuiControl, , OutputFilePath, %OutputFilePath%
Return

Start:
    Gui, Submit, NoHide  ; Get the input from the Edit controls

    ; Check for valid manual input
    if (PackageTitle = "" && FilePath = "") {
        MsgBox, Please enter a title or select a .pbr file.
        Return
    }

    ; If a file path is provided, read the file
    if (FilePath != "") {
        FileRead, FileContents, %FilePath%
        if ErrorLevel {
            MsgBox, Could not read the file. Please ensure it exists.
            Return
        }

        ; Trim whitespace and parse contents
        StringTrimRight, FileContents, FileContents, 0
        ; Debugging: Show raw file contents
        MsgBox, Raw File Contents: %FileContents%

        ; Parse the contents
        if !RegExMatch(FileContents, "^\s*(.*?)\s*\|\&\s*\|(\d+)\s*$", TitleDuration) {
            MsgBox, The file does not contain valid data in the expected format.
            Return
        }

        PackageTitle := TitleDuration1
        Duration := TitleDuration2

        ; Debugging messages
        MsgBox, Title: %PackageTitle%`nDuration: %Duration%

        if (PackageTitle = "") {
            MsgBox, The file does not contain a valid title.
            Return
        }
        if (Duration = "" || !RegExMatch(Duration, "^\d+$") || Duration < 1) {
            MsgBox, The file does not contain a valid duration in seconds.
            Return
        }
    } else {
        ; Validate manual input
        if (Duration = "" || !RegExMatch(Duration, "^\d+$") || Duration < 1) {
            MsgBox, Please enter a valid duration in seconds.
            Return
        }
    }

    ; Show a temporary GUI with the title before starting
    Gui, Destroy
    Gui, Add, Text, vTitleText, %PackageTitle%
    Gui, Add, Progress, w400 h20 vProgressBar
    Gui, Add, Button, gCancel, Cancel
    Gui, Show, , %PackageTitle%

    GuiControl, , ProgressBar, 0  ; Reset progress bar
    Step := 100 / Duration  ; Calculate step based on the user-defined duration
    ProgressValue := 0
    Cancelled := false

    ; Run a loop for progress
    Loop, % Duration
    {
        Sleep, 1000
        if (Cancelled) {
            break
        }
        ProgressValue += Step
        GuiControl, , ProgressBar, %ProgressValue%
    }

    if (Cancelled) {
        MsgBox, Successfully canceled.
    } else {
        MsgBox, %PackageTitle% completed!
    }
    Gui, Destroy
    ExitApp

CreateFile:
    Gui, Submit, NoHide  ; Ensure inputs are captured

    ; Check for valid input before creating a file
    if (PackageTitle = "" || Duration = "" || !RegExMatch(Duration, "^\d+$") || Duration < 1 || OutputFilePath = "") {
        MsgBox, Please enter a valid title, duration, and output file path to create a .pbr file.
        Return
    }

    ; Trim any whitespace from the output file path
    OutputFilePath := Trim(OutputFilePath)

    ; Debugging: Check the output file path and its length
    filePathLength := StrLen(OutputFilePath) ; Store the length in a variable
    MsgBox, Output file path: [%OutputFilePath%]`nLength: %filePathLength%

    ; Ensure that the file path ends with .pbr
    if (SubStr(OutputFilePath, -4) != ".pbr") {
        MsgBox, Please ensure the file name ends with .pbr.
        Return
    }

    ; Create the .pbr file at the specified output path
    FileAppend, %PackageTitle% |`&| %Duration%`n, %OutputFilePath%
    MsgBox, Successfully created %OutputFilePath%.
Return

Cancel:
    Cancelled := true
Return

GuiClose:
    ExitApp

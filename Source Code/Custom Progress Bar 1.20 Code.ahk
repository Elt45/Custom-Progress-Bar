Gui, Add, Text, , Enter Title:
Gui, Add, Edit, vPackageTitle w300
Gui, Add, Text, , Enter Duration (seconds):
Gui, Add, Edit, vDuration w100
Gui, Add, Button, gStart, Start
Gui, Show, , Custom Progress Bar

Return

Start:
    Gui, Submit, NoHide  ; Get the input from the Edit controls
    if (PackageTitle = "") {
        MsgBox, Please enter a title.
        Return
    }
    if (Duration = "" || !RegExMatch(Duration, "^\d+$") || Duration < 1) {
        MsgBox, Please enter a valid duration in seconds.
        Return
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

    Loop, % Duration
    {
        Sleep, 1000
        if (A_GuiControl = "Cancel")  ; If Cancel button is pressed, exit loop
            ExitApp
        ProgressValue += Step
        GuiControl, , ProgressBar, % Round(ProgressValue)  ; Update progress bar
    }

    MsgBox, %PackageTitle% completed!
    Gui, Destroy
Return

Cancel:
    GuiControl, , ProgressBar, 0  ; Reset progress bar when canceled
    MsgBox, Task Cancelled
    Gui, Destroy
    Return

GuiClose:
    ExitApp

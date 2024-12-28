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

    ; Create a flag to track if the task should be canceled
    IsCanceled := false

    ; Main task loop
    Loop, % Duration
    {
        Sleep, 1000
        if (IsCanceled)  ; If canceled, show message box and ask for resume or close
        {
            MsgBox, 4,, Close? Would you like to close the task or resume?  ; Yes (Close), No (Resume)
            IfMsgBox, Yes
            {
                ExitApp  ; Close the script
            }
            Else  ; No (Resume)
            {
                IsCanceled := false  ; Resume the task
                Continue  ; Continue with the loop
            }
        }
        ProgressValue += Step
        GuiControl, , ProgressBar, % Round(ProgressValue)  ; Update progress bar
    }

    if (!IsCanceled) {
        MsgBox, %PackageTitle% completed!
    }
    Gui, Destroy
Return

Cancel:
    IsCanceled := true  ; Set the cancel flag to true
    GuiControl, , ProgressBar, 0  ; Reset progress bar when canceled
    MsgBox, 4,, Close? ; Yes (Close), No (Resume)
    IfMsgBox, Yes
    {
        Gui, Destroy
        ExitApp  ; Exit the script
    }
    Else  ; No (Resume)
    {
        IsCanceled := false  ; Resume the task
        Return  ; Continue with the loop
    }
Return

GuiClose:
    ExitApp

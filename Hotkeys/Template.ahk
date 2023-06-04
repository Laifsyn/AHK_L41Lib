#Requires AutoHotkey v2.0







^r:: reload
#SuspendExempt true
!s:: {
    doSuspend := 1
    While GetKeyState("s", "P") & GetKeyState("Alt", "P")
    {
        if GetKeyState("a", "P") & doSuspend
            Suspend(), doSuspend := 0
        else if !GetKeyState("a", "P")
            doSuspend := 1
    }
}

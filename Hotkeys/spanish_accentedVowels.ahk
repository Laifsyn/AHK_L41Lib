#Requires AutoHotkey v2.0

/*
How to use as it is:
To get the accented vowel press:
Alt + Shift + {vowel or n} 
Alt + {vowel or n}

To Suspend Hotkeys entries:
Hold Alt and s, and while keeping hold of alt + s, press a to toggle suspend state.
*/

Create_es_accentVowels()
Create_es_accentVowels("!+")

Create_es_accentVowels(modifiers := "!", options := "On") {
    static Vowels
    if !IsSet(Vowels)
        Vowels := Map(
            "a", Map("U", "Á", "L", "á"),
            "e", Map("U", "É", "L", "é"),
            "i", Map("U", "Í", "L", "í"),
            "o", Map("U", "Ó", "L", "ó"),
            "u", Map("U", "Ú", "L", "ú"),
            "n", Map("U", "Ñ", "L", "ñ")
        )
    for vowelKey, IMap in Vowels {
        Closure := (IMap, params*) => GetKeyState("CapsLock", "T") ^ GetKeyState("Shift", "P") ?
            SendInput(IMap["U"]) : SendInput(IMap["L"])
        Hotkey(modifiers vowelKey, Closure.Bind(IMap), options)
    }
}
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

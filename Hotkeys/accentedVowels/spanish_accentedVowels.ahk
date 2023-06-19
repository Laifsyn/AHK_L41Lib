#Requires AutoHotkey v2.0
#Include <udf>

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
DL := ClassDesarrolloLogico()
class ClassDesarrolloLogico extends C_storedData {
    __New() {
        super.__New("_desarrolloLogico", true)
    }
    getData(type, prompt) {
        last := this.data["lastGetData_" StrLower(type)]
        IB := InputBox("Ingrese un dato para " prompt, , , last)
        if IB.result != "ok"
            Exit
        this.data["lastGetData_" StrLower(type)] := IB.Value
        return StrSplit(IB.Value, ",", " `r`n")
    }
    Para(indexVar, startValue, operand := "<=") {
        old := A_Clipboard, A_Clipboard := ""
        A_Clipboard := paraFunc := Format("Para({1} = {2}; {1} {3} `; {1}++)`r`n", indexVar, startValue, operand)
        offset := StrLen(paraFunc) - RegExMatch(paraFunc, "i)" operand " `;") - StrLen(operand) - 1
        this.SendInput(offset)
        A_Clipboard := old
    }

    ImprimirLeer(Prompt, varName?) {
        old := A_Clipboard, A_Clipboard := ""
        if IsSet(varName)
            A_Clipboard := Format('Imprimir("{1}");`r`nLeer({2});', prompt, varName)
        else
            A_Clipboard := Format('Imprimir("{1}");', prompt)
        this.sendInput
        A_Clipboard := old
    }

    sendInput(offset := 0) {
        ClipWait(2, 1)
        sendInput("{ctrl down}v{ctrl up}")
        Sleep(250)
        if offset > 0
            SendInput("{left " offset "}")
    }
}
#hotif winActive("ahk_exe Code.exe")
^+p:: DL.Para(DL.GetData("paraFunc", "Para Function`r`n(indexVar, startValue, operand := <=)")*)
^+i:: DL.ImprimirLeer(DL.GetData("imprimirLeer", "Imprimir y Leer`r`n(Imprimir Prompt, Variable where to assign")*)
#hotif
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
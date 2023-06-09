#Requires AutoHotkey v2.0
#Include <eval> ; Converts String expression as AHK expressions. ie. "!!5" => 1
myMathString := mathString()
!+1:: SendInput(myMathString.evaluated)
!2:: SendInput(myMathString.getAndEvaluate(A_Clipboard))
!1:: SendInput(myMathString.getAndEvaluate())
!3:: msgbox(Format("Result: {}, from Clipboard `r`n{}", myMathString.getAndEvaluate(), myMathString.toEvaluate))
!9:: SendInput(myMathString.arrayGetAndEvaluate(A_Clipboard))
!0:: myMathString.Insert()
Class mathString extends Object {
    ;
    __Get(name, params*) {
        if (name = "Value")
            return this.evaluated
        return super.__Get(name, params*)
    }
    _evaluated := 0
    evaluated {
        get {
            if !eval(this.toEvaluate, true)
                throw ValueError("Not recognized expression!", Type(this), Chr(34) this.toEvaluate Chr(34))
            if this.isNewValue
                this._evaluated := eval(this.toEvaluate), this.isNewValue := false
            return this._evaluated
        }
    }
    isNewValue := 0
    _toEvaluate := ""
    toEvaluate {
        set {
            this.isNewValue := 1
            this._toEvaluate := Value
        }
        get => this._toEvaluate
    }

    arrayGetAndEvaluate(inputData?, delimiter := ",", omitChars := " ,", stringFormat?) {

        if !IsSet(inputData)
            this.__getClipboard(), inputData := this.toEvaluate
        text := ""
        if RegExMatch(inputData,replaceNeedle:="\{(.*)\}", &strFormat)
            inputData:=RegExReplace(inputData,replaceNeedle,""), stringFormat:=strFormat[1]
        inputData := StrSplit(inputData, delimiter, omitChars)
        for index, expression in inputData
        {
            this.toEvaluate := expression
            inputData[index] := this.evaluated
        }
        if IsSet(stringFormat)
            rv := Format(stringFormat, inputData*)
        else
        {
            rv := ""
            for v in inputData
                rv .= v delimiter
            rv := Rtrim(rv, delimiter)
        }
        A_Clipboard := rv
        return rv
    }

    getAndEvaluate(inputData?) {
        if !IsSet(inputData)
            this.__getClipboard()
        else
            this.toEvaluate := inputData
        return this.evaluated
    }
    Insert(data?) {
        static lastInsert := [], insertLastIndex := () => lastInsert.Length
        if IsSet(data)
            lastInsert.Push(data)
        else
            lastInsert.Push(InputBox("Insert expression", , , insertLastIndex() ? lastInsert[insertLastIndex()] : "").Value)
        this.getAndEvaluate(lastInsert[insertLastIndex()])
        Sleep(200)
        A_Clipboard := this.evaluated
        SendInput(this.evaluated)
    }
    __getClipboard(attemptsLimit := 5, stash_unStash := true) {
        if stash_unStash
            this.__stashClipboard()
        While 1 {
            if A_index > attemptsLimit
            {
                this.__unStash()
                throw ValueError("Couldn't get anything from the clipboard!")
            }
            SendInput("^c")
            if ClipWait(1, 1)
                break
        }
        this.toEvaluate := A_Clipboard
        if stash_unStash
            this.__unStash()
        return this
    }

    isStashed := 0
    __stashClipboard(replace?) {
        static date := A_Now, stashLenght := "unset"
        if this.isStashed && MsgBox(Format("There's already stashed data. Do you want to replace it?`r`n{} ago"
            , this.__formatTime(DateDiff(A_Now, date, "s"))
            , stashLenght > 100 ? stashLenght : this.stashedClipboard), , 0x4) = "No"
            return
        date := A_Now
        this.isStashed := 1
        this.stashedClipboard := A_Clipboard, A_Clipboard := ""
        stashLenght := StrLen(this.stashedClipboard)
        return this
    }
    __unStash() {
        if !this.isStashed
            throw Error("There's nothing to un-stash?")
        A_Clipboard := this.stashedClipboard, this.stashedClipboard := ""
        this.isStashed := 0
        return this
    }
    __formatTime(seconds) { ;Input time as seconds
        if seconds > 3600
            formatting := "hh 'hours' mm 'minutes' ss 'seconds'"
        else if seconds > 60
            formatting := "mm 'minutes' ss 'seconds'"
        else
            formatting := "ss 'seconds'"
        return FormatTime(DateAdd("20000101", seconds, "s"), formatting)
    }
    eval() => eval(this.toEvaluate)
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
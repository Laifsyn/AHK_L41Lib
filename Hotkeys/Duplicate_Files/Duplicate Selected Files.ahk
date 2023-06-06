#Requires AutoHotkey v2.0
cDFile := DuplicateFile()
!1:: cDFile.get_rename_andBackup(A_Clipboard)

class DuplicateFile {

    get_rename_andBackup(Data?, iteratedName := (num) => Format(" ({})", num), copies := 1, backup := true) {
        if !IsSet(Data)
            items := this.__getClipboard()
        else
            items := Data
        text := ""
        Paths := StrSplit(items, "`r`n", " ")
        if !(matches := this.isPath(Paths*)) = Paths.Length
            throw ValueError("There seems to be an item that's not a Path", , Format("{} items of {}", Paths.Length - matches, paths.Length))
        ; undoList:=[]  I can't decide on how to perform the Undo action
        for _, v in Paths {
            SplitPath(v, &_fullname, &_path, &_ext, &_name)
            ; undoList.Push(this.__backUp(v)) I can't decide on how to perform the Undo action
            if backup
                this.__backUp(v)
            destPath := ""
            Loop copies
            {
                offset := A_Index - 1
                Loop
                {
                    destPath := Format(_path "\{}.{}", _name iteratedName(A_Index + offset), _ext)
                    if !FileExist(destPath)
                        break
                }
                ; MsgBox destPath
                ; text .= Format("{}`r`n`r`n", destPath)
                FileCopy(v, destPath)
            }
        }
        if text != ""
            msgbox text
        ; this.undoList.push(undoList)
    }

    isPath(params*) {
        returnVal := 0
        for _, v in params
        {
            SplitPath(v, &fullName, &dir, &ext, &name)
            if dir = ""
                continue
            returnVal += 1
        }
        else
            throw Error("No data has been inputted!")
        return returnVal
    }

    __backUp(fileFullPath) {
        SplitPath(fileFullPath, &_fullname, &_path, &_ext, &_name)
        newPath := _path "\stored\"
        if !FileExist(newPath)
            DirCreate(newPath)
        newPath := _path "\stored\" _fullname
        if FileExist(newPath)
            return
        FileCopy(fileFullPath, newPath)
        ; return [fileFullPath, newPath] I can't decide on how to perform the Undo action
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
        returnVal := A_Clipboard
        if stash_unStash
            this.__unStash()
        return returnVal
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
#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#include <UDF>
G := myGlobal()
tempData := C_tempData()
storedData := C_storedData()

last := tempData.data.Has("ModsPath") ? tempData.data["ModsPath"] : ""
while 1 {
    obj := InputBox("Insert Minecraft mods File Path.", G.name, , last)
    if obj.result = "cancel"
        break
    if !FileExist(last := obj.value)
        continue
    if (Obj.value = tempData.data["ModsPath"])
        break
    tempData.data["ModsPath"] := obj.value
    tempData.Dump()
    MsgBox(tempData.data["ModsPath"])
    break
}
exit

ReadModLists() {
    global tempData, storedData
    other := []
    max := 0
    maxSize := 0
    getSize := () => A_LoopFileSizeKB < 10000 ? A_LoopFileSizeKB "KB": Round(A_LoopFileSizeMB + Mod(A_LoopFileSizeKB,1000)/1000,2 ) "MB"
    loop files tempData.data["ModsPath"] "\*"
    {
        size := getSize()
        SplitPath(A_LoopFileName, , , &ext, &name)
        if ext != "jar"
            name := name "." ext
        Max := StrLen(name) < max ? Max : StrLen(name)
        maxSize := StrLen(size) < maxSize ? maxSize : StrLen(size)
    }
    col1 := "ModName", col2 := "Size", col3 := "lastModified"
    Head := col1 stringJoin(" ", max - StrLen(col1) + 2) col2 stringJoin(" ", maxSize - StrLen(col2) + 4) col3
    Text := ""
    loop files tempData.data["ModsPath"] "\*"
    {
        size := getSize()
        extraData := Format(" [{}]{}{}hrs.", size, stringJoin(" ", maxSize - StrLen(size) + 2), FormatTime(A_LoopFileTimeModified, "MMMM dd hh:mm"))

        SplitPath(A_LoopFileName, , , &ext, &name)
        if ext != "jar"
            name := name "." ext
        extraData := stringJoin(" ", max - StrLen(name) + 1) extraData
        if ext = "jar"
            text .= name extraData "`r`n"
        else
            other.push(Format("{}`r`n", name extraData))
    }
    text := Trim(text, "`r`n")
    text := Sort(text)
    temp := ""
    for v in other
        temp .= v "`r`n"
    if temp != ""
        temp := Sort(temp)
    text := Trim(text temp, "`r`n")
    text := Head "`r`n" text
    path := storedData.data["modlistPath"]
    while 1
        if !FileExist(path)
            path := InputBox("Input the path where to store the modlist").value
        else
        {
            storedData.data["modlistPath"] := path, storedData.Dump()
            break
        }

    SetListVars(path "\modlist.list`r`n" Enumerate(text))
    file := FileOpen(path "\modlist.list", 0x1, A_FileEncoding)
    file.Write(Format("{2}", FormatTime(A_Now, "yyyy/MM/dd hh:mm"), text))
    file.Length := file.Pos
}
^r:: Reload
^!1:: ReadModLists()
!^esc:: tempData.OpenFilePath()
Enumerate(inputString) {
    text := ""
    inputstring := Trim(inputString, " `r`n")
    for line in StrSplit(inputString, "`r`n", " `r`n")
        text .= Format("{}-){}`r`n", A_index, line)
    return Trim(text, "`r`n")
}
Class myGlobal extends thisFile {
    __Init() {
        super.__Init()
    }
}
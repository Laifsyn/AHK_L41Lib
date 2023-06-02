#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#include <UDF>
G := myGlobal()
storedData := C_storedData()
last := storedData.data.Has("ModsPath") ? storedData.data["ModsPath"] : ""
while 1 {
    obj := InputBox("Insert Minecraft mods File Path.", G.name, , last)
    if obj.result = "cancel"
        break
    if !FileExist(last := obj.value)
        continue
    if (Obj.value = storedData.data["ModsPath"])
        break
    storedData.data["ModsPath"] := obj.value
    storedData.Dump()
    MsgBox(storedData.data["ModsPath"])
    break
}
exit

ReadModLists() {
    global storedData
    other := []
    max := 0
    maxSize := 0
    getSize := () => A_LoopFileSizeKB < 10000 ? A_LoopFileSizeKB "KB": Round(A_LoopFileSizeMB + Mod(A_LoopFileSizeKB,1000)/1000,2 ) "MB"
    loop files storedData.data["ModsPath"] "\*"
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
    loop files storedData.data["ModsPath"] "\*"
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
    text := Head "`r`n" text temp
    path := storedData.data["modlistPath"]
    while 1
        if !FileExist(path)
            path := InputBox("Input the path where to store the modlist",,,A_ScriptDir "\modlist.list").value
        else
        {
            storedData.data["modlistPath"] := path, storedData.Dump()
            break
        }

    SetListVars(path "\modlist.list`r`n" Enumerate(text))
    file := FileOpen(path "\modlist.list", 0x1, A_FileEncoding)
    file.Write(Format("{1}`r`n{2}", "https://github.com/Laifsyn/Laifsyn_2023I.Practices/blob/8832c3c55b31df0a55a27ec65f58f7fec6911a2f/Ocios/config.zip", text))
    file.Length := file.Pos
}
^r:: Reload
^!1:: ReadModLists()
!^esc:: storedData.OpenFilePath()
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
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
    text := ""
    other := []
    loop files tempData.data["ModsPath"] "\*"
    {
        SplitPath(A_LoopFileName, , , &ext, &name)
        if ext = "jar"
            text .= name "`r`n"
        else
            other.push(Format("{}.{}`r`n", name, ext))
    }
    text := Trim(text, "`r`n")
    text := Sort(text)
    temp := ""
    for v in other
        temp .= v "`r`n"
    if temp != ""
        temp:=Sort(temp)
    text := Trim(text temp, "`r`n")

    SetListVars(Enumerate(text))
    path := storedData.data["modlistPath"]
    while 1
        if !FileExist(path)
            path := InputBox("Input the path where to store the modlist").value
        else
        {
            storedData.data["modlistPath"] := path, storedData.Dump()
            break
        }

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
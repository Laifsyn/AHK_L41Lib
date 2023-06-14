#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#include <UDF>
#include "%A_ScriptDir%\ModMatcher.ahk"
G := myGlobal()
storedData := C_storedData()
last := storedData.data.Has("ModsPath") ? storedData.data["ModsPath"] : ""
while 1 {
    obj := InputBox("Insert Minecraft mods File Path.", G.name, , last)
    if obj.result = "cancel"
        break
    if !FileExist(last := obj.value)
    {
        MsgBox "Path doesn't exists : `r`n" last
        continue
    }
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
    A_nonJars := [], A_nonJars_detailed := []
    static IncludeList := ["jar", "disabled"]
    max := 0
    maxSize := 0
    getSize := () => A_LoopFileSizeKB < 10000 ? A_LoopFileSizeKB "KB" : Round(A_LoopFileSizeMB + Mod(A_LoopFileSizeKB, 1000) / 1000, 2) "MB"
    loop files storedData.data["ModsPath"] "\*"
    {
        size := getSize()
        SplitPath(A_LoopFileName, , , &ext, &name)
        if !isInList(ext, IncludeList)
            continue
        if ext != "jar"
            name := name "." ext
        Max := StrLen(name) < max ? Max : StrLen(name)
        maxSize := StrLen(size) < maxSize ? maxSize : StrLen(size)
    }
    col1 := "ModName", col2 := "Size", col3 := "lastModified"
    Head := col1 stringJoin(" ", max - StrLen(col1) + 2) col2 stringJoin(" ", maxSize - StrLen(col2) + 4) col3
    Text := ""
    detailedText := ""
    loop files storedData.data["ModsPath"] "\*"
    {
        size := getSize()
        ; extraData := Format(" [{}]{}{}hrs.", size, stringJoin(" ", maxSize - StrLen(size) + 2), FormatTime(A_LoopFileTimeModified, "MMMM dd hh:mm"))
        extraData := Format(" [{}]{}{} `t {}", size, stringJoin(" ", maxSize - StrLen(size) + 2), FormatTime(A_LoopFileTimeModified, "yyyy-MM-dd hh:mm:ss"), FormatTime(A_LoopFileTimeCreated, "yyyy-MM-dd hh:mm:ss"))

        SplitPath(A_LoopFileName, , , &ext, &name)
        if !isInList(ext, IncludeList)
            continue
        if ext != "jar"
            name := name "." ext
        extraData := stringJoin(" ", max - StrLen(name) + 1) extraData
        if ext = "jar"
            ;text .= name extraData "`r`n"
            text .= name "`r`n", detailedText .= name extraData "`r`n"
        else
            A_nonJars.push(Format("{}`r`n", name)), A_nonJars_detailed.Push(Format("{}`r`n", name))
    }
    text := Trim(text, "`r`n"), text := Sort(text)
    detailedText := Sort(detailedText), detailedText := Trim(detailedText, "`r`n")
    nonJars := ""
    nonJarsDetailed := ""
    for v in A_nonJars
        nonJars .= v "`r`n"
    if nonJars != ""
        nonJars := "`r`n" trim(Sort(nonJars), "`r`n")

    for v in A_nonJars_detailed
        nonJarsDetailed .= v "`r`n"
    if nonJarsDetailed != ""
        nonJarsDetailed := "`r`n" trim(Sort(nonJarsDetailed), "`r`n")
    ; text := Head "`r`n" text temp
    text := text nonJars

    detail := Head "`r`n" detailedText nonJars
    path := storedData.data["modlistPath"]
    while 1
        if !FileExist(path)
            path := InputBox("Input the path where to store the modlist", , , A_ScriptDir "\modlist.list").value
        else
        {
            storedData.data["modlistPath"] := path, storedData.Dump()
            break
        }

    SetListVars(path "\modlist.list`r`n" Enumerate(text))
    file := FileOpen(path "\modlist.list", 0x1, A_FileEncoding)
    file.Write(text := Format("{4}{2}`r`n`r`n{3}`r`n", "https://github.com/Laifsyn/Laifsyn_2023I.Practices/blob/8832c3c55b31df0a55a27ec65f58f7fec6911a2f/Ocios/config.zip`r`n", text, detail, ""))
    file.Length := file.Pos

    file := FileOpen(storedData.data["ModsPath"] "\modlist.list", 0x1, A_FileEncoding)
    file.Write(text)
    file.Length := file.Pos
    if MsgBox("Wanna open the list?", , 0x4) = "yes"
        run storedData.data["ModsPath"] "\modlist.list"
}
^r:: Reload
^!1:: ReadModLists()
!^esc:: storedData.OpenFilePath()
!+m:: run A_ScriptDir
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
#Requires AutoHotkey v2.0
/*
How to use:
1-) Drop this script inside your mod's folder.
2-) Drop the modlist.list inside your mod's folder (same as in step 1)
3-) Run the function CrossCheck() to obtain the summary

modlist.list follow's this logic on how it interprets it:
When parsing the mod's in modlist.list, it will add a .jar at the end if it doesn't find the ".jar" string anywhere.
so writing "fabric-api-0.83.0+1.19.4.jar" or "fabric-api-0.83.0+1.19.4" is irrelevant.
When Parsing:
It ignores files that has extension of "list", "zip" or "ahk", aka. ignoreList.
Parsing stops once it encounter's an empty line.

*/
#Include <udf>
storedData := C_storedData(, false)
old := [storedData.data["ModsPath"], storedData.data["modlist.list"]]
storedData.data["ModsPath"] := getInputData(Format("Enter your mod's Path`r`n{}", FileExist(v := storedData.data["ModsPath"]) ? "Already Registered:`r`n" v : ""), , v, "Path")
storedData.data["modlist.list"] := getInputData(Format("Enter your modlist.list Path`r`n{}", FileExist(v := storedData.data["modlist.list"]) ? "Already Registered:`r`n" v : ""), , v, "file")
if (
    old[1] != storedData.data["ModsPath"] or
    old[2] != storedData.data["modlist.list"]
)
    MsgBox("Updating config data"), storedData.Dump()
old := unset
!^9:: deleteMods()
!^5:: CrossCheck()
^+r:: Reload
crossCheck(modsPath := storedData.data["ModsPath"]) {
    modList := ""
    static ignoreList := ["list", "zip", "ahk", "exe"]
    loop read storedData.data["modlist.list"]
    {
        if InStr(A_LoopReadLine, "https")
            continue
        if A_LoopReadLine = ""
        {
            break
        }
        SplitPath(A_LoopReadLine, &filename, , &ext)
        if isInList(ext, ignoreList)
            continue
        if !InStr(A_LoopReadLine, ".jar")
            thisLine := A_LoopReadLine ".jar"
        else
            thisLine := A_LoopReadLine

        modList .= thisLine "`r`n"
    }
    getModName := (text) => RegExReplace(RegExReplace(text, "(-|v|_)\d.*", ""), "\[.*\]", "")
    nameList := getModName(modList) ;ModList as raw text
    modlist := StrSplit(modList, "`r`n", " ")
    youHaveMods := []
    youLackMods := []
    needsUpdate := [[], [], []]
    yourExtraMods := []
    localMods := []
    isLAreadyListed := []
    text := ""
    loop files storedData.data["ModsPath"] "\*"
        text .= A_LoopFileName "`r`n"
    for _, loopVal in (rr := StrSplit(sort(text, "C0"), "`r`n"))
    {

        SplitPath(loopVal, &filename, , &ext)
        if isInList(ext, ignoreList)
            continue
        localMods.Push(loopVal)
        if isInList(loopVal, modList)
            youHaveMods.Push(loopVal)
        else if updateIndex := isInList(getModName(loopVal), A_NameList := StrSplit(nameList, "`r`n"))
            needsUpdate[1].Push(modList[updateIndex])
            , needsUpdate[2].Push(Format("{}\{}", storedData.data["ModsPath"], loopVal))
            , needsUpdate[3].Push(Format('{2} `t`t"{1}", [{3}]', loopVal, modList[updateIndex], A_NameList[updateIndex]))
            , isLAreadyListed.Push(modList[updateIndex])
        else
            yourExtraMods.Push(loopVal)
    }

    for i, v in modList {
        if !isInList(v, localMods) and !isInList(v, isLAreadyListed)
            youLackMods.Push(v)
    }
    text := ""
    if youLackMods.Length > 0
        text .= Format("[Mods that you're missing from the list]`r`n{}`r`n", listParse(youLackMods))
    if needsUpdate[3].Length > 0
        text .= Format('[Mods that have mismatching version/name] List != "Local" [Name that{2}s doing the Match]`r`n{1}`r`n`r`n', listParse(needsUpdate[3]), "'")
    if yourExtraMods.Length > 0
        text .= Format("[Mods that don't appear in the list]`r`n{}`r`n", listParse(yourExtraMods))
    if youHaveMods.Length > 0
        text .= Format("[Mods you have that's matched modlist]`r`n{}`r`n`r`n", listParse(youHaveMods))
    if needsUpdate[2].Length > 0
        text .= Format("[Outdated mods?]`r`n{}`r`n`r`n", listParse(needsUpdate[2], "", false))

    SetListVars(text, 1)
}

isInList(item, list) {
    for i, v in list
        if item = v
            return i
    return false
}

listParse(items, header := "`t", enum := true) {
    text := ""
    maxcol := StrLen(items.Length)
    for i, k in items
    {
        if k = ""
            continue
        if enum
            text .= Format('{1}{2}-) {3} `r`n', header, stringJoin(' ', maxcol - StrLen(i)) String(i), k)
        else
            text .= Format('{1}{3} `r`n', header, stringJoin(' ', maxcol - StrLen(i)) String(i), k)
    }

    return text
}

deleteMods(mods := A_Clipboard) {
    fails := 0
    max := 0
    SetListVars(mods)
    if MsgBox("These are the mods you're looking to delete. Are you sure?", , 0x4) != "Yes"
        return
    for _, filePath in StrSplit(mods, "`r`n", " `t")
    {
        if FileExist(filePath)
        {
            try
                FileDelete(filePath)
            catch as E
                fails += 1
        }
        else
            fails += 1
        max := A_Index
    }
    MsgBox(Format("Delete successfully with: {} fails out of {} files", fails, max))
}
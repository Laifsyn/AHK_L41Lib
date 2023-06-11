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
!^5:: CrossCheck()

crossCheck(modListPath := A_ScriptDir "\modlist.list") {
    modList := ""
    static ignoreList := ["list", "zip", "ahk"]
    loop read A_ScriptDir "\modlist.list"
    {
        if A_Index = 1
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
    getModName := (text) => RegExReplace(RegExReplace(text, "(-|v|_)\d.*\.", "."), "\[.*\]", "")
    nameList := getModName(modList)
    modlist := StrSplit(modList, "`r`n", " ")
    youHaveMods := []
    youLackMods := []
    needsUpdate := []
    yourExtraMods := []
    localMods := []
    isLAreadyListed := []
    text := ""
    loop files A_ScriptDir "\*"
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
            needsUpdate.Push(Format('"{}" != "{}", [{}]', loopVal, modList[updateIndex], A_NameList[updateIndex])), isLAreadyListed.Push(modList[updateIndex])
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
    if needsUpdate.Length > 0
        text .= Format('[Mods that have mismatching version/name] "Local" != "List" [Name that{2}s doing the Match]`r`n{1}`r`n`r`n', listParse(needsUpdate), "'")
    if yourExtraMods.Length > 0
        text .= Format("[Mods that don't appear in the list]`r`n{}`r`n", listParse(yourExtraMods))
    if youHaveMods.Length > 0
        text .= Format("[Mods you have that's matched modlist]`r`n{}`r`n`r`n", listParse(youHaveMods))
    SetListVars(text, 1)
}
/* disable(input := A_clipboard) {
    if msgbox("Disabling `r`n" forLoop(input), , 0x4) != "Yes"
        return
    for v in StrSplit(input, "`r`n", " ")
    {
        SplitPath(v, &filename, &path, &ext)
        if ext = "jar"
            FileMove(v, Format("{}\{}.disabled", path, filename))
    }

}

Enable(input := A_clipboard) {
    if msgbox("Enabling `r`n" forLoop(input), , 0x4) != "Yes"
        return
    for v in StrSplit(input, "`r`n", " ")
    {
        SplitPath(v, &filename, &path, &ext, &originalFile)
        if ext = "disabled"
            FileMove(v, Format("{}\{}", path, originalFile))
    }

}

forLoop(text) {
    returnVal := ""
    for v in StrSplit(text, "`r`n", " ")
    {
        SplitPath(v, &filename, &path, &ext, &originalFile)
        returnVal .= filename "`r`n"
    }
    return returnVal
} */
^r:: reload


isInList(item, list) {
    for i, v in list
        if item = v
            return i
    return false
}

SetListVars(Text, DoWaitMsg := 0, msgboxText := "Waiting.....") {
    ListVars
    WinWaitActive "ahk_class AutoHotkey"
    ControlSetText Text, "Edit1"
    if DoWaitMsg
        Msgbox msgboxText
}
listParse(items, header := "`t") {
    text := ""
    maxcol := StrLen(items.Length)
    for i, k in items
    {
        if k = ""
            continue
        text .= Format('{1}{2}-) {3} `r`n', header, textJoin(' ', maxcol - StrLen(i)) String(i), k)
    }

    return text
}

textJoin(string, amount) {
    text := ""
    loop amount
        text .= string
    return text
}
#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
#include <UDF>
G:=myGlobal()
store := storedData()

DisplayMap(Start)
start.Dump()
^r:: Reload

Class myGlobal extends thisFile {
    __Init() {
        super.__Init()

    }
}
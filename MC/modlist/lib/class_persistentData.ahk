#Requires AutoHotkey v2.0


Class thisFile extends Map {
    encoding := "utf-8"
    name {
        get {
            if this.HasProp("_name")
                return this._name
            SplitPath(A_ScriptFullPath, , , , &name)
            return this._name := name
        }
    }
}

Class persistentData extends thisFile {

    __Init() {
        super.__Init()
        this.ext := "json"
        this.data := Map()
        this.store := Map("path", A_ScriptDir "\config")
        this.store["fileName"] := "persistentData." this.ext
        this.DefineProp("fileFullPath", {get:(this)=>(this.store["path"] "\" this.store["fileName"])})
    }

    __New() {
        this.__isCreated(this.fileFullPath)
        this.Load()
        return this
    }
    Load() {
        Try
            map := JXON.Load(this.__Read())
        catch
        {
            Sleep(800)
            If (r := MsgBox(Format("There was an issue with loading {}.`r`nAccepting will delete your data and load an empty file.", this.fileFullPath), this.name, 0x3) = "No")
            {
                this.Load()
                return
            } else if (r = "cancel")
                return

            FileDelete(this.fileFullPath)
            this.__isCreated(this.fileFullPath)
            this.Load()
            return
        }
        this.__MergeMap(this.data, map)
    }
    __Read() => FileRead(this.store["path"] "\" this.store["fileName"], this.encoding)
    __isCreated(path, shouldCreate := 1) {
        if !(exists := FileExist(path)) && shouldCreate
            this.__FileAppend("{}", path, this.encoding)
        return !!exists
    }
    __FileAppend(content, path, options) {
        SplitPath(path, , &dir)
        if !FileExist(dir)
            DirCreate(dir)
        FileAppend(content, path, options)
    }
    Dump() {
        fileObj := FileOpen(this.fileFullPath, 0x3, this.encoding)
        openPos := fileObj.Pos
        map := JXON.Load(fileObj.Read()), fileObj.Pos := openPos
        map := this.__MergeMap(map, this.data)
        map.set("timestamp", A_Now)
        fileObj.Write(JXON.Dump(map, 2))
        fileobj.Close()
    }
    __MergeMap(what, withWhat) {
        for k, v in withWhat
        {
            if (v is Object)
                v := Format("[{}]{}", ObjPtr(v), Type(v))
            what[k] := v
        }
        return what
    }
    OpenFilePath() {
        run(this.store["path"])
    }
    fileFullPath2{
        get => (this.store["path"] "\" this.store["fileName"])
    }
}

class C_tempData extends persistentData {

    __Init() {
        super.__Init()
        this.store.set("path", A_Temp "\AutoHotkey\config")
    }

}
class C_storedData extends persistentData {

}
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
    __New(namespace := "_default", syncOnChange := False) {
        this.sync := syncOnChange
        this.namespace := namespace
        this.ext := "json"
        this.store := Map("path", A_ScriptDir "\config")
        this.store["fileName"] := Format("persistentData{}.{}", this.namespace = "" ? "" : this.namespace, this.ext)
        this.DefineProp("fileFullPath", { get: (this) => (this.store["path"] "\" this.store["fileName"]) })
        this.__isCreated(this.fileFullPath)
        this.Load()
        return this
    }
    _data := Map()
    data[key?, prop := "value", skipSync := False] {
        set {
            if !IsSet(key)
                throw ValueError(Format("{}.data[{}].{}?", Type(this), "unset", prop), , "Key is Unset")
            if !this._data.has(key)
                this._data[key] := Object()
                .DefineProp("value", { value: Value })
                .DefineProp("sync", { get: (envObj) => this.sync })
            else
                this._data[key].DefineProp(prop, { value: Value })
            if skipSync
                return
            if this._data[key].sync
                this.Dump()
        }
        get {

            if !IsSet(key)
                return this._data
            if !this._data.has(key)
                this.data[key] := ""
            if !this._data[key].HasProp(prop)
                throw ValueError(Format("{}.data[{}].{} has no such property.", Type(this), key, prop), , prop)
            return this._data[key].%prop%
        }
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
        for k,v in map
            this.data[k]:=v
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
        fileObj.Write(text:=JXON.Dump(map, 2)), fileobj.Length:=StrLen(text)+openPos
        fileobj.Close()
    }
    __MergeMap(what, withWhat) {
        for k, v in withWhat
        {
            if v.HasProp("value")
                v := v.value
            if (v is Object)
                v := Format("[{}]{}", ObjPtr(v), Type(v))
            what[k] := v
        }
        return what
    }
    OpenFilePath() {
        run(this.store["path"])
    }
    fileFullPath {
        get => (this.store["path"] "\" this.store["fileName"])
    }
}

class C_tempData extends persistentData {

    __New(params*) {
        super.__New(params*)
        this.store.set("path", A_Temp "\AutoHotkey\config")
    }

}
class C_storedData extends persistentData {

}
#Requires AutoHotkey v2.0

Create_es_accentVowels()
Create_es_accentVowels("!+")

Create_es_accentVowels(modifiers := "!", options := "On") {
    static Vowels
    if !IsSet(Vowels)
        Vowels := Map(
            "a", Map("U", "Á", "L", "á"),
            "e", Map("U", "É", "L", "é"),
            "i", Map("U", "Í", "L", "í"),
            "o", Map("U", "Ó", "L", "ó"),
            "u", Map("U", "Ú", "L", "ú"),
            "n", Map("U", "Ñ", "L", "ñ")
        )
    for vowelKey, IMap in Vowels {
        Closure := (IMap, params*) => GetKeyState("CapsLock", "T") ^ GetKeyState("Shift", "P") ?
            SendInput(IMap["U"]) : SendInput(IMap["L"])
        Hotkey(modifiers vowelKey, Closure.Bind(IMap), options)
    }
}

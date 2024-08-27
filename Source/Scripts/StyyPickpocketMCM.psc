Scriptname StyyPickpocketMCM extends MCM_ConfigBase
{The documentation string.}

StealingIsNotBrowsing property timerScript auto
GlobalVariable Property StyyPickStressMiniTimer Auto ;stress timer
GlobalVariable Property StyyPickDebugNotification Auto ;enables debug notifications
GlobalVariable Property StyySkillModifier Auto ;modifier for timer calcs
GlobalVariable property timerMinCap Auto ;min time possible
GlobalVariable property timerMaxCap auto ;max time possible

Function LoadSettings()
    timerMinCap.SetValue(GetModSettingFloat("fMinCap:Caps"))
    timerMaxCap.SetValue(GetModSettingFloat("fMaxCap:Caps"))
    StyySkillModifier.SetValue(GetModSettingFloat("fModifier:Caps"))
    StyyPickDebugNotification.SetValueInt(GetModSettingBool("bEnableDebug:Debug") as int)
endfunction

Function LoadDefaults()
    
EndFunction

Event OnConfigInit()
    LoadSettings()
EndEvent

Event OnSettingChange(string a_ID)
    if a_ID == "fMinCap:Caps"
        timerMinCap.SetValue(GetModSettingFloat(a_ID))
    endif
    if a_ID == "fMaxCap:Caps"
        timerMaxCap.SetValue(GetModSettingFloat(a_ID))
    endif
    if a_ID == "fModifier:Caps"
        StyySkillModifier.SetValue(GetModSettingFloat(a_ID))
    endif
    if a_ID == "bEnableDebug"
        StyyPickDebugNotification.SetValueInt(GetModSettingBool("bEnableDebug:Debug") as int)
    endif
endevent


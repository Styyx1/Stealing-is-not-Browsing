Scriptname StealingIsNotBrowsing extends ReferenceAlias

import PO3_SKSEFunctions
import RogueUI
import DbAliasTimer
;----------------PROPERTIES---------------
Actor Property PlayerRef Auto
MiscObject Property Lockpick Auto
Spell Property StyyStressSpell Auto
MagicEffect Property PickpocketMonitorEffect Auto ;effect that checks for pickpocket action
Keyword Property StyyPickpocketTimerKeyword Auto ;keyword for potions

MagicEffect Property StyyPickpocketPotionEffect Auto ; 

; time increase Keywords. Number means increase in seconds. I recommend use till max 7

Keyword Property Pickpocket_TimeIncrease_1 auto
Keyword Property Pickpocket_TimeIncrease_2 auto
Keyword Property Pickpocket_TimeIncrease_3 auto
Keyword Property Pickpocket_TimeIncrease_4 auto
Keyword Property Pickpocket_TimeIncrease_5 auto
Keyword Property Pickpocket_TimeIncrease_6 auto
Keyword Property Pickpocket_TimeIncrease_7 auto
Keyword Property Pickpocket_TimeIncrease_8 auto
Keyword Property Pickpocket_TimeIncrease_9 auto
Keyword Property Pickpocket_TimeIncrease_10 auto
Keyword Property Pickpocket_TimeIncrease_15 auto

;Variables for MCM 
GlobalVariable Property StyyPickStressMiniTimer Auto ;stress timer
GlobalVariable Property StyyPickDebugNotification Auto ;enables debug notifications
GlobalVariable Property StyySkillModifier Auto ;modifier for timer calcs
GlobalVariable property timerMinCap Auto ;min time possible
GlobalVariable property timerMaxCap auto ;max time possible

;other properties
float property StyyModifiedTimer auto hidden ;timer set via other effects. see StyyIncreaseTimerPosion.psc to see how to make use of it
float property Timer auto hidden
string property ActorValueMod auto

;----------------VARIABLES---------------
float PotionTimer
MagicEffect[] activeList
float SleepModifier

;----------------FUNCTIONS---------------

bool Function IsPickingLock(Actor akActor)
    If (akActor.IsDead())
        return false
    elseif (akActor.IsPlayerTeammate())
        return false
    elseif (akActor.IsOffLimits() && !akActor.isDead() && !akActor.IsPlayerTeammate())
        return true
    Else
        return true
    EndIf
endfunction

bool Function HasPotionKeyword(Form akBaseObject)
    If akBaseObject.HasKeyword(Pickpocket_TimeIncrease_1)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_2)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_3)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_4)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_5)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_6) 
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_7)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_8)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_9)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_10)
        return true
    elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_15)
        return true
    else
        return false 
    EndIf
endfunction

float Function CalcFullTimer()
    float result = Timer
    if (PlayerRef.HasMagicEffectWithKeyword(StyyPickpocketTimerKeyword))
        result += PotionTimer
        ShowNotif("Potion added timer effect for + " + PotionTimer + " seconds")
    endif
    Timer = result
    ShowNotif("full timer is: " + Timer)
    return Timer
endfunction

float Function ModifyTimerBy()
    if PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_1)
        Timer += 1
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_2)
        Timer += 2
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_3)
        Timer += 3
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_4)
        Timer += 4
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_5)
        Timer += 5
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_6)
        Timer += 6
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_7)
        Timer += 7
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_8)
        Timer += 8
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_9)
        Timer += 9
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_10)
        Timer += 10
    elseif PlayerRef.HasMagicEffectWithKeyword(Pickpocket_TimeIncrease_15)
        Timer += 15
    endif
    ShowNotif("ModifyTimerBy calculated timer: " + Timer)
    return Timer
EndFunction

Function TimePickPocket()
    if  IsPickingLock(GetContainerOwner()) && FindEffect()   
        PO3_SKSEFunctions.HideMenu("ContainerMenu")  
        ShowNotif("waited " + Timer as string + " sec")   
        StyyPickStressMiniTimer.mod(1)
        if StyyPickStressMiniTimer.GetValueInt() == 4
            StyyStressSpell.Cast(PlayerRef, PlayerRef)
            StyyPickStressMiniTimer.SetValue(0)
        endif
        Actor rndActor = PO3_SKSEFunctions.GetRandomActorFromRef(PlayerRef as ObjectReference, 1024, true)
        if IsDetectedByAnyone(PlayerRef)
            rndActor.SendTrespassAlarm(PlayerRef) ;Tresspass alarm cause other alarms didn't make much sense to me            
        endif
        return
    endif
EndFunction

Function ShowNotif(string notif)
    ; Function to make debugging easy hidden via global    
    if StyyPickDebugNotification.GetValueInt() == 1
        debug.notification(notif)
    endif
endfunction

bool Function FindEffect()
    ; check for ACTIVE effects
    activeList = GetActiveEffects(PlayerRef, false)
    if activeList.Find(PickpocketMonitorEffect) > 0 
        return true
    else 
        return false
    endif
endfunction

float function CalcTimer()
    float modifer = StyySkillModifier.GetValue()    
    Timer = (PlayerRef.GetActorValue(ActorValueMod) / modifer) * SleepModifier
    ShowNotif("timer calculated with actor value. " + ActorValueMod + " level is " + PlayerRef.GetActorValue(ActorValueMod) + " and modifer is " + modifer as string)
    return Timer
endfunction
;----------------Main Script---------------
Event OnPlayerLoadGame()
    ActorValueMod = "Pickpocket" as string
EndEvent

Event OnInit()
    self.RegisterForSingleUpdate(1) ;to prevent double OnInit    
EndEvent

Event OnUpdate()
    self.RegisterForMenu("ContainerMenu")
    ActorValueMod = "Pickpocket" as string
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    If HasPotionKeyword(akBaseObject)    
        If Game.IsPluginInstalled("zxlice's ultimate potion animation.esp") 
        Utility.Wait(1.5)
        elseif Game.IsPluginInstalled("Animated Potions.esp")
        Utility.Wait(2.2)
        elseif Game.IsPluginInstalled("TaberuAnimation.esp")
        Utility.Wait(5.4)
        else
        Utility.Wait(0.1)
        endif
    
        if akBaseObject.HasKeyword(Pickpocket_TimeIncrease_1)
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())           
            PotionTimer = 1.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_2)
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 2.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_3)
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 3.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_4)
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 4.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_5)
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 5.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_6)          
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 6.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_7)           
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 7.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_8)           
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 8.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_9)            
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 9.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_10)            
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 10.0
        elseif akBaseObject.HasKeyword(Pickpocket_TimeIncrease_15)            
            AddMagicEffectToPotion(akBaseObject as Potion, StyyPickpocketPotionEffect, 1, 0, (akBaseObject as Potion).GetNthEffectDuration(0), 0, none)
            ShowNotif("Duration of the effects are: " + (akBaseObject as Potion).GetEffectDurations())
            PotionTimer = 15.0
        
        else 
            PotionTimer = 0.0
        endif  
    endif
    ShowNotif("timer modifier from equipping is: " + PotionTimer)
EndEvent

Event OnMenuOpen(String MenuName)    
    if MenuName == "ContainerMenu" && UI.IsMenuOpen("ContainerMenu") && FindEffect()        
        actor owner = GetContainerOwner() 
        ;ShowNotif("container target is "+ owner.GetDisplayName()) 
        if owner.GetSleepState() == 3
            SleepModifier = 2.0
            ShowNotif("Sleep state of "+ owner.GetDisplayName() + " detected, timer modified by factor "+ SleepModifier)
        else 
            SleepModifier = 1.0
        endif
        CalcTimer()
        ModifyTimerBy()
        CalcFullTimer()
    ;--------------set cap for timer-------------------------
        ShowNotif("Menu Timer = " + Timer as string)
        if Timer < timerMinCap.GetValue() * SleepModifier
            Timer = timerMinCap.GetValue()
            ShowNotif("Min cap is: " + timerMinCap.GetValue())
        elseif Timer > timerMaxCap.GetValue() * SleepModifier
            Timer = timerMaxCap.GetValue()
            ShowNotif("Max cap is: " +  timerMaxCap.GetValue())
        endif
    ;--------------set cap for timer-------------------------
        ;ShowNotif("caps are: " + timerMinCap.GetValue() + " and " + timerMaxCap.GetValue())
        ShowNotif("Timer is " + Timer)

        DbAliasTimer.StartMenuModeTimer(self as Alias, Timer as float, 2)
        

    endif
endevent

Auto State busy
        ; Note: Parameterless state events are only supported in Skyrim.
    Event OnBeginState()
        DbAliasTimer.StartMenuModeTimer(self as Alias, Timer as float, 2)
    EndEvent
    Event OnEndState()
    EndEvent
EndState

Event OnTimerMenuMode(int aiTimerID)
    ShowNotif("timer's up")
    if aiTimerID == 2 
        ShowNotif("Timer with ID " + aiTimerID + " out")
        TimePickPocket()
    Endif
EndEvent

Event OnMenuClose(String MenuName)
    float el_time = DbAliasTimer.GetTimeElapsedOnMenuModeTimer(self as Alias, 2)
    ShowNotif("Closed Menu Timer and the elapsed time so far is: " + el_time)
    if MenuName == "ContainerMenu"
        DbAliasTimer.CancelMenuModeTimer(self as Alias, 2)
        ShowNotif("closed menu with ID ["+ 2 + "]")
    endif
Endevent

Actor Function GetContainerOwner()
	Form[] menuForms = GetAssociatedMenuForm("ContainerMenu")
	If menuForms && menuForms.Length >= 1        
		Return menuForms[0] as Actor        
	EndIf
EndFunction
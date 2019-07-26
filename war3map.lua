function InitGlobals()
end
function levelup(hero)
    SetHeroAgi(hero, GetHeroAgi(hero) + 5)
    SetHeroStr(hero, GetHeroStr(hero) + 5)
    SetHeroInt(hero, GetHeroInt(hero) + 5)
    IncUnitAbilityLevel(hero, FourCC("AEfk"))
    IncUnitAbilityLevel(hero, FourCC("AHbz"))
    IncUnitAbilityLevel(hero, FourCC("AHfs"))
    IncUnitAbilityLevel(hero, FourCC("AUdd"))
end
function createZombie(player)
    CreateUnit( player, FourCC("nzom"), 0, 0, 0 )
end
function createMarine(player)
    u = CreateUnit( player, FourCC("H000"), 0, 0, 0 )
    UnitAddAbility(u, FourCC("Afzy"))
    UnitAddAbility(u, FourCC("Suhf"))
    BlzSetHeroProperName(u, GetPlayerName( player ))
    levelup(u)
end
function createCreeps(count)
    --[[
    for i=0,bj_MAX_PLAYERS do
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            for j=1,count do
                createZombie(Player(i))
            end
        end
    end
    ]]
    for i=1,count do
        createZombie(Player(25))
    end
end
function init()
    for i=0,bj_MAX_PLAYERS do
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            createMarine(Player(i))
        end
    end
end
function Trig_level_Actions()
    levelup(GetTriggerUnit())
end

function Trig_dead_Actions()
    RemoveUnit(GetTriggerUnit())
    CreateItem(FourCC("texp"), -300, 0)
end

function Trig_start_Actions()
    init()
end

function Trig_creep_Actions()
    createCreeps(10)
end

function Trig_pick_Actions()
    local unit = GetManipulatingUnit()
    local new_item = GetManipulatedItem()
    local count = 0
    for i=0,bj_MAX_PLAYER_SLOTS do
        item = UnitItemInSlot(unit, i)
        if GetItemTypeId(item) == GetItemTypeId(new_item) then
            count = count + 1
            if item ~= new_item then
                old_item = item
            end
        end
    end
    if count > 1 then
        if GetItemCharges(new_item) == 0 then
            SetItemCharges(old_item, GetItemCharges(old_item) + 1)
        else
            SetItemCharges(old_item, GetItemCharges(old_item) + GetItemCharges(new_item))
        end
        RemoveItem(new_item)
    end
end
function InitTrig_level()
    gg_trg_level = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(gg_trg_level, EVENT_PLAYER_HERO_LEVEL)
    TriggerAddAction(gg_trg_level, Trig_level_Actions)
end

function InitTrig_dead()
    gg_trg_dead = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(gg_trg_dead, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(gg_trg_dead, Trig_dead_Actions)
end

function InitTrig_start()
    gg_trg_start = CreateTrigger()
    TriggerRegisterTimerEventSingle(gg_trg_start, 0.00)
    TriggerAddAction(gg_trg_start, Trig_start_Actions)
end

function InitTrig_creep()
    gg_trg_creep = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(gg_trg_creep, 5.00)
    TriggerAddAction(gg_trg_creep, Trig_creep_Actions)
end

function InitTrig_pick()
    gg_trg_pick = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(gg_trg_pick, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(gg_trg_pick, Trig_pick_Actions)
end

function InitCustomTriggers()
    InitTrig_level()
    InitTrig_dead()
    InitTrig_start()
    InitTrig_creep()
    InitTrig_pick()
end

function InitCustomPlayerSlots()
    for i=0,bj_MAX_PLAYERS do
        SetPlayerStartLocation(Player(i), i)
        SetPlayerColor(Player(i), ConvertPlayerColor(i))
        SetPlayerRacePreference(Player(i), RACE_PREF_HUMAN)
        SetPlayerRaceSelectable(Player(i), false)
        if i > 0 then
            SetPlayerController(Player(i), MAP_CONTROL_COMPUTER)
        else
            SetPlayerController(Player(i), MAP_CONTROL_USER)
        end
    end
end

function main()
    SetCameraBounds(-1280.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -1536.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 1280.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 1024.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -1280.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 1024.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 1280.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -1536.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    NewSoundEnvironment("Default")
    SetAmbientDaySound("LordaeronSummerDay")
    SetAmbientNightSound("LordaeronSummerNight")
    SetMapMusic("Music", true, 0)
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
end

function config()
    SetMapName("TRIGSTR_001")
    SetMapDescription("TRIGSTR_003")
    SetPlayers(24)
    SetTeams(1)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    for i=0,bj_MAX_PLAYERS do
        DefineStartLocation(i, 0, 0)
    end
    InitCustomPlayerSlots()
end
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
    for i=0,24 do
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            for j=1,count do
                createZombie(Player(i))
            end
        end
    end
end
function init()
    for i=0,24 do
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            createMarine(Player(i))
        end
    end
end
function Trig_level_Actions()
    levelup(GetTriggerUnit())
end

function Trig_die_Actions()
    RemoveUnit(GetTriggerUnit())
    --CreateItem(FourCC("stpg"), -100, 0)
    --CreateItem(FourCC("glsk"), -100, 0)
    --CreateItem(FourCC("mort"), -100, 0)
    --CreateItem(FourCC("mort"), -100, 0)
    --CreateItem(FourCC("mcou"), -100, 0)
    CreateItem(FourCC("texp"), -100, 0)
end

function Trig_start_Actions()
    init()
end

function Trig_creep_Actions()
    createCreeps(4)
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
    TriggerAddAction(gg_trg_dead, Trig_die_Actions)
end

function InitTrig_start()
    gg_trg_start = CreateTrigger()
    TriggerRegisterTimerEventSingle(gg_trg_start, 0.00)
    TriggerAddAction(gg_trg_start, Trig_start_Actions)
end

function Trig_creep_Actions()
        createCreeps(10)
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
    SetPlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(0), true)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    SetPlayerColor(Player(1), ConvertPlayerColor(1))
    SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(1), true)
    SetPlayerController(Player(1), MAP_CONTROL_USER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerTeam(Player(1), 0)
end

function InitAllyPriorities()
    SetStartLocPrioCount(0, 1)
    SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(1, 1)
    SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
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
    SetPlayers(2)
    SetTeams(2)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    DefineStartLocation(0, 0.0, -256.0)
    DefineStartLocation(1, 0.0, -256.0)
    InitCustomPlayerSlots()
    SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    InitGenericPlayerSlots()
    InitAllyPriorities()
end
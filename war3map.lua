function InitGlobals()
    --constants
    C_ID_UNIT_ZOMBIE="nzom"
    C_ID_UNIT_MARINE="H000"

    --variables
    Game = gameClass:new()
end

--ClassGame
gameClass = {}
function gameClass:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.round=0
    self.players=GetPlayers()
    self.zombies=0
    self.maxZombies=24+((self.players-1)*6)
    return o
end
function gameClass:getZombies()
    return math.ceil((self.round*0.15)*self.maxZombies)
end
function gameClass:setRound(round)
    self.round = round
end
function gameClass:getRound()
    return self.round
end
function gameClass:newRound()
    self:setRound(self:getRound() + 1)
    print("# RONDA: " .. self:getRound())
    print("# MAX ZOMBI: " .. self.maxZombies)
    print("# ZOMBI: " .. self:getZombies())
end
--End ClassGame

--Functions
function GetZombies()
    return 4
end
function createMarine(player)
    hero = CreateUnit( player, FourCC(C_ID_UNIT_MARINE), 0, 0, 0 )
    SelectUnitForPlayerSingle( hero, player )
    UnitAddAbility(hero, FourCC("Afzy"))
    UnitAddAbility(hero, FourCC("Suhf"))
    --BlzSetHeroProperName(hero, GetPlayerName( player ))
    BlzSetHeroProperName(hero, "Marine")
    SetHeroAgi(hero, 13)
    SetHeroStr(hero, 14)
    SetHeroInt(hero, 15)
end
function createZombie(player)
    CreateUnit( player, FourCC(C_ID_UNIT_ZOMBIE), 0, 0, 0 )
end
function AddItemCharges(item, charges)
    if charges == 0 then
        SetItemCharges(item, GetItemCharges(item) + 1)
    else
        SetItemCharges(item, GetItemCharges(item) + charges)
    end
end

--Actions
function Trig_level_Actions()
    local hero = GetTriggerUnit()
    SetHeroAgi(hero, GetHeroAgi(hero) + 1)
    SetHeroStr(hero, GetHeroStr(hero) + 1)
    SetHeroInt(hero, GetHeroInt(hero) + 1)
end
function Trig_dead_Actions()
    RemoveUnit(GetTriggerUnit())
end
function Trig_creep_Actions()
    Game:newRound()
    for i=1,GetPlayers() do
        createZombie(Player(24))
    end
end
function Trig_pick_Actions()
    local unit = GetManipulatingUnit()
    local newitem = GetManipulatedItem()
    local count = 0
    for i=0,bj_MAX_PLAYER_SLOTS do
        item = UnitItemInSlot(unit, i)
        if GetItemTypeId(item) == GetItemTypeId(newitem) then
            count = count + 1
            if item ~= newitem then
                olditem = item
            end
        end
    end
    if count > 1 then
        AddItemCharges(olditem, GetItemCharges(newitem))
        RemoveItem(newitem)
    end
end

--Triggers
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
function InitTrig_creep()
    gg_trg_creep = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(gg_trg_creep, 4.00)
    TriggerAddAction(gg_trg_creep, Trig_creep_Actions)
end
function InitTrig_pick()
    gg_trg_pick = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(gg_trg_pick, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(gg_trg_pick, Trig_pick_Actions)
end

--setup
function InitCustomTriggers()
    InitTrig_level()
    InitTrig_dead()
    InitTrig_creep()
    InitTrig_pick()
end
function InitCreateHeros()
    for i=0,GetPlayers() do
        --if MeleeWasUserPlayer(Player(i)) then
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            createMarine(Player(i))
        end
    end
end
function InitCustomPlayerSlots()
    for i=0,GetPlayers() do
        --SetPlayerController(Player(i), MAP_CONTROL_USER)
        SetPlayerController(Player(i), ( i > 0 and MAP_CONTROL_COMPUTER or MAP_CONTROL_USER))
    end
end
function main()
    SetCameraBoundsToRect(GetWorldBounds())
    InitGlobals()
    InitCustomTriggers()
    InitCreateHeros()
end
function config()
    SetPlayers(4)
    InitCustomPlayerSlots()
end
function InitGlobals()
    --constants
    C_ID_UNIT_ZOMBIE="nzom"
    C_ID_UNIT_MARINE="H000"

    --variables
    Game = gameClass:new()
    marineHero = {}
end

--ClassGame
gameClass = {}
function gameClass:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.round=0
    self.players=GetPlayers()
    self.maxZombis=24+((self.players-1)*6)
    self.dieZombis=0
    self.mapZombis=0
    self.tmpZombis=0
    return o
end
function gameClass:setTmpZombis(tmpZombis)
    self.tmpZombis = tmpZombis
end
function gameClass:getTmpZombis(tmpZombis)
    return self.tmpZombis
end
function gameClass:getMaxZombis(tmpZombis)
    return self.maxZombis
end
function gameClass:setDieZombis(dieZombis)
    self.dieZombis = dieZombis
end
function gameClass:getDieZombis()
    return self.dieZombis
end
function gameClass:isNewRound()
    return (self.mapZombis-self.dieZombis==0)
end
function gameClass:getMapZombis()
    return self.mapZombis
end
function gameClass:calMapZombis()
    return math.ceil((self.round*0.15)*self.maxZombis)
end
function gameClass:newRound()
    self.round = self.round + 1
    self.dieZombis = 0
    self.tmpZombis = 0
    self.mapZombis = self:calMapZombis()
    print("Ronda: " .. self.round)
    for i=0,GetPlayers() do
        ReviveHero(marineHero[i], 0, 0, false)
    end
end
--End ClassGame

--Functions
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
    return hero
end
function createZombie(player)
    CreateUnit( player, FourCC(C_ID_UNIT_ZOMBIE), 0, 0, 0 )
end
function createZombis(count)
    for i=1,count do
        Game:setTmpZombis(Game:getTmpZombis() + 1)
        CreateUnit( Player(24), FourCC(C_ID_UNIT_ZOMBIE), 0, 0, 0 )
    end
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
    local unit = GetTriggerUnit()
    if GetUnitTypeId(unit) == FourCC(C_ID_UNIT_ZOMBIE) then
        RemoveUnit(unit)
        Game:setDieZombis(Game:getDieZombis() + 1)
        --print("zombis: " .. Game:getDieZombis() .. "-" .. Game:getTmpZombis() .. "-" .. Game:getMapZombis() .. "-" .. Game:getMaxZombis())
        if Game:isNewRound() then
            Game:newRound()
            createZombis(Game:getMapZombis() > Game:getMaxZombis() and Game:getMaxZombis() or Game:getMapZombis())
        else
            createZombis(Game:getMapZombis() - Game:getTmpZombis() ~= 0 and 1 or 0)
        end
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
function InitTrig_pick()
    gg_trg_pick = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(gg_trg_pick, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(gg_trg_pick, Trig_pick_Actions)
end

--setup
function InitCustomTriggers()
    InitTrig_level()
    InitTrig_dead()
    InitTrig_pick()
end
function InitCreateHeros()
    for i=0,GetPlayers() do
        --if MeleeWasUserPlayer(Player(i)) then
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            marineHero[i]=createMarine(Player(i))
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
    Game:newRound()
    createZombis((Game:getMapZombis() > Game:getMaxZombis() and Game:getMaxZombis() or Game:getMapZombis()))
end
function config()
    SetPlayers(8)
    InitCustomPlayerSlots()
end
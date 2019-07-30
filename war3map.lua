function InitGlobals()
    --constants
    C_ID_UNIT_ZOMBIE="nzom"
    C_ID_UNIT_MARINE="H000"

    --variables
    Game = gameClass:new()
    marineHero = {}
    boardPoints = nil
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
    self.board = nil
    return o
end
function gameClass:setTmpZombis(tmpZombis)
    self.tmpZombis = tmpZombis
end
function gameClass:getTmpZombis()
    return self.tmpZombis
end
function gameClass:getMaxZombis()
    return self.maxZombis
end
function gameClass:setDieZombis(dieZombis)
    self.dieZombis = dieZombis
end
function gameClass:getDieZombis()
    return self.dieZombis
end
function gameClass:setRound(round)
    self.round = round
end
function gameClass:getRound()
    return self.round
end
function gameClass:isNewRound()
    return (self.mapZombis-self.dieZombis==0)
end
function gameClass:getMapZombis()
    return self.mapZombis
end
function gameClass:setBoard(board)
    self.board = board
end
function gameClass:getBoard()
    return self.board
end
function gameClass:calMapZombis()
    return math.ceil((self.round*0.15)*self.maxZombis)
end
function gameClass:newRound()
    self.round = self.round + 1
    self.dieZombis = 0
    self.tmpZombis = 0
    self.mapZombis = self:calMapZombis()
    LeaderboardSetLabel(self.board, "Ronda " .. self.round)
    for i=0,GetPlayers() do
        ReviveHero(marineHero[i], 0, 0, true)
    end
end
--End ClassGame

--Functions
function CreateBoard()
    board = CreateLeaderboard()
    ForceSetLeaderboardBJ(board, GetPlayersAll())
    LeaderboardSetLabel(board, "Ronda " .. Game:getRound())
    for i=0,GetPlayers()-1 do
        LeaderboardAddItem(board, GetPlayerName(Player(i)), 0, Player(i))
    end
    LeaderboardSetSizeByItemCount(board, GetPlayers()+1)
    return board
end
function createMarine(player)
    local hero
    --hero = CreateUnit( player, FourCC(C_ID_UNIT_MARINE), 0, 0, 0 )
    hero = CreateUnitAtLoc( player, FourCC(C_ID_UNIT_MARINE), GetPlayerStartLocationLoc(player), 0.00 )
    SelectUnitForPlayerSingle(hero, player)
    UnitAddAbility(hero, FourCC("Suhf"))
    UnitAddAbility(hero, FourCC("AEfk"))
    UnitAddAbility(hero, FourCC("AHbz"))
    UnitAddAbility(hero, FourCC("AHfs"))
    UnitAddAbility(hero, FourCC("AUdd"))
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
    local hero = GetKillingUnit()
    local gold = GetPlayerState(GetOwningPlayer(hero), PLAYER_STATE_RESOURCE_GOLD)
    if GetUnitTypeId(unit) == FourCC(C_ID_UNIT_ZOMBIE) then
        LeaderboardSetItemValue(Game:getBoard(), LeaderboardGetPlayerIndex(Game:getBoard(), GetOwningPlayer(hero)), gold)
        LeaderboardSortItemsByValue(Game:getBoard(), false)
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
function Trig_init_Actions()
    Game:setBoard(CreateBoard())
    Game:newRound()
    for i=0,GetPlayers() do
        --if MeleeWasUserPlayer(Player(i)) then
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            marineHero[i]=createMarine(Player(i))
        end
    end
    createZombis((Game:getMapZombis() > Game:getMaxZombis() and Game:getMaxZombis() or Game:getMapZombis()))
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
function InitTrig_init()
    gg_trg_init = CreateTrigger()
    TriggerRegisterTimerEventSingle(gg_trg_init, 0)
    TriggerAddAction(gg_trg_init, Trig_init_Actions)
end

--setup
function InitCustomTriggers()
    InitTrig_level()
    InitTrig_dead()
    InitTrig_pick()
    InitTrig_init()
end
function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(2), 2)
    SetPlayerController(Player(2), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(3), 3)
    SetPlayerController(Player(3), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(4), 4)
    SetPlayerController(Player(4), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(5), 5)
    SetPlayerController(Player(5), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(6), 6)
    SetPlayerController(Player(6), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(7), 7)
    SetPlayerController(Player(7), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(8), 8)
    SetPlayerController(Player(8), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(9), 9)
    SetPlayerController(Player(9), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(10), 10)
    SetPlayerController(Player(10), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(11), 11)
    SetPlayerController(Player(11), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(12), 12)
    SetPlayerController(Player(12), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(13), 13)
    SetPlayerController(Player(13), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(14), 14)
    SetPlayerController(Player(14), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(15), 15)
    SetPlayerController(Player(15), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(16), 16)
    SetPlayerController(Player(16), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(17), 17)
    SetPlayerController(Player(17), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(18), 18)
    SetPlayerController(Player(18), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(19), 19)
    SetPlayerController(Player(19), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(20), 20)
    SetPlayerController(Player(20), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(21), 21)
    SetPlayerController(Player(21), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(22), 22)
    SetPlayerController(Player(22), MAP_CONTROL_COMPUTER)
    SetPlayerStartLocation(Player(23), 23)
    SetPlayerController(Player(23), MAP_CONTROL_COMPUTER)
end
function main()
    SetCameraBounds(-5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -5632.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5120.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 5120.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -5632.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
end
function config()
    SetPlayers(24)
    DefineStartLocation(0, 0, 0)
    DefineStartLocation(1, 0, 0)
    DefineStartLocation(2, 0, 0)
    DefineStartLocation(3, 0, 0)
    DefineStartLocation(4, 0, 0)
    DefineStartLocation(5, 0, 0)
    DefineStartLocation(6, 0, 0)
    DefineStartLocation(7, 0, 0)
    DefineStartLocation(8, 0, 0)
    DefineStartLocation(9, 0, 0)
    DefineStartLocation(10, 0, 0)
    DefineStartLocation(11, 0, 0)
    DefineStartLocation(12, 0, 0)
    DefineStartLocation(13, 0, 0)
    DefineStartLocation(14, 0, 0)
    DefineStartLocation(15, 0, 0)
    DefineStartLocation(16, 0, 0)
    DefineStartLocation(17, 0, 0)
    DefineStartLocation(18, 0, 0)
    DefineStartLocation(19, 0, 0)
    DefineStartLocation(20, 0, 0)
    DefineStartLocation(21, 0, 0)
    DefineStartLocation(22, 0, 0)
    DefineStartLocation(23, 0, 0)
    InitCustomPlayerSlots()
    --InitGenericPlayerSlots()
end
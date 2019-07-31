function InitGlobals()
    --constants
    C_ID_UNIT_ZOMBIE="nzom"
    C_ID_UNIT_MARINE="H000"

    --variables
    Game = gameClass:new()
    marineHero = {}
    groupZombis = CreateGroup()
    boardPoints = nil
end

--ClassGame
gameClass = {}
function gameClass:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.round=20
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
function ContinuousAttack(zombi)
	local mindistance=0
	local tmpdistance=0
	local victim=nil
	for i=0,GetPlayers()-1 do
		if GetUnitState(marineHero[i], UNIT_STATE_LIFE) > 0 then
			tmpdistance=DistanceBetweenPoints(GetUnitLoc(zombi), GetUnitLoc(marineHero[i]))
			if tmpdistance < mindistance or mindistance == 0 then
				mindistance=tmpdistance
				victim=marineHero[i]
			end
		end
	end
	print("Mejor distancia para atacar a :" .. GetPlayerName(GetOwningPlayer(victim)) .. " = " .. mindistance)
	IssueTargetOrder( zombi, "attack", victim )
end
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
function CreateMarine(player)
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
function CreateZombis(count)
    for i=1,count do
        Game:setTmpZombis(Game:getTmpZombis() + 1)
        zombi=CreateUnit( Player(24), FourCC(C_ID_UNIT_ZOMBIE), math.random(-4000,4000), math.random(-4000,4000), 0 )
        GroupAddUnit(groupZombis, zombi)
        ContinuousAttack(zombi)
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
    local zombi = GetTriggerUnit()
    local hero = GetKillingUnit()
    local gold = GetPlayerState(GetOwningPlayer(hero), PLAYER_STATE_RESOURCE_GOLD)
    if GetUnitTypeId(zombi) == FourCC(C_ID_UNIT_ZOMBIE) then
        LeaderboardSetItemValue(Game:getBoard(), LeaderboardGetPlayerIndex(Game:getBoard(), GetOwningPlayer(hero)), gold)
        LeaderboardSortItemsByValue(Game:getBoard(), false)
        GroupRemoveUnit(groupZombis, zombi)
        RemoveUnit(zombi)
        Game:setDieZombis(Game:getDieZombis() + 1)
        --print("zombis: " .. Game:getDieZombis() .. "-" .. Game:getTmpZombis() .. "-" .. Game:getMapZombis() .. "-" .. Game:getMaxZombis())
        if Game:isNewRound() then
            Game:newRound()
            CreateZombis(Game:getMapZombis() > Game:getMaxZombis() and Game:getMaxZombis() or Game:getMapZombis())
        else
            CreateZombis(Game:getMapZombis() - Game:getTmpZombis() ~= 0 and 1 or 0)
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
            marineHero[i]=CreateMarine(Player(i))
        end
    end
    CreateZombis((Game:getMapZombis() > Game:getMaxZombis() and Game:getMaxZombis() or Game:getMapZombis()))
end
function Trig_attack_Actions()
	local zombi
	for i=0,BlzGroupGetSize(groupZombis) do
		zombi = BlzGroupUnitAt(groupZombis, i)
		ContinuousAttack(zombi)
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
function InitTrig_init()
    gg_trg_init = CreateTrigger()
    TriggerRegisterTimerEventSingle(gg_trg_init, 0)
    TriggerAddAction(gg_trg_init, Trig_init_Actions)
end
function InitTrig_attack()
    gg_trg_attack = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(gg_trg_attack, .3)
    TriggerAddAction(gg_trg_attack, Trig_attack_Actions)
end

--setup
function InitCustomTriggers()
    InitTrig_level()
    InitTrig_dead()
    InitTrig_pick()
    InitTrig_init()
    InitTrig_attack()
end
function InitCustomPlayerSlots()
	for i=0,GetPlayers()-1 do
		SetPlayerStartLocation(Player(i), i)
		SetPlayerController(Player(i), (i > 0 and MAP_CONTROL_COMPUTER or MAP_CONTROL_USER))
	end
end
function main()
    SetCameraBounds(-5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -5632.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5120.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 5120.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -5632.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
end
function config()
    SetPlayers(4)
    for i=0,GetPlayers()-1 do
    	DefineStartLocation(i, math.random(-4000,4000), math.random(-4000,4000))
    end
    InitCustomPlayerSlots()
    InitGenericPlayerSlots()
end
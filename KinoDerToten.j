globals
	constant integer LIMIT_ZOMBIE		= 50
	constant integer LIMIT_WOLF			= 5
	constant integer USES_MISTERYBOX	= 10
	constant integer MAX_PLAYERS		= 4
	constant integer POINT_INSTAKILL	= 110
	constant integer TIME_BREAKROUND	= 6
	constant integer COST_MISTERYBOX	= 0
	constant integer ONE_PERCENT		= 1
	constant integer HUNDRED_PERCENT	= 100
	integer usesMisterBox	= 0
	integer round			= 0
	integer players			= 0
	integer totalZombie
	integer inmapZombie
	integer limitCreate
	integer array pointPlayer
	leaderboard tablePoints
	rect array pointsMisteryBox
	rect array regionZombie
	boolean flagCreate
	boolean isActiveDoublePoint	= false
	boolean isActiveInstantKill	= false
	boolean isActivateLight		= false
	boolean isTimeHellhounds	= false
	string array weapons
	string array modelWeapon
	hashtable hashtableTimer = InitHashtable()
endglobals

function reckonZombie takes integer numbRound, integer numbPlayer returns integer
	local real numbZombie
	if numbPlayer == 1 and numbRound == 1 then
		set numbZombie = 6
	endif
	if numbPlayer == 1 and numbRound == 2 then
		set numbZombie = 8
	endif
	if numbPlayer == 1 and numbRound == 3 then
		set numbZombie = 13
	endif
	if numbPlayer == 1 and numbRound == 4 then
		set numbZombie = 18
	endif
	if numbPlayer == 1 and numbRound == 5 then
		set numbZombie = 24
	endif
	if numbPlayer == 1 and numbRound == 6 then
		set numbZombie = 27
	endif
	if numbPlayer == 1 and numbRound == 7 then
		set numbZombie = 28
	endif
	if numbPlayer == 1 and numbRound == 8 then
		set numbZombie = 28
	endif
	if numbPlayer == 1 and numbRound == 9 then
		set numbZombie = 29
	endif
	if numbPlayer == 1 and numbRound == 10 then
		set numbZombie = 33
	endif
	if numbPlayer == 1 and numbRound > 10 then
		set numbZombie = 0.0842 * (numbRound * numbRound) + 0.1954 * (numbRound) + 22.05
	endif
	if numbPlayer == 2 and numbRound == 1 then
		set numbZombie = 7
	endif
	if numbPlayer == 2 and numbRound == 2 then
		set numbZombie = 9
	endif
	if numbPlayer == 2 and numbRound == 3 then
		set numbZombie = 15
	endif
	if numbPlayer == 2 and numbRound == 4 then
		set numbZombie = 21
	endif
	if numbPlayer == 2 and numbRound == 5 then
		set numbZombie = 27
	endif
	if numbPlayer == 2 and numbRound == 6 then
		set numbZombie = 31
	endif
	if numbPlayer == 2 and numbRound == 7 then
		set numbZombie = 32
	endif
	if numbPlayer == 2 and numbRound == 8 then
		set numbZombie = 33
	endif
	if numbPlayer == 2 and numbRound == 9 then
		set numbZombie = 34
	endif
	if numbPlayer == 2 and numbRound == 10 then
		set numbZombie = 42
	endif
	if numbPlayer == 2 and numbRound > 10 then
		set numbZombie = 0.1793 * (numbRound * numbRound) + 0.0405 * (numbRound) + 23.187
	endif
	if numbPlayer == 3 and numbRound == 1 then
		set numbZombie = 11
	endif
	if numbPlayer == 3 and numbRound == 2 then
		set numbZombie = 14
	endif
	if numbPlayer == 3 and numbRound == 3 then
		set numbZombie = 23
	endif
	if numbPlayer == 3 and numbRound == 4 then
		set numbZombie = 32
	endif
	if numbPlayer == 3 and numbRound == 5 then
		set numbZombie = 41
	endif
	if numbPlayer == 3 and numbRound == 6 then
		set numbZombie = 47
	endif
	if numbPlayer == 3 and numbRound == 7 then
		set numbZombie = 48
	endif
	if numbPlayer == 3 and numbRound == 8 then
		set numbZombie = 50
	endif
	if numbPlayer == 3 and numbRound == 9 then
		set numbZombie = 51
	endif
	if numbPlayer == 3 and numbRound == 10 then
		set numbZombie = 62
	endif
	if numbPlayer == 3 and numbRound > 10 then
		set numbZombie = 0.262 * (numbRound * numbRound) + 0.301 * (numbRound) + 33.114
	endif
	if numbPlayer == 4 and numbRound == 1 then
		set numbZombie = 14
	endif
	if numbPlayer == 4 and numbRound == 2 then
		set numbZombie = 18
	endif
	if numbPlayer == 4 and numbRound == 3 then
		set numbZombie = 30
	endif
	if numbPlayer == 4 and numbRound == 4 then
		set numbZombie = 42
	endif
	if numbPlayer == 4 and numbRound == 5 then
		set numbZombie = 54
	endif
	if numbPlayer == 4 and numbRound == 6 then
		set numbZombie = 62
	endif
	if numbPlayer == 4 and numbRound == 7 then
		set numbZombie = 64
	endif
	if numbPlayer == 4 and numbRound == 8 then
		set numbZombie = 66
	endif
	if numbPlayer == 4 and numbRound == 9 then
		set numbZombie = 68
	endif
	if numbPlayer == 4 and numbRound == 10 then
		set numbZombie = 83
	endif
	if numbPlayer == 4 and numbRound > 10 then
		set numbZombie = 0.3462 * (numbRound * numbRound) + 0.4964 * (numbRound) + 43.164
	endif
	return R2I(numbZombie + 0.5)
endfunction
function isProbability takes integer percent returns boolean
	if ( GetRandomInt( ONE_PERCENT, HUNDRED_PERCENT ) <= percent ) then
		return true
	endif
	return false
endfunction
function createZombie takes nothing returns nothing
	local unit unitZombie
	local integer typeZombie = 'nzom'
	if isActivateLight then
		if isProbability(20) then
			set typeZombie = 'ugho'
		endif
	endif
	set unitZombie = CreateUnitAtLoc( Player(4), typeZombie, GetRandomLocInRect(regionZombie[GetRandomInt(0,5)]), 0.00 )
	call BlzSetUnitArmor( unitZombie, round )
	call SetUnitColor( unitZombie, PLAYER_COLOR_BROWN )
	call GroupAddUnitSimple( unitZombie, udg_grupoZombies )
endfunction
function calTimeHellhounds takes integer ronda returns boolean
	local integer modulo
	set modulo = GetRandomInt(4,7)
	if ModuloInteger(ronda, modulo) == 0 then
		return true
	endif
	return false
endfunction
function reckonWolf takes integer numbRound, integer numbPlayer returns integer
	local real numbWolf
	set numbWolf = ( ( numbRound * numbRound ) / ( 2 * numbRound ) ) + numbPlayer
	return R2I(numbWolf + 0.5)
endfunction
function newZombie takes real wait returns nothing
	set totalZombie = totalZombie - 1
	set inmapZombie = inmapZombie + 1
	if wait > 0 then
		call PolledWait(wait)
	endif
	if isTimeHellhounds then
		call PolledWait(GetRandomReal(0.00, 6.00))
		call TriggerExecute( gg_trg_CreateWolf )
	else
		call createZombie()
	endif
endfunction
function newRound takes nothing returns nothing
	local integer addZombie
	set round = round + 1
	set totalZombie = 0
	set inmapZombie = 0
	call LeaderboardSetLabel(tablePoints, "Ronda " + I2S(round))
	call PolledWait(TIME_BREAKROUND)
	set isTimeHellhounds = calTimeHellhounds(round)
	if isTimeHellhounds then
		set totalZombie = reckonWolf(round, players)
		set limitCreate = LIMIT_WOLF
	else
		set totalZombie = reckonZombie(round, players)
		set limitCreate = LIMIT_ZOMBIE
	endif
	if totalZombie > limitCreate then
		set addZombie = limitCreate
	else
		set addZombie = totalZombie
	endif	
	set flagCreate = false
	loop
		exitwhen addZombie <= 0
		call newZombie(0.00)
		set addZombie = addZombie - 1
	endloop
	call EnableTrigger( gg_trg_AttractAliade )
	set flagCreate = true
endfunction
function deadZombie takes unit zombie returns nothing
	set inmapZombie = inmapZombie - 1
	if totalZombie > 0 and flagCreate == true then
		if inmapZombie < limitCreate then
			call newZombie(6.00)
		endif
	endif
	if totalZombie == 0 and inmapZombie == 0 then
		call DisableTrigger( gg_trg_AttractAliade )
		call newRound()
	endif
endfunction
function addPointInScore takes integer addPoint, unit aliade returns nothing
	local integer idAliade
	if isActiveInstantKill then
		set addPoint = POINT_INSTAKILL
		call KillUnit(GetAttackedUnitBJ())
	endif
	if isActiveDoublePoint then
		set addPoint = addPoint * 2
	endif
	set idAliade = GetConvertedPlayerId(GetOwningPlayer(aliade))
	set pointPlayer[idAliade] = pointPlayer[idAliade] + addPoint
	call LeaderboardSetPlayerItemValueBJ( GetOwningPlayer(aliade), tablePoints, pointPlayer[idAliade] )
	call LeaderboardSortItemsByValue(tablePoints, false)
	call CreateTextTagUnitBJ( "+" + I2S(addPoint), aliade, 0, 10, 100, 100, 0.00, 0 )
	call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
	call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 0.60 )
	call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90 )
	call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.10 )
endfunction
function delPointInScore takes integer delPoint, unit aliade returns nothing
	local integer idAliade
	set idAliade = GetConvertedPlayerId(GetOwningPlayer(aliade))
	set pointPlayer[idAliade] = pointPlayer[idAliade] - delPoint
	call LeaderboardSetPlayerItemValueBJ( GetOwningPlayer(aliade), tablePoints, pointPlayer[idAliade] )
	call LeaderboardSortItemsByValue(tablePoints, false)
	call CreateTextTagUnitBJ( "-" + I2S(delPoint), aliade, 0, 10, 100, 100, 0.00, 0 )
	call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
	call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 0.60 )
	call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90 )
	call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.10 )
endfunction
function UnitFlyUp takes unit u, real h, real v returns nothing
	call UnitAddAbility( u, 'Amrf' )
	call UnitRemoveAbility( u, 'Amrf' )
	call SetUnitFlyHeight( u, h, v )
endfunction
function UnitFlyDown takes unit u , real v returns nothing
	call UnitAddAbility( u, 'Amrf' )
	call UnitRemoveAbility( u, 'Amrf' )
	call SetUnitFlyHeight( u, 0.01, v )
endfunction
function actionThunderGun takes unit caster, group groupTemporal returns nothing
	local location locationCaster
	local location locationTarget
	local location locationTemporal
	local unit firtZombie
	local group groupZombie = CreateGroup()
	set locationCaster = GetUnitLoc(caster)
	call GroupAddGroup(groupTemporal, groupZombie)
	loop
		set firtZombie = FirstOfGroup(groupZombie)
		exitwhen(firtZombie == null)
		call GroupRemoveUnit(groupZombie, firtZombie)
		if GetOwningPlayer(firtZombie) == Player(4) then
			set locationTarget = GetUnitLoc(firtZombie)
			set locationTemporal = PolarProjectionBJ(locationTarget, 46.00, AngleBetweenPoints(locationCaster, locationTarget))
			call SetUnitPositionLoc( firtZombie, locationTemporal )
			if IsUnitAliveBJ(firtZombie) == true then
				call UnitDamageTarget(caster, firtZombie, 30, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
			endif
		endif
	endloop
	call DestroyGroup(groupZombie)
	set groupZombie = null
	set locationCaster = null
	set locationTarget = null
	set locationTemporal = null
	set firtZombie = null
endfunction
function doJump takes unit u returns nothing
	call UnitFlyUp( u, 200.00, 1200.00 )
	call PolledWait( .21 )
	call UnitFlyDown( u, 1200.00 )
endfunction
function randomGun takes unit box returns nothing
	local integer i = 0
	local effect efectUseMisteryBox
	call SetUnitInvulnerable( box, true )
	/*local integer i = 0
	local real shift
	local string text
	local texttag tag = CreateTextTag()
	loop
		set i = i + 1
		exitwhen i == 50
		set text = weapons[GetRandomInt(0, 22)]
		set shift = RMinBJ(StringLength(text) * 7, 200)
		call SetTextTagText(tag, text, .019)
		call SetTextTagPos(tag, GetUnitX(box)-shift, GetUnitY(box)+100, 16.0)
		call PolledWait(.001)
	endloop
	call PolledWait(10)
	call DestroyTextTag(tag)
	return text*/
	loop
		set i = i + 1
		exitwhen i == 50
		set efectUseMisteryBox = AddSpecialEffectTarget( modelWeapon[GetRandomInt(0, 13)], box, "overhead" )
		call DestroyEffect( efectUseMisteryBox )
		call BlzPlaySpecialEffect( efectUseMisteryBox, ANIM_TYPE_DEATH )
		call BlzSetSpecialEffectScale( efectUseMisteryBox, 0.00 )
		call PolledWait(2)
	endloop
	set efectUseMisteryBox = null
	call SetUnitInvulnerable( box, false )
endfunction
function useMysteryBox takes unit box, unit user returns nothing
	local integer idUser
	set idUser = GetConvertedPlayerId(GetOwningPlayer(user))
	if pointPlayer[idUser] >= COST_MISTERYBOX then
		call SetUnitAnimation( box, "death" )
		if ( usesMisterBox == USES_MISTERYBOX ) then
			set usesMisterBox = 0
			call SetUnitInvulnerable( box, true )
			call UnitFlyUp( box, 1500.00, 200.00 )
			call PolledWait( 10.00 )
			call UnitFlyDown( box, 200.00 )
			call SetUnitInvulnerable( box, false )
			call SetUnitPositionLoc( box, GetRectCenter(pointsMisteryBox[GetRandomInt(0, 5)]) )
		else
			call delPointInScore( COST_MISTERYBOX, user )
			set usesMisterBox = usesMisterBox + 1
			call randomGun(box)
		endif
		call SetUnitAnimation( box, "stand" )
	endif
endfunction
function createTablePoints takes nothing returns nothing
	local integer i = 1
	set tablePoints = CreateLeaderboard()
	call ForceSetLeaderboardBJ(tablePoints, GetPlayersAll())
	call LeaderboardDisplay(tablePoints, true)
	loop
		exitwhen i > players
		call LeaderboardAddItemBJ( ConvertedPlayer(i), tablePoints, GetPlayerName(ConvertedPlayer(i)), 0 )
		set i = i + 1
	endloop
endfunction
function init takes nothing returns nothing
	local integer i = 0
	local unit person
	set weapons[0]	= "KRM-262"
	set weapons[1]	= "Kuda"
	set weapons[2]	= "Sheiva"
	set weapons[3]	= "HVK-30"
	set weapons[4]	= "KN-44"
	set weapons[5]	= "M8A7"
	set weapons[6]	= "Weevil"
	set weapons[7]	= "BRM"
	set weapons[8]	= "Dingo"
	set weapons[9]	= "48 Dredge"
	set weapons[10]	= "Gorgon"
	set weapons[11]	= "Locus"
	set weapons[12]	= "Drakon"
	set weapons[13]	= "SVG-100"
	set weapons[14]	= "Man-O-War"
	set weapons[15]	= "205 Brecci"
	set weapons[16]	= "Haymaker 12"
	set weapons[17]	= "XM-53"
	set weapons[18]	= "Raygun"
	set weapons[19]	= "Thundergun"
	set weapons[20]	= "Galil"
	set weapons[21]	= "M16"
	set weapons[22]	= "Monkey Bombs"
	set modelWeapon[0] = "war3mapImported\\ak47_ByEpsilon.mdx"
	set modelWeapon[1] = "war3mapImported\\Bolt_Pistol.mdx"
	set modelWeapon[2] = "war3mapImported\\Claw.mdx"
	set modelWeapon[3] = "war3mapImported\\D9gun.mdx"
	set modelWeapon[4] = "war3mapImported\\D9gun_Portrait.mdx"
	set modelWeapon[5] = "war3mapImported\\M82.mdx"
	set modelWeapon[6] = "war3mapImported\\MP40.mdx"
	set modelWeapon[7] = "war3mapImported\\mp5_ByEpsilon.mdx"
	set modelWeapon[8] = "war3mapImported\\Plasma_Pistol.mdx"
	set modelWeapon[9] = "war3mapImported\\Premium_Bolter.mdx"
	set modelWeapon[10] = "war3mapImported\\sg552_ByEpsilon.mdx"
	set modelWeapon[11] = "war3mapImported\\SniperRifle.mdx"
	set modelWeapon[12] = "war3mapImported\\sta11.mdx"
	set modelWeapon[13] = "war3mapImported\\Suomi-konepistooli02.mdx"
	set pointsMisteryBox[0] = gg_rct_MisteryBox01
	set pointsMisteryBox[1] = gg_rct_MisteryBox02
	set pointsMisteryBox[2] = gg_rct_MisteryBox03
	set pointsMisteryBox[3] = gg_rct_MisteryBox04
	set pointsMisteryBox[4] = gg_rct_MisteryBox05
	set pointsMisteryBox[5] = gg_rct_MisteryBox06
	set regionZombie[0] = gg_rct_RegionZombie01
	set regionZombie[1] = gg_rct_RegionZombie02
	set regionZombie[2] = gg_rct_RegionZombie03
	set regionZombie[3] = gg_rct_RegionZombie04
	set regionZombie[4] = gg_rct_RegionZombie05
	call CreateUnitAtLoc( Player(PLAYER_NEUTRAL_PASSIVE), 'n001',  GetRectCenter(pointsMisteryBox[1]), 0.00 )
	set isActiveDoublePoint = false
	loop
		if ( GetPlayerSlotState( Player(players)) == PLAYER_SLOT_STATE_PLAYING ) then
			set person = CreateUnitAtLoc( Player(players), 'H002', GetPlayerStartLocationLoc(Player(players)), 0.00 )
			call GroupAddUnit( udg_grupoAliados, person )
			set players = players + 1
		endif
		set i = i + 1
		exitwhen i == MAX_PLAYERS
	endloop
	set person = null
	call PolledWait( .01 )
	call createTablePoints()
	call newRound()
endfunction
function AllRemoveBuff takes group grupo, integer hechizoId returns nothing
	local unit persona
	local group temporal = CreateGroup()
	call GroupAddGroup(grupo, temporal)
	loop
		set persona = FirstOfGroup(temporal)
		exitwhen persona == null
		call UnitRemoveAbility( persona, hechizoId )
		call GroupRemoveUnit(temporal, persona)
	endloop
	call DestroyGroup(temporal)
	set temporal = null
endfunction
function disablex2 takes nothing returns nothing
	local timer t = GetExpiredTimer()
	set isActiveDoublePoint = false
	call AllRemoveBuff( udg_grupoAliados, 'B000' )
	call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enabledx2 takes nothing returns nothing
	local timer t = CreateTimer()
	set isActiveDoublePoint = true
	call TimerStart( t, 30.00, false, function disablex2 )
	set t = null
endfunction
function isMysteryBox takes nothing returns boolean
	return ( GetUnitTypeId(GetFilterUnit()) == 'n001' )
endfunction
function getPicked takes nothing returns nothing
	call RemoveUnit( GetEnumUnit() )
endfunction
function disableFireSale takes nothing returns nothing
	local timer t = GetExpiredTimer()
	local integer i = 0
	loop
		call ForGroupBJ( GetUnitsInRectMatching(pointsMisteryBox[i], Condition(function isMysteryBox)), function getPicked )
		set i = i + 1
		exitwhen i == 6
	endloop
	call CreateUnitAtLoc( Player(PLAYER_NEUTRAL_PASSIVE), 'n001',  GetRectCenter(pointsMisteryBox[GetRandomInt(0, 5)]), 0.00 )
	call AllRemoveBuff( udg_grupoAliados, 'B002' )
	call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enableFireSale takes nothing returns nothing
	local timer t = CreateTimer()
	local integer i = 0
	loop
		call ForGroupBJ( GetUnitsInRectMatching(pointsMisteryBox[i], Condition(function isMysteryBox)), function getPicked )
		call CreateUnitAtLoc( Player(PLAYER_NEUTRAL_PASSIVE), 'n001',  GetRectCenter(pointsMisteryBox[i]), 0.00 )
		set i = i + 1
		exitwhen i == 6
	endloop
	call TimerStart( t, 30.00, false, function disableFireSale )
	set t = null
endfunction
function disableInstantKill takes nothing returns nothing
	local timer t = GetExpiredTimer()
	set isActiveInstantKill = false
	call AllRemoveBuff( udg_grupoAliados, 'B003' )
	call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enabledInstantKill takes nothing returns nothing
	local timer t = CreateTimer()
	set isActiveInstantKill = true
	call TimerStart( t, 30.00, false, function disableInstantKill )
	set t = null
endfunction
function GetUnitWithLessDistance takes unit zombie, group people returns unit
	local unit closer
	local unit person
	local real nowdistance = 0
	local real maxdistance = 0
	loop
		set person = FirstOfGroup(people)
		exitwhen person == null
		set nowdistance = DistanceBetweenPoints(GetUnitLoc(zombie), GetUnitLoc(person))
		if nowdistance > maxdistance then
			set closer = person
		endif
		call GroupRemoveUnit(people, person)
	endloop
	set person = null
	return closer
endfunction
function AttackZombie takes unit zombie, group aliade returns nothing
	local unit victim
	local group tempAliade = CreateGroup()
	call GroupAddGroup(aliade, tempAliade)
	set victim = GetUnitWithLessDistance(zombie, tempAliade)
	call IssueTargetOrder( zombie, "attack", victim )
	call DestroyGroup(tempAliade)
	set zombie = null
	set victim = null
	set tempAliade = null
endfunction
function ActionRaygun takes nothing returns nothing
endfunction
function deadAlly takes nothing returns nothing
	local timer t = GetExpiredTimer()
	call RemoveUnit(LoadUnitHandle(hashtableTimer, GetHandleId(t), 1))
	call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function decaeAlly takes unit ally returns nothing
	local timer t = CreateTimer()
	local effect efecto
	call SaveUnitHandle(hashtableTimer, GetHandleId(t), 1, ally)
	call TimerStart( t, 20.00, false, function deadAlly )
	set t = null
	call SetUnitInvulnerable( ally, true )
	//call SetUnitAnimation( ally, "death" )
	set efecto = AddSpecialEffectTarget( "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl", ally, "overhead" )
	call BlzSetSpecialEffectScale( efecto, .5 )
	call BlzSetSpecialEffectColor( efecto, 120, 120, 120 ) // Blanco
	/*call PolledWait(5)
	call BlzSetSpecialEffectColor( efecto, 244, 208, 63 ) // Amarillo
	call PolledWait(5)
	call BlzSetSpecialEffectColor( efecto, 230, 126, 34 ) // Naranja
	call PolledWait(5)
	call BlzSetSpecialEffectColor( efecto, 192, 57, 43 ) // Rojo*/
endfunction
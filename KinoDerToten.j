globals
	constant integer LIMIT_ZOMBIE		= 24
	constant integer LIMIT_WOLF			= 5
	constant integer USES_MISTERYBOX	= 2
	constant integer MAX_PLAYERS		= 4
	constant integer POINT_INSTAKILL	= 110
	constant integer TIME_BREAKROUND	= 6
	integer round = 20
	integer totalZombie
	integer inmapZombie
	integer limitCreate
	integer players = 0
	integer usesMisterBox = 0
	leaderboard tablePoints
	integer array pointPlayer
	rect array pointsMisteryBox
	boolean flagCreate
	boolean isActiveDoublePoint = false
	boolean isActiveInstantKill = false
	boolean isActivateLight = false
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
function isProbability takes real percent returns boolean
	local integer maxProbability
	set maxProbability = R2I( 100 / percent )
	if ( GetRandomInt(1, maxProbability) == 1 ) then
		return true
	endif
	return false
endfunction
function createZombie takes nothing returns nothing
	local unit unitZombie
	local integer typeZombie = 'nzom'
	if isActivateLight then
		if isProbability(10.00) then
			set typeZombie = 'ugho'
		endif
	endif
	set unitZombie = CreateUnitAtLoc( Player(4), typeZombie,  GetRandomLocInRect(gg_rct_regionZombie), 0.00 )
	call BlzSetUnitArmor( unitZombie, round )
	call SetUnitColor( unitZombie, PLAYER_COLOR_BROWN )
	call GroupAddUnitSimple( unitZombie, udg_grupoZombies )
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
	if ModuloInteger(round, 5) == 0 then
		call TriggerExecute( gg_trg_CreateWolf )
	else
		call createZombie()
	endif
endfunction
function newRound takes nothing returns nothing
	local integer addZombie
	local real waitCreate
	set round = round + 1
	set totalZombie = 0
	set inmapZombie = 0
	call LeaderboardSetLabel(tablePoints, "Ronda " + I2S(round))
	call PolledWait(TIME_BREAKROUND)
	if ModuloInteger(round, 5) == 0 then
		set totalZombie = reckonWolf(round, players)
		set waitCreate = GetRandomReal(0.00, 6.00)
		set limitCreate = LIMIT_WOLF
	else
		set totalZombie = reckonZombie(round, players)
		set waitCreate = 0
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
		call newZombie(waitCreate)
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
function doJump takes unit u returns nothing
	call UnitFlyUp( u, 200.00, 1200.00 )
	call PolledWait( .21 )
	call UnitFlyDown( u, 1200.00 )
endfunction
function randomGun takes unit box returns nothing
	local effect efectUseMisteryBox
	set efectUseMisteryBox = AddSpecialEffectTarget( "Objects\\RandomObject\\RandomObject.mdl", box, "overhead" )
	call BlzSetSpecialEffectScale( efectUseMisteryBox, .85 )
	call DestroyEffect( efectUseMisteryBox )
	call PolledWait( 5.00 )
	set efectUseMisteryBox = AddSpecialEffectTarget( "Units\\Creeps\\HeroTinkerRobot\\HeroTinkerRobot.mdl", box, "overhead" )
	call PolledWait( 15.00 )
	call DestroyEffect( efectUseMisteryBox )
	set efectUseMisteryBox = null
endfunction
function useMysteryBox takes unit box, unit user returns nothing
	if ( usesMisterBox == USES_MISTERYBOX ) then
		set usesMisterBox = 0
		call SetUnitInvulnerable( box, true )
		call UnitFlyUp( box, 1500.00, 200.00 )
		call PolledWait( 10.00 )
		call UnitFlyDown( box, 200.00 )
		call SetUnitInvulnerable( box, false )
		call SetUnitPositionLoc( box, GetRectCenter(pointsMisteryBox[GetRandomInt(0, 5)]) )
	else
		set usesMisterBox = usesMisterBox + 1
		call SetUnitInvulnerable( box, true )
		call randomGun(box)
		call SetUnitInvulnerable( box, false )
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
	set pointsMisteryBox[0] = gg_rct_MisteryBox01
	set pointsMisteryBox[1] = gg_rct_MisteryBox02
	set pointsMisteryBox[2] = gg_rct_MisteryBox03
	set pointsMisteryBox[3] = gg_rct_MisteryBox04
	set pointsMisteryBox[4] = gg_rct_MisteryBox05
	set pointsMisteryBox[5] = gg_rct_MisteryBox06
	call CreateUnitAtLoc( Player(PLAYER_NEUTRAL_PASSIVE), 'n001',  GetRectCenter(pointsMisteryBox[2]), 0.00 )
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
function disablex2 takes nothing returns nothing
	local timer t = GetExpiredTimer()
	set isActiveDoublePoint = false
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
globals
	constant integer LIMIT_ZOMBIE		= 24
	constant integer LIMIT_WOLF			= 5
	constant integer MAX_USEMISTERYBOX	= 2
	constant integer MAX_PLAYERS		= 4
	constant integer POINT_HURT			= 10
	constant integer POINT_KILL			= 100
	constant integer TIME_BREAKROUND	= 4
	integer round = 0
	integer totalzombie
	integer inmapzombie
	integer limitCreate
	integer players = 0
	integer usesMisterBox = 0
	leaderboard tablePoints
	unit misteryBox
	integer array pointPlayer
	rect array pointsMisteryBox
	boolean flagCreate
	boolean activeDoublePoint = false
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
function reckonWolf takes integer numbRound, integer numbPlayer returns integer
	local real numbWolf
	set numbWolf = ( ( numbRound * numbRound ) / ( 2 * numbRound ) ) + numbPlayer
	return R2I(numbWolf + 0.5)
endfunction
function newZombie takes real w returns nothing
	set totalzombie = totalzombie - 1
	set inmapzombie = inmapzombie + 1
	if w > 0 then
		call PolledWait(w)
	endif
	if ModuloInteger(round, 5) == 0 then
		call TriggerExecute( gg_trg_CreateWolf )
	else
		call TriggerExecute( gg_trg_CreateZombie )
	endif
endfunction
function newRound takes nothing returns nothing
	local integer addZombie
	local real waitCreate
	set round = round + 1
	set totalzombie = 0
	set inmapzombie = 0
	call LeaderboardSetLabel(tablePoints, "Ronda " + I2S(round))
	call PolledWait(TIME_BREAKROUND)
	if ModuloInteger(round, 5) == 0 then
		set totalzombie = reckonWolf(round, players)
		set waitCreate = GetRandomReal(0.00, 6.00)
		set limitCreate = LIMIT_WOLF
	else
		set totalzombie = reckonZombie(round, players)
		set waitCreate = 0
		set limitCreate = LIMIT_ZOMBIE
	endif
	if totalzombie > limitCreate then
		set addZombie = limitCreate
	else
		set addZombie = totalzombie
	endif	
	set flagCreate = false
	loop
		exitwhen addZombie <= 0
		call newZombie(waitCreate)
		set addZombie = addZombie - 1
	endloop
	set flagCreate = true
endfunction
function deadZombie takes unit zombie returns nothing
	set inmapzombie = inmapzombie - 1
	if totalzombie > 0 and flagCreate == true then
		if inmapzombie < limitCreate then
			call newZombie(6.00)
		endif
	endif
	if totalzombie == 0 and inmapzombie == 0 then
		call newRound()
	endif
endfunction
function actionThunderGun takes unit c, group gt returns nothing
	local location locationCaster
	local location locationTarget
	local location locationTemporal
	local unit f
	local group gz = CreateGroup()
	set locationCaster = GetUnitLoc(c)
	call GroupAddGroup(gt, gz)
	loop
		set f = FirstOfGroup(gz)
		exitwhen(f == null)
		call GroupRemoveUnit(gz, f)
		if GetOwningPlayer(f) == Player(4) then
			set locationTarget = GetUnitLoc(f)
			set locationTemporal = PolarProjectionBJ(locationTarget, 36.00, AngleBetweenPoints(locationCaster, locationTarget))
			call SetUnitPositionLoc( f, locationTemporal )
			call UnitDamageTargetBJ( c, f, 5, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL )
		endif
	endloop
	call DestroyGroup(gz)
	set gz = null
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
function useMysteryBox takes unit user returns nothing
	local effect efectUseMisteryBox
	if ( usesMisterBox == MAX_USEMISTERYBOX ) then
		set usesMisterBox = 0
		call SetUnitInvulnerable( misteryBox, true )
		call UnitFlyUp( misteryBox, 1500.00, 200.00 )
		call PolledWait( 10.00 )
		call UnitFlyDown( misteryBox, 200.00 )
		call SetUnitInvulnerable( misteryBox, false )
		call SetUnitPositionLoc( misteryBox, GetRectCenter(pointsMisteryBox[GetRandomInt(0, 5)]) )
	else
		set usesMisterBox = usesMisterBox + 1
		call SetUnitInvulnerable( misteryBox, true )
		set efectUseMisteryBox = AddSpecialEffectTarget( "Objects\\RandomObject\\RandomObject.mdl", misteryBox, "overhead" )
		call BlzSetSpecialEffectScale( efectUseMisteryBox, .85 )
		call DestroyEffect( efectUseMisteryBox )
		call PolledWait( 5.00 )
		set efectUseMisteryBox = AddSpecialEffectTarget( "Units\\Creeps\\HeroTinkerRobot\\HeroTinkerRobot.mdl", misteryBox, "overhead" )
		call PolledWait( 15.00 )
		call DestroyEffect( efectUseMisteryBox )
		call SetUnitInvulnerable( misteryBox, false )
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
function addPointInScore takes unit zombie returns nothing
	local integer addPoint
	local unit aliade
	local integer idAliade
	if ( IsUnitDeadBJ(zombie) == true ) then
		set addPoint = POINT_KILL
		set aliade = GetKillingUnitBJ()
	else
		set addPoint = POINT_HURT
		set aliade = GetAttacker()
	endif
	if activeDoublePoint then
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
function init takes nothing returns nothing
	local integer i = 0
	set pointsMisteryBox[0] = gg_rct_MisteryBox01
	set pointsMisteryBox[1] = gg_rct_MisteryBox02
	set pointsMisteryBox[2] = gg_rct_MisteryBox03
	set pointsMisteryBox[3] = gg_rct_MisteryBox04
	set pointsMisteryBox[4] = gg_rct_MisteryBox05
	set pointsMisteryBox[5] = gg_rct_MisteryBox06
	set misteryBox = CreateUnitAtLoc( Player(PLAYER_NEUTRAL_PASSIVE), 'h003',  GetRectCenter(pointsMisteryBox[2]), 0.00 )
	set activeDoublePoint = false
	loop
		if ( GetPlayerSlotState( Player(players)) == PLAYER_SLOT_STATE_PLAYING ) then
			call CreateUnitAtLoc( Player(players), 'H002', GetPlayerStartLocationLoc(Player(players)), 0.00 )
			call GroupAddUnitSimple( GetLastCreatedUnit(), udg_grupoAliados )
			set players = players + 1
		endif
		set i = i + 1
		exitwhen i == MAX_PLAYERS
	endloop
	call PolledWait( .1 )
	call createTablePoints()
	call newRound()
endfunction
function disablex2 takes nothing returns nothing
	local timer t = GetExpiredTimer()
	set activeDoublePoint = false
	call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enabledx2 takes nothing returns nothing
	local timer t = CreateTimer()
	set activeDoublePoint = true
	call TimerStart( t, 30.00, false, function disablex2 )
	set t = null
endfunction
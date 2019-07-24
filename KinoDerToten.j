globals
	constant integer LIMIT_ZOMBIE		= 36
	constant integer LIMIT_HELLHOUNDS	= 2
	constant integer LAPSE_HELLHOUNDS	= 4
	constant integer USES_MISTERYBOX	= 10
	constant integer MAX_PLAYERS		= 24
	constant integer POINT_INSTAKILL	= 110
	constant integer TIME_BREAKROUND	= 6
	constant integer COST_MISTERYBOX	= 900
	constant integer ID_MISTERYBOX		= 'B000'
	constant integer ID_ZOMBIE			= 'nzom'
	constant integer ID_HELLHOUNDS		= 'osw1'
	constant integer ID_CRAWLER			= 'ugho'
	constant integer ID_ALIADE			= 'H000'
	constant integer ID_MONKEYBOMB		= 'ncg1'
	constant integer ID_PERK			= 'BTrx'
	constant integer ID_BARREL			= 'LTbr'
	constant integer NUMBER_ZERO		= 0
	constant integer LIMIT_MOVESPEED	= 522
	constant real    LAPSE_CAPTURE		= 10.00
	constant real    LAPSE_FLICKER		= 5.00
	integer round			= 20
	integer usesMisterBox	= 0
	integer players			= 0
	integer totalZombie
	integer inmapZombie
	integer limitCreate
	integer tempCountObstacle = 0
	leaderboard tablePoints
	rect array pointsMisteryBox
	rect array regionZombie
	boolean flagCreate
	boolean isActiveDoublePoint	= false
	boolean isActiveInstantKill	= false
	boolean isActivateLight		= false
	boolean isTimeHellhounds	= false
	boolean isDebugger			= true
	string array weapons
	string array aliasAliades
	destructable array objectCarpenter
	destructable array perk
	ally array allys
	hashtable timerHashtable = InitHashtable()
	bonus extraBonus
endglobals
function Alert takes string message returns nothing
	if isDebugger then
		call BJDebugMsg(message)
	endif
endfunction
function createMisteryBox takes location geo returns nothing
		local destructable d
		set d = CreateDestructableLoc( ID_MISTERYBOX, geo, GetRandomDirectionDeg(), 1, 0 )
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
function disableDoublePoint takes nothing returns nothing
	local timer t = GetExpiredTimer()
	set isActiveDoublePoint = false
		call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enabledDoublePoint takes nothing returns nothing
	local timer t = CreateTimer()
	set isActiveDoublePoint = true
	call TimerStart( t, 30.00, false, function disableDoublePoint )
	set t = null
endfunction
function isMysteryBox takes nothing returns boolean
	return ( GetUnitTypeId(GetFilterUnit()) == ID_MISTERYBOX )
endfunction
function getPicked takes nothing returns nothing
	call RemoveUnit( GetEnumUnit() )
endfunction
function GroupRemoveAll takes group g returns nothing
	local unit u
	loop
		set u = FirstOfGroup(g)
		exitwhen u == null
		call GroupRemoveUnit(g, u)
		call RemoveUnit( u )
		set u = null
	endloop
endfunction
function disableFireSale takes nothing returns nothing
	local timer t = GetExpiredTimer()
	call GroupRemoveAll(udg_grupoMisteryBox)
	call createMisteryBox(GetRectCenter(pointsMisteryBox[GetRandomInt(0, 5)]))
		call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enableFireSale takes nothing returns nothing
	local timer t = CreateTimer()
	local integer i = 0
	call GroupRemoveAll(udg_grupoMisteryBox)
	loop
		call createMisteryBox(GetRectCenter(pointsMisteryBox[i]))
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
function disableNuke takes nothing returns nothing
	local timer t = GetExpiredTimer()
		call PauseTimer( t )
	call DestroyTimer( t )
	set t = null
endfunction
function enabledNuke takes nothing returns nothing
	local timer t = CreateTimer()
	local unit u
	loop
		set u = FirstOfGroup(udg_grupoZombies)
		exitwhen u == null
		call KillUnit( u )
		call DestroyEffect( AddSpecialEffectTargetUnitBJ( "origin", u, "Abilities\\Spells\\Human\\FlameStrike\\FlameStrike1.mdl" ) )
		call GroupRemoveUnit(udg_grupoZombies, u)
		set u = null
	endloop
	call TimerStart( t, 1.00, false, function disableNuke )
	set t = null
endfunction
struct bonus
	static integer  idbonus
	static effect   fxbonus
	static integer  sizeBonus
	static location place
	static boolean  isAvailable
	static timer    timeDestroy
	static timer    timeFlicker
	static trigger  trigCapture
	static trigger  trigFlicker
	string array mdbonus[5]
	static method isAliade takes nothing returns boolean
		return IsUnitInGroup(GetTriggerUnit(), udg_grupoAliados)
	endmethod
	method drop takes nothing returns nothing
		set this.isAvailable = true
		call DestroyEffect(this.fxbonus)
		set this.fxbonus = null
		call PauseTimer(this.timeDestroy)
		call DestroyTimer(this.timeDestroy)
		set this.timeDestroy = null
		call DisableTrigger(this.trigCapture)
		set this.trigCapture = null
	endmethod
	static method create takes nothing returns bonus
		local thistype this = allocate()
		set this.isAvailable = true
		set this.sizeBonus = 1
		set this.mdbonus[0] = "Objects\\InventoryItems\\runicobject\\runicobject.mdl"
		set this.mdbonus[1] = "Objects\\InventoryItems\\CrystalShard\\CrystalShard.mdl"
		set this.mdbonus[2] = "Objects\\InventoryItems\\BundleofLumber\\BundleofLumber.mdl"
		set this.mdbonus[3] = "Objects\\InventoryItems\\Glyph\\Glyph.mdl"
		set this.mdbonus[4] = "Objects\\InventoryItems\\PotofGold\\PotofGold.mdl"
		return this
	endmethod
	static method disableFlicker takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local thistype this = allocate()
		call DestroyTimer( .timeFlicker )
		call DisableTrigger( .trigFlicker )
		set .timeFlicker = null
		set .trigFlicker = null
		call this.drop()
	endmethod
	static method doFlicker takes nothing returns nothing
		if .sizeBonus == 1 then
			set .sizeBonus = -1
		else
			set .sizeBonus = 1
		endif
		call BlzSetSpecialEffectScale( .fxbonus, .sizeBonus)
	endmethod
	static method doDestroy takes nothing returns nothing
		local thistype this = allocate()
		if GetExpiredTimer() == null then
			call this.doEffect()
			call this.drop()
		else
			call PauseTimer( .timeDestroy )
			call DestroyTimer( .timeDestroy )
			set .trigFlicker = CreateTrigger()
			call TriggerRegisterTimerEventPeriodic( .trigFlicker, 0.2 )
			call TriggerAddAction( .trigFlicker, function thistype.doFlicker )
			set .timeFlicker = CreateTimer()
			call TimerStart( .timeFlicker, LAPSE_FLICKER, false, function thistype.disableFlicker )
		endif
	endmethod
	private method add takes nothing returns nothing
		local string model = this.mdbonus[this.idbonus]
		set this.fxbonus = AddSpecialEffectLoc(model, this.place)
		set this.isAvailable = false
		set this.trigCapture = CreateTrigger()
		call EnableTrigger(this.trigCapture)
		call TriggerRegisterEnterRectSimple( this.trigCapture, GetRectFromCircleBJ( this.place, 40 ) )
		call TriggerAddCondition( this.trigCapture, Condition( function thistype.isAliade ) )
		call TriggerAddAction( this.trigCapture, function thistype.doDestroy )
		call EnableTrigger( this.trigCapture )
		set this.timeDestroy = CreateTimer()
		call TimerStart( this.timeDestroy, LAPSE_CAPTURE, false, function thistype.doDestroy )
	endmethod
	method doEffect takes nothing returns nothing
		if this.idbonus == 0 then
			call Alert("Fire Sale")
			call enableFireSale()
		elseif this.idbonus == 1 then
			call Alert("Insta Kill")
			call enabledInstantKill()
		elseif this.idbonus == 2 then
			call Alert("Max Ammo")
		elseif this.idbonus == 3 then
			call Alert("Nuke")
			call enabledNuke()
		elseif this.idbonus == 4 then
			call Alert("Double Point")
			call enabledDoublePoint()
		else
			call Alert("No found POWERUP #" + I2S(this.idbonus))
		endif
	endmethod
	method random takes nothing returns nothing
		if this.isAvailable then
			set this.idbonus = GetRandomInt(0,4)
			call this.add()
		endif
	endmethod
	method maxAmmo takes nothing returns nothing
		if this.isAvailable then
			set this.idbonus = 2
			call this.add()
		endif
	endmethod
endstruct
struct ally
	unit marine
	integer point
	integer totalDead
	integer totalKill
	boolean isDying
	effect effTarget
	static method create takes unit marine returns ally
		local ally new = allocate()
		set new.point = 0
		set new.totalDead = 0
		set new.totalKill = 0
		set new.isDying = false
		set new.marine = marine
		call UnitAddAbility( marine, 'A002' )
		call UnitAddAbility( marine, 'ACtb' )
		call UnitAddAbility( marine, 'A00K' )
		call UnitAddAbility( marine, 'A00L' )
		call UnitAddAbility( marine, 'ACcv' )
		call UnitAddAbility( marine, 'A006' )
		call UnitAddAbility( marine, 'ANcl' )
		call UnitAddAbility( marine, 'A00B' )
		call UnitAddAbility( marine, 'A100' )
		call BlzSetHeroProperName( marine, aliasAliades[GetRandomInt(0,7)] )
		call BlzSetUnitMaxMana( marine, 5000 )
		call SetUnitManaBJ( marine, 5000 )
		return new
	endmethod
	method addPoint takes integer point returns nothing
		set this.point = this.point + point
	endmethod
	method delPoint takes integer point returns nothing
		set this.point = this.point - point
	endmethod
endstruct
function removeMonkey takes nothing returns nothing
	local unit u
	local timer removeTime
	set removeTime = GetExpiredTimer()
	set u = LoadUnitHandle(timerHashtable, GetHandleId(removeTime), 1)
	call KillUnit( u )
	call RemoveUnit( u )
	call PauseTimer( removeTime )
	call DestroyTimer( removeTime )
	set removeTime = null
	set u = null
endfunction
function useMonkeyBomb takes unit caster, location target returns nothing
	local effect fx
	local unit u
	local real i
	local real startAngle
	local timer removeTime = CreateTimer()
	call Alert("Is Monkey Bomb")
	set startAngle = AngleBetweenPoints(GetUnitLoc(caster), target)
	call Alert(":(x,y)" + "(" + I2S(R2I(GetLocationX(target))) + "," + I2S(R2I(GetLocationY(target))) + ")")
	set u = CreateUnit( GetOwningPlayer(caster), ID_MONKEYBOMB, GetLocationX(target), GetLocationY(target), startAngle )
	call UnitAddAbility(u, 'Amrf')
    call UnitRemoveAbility(u, 'Amrf')
    call IssuePointOrder(u, "move", GetLocationX(target), GetLocationY(target))
	call SaveUnitHandle(timerHashtable, GetHandleId(removeTime), 1, u)
	call TimerStart( removeTime, 4.00, false, function removeMonkey )
	set removeTime = null
	endfunction
function useAbility takes integer a, unit caster, location target returns nothing
	call Alert("Cast ability: " + GetAbilityName(a))
	if a == 'A00B' then
		call useMonkeyBomb(caster, target)
	endif
endfunction
function addDestructibles takes nothing returns nothing
	local destructable obstacle = GetEnumDestructable()
			if GetDestructableLife(obstacle) > 0 then
			call Alert("Obstaculo encontrado: " + GetDestructableName(obstacle))
			set tempCountObstacle = tempCountObstacle + 1
			set objectCarpenter[tempCountObstacle] = obstacle
		endif
	endfunction
function detectObstacle takes real radius, location loc returns nothing
	set tempCountObstacle = 0
	call Alert("Escaneando obtaculos en un radio de " + I2S(R2I(radius)))
	call EnumDestructablesInCircleBJ( radius, loc, function addDestructibles )
endfunction
function registerAllDestructibles takes nothing returns nothing
	set tempCountObstacle = 0
	call EnumDestructablesInRectAll( GetPlayableMapRect(), function addDestructibles )
endfunction
function activeLightSwitch takes nothing returns nothing
	call Alert("Luz Activada!")
	call SetDestructableAnimationBJ( perk[0], "stand alternate" )
	set isActivateLight = true
endfunction
function reckonZombie takes integer numbRound, integer numbPlayer returns integer
	local real numbZombie
	set numbZombie = (numbPlayer * 0.01) * (numbRound * numbRound) + (numbPlayer * 0.1) * numbRound + numbPlayer
	return R2I(numbZombie + 3.5)
endfunction
function isProbability takes integer percent returns boolean
	return GetRandomInt( 1, 100 ) <= percent
endfunction
function DistanceBetweenWidget takes widget wA, widget wB returns real
	local real dx = GetWidgetX(wB) - GetWidgetX(wA)
	local real dy = GetWidgetY(wB) - GetWidgetY(wA)
	return SquareRoot(dx * dx + dy * dy)
endfunction
function GetDestructableWithLessDistance takes unit zombie returns widget
	local widget barrel
	local real nowdistance = 0
	local real mindistance = 0
	local integer i = 0
	loop
		exitwhen i == tempCountObstacle
		set i = i + 1
		set nowdistance = DistanceBetweenPoints(GetUnitLoc(zombie), GetDestructableLoc(objectCarpenter[i]))
		if ( nowdistance < mindistance ) or ( mindistance == 0 ) then
			set mindistance = nowdistance
			set barrel = objectCarpenter[i]
		endif
	endloop
	return barrel
endfunction
function GetUnitWithLessDistance takes unit zombie, group people returns widget
	local widget aliade
	local unit pickUnit
	local real nowdistance = 0
	local real mindistance = 0
	loop
		set pickUnit = FirstOfGroup(people)
		set nowdistance = DistanceBetweenPoints(GetUnitLoc(zombie), GetUnitLoc(pickUnit))
		call Alert("Distancia Aliado: " + I2S(R2I(nowdistance)))
		exitwhen ( pickUnit == null ) or ( nowdistance <= 95.00 )
		call GroupRemoveUnit(people, pickUnit)
		if ( nowdistance < mindistance ) or ( mindistance == 0 ) then
			call Alert("Nuevo registro de distancia mas corta: " + I2S(R2I(nowdistance)))
			set mindistance = nowdistance
			set aliade = pickUnit
		endif
		set pickUnit = null
	endloop
	return aliade
endfunction
function AttackZombie takes unit zombie, group aliades returns nothing
	local widget victim
	local group tempAliade = CreateGroup()
	call GroupAddGroup(aliades, tempAliade)
	call detectObstacle(95.00, GetUnitLoc(zombie))
	if tempCountObstacle > 0 then
		call Alert("Numero de obtaculos: " + I2S(tempCountObstacle))
		set victim = GetDestructableWithLessDistance(zombie)
	else
		call Alert("No hay obstaculos")
		set victim = GetUnitWithLessDistance(zombie, tempAliade)
	endif
	call DestroyGroup(tempAliade)
	set tempAliade = null
	call IssueTargetOrder( zombie, "attack", victim )
	set victim = null
	set zombie = null
endfunction
function createZombie takes nothing returns nothing
	local unit unitZombie
	local integer zombieMovespeed
	local integer zombieHealPoint
	if isActivateLight and isProbability(20) then
		set unitZombie = CreateUnitAtLoc( Player(25), ID_CRAWLER, GetRandomLocInRect(regionZombie[GetRandomInt(0,3)]), 0.00 )
		call AddSpecialEffectTarget( "Abilities\\Spells\\Undead\\PlagueCloud\\PlagueCloudCaster.mdl", unitZombie, "foot" )
	else
		set unitZombie = CreateUnitAtLoc( Player(25), ID_ZOMBIE, GetRandomLocInRect(regionZombie[GetRandomInt(0,3)]), 0.00 )
	endif
	//call SetUnitPathing( unitZombie, false )
	set zombieMovespeed = R2I(GetUnitDefaultMoveSpeed(unitZombie) + (round * 0.05))
	set zombieHealPoint = R2I(BlzGetUnitMaxHP(unitZombie) + (round * 5))
	if zombieMovespeed >= LIMIT_MOVESPEED then
		set zombieMovespeed = LIMIT_MOVESPEED
	endif
	call SetUnitMoveSpeed( unitZombie, zombieMovespeed)
	call BlzSetUnitMaxHP( unitZombie, zombieHealPoint)
	call SetUnitLifePercentBJ( unitZombie, 100 )
	call GroupAddUnitSimple( unitZombie, udg_grupoZombies )
endfunction
function calTimeHellhounds takes integer ronda returns boolean
	return ModuloInteger(ronda, LAPSE_HELLHOUNDS) == NUMBER_ZERO
endfunction
function createHellhounds takes nothing returns nothing
	local unit unitHellhound
	local location randomPoint
	local unit randomUnit
	set randomUnit = GroupPickRandomUnit(udg_grupoAliados)
	set randomPoint = OffsetLocation(GetUnitLoc(randomUnit), GetRandomReal(-200.00, 200.00), GetRandomReal(-200.00, 200.00))
	call AddSpecialEffectLocBJ( randomPoint, "Abilities\\Weapons\\Bolt\\BoltImpact.mdl" )
	call AddSpecialEffectLocBJ( randomPoint, "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl" )
	set unitHellhound = CreateUnitAtLoc( Player(25), ID_HELLHOUNDS, randomPoint, AngleBetweenPoints(randomPoint, GetUnitLoc(randomUnit)) )
	call AddSpecialEffectTarget( "Environment\\LargeBuildingFire\\LargeBuildingFire1.mdl", unitHellhound, "foot" )
	call GroupAddUnitSimple( unitHellhound, udg_grupoZombies )
	call BlzSetUnitMaxHP( unitHellhound, R2I(BlzGetUnitMaxHP(unitHellhound) + ( (round + players ) * 10) ))
	call SetUnitLifePercentBJ( unitHellhound, 100 )
endfunction
function reckonHellhounds takes integer numbRound, integer numbPlayer returns integer
	local real numbHellhounds
	set numbHellhounds = ( ( numbRound * numbRound ) / ( 2 * numbRound ) ) + numbPlayer
	return R2I(numbHellhounds + 0.5)
endfunction
function newEnemy takes real wait returns nothing
	set totalZombie = totalZombie - 1
	set inmapZombie = inmapZombie + 1
	if wait > 0 then
		call PolledWait(wait)
	endif
	if isTimeHellhounds then
		call PolledWait(GetRandomReal(0, 2))
		call createHellhounds()
	else
		call createZombie()
	endif
endfunction
function newRound takes nothing returns nothing
	local integer addZombie
	set round = round + 1
	set totalZombie = NUMBER_ZERO
	set inmapZombie = NUMBER_ZERO
	call LeaderboardSetLabel(tablePoints, "Ronda " + I2S(round))
	call PolledWait(TIME_BREAKROUND)
	set isTimeHellhounds = calTimeHellhounds(round)
	if isTimeHellhounds then
		set totalZombie = reckonHellhounds(round, players)
		set limitCreate = LIMIT_HELLHOUNDS * players
	else
		set totalZombie = reckonZombie(round, players)
		set limitCreate = R2I(LIMIT_ZOMBIE + ( players * 0.2 ))
	endif
	if totalZombie > limitCreate then
		set addZombie = limitCreate
	else
		set addZombie = totalZombie
	endif	
	set flagCreate = false
	call EnableTrigger( gg_trg_AttractAliade )
	loop
		exitwhen addZombie <= NUMBER_ZERO
		call newEnemy(NUMBER_ZERO)
		set addZombie = addZombie - 1
	endloop
	set flagCreate = true
endfunction
function removeZombie takes nothing returns nothing
	local timer removeTime = GetExpiredTimer()
	call RemoveUnit( LoadUnitHandle(timerHashtable, GetHandleId(removeTime), 1) )
	call PauseTimer( removeTime )
	call DestroyTimer( removeTime )
	set removeTime = null
endfunction
function deadZombie takes unit zombie returns nothing
	//local timer removeTime = CreateTimer()
	//call SaveUnitHandle(timerHashtable, GetHandleId(removeTime), 1, zombie)
	//call TimerStart( removeTime, 4.00, false, function removeZombie )
	//set removeTime = null

	set inmapZombie = inmapZombie - 1
	call GroupRemoveUnitSimple( zombie, udg_grupoZombies )
	if totalZombie > 0 and flagCreate == true and inmapZombie < limitCreate then
		call newEnemy(6.00)
	endif
	if totalZombie == 0 and inmapZombie == 0 then
		if isTimeHellhounds then
			set extraBonus.place = GetUnitLoc(zombie)
			call extraBonus.maxAmmo()
		endif
		call DisableTrigger( gg_trg_AttractAliade )
		call newRound()
	else
		if isProbability(1) then
			set extraBonus.place = GetUnitLoc(zombie)
			call extraBonus.random()
		endif
	endif
	call RemoveUnit(zombie)
	set zombie = null
endfunction
function IdOwner takes unit u returns integer
	return GetPlayerId(GetOwningPlayer(u))
endfunction
function addPointInScore takes integer point, unit aliade returns nothing
	local integer i = IdOwner(aliade)
	local ally a = allys[i]
	if isActiveInstantKill then
		set point = POINT_INSTAKILL
		call KillUnit(GetAttackedUnitBJ())
	endif
	if isActiveDoublePoint then
		set point = point * 2
	endif
	call a.addPoint(point)
	call SetPlayerStateBJ( GetOwningPlayer(aliade), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(aliade), PLAYER_STATE_RESOURCE_GOLD) + point )
	call LeaderboardSetPlayerItemValueBJ( GetOwningPlayer(aliade), tablePoints, a.point )
	call LeaderboardSortItemsByValue(tablePoints, false)
	call CreateTextTagUnitBJ( "+" + I2S(point), aliade, 0, 10, 100, 100, 0.00, 0 )
	call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
	call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 0.60 )
	call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90 )
	call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.10 )
endfunction
function delPointInScore takes integer point, unit aliade returns nothing
	local ally a = allys[IdOwner(aliade)]
	call a.delPoint(point)
	call SetPlayerStateBJ( GetOwningPlayer(aliade), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(aliade), PLAYER_STATE_RESOURCE_GOLD) - point )
	call LeaderboardSetPlayerItemValueBJ( GetOwningPlayer(aliade), tablePoints, a.point )
	call LeaderboardSortItemsByValue(tablePoints, false)
	call DestroyEffect( AddSpecialEffectTarget( "UI\\Feedback\\GoldCredit\\GoldCredit.mdl", aliade, "overhead" ) )
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
			set locationTarget = GetUnitLoc(firtZombie)
			set locationTemporal = PolarProjectionBJ(locationTarget, GetRandomInt(50,200), AngleBetweenPoints(locationCaster, locationTarget))
			call SetUnitPositionLoc( firtZombie, locationTemporal )
			if IsUnitAliveBJ(firtZombie) == true then
				call UnitDamageTarget(caster, firtZombie, 30, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
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
	call UnitFlyUp( u, 240.00, 1800.00 )
	call PolledWait( .003 )
	call UnitFlyDown( u, 900.00 )
	call SetUnitPathing( u, true )
endfunction
function randomGun takes unit box returns nothing
	local integer i = 0
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
		call TriggerSleepAction(.0005)
	endloop
	call PolledWait(10)
	call DestroyTextTag(tag)
endfunction
function useMysteryBox takes unit box, unit user returns nothing
	local ally a = allys[IdOwner(user)]
	if a.point >= COST_MISTERYBOX then
		call SetUnitAnimation( box, "death" )
		call SetUnitInvulnerable( box, true )
		if ( usesMisterBox == USES_MISTERYBOX ) then
			set usesMisterBox = 0
			call UnitFlyUp( box, 1500.00, 200.00 )
			call PolledWait( 10.00 )
			call UnitFlyDown( box, 200.00 )
			call SetUnitPositionLoc( box, GetRectCenter(pointsMisteryBox[GetRandomInt(0, 5)]) )
		else
			call delPointInScore( COST_MISTERYBOX, user )
			set usesMisterBox = usesMisterBox + 1
			call randomGun(box)
		endif
		call SetUnitInvulnerable( box, false )
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
	set aliasAliades[0] = "Alex Mason"
	set aliasAliades[1] = "Viktor Reznov"
	set aliasAliades[2] = "Edward Richtofen"
	set aliasAliades[3] = "Frank Woods"
	set aliasAliades[4] = "Nikolai Belinski"
	set aliasAliades[5] = "Dimitri Petrenko"
	set aliasAliades[6] = "Jason Hudson"
	set aliasAliades[7] = "Takeo Masaki"
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
	set perk[0] = CreateDestructableLoc( ID_PERK, GetRectCenter(GetPlayableMapRect()), GetRandomDirectionDeg(), 1, 0 )
	set extraBonus = bonus.create()
	call createMisteryBox(GetRectCenter(pointsMisteryBox[1]))
	set isActiveDoublePoint = false
	loop
		if ( GetPlayerSlotState( Player(players)) == PLAYER_SLOT_STATE_PLAYING ) then
			set person = CreateUnitAtLoc( Player(players), ID_ALIADE, GetPlayerStartLocationLoc(Player(players)), 0.00 )
			call SelectUnitForPlayerSingle( person, Player(players) )
			call GroupAddUnit( udg_grupoAliados, person )
			set allys[players] = ally.create(person)
			set players = players + 1
		endif
		set i = i + 1
		exitwhen i == MAX_PLAYERS
	endloop
	set person = null
	call PolledWait( .001 )
	call createTablePoints()
	call newRound()
endfunction
function deadAlly takes nothing returns nothing
	local timer deathTime = GetExpiredTimer()
	local unit aliado = LoadUnitHandle(timerHashtable, GetHandleId(deathTime), 1)
	local integer i = IdOwner(aliado)
	local ally a = allys[i]
	if a.isDying then
		call KillUnit( a.marine )
	endif
	call DestroyTimer( deathTime )
	set deathTime = null
endfunction
function decaeAlly takes unit aliado returns nothing
	local timer deathTime = CreateTimer()
	local integer i = IdOwner(aliado)
	local integer bj_forLoopAIndex
	local ally a = allys[i]
	call GroupRemoveUnitSimple( aliado, udg_grupoAliados )
	if IsUnitGroupEmptyBJ(udg_grupoAliados) then
		set bj_forLoopAIndex = 1
		loop
			exitwhen bj_forLoopAIndex > GetPlayers()
			call CustomDefeatBJ( ConvertedPlayer(bj_forLoopAIndex), "Game Over" )
			set bj_forLoopAIndex = bj_forLoopAIndex + 1
		endloop
	endif
	set a.isDying = true
	call SaveUnitHandle(timerHashtable, GetHandleId(deathTime), 1, a.marine)
	call GroupRemoveUnit(udg_grupoAliados, a.marine)
	call TimerStart( deathTime, 60.00, false, function deadAlly )
				endfunction
function reviveAlly takes unit aliado returns nothing
	local integer i = IdOwner(aliado)
	local ally a = allys[i]
	set a.isDying = false
	call GroupAddUnit(udg_grupoAliados, a.marine)
	call DestroyEffect( a.effTarget )
	call SetUnitAnimation( a.marine, "stand" )
	call SetUnitInvulnerable( a.marine, false )
	call PauseUnitBJ( false, a.marine )
endfunction
function adjustingAngle takes real angle returns real
	if angle > 360 then
		set angle = angle - 360
	endif
	if angle < 0 then
		set angle = angle + 360
	endif
	return angle
endfunction
function minAngleThunder takes real angle returns real
	return adjustingAngle(angle - 45)
endfunction
function maxAngleThunder takes real angle returns real
	return adjustingAngle(angle + 45)
endfunction
function isThisOnRadar takes real angle, real left, real right, real middle returns boolean
	local real adjust
	set adjust = 45
	if ( middle >= 360 - adjust and middle <= 360 ) or ( middle <= adjust and middle >= 0 ) then
		return ( angle >= left and angle < 360 ) or ( angle <= right and angle >= 0 )
	else
		return ( angle >= left ) and ( angle <= right )
	endif
endfunction
function useThunderGun takes unit caster, location target returns nothing
	local real angle
	local real angleAdjust
	local real angleLeft
	local real angleRight
	local real angleUnit
	local effect effectThunder
	local unit affectedUnit
	local group tempAreaGroup = CreateGroup()
	set angle = AngleBetweenPoints(GetUnitLoc(caster), target)
	set angleAdjust = angle + 180
	set angleLeft = minAngleThunder(angleAdjust)
	set angleRight = maxAngleThunder(angleAdjust)
	set tempAreaGroup = GetUnitsInRangeOfLocAll(900.00, GetUnitLoc(caster))
	loop
		set affectedUnit = FirstOfGroup(tempAreaGroup)
		exitwhen affectedUnit == null
		call GroupRemoveUnit(tempAreaGroup, affectedUnit)
		if IsUnitEnemy(affectedUnit, GetOwningPlayer(caster)) then
			set angleUnit = AngleBetweenPoints(GetUnitLoc(caster), GetUnitLoc(affectedUnit)) + 180
			if isThisOnRadar(angleUnit, angleLeft, angleRight, angleAdjust)then
				//call SetUnitPathing( affectedUnit, false )
				call GroupAddUnit(udg_groupAreaUnitsThunder, affectedUnit)
			endif
		endif
	endloop
	call EnableTrigger( gg_trg_EffectThunderGun )
	set effectThunder = AddSpecialEffectLocBJ( GetUnitLoc(caster), "Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl" )
	call BlzSetSpecialEffectColor( effectThunder, 160, 160, 160 )
	call DestroyEffect( effectThunder )
	call BlzSetSpecialEffectScale( effectThunder, 6.00 )
	call BlzSetSpecialEffectYaw( effectThunder, Deg2Rad(45.00) )
	call BlzSetSpecialEffectPitch( effectThunder, Deg2Rad(( angle + 90.00 )) )
	call DestroyEffect( effectThunder )
	set effectThunder = null
endfunction
function AttrackAliade takes nothing returns nothing
	local unit zombie
	local group tempGroup
	if CountUnitsInGroup(udg_grupoZombies) > 0 or CountUnitsInGroup(udg_grupoAliados) > 0 then
		set tempGroup = CreateGroup()
		call GroupAddGroup(udg_grupoZombies, tempGroup)
		loop
			set zombie = FirstOfGroup(tempGroup)
			call GroupRemoveUnit(tempGroup, zombie)
			exitwhen zombie == null
			call AttackZombie(zombie, udg_grupoAliados)
			set zombie = null
		endloop
	endif
	set zombie = null
	set tempGroup = null
endfunction
function doBarricade takes location l returns nothing
	local destructable d
	set d = CreateDestructableLoc( ID_BARREL, l, GetRandomDirectionDeg(), 1, 0 )
endfunction
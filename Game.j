struct Game
	integer round
	integer allies
	integer zombies
	static method create takes nothing returns Game
		local integer i = 0
		local Game data = Game.allocate()
		set data.round = 0
		set data.allies = 4
		return data
	endmethod
	private method ZombiesPerRound takes nothing returns nothing
		set this.zombies = ( this.round + 6 ) * this.allies
		set this.zombies = R2I( ( (this.allies * 0.01) * (this.round * this.round) + (this.allies * 0.1) * this.round + this.allies ) + 5.5 )
	endmethod
	public method nextRound takes nothing returns nothing
		set this.round = this.round + 1
		call ZombiesPerRound()
	endmethod
endstruct
struct Ally
	integer points = 0
	integer deads = 0
	integer kills = 0
endstruct
struct Zombie
	location site
	player owner
	static method create takes string type returns unit
		local Zombie data = Zombie.allocate()
		local rect array tempsite
		local integer i = 0
		set tempsite[0] = gg_rct_RegionZombie01
		set tempsite[1] = gg_rct_RegionZombie02
		set tempsite[2] = gg_rct_RegionZombie03
		set tempsite[3] = gg_rct_RegionZombie04
		set tempsite[4] = gg_rct_RegionZombie05
		set data.site = GetRandomLocInRect(tempsite[GetRandomInt(0,5)])
		set data.owner = Player(4)
		return CreateUnitAtLoc( data.owner, type, data.site, 0.00 )
	endmethod
endstruct
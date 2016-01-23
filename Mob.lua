require "Player"

Mob = {}
Mob.__index = Mob

setmetatable(Mob, {
  __index  = Player,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Mob:initMob()
	self.x = 200
	self.y = 200
	self.speed = 200
	self.hit_point = 20
	self.attack_point = 2
	self.img = nil	
end

function Mob:_init()
	self:initMob()
end

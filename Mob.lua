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

function Player:_init()
	self.x = 200
	self.y = 200
	self.speed = 200
	self.img = love.graphics.newImage("data/octocat.png")
end

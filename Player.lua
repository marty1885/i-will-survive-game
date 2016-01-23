require "Object"

Player = {}
Player.__index = Player

setmetatable(Player, {
  __index  = Object,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Player:initPlayer()
	self:initObject()
	self.x = 200
	self.y = 200
	self.speed = 200
	self.img = love.graphics.newImage("data/octocat.png")
end

function Player:_init()
	self:initPlayer()
end

require "Object"

Bullet = {}
Bullet.__index = Bullet

setmetatable(Bullet, {
  __index  = Object,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,})

function Bullet:initBullet(path)
	self:initObject(path)
	self.x = 200
	self.y = 200
	self.speed = 200
	self.hit_point = 1
	self.attack_point = 10
end

function Bullet:_init(path)
	self:initBullet(path)
end

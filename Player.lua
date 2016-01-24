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

function Player:initPlayer(path)
	self:initObject(path)
	self.x = 200
	self.y = 200
	self.speed = 200
	self.hit_point = 100
	self.attack_point = 2
	self.items = {}
end

function Player:_init(path)
	self:initPlayer(path)
end

function Player:attacked(attack_point)
	self.hit_point = self.hit_point - attack_point
	if self.hit_point <= 0 then
		return false
	else
		return true
	end
end

function Player:receiveItem(item)
	table.insert(self.items, item)
end

function Player:getItems()
	return self.items
end

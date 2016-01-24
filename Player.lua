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
	self.quadImage = {}
end

function Player:loadQuad(path0,path1,path2,path3)
	self.quadImage[0] = Object(path0).img
	self.quadImage[1] = Object(path1).img
	self.quadImage[2] = Object(path2).img
	self.quadImage[3] = Object(path3).img
end

function Player:update()
	vx,vy = self.body:getLinearVelocity()
	if vx > vy then
		if vx > 0 then
			self.img = self.quadImage[3]
		else
			self.img = self.quadImage[2]
		end
	else
		if vy > 0 then
			self.img = self.quadImage[0]
		else
			self.img = self.quadImage[1]
		end
	end
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

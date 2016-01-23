Object = {}
Object.__index = Object

setmetatable(Object, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

Object_Types = {
	Object = "Object",
	Player = "Player",
	Mob = "Mob",
	Weapon = "Weapon",
	Bullet = "Bullet",
	Item = "Item",
}

function Object:loadImage(path)
	self.img = love.graphics.newImage(path)
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()
end

function Object:initObject()
	self.x = 1
	self.y = 1
	self.speed = 0
	self.width = 32
	self.height = 32
end

function Object:_init()
	self:initObject()
end

function Object:enablePhysics(id, isStatic)
	type = nil
	if isStatic then
		type = "static"
	else
		type = "dynamic"
	end

	self.body = love.physics.newBody(world, self.x, self.y, type)
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setUserData(id)
	return self.fixture
end

function Object:updateCoordinate()
	self.x = self.body:getX()-self.width/2
	self.y = self.body:getY()-self.height/2
end

function Object:setCoordinate(x, y)
	self.x = x
	self.y = y
end

function Object:setSize(w, h)
	self.width = w
	self.height = h
end

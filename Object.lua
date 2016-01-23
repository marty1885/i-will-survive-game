Object = {}
Object.__index = Object

setmetatable(Object, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Object:initObject()
	self.x = 1
	self.y = 1
	self.speed = 0
	self.width = 32
	self.height = 32
	self.img = nil
end

function Object:_init()
	self:initObject()
end

function Object:enablePhysics(id, isStatic)
	print(self.width)

	type = nil
	if isStatic then
		type = "static"
	else
		type = "dynamic"
	end

	self.body = love.physics.newBody(world,self.x,self.y,type)
	self.shape = love.physics.newRectangleShape(self.width,self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setRestitution(0.1)
	self.fixture:setUserData(id)
end

function Object:updateCoordinate()
	self.x = self.body:getX()-self.width/2
	self.y = self.body:getY()-self.height/2
end

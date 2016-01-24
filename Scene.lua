require "Object"

Scene = {}
Scene.__index = Scene

setmetatable(Scene, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Scene:clear()
	for i, obj in ipairs(self.scene) do
		self.fixture[obj]:getBody():destroy()
	end
	self.scene = {}
end

function Scene:initScene()
	self.scene = {}
	self.fixture = {}
	self.wallImage = nil
	self.width = 0
	self.height = 0
end

function Scene:getSize()
	return self.width * self.wallImage:getWidth(), self.height * self.wallImage:getHeight()
end

function Scene:createBorder(width, height)
	self.width = width
	self.height = height
	for i=0, height do
		scene:addWall(0,i)
		scene:addWall(width,i)
	end

	for i=0, width do
		scene:addWall(i,0)
		scene:addWall(i,height)
	end
end

function Scene:addObject(obj, type)
	local size = table.getn(self.scene)
	self.scene[size+1] = obj
	return self.scene[size+1]:enablePhysics(type, true)
end

function Scene:addWall(x, y)
	local size = table.getn(self.scene)
	self.scene[size+1] = Object("")
	self.scene[size+1]:setImage(self.wallImage)
	self.scene[size+1]:setCoordinate(x*self.wallImage:getWidth(),y*self.wallImage:getHeight())
	self.fixture[self.scene[size+1]] = self.scene[size+1]:enablePhysics(Object_Types.Object, true)
end

function Scene:loadWallImage(path)
	self.wallImage = love.graphics.newImage(path)
end

function Scene:drawAll()
	for i, obj in ipairs(self.scene) do
		love.graphics.draw(obj.img, obj.x-obj.img:getWidth()/2, obj.y-obj.img:getHeight()/2)
	end
end

function Scene:_init()
	self:initScene()
end

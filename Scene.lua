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

function Scene:initScene()
	self.scene = {}
	self.wallImage = nil
end

function Scene:addWall(x, y)
	local size = table.getn(self.scene)
	self.scene[size+1] = Object("")
	self.scene[size+1]:setImage(self.wallImage)
	self.scene[size+1]:setCoordinate(x*self.wallImage:getWidth(),y*self.wallImage:getHeight())
	self.scene[size+1]:enablePhysics(Object_Types.Object, true)
end

function Scene:loadWallImage(path)
	self.wallImage = love.graphics.newImage(path)
end

function Scene:drawAll()
	for i, obj in ipairs(self.scene) do
		love.graphics.draw(self.wallImage, obj.x-self.wallImage:getWidth()/2, obj.y-self.wallImage:getHeight()/2)
	end
end

function Scene:_init()
	self:initScene()
end

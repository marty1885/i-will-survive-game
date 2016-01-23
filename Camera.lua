require "Object"

Camera = {}
Camera.__index = Camera

setmetatable(Camera, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Camera:initCamera()
	self.x = 0
	self.y = 0
	self.width = 1200
	self.height = 800
	self.zoomX = 1.0
	self.zoomY = 1.0
	self.offsetX = 0
	self.offsetY = 0
end

local function valueInRance(value, min, max)
	return value >= min and value <= max
end

function Camera:apply()
	love.graphics.push()
	love.graphics.scale(self.zoomX, self.zoomY)
	love.graphics.translate(self.x + self.offsetX, self.offsetY + self.y)
end

function Camera:deapply()
	love.graphics.pop()
end

function Camera:intersects(obj)

	local objX = obj.x
	local objW = obj.width
	local objY = obj.y
	local objH = obj.height

	objX = objX * self.zoomX
	objW = objW * self.zoomX
	objY = objY * self.zoomY
	objH = objH * self.zoomY
	objX = objX + self.offsetX
	objY = objY + self.offsetY

	xOverlap = valueInRance(self.x, objX, objX + objW) or
        	valueInRance(objX, self.x, self.x + self.width)

	yOverlap = valueInRance(self.y, objY, objY + objH) or
        	valueInRance(objY, self.y, self.y + self.height);

	return xOverlap and yOverlap

end

function Camera:_init()
	self:initCamera()
end

function Camera:centerOn(obj)
	self.offsetX = -obj.x - obj.width/2 + self.width/2
	self.offsetY = -obj.y - obj.height/2 + self.height/2
end

function Camera:getTopRight()
	return self.x,self.y
end

function Camera:getSize()
	return self.width, self.height
end

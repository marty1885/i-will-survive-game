Object = {}
Object.__index = Object

setmetatable(Object, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Object:_init()
	self.x = 1
	self.y = 1
	self.speed = 0
	self.width = 1
	self.height = 1
	self.img = nil
end

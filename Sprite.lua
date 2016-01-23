Sprite = {}
Sprite.__index = Sprite

setmetatable(Sprite, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Sprite:_init()
	self.x = 1
	self.y = 1
	self.speed = 0
	self.width = 1
	self.height = 1
	self.img = nil
end

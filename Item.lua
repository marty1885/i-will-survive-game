require "Object"

Item = {}
Item.__index = Item

setmetatable(Item, {
  __index  = Object,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Item:initItem(path)
	self:initObject(path)
	self.hit_point = 100
end

function Item:_init(path)
	self:initItem(path)
end

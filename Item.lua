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

function Player:_init()
end

Viewport = {}
Viewport.__index = Viewport

setmetatable(Viewport, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Viewport:_init()
end

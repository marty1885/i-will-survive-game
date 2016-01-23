Weapon = {}
Weapon.__index = Weapon

setmetatable(Weapon, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Weapon:_init()
end

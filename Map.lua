require "Sprite"

Map = {}
Map.__index = Map

setmetatable(Map, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Map:_init()
	self.width = 1200
	self.height = 800

	self.map = {}          -- create the matrix
	for i=1,self.width do
		self.map[i] = {}
		for j=1,self.height do
			self.map[i][j] = Sprite()
		end
	end
end

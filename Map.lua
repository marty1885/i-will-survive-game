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
	self.width = 64
	self.height = 64

	self.map = {}          -- create the matrix
	for i=1,self.width do
		self.map[i] = {}
		for j=1,self.height do
			self.map[i][j] = Sprite()
			self.map[i][j]:loadImage("data/grass.png")
		end
	end
end

debug = true

world = nil

package.path = package.path .. ';./?.lua;'
require "Map"
require "Object"
require "Player"
require "Viewport"
require "Weapon"
require "Camera"

player = nil
sprite = nil
camera = nil


function love.load()
	map = Map()
	sprite = Object()
	sprite:loadImage("data/grass.png")
	player = Player()

	world = love.physics.newWorld(0,0,true)

	player.x = 200
	player.y = 200

	player.width = 64
	player.height = 64

	sprite.x = 400
	sprite.y = 500
	sprite:enablePhysics("s",true)
	player:enablePhysics("p",false)

	camera = Camera()
end

function love.update(dt)
	world:update(dt)

	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	if love.keyboard.isDown('left','a') then
		player.body:applyForce(-100,0)
	end

	if love.keyboard.isDown('right','d') then
		player.body:applyForce(100,0)
	end

	if love.keyboard.isDown('up', 'w') then
		player.body:applyForce(0,-100)
	end

	if love.keyboard.isDown('down', 's') then
		player.body:applyForce(0,100)
	end

	player:updateCoordinate()
	sprite:updateCoordinate()
end

function love.draw(dt)
	camera:centerOn(player)
	camera:apply()

	love.graphics.draw(sprite.img, sprite.x, sprite.y)

	if camera:intersects(player) then
		love.graphics.draw(player.img, player.x, player.y)
	end
	camera:deapply()
	love.graphics.print("FPS = " ..love.timer.getFPS(), 0, 0)
end

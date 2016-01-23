debug = true

world = nil

package.path = package.path .. ';./?.lua;'
require "Map"
require "Object"
require "Player"
require "Viewport"
require "Weapon"

player = nil
sprite = nil


function love.load()
	map = Map()
	sprite = Object()
	sprite.img = love.graphics.newImage("data/grass.png")
	player = Player()

	world = love.physics.newWorld(0,0,true)

	player.x = 400
	player.y = 400

	player.width = 64
	player.height = 64

	sprite.x = 400
	sprite.y = 500
	sprite:enablePhysics("s",true)
	player:enablePhysics("p",false)
end

function love.update(dt)
	world:update(dt)

	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	if love.keyboard.isDown('left','a') then
		player.x = player.x - (player.speed*dt)
	end

	if love.keyboard.isDown('right','d') then
		player.x = player.x + (player.speed*dt)
	end

	if love.keyboard.isDown('up', 'w') then
		player.y = player.y - (player.speed*dt)
	end

	if love.keyboard.isDown('down', 's') then
		player.y = player.y + (player.speed*dt)
		player.body:applyForce(0,100)
	end

	player:updateCoordinate()
	sprite:updateCoordinate()
end

function love.draw(dt)
	love.graphics.draw(sprite.img, sprite.x, sprite.y)
	love.graphics.draw(player.img, player.x, player.y)
end

debug = true

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
end

function love.update(dt)
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
	end
end

function love.draw(dt)
	love.graphics.draw(sprite.img, 200, 200)
	love.graphics.draw(player.img, player.x, player.y)
end

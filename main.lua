debug = true

world = nil

package.path = package.path .. ';./?.lua;'
require "Map"
require "Object"
require "Player"
require "Viewport"
require "Weapon"
require "Mob"

player = nil
sprite = nil
mob = nil

players = {}
mobs = {}

function love.load()
	map = Map()
	sprite = Object()
	sprite:loadImage("data/grass.png")
	player = Player()
	player:loadImage("data/octocat.png")
	mob = Mob()
	mob:loadImage("data/free-bsd-32.png")

	-- Create World
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	-- Create Player
	player:setCoordinate(400, 400)
	player:setSize(64, 64)
	players[player:enablePhysics(Object_Types.Player, false)] = player

	-- Create Map
	sprite:setCoordinate(400, 500)
	sprite:enablePhysics(Object_Types.Object, true)

	-- Create Mob
	mob:setCoordinate(400, 300)
	mob:setSize(32, 32)
	mobs[mob:enablePhysics(Object_Types.Mob, true)] = mob
	
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
	mob:updateCoordinate()
end

function love.draw(dt)
	love.graphics.draw(sprite.img, sprite.x, sprite.y)
	love.graphics.draw(player.img, player.x, player.y)
	love.graphics.draw(mob.img, mob.x, mob.y)
end

function beginContact(a, b, coll)
	if a:getUserData() ~= b:getUserData() then
		local player_fixture = nil
		local collide_fixture = nil
		if a:getUserData() == Object_Types.Player then
			player_fixture = a
			collide_fixture = b
		elseif b:getUserData() == Object_Types.Player then
			player_fixture = b
			collide_fixture = a
		end

		local collide_user_data = collide_fixture:getUserData()
		if collide_user_data == Object_Types.Object then
			-- do nothing
		elseif collide_user_data == Object_Types.Weapon then
			-- Get weapon
		elseif collide_user_data == Object_Types.Mob then
			players[player_fixture]:attacked(mobs[collide_fixture].attack_point)
			print(players[player_fixture].hit_point)
		end		
	end				 
end
 
function endContact(a, b, coll)

end
 
function preSolve(a, b, coll)
	
end
 
function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
end

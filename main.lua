debug = true

world = nil

package.path = package.path .. ';./?.lua;'
require "Map"
require "Object"
require "Player"
require "Viewport"
require "Weapon"
require "Camera"
require "Mob"

player = nil
sprite = nil
camera = nil
mob = nil

players = {}
mobs = {}

function love.load()
	--map = Map()
	sprite = Object()
	sprite:loadImage("data/grass.png")
	player = Player()
	player.x = 200
	player.y = 200
	sprite.x = 400
	sprite.y = 500
	camera = Camera()
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
	--sprite:enablePhysics(Object_Types.Object, true)

	-- Create Mob
	mob:setCoordinate(400, 300)
	mob:setSize(32, 32)
	mobs[mob:enablePhysics(Object_Types.Mob, true)] = mob

end

local function mod(a,b)
	return  a - math.floor(a/b)*b
end

local function clamp(n,min,max)
	return math.min(math.max(n,min),max)
end

function love.update(dt)
	world:update(dt)

	local vx,vy = player.body:getLinearVelocity()
	--clamp speed
	local maxVelosity = 180
	player.body:setLinearVelocity(clamp(vx,-maxVelosity,maxVelosity),
		clamp(vy,-maxVelosity,maxVelosity))
	vx,vy = player.body:getLinearVelocity()

	local force = 1000
	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	if love.keyboard.isDown('left','a') then
		player.body:applyForce(-force,0)
	end

	if love.keyboard.isDown('right','d') then
		player.body:applyForce(force,0)
	end

	if love.keyboard.isDown('up', 'w') then
		player.body:applyForce(0,-force)
	end

	if love.keyboard.isDown('down', 's') then
		player.body:applyForce(0,force)
	end

	player:updateCoordinate()
	--sprite:updateCoordinate()
	mob:updateCoordinate()
end

function love.draw(dt)
	camera:centerOn(player)
	camera:apply()

	local x,y = camera:getTopRight()
	local w,h = camera:getSize()
	x = x - camera.offsetX
	y = y - camera.offsetY
	local spriteWidth = sprite.width * camera.zoomX
	local spriteHeight = sprite.height * camera.zoomY
	local startX = x - mod(x,spriteWidth)
	local startY = y - mod(y,spriteHeight)

	local yCoord = startY
	while yCoord <= y+h do
		local xCoord = startX
		while xCoord <= x+w do
			love.graphics.draw(sprite.img, xCoord, yCoord)
			xCoord = xCoord + spriteWidth
		end
		yCoord = yCoord + spriteHeight
	end

	if camera:intersects(mob) then
		love.graphics.draw(mob.img, mob.x, mob.y)
	end

	if camera:intersects(player) then
		love.graphics.draw(player.img, player.x, player.y)
	end

	camera:deapply()
	love.graphics.print("FPS = " ..love.timer.getFPS(), 0, 0)
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

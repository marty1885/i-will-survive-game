debug = true

world = nil

package.path = package.path .. ';./?.lua;'
require "Object"
require "Player"
require "Viewport"
require "Weapon"
require "Camera"
require "Mob"
require "Bullet"

player = nil
sprite = nil
camera = nil
mob = nil

-- Hash table for referencing from fixture
players = {}
mobs = {}
bullets = {}

canShoot = true
canShootTimerMax = 0.5
canShootTimer = canShootTimerMax

function love.load()
	--map = Map()
	sprite = Object()
	sprite:loadImage("data/grass.png")
	camera = Camera()

	-- Create World
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	-- Create Player
	player = Player()
	player:loadImage("data/octocat.png")
	player:setCoordinate(400, 400)
	player:setSize(64, 64)
	players[player:enablePhysics(Object_Types.Player, false)] = player

	-- Create Map
	sprite:setCoordinate(400, 500)
	--sprite:enablePhysics(Object_Types.Object, true)

	-- Create Mob
	mob = Mob()
	mob:loadImage("data/free-bsd-32.png")
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

	-- Bullet
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end
	if love.keyboard.isDown('lctrl') and canShoot then
		new_bullet = Bullet()
		new_bullet:loadImage("data/bullet_2_blue.png")
		new_bullet:setCoordinate(player.body:getX(), player.body:getY() - player.height)
		new_bullet:setSize(10, 26)
		bullets[new_bullet:enablePhysics(Object_Types.Bullet, false)] = new_bullet
		new_bullet.body:applyForce(0, -1000)
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	player:updateCoordinate()
	for fixture, mob in pairs(mobs) do
		mob:updateCoordinate()
	end
	-- update the positions of bullets
	for fixture, bullet in pairs(bullets) do
		bullet:updateCoordinate()
		if bullet.y < 0 then -- remove bullets when they pass off the screen
			bullets[fixture] = nil
			fixture:getBody():destroy()
		end
	end
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

	if camera:intersects(player) then
		love.graphics.draw(player.img, player.x, player.y)
	end

	for fixture, mob in pairs(mobs) do
		love.graphics.draw(mob.img, mob.x, mob.y)
	end

	-- Draw Bullets
	for fixture, bullet in pairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	camera:deapply()


	-- Debug information
	love.graphics.print("FPS = " ..love.timer.getFPS(), 0, 0)
	love.graphics.print("HP = " ..player.hit_point, 0, 12)
end

function beginContact(a, b, coll)
	if a:getUserData() ~= b:getUserData() then
		local player_fixture = nil
		local collide_fixture = nil
		local bullet_fixture = nil
		if a:getUserData() == Object_Types.Player then
			player_fixture = a
			collide_fixture = b
		elseif b:getUserData() == Object_Types.Player then
			player_fixture = b
			collide_fixture = a
		end

		if a:getUserData() == Object_Types.Bullet then
			bullet_fixture = a
			collide_fixture = b
		elseif b:getUserData() == Object_Types.Bullet then
			bullet_fixture = b
			collide_fixture = a
		end

		local collide_user_data = collide_fixture:getUserData()

		-- Player Collision
		if player_fixture ~= nil then
			if collide_user_data == Object_Types.Object then
				-- do nothing
			elseif collide_user_data == Object_Types.Weapon then
				-- Get weapon
			elseif collide_user_data == Object_Types.Mob then
				players[player_fixture]:attacked(mobs[collide_fixture].attack_point)
			end
		end

		-- Bullet Collision
		if bullet_fixture ~= nil then
			if collide_user_data == Object_Types.Mob then
				if not mobs[collide_fixture]:attacked(bullets[bullet_fixture].attack_point) then
					mobs[collide_fixture] = nil
					collide_fixture:getBody():destroy()
				end
			end
			bullets[bullet_fixture] = nil
			bullet_fixture:getBody():destroy()
		end
	end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

end

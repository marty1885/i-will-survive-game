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
require "Scene"

player = nil
sprite = nil
camera = nil
--mob = nil
scene = nil
bulletImage = nil
bulletSound = nil

-- Hash table for referencing from fixture
players = {}
mobs = {}
bullets = {}

canShoot = true
canShootTimerMax = 0.15
canShootTimer = canShootTimerMax

local function mod(a,b)
	return  a - math.floor(a/b)*b
end

local function clamp(n,min,max)
	return math.min(math.max(n,min),max)
end

function love.load()
	--map = Map()
	sprite = Object("data/grass.png")
	camera = Camera()

	-- Create World
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	-- create scene
	scene = Scene()
	scene:loadWallImage("data/stone.png")
	scene:createBorder(32,32)

	-- Create Player
	player = Player("data/octocat.png")
	player:setCoordinate(16*32, 16*32)
	player:setSize(64, 64)
	players[player:enablePhysics(Object_Types.Player, false)] = player

	-- Create Map
	sprite:setCoordinate(400, 500)
	--sprite:enablePhysics(Object_Types.Object, true)


	bulletImage = love.graphics.newImage("data/bullet_2_blue.png")
	bulletSound = love.audio.newSource("data/bullet.wav")

	-- Create Mob
	math.randomseed(os.time())
	scene_width, scene_height = scene:getSize()
	local grid_divisor = 7
	local width_offset = scene_width / grid_divisor
	local height_offset = scene_height / grid_divisor
	local mob_start_x = player.x - width_offset * 0.5 * (grid_divisor - 1)
	local mob_start_y = player.y - height_offset * 0.5 * (grid_divisor - 1)
	print(width_offset, height_offset)
	print(mob_start_x, mob_start_y)
	for i = 0, grid_divisor - 1 do
		for j = 0, grid_divisor - 1 do
			local mob = Mob("data/free-bsd-32.png")
			mob:setCoordinate(mob_start_x + i * width_offset + width_offset / 2 * (math.random() - 0.5),
							  mob_start_y + j * height_offset + height_offset / 2 * (math.random() - 0.5))
			mob:setSize(32, 32)
			mobs[mob:enablePhysics(Object_Types.Mob, true)] = mob
		end
	end
end


function updateHashmap(map)
	for fixture, obj in pairs(map) do
		obj:updateCoordinate()
	end
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
	if love.mouse.isDown(1) and canShoot then
		local mouseX,mouseY = love.mouse.getPosition()
		local relativeX = mouseX - player.body:getX() - camera.offsetX
		local relativeY = mouseY - player.body:getY() - camera.offsetY
		local length = math.sqrt(relativeX*relativeX + relativeY*relativeY)
		normalX = relativeX / length
		normalY = relativeY / length
		bulletXCoord = normalX * player.width
		bulletYCoord = normalY * player.height

		new_bullet = Bullet("")
		new_bullet:setImage(bulletImage)
		new_bullet:setCoordinate(player.body:getX() + bulletXCoord, player.body:getY() + bulletYCoord)
		new_bullet:setSize(10, 26)
		bullets[new_bullet:enablePhysics(Object_Types.Bullet, false)] = new_bullet
		new_bullet.body:applyForce(10000*normalX, 10000*normalY)
		new_bullet.direction = math.atan2(normalX,normalY)
		new_bullet.body:setAngle(math.atan2(normalX,normalY))
		canShoot = false
		canShootTimer = canShootTimerMax
		--love.audio.play(bulletSound)
	end

	player:updateCoordinate()

	updateHashmap(mobs)
	-- update the positions of bullets
	updateHashmap(bullets)
end

function drawHashmap(map)
	for fixture, obj in pairs(map) do
		love.graphics.draw(obj.img, obj.x, obj.y,-obj.direction)
	end
end

function drawAllHashmap()
	drawHashmap(mobs)
	-- Draw Bullets
	drawHashmap(bullets)
end

function darwBackground()
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
end

function love.draw(dt)
	camera:centerOn(player)
	camera:apply()

	darwBackground()
	scene:drawAll(camera)
	-- darw player
	love.graphics.draw(player.img, player.x, player.y)
	drawAllHashmap()
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
				if not players[player_fixture]:attacked(mobs[collide_fixture].attack_point) then
					print("You are dead")
				end
			end
		end

		-- Bullet Collision
		if bullet_fixture ~= nil then
			if collide_user_data == Object_Types.Mob and bullets[bullet_fixture] ~= nil then
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

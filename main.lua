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
require "Item"

player = nil
sprite = nil
camera = nil
--mob = nil
scene = nil
bulletImage = nil
bulletSound = nil
shader = nil
canvas = nil
bgm = nil
deathSound = nil
godMode = false

-- Hash table for referencing from fixture
players = {}
player_kill_count = 0
mobs = {}
grid_divisor = 10
MAX_MOBS_COUNT = 100
mobs_total_count = 0
mob_speed = 100

bullets = {}
items = {}

canMobRespawn = true
canMobRespawnTimerMax = 0.38
canMobRespawnTimer = canMobRespawnTimerMax

canShoot = true
canShootTimerMax = 0.1
canShootTimer = canShootTimerMax

local function mod(a,b)
	return  a - math.floor(a/b)*b
end

local function clamp(n,min,max)
	return math.min(math.max(n,min),max)
end

function love.load()
	--map = Map()
	sprite = Object("data/stone.png")
	camera = Camera()

	-- Create World
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	-- create scene
	scene = Scene()
	scene:loadWallImage("data/stone.png")
	scene:createBorder(128,128)

	-- Create Player
	player = Player("data/ro.png")
	player:loadQuad("data/ro0.png","data/ro1.png","data/ro2.png","data/ro3.png")
	player:setCoordinate(scene.width / 2 * 32, scene.height / 2 * 32)
	-- player:setSize(32, 32)
	players[player:enablePhysics(Object_Types.Player, false)] = player

	-- Create Map
	sprite:setCoordinate(400, 500)
	--sprite:enablePhysics(Object_Types.Object, true)

	canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

	shader = love.graphics.newShader[[

	vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
	{
		vec3 col = Texel(tex, tc).xyz;
		col *= smoothstep(1,0,length(vec2(0.5,0.5)-tc))*smoothstep(1,0,length(vec2(0.5,0.5)-tc));

		return vec4(col,1);
	}
	]]


	bulletImage = love.graphics.newImage("data/bullet_2_blue.png")
	bulletSound = love.audio.newSource("data/bullet.wav")

	bgm = love.audio.newSource("data/BGM.mp3")
	deathSound = love.audio.newSource("data/kill.wav")
	love.audio.play(bgm)

	-- Initialize Mobs
	math.randomseed(os.time())

	-- Create Trees
	scene_width, scene_height = scene:getSize()
	local width_offset = scene_width / grid_divisor
	local height_offset = scene_height / grid_divisor

	local total_num_trees = 180
	for i = 1, total_num_trees do
		local i = math.random(0, grid_divisor - 1)
		local j = math.random(0, grid_divisor - 1)
		local tree_start_x = scene_width / 2 - width_offset * 0.5 * (grid_divisor - 1)
		local tree_start_y = scene_height / 2 - height_offset * 0.5 * (grid_divisor - 1)
		tree = nil
		if math.random(2) == 1 then
			tree = Item('data/Tree1.png')
		else
			tree = Item('data/Tree2.png')
		end
		tree:setCoordinate(tree_start_x + i * width_offset + width_offset / 2 * (math.random() - 0.5),
		 			tree_start_y + j * height_offset + height_offset / 2 * (math.random() - 0.5))

		scene:addObject(tree, Object_Types.Item)
	end

	--item = Item("data/chest.png")
	--item:setCoordinate(player.x - 100, player.y)
	--item:setSize(32, 32)
	--items[item:enablePhysics(Object_Types.Item, true)] = item
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



	local friction = 2
	local sx = 1*friction
	local sy = 1*friction
	if vx < 0 then
		sx = -1*friction
	end

	if vy < 0 then
		sy = -1*friction
	end
	-- friction
	vax = vx - sx
	vay = vy - sy
	if(vax*vx <= 0) then
		vax = 0
	end

	if(vay*vy <= 0) then
		vay = 0
	end

	player.body:setLinearVelocity(vax,vay)


	local force = 3000
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

	if love.keyboard.isDown('[') then
		mob_speed = mob_speed - 5
	end

	if love.keyboard.isDown(']') then
		mob_speed = mob_speed + 5
	end

	if love.keyboard.isDown('9') then
		canShootTimerMax = canShootTimerMax + 0.01
	end

	if love.keyboard.isDown('0') then
		canShootTimerMax = canShootTimerMax - 0.01
	end

	if love.keyboard.isDown('g') then
		player.hit_point = 10000
		godMode = true
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
		love.audio.play(bulletSound)
	end

	-- Create Mob
	canMobRespawnTimer = canMobRespawnTimer - (1 * dt)
	if canMobRespawnTimer < 0 then canMobRespawn = true end
	scene_width, scene_height = scene:getSize()
	local width_offset = scene_width / grid_divisor
	local height_offset = scene_height / grid_divisor
	local mob_start_x = scene_width / 2 - width_offset * 0.5 * (grid_divisor - 1)
	local mob_start_y = scene_height / 2 - height_offset * 0.5 * (grid_divisor - 1)
	if mobs_total_count < MAX_MOBS_COUNT and canMobRespawn then
		local i = math.random(0, grid_divisor - 1)
		local j = math.random(0, grid_divisor - 1)
		local mob = nil
		local random_num = math.random(3)
		if random_num == 1 then
			mob = Mob("data/slime0.png")
			mob.hit_point = 30
		elseif random_num == 2 then
			mob = Mob("data/slime1.png")
			mob.hit_point = 40
		elseif random_num == 3 then
			mob = Mob("data/slime2.png")
			mob.hit_point = 50
		end

		mob:setCoordinate(mob_start_x + i * width_offset + width_offset / 2 * (math.random() - 0.5),
						  mob_start_y + j * height_offset + height_offset / 2 * (math.random() - 0.5))
		-- mob:setSize(32, 32)
		mobs[mob:enablePhysics(Object_Types.Mob, false)] = mob
		mobs_total_count = mobs_total_count + 1
		MAX_MOBS_COUNT = MAX_MOBS_COUNT + 1
		canMobRespawn = false
		canMobRespawnTimer = canMobRespawnTimerMax
	end

	player:updateCoordinate()

	for fixture, mob in pairs(mobs) do
		local relative_x = player.body:getX() - mob.body:getX()
		local relative_y = player.body:getY() - mob.body:getY()
		local length = math.sqrt(math.pow(relative_x, 2) + math.pow(relative_y, 2))
		local normal_x = relative_x / length
		local normal_y = relative_y / length
		mob.body:setLinearVelocity(mob_speed * normal_x, mob_speed * normal_y)
		mob:updateCoordinate()
	end
	-- update the positions of bullets
	updateHashmap(bullets)
	updateHashmap(items)

	player:update()
end

function drawHashmap(map)
	for fixture, obj in pairs(map) do
		love.graphics.draw(obj.img, obj.x, obj.y,-obj.direction)
	end
end

function drawAllHashmap()
	drawHashmap(mobs)
	drawHashmap(bullets)
	drawHashmap(items)
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


	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		darwBackground()
		love.graphics.draw(player.img, player.x, player.y)
		drawAllHashmap()
		scene:drawAll(camera)
	love.graphics.setCanvas()
	love.graphics.setShader(shader)

	-- darw player
	--drawHashmap(mobs)

	camera:deapply()
	love.graphics.draw(canvas)

	love.graphics.setShader()

	-- Debug information
	love.graphics.print("FPS = " ..love.timer.getFPS(), 0, 0)
	love.graphics.print("HP = " ..player.hit_point, 0, 12)
	love.graphics.print("Kill Count = " ..player_kill_count, 0, 24)
	love.graphics.print("Player Item count = " ..table.getn(player:getItems()), 0, 36)
	love.graphics.print("PS : Lua sucks for writing an entire game engine. LOL", 0, 60)
end

function beginContact(a, b, coll)
	if a:getUserData() ~= b:getUserData() then
		local player_fixture = nil
		local collide_fixture = nil
		local bullet_fixture = nil
		local mob_fixture = nil
		if a:getUserData() == Object_Types.Player then
			player_fixture = a
			collide_fixture = b
		elseif b:getUserData() == Object_Types.Player then
			player_fixture = b
			collide_fixture = a
		elseif a:getUserData() == Object_Types.Bullet then
			bullet_fixture = a
			collide_fixture = b
		elseif b:getUserData() == Object_Types.Bullet then
			bullet_fixture = b
			collide_fixture = a
		elseif a:getUserData() == Object_Types.Mob then
			mob_fixture = a
			collide_fixture = b
		elseif b:getUserData() == Object_Types.Mob then
			mob_fixture = b
			collide_fixture = a
		end

		local collide_user_data = collide_fixture:getUserData()

		-- Player Collision
		if player_fixture ~= nil then
			if collide_user_data == Object_Types.Object then
				-- do nothing
			elseif collide_user_data == Object_Types.Weapon then
				-- Get weapon
			elseif collide_user_data == Object_Types.Item then
				--player:receiveItem(items[collide_fixture])
				--items[collide_fixture] = nil
				--collide_fixture:getBody():destroy()
			elseif collide_user_data == Object_Types.Mob then
				if mobs[collide_fixture] ~= nil and
				not players[player_fixture]:attacked(mobs[collide_fixture].attack_point) then
					if not godMode then
						love.event.push('quit')
					end
				end
			end
		end

		-- Bullet Collision
		if bullet_fixture ~= nil then
			if collide_user_data == Object_Types.Mob and bullets[bullet_fixture] ~= nil then
				if not mobs[collide_fixture]:attacked(bullets[bullet_fixture].attack_point) then
					mobs[collide_fixture] = nil
					collide_fixture:getBody():destroy()
					mobs_total_count = mobs_total_count - 1
					player_kill_count = player_kill_count + 1
					--love.audio.play(deathSound)
				end
			end
			if collide_user_data ~= Object_Types.Bullet then
				bullets[bullet_fixture] = nil
				bullet_fixture:getBody():destroy()
			end
		end

		-- Mob Collision
		if mob_fixture ~= nil then

		end
	end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

end

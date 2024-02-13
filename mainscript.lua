Config = {
	Map = "nanskip.red_voxel",

	Items = {

		"nanskip.red_voxel",
		"nanskip.conv_conveyor",
		"nanskip.conv_mine",
		"nanskip.conv_generator",
		"nanskip.conv_selection",
		"nanskip.conv_grass",
		"nanskip.conv_ore_coal",
		"nanskip.conv_wire",
		"nanskip.conv_mine_v2",
		"nanskip.conv_ore_copper",
		"nanskip.conv_copper_turret",
	},
}

config = {
	mapSize = { 100, 100 },
}

Client.OnStart = function()
	loadShapes()
end

Client.Tick = function(dt)
	if fpsChecked then
		tick(dt)
	else
		checkFps(dt)
	end
end

load = function()
	loadEverything()
	ui = require("uikit")

	base = Shape(Items.nanskip.conv_generator)
	base.Position = Number3(config.mapSize[1], 3, config.mapSize[2]) * 5 / 2
	base.Scale = 2
	base:SetParent(World)
	base.Physics = PhysicsMode.Trigger
	base.isBase = true
	base.Shadow = true
	moveCursortimer = 0

	globalHealth = 100

	moveX, moveY = 0, 0
	Camera:SetModeFree()
	Camera.Position = Number3(config.mapSize[1], 20, config.mapSize[2] - 10) * 5 / 2
	Camera.Rotation = Rotation(1, 0, 0)
	selectedItem = "none"
	roundTimer = 0
	roundEnd = 15
	roundTime = 15
	multiplier = 2
	avgFPS = 0
	roundTime = roundTime + 10
	numberOfEnemies = 5
	multiplier = 1.1
	map = {}
	mapBuildings = {}

	if Client.IsMobile then textSize = "small" else textSize = "default" end

	for i=1, config.mapSize[1] do
		mapBuildings[i] = {}
	end

	globalEnemies = {}
	selectedPage = 1
	inventory = {
		coins = 100,
	}

	generateMap()
	createUi()
	loadMusic()
	createStatus()
	conv = AudioSource()
	conv:SetParent(Camera)

	loadImage("game_icon", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/game_icon.png")

	loadImage("basic_mine", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/basic_mine_icon.png")
	loadImage("mine_v2", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/mine_icon.png")
	loadImage(
		"basic_generator",
		"https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/basic_generator_icon.png"
	)
	loadImage(
		"generator_v2",
		"https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/generator_v2_icon.png"
	)
	loadImage("conveyor", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/conveyor_icon.png")
    loadImage("remover", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/remover_icon.png")
	loadImage("cable", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/cable_icon.png")
	loadImage("turret", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/turret_icon.png")
	loadImage(
		"turret_sniper",
		"https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/turret_sniper.png"
	)
	loadImage("copper_turret", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/copper_turret_icon.png")
	loadImage("turret_v2", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/turret_v2_icon.png")
	loadImage("pole", "https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/pole_icon.png")
	loadImage(
		"conveyor_spot",
		"https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/conveyor_spot_icon.png"
	)
	loadImage(
		"wood_wall",
		"https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/wood_wall_icon.png"
	)
	loadImage(
		"stone_wall",
		"https://raw.githubusercontent.com/Nanskipp/tech-game/main/images/icon/stone_wall_icon.png"
	)
end

loadShapes = function()
	shapes = {}
	for i = 1, 1000 do
		shape = Shape(Items.nanskip.conv_generator)
		shape.Position = Number3(5, 5, 5)
		shape.Tick = function(self)
			for i=1, 5 do
				self.Position = self.Position
				self.Rotation = self.Rotation + Number3(0, 0.01, 0)
			end
		end
		table.insert(shapes, shape)

		World:AddChild(shape)
	end

	averageFps = 60
	fpsTimer = 0
end

showIcon = function()
	gameicon = Quad()
	gameicon.Image = icons["game_icon"]
	gameicon:SetParent(Camera)
	gameicon.Position = Camera.Position+Camera.Forward*0.8 + Camera.Left*0.5+Camera.Down*0.5
end

checkFps = function(dt)
	fps = round(1 / dt)
	averageFps = (averageFps + fps) / 2

	fpsTimer = fpsTimer + 1

	if fpsTimer >= 30 then
		if averageFps > 60 then
			fpsResult = "good"
			fpsMultiplier = 1
		elseif averageFps >= 50 and averageFps <= 60 then
			fpsResult = "normal"
			fpsMultiplier = 0.75
		elseif averageFps >= 30 and averageFps < 50 then
			fpsResult = "low"
			fpsMultiplier = 0.4
		elseif averageFps < 30 then
			fpsResult = "super low"
			fpsMultiplier = 0
		end

		print("Your FPS is " .. fpsResult .. ".")

		for i = 1, #shapes do
			shapes[i].Tick = nil
			shapes[i]:SetParent(nil)
			shapes[i] = nil
		end

		collectgarbage("collect")
		fpsChecked = true
		load()
	end
end

tick = function(dt)
	globalDT = dt
	globalSpeed = 60/(1/globalDT)

	if moveX ~= nil and moveY ~= nil then
		Camera.Position = Camera.Position + Number3(moveX, 0, moveY)*globalSpeed
	end
	if moveCursortimer == nil then
		moveCursortimer = 0
	end
	if statusBG ~= nil and Client.IsMobile then
		statusBG.IsHidden = true
	end
	moveCursortimer = moveCursortimer + 1

	roundTimer = roundTimer + 1

	if roundTimer >= 60 then
		roundTimer = 0
		roundEnd = roundEnd - 1
	end

	if roundEnd == 0 then
		newRound()
	end

	updateUi()

	if globalHealth <= 0 then
		roundEnd = math.Huge

		gameover2 = ui:createText(
			"     GAME OVER\ni have no time\nto implement game restart,\nso just rejoin the game\npls:)",
			Color(0, 0, 0), textSize
		)
		gameover = ui:createText(
			"     GAME OVER\ni have no time\nto implement game restart,\nso just rejoin the game\npls:)",
			Color(255, 255, 255), textSize
		)
		gameover.pos = Number2(Screen.Width / 2 - gameover.Width / 2, Screen.Height / 2 - gameover.Height / 2)
		gameover2.pos = Number2(gameover.pos.X + 1, gameover.pos.Y - 1)

		Client.Tick = function() end
	end
end

newRound = function()
	roundEnd = roundTime
	if newHp == nil then
		newHp = 1
	end
	if newDamage == nil then
		newDamage = 1
	end

	inventory["coins"] = inventory["coins"] + 75

	for i = 1, numberOfEnemies do
		local selectEnemy = enemies.walker

		selectEnemy.Position = Number3(math.random(0, config.mapSize[1] * 5), 5, math.random(0, config.mapSize[2] * 5))

		posz = math.random(0, 1)
		if math.random(0, 1) == 0 then
			selectEnemy.Position.X = posz * config.mapSize[1] * 5
		else
			selectEnemy.Position.Z = posz * config.mapSize[2] * 5
		end

		selectEnemy.damage = newDamage
		selectEnemy.health = newHp

		enemy(selectEnemy)
	end
	numberOfEnemies = round(numberOfEnemies * multiplier)
	if numberOfEnemies > 50 then
		numberOfEnemies = 50
	end
	newHp = newHp + 1
	newDamage = newDamage + 0.5

	if multiplier > 1.1 then
		multiplier = multiplier - 0.1
	end
end

createUi = function()
	if inventoryBG ~= nil then
		inventoryBG:setParent(nil)
	end
	if Client.IsMobile == true then
		inventoryBGoffset = Screen.Width * 0.25
	else
		inventoryBGoffset = 0
	end
	inventoryBG = ui:createFrame(Color(0, 0, 0, 0.6))
	inventoryBG.pos = Number2(inventoryBGoffset, 0 - Screen.SafeArea.Bottom)
	inventoryBG.Width, inventoryBG.Height = Screen.Width - inventoryBGoffset, Screen.Height * 0.2 + 10
	inventoryBG.onPress = function(_)
		return
	end
	inventoryBGline = ui:createFrame(Color(0, 0, 0, 0.4))
	inventoryBGline.pos = Number2(0, inventoryBG.Height - 4)
	inventoryBGline.Height = 4
	inventoryBGline.Width = Screen.Width - inventoryBGoffset
	inventoryBGline:setParent(inventoryBG)

	if fpsShowerbg ~= nil then
		fpsShowerbg:setParent(nil)
	end
	if fpsShower ~= nil then
		fpsShower:setParent(nil)
	end
	fpsShowerbg = ui:createFrame(Color(0, 0, 0, 0.6))
	fpsShower = ui:createText("FPS: 60", Color(200, 200, 200), textSize)
	fpsShower.pos =
		Number2(Screen.Width - fpsShower.Width - 8, Screen.Height - Screen.SafeArea.Top - fpsShower.Height - 8)
	fpsShowerbg.pos = Number2(fpsShower.pos.X - 8, fpsShower.pos.Y - 8)
	fpsShowerbg.Width = fpsShower.Width + 16
	fpsShowerbg.Height = fpsShower.Height + 16

	healthBar = ui:createText("health placeholder", Color(255, 0, 0), textSize)
	healthBar.pos = Number2(8 - inventoryBGoffset, Screen.Height - healthBar.Height - 48)
	healthBar:setParent(inventoryBG)

	inventoryText = ""
	for key, value in pairs(inventory) do
		inventoryText = inventoryText .. key .. ": " .. value
	end

	inventoryContainer = ui:createFrame(Color(0, 0, 0, 0.6))
	inventoryContainer:setParent(inventoryBG)

	inventoryContainerText = ui:createText(inventoryText, Color(255, 255, 255), textSize)
	inventoryContainerText.pos = Number2(Screen.Width / 2, Screen.Height - Screen.SafeArea.Top - inventoryContainerText.Height - 8)
	inventoryContainerText:setParent(inventoryBG)

	inventoryContainer.Width = inventoryContainerText.Width + 32
	inventoryContainer.Height = inventoryContainerText.Height + 32
	inventoryContainer.pos =
		Number2(Screen.Width / 2 - inventoryContainerText.Width / 2 - 16 - inventoryBGoffset, Screen.Height * 0.9 - 16)

	pages = {
		{
			name = "Resources",
			content = { buildings.mine, buildings.mine_v2, buildings.generator, buildings.generator_v2},
		},
		{
			name = "Turrets",
			content = { buildings.turret, buildings.copper_turret, buildings.turret_v2, buildings.turret_sniper },
		},
		{
			name = "Connections",
			content = { connections.conveyor, connections.cable, buildings.conveyor_spot, buildings.electicity_pole },
		},
		{
			name = "Walls",
			content = { buildings.wood_wall, buildings.stone_wall },
		},
	}

    for i=1, #pages do
        pages[i].content[#pages[i].content+1] = buildings.remover
    end
	local offsetX = 0

	refreshPage = function()
		if page ~= nil then
			page:setParent(nil)
		end
		page = ui:createFrame(Color(0, 0, 0, 1))
		page.Width, page.Height = 0, 0
		page.pos.X = inventoryBGoffset
		local offsetX = 8

		clickSound = AudioSource("button_4")
		clickSound:SetParent(Camera)

		for i = 1, #pages[selectedPage].content do
			selectButton = ui:createFrame(Color(0, 0, 0, 0.3))
			selectButton.pos = Number2(offsetX, 18 + Screen.SafeArea.Bottom)
			selectButton.onPress = function(_)
				selectedItem = pages[selectedPage].content[i]
				clickSound:Play()
				refreshPage()
			end

			selectButton.Width = inventoryBG.Height - 16 - 10
			selectButton.Height = inventoryBG.Height - 16 - 10
			offsetX = offsetX + inventoryBG.Height - 8

			if selectedItem == pages[selectedPage].content[i] then
				selectButton.line = ui:createFrame(Color(255, 255, 255))

				selectButton.line.pos = Number2(0, -6)
				selectButton.line.Width = selectButton.Width
				selectButton.line.Height = 6
				selectButton.line:setParent(selectButton)
			end

			selectButton.text = ui:createText(pages[selectedPage].content[i].name, Color(255, 255, 255), textSize)
			selectButton.text:setParent(selectButton)
			selectButton.text.pos = Number2(4, 0)

			local price = pages[selectedPage].content[i].costs["coins"]
			if price == nil then
				price = 0
			end
			selectButton.price = ui:createText(price, Color(255, 255, 0), textSize)
			selectButton.price:setParent(selectButton)
			selectButton.price.pos = Number2(4, selectButton.Height - selectButton.price.Height - 4)

			selectButton.icon = ui:createFrame(Color(0, 0, 0, 1))
			selectButton.icon.Color = Color(1.0, 1.0, 1.0, 0.999)
			selectButton.icon.object.Image = icons[pages[selectedPage].content[i].icon]
			selectButton.icon.object.IsDoubleSided = false
			selectButton.icon:setParent(selectButton)
			selectButton.icon.pos = Number2(21, 32)
			selectButton.icon.object.Width = selectButton.Width - 32 - 10
			selectButton.icon.object.Height = selectButton.Height - 32 - 10
			selectButton:setParent(page)
		end
	end

	for i = 1, #pages do
		button = ui:createButton(pages[i].name, {borders = false})
		button.id = i
		button.pos = Number2(offsetX, inventoryBG.Height)
		button:setColor(Color(0, 0, 0, 0.8))
		button:setColorPressed(Color(0, 0, 0, 0.85))

		offsetX = offsetX + button.Width
		button:setParent(inventoryBG)

		button.onPress = function(button)
			selectedPage = button.id
			refreshPage()
		end
	end
	refreshPage()
end

Screen.DidResize = function()
	if fpsChecked then
		inventoryBG:setParent(nil)
		inventoryContainerText:setParent(nil)
		createUi()
	end
end

updateUi = function()
	inventoryText = ""
	for key, value in pairs(inventory) do
		inventoryText = inventoryText .. key .. ": " .. value
	end
	inventoryContainerText.object.Text = inventoryText
	inventoryBG.pos.Y = Screen.SafeArea.Bottom
	healthBar.object.Text = "Health: " .. globalHealth
	healthBar.pos = Number2(8 - inventoryBGoffset, Screen.Height - healthBar.Height - 8 - Screen.SafeArea.Top - Screen.SafeArea.Bottom)
	inventoryContainerText.pos = Number2(
		Screen.Width / 2 - inventoryContainerText.Width / 2 - inventoryBGoffset,
		Screen.Height - Screen.SafeArea.Top - inventoryContainerText.Height - 6 - Screen.SafeArea.Bottom
	)
	inventoryContainer.pos = Number2(
		Screen.Width / 2 - inventoryContainerText.Width / 2 - 16 - inventoryBGoffset,
		Screen.Height - Screen.SafeArea.Top - inventoryContainerText.Height - 16 - Screen.SafeArea.Bottom
	)

	inventoryContainer.Width = inventoryContainerText.Width + 32
	inventoryContainer.Height = inventoryContainerText.Height + 16

	avgFPS = (avgFPS + 1 / globalDT) / 2
	fpsShower.Text = "FPS: " .. round(avgFPS)
	fpsShower.pos =
		Number2(Screen.Width - fpsShower.Width - 8, Screen.Height - Screen.SafeArea.Top - fpsShower.Height - 8)
	fpsShowerbg.pos = Number2(fpsShower.pos.X - 8, fpsShower.pos.Y - 8)
	fpsShowerbg.Width = fpsShower.Width + 16
	fpsShowerbg.Height = fpsShower.Height + 16
end

newId = function()
	globalId = (globalId or 0) + 1

	return globalId
end

loadImage = function(name, url)
	HTTP:Get(url, function(res)
		local obj = res.Body
		icons[name] = obj
		if res.StatusCode ~= 200 then
			print("status: " .. res.StatusCode)
		end
	end)
end

Client.DirectionalPad = function(dpadX, dpadY)
	moveX = dpadX
	moveY = dpadY
end

createStatus = function(obj)
	if obj == nil then
		obj = Object()

		obj.name = "name placeholder"
		obj.description = "description placeholder"
		obj.container = { placeholder = 0 }
		obj.health = "placeholder"
	end

	statusBG = ui:createFrame(Color(0, 0, 0, 0.6))
	statusBG.Width = Screen.Width * 0.25
	statusBG.Height = Screen.Height * 0.2
	statusBG.pos = Number2(Screen.Width - statusBG.Width, inventoryBG.Height)

	statusNameBG = ui:createFrame(Color(0, 0, 0, 0.2))
	statusName = ui:createText(string.gsub(obj.name, "\n", " "), Color(255, 255, 255), textSize)
	statusName.pos = Number2(8, statusBG.Height - statusName.Height - 4)
	statusNameBG:setParent(statusBG)
	statusName:setParent(statusBG)
	statusNameBG.pos = Number2(0, statusBG.Height - statusName.Height - 8)
	statusNameBG.Width = statusBG.Width
	statusNameBG.Height = statusName.Height + 8

	statusDescription = ui:createText(obj.description, Color(255, 255, 255), textSize)
	statusDescription.pos = Number2(8, statusBG.Height - statusName.Height - statusDescription.Height - 4)
	statusDescription:setParent(statusBG)

	local containerText = "Container: "
	for key, value in pairs(obj.container) do
		containerText = containerText .. key .. ": " .. value
	end
	containerText = containerText .. "\nHealth: " .. obj.health
	statusContainer = ui:createText(containerText, Color(255, 255, 255), textSize)
	statusContainer.pos = Number2(8, 8)
	statusContainer:setParent(statusBG)
end

refreshStatus = function(obj)
	statusName.object.Text = string.gsub(obj.name, "\n", " ")
	statusDescription.object.Text = obj.description
	statusDescription.pos = Number2(8, statusBG.Height - statusName.Height - statusDescription.Height - 8)

	local containerText = "Container: "
	for key, value in pairs(obj.container) do
		containerText = containerText .. key .. ": " .. value .. "\n"
	end
	containerText = containerText .. "\nHealth: " .. round(obj.health)
	statusContainer.object.Text = containerText

	local statHeight = statusNameBG.Height + statusDescription.Height + statusContainer.Height
	statusBG.Height = math.max(Screen.Height*0.1, statHeight)
	statusNameBG.pos = Number2(0, statusBG.Height - statusName.Height - 8)
	statusName.pos = Number2(8, statusBG.Height - statusName.Height - 4)
end

enemy = function(config)
	local enemy = Object()

	if config == nil then
		config = {
			Position = Number3(0, 0, 0),
			Rotation = Rotation(0, 0, 0),
			Scale = Number3(5, 5, 5),
			type = "none",
			id = 0,
			shape = "nanskip.red_voxel",
			radius = 10,
			health = 2,
			Tick = function(self) end,
			start = function(self)
				print(self)
				World:AddChild(self)
			end,
		}
	end

	Object:Load(config.shape, function(obj, config)
		obj.Pivot = Number3(0, 0, 0)
		obj.CollisionGroups = CollisionGroups(2)
		enemy:AddChild(obj)

		enemy:start()
	end)

	enemy.Position = config.Position
	enemy.Rotation = config.Rotation
	enemy.Scale = config.Scale
	enemy.type = config.type
	enemy.health = config.health
	enemy.id = config.id
	enemy.Tick = config.Tick
	enemy.start = config.start
	enemy.globalID = nil
	enemy.damage = config.damage
end

building = function(config)
	local building = Object()

	local defaultConfig = {
		Position = Number3(0, 0, 0),
		Rotation = Rotation(0, 0, 0),
		Scale = Number3(5, 5, 5),
		type = "none",
		id = 0,
		shape = "nanskip.red_voxel",
		inputs = {},
		outputs = {},
		container = {},
		hasIn = {},
		typeIn = "none",
		hasOut = {},
		typeOut = "none",
		icon = nil,
		Tick = function(self) end,
		start = function(self)
			print(self)
			World:AddChild(self)
		end,

		name = "blank",
		costs = { coins = { 1 } },
		health = 5
	}

	Object:Load(config.shape, function(obj, config)
		obj.Pivot = Number3(0, 0, 0)
		obj.CollisionGroups = CollisionGroups(2)
		building:AddChild(obj)

		building:start()
	end)

	building.Position = config.position or defaultConfig.position
	building.Rotation = config.rotation or defaultConfig.rotation
	building.Scale = config.scale or defaultConfig.scale
	building.type = config.type or defaultConfig.type
	building.id = config.id or defaultConfig.id
	building.Tick = config.tick or defaultConfig.tick
	building.start = config.start or defaultConfig.start
	building.inputs = clone(config.inputs) or clone(defaultConfig.inputs)
	building.outputs = clone(config.outputs) or clone(defaultConfig.outputs)
	building.hasIn = config.hasIn or defaultConfig.hasIn
	building.typeIn = config.typeIn or defaultConfig.typeIn
	building.hasOut = config.hasOut or defaultConfig.hasOut
	building.typeOut = config.typeOut or defaultConfig.typeOut
	building.container = clone(config.container) or clone(defaultConfig.container)
	building.icon = config.icon or defaultConfig.icon
	building.object = config.object or defaultConfig.object
	building.itemtype = config.itemtype or defaultConfig.itemtype
	building.connected = {}
	building.name = config.name or defaultConfig.name
	building.description = config.description or "placeholder"
	building.health = config.health or defaultConfig.health
    building.costs = config.costs or defaultConfig.costs

	mapBuildings[round(building.Position.X/5)][round(building.Position.Z/5)] = building

	building.destroy = function(self)
		if firstBuilding == self then
			selectedBuilding:SetParent(nil)
			fake:SetParent(nil)
			placingConnection = false
			conv.Sound = "buttonnegative_3"
			conv:Play()
		end

		for i = 1, #self.connected do
			self.connected[i]:SetParent(nil)
		end

		for i, e in ipairs(self.inputs) do
			for h, v in ipairs(e.outputs) do
				if v == self then
					table.remove(e.outputs, h)
					break
				end
			end
		end
		for i, e in ipairs(self.outputs) do
			for h, v in ipairs(e.inputs) do
				if v == self then
					table.remove(e.inputs, h)
					break
				end
			end
		end

		local explosionsound = AudioSource("big_explosion_2")
		explosionsound.Pitch = 3
		explosionsound.Position = self.Position
		World:AddChild(explosionsound)
		explosionsound:Play()
		explosionsound.Tick = function(self, dt)
			if not self.IsPlaying then
				self:SetParent(nil)
				self.Tick = nil
			end
		end
		for i = 1, 5 * fpsMultiplier do
			local particle = Shape(Items.nanskip.red_voxel)
			particle.Position = self.Position + Number3(2.5, 3, 2.5)
			local particleColor = Color(
				round(234 / (math.random(10, 25) * 0.1)),
				round(134 / (math.random(10, 25) * 0.1)),
				round(43 / (math.random(10, 25) * 0.1))
			)
			particle.Palette[1].Color = particleColor
			particle.Physics = PhysicsMode.Disabled
			particle.timer = 0
			particle.Scale = math.random(10, 30) * 0.1
			particle.vel = Number3(math.random(-10, 10) * 0.03, math.random(3, 10) * 0.1, math.random(-10, 10) * 0.03)

			particle.Tick = function(self, dt)
				self.timer = self.timer + 1 * globalSpeed

				self.Position = self.Position + self.vel
				self.vel.X = self.vel.X * 0.98
				if self.Position.Y > 5.2 then
					self.vel.Y = self.vel.Y - 0.05
				else
					self.vel.Y = 0
				end
				self.vel.Z = self.vel.Z * 0.98

				self.Palette[1].Color.A = self.Palette[1].Color.A - 4
				self.Scale = self.Scale * 0.98

				if self.timer >= 60 then
					self:SetParent(nil)
					self.Tick = nil
					self = nil
				end
			end
			World:AddChild(particle)
		end

		mapBuildings[round(self.Position.X/5)][round(self.Position.Z/5)] = nil

		self.Tick = nil
		self:SetParent(nil)
		self = nil
	end

	return building
end

bullet = function(config)
	defaultConfig = {
		Position = Number3(0, 0, 0),
		Rotation = Rotation(0, 0, 0),
		Scale = Number3(1, 1, 1),
		Pivot = Number3(0.5, 0.5, 0.5),
		damage = 1,
		health = 100,
		coins = 1,
		tick = function(self, dt)
			if self.timer == nil then self.timer = 0 end
			self.timer = self.timer + 1
			self.Position = self.Position + self.Forward * 2 * globalSpeed

			if self.timer >= self.health then
				self:remove()
			end
		end,
		start = function(self)
			self.Palette[1].Color = self.color
			World:AddChild(self)
		end,
		remove = function(self) self.Tick = nil self:SetParent(nil) self = nil end,
		shape = Shape(Items.nanskip.red_voxel),
		color = Color(255, 255, 255),
	}

	local bullet = Shape(config.shape or defaultConfig.shape)

	bullet.Position = config.Position or defaultConfig.Position
	bullet.Rotation = config.Rotation or defaultConfig.Rotation
	bullet.Scale = config.Scale or defaultConfig.Scale
	bullet.Pivot = config.Pivot or defaultConfig.Pivot
	bullet.Tick = config.tick or defaultConfig.tick
	bullet.OnCollisionBegin = function(self, other)
		newother = other:GetParent()
		if newother.type == "enemy" then
			newother.health = newother.health - self.damage
			inventory["coins"] = inventory["coins"] + self.coins
			self:remove()
		elseif newother == Map then
			self:remove()
		end
	end
	bullet.start = config.start or defaultConfig.start
	bullet.damage = config.damage or defaultConfig.damage
	bullet.color = config.color or defaultConfig.color
	bullet.health = config.health or defaultConfig.health
	bullet.coins = config.coins or defaultConfig.coins
	bullet.remove = defaultConfig.remove

	bullet:start()

end

moveCursor = LocalEvent:Listen(LocalEvent.Name.PointerMove, function(a)
	local impact = a:CastRay(CollisionGroups(1))

	if fpsChecked then
		if moveCursortimer >= 2 then
			if impact ~= nil then
				if placingConnection then
					secondBuilding = Object()
					if type(impact.Block.Position) == "Number3" then
						secondBuilding.Position = impact.Block.Position + Number3(0, 5, 0)
					end
					generateConnection(firstBuilding, secondBuilding, true, 99999, selectedConnection)
				end
			end
			moveCursortimer = 0
		end
	end
end)

moveCursor2 = LocalEvent:Listen(LocalEvent.Name.PointerMove, function(a)
	local impact = a:CastRay(CollisionGroups(2))

	if fpsChecked then
		removeStatus = function()
			if statusBG ~= nil then
				statusBG:setParent(nil)
			end
		end

		if impact ~= nil then
			local obj = impact.Object:GetParent()
			if obj.id ~= nil then
				statusBG.IsHidden = false
				refreshStatus(obj)
			else
				statusBG.IsHidden = true
			end
		else
			statusBG.IsHidden = true
		end
	end
end)

Pointer.Click = function(pointerEvent)
	local impact = pointerEvent:CastRay(CollisionGroups(1, 2))

	if impact ~= nil then
		if impact.Object == Map then
			if not placingConnection then
				if selectedItem.itemtype == "building" then
					selectedItem.position = impact.Block.Position + Number3(0, 5, 0)
					canBuy = true

					for key, value in pairs(selectedItem.costs) do
						if selectedItem.costs[key] > inventory[key] then
							canBuy = false
						end
					end

					if canBuy then
						building(selectedItem)
						for key, value in pairs(selectedItem.costs) do
							inventory[key] = inventory[key] - selectedItem.costs[key]
						end
					else
						conv.Sound = "buttonnegative_3"
						conv:Play()
						print("You can't afford that building! It costs " .. selectedItem.costs["coins"] .. " coins.")
					end
				end
			else
				selectedBuilding:SetParent(nil)
				fake:SetParent(nil)
				placingConnection = false
				conv.Sound = "buttonnegative_3"
				conv:Play()
			end
		end
		if impact.Object ~= Map then
			obj = impact.Object:GetParent()
			if obj.type == nil then
				return
			end
			if selectedItem ~= connections.conveyor then
				if selectedItem ~= connections.cable then
					if selectedItem.itemtype ~= "remover" then
						return
					end
				end
			end
            if selectedItem.itemtype == "remover" then

                for key, value in pairs(obj.costs) do
                    inventory[key] = inventory[key] + round(obj.costs[key]/2)
                end
                obj:destroy()

                return
            end
			if not placingConnection then
				if obj.typeOut == selectedItem.icon then
					if obj.hasOut then
						placingConnection = true
						firstBuilding = obj

						selectedBuilding = Shape(Items.nanskip.conv_selection)
						selectedConnection = selectedItem.shape

						World:AddChild(selectedBuilding)
						selectedBuilding.Pivot = Number3(1, 0, 1)
						selectedBuilding.IsUnlit = true
						selectedBuilding.Position = obj.Position
					end
				else
					conv.Sound = "buttonnegative_3"
					conv:Play()
				end
			else
				if obj.hasIn then
					secondBuilding = obj
					if secondBuilding.typeIn == firstBuilding.typeOut then
						generateConnection(firstBuilding, secondBuilding, false, 10, selectedConnection, firstOutType)

						selectedBuilding:SetParent(nil)
						placingConnection = false
					else
						placingConnection = false
						conv.Sound = "buttonnegative_3"
						conv:Play()
					end
				end
			end
		end
	end
end

icons = {}

loadEverything = function()
	-- AMBIENCE SETUP (begin) --

	if fpsMultiplier > 0.5 then
		require("ambience"):set({
			sky = {
				skyColor = Color(0, 168, 255),
				horizonColor = Color(137, 222, 229),
				abyssColor = Color(76, 144, 255),
				lightColor = Color(142, 180, 204),
				lightIntensity = 0.700000,
			},
			fog = {
				color = Color(19, 159, 204),
				near = 500,
				far = 1000,
				lightAbsorbtion = 0.400000,
			},
			sun = {
				color = Color(255, 247, 204),
				intensity = 1.000000,
				rotation = Number3(1.061161, 0.789219, 1.000000),
			},
			ambient = {
				skyLightFactor = 0.100000,
				dirLightFactor = 0.200000,
			},
		})
	end

	-- AMBIENCE SETUP (end) --

	bullets = {
		
	}

	enemies = {
		walker = {
			Position = Number3(0, 5, 0),
			Rotation = Rotation(0, 0, 0),
			Scale = Number3(1, 1, 1),
			type = "enemy",
			shape = "nanskip.conv_walker",
			radius = 10,
			health = 2,
			damage = 1,
			Tick = function(self)
				if self.timer == nil then
					self.timer = 0
				end

				self.timer = self.timer + 1 * globalSpeed
				self.Forward = Number3(config.mapSize[1] * 5 / 2, 5, config.mapSize[2] * 5 / 2) - self.Position
				self.LocalRotation.Z = math.sin(self.timer * 0.3) * 0.08

				self.Position = self.Position + self.Forward * 0.15* globalSpeed

				if self.health <= 0 then self:explode() end
			end,
			start = function(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.Physics = PhysicsMode.Trigger
				self.obj.Pivot = Number3(2.5, -1.5, 2.5)

				table.insert(globalEnemies, self)

				self.remove = function(self)
					for i, e in ipairs(globalEnemies) do
						if e == self then
							table.remove(globalEnemies, i)
							self.Tick = nil
							self:SetParent(nil)
							break
						end
					end
				end

				self.explode = function(self)
					local explosion = Shape(Items.nanskip.red_voxel)
					explosion.Pivot = Number3(0.5, 0.5, 0.5)
					explosion.Scale = Number3(12, 12, 12)
					explosion.Position = self.Position
					explosion.timer = 0
					explosion.damage = self.damage
					explosion.IsHidden = true

					local explosionsound = AudioSource("big_explosion_1")
					explosionsound.Pitch = 3
					explosionsound.Position = self.Position
					World:AddChild(explosionsound)
					explosionsound:Play()
					explosionsound.Tick = function(self)
						if not self.IsPlaying then
							self:SetParent(nil)
							self.Tick = nil
						end
					end

					self:remove()

					explosion.OnCollisionBegin = function(self, other)
						newother = other:GetParent()
						if newother.id ~= nil then
							newother.health = newother.health - self.damage
						end
					end

					explosion.Tick = function(self, dt)
						self.timer = self.timer + 1 * globalSpeed
						if self.timer >= 10 then
							self:SetParent(nil)
							self.Tick = nil
							self = nil
						end
					end
					World:AddChild(explosion)
					for i = 1, 5 * fpsMultiplier do
						local particle = Shape(Items.nanskip.red_voxel)
						particle.Position = self.Position + Number3(2.5, 3, 2.5)
						particle.Physics = PhysicsMode.Disabled
						local particleColor = Color(
							round(254 / (math.random(10, 25) * 0.1)),
							round(104 / (math.random(10, 25) * 0.1)),
							round(13 / (math.random(10, 25) * 0.1))
						)
						particle.Palette[1].Color = particleColor
						particle.timer = 0
						particle.Scale = math.random(10, 30) * 0.1
						particle.vel =
							Number3(math.random(-10, 10) * 0.03, math.random(3, 10) * 0.1, math.random(-10, 10) * 0.03)

						particle.Tick = function(self, dt)
							self.timer = self.timer + 1 * globalSpeed

							self.Position = self.Position + self.vel
							self.vel.X = self.vel.X * 0.98
							if self.Position.Y > 5.2 then
								self.vel.Y = self.vel.Y - 0.05
							else
								self.vel.Y = 0
							end
							self.vel.Z = self.vel.Z * 0.98

							self.Palette[1].Color.A = self.Palette[1].Color.A - 4
							self.Scale = self.Scale * 0.98

							if self.timer >= 60 then
								self:SetParent(nil)
								self.Tick = nil
								self = nil
							end
						end
						World:AddChild(particle)
					end
				end

				self.obj.OnCollisionBegin = function(self, other)
					newother = other:GetParent()
					if newother.id ~= nil then
						parent = self:GetParent()
						parent:explode()
					end
					if other.isBase then
						parent = self:GetParent()
						globalHealth = globalHealth - round(parent.damage)
						parent:explode()
					end
				end
				World:AddChild(self)
			end,
		},
	}

	buildings = {
        remover = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "Remover",
			id = newId(),
			shape = "nanskip.conv_mine",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = false,
			typeIn = "none",
			hasOut = true,
			typeOut = "conveyor",
			tick = function(self) end,
			start = function(self)
                print("You should click on building to remove it.")
			end,

			name = "Remover",
			description = "you really can't see\nthis message",
			costs = {},
			icon = "remover",
			object = Shape(Items.nanskip.conv_mine),
			itemtype = "remover",
		},
		wood_wall = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "wall",
			id = newId(),
			shape = "nanskip.conv_wood_wall",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = false,
			typeIn = "none",
			hasOut = false,
			typeOut = "none",
			health = 30,
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
			end,
			start = function(self)
				World:AddChild(self)
			end,

			name = "Wood\nWall",
			description = "Just a wood wall.\nHas 30 health points.",
			costs = { coins = 50 },
			icon = "wood_wall",
			object = Shape(Items.nanskip.conv_mine),
			itemtype = "building",
		},
		stone_wall = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "wall",
			id = newId(),
			shape = "nanskip.conv_stone_wall",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = false,
			typeIn = "none",
			hasOut = false,
			typeOut = "none",
			health = 100,
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
			end,
			start = function(self)
				World:AddChild(self)
			end,
			name = "Stone\nWall",
			description = "Just a wood wall.\nHas 100 health points.",
			costs = { coins = 300 },
			icon = "stone_wall",
			itemtype = "building",
		},
		mine = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "Drill",
			id = newId(),
			shape = "nanskip.conv_mine",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = false,
			typeIn = "none",
			hasOut = true,
			typeOut = "conveyor",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				if self.obj.animated_part.Rotation ~= nil then
					if self.obj.animated_part.timer == nil then
						self.obj.animated_part.timer = 0
					end

					if self.ore ~= "none" then
						self.obj.animated_part.timer = self.obj.animated_part.timer + 3* globalSpeed
						self.obj.animated_part.Rotation = self.obj.animated_part.Rotation + Rotation(0, 0.03* globalSpeed, 0)
					else
						self.obj.animated_part.timer = self.obj.animated_part.timer + 1* globalSpeed
						self.obj.animated_part.Rotation = self.obj.animated_part.Rotation + Rotation(0, 0.005* globalSpeed, 0)
					end

					if self.obj.animated_part.timer > 628 then
						self.obj.animated_part.timer = 1
						self.obj.update = true
					end

					if self.obj.animated_part.timer > 400 and self.obj.update then
						for i = 1, 5 * fpsMultiplier do
							local particle = Shape(Items.nanskip.red_voxel)
							particle.Physics = PhysicsMode.Disabled
							particle.Position = self.Position + Number3(2.5, 3, 2.5)
							particle.Palette[1].Color = Color(55, 55, 55)
							particle.timer = 0
							particle.vel = Number3(math.random(-10, 10) * 0.03, 0.3, math.random(-10, 10) * 0.03)

							particle.Tick = function(self, dt)
								self.timer = self.timer + 1 * globalSpeed

								self.Position = self.Position + self.vel
								self.vel.X = self.vel.X * 0.98
								self.vel.Y = self.vel.Y + 0.003
								self.vel.Z = self.vel.Z * 0.98

								self.Palette[1].Color.A = self.Palette[1].Color.A - 3
								self.Scale = self.Scale * 0.98

								if self.timer >= 60 then
									self:SetParent(nil)
									self.Tick = nil
									self = nil
								end
							end
							World:AddChild(particle)
						end
						self.obj.update = false
					end

					-- PARTICLES DISABLED DUE TO INSTABILITY

					self.obj.animated_part.Position.Y = 9.16 + math.sin(self.obj.animated_part.timer * 0.01)

					if self.timer == nil then
						self.timer = 0
					end
					self.timer = self.timer + 1 * globalSpeed

					if self.ore ~= "none" then
						if self.timer >= 60 then
							self.timer = 0
							if self.container[self.ore] == nil then
								self.container[self.ore] = 0
							end
							self.container[self.ore] = self.container[self.ore] + 1
							if self.container[self.ore] <= 0 then
								return
							end
							local moveItem = "none"
							local bruhOutputs = {}
							for key, value in pairs(self.container) do
								if moveItem ~= nil then
									moveItem = key
								end
								if moveItem ~= nil and moveItem ~= "none" then
									for key, value in pairs(self.outputs) do
										if value.container[moveItem] == nil then
											value.container[moveItem] = 0
										end
										if value ~= nil then
											table.insert(bruhOutputs, value)
										end
									end
									for i = 1, #self.outputs do
										value = bruhOutputs[math.random(1, #bruhOutputs)]
										if value ~= nil then
											if self.container[moveItem] > 0 then
												value.container[moveItem] = value.container[moveItem] + 1
												self.container[moveItem] = self.container[moveItem] - 1
											end
										end
									end
								end
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.animated_part = self.obj:GetChild(1)
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.obj.update = true

				self.ore = map[round(self.Position.X / 5)][round(self.Position.Z / 5)]
			end,

			name = "Basic\nDrill",
			description = "Can Drill basic resou-\nrces such as coal,\niron or copper.",
			costs = { coins = 5 },
			icon = "basic_mine",
			object = Shape(Items.nanskip.conv_mine),
			itemtype = "building",
		},
		mine_v2 = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "Drill",
			id = newId(),
			shape = "nanskip.conv_mine_v2",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = false,
			typeIn = "none",
			hasOut = true,
			typeOut = "conveyor",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				if self.obj.animated_part.Rotation ~= nil then
					if self.obj.animated_part.timer == nil then
						self.obj.animated_part.timer = 0
					end

					if self.ore ~= "none" then
						self.obj.animated_part.timer = self.obj.animated_part.timer + 6* globalSpeed
						self.obj.animated_part.Rotation = self.obj.animated_part.Rotation + Rotation(0, 0.03* globalSpeed, 0)
					else
						self.obj.animated_part.timer = self.obj.animated_part.timer + 2* globalSpeed
						self.obj.animated_part.Rotation = self.obj.animated_part.Rotation + Rotation(0, 0.005* globalSpeed, 0)
					end

					if self.obj.animated_part.timer > 628 then
						self.obj.animated_part.timer = 1
						self.obj.update = true
					end

					if self.obj.animated_part.timer > 400 and self.obj.update then
						for i = 1, 5 * fpsMultiplier do
							local particle = Shape(Items.nanskip.red_voxel)
							particle.Position = self.Position + Number3(2.5, 3, 2.5)
							particle.Physics = PhysicsMode.Disabled
							particle.Palette[1].Color = Color(155, 155, 155)
							particle.timer = 0
							particle.vel = Number3(math.random(-10, 10) * 0.03, 0.3, math.random(-10, 10) * 0.03)

							particle.Tick = function(self, dt)
								self.timer = self.timer + 1 * globalSpeed

								self.Position = self.Position + self.vel
								self.vel.X = self.vel.X * 0.98
								self.vel.Y = self.vel.Y + 0.003
								self.vel.Z = self.vel.Z * 0.98

								self.Palette[1].Color.A = self.Palette[1].Color.A - 3
								self.Scale = self.Scale * 0.98

								if self.timer >= 60 then
									self:SetParent(nil)
									self.Tick = nil
									self = nil
								end
							end
							World:AddChild(particle)
						end
						self.obj.update = false
					end

					-- PARTICLES DISABLED DUE TO INSTABILITY

					self.obj.animated_part.Position.Y = 10.16 + math.sin(self.obj.animated_part.timer * 0.01)

					if self.timer == nil then
						self.timer = 0
					end
					self.timer = self.timer + 1 * globalSpeed

					if self.ore ~= "none" then
						if self.timer >= 20 then
							self.timer = 0
							if self.container[self.ore] == nil then
								self.container[self.ore] = 0
							end
							self.container[self.ore] = self.container[self.ore] + 1
							if self.container[self.ore] <= 0 then
								return
							end
							local moveItem = "none"
							local bruhOutputs = {}
							for key, value in pairs(self.container) do
								if moveItem ~= nil then
									moveItem = key
								end
								if moveItem ~= nil and moveItem ~= "none" then
									for key, value in pairs(self.outputs) do
										if value.container[moveItem] == nil then
											value.container[moveItem] = 0
										end
										if value ~= nil then
											table.insert(bruhOutputs, value)
										end
									end
									for i = 1, #self.outputs do
										value = bruhOutputs[math.random(1, #bruhOutputs)]
										if value ~= nil then
											if self.container[moveItem] > 0 then
												value.container[moveItem] = value.container[moveItem] + 1
												self.container[moveItem] = self.container[moveItem] - 1
											end
										end
									end
								end
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.animated_part = self.obj:GetChild(1)
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.obj.update = true

				self.ore = map[round(self.Position.X / 5)][round(self.Position.Z / 5)]
			end,

			name = "Upgraded\nDrill",
			description = "Faster than basic.",
			costs = { coins = 30 },
			icon = "mine_v2",
			object = Shape(Items.nanskip.conv_mine_v2),
			itemtype = "building",
		},
		generator = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "generator",
			id = newId(),
			shape = "nanskip.conv_generator",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "conveyor",
			hasOut = true,
			typeOut = "cable",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				if self.timer == nil then
					self.timer = 0
				end
				if self.timer2 == nil then
					self.timer2 = 0
				end
				self.timer = self.timer + 1 * globalSpeed
				self.timer2 = self.timer2 + 1

				if self.obj ~= nil then
					if self.animate then
						self.obj.Position = self.Position + Number3(math.random(-10, 10)*0.005, math.random(-10, 10)*0.005, math.random(-10, 10)*0.005)
					else
						self.obj.Position = self.Position	
					end
				end

				if self.container["energy"] == nil then
					self.container["energy"] = 0
				end
				if self.timer >= 60 then
					self.animate = false
					self.timer = 0
					if self.container["coal"] == nil then
						self.container["coal"] = 0
					end
					if self.container["coal"] > 0 then
						self.container["coal"] = self.container["coal"] - 1
						self.container["energy"] = self.container["energy"] + 1
						self.animate = true
					end
					if self.container["coal"] > 10 then
						self.container["coal"] = 10
					end
				end
				if self.timer2 >= 20 then
					self.timer2 = 0
					if self.container["energy"] > 10 then
						self.container["energy"] = 10
					end
					for key, value in pairs(self.outputs) do
						if value.container["energy"] == nil then
							value.container["energy"] = 0
						end
						if self.container["energy"] > 0 then
							if math.random(1, #self.outputs) == 1 then
								value.container["energy"] = value.container["energy"] + 1
								self.container["energy"] = self.container["energy"] - 1
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
			end,

			name = [[Basic
Generator]],
			description = "Generates energy\nusing coal.",
			costs = { coins = 20 },
			icon = "basic_generator",
		},
		generator_v2 = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "generator_v2",
			id = newId(),
			shape = "nanskip.conv_generator_v2",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "conveyor",
			hasOut = true,
			typeOut = "cable",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				if self.timer == nil then
					self.timer = 0
				end
				if self.timer2 == nil then
					self.timer2 = 0
				end
				self.timer = self.timer + 1 * globalSpeed
				self.timer2 = self.timer2 + 1 * globalSpeed

				if self.obj ~= nil then
					if self.animate then
						self.obj.Position = self.Position + Number3(math.random(-10, 10)*0.005, math.random(-10, 10)*0.005, math.random(-10, 10)*0.005)
					else
						self.obj.Position = self.Position	
					end
				end

				if self.container["energy"] == nil then
					self.container["energy"] = 0
				end
				if self.timer >= 20 then
					self.timer = 0
					self.animate = false
					if self.container["coal"] == nil then
						self.container["coal"] = 0
					end
					if self.container["coal"] > 0 then
						self.container["coal"] = self.container["coal"] - 1
						self.container["energy"] = self.container["energy"] + 1
						self.animate = true
					end
					if self.container["coal"] > 10 then
						self.container["coal"] = 10
					end
				end
				if self.timer2 >= 10 then
					self.timer2 = 0
					if self.container["energy"] > 10 then
						self.container["energy"] = 10
					end
					for key, value in pairs(self.outputs) do
						if value.container["energy"] == nil then
							value.container["energy"] = 0
						end
						if self.container["energy"] > 0 then
							if math.random(1, #self.outputs) == 1 then
								value.container["energy"] = value.container["energy"] + 1
								self.container["energy"] = self.container["energy"] - 1
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
			end,

			name = "Generator",
			description = "Generates energy\nusing coal.\nFaster.",
			costs = { coins = 60 },
			icon = "generator_v2",
		},
		turret = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "turret",
			id = newId(),
			shape = "nanskip.conv_turret",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "cable",
			hasOut = false,
			typeOut = "none",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				local nearbyEnemies = {}
				if self.reloadtimer == nil then
					self.reloadtimer = 0
				end

				self.reloadtimer = self.reloadtimer + 1

				for key, value in ipairs(globalEnemies) do
					local enemy = value

					if distance(enemy.Position, self.Position) <= 30 then
						table.insert(nearbyEnemies, enemy)
					end
					enemy = nil
				end

				local dist = 1000
				local selectedEnemy = 0
				for key, value in ipairs(nearbyEnemies) do
					if distance(value.Position, self.Position) < dist then
						dist = distance(value.Position, self.Position)
						selectedEnemy = value
					end
				end
				if self.container["energy"] == nil then
					self.container["energy"] = 0
				end
				if self.container["energy"] > 5 then
					self.container["energy"] = 5
				end
				if selectedEnemy ~= 0 and selectedEnemy ~= nil then
					if self.container["energy"] > 0 then
						if self.reloadtimer >= 60 then
							self.obj.animated_part.Forward = (selectedEnemy.Position+Number3(0, 2.5, 0)) - self.obj.animated_part.Position

							selectedEnemy.health = selectedEnemy.health - 1

							self.reloadtimer = 0
							self.container["energy"] = self.container["energy"] - 1
							inventory["coins"] = inventory["coins"] + 3

							local pew = Shape(Items.nanskip.red_voxel)

							pew.Palette[1].Color = Color(255, 255, 0)
							pew.Pivot = Number3(0.5, 0.5, 0)
							pew.Position = self.obj.animated_part.Position + self.obj.animated_part.Up * 0.8
							pew.Forward = self.obj.animated_part.Forward
							pew.Scale = Number3(0.5, 0.5, dist)
							World:AddChild(pew)

							pew.Tick = function(self, dt)
								if self.timer == nil then
									self.timer = 0
								end
								self.timer = self.timer + 1 * globalSpeed
								if self.timer >= 5 then
									self:SetParent(nil)
									self.Tick = nil
									self = nil
								end
							end

							if self.sound ~= nil then
								self.sound:Play()
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.animated_part = self.obj:GetChild(1)
				self.obj.animated_part.Shadow = true
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.sound = AudioSource("laser_gun_shot_1")
				self.sound:SetParent(self)
				self.sound.Pitch = 1.75
			end,

			name = [[Basic
Turret]],
			description = "Shoots enemies by\nusing energy.",
			costs = { coins = 10 },
			icon = "turret",
		},
		turret_v2 = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "turret_v2",
			id = newId(),
			shape = "nanskip.conv_turret_v2",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "cable",
			hasOut = false,
			typeOut = "none",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				local nearbyEnemies = {}
				if self.reloadtimer == nil then
					self.reloadtimer = 0
				end

				self.reloadtimer = self.reloadtimer + 1

				for key, value in ipairs(globalEnemies) do
					local enemy = value

					if distance(enemy.Position, self.Position) <= 40 then
						table.insert(nearbyEnemies, enemy)
					end
					enemy = nil
				end

				local dist = 1000
				local selectedEnemy = 0
				for key, value in ipairs(nearbyEnemies) do
					if distance(value.Position, self.Position) < dist then
						dist = distance(value.Position, self.Position)
						selectedEnemy = value
					end
				end
				if self.container["energy"] == nil then
					self.container["energy"] = 0
				end
				if self.container["energy"] > 30 then
					self.container["energy"] = 30
				end
				if selectedEnemy ~= 0 and selectedEnemy ~= nil then
					if self.container["energy"] > 0 then
						if self.reloadtimer >= 5 then
							self.obj.animated_part.Forward = (selectedEnemy.Position+Number3(0, 2.5, 0)) - self.obj.animated_part.Position

							selectedEnemy.health = selectedEnemy.health - 2

							self.reloadtimer = 0
							if math.random(1, 5) ~= 1 then
								self.container["energy"] = self.container["energy"] - 1
							end
							inventory["coins"] = inventory["coins"] + 3

							if self.offSide == nil then
								self.offSide = 0
							end

							local changeSide = function()
								if self.offSide == 0 then
									self.offSide = 1
								else
									self.offSide = 0
								end
							end

							if self.offSide == 0 then
								self.offSideOffset = self.obj.animated_part.Right * 1.8
							else
								self.offSideOffset = self.obj.animated_part.Left * 1.8
							end

							local pew = Shape(Items.nanskip.red_voxel)

							pew.Palette[1].Color = Color(255, 255, 0)
							pew.Pivot = Number3(0.5, 0.5, 0)
							pew.Position = self.obj.animated_part.Position
								+ self.obj.animated_part.Up * 0.8
								+ self.offSideOffset
							pew.Forward = self.obj.animated_part.Forward
							pew.Scale = Number3(0.5, 0.5, dist)
							World:AddChild(pew)
							changeSide()

							pew.Tick = function(self, dt)
								if self.timer == nil then
									self.timer = 0
								end
								self.timer = self.timer + 1 * globalSpeed
								if self.timer >= 5 then
									self:SetParent(nil)
									self.Tick = nil
									self = nil
								end
							end

							if self.sound ~= nil then
								self.sound:Play()
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.animated_part = self.obj:GetChild(1)
				self.obj.animated_part.Shadow = true
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.sound = AudioSource("laser_gun_shot_1")
				self.sound:SetParent(self)
				self.sound.Pitch = 2
			end,

			name = "Double\nTurret",
			description = "Shoots enemies by\nusing energy.",
			costs = { coins = 120 },
			icon = "turret_v2",
		},
		copper_turret = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "copper_turret",
			id = newId(),
			shape = "nanskip.conv_copper_turret",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "conveyor",
			hasOut = false,
			typeOut = "none",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				local nearbyEnemies = {}
				if self.reloadtimer == nil then
					self.reloadtimer = 0
				end

				self.reloadtimer = self.reloadtimer + 1

				for key, value in ipairs(globalEnemies) do
					local enemy = value

					if distance(enemy.Position, self.Position) <= 60 then
						table.insert(nearbyEnemies, enemy)
					end
					enemy = nil
				end

				local dist = 1000
				local selectedEnemy = 0
				for key, value in ipairs(nearbyEnemies) do
					if distance(value.Position, self.Position) < dist then
						dist = distance(value.Position, self.Position)
						selectedEnemy = value
					end
				end
				if self.container["copper"] == nil then
					self.container["copper"] = 0
				end
				if self.container["copper"] > 20 then
					self.container["copper"] = 20
				end
				if selectedEnemy ~= 0 and selectedEnemy ~= nil then
					if self.container["copper"] > 0 then
						if self.reloadtimer >= 10 then
							self.obj.animated_part.Forward = (selectedEnemy.Position+Number3(0, 2.5, 0)) - self.obj.animated_part.Position

							self.reloadtimer = 0
							self.container["copper"] = self.container["copper"] - 1

							bullet({
								Position = self.obj.animated_part.Position + self.obj.animated_part.Forward + self.obj.animated_part.Up*0.5,
								Rotation = self.obj.animated_part.Rotation,
								color = Color(226, 169, 46)})

							if self.sound ~= nil then
								self.sound:Play()
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.animated_part = self.obj:GetChild(1)
				self.obj.animated_part.Shadow = true
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.sound = AudioSource("gunshot_5")
				self.sound:SetParent(self)
				self.sound.Pitch = 1.3
			end,

			name = "Copper\nTurret",
			description = "Shoots enemies by\nusing copper.",
			costs = { coins = 40 },
			icon = "copper_turret",
		},
		turret_sniper = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "turret_sniper",
			id = newId(),
			shape = "nanskip.conv_sniper",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "cable",
			hasOut = false,
			typeOut = "none",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				local nearbyEnemies = {}
				if self.reloadtimer == nil then
					self.reloadtimer = 0
				end

				self.reloadtimer = self.reloadtimer + 1

				for key, value in ipairs(globalEnemies) do
					local enemy = value

					if distance(enemy.Position, self.Position) <= 100 then
						table.insert(nearbyEnemies, enemy)
					end
					enemy = nil
				end

				local dist = 1000
				local selectedEnemy = 0
				for key, value in ipairs(nearbyEnemies) do
					if distance(value.Position, self.Position) < dist then
						dist = distance(value.Position, self.Position)
						selectedEnemy = value
					end
				end
				if self.container["energy"] == nil then
					self.container["energy"] = 0
				end
				if self.container["energy"] > 20 then
					self.container["energy"] = 20
				end
				if selectedEnemy ~= 0 and selectedEnemy ~= nil then
					if self.container["energy"] > 0 then
						if self.reloadtimer >= 180 then
							self.obj.animated_part.Forward = (selectedEnemy.Position+Number3(0, 2.5, 0)) - self.obj.animated_part.Position

							selectedEnemy.health = selectedEnemy.health - 8

							self.reloadtimer = 0
							self.container["energy"] = self.container["energy"] - 1
							inventory["coins"] = inventory["coins"] + 10

							local pew = Shape(Items.nanskip.red_voxel)

							pew.Palette[1].Color = Color(0, 255, 255)
							pew.Pivot = Number3(0.5, 0.5, 0)
							pew.Position = self.obj.animated_part.Position + self.obj.animated_part.Up * 0.8
							pew.Forward = self.obj.animated_part.Forward
							pew.Scale = Number3(0.5, 0.5, dist)
							World:AddChild(pew)

							pew.Tick = function(self, dt)
								if self.timer == nil then
									self.timer = 0
								end
								self.timer = self.timer + 1 * globalSpeed
								if self.timer >= 20 then
									self:SetParent(nil)
									self.Tick = nil
									self = nil
								end
							end

							if self.sound ~= nil then
								self.sound:Play()
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.animated_part = self.obj:GetChild(1)
				self.obj.animated_part.Shadow = true
				self.obj.animated_part.Physics = PhysicsMode.Disabled
				self.sound = AudioSource("laser_gun_shot_1")
				self.sound:SetParent(self)
				self.sound.Pitch = 0.75
			end,

			name = "Sniper\nTurret",
			description = "Shooting so far with\n big damage\nbut slow.",
			costs = { coins = 200 },
			icon = "turret_sniper",
		},
		conveyor_spot = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "turret",
			id = newId(),
			shape = "nanskip.conv_base",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "conveyor",
			hasOut = true,
			typeOut = "conveyor",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				if self.timer == nil then
					self.timer = 0
				end
				self.timer = self.timer + 1 * globalSpeed
				if self.timer >= 5 then
					self.timer = 0
					local moveItem = "none"
					local bruhOutputs = {}
					for key, value in pairs(self.container) do
						if moveItem ~= nil then
							moveItem = key
						end
						if moveItem ~= nil and moveItem ~= "none" then
							for key, value in pairs(self.outputs) do
								if value.container[moveItem] == nil then
									value.container[moveItem] = 0
								end
								if value ~= nil then
									table.insert(bruhOutputs, value)
								end
							end
							for i = 1, #self.outputs do
								value = bruhOutputs[math.random(1, #bruhOutputs)]
								if value ~= nil then
									if self.container[moveItem] > 0 then
										value.container[moveItem] = value.container[moveItem] + 1
										self.container[moveItem] = self.container[moveItem] - 1
									end
								end
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.Pivot = Number3(0, -0.5, 0)
			end,

			name = "Conveyor\nspot",
			description = "Used to connect\nconveyors.",
			costs = { coins = 5 },
			icon = "conveyor_spot",
		},
		electicity_pole = {
			rotation = Rotation(0, 0, 0),
			scale = Number3(0.833, 0.833, 0.833),
			type = "turret",
			id = newId(),
			shape = "nanskip.conv_pole",
			inputs = {},
			outputs = {},
			container = {},
			hasIn = true,
			typeIn = "cable",
			hasOut = true,
			typeOut = "cable",
			itemtype = "building",
			tick = function(self)
				if self.health <= 0 then
					self:destroy()
				end
				if self.timer == nil then
					self.timer = 0
				end
				self.timer = self.timer + 1 * globalSpeed
				if self.timer >= 5 then
					self.timer = 0
					local moveItem = "none"
					local bruhOutputs = {}
					for key, value in pairs(self.container) do
						if moveItem ~= nil then
							moveItem = key
						end
					end
					if moveItem ~= nil and moveItem ~= "none" then
						for key, value in pairs(self.outputs) do
							if value.container[moveItem] == nil then
								value.container[moveItem] = 0
							end
							if value ~= nil then
								table.insert(bruhOutputs, value)
							end
						end
						for i = 1, #self.outputs do
							value = bruhOutputs[math.random(1, #bruhOutputs)]
							if value ~= nil then
								if self.container[moveItem] > 0 then
									value.container[moveItem] = value.container[moveItem] + 1
									self.container[moveItem] = self.container[moveItem] - 1
								end
							end
						end
					end
				end
			end,
			start = function(self)
				World:AddChild(self)
				self.obj = self:GetChild(1)
				self.obj.Shadow = true
				self.obj.Pivot = Number3(0, -0.5, 0)
			end,

			name = "Electricity\npole",
			description = "Used to connect\ncables.",
			costs = { coins = 5 },
			icon = "pole",
		},
	}

	connections = {
		conveyor = {
			from = { "mine" },
			to = { "generator" },
			name = "Conveyor",
			icon = "conveyor",
			shape = Items.nanskip.conv_conveyor,
		},
		cable = {
			from = { "generator" },
			to = { "pole" },
			name = "Cable",
			icon = "cable",
			shape = Items.nanskip.conv_wire,
		},
	}
end

generateConnection = function(first, second, isFake, maxDistance, shape, type)
	if round(distance(first.Position, second.Position) / 5 / 0.75) < maxDistance then
		if fake ~= nil then
			fake:SetParent(nil)
		end
		if isFake then
			fake = Object()
			World:AddChild(fake)
		end
		notSame = true
		for key, value in pairs(first.outputs) do
			if value == second then
				notSame = false
			end
		end
		for i = 1, round(distance(first.Position, second.Position) / 5 / 0.75) do
			if notSame then
				connection = Shape(shape)

				connection.Forward = second.Position - first.Position
				if shape == Items.nanskip.conv_conveyor then
					connection.Pivot = Number3(3, 2, 3)
					connection.Scale = Number3(0.75, 0.75, 0.75)*0.833
				end
				if shape == Items.nanskip.conv_wire then
					connection.Pivot = Number3(1, -15, 1)
					connection.Scale = Number3(0.25, 0.25, 1)*0.833
				end
				connection.Position = first.Position
					+ Number3(2.5, 1.5, 2.5)
					+ connection.Forward * 5 * i * 0.75
					- connection.Forward * 3
				--connection.Scale = 0.833 * 0.75

				if not isFake then
					if not isCable then
						connection.Tick = function(self, dt)
							self.movedPart = self:GetChild(1)
							if shape == Items.nanskip.conv_conveyor then
								if self.timer == nil then
									self.timer = 1
								end

								self.timer = self.timer + 1 * globalSpeed
								if self.timer >= 101 then
									self.timer = 1
								end

								if self.movedPart.offsetY == nil then
									self.movedPart.offsetY = math.random(-100, 100) * 0.0001
								end
								self.movedPart.Position = self.Position
									+ Number3(0, 0 + self.movedPart.offsetY, 0)
									+ (self.Forward * self.timer * 0.01) * 2.5 * 0.75
							end
						end
					end
					World:AddChild(connection)
					table.insert(first.connected, connection)
					table.insert(second.connected, connection)
				else
					fake:AddChild(connection)
				end
			end
		end
		if not isFake then
			if notSame then
				table.insert(first.outputs, second)
				table.insert(second.inputs, first)
				conv.Sound = "buttonpositive_2"
				conv:Play()
			else
				conv.Sound = "buttonnegative_3"
				conv:Play()
			end
		end
	else
		if fake ~= nil then
			fake:SetParent(nil)
			conv.Sound = "buttonnegative_3"
			conv:Play()
		end
	end
end

round = function(number)
	return math.floor(number + 0.5)
end

distance = function(pos1, pos2)
	return math.sqrt(
		(pos1.X - pos2.X) * (pos1.X - pos2.X)
			+ (pos1.Y - pos2.Y) * (pos1.Y - pos2.Y)
			+ (pos1.Z - pos2.Z) * (pos1.Z - pos2.Z)
	)
end

generateMap = function()
	sizeX = config.mapSize[1]
	sizeY = config.mapSize[2]

	secondLayer = MutableShape(Items.nanskip.red_voxel)
	thirdLayer = MutableShape(Items.nanskip.red_voxel)

	for x = 1, sizeX do
		map[x] = {}
		for y = 1, sizeY do
			map[x][y] = "none"
			perlinY = perlin(x * 0.2, y * 0.2)
			randomness = math.random(-3, 3)

			if math.random(0, 50) == 0 then
				grass = Shape(Items.nanskip.conv_grass)
				grass.Position = Number3(x * 5, 5, y * 5)
				grass.Scale = 0.8
				grass.Rotation = Rotation(0, math.random(-314, 314) * 0.01, 0)
				grass.CollisionGroups = CollisionGroups(3)
				grass.Physics = PhysicsMode.Disabled

				World:AddChild(grass)
				grass.Shadow = true
			end

			coalY = perlin(x * 0.08, y * 0.08) ^ 2
			copperY = perlin(x * 0.075+15, y * 0.075+15) ^ 2

			if coalY * 10 >= 2 then
				if fpsMultiplier >= 0.4 then
					coalOre = Shape(Items.nanskip.conv_ore_coal)

					coalOre.Position = Number3(x * 5 + 2.5, 4.9, y * 5 + 2.5)
					coalOre.Rotation.Y = math.random(-314, 314) * 0.01
					coalOre.Scale = 0.5
					coalOre.CollisionGroups = CollisionGroups(3)
					coalOre.Physics = PhysicsMode.Disabled
					coalOre.Shadow = true
				end

				map[x][y] = "coal"
			end

			if copperY * 10 >= 2.2 then
				if fpsMultiplier >= 0.4 then
					copperOre = Shape(Items.nanskip.conv_ore_copper)

					copperOre.Position = Number3(x * 5 + 2.5, 4.9, y * 5 + 2.5)
					copperOre.Rotation.Y = math.random(-314, 314) * 0.01
					copperOre.Scale = 0.5
					copperOre.CollisionGroups = CollisionGroups(3)
					copperOre.Physics = PhysicsMode.Disabled
					copperOre.Shadow = true
				end
				if map[x][y] ~= "coal" then
					map[x][y] = "copper"
				else
					map[x][y] = "blocked"
				end
			end
			
			if map[x][y] == "copper" then
				if fpsMultiplier >= 0.4 then World:AddChild(copperOre) end
			elseif map[x][y] == "coal" then
				if fpsMultiplier >= 0.4 then World:AddChild(coalOre) end
			elseif map[x][y] == "blocked" then
				local i = {"copper", "coal"}
				map[x][y] = i[math.random(1, 2)]

				if map[x][y] == "copper" then
					if fpsMultiplier >= 0.4 then World:AddChild(copperOre) end
				elseif map[x][y] == "coal" then
					if fpsMultiplier >= 0.4 then World:AddChild(coalOre) end
				end
			end

			local block = Block(Color(110 + randomness, 159 + randomness, 81 + randomness), Number3(x, 0, y))
			if map[x][y] == "coal" and fpsMultiplier < 0.4 then
				block = Block(Color(50 + randomness, 50 + randomness, 50 + randomness), Number3(x, 0, y))
			end
			if map[x][y] == "copper" and fpsMultiplier < 0.4 then
				block = Block(Color(104 + randomness, 61 + randomness, 32 + randomness), Number3(x, 0, y))
			end
			Map:AddBlock(block)

			block.Color = Color(block.Color.R-10, block.Color.G-10, block.Color.B-10)

			if perlinY * 10 <= 0 then
				secondLayer:AddBlock(block)
			end
			if perlinY * 10 <= -1.5 then
				thirdLayer:AddBlock(block)
			end
		end
	end

	secondLayer:SetParent(World)
	secondLayer.Scale = 5
	secondLayer.Pivot = Number3(0, -0.05, 0)
	secondLayer.Physics = PhysicsMode.Disabled
	secondLayer.CollisionGroups = CollisionGroups(3)
	secondLayer.Shadow = true

	thirdLayer:SetParent(World)
	thirdLayer.Scale = 5
	thirdLayer.Pivot = Number3(0, -0.1, 0)
	thirdLayer.Physics = PhysicsMode.Disabled
	thirdLayer.CollisionGroups = CollisionGroups(3)
	thirdLayer.Shadow = true

	Map:ComputeBakedLight()
end

function clone(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

-- Function to generate Perlin noise
function perlin(x, y)
	x = x % 256
	y = y % 256
	local X = math.floor(x)
	local Y = math.floor(y)
	x = x - math.floor(x)
	y = y - math.floor(y)
	local u = fade(x)
	local v = fade(y)

	local p = permutation
	local A = (p[X] + Y) % 256
	local AA = p[A]
	local AB = p[(A + 1) % 256]
	local B = (p[(X + 1) % 256] + Y) % 256
	local BA = p[B]
	local BB = p[(B + 1) % 256]

	return lerp(
		v,
		lerp(u, grad(p[AA], x, y), grad(p[BA], x - 1, y)),
		lerp(u, grad(p[AB], x, y - 1), grad(p[BB], x - 1, y - 1))
	)
end

function lerp(t, a, b)
	return a + t * (b - a)
end

function grad(hash, x, y)
	local h = hash and (hash & 15) or 0
	local u = h < 8 and x or y
	local v = h < 4 and y or (h == 12 or h == 14) and x or 0
	return ((h & 1) == 0 and u or -u) + ((h & 2) == 0 and v or -v)
end

-- Permutation table (you can use any permutation here)
permutation = {}
for i = 0, 255 do
	permutation[i] = math.random(0, 255)
end
-- Helper functions
function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

loadMusic = function()
	music = AudioSource()
	music:SetParent(Camera)
	music.Volume = 0.3
	music.Loop = true

	load_sound("https://raw.githubusercontent.com/Nanskipp/tech-game/main/onitheme.mp3", function(sound)
		music.Sound = sound
		music:Play()
	end)
end

load_sound = function(url, callback)
	HTTP:Get(url, function(res)
		if res.StatusCode ~= 200 then
			print("Sound load error: " .. res.StatusCode)
			return
		else
			local obj = res.Body
			callback(obj)
		end
	end)
end

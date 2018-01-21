function love.load()
  -- Set up variables
  -- Libraries
  require 'libraries/serialize/show'
  anim8 = require 'libraries/anim8/anim8'
  sti = require 'libraries/sti'
  cameraLib = require 'libraries/hump/camera'
  sprites = require 'sprites'
  love.window.setMode(900, 700)
  love.graphics.setBackgroundColor(155, 214, 255)

  -- World
  world = love.physics.newWorld(0, 700, false)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
  -- Objects
  require 'player'
  require 'coin'

  sounds = {}
  sounds.coinCollect = love.audio.newSource('sounds/coin_collect.wav')
  sounds.mapLvl1 = love.audio.newSource('sounds/map_lvl1_sound.ogg')
  lvlSoundRunning = false

  gameStates = {}
  gameStates.PRE_PLAY = 1
  gameStates.PLAY = 2

  gameState = gameStates.PRE_PLAY
  menuFont = love.graphics.newFont(30)
  timer = 0

  savedData = {}
  savedData.bestTime = 999

  if love.filesystem.exists("savedData.lua") then
    local data = love.filesystem.load("savedData.lua")
    data()
  end

  cam = cameraLib()
  platforms = {}
  gameMap = sti("maps/map_lvl1_tile_map.lua")
  for i, obj in pairs(gameMap.layers['Platforms'].objects) do
    spawnPlatform(obj.x, obj.y, obj.width, obj.height)
  end

  for i, obj in pairs(gameMap.layers['Coins'].objects) do
    spawnCoin(obj.x, obj.y)
  end
end

function love.update(dt)
  world:update(dt)
  playerUpdate(dt)
  gameMap:update(dt)
  coinsUpdate(dt)

  cam:lookAt(player.body:getX(), love.graphics.getHeight()/2)

  for i, c in ipairs(coins) do
    c.animation:update(dt)
  end
  if gameState == gameStates.PLAY then
    timer = timer + dt
    if lvlSoundRunning == false then
      sounds.mapLvl1:play()
      sounds.mapLvl1:setVolume(0.25)
      lvlSoundRunning = true
    end
  end

  if #coins == 0 and gameState == gameStates.PLAY then
    resetLvl()
    if timer < savedData.bestTime then
        saveTimer()
    end
  end

  if player.dead == true then
    resetLvl()
  end

end

function love.draw()
  cam:attach()

  gameMap:drawLayer(gameMap.layers['TilesLayer'])

  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), nil, player.direction, 1, sprites.player_stand:getWidth()/2, sprites.player_stand:getHeight()/2)

  for i, c in ipairs(coins) do
    c.animation:draw(sprites.coin, c.x, c.y, nil, nil, nil, 20.5, 21)
  end

  cam:detach()
  if gameState == gameStates.PRE_PLAY then
      love.graphics.setFont(menuFont)
      love.graphics.printf("Press any button to begin !", 0, 50, love.graphics.getWidth(), "center")
      love.graphics.printf("Best time: "..savedData.bestTime , 0, 150, love.graphics.getWidth(), "center")
  end
  love.graphics.print("Time: " .. math.floor(timer), 10, 660)
end

function love.keypressed(key, scancode, isrepeat)
  if key == "up" and player.grounded == true then
    player.body:applyLinearImpulse(0, player.impulse)
  end
  if gameState == gameStates.PRE_PLAY then
    gameState = gameStates.PLAY
    timer = 0
  end
end

function getDistanceBetween(y1, x1, y2, x2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function spawnPlatform(x, y, width, height)
  local platform = {}
  platform.body = love.physics.newBody(world, x, y, "static")
  platform.shape = love.physics.newRectangleShape(width/2, height/2, width, height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape)
  platform.width = width
  platform.height = height

  table.insert(platforms, platform)
end

function beginContact(a, b, coll)
  player.grounded = true
end

function endContact(a, b, coll)
  player.grounded = false
end

function saveTimer (timer)
  savedData.bestTime = math.floor(timer)
  love.filesystem.write("savedData.lua", table.show(savedData, "savedData"))
end

function resetLvl ()
  gameState = gameStates.PRE_PLAY
  resetPlayer()
  for i, obj in pairs(gameMap.layers['Coins'].objects) do
    spawnCoin(obj.x, obj.y, obj.width, obj.height)
  end
  sounds.mapLvl1:stop()
  lvlSoundRunning = false
end

function love.load()
  -- Libraries
  require 'libraries/serialize/show'
  anim8 = require 'libraries/anim8/anim8'
  sti = require 'libraries/sti'
  cameraLib = require 'libraries/hump/camera'
  sprites = require 'sprites'
  -- Window
  love.window.setMode(1280, 720)
  love.graphics.setBackgroundColor(155, 214, 255)
  -- World
  world = love.physics.newWorld(0, 900, false)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
  -- Objects
  player = require 'player'
  coins = require 'coins'
  platforms = require 'platforms'
  fallingPlatforms = require 'fallingPlatforms'
  boss = require 'boss'

  -- Sound
  sounds = {}
  sounds.coinCollect = love.audio.newSource('sounds/coin_collect.wav')
  sounds.mapLvl1 = love.audio.newSource('sounds/map_lvl1_sound.ogg')
  lvlSoundRunning = false
  --States
  gameStates = {}
  gameStates.PRE_PLAY = 1
  gameStates.PLAY = 2
  gameState = gameStates.PRE_PLAY
  -- UI
  menuFont = love.graphics.newFont(30)
  timer = 0
  savedData = {}
  savedData.bestTime = 999
  if love.filesystem.exists("savedData.lua") then
    local data = love.filesystem.load("savedData.lua")
    data()
  end
  -- Set up
  cam = cameraLib()
  gameMap = sti("maps/tiles_sheet_platformer.lua")
  platforms:load()
  fallingPlatforms:load()
  coins:load()
  boss:load()
end

function love.update(dt)
  world:update(dt)
  gameMap:update(dt)
  cam:lookAt(player.body:getX(), love.graphics:getHeight()/2)
  player:update(dt)
  fallingPlatforms:update(dt)
  coins:update(dt)
  boss:update(dt)

  if gameState == gameStates.PLAY then
    timer = timer + dt
    if lvlSoundRunning == false then
      sounds.mapLvl1:play()
      sounds.mapLvl1:setVolume(0.1)
      lvlSoundRunning = true
    end
  end

  if #coins.bag == 0 and gameState == gameStates.PLAY then
    resetLvl()
    if timer < savedData.bestTime then
        saveTimer(timer)
    end
  end
  if player.state == 'dead' then
    resetLvl()
  end

end

function love.draw()
  cam:attach()
  gameMap:drawLayer(gameMap.layers['tiles_layer'])
  player:draw()
  fallingPlatforms:draw()
  coins:draw()
  boss:draw()
  cam:detach()


  if gameState == gameStates.PRE_PLAY then
      love.graphics.setFont(menuFont)
      love.graphics.printf("Press any button to begin !", 0, 50, love.graphics.getWidth(), "center")
      love.graphics.printf("Best time: "..savedData.bestTime , 0, 150, love.graphics.getWidth(), "center")
  end
  love.graphics.print("Time: " .. math.floor(timer), 10, 660)
end

function love.keypressed(key, scancode, isrepeat)
  if gameState == gameStates.PRE_PLAY then
    gameState = gameStates.PLAY
    timer = 0
  end
end

function getDistanceBetween(y1, x1, y2, x2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function beginContact(a, b, coll)
  print(b:getUserData()) --debug
  if 'Player' == a:getUserData() and 'Platform' == b:getUserData() then
    local platformBody = b:getBody()
    playerFeetPosition = player.body:getY() + player.hitbox.height/2
    platformTopPosition = platformBody:getY()
    -- Prevent wall glitch
    if playerFeetPosition < platformTopPosition then
      player.grounded = true
    end
  end
  if 'Player' == a:getUserData() and 'FallingPlatform' == b:getUserData() then
    currentContactPlatform = fallingPlatforms:getPlatform(b:getBody():getX(), b:getBody():getY())
    if currentContactPlatform ~= nil then
      playerFeetPosition = player.body:getY() + player.hitbox.height/2
      -- Prevent wall glitch
      if playerFeetPosition < currentContactPlatform.body:getY() then
        player.grounded = true
        currentContactPlatform.sprite = sprites.fallingPlatformDead
        currentContactPlatform.hit = true
      end
    end
  end
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
  player:reset()
  coins:load()
  fallingPlatforms:load()
  sounds.mapLvl1:stop()
  lvlSoundRunning = false
end

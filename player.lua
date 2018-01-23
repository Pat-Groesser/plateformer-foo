local player = {}
player.body = love.physics.newBody(world, 400, 400, "dynamic") --spawn
player.body:setFixedRotation(true)
player.hitbox = {}
player.hitbox.width = 55
player.hitbox.height = 73
player.shape = love.physics.newRectangleShape(player.hitbox.width, player.hitbox.height)
player.fixture = love.physics.newFixture(player.body, player.shape)
player.fixture:setUserData('Player')
player.speed = 500
player.impulse = -1300
player.grounded = false
player.state = 'idle'
player.direction = 1 -- right / -1 -- left
-- Moving animation
player.grid = anim8.newGrid(59, 75, 59, 450, 0,0, 0)
player.animations = {}
player.animations.walking = anim8.newAnimation(player.grid(1, '1-6'), 0.1)
player.animations.jump = anim8.newAnimation(player.grid(1, '3-3'), 0.1) -- static animation

local function updatePlayerRunning(dt, direction)
  player.state = 'run'
  player.direction = direction
  if 1 == player.direction then
    player.body:setX(player.body:getX() + player.speed * dt)
  else
    player.body:setX(player.body:getX() - player.speed * dt)
  end
  if true == player.grounded then
    player.animations.walking:update(dt)
  end
end

local function checkPlayerPosition()
  if player.body:getY() > love.graphics.getHeight() then
    player.sate = 'dead'
  end
end

function player:update(dt)
  if gameState == gameStates.PLAY then
    if true == player.grounded then
      player.state = 'idle'
      if love.keyboard.isDown("up") then
        player.body:applyLinearImpulse(0, player.impulse)
      end
    end

    if love.keyboard.isDown("left") then
      updatePlayerRunning(dt, -1)
    end

    if love.keyboard.isDown("right") then
      updatePlayerRunning(dt, 1)
    end

    if 'idle' == player.state then
        player.animations.walking:gotoFrame(1)
    end
  end
end

function player:draw()
  if true == player.grounded then
    player.animations.walking:draw(sprites.player_sheet, player.body:getX(), player.body:getY(), nil, player.direction, 1, player.hitbox.width/2, player.hitbox.height/2)
  else
    player.animations.jump:draw(sprites.player_sheet, player.body:getX(), player.body:getY(), nil, player.direction, 1, player.hitbox.width/2, player.hitbox.height/2)
  end
end

function player:reset()
    player.body:setPosition(500, 350)
    player.grounded = true
    player.state = 'idle'
    player.sprite = sprites.player_stand
end

return player

player = {}
player.body = love.physics.newBody(world, 500, 350, "dynamic")
player.body:setFixedRotation(true)
player.shape = love.physics.newRectangleShape(66, 92)
player.fixture = love.physics.newFixture(player.body, player.shape)
player.speed = 300
player.impulse = -3000
player.grounded = false
player.dead = false
player.direction = 1 -- right / -1 -- left
player.sprite = sprites.player_stand

function playerUpdate(dt)
  if gameState == gameStates.PLAY then
    if love.keyboard.isDown("left") then
      player.body:setX(player.body:getX() - player.speed * dt)
      player.direction = -1
    end

    if love.keyboard.isDown("right") then
      player.body:setX(player.body:getX() + player.speed * dt)
      player.direction = 1
    end

    if player.grounded == true then
      player.sprite = sprites.player_stand
    else
      player.sprite = sprites.player_jump
    end

    if player.body:getY() > love.graphics.getHeight() then
      player.dead = true
    end
  end
end

function resetPlayer()
    player.body:setPosition(500, 350)
    player.grounded = true
    player.dead = false
    player.sprite = sprites.player_stand
end

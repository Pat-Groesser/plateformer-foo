local boss = {}

local function spawnBoss()
  local bossData = gameMap.layers['boss_obj'].objects[1]
  boss.body = love.physics.newBody(world, bossData.x, bossData.y, "static") --spawn
  boss.hitbox = {
    width = bossData.width,
    height = bossData.height
  }
  boss.shape = love.physics.newRectangleShape(boss.hitbox.width/2, boss.hitbox.height/2 , boss.hitbox.width, boss.hitbox.height)
  boss.fixture = love.physics.newFixture(boss.body, boss.shape)
  boss.fixture:setUserData('Boss')
  boss.state = 'idle'
  -- Moving animation
  boss.grid = {
    idle = anim8.newGrid(416, 474, 418, 949, 0,1, 0),
    hit = anim8.newGrid(405, 472, 405, 945, 0,0, 0)
  }
  boss.animations = {
    idle = anim8.newAnimation(boss.grid.idle(1, '1-2'), 0.3),
    hit = anim8.newAnimation(boss.grid.hit(1, '1-2'), 0.3)
  }
  boss.sprite = sprites.bossIdle
  boss.hitTimer = 0
end

function boss:load()
  spawnBoss()
end

function boss:update(dt)
  boss.animations.idle:update(dt)
end

function boss:draw()
  love.graphics.rectangle('fill', boss.body:getX(), boss.body:getY(), boss.hitbox.width, boss.hitbox.height)
  boss.animations.idle:draw(boss.sprite, boss.body:getX(), boss.body:getY()-40)
end

return boss

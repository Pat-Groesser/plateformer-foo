local fallingPlatforms = {}
fallingPlatforms.bag = {}
fallingPlatforms.fallingSpeed = 5

local function spawnPlatform(x, y)
  local fallingPlatform = {}
  fallingPlatform.width = 70
  fallingPlatform.height = 70
  fallingPlatform.body = love.physics.newBody(world, x, y, "static")
  fallingPlatform.shape = love.physics.newRectangleShape(fallingPlatform.width/2, fallingPlatform.height/2, fallingPlatform.width, fallingPlatform.height)
  fallingPlatform.fixture = love.physics.newFixture(fallingPlatform.body, fallingPlatform.shape)
  fallingPlatform.sprite = sprites.fallingPlatform
  fallingPlatform.state = 'static' -- static / falling
  fallingPlatform.hit = false
  fallingPlatform.timer = 0
  fallingPlatform.fixture:setUserData('FallingPlatform')

  table.insert(fallingPlatforms.bag, fallingPlatform)
end

function fallingPlatforms:load()
  for i, obj in pairs(gameMap.layers['falling_platforms_obj'].objects) do
    spawnPlatform(obj.x, obj.y)
  end
end

function fallingPlatforms:update(dt)
  for i, platform in ipairs(fallingPlatforms.bag) do
    if platform.hit == true and platform.state ~= 'falling' then
      platform.timer = platform.timer + dt
      if platform.timer > 1 then
        platform.state = 'falling'
        platform.body:setType('dynamic')
      end
    end
    if platform.state == 'falling' and platform.body:getY() > love.graphics.getHeight() then
      table.remove(fallingPlatforms.bag, i)
    end
  end
end

function fallingPlatforms:draw()
  for i, platform in ipairs(fallingPlatforms.bag) do
    love.graphics.draw(platform.sprite, platform.body:getX(), platform.body:getY())
  end
end

function fallingPlatforms:getPlatform(x, y)
  for i, platform in ipairs(fallingPlatforms.bag) do
    if platform.body:getY() == y and platform.body:getX() == x then
      return platform
    end
  end

  return nil
end

return fallingPlatforms

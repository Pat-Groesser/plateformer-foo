local platforms = {}
platforms.bag = {}

local function spawnPlatform(x, y, width, height)
  local platform = {}
  platform.body = love.physics.newBody(world, x, y, "static")
  platform.shape = love.physics.newRectangleShape(width/2, height/2, width, height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape)
  platform.fixture:setUserData('Platform')
  platform.width = width
  platform.height = height

  table.insert(platforms.bag, platform)
end

function platforms:load()
  for i, obj in pairs(gameMap.layers['platforms_obj'].objects) do
    spawnPlatform(obj.x, obj.y, obj.width, obj.height)
  end
end

return platforms

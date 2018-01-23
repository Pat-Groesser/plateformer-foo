local coins = {}
coins.bag = {}

local function spawnCoin(x, y)
  local coin = {}
  coin.x = x
  coin.y = y
  coin.collected = false

  coin.grid = anim8.newGrid(41, 42, 123, 126)
  coin.animation = anim8.newAnimation(coin.grid('1-3', 1, '1-3', 2, '1-2', 3), 0.1)
  table.insert(coins.bag, coin)
end

function coins:load()
  for i, obj in pairs(gameMap.layers['coins_obj'].objects) do
     spawnCoin(obj.x, obj.y)
  end
end

function coins:update(dt)
  if gameState == gameStates.PLAY then
    for i, coin in ipairs(coins.bag) do
      if getDistanceBetween(coin.x, coin.y, player.body:getX(), player.body:getY()) < 50 then
        coin.collected = true
        sounds.coinCollect:play()
      end
      coin.animation:update(dt)
    end

    for i=#coins.bag, 1, -1 do
        local coin = coins.bag[i]
        if coin.collected == true then
          table.remove(coins.bag, i)
        end
    end
  end
end

function coins:draw()
  for i, coin in ipairs(coins.bag) do
    coin.animation:draw(sprites.coin, coin.x, coin.y, nil, nil, nil, 20.5, 21)
  end
end

return coins

local sprites = {}

sprites.coin = love.graphics.newImage('sprites/coin_sheet.png')
sprites.player_sheet = love.graphics.newImage('sprites/cat_happy_sheet_small.png')
sprites.fallingPlatform = love.graphics.newImage('sprites/grassBlock.png')
sprites.fallingPlatformDead = love.graphics.newImage('sprites/grassBlock_dead.png')
sprites.bossIdle = love.graphics.newImage('sprites/idle_boss.png')
sprites.bossHit = love.graphics.newImage('sprites/hit_boss.png')

return sprites

function love.load()
    love.window.setMode(1280, 720)

    anim8 = require 'libraries/anim8/anim8'
    sti = require'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.slugSheet = love.graphics.newImage('sprites/slugSheet.png')

    local grid = anim8.newGrid(32, 64, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local slugGrid = anim8.newGrid(64, 32, sprites.slugSheet:getWidth(), sprites.slugSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-6', 1), 0.2)
    animations.run = anim8.newAnimation(grid('1-4', 2), 0.2)
    animations.jump = anim8.newAnimation(grid('1-1', 3), 0.2)
    animations.slugWalk = anim8.newAnimation(slugGrid('1-4', 1), 0.2)
    animations.slugDie = anim8.newAnimation(slugGrid('1-4', 2), 0.2)

    wf = require('libraries/windfield/windfield')
    world = wf.newWorld(0, 200, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Hazard')
    world:addCollisionClass('Enemy')

    require('player')
    require('slug')
    
    --[[
    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Hazard"})
    dangerZone:setType("static")
    ]]

    platforms = {}

    doorX = 0
    doorY = 0

    currentLevel = "Level1"


    loadMap(currentLevel)
end


function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateSlugs(dt)


    local px, py = player:getPosition()
    cam:lookAt(px, py)

    local colliders = world:queryCircleArea(doorX, doorY, 16, {'Player'})
    if #colliders > 0 then
        if currentLevel == "Level1" then
            loadMap("Level2")
        
        elseif currentLevel == "Level2" then
            loadMap("Level1")
        end
    end
end


function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        --world:draw()
        drawPlayer()
        drawSlug()
    cam:detach()
end


function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -2400)
        end
    end

    if key == "r" then
        loadMap("Level2")
    end

end


function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 20, {'Platform'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end


function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType("static")
        table.insert(platforms, platform)
    end
end


function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end

    local i = #slugs
    while i > -1 do
        if slugs[i] ~= nil then
            slugs[i]:destroy()
        end
        table.remove(slugs, i)
        i = i - 1
    end
end


function loadMap(mapName)
    currentLevel = mapName
    destroyAll()
    player:setPosition(64, 650)
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers["Slugs"].objects) do
        spawnSlug(obj.x, obj.y)
    end

    for i, obj in pairs(gameMap.layers["Door"].objects) do
        doorX = obj.x
        doorY = obj.y
    end
end 
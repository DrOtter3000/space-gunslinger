function love.load()
    love.window.setMode(1280, 720)

    anim8 = require 'libraries/anim8/anim8'
    sti = require'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(32, 64, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-6', 1), 0.2)
    animations.run = anim8.newAnimation(grid('1-4', 2), 0.2)
    animations.jump = anim8.newAnimation(grid('1-1', 3), 0.2)

    wf = require('libraries/windfield/windfield')
    world = wf.newWorld(0, 400, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Hazard')

    require('player')
    
    --[[
    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Hazard"})
    dangerZone:setType("static")
    ]]

    platforms = {}

    loadMap()
end


function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)


    local px, py = player:getPosition()
    cam:lookAt(px, py)
end


function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()
        drawPlayer()
    cam:detach()
end


function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -1200)
        end
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


function loadMap()
    gameMap = sti("maps/Level1.lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end 
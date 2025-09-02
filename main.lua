function love.load()
    love.window.setMode(1280, 720)

    anim8 = require 'libraries/anim8/anim8'
    sti = require'libraries/Simple-Tiled-Implementation/sti'

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
    
    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Hazard"})
    dangerZone:setType("static")

    loadMap()
end


function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
end


function love.draw()
    world:draw()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    drawPlayer()
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


function loadMap()
    gameMap = sti("maps/Level1.lua")

end
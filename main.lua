function love.load()
    anim8 = require 'libraries/anim8/anim8'

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(16, 32, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-4', 1), 0.2)
    animations.jump = anim8.newAnimation(grid('1-1', 2), 0.2)
    animations.run = anim8.newAnimation(grid('1-4', 3), 0.2)

    wf = require('libraries/windfield/windfield')
    world = wf.newWorld(0, 400, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Hazard')

    player = world:newRectangleCollider(360, 100, 16, 32, {collision_class = "Player"})
    player:setFixedRotation(true)
    player.speed = 300
    player.animation = animations.idle
    player.isMoving = false
    -- Direction -1 = left, 1 = right
    player.direction = 1
    player.grounded = true
    
    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Hazard"})
    dangerZone:setType("static")
end


function love.update(dt)
    world:update(dt)
    if player.body then
        local colliders = world:queryRectangleArea(player:getX() - 8, player:getY() + 16, 16, 2,{'Platform'})
        if #colliders > 0 then
            player.grounded = true
        else
            player.grounded = false
        end

        player.isMoving = false
        local px, py = player:getPosition()
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
            player.isMoving = true
            player.direction = -1
        end
    end

    if player:enter('Hazard') then
        player:destroy()
    end

    if player.grounded then
        if player.isMoving then
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end

    player.animation:update(dt)
end


function love.draw()
    world:draw()

    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, player.direction, 1, 8, 16)
end


function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -250)
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
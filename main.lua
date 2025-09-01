function love.load()
    wf = require('libraries/windfield/windfield')
    world = wf.newWorld(0, 400, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Hazard')

    player = world:newRectangleCollider(360, 100, 16, 32, {collision_class = "Player"})
    player:setFixedRotation(true)
    player.speed = 300
    
    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Hazard"})
    dangerZone:setType("static")
end


function love.update(dt)
    world:update(dt)

    if player.body then
        local px, py = player:getPosition()
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
        end
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
        end
    end

    if player:enter('Hazard') then
        player:destroy()
    end
end


function love.draw()
    world:draw()
end


function love.keypressed(key)
    if key == 'up' then
        local colliders = world:queryRectangleArea(player:getX() - 8, player:getY() + 16, 16, 2,{'Platform'})
        if #colliders > 0 then
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
player = world:newRectangleCollider(360, 100, 32, 64, {collision_class = "Player"})
player:setFixedRotation(true)
player.speed = 300
player.animation = animations.idle
player.isMoving = false
-- Direction -1 = left, 1 = right
player.direction = 1
player.grounded = true


function playerUpdate(dt)
    if player.body then
        local colliders = world:queryRectangleArea(player:getX() - 16, player:getY() + 32, 32, 2,{'Platform'})
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


function drawPlayer()
    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, player.direction, 1, 16, 32)
end

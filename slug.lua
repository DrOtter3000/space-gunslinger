slugs = {}


function spawnSlug(x, y)
    local slug = world:newRectangleCollider(x, y, 64, 32, {collision_class = "Enemy"})
    slug.direction = 1
    slug.speed = 100
    slug.animation = animations.slugWalk
    table.insert(slugs, slug)
end


function updateSlugs(dt)
    for i, e in ipairs(slugs) do
        e.animation:update(dt)
        local ex, ey = e:getPosition()
        
        local colliders = world:queryRectangleArea(ex + (32 * e.direction), ey + 16, 10, 10, {'Platform'})
        if #colliders == 0 then
            e.direction = e.direction * -1
        end

        e:setX(ex + e.speed * dt * e.direction)
    end
end


function drawSlug()
    for i, e in ipairs(slugs) do
        local ex, ey = e:getPosition()
        e.animation:draw(sprites.slugSheet, ex, ey, nil, -e.direction, 1, 32, 16)
    end
end
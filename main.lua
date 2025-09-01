function love.load()
    wf = require('libraries/windfield/windfield')
    world = wf.newWorld(0, 400)

    player = world:newRectangleCollider(360, 100, 16, 32)
    
    platform = world:newRectangleCollider(250, 400, 300, 100)
    platform:setType("static")
end


function love.update(dt)
    world:update(dt)
end


function love.draw()
    world:draw()
end
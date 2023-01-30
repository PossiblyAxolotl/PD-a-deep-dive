-- the patented PossiblyAxolotl particle system used in Shopping Spree and Rocket Bytes
-- say "patented PossiblyAxolotl particle system" 5 times fast

local exps = {}

local gfx <const> = playdate.graphics

function explode(_x,_y)
    for i = 1, 10, 1 do
        local part = {
            x = _x,
            y = _y,
            dir = math.random(0,359),
            size = math.random(10,15),
            speed = math.random(1,3)
        }
        exps[#exps+1] = part
    end
end

function miniExplode(_x,_y)
    for i = 1, 6, 1 do
        local part = {
            x = _x,
            y = _y,
            dir = math.random(0,359),
            size = math.random(7,10),
            speed = math.random(1,3)
        }
        exps[#exps+1] = part
    end
end

function processExplosions()
    gfx.setColor(gfx.kColorWhite)
    for part = 1, #exps do
        local particle = exps[part]

        particle.x += math.sin(particle.dir) * particle.speed
        particle.y -= math.cos(particle.dir) * particle.speed
        gfx.fillCircleAtPoint(particle.x,particle.y,particle.size)
        exps[part].size -= .3

        if exps[part].size < 0 then exps[part].size = 0 end
    end

    for part = 1, #exps do
        if exps[part].size <= 0.1 then
            table.remove(exps, part)
            break
        end
    end
end

local bubs = {}

function bubbles()
    while #bubs < 10 do
        bub = {}
        bub.x = math.random( 45,354 )
        bub.y = 141
        bub.size = math.random(3,6)
        bub.speed = math.random(1,5)
        bubs[#bubs+1] = bub
    end

    for bb =1, #bubs, 1 do
        bub = bubs[bb]
        gfx.setColor(gfx.kColorWhite)
        gfx.drawCircleAtPoint(bub.x,bub.y,bub.size)

        bub.y -= bub.speed

        if bub.y < 45 then
            bub.x = math.random( 45,354 )
            bub.y = 141
            bub.size = math.random(3,6)
            bub.speed = math.random(1,5)
        end

        bubs[bb]= bub
    end
end
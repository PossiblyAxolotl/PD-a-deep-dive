-- PossiblyAxolotl
-- December 2nd, 2022 to December 4th, 2022
-- A Deep Dive

--[[ VARIABLES ]]--

local currentValue, requiredValue , steps, mode, score, timer, resetTime = 0, 30, 0, 5, 0, 10.0, 10.0
local gameState = 0 -- 0 = menu, 1 = game
local boxh= 0

local gfx <const> = playdate.graphics

--[[ SPRITES ]]--

imgWindow = gfx.image.new('gfx/window')
imgCrackedWindow = gfx.image.new('gfx/crackedwindow')
imgScreen = gfx.image.new('gfx/directionscreen')
imgPodium = gfx.image.new("gfx/wheelpodium")
imgWheel = gfx.image.new("gfx/wheel")
imgCirc = gfx.image.new('gfx/arrow2')

font = gfx.font.new('gfx/WaterFont')
fontB = gfx.font.new('gfx/WaterFontBig')

--[[ MUSIC ]] --
fBGM = playdate.sound.fileplayer.new('mus/music')
fPercussion = playdate.sound.fileplayer.new('mus/percussion')

sPlay = playdate.sound.sampleplayer.new('sfx/start')
sDie = playdate.sound.sampleplayer.new('sfx/die')
sClick = playdate.sound.sampleplayer.new('sfx/click')

fBGM:setVolume(0.5)
fPercussion:setVolume(0.01)

fBGM:play(0)
fPercussion:play(0)

--[[ SETUP ]]--

import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/math"
import "particles.lua"

local menu = playdate.getSystemMenu()
menu:addCheckmarkMenuItem("inverted", function(value) playdate.display.setInverted(value) end)
menu:addMenuItem("by possiblyax", function() print('https://possiblyaxolotl.itch.io') end)

math.randomseed(playdate.getSecondsSinceEpoch())
gfx.setLineWidth(2)
playdate.display.setInverted(false)

playdate.ui.crankIndicator:start() 

function playdate.update()
    gfx.clear(gfx.kColorBlack)
    local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
    local cosinval = (math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 6)
    gfx.drawLine(0,20+sinval,400,20-sinval)
    bubbles()
    imgWindow:drawCentered(80,90+(sinval/2)+sinval)
    imgWindow:drawCentered(200,90+(sinval/2))
    imgWindow:drawCentered(320,90+(sinval/2)-sinval)

    if gameState == 1 then -- game
        if boxh > 0 then
            gfx.fillRect(200,240-boxh/8,400,boxh/8)
            boxh = playdate.math.lerp(boxh,0,0.1)
        end
        updateGame()
        fPercussion:setVolume(playdate.math.lerp(fPercussion:getVolume(),0.5,0.05))
        if requiredValue > 0 then
            imgCirc:drawCentered(80,90+(sinval/2)+sinval)
            imgCirc:drawCentered(320,90+(sinval/2)-sinval)
        else
            imgCirc:drawCentered(80,90+(sinval/2)+sinval,  playdate.graphics.kImageFlippedX)
            imgCirc:drawCentered(320,90+(sinval/2)-sinval,  playdate.graphics.kImageFlippedX)
        end
    elseif gameState == 2 then -- dead 
        imgCrackedWindow:drawCentered(80,90+(sinval/2)+sinval)
        imgCrackedWindow:drawCentered(200,90+(sinval/2))
        imgCrackedWindow:drawCentered(320,90+(sinval/2)-sinval)
        currentValue = playdate.math.lerp(currentValue,0,0.05)
        fontB:drawText("REPLAY",320-gfx.getTextSize("REPLAY"),200-sinval/4)
        fontB:drawText("MENU",80-gfx.getTextSize("MENU"),200-sinval/4)
        font:drawText("YOU DIED",200-gfx.getTextSize("YOU DIED")/2,0)
        font:drawText(score,200-(gfx.getTextSize(score)/2),24+(math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 3))
        if currentValue > 400 then currentValue = 400 elseif currentValue < -400 then currentValue = -400 end

        gfx.setColor(gfx.kColorXOR)
        if currentValue > 0 then
            gfx.fillRect(200,240-currentValue/8,400,currentValue/8)
            if currentValue > 300 then
                startGame()
            end
        elseif currentValue < 0 then
            gfx.fillRect(0,240+currentValue/8,200,-currentValue/8)
            if currentValue < -300 then
                gameState = 0
                boxh = 300
                explode(320,220)
                explode(80,220)
            end
        end

    elseif gameState == 0 then -- mainmenu
        local dat = playdate.datastore.read("score")
        currentValue = playdate.math.lerp(currentValue,0,0.05)
        fPercussion:setVolume(playdate.math.lerp(fPercussion:getVolume(),0.01,0.1))

        font:drawText("A DEEP DIVE",200-gfx.getTextSize("A DEEP DIVE")/2,0)

        fontB:drawText("PLAY",320-gfx.getTextSize("PLAY"),200-sinval/4)
        if dat ~= nil then
            fontB:drawText(dat.score,80-gfx.getTextSize(dat.score),210-sinval/4)
            font:drawText("HIGHSCORE",80-gfx.getTextSize("HIGHSCORE")/2,200-sinval/4)
        end

        gfx.setColor(gfx.kColorXOR)

        if boxh > 0 then
            gfx.fillRect(0,240-boxh/8,200,boxh/8)
            boxh = playdate.math.lerp(boxh,0,0.1)
        end

        if currentValue > 400 then currentValue = 400 elseif currentValue < -400 then currentValue = -400 end

        if currentValue > 0 then
            gfx.fillRect(200,240-currentValue/8,400,currentValue/8)
            if currentValue > 300 then
                startGame()
            end
        end
    end

    processExplosions()

    imgPodium:drawCentered(200,123+(cosinval/2))
    imgWheel:drawRotated(200,150+sinval,currentValue/2+cosinval)

    if gameState == 2 then -- death
        local nv = playdate.math.lerp(fBGM:getRate(), 0.5, 0.05)
        fBGM:setRate(nv)
        fPercussion:setRate(nv)
    else
        local nv = playdate.math.lerp(fBGM:getRate(), 1.0, 0.05)
        fBGM:setRate(nv)
        fPercussion:setRate(nv)
    end

    if playdate.isCrankDocked() then
    playdate.ui.crankIndicator:update()
    end
end

function startGame()
    boxh = 300
    sPlay:play()
    explode(320,220)
    explode(80,220)
    local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
    mode = math.random(2,4)

    resetTime = 10.0
    timer = 10.0

    score = 0

    gameState = 1

    miniExplode(200,2)

    miniExplode(80,90+(sinval/2)+sinval)
    miniExplode(320,90+(sinval/2)-sinval)

    preps["f"..mode]()
end

function updateGame()
    if timer < 0 then
        sDie:play()
        local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        local cosinval = (math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        currentValue = 0
        gameState = 2
        miniExplode(200,2)

        explode(320,220)
        explode(80,220)
        explode(200,150+sinval,currentValue/2+cosinval)

        miniExplode(80,90+(sinval/2)+sinval)
        miniExplode(320,90+(sinval/2)-sinval)

        local dat = playdate.datastore.read('score')
        if dat ~= nil then
            if dat.score < score then playdate.datastore.write({score=score},"score") end
        else
            playdate.datastore.write({score=score},"score")
        end
    end

    if steps < 1 then
        mode = math.random(2,4)

        preps["f"..mode]()
    end

    funcs["f"..mode]()

    timer -= .1

    if timer > 0 then
        gfx.fillRect(200-(timer/resetTime*80),4,(timer/resetTime*160),8)
    end

    font:drawText(score,200-(gfx.getTextSize(score)/2),24+(math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 3))
end

--[[ MODES ]]--

local function positionOver()
    return (requiredValue > 0 and currentValue > requiredValue) or (requiredValue < 0 and currentValue < requiredValue)
end

function prepareMode1() -- pong [deprecated]
    currentValue = 0
    requiredValue = 150
    steps = math.random(5, 10)
end

function mode1() 
    if positionOver() then
        requiredValue *= -1
        steps -= 1
        score += 1
        explode(200,120)
        timer = resetTime
    end

    if currentValue < -180  then
        currentValue = -180
    elseif currentValue > 180 then
        currentValue = 180
    end
end

function prepareMode2() -- fast
    currentValue = 0
    requiredValue = 180
    steps = math.random(3, 7)
    miniExplode(200,120)
    timer = resetTime
end

function mode2()
    if positionOver() then
        currentValue = 0
        steps -= 1
        score += 1
        local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        local cosinval = (math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        miniExplode(200,150+sinval,currentValue/2+cosinval)
        timer = resetTime
        sClick:play()
        if resetTime > 1.0 then resetTime-=0.05 end
    end

    if currentValue < -360 then currentValue = -360 end
end

function prepareMode3() -- fast (negative)
    currentValue = 0
    requiredValue = -180
    steps = math.random(3, 7)
end

function mode3()
    if positionOver() then
        currentValue = 0
        steps -= 1
        score += 1
        local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        local cosinval = (math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        miniExplode(200,150+sinval,currentValue/2+cosinval)
        timer = resetTime
        sClick:play()
        if resetTime > 1.0 then resetTime-=0.05 end
    end

    if currentValue > 360 then currentValue = 360 end
end

function prepareMode4() -- variable pong
    currentValue = 0
    requiredValue = math.random(30, 200)
    steps = math.random(5, 10)
end

function mode4() 
    if positionOver() then
        requiredValue *= -1
        steps -= 1
        score += 1
        local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        local cosinval = (math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        explode(200,150+sinval,currentValue/2+cosinval)
        timer = resetTime
        if resetTime > 1.0 then resetTime-=0.05 end
        sClick:play()
    end

    if requiredValue > 0 then
        if currentValue < -requiredValue-10  then
            currentValue = -requiredValue-10
        elseif currentValue > requiredValue+10 then
            currentValue = requiredValue
        end
    else
        if currentValue < requiredValue-10  then
            currentValue = requiredValue-10
        elseif currentValue > -requiredValue+10 then
            currentValue = -requiredValue
        end
    end
end

function prepareMode5() -- random pong
    currentValue = 0
    requiredValue = math.random(90, 400)
    if math.random() > 0.5 then
        requiredValue *= -1
    end

    steps = math.random(2, 14)
end

function mode5() 
    if positionOver() then
        if requiredValue > 0 then
            requiredValue = math.random(-500,-45)
        else
            requiredValue = math.random(45,500)
        end
        steps -= 1
        sClick:play()
        score += 1
        local sinval = (math.sin(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        local cosinval = (math.cos(playdate.getCurrentTimeMilliseconds() / 400) * 6)
        explode(200,150+sinval,currentValue/2+cosinval)
        timer = resetTime
    end

    if requiredValue > 0 then
        if currentValue < -requiredValue-10  then
            currentValue = -requiredValue-10
        elseif currentValue > requiredValue+10 then
            currentValue = requiredValue
        end
    else
        if currentValue < requiredValue-10  then
            currentValue = requiredValue-10
        elseif currentValue > -requiredValue+10 then
            currentValue = -requiredValue
        end
    end
end

preps = {
    f1 = prepareMode1,
    f2 = prepareMode2,
    f3 = prepareMode3,
    f4 = prepareMode4,
    f5 = prepareMode5
}

funcs = {
    f1 = mode1,
    f2 = mode2,
    f3 = mode3,
    f4 = mode4,
    f5 = mode5
}

function playdate.cranked(change, acceleratedChange)
    currentValue += change
end

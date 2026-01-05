local canBlockInThisSong = false
local anims = {'LEFT', 'DOWN', 'UP', 'RIGHT'}

local pushDist = 0
local pushLimit = 40

local disablePush = true
local disableBlock = false
local disableHealthDrain = false
local playDadParryAnims = false
local doSplahes = false
local doDadSplashes = false
local disableRanged = false
local disableBFBlock = false
local disableDadBlock = false
local doMattEchoTrail = false
local doBFEchoTrail = false

local trailCount = 0
local trailLimit = 40

local state = ''

local defaultBFX = 0
local defaultMattX = 0
local startPlayer1 = ''
local startPlayer2 = ''
local auraFadeTime = 0
local auraFaded = true
--stupid tko stage change
local dad0X = 0
--local dad1X = 0
local bfX = 0
local forceupdateCharPos = false
local forceupdateCharPosTime = 0
local parryMatt = -1


local isDadEcho = false
local isBfEcho = false
local function detectFight()
    isDadEcho = false
    isBfEcho = false
    local bf = {
        'boxing-husk',
        'boxing-husk-alt',
        'bf-lightglove',
        'wiik3bf',
        ''
    }
    local matt = {
        'boxing-matt',
        'matt-lightglove',
        ''
    }
    for matts = 1,#matt do
        if getProperty('dad.curCharacter') == matt[matts] then
            --asMattFight = true
            isDadEcho = true
            break
        end
    end
    for bfs = 1,#bf do
        if getProperty('boyfriend.curCharacter') == bf[bfs] then
            --asBfFight = true
            isBfEcho = true
            if bf[bfs] == 'Wiik3BFOnii' or bf[bfs] == 'TKOBFOnii' then
                isBfEcho = false
            end
            break
        end
    end
end

function onCreatePost()
    detectFight()
    local songList =
	{
		'Fisticuffs',
        'Place Holderreborn',
        'Place Holderunbound',
        'Blastout',
        'Place Holderalarmiing',
        --'Edgelord',
        --'Revenge',
        'immortal',
        'Light Gloves',
        'DISADVANTAGE'
	} 

	for song = 1,#songList do
		if songName == songList[song] then
            canBlockInThisSong = true
            addCharacterToList('bf','boyfriend')
            addCharacterToList('bf','dad')
            break
		end
	end
    defaultBFX = getProperty('boyfriendGroup.x') + getProperty('boyfriend.positionArray[0]')
    defaultMattX = getProperty('dadGroup.x') + getProperty('dad.positionArray[0]')
    startPlayer1 = getProperty('boyfriend.curCharacter')
    startPlayer2 = getProperty('dad.curCharacter')
    if canBlockInThisSong then
        makeAnimatedLuaSprite('bfShield', 'characters/ShieldStand_BF', defaultBFX-100, getProperty('boyfriendGroup.y') + 320)
        scaleObject('bfShield',1.5,1.5)
        addAnimationByPrefix('bfShield', 'idle', 'BF Shield0', 24, true)
        addAnimationByPrefix('bfShield', 'fade', 'FadeIn', 24, false)
        objectPlayAnimation('bfShield', 'shield', true)
        setProperty('bfShield.alpha',0.01)
        addLuaSprite('bfShield',false)
        setObjectOrder('bfShield', getObjectOrder('dadGroup')-1)
        
    
        makeAnimatedLuaSprite('mattShield', 'characters/ShieldStand_Matt', defaultMattX-50, getProperty('dadGroup.y') + 320)
        scaleObject('mattShield',1.5,1.5)
        addAnimationByPrefix('mattShield', 'idle', 'idle0', 24, true)
        addAnimationByPrefix('mattShield', 'fade', 'FadeIn', 24, false)
        objectPlayAnimation('mattShield', 'shield', true)
        setProperty('mattShield.alpha',0.01)
        addLuaSprite('mattShield',false)
        setObjectOrder('mattShield', getObjectOrder('boyfriendGroup')-1)
        createTrail('boyfriend')
        createTrail('dad')
        if songName == 'Edgelord' then
            disablePush = false
            pushLimit = 60
        elseif songName == 'Revenge' then
            canBlockInThisSong = false
        elseif songName == 'TKO' then
            addCharacterToList('TKOPowerup','dad')
            addCharacterToList('TKOMattDark','dad')

            makeAnimatedLuaSprite('auraMatt', 'characters/aura', -230, -300)
            addAnimationByPrefix('auraMatt', 'aura', 'aura', 24, true)
            objectPlayAnimation('auraMatt', 'aura')
            scaleObject('auraMatt',4,4)
            setProperty('auraMatt.alpha',0.001)
            addLuaSprite('auraMatt',false)
            setObjectOrder('auraMatt', getObjectOrder('dadGroup')-1)
        end
    end
    --[[
    setCharacterShouldDance('dadCharacter4', false)
    setActorAlpha(0, 'dadCharacter4')
    setCharacterShouldDance('bfCharacter4', false)
    setActorAlpha(0, 'bfCharacter4')
    playCharacterAnimation('dadCharacter4', 'FadeIn', true)
    playCharacterAnimation('dadCharacter4', 'idlemoment', true)


    triggerEvent('change block state', 'bfshield', '')
    ]]--
end

function createEcho(character,createAnims)
    trailCount = (trailCount + 1) % trailLimit
    if parryMatt == trailCount then
        trailCount = trailCount + 1
    end
    local name = character..'Echo'..trailCount
    local file = ''
    local offsetX = 0
    local offsetY = 0
    if character == 'boyfriend' then
        file = 'characters/BFWiik3Echo'
        offsetX = 130
        offsetY = 100
    elseif character == 'dad' then
        file = 'characters/MattWiik3Echo'
        offsetX = 160
        offsetY = 110
    end
    if not createAnims then
        offsetX = offsetX + getProperty(character..'.offset.x')
        offsetY = offsetY + getProperty(character..'.offset.y')
    end

    makeAnimatedLuaSprite(name,file,getProperty(character..'.x') - offsetX,getProperty(character..'.y') - offsetY)
    scaleObject(name,1.5,1.5)
    local animN = getProperty(character..'.animation.curAnim.name')
    if not createAnims then
        local anim = getProperty(character..'.animation.frameName')
        addAnimationByPrefix(name,animN,string.sub(anim,0,string.len(anim) - 4),getProperty(character..'.animation.curAnim.frameRate'),getProperty(character..'.animation.curAnim.looped'))
    else
        if character == 'dad' then
            addAnimationByPrefix(name,'singLEFT','attackleft',24,false)
            addAnimationByPrefix(name,'singDOWN','attackdown',24,false)
            addAnimationByPrefix(name,'singUP','attackup',24,false)
            addAnimationByPrefix(name,'singRIGHT','attackright',24,false)
            addAnimationByPrefix(name,'blockUP','blockup',24,false)
            addAnimationByPrefix(name,'blockDOWN','blockdown',24,false)
            addAnimationByPrefix(name,'blockLEFT','blockleft',24,false)
            addAnimationByPrefix(name,'blockRIGHT','blockright',24,false)
            addAnimationByPrefix(name,'parryLEFT','parryleft',24,false)
            addOffset(name,'parryLEFT',126,-15)
            addAnimationByPrefix(name,'parryDOWN','parrydown',24,false)
            addOffset(name,'parryDOWN',125,-15)
            addAnimationByPrefix(name,'parryUP','parryup',24,false)
            addOffset(name,'parryUP',125,-5)
            addAnimationByPrefix(name,'parryRIGHT','parryright',24,false)
            addOffset(name,'parryRIGHT',125,-7)
            objectPlayAnimation(name,'parryUP',true)
        elseif character == 'boyfriend' then
            addAnimationByPrefix(name,'singLEFT','BF Attack Left',24,false)
            addAnimationByPrefix(name,'singDOWN','BF Attack Down',24,false)
            addAnimationByPrefix(name,'singUP','BF Attack Up',24,false)
            addAnimationByPrefix(name,'singRIGHT','BF Attack Right',24,false)
            addAnimationByPrefix(name,'blockLEFT','BF Block Left',24,false)
            addAnimationByPrefix(name,'blockDOWN','BF Block Down',24,false)
            addAnimationByPrefix(name,'blockUP','BF Block Up',24,false)
            addAnimationByPrefix(name,'blockRIGHT','BF Block Right',24,false)
            addAnimationByPrefix(name,'dodgeLEFT','dodge DOWN',24,false)
            addAnimationByPrefix(name,'dodgeDOWN','dodge DOWN',24,false)
            addAnimationByPrefix(name,'dodgeUP','dodge UP',24,false)
            addAnimationByPrefix(name,'dodgeRIGHT','dodge UP',24,false)
            addAnimationByPrefix(name,'dodge','dodge UP',24,false)
        end
    end
    objectPlayAnimation(name,animN,true)
    addLuaSprite(name,false)
    setObjectOrder(name,getObjectOrder(character..'Group')-1)
    --updateHitbox(name)
end

function onUpdate(elapsed)
    if canBlockInThisSong then
        if songName == 'TKO' then
            if not auraFaded then
                auraFadeTime = auraFadeTime - elapsed
                if auraFadeTime < 0 then
                    auraFaded = true
                    setProperty('auraMatt.alpha',1)
                end
            else
                setProperty('auraMatt.x',getCharX('dad') - 150)
                setProperty('auraMatt.y',getCharY('dad') - 200)
            end
            if curStage == 'TKODark' then
                local a = getProperty('auraMatt.alpha')
                setProperty('tko-floor.alpha',-a+1)
                setProperty('tko-floorGlow.alpha',a)
            end
            
            if forceupdateCharPos then
                forceupdateCharPosTime = forceupdateCharPosTime - elapsed
                setProperty('boyfriend.x',bfX)
                --setActorX(dad1X, 'dadCharacter1')
                --setActorX(dad0X, 'dadCharacter0')
                --forceupdateCharPos = false
                if forceupdateCharPosTime < 0 then
                    forceupdateCharPos = false
                end
            end

        else
            if curStage == 'TKODark' then
                setProperty('tko-floorGlow.alpha',0)
            end
        end
    end
end

function dadBlock(data, doPush)
    if not canBlockInThisSong  then
        return
    end
    if doBFEchoTrail then
        --createEcho('boyfriend')
        --echoAnim('boyfriend', 'sing'..anims[data+1], true)
        createTrail('boyfriend')
    end
    setObjectOrder('dad',getObjectOrder('dadGroup')-1)
    local bfPunchOffsets = {200,220,100,150}
    if doSplahes and doPush then
        createPush(data+4,getCharX('boyfriend')-300,getCharY('boyfriend')+bfPunchOffsets[data+1]+330,getObjectOrder('boyfriendGroup')+2)
    end
    if not disableDadBlock and not disableBlock then
        if not playDadParryAnims then
            chracterAnim('dad', 'block'..anims[data+1])
        else
            chracterAnim('dad', 'parry'..anims[data+1])
        end
        if parryMatt ~= -1 then
            objectPlayAnimation('dadEcho'..parryMatt,'parry'..anims[data+1],true)
        end
        if pushDist >= -pushLimit and doPush and not disablePush then
            pushDist = pushDist - 1
            setProperty('boyfriend.x',getProperty('boyfriend.x')-5)
            setProperty('dad.x',getProperty('dad.x')-5)
        end
    end
    if not disableRanged then
        doRange('bfPunch'..data,getCharX('dad')+400,getCharY('boyfriend') + bfPunchOffsets[data+1]+300,getObjectOrder('dadGroup')+2,true)
    end
end
function bfBlock(data, doPush)
    if not canBlockInThisSong then
        return
    end
    setObjectOrder('dad',getObjectOrder('boyfriendGroup')+1)
    if not disableBFBlock and not disableBlock then
        if not string.find(getProperty('boyfriend.animation.curAnim.name'), 'dodge') then
            chracterAnim('boyfriend', 'block'..anims[data+1])
            if pushDist <= pushLimit and doPush and not disablePush then
                pushDist = pushDist + 1
                setProperty('boyfriend.x',getProperty('boyfriend.x')+5)
                setProperty('dad.x',getProperty('dad.x')+5)
            end
        end
    end
    if playDadParryAnims then
        chracterAnim('dad', 'parry'..anims[data+1])
    end
    local mattPunchOffsets = {190,250,110,140}
    if doDadSplashes and doPush then
        createPush(data,getCharX('dad')+420,getCharY('dad')+mattPunchOffsets[data+1]+310,getObjectOrder('boyfriendGroup')+2)
        --setObjectOrder('dad', getActorLayer('bfCharacter4')+1)
    end
    if doMattEchoTrail then
        createTrail('dad')
    end
    if not disableRanged then
        doRange('dadPunsh'..data,getCharX('bf')-650,getCharY('dad')+mattPunchOffsets[data+1]+300,getObjectOrder('boyfriendGroup')+2,false)
    end
end


function createPush(data,x,y,order)
    local name = 'punchSplash'..data
    cancelTween(name..'Alpha')
    makeAnimatedLuaSprite(name, 'characters/Splash', x, y)
    setProperty(name..'.angle',90)
    addAnimationByPrefix(name, 'splash', 'splash', 24, false)
    doTweenAlpha(name..'Alpha',name, 0, stepCrochet/500)
    addLuaSprite(name,false)
    scaleObject(name,0.5,0.5)
    setObjectOrder(name, order)
    objectPlayAnimation(name, 'splash', true)
end

function doRange(name,x,y, order,flipX)
    local doRanged = true
    local function detectRange()
        local rangeSpr = ''
        local dist = math.abs(getCharX('dad') - getCharX('boyfriend'))
        if dist < 500 then
            doRanged = false
        elseif dist >= 500 and dist < 700 then
            rangeSpr = 'Mid'
        elseif dist >= 700 then
            rangeSpr = 'Long'
        end
        return rangeSpr
    end
    if doRanged then
        local rangeSpr = detectRange()
        if rangeSpr == '' then
            return
        end
        if flipX == nil then
            flipX = false
        end
        if flipX then
            rangeSpr = rangeSpr..'BF'
        else
            rangeSpr = rangeSpr..'Matt'
        end

        makeLuaSprite(name, 'punches/'..rangeSpr, x, y)
        local offset = getProperty(name..'.width')
        if string.match(rangeSpr,'Long') then
            offset = offset / 4
        end
        if not flipX then
            setProperty(name..'.x',getProperty(name..'.x') + offset)
        else
            setProperty(name..'.x',getProperty(name..'.x') - offset)
        end
        doTweenAlpha(name..'alpha',name, 0, stepCrochet/500)
        addLuaSprite(name,false)
        setObjectOrder(name,order)
        
    end
end

function createTrail(character)
    if character == 'boyfriend' and isBfEcho or character == 'dad' and isDadEcho then
        createEcho(character)
        doTweenAlpha(character..'Echo'..trailCount..'Alpha',character..'Echo'..trailCount,0,stepCrochet*0.001*4,'cubeIn')
    end
end

function opponentNoteHit(id, data, type, sus)
	bfBlock(data, not sus)
    if not disableHealthDrain and canBlockInThisSong then
        doHealthDrain()
    end
end
function goodNoteHit(id, data, type, sus)
    if type ~= 'Wiik3Punch' and type ~= 'Wiik4Sword' then --dont block when dodging
        dadBlock(data, not sus)
    end
end

function onEvent(name, v1, v2)
    if name == 'change block state' then
        startState(v1)

    elseif name == "Change Stage" then
        pushDist = 0
        if v1 == 'VoiidArena-Edgelord' then
            pushLimit = 80
            disablePush = true
        elseif v1 == 'Arena-Voiid' or v1 == 'Edgelord-Intro' then
            pushLimit = 50
        end
        if songName == 'Revenge' then
            canBlockInThisSong = true
            if curStage == 'VoiidBoxingRingFar' then
                canBlockInThisSong = false
            end
        elseif songName == 'TKO' then
            cancelTween('bfX')
            cancelTween('dadX')
            --trace('yahosdljhasdshjal')
            forceupdateCharPos = true
            forceupdateCharPosTime = 2 --stupid character offset bullshit with stage change
            doTweenX('bfX', 'boyfriend',bfX, 0.01, 'cubeOut')
            --doTweenX('dadX', 'dad', dad0X, 0.01, 'cubeOut')
            startPlayer2 = 'TKOMattDark'
        end
    elseif name == 'toggle matt echo trail' then
        doMattEchoTrail = not doMattEchoTrail
    elseif name == 'toggle bf echo trail' then
        doBFEchoTrail = not doBFEchoTrail
   elseif name == 'Change Character' then
        detectFight()
        --[[if songName == 'TKO' then
            if string.lower(v1) == 'bf' then
                doTweenX('bfX', 'boyfriend',bfX, 0.01, 'cubeOut')
            elseif string.lower(v1) == 'dad' then
                doTweenX('dadX', 'dad', dad0X, 0.01, 'cubeOut')
            end
        end
        --fix for shields
        --setCharacterShouldDance('dadCharacter4', false)
        --setCharacterShouldDance('bfCharacter4', false)
        ]]--
    end
end

function resetShield(character)
    if character == 'dad' then
        local currentMattPos = getCharX('dad')
        triggerEvent('Change Character', 'dad', startPlayer2)
        setProperty('dad.x',currentMattPos + getProperty('dad.positionArray[0]'))
        --setObjectOrder('dad',getObjectOrder('dadGroup'))
    elseif character == 'bf' then
        local currentBFPos = getCharX('boyfriend')
        triggerEvent('Change Character', 'boyfriend', startPlayer1)
        setProperty('boyfriend.x',currentBFPos + getProperty('boyfriend.positionArray[0]'))
        --setObjectOrder('boyfriend',getObjectOrder('boyfriendGroup'))
        
    end
    resetPos(character)
    removeShield(character)
end

function resetPos(character)
    if character == 'dad' then
        doTweenX('dadX','dad', defaultMattX, stepCrochet*0.001*4, 'cubeOut')
    elseif character == 'bf' then
        doTweenX('bfX', 'boyfriend', defaultBFX, stepCrochet*0.001*4, 'cubeOut')
    end
end

function doShield(character)
    local time = stepCrochet*0.001*4
    if character == 'bf' then
        local currentBFPos = getCharX('boyfriend')
        startPlayer1 = getProperty('boyfriend.curCharacter')
        triggerEvent('Change Character', 'boyfriend', 'Wiik3BFSingRTX')
        setProperty('boyfriend.x',currentBFPos + getProperty('boyfriend.positionArray[0]'))
        doTweenX('bfX', 'boyfriend', defaultBFX+450, time, 'cubeIn')
        activeShield('bf')
        --[[
        disableHealthDrain = true    
        doTweenX('dad4X','dadCharacter4', currentMattPos, stepCrochet*0.001*8, 'cubeIn')
        setProperty('bfCharacter0.x',currentBFPos)
        setProperty('bfCharacter4.alpha',0)

        doTweenX('dad0X', 'dadCharacter0', defaultMattX-150+(pushDist*5), stepCrochet*0.001*4, 'cubeIn')]]--
    elseif character == 'dad' then
        local currentMattPos = getCharX('dad')
        startPlayer2 = getProperty('dad.curCharacter')
        triggerEvent('Change Character', 'dad', 'Wiik3VoiidMattSing')
        setProperty('dad.x',currentMattPos + getProperty('dad.positionArray[0]'))
        doTweenX('dadX', 'dad', defaultMattX-450, time, 'cubeIn')
        playDadParryAnims = true
        activeShield('dad')
        --setProperty('dadCharacter4.alpha',0)
    end

end
function activeShield(character,pos)
    if character == 'dad' then
        if pos == nil then
            pos = defaultMattX
        end
        objectPlayAnimation('mattShield','idle',true)
        setProperty('mattShield.x',pos-200)
        doTweenAlpha('mattShieldAlpha', 'mattShield', 1, stepCrochet*0.001*4, 'cubeIn')
    elseif character == 'bf' then
        if pos == nil then
            pos = defaultBFX
        end
        objectPlayAnimation('bfShield','idle',true)
        doTweenAlpha('bfShiledAlpha','bfShield', 1, stepCrochet*0.001*4, 'cubeIn')
        setProperty('bfShield.x',pos-100)
    end
end
function removeShield(character)
    if character == 'bf' then
        objectPlayAnimation('bfShield','fade',true)
        doTweenAlpha('bfShieldAlpha', 'bfShield', 0, stepCrochet*0.001*4, 'cubeOut')

    elseif character == 'dad' then
        objectPlayAnimation('mattShield','fade',true)
        doTweenAlpha('mattShieldAlpha','mattShield', 0, stepCrochet*0.001*4, 'cubeOut')
    end
    --resetPos(character)
end

function transOutState()
    if state == 'shield' then
        resetShield('dad')
    elseif state == 'bfshield' then
        resetShield('bf')
    elseif state == 'doubleshield' then
        resetShield('bf')
        resetShield('dad')

        
    elseif state == 'echoInFront' or state == 'echoInFront-tko' then
        triggerEvent('Change Character', 'dad', startPlayer2)
        cameraFlash('game', 'FFFFFF', stepCrochet*0.001*4, true)
        doTweenX('dad', 'x', defaultMattX+getProperty('dad.positionArray[0]')+(pushDist*5), stepCrochet*0.001*4, 'cubeOut')
    elseif state == 'tko-powerup' then
        local currentMattPos = getCharX('dad')
        doTweenX('dadX', 'dad', currentMattPos-75, stepCrochet*0.001*4, 'cubeOut')
        --tweenActorProperty('dadCharacter0', 'alpha', 0, stepCrochet*0.001*8, 'cubeIn')
        doTweenAlpha('auraMattA','auraMatt' ,0, stepCrochet*0.001*8, 'cubeOut')
        chracterAnim('dad', 'destrans')
        --setCharacterShouldDance('dadCharacter1', false)
    elseif state == 'duet' or state == 'duet-tko' or state == 'tko-closeup' then
        resetPos('dad')
        resetPos('bf')
    end
end
function resetState()
    doSplahes = false
    doDadSplashes = false
    disableRanged = true
    disablePush = true
    disableDadBlock = false
    playDadParryAnims = false
    disableBlock = false
    disableHealthDrain = false
    disableBFBlock = false
    if curStage == 'TKO' then
        disableRanged = false
    end
end
function startState(value1)
    if state == value1 then
        return
    end
    if state ~= '' then
        transOutState() --shitty state machine
    end
    resetState()
    state = value1
    if state == '' then
        return
    end
    if state == 'pushing' then
        disablePush = false
    elseif state == 'duet parry' then
        playDadParryAnims = true
        disableBFBlock = true
        --setCharacterSingPrefix('dad', 'parry')
    elseif state == 'no ranged' then --so they dont use it after duet/shield
        disableRanged = true
        disableBlock = false
    elseif state == 'duet' then
        doSplahes = true
        disableRanged = true
        disableBlock = true
        doTweenX('dadX', 'dad', defaultMattX-130+(pushDist*5), stepCrochet*0.001*4, 'cubeIn')
        doTweenX('bfX', 'boyfriend', defaultBFX+130+(pushDist*5), stepCrochet*0.001*4, 'cubeIn')
    elseif state == 'duet-tko' then
        doSplahes = true
        disableRanged = true
        disableBlock = true
        doTweenX('dadX','dad', defaultMattX+(pushDist*5)+100, stepCrochet*0.001*4, 'cubeIn')
        doTweenX('bfX', 'boyfriend', defaultBFX+(pushDist*5)-100, stepCrochet*0.001*4, 'cubeIn')
    elseif state == 'tko-bfmoveright' then
        disableBlock = false
        disableRanged = false
        doTweenX('bfX', 'boyfriend', defaultBFX+(pushDist*5)+200, stepCrochet*0.001*31, 'cubeIn')
    elseif state == 'tko-mattmoveleft' then
        disableBlock = false
        disableRanged = false
        doTweenX('dadX', 'dad', defaultMattX+(pushDist*5)-200, stepCrochet*0.001*31, 'cubeIn')
    elseif state == 'shield' then
        doShield('dad')
        doSplahes = true
        disableBFBlock = true
    elseif state == 'bfshield' then
        doShield('bf')
        doDadSplashes = true
        disableDadBlock = true
    elseif state == 'echoInFront' then
        disableRanged = true
        disableBlock = false
        local currentMattPos = getCharX('dad')
        startPlayer2 = getProperty('dad.curCharacter')
        triggerEvent('change character', 'dad', 'Wiik3EchoParry')
        setProperty('dad.x',currentMattPos + getProperty('dad.positionArray[0]'))
        doTweenX('dadX', 'dad', defaultMattX+(pushDist*5), stepCrochet*0.001*8, 'cubeIn')
        --doTweenX('dad1X','dadCharacter1', defaultMattX+(pushDist*5)-450, stepCrochet*0.001*8, 'cubeOut')
        --doTweenX('dad', 'x', getOriginalCharX(1)-450+(pushDist*5), stepCrochet*0.001*8, 'cubeOut')
    elseif state == 'echoInFront-tko' then
        disableRanged = true
        disableBlock = false
        local currentMattPos = getCharX('dad')
        startPlayer2 = getProperty('dad.curCharacter')
        triggerEvent('change character', 'dad', 'Wiik3EchoParry')
        setProperty('dad.x',currentMattPos + getProperty('dad.positionArray[0]'))
        doTweenX('dadX', 'dad', defaultMattX+(pushDist*5)+290, stepCrochet*0.001*8, 'cubeIn')
        doTweenX('dadX', 'mattShield', defaultMattX+(pushDist*5)+290-450, stepCrochet*0.001*8, 'cubeOut')
        doTweenX('bfX', 'boyfriend', defaultBFX+(pushDist*5)-290, stepCrochet*0.001*4, 'cubeIn')
        --tweenActorProperty('dad', 'x', getOriginalCharX(1)-450+(pushDist*5), stepCrochet*0.001*8, 'cubeOut')
    elseif state == 'doubleshield' then
        doSplahes = true
        activeShield('bf',defaultMattX - 50)
        activeShield('dad',defaultBFX + 50)
        doTweenX('bfX', 'boyfriend', defaultBFX+450+(pushDist*5), stepCrochet*0.001*4, 'cubeIn')
        doTweenX('dadX', 'dad', defaultMattX-450+(pushDist*5), stepCrochet*0.001*4, 'cubeIn')
        doSplahes = true
        doDadSplashes = true
        disableHealthDrain = true
        disableBlock = true
    elseif value1 == 'resetpush' then
        pushDist = 0
        doTweenX('dadX','dad', defaultMattX+(pushDist*5), stepCrochet*0.001*4, 'cubeOut')
        doTweenX('bfX','boyfriend', defaultBFX+(pushDist*5), stepCrochet*0.001*4, 'cubeOut')
        disableRanged = false
        disableBlock = false
    elseif state == 'disable' then
        canBlockInThisSong = false
    elseif state == 'enable' then
        canBlockInThisSong = true
    elseif state == 'tko-closeup' then
        disableRanged = true
        disableBlock = false
        doTweenX('dadX', 'dad', defaultMattX+(pushDist*5)+290, stepCrochet*0.001*4, 'cubeIn')
        doTweenX('bfX', 'boyfriend', defaultBFX+(pushDist*5)-290, stepCrochet*0.001*4, 'cubeIn')
    elseif state == 'tko-powerup' then
        disableRanged = true
        disableBlock = false
        disableBFBlock = true
        local currentMattPos = getCharX('dad')
        local currentBFPos = getCharX('boyfriend')
        startPlayer2 = getProperty('dad.curCharacter')
        dad0X = currentMattPos+200
        bfX = currentBFPos+300
        triggerEvent('Change Character', 'dad', 'TKOPowerup')
        setProperty('dad.x',currentMattPos + getProperty('dad.positionArray[0]'))
        setProperty('boyfriend.x',currentBFPos + getProperty('boyfriend.positionArray[0]'))
        chracterAnim('dad','trans')
        createEcho('dad',true)
        parryMatt = trailCount
        setProperty('dadEcho'..parryMatt..'.x',defaultBFX - 600 - getProperty('boyfriend.positionArray[0]'))
        setProperty('dadEcho'..parryMatt..'.y',getCharY('boyfriend') + 300)
        --doTweenX('bfX', 'boyfriend', currentBFPos+200, stepCrochet*0.001*8, 'cubeIn')
        auraFadeTime = stepCrochet*0.001*16
        auraFaded = false


        --[[
            doTweenX('dad0X', 'dadCharacter0', currentMattPos+200, stepCrochet*0.001*8, 'cubeIn')
            doTweenX('dad1X', 'dadCharacter1', currentMattPos-400+200, stepCrochet*0.001*8, 'cubeIn')
            setProperty('dadCharacter1.x',currentMattPos-75)
            playCharacterAnimation('dadCharacter1', 'trans', true)
            setCharacterPlayFullAnim('dadCharacter1', true)
        ]]--
    elseif state == 'tko-powerupEnd' then
        disableBFBlock = false
        disableRanged = true
        disableBlock = false
        local currentMattPos = getCharX('dad')
        local currentBFPos = getCharX('boyfriend')
        triggerEvent('Change Character', 'dad', startPlayer2)
        setProperty('dad.x',currentMattPos+75 + getProperty('dad.positionArray[0]'))
        setProperty('boyfriend.x',currentBFPos + getProperty('boyfriend.positionArray[0]'))
        doTweenX('bfX', 'boyfriend', defaultBFX-300, stepCrochet*0.001*8, 'cubeIn')
        doTweenX('dadX', 'dad', defaultMattX+(pushDist*5)+290, stepCrochet*0.001*8, 'cubeOut')
        doTweenAlpha('dadEcho'..trailCount..'Alpha','dadEcho'..trailCount,0,stepCrochet*0.001*8,'cubeOut')
        --tweenActorProperty('boyfriend', 'x', defaultBFX+(pushDist*5), stepCrochet*0.001*4, 'cubeOut')
    else
        disableRanged = false
        disableBlock = false
    end
end

function onTweenCompleted(tag)
    if (string.match(tag,'dadEcho') or string.match(tag,'boyfriendEcho',0) or string.match(tag,'punchSplash',0)) and string.match(tag,'Alpha') then
        local s = string.gsub(tag,'Alpha','')
        removeLuaSprite(s,true)
    end
end

function doHealthDrain()
    if getHealth() - 0.008 > 0.09 then
        setHealth(getHealth() - 0.008)
    else
        setHealth(0.035)
    end
end

function chracterAnim(character,anim)
    characterPlayAnim(character,anim,true)
    setProperty(character..'.specialAnim',true)
end

function getCharX(character)
    if character == 'bf' or character == 'boyfriend' then
        return getProperty('boyfriend.x')- getProperty('boyfriend.positionArray[0]')
    elseif character == 'dad' then
        return getProperty('dad.x') - getProperty('dad.positionArray[0]')
    end
end
function getCharY(character)
    if character == 'bf' or character == 'boyfriend' then
        return getProperty('boyfriend.y') - getProperty('boyfriend.positionArray[1]')
    elseif character == 'dad' then
        return getProperty('dad.y') - getProperty('dad.positionArray[1]')
    end
end
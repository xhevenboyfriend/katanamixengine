local flipMatt = false
local matts = {}
local mattParry = false
local mattNotes = {}
local voiidParrys = {}
local parryTime = 583
local waitForParry = true
function onCreatePost()
    for notes = 0,getProperty('unspawnNotes.length')-1 do
        local type = getPropertyFromGroup('unspawnNotes',notes,'noteType')
        local strum = getPropertyFromGroup('unspawnNotes',notes,'strumTime')
        if songName == 'Alter Ego' and strum > 90000 and strum < 103300 then
            goto continue
        end
		if type == 'Wiik3Punch' or type == 'Wiik4Sword' or type == 'BoxingMatchPunch' then
            table.insert(mattNotes,{type,strum})
        elseif type == 'VoiidParry' then
            --table.insert(voiidParrys,{type,strum})
            table.insert(voiidParrys,strum)
		end
        ::continue::
    end

    if #mattNotes > 0 then
        createMatt('attack')
        createMatt('boxing')
        createMatt('sword')
        setProperty('MattStandattack0.alpha',0.01)
        setProperty('MattStandsword2.alpha',0.01)
        setProperty('MattStandboxing1.alpha',0.01)

    end
    detectParry()
    if #voiidParrys > 0 then
        createMatt('parry')
        setProperty('MattStandParry.alpha',0.01)
        makeAnimatedLuaSprite('flamePunch', 'FireGlove', 0, 0)
        addAnimationByPrefix('flamePunch', 'FireGlove', 'FireGlove', 24, true)
        setProperty('flamePunch.acceleration.x',3000)
        --objectPlayAnimation('flamePunch', 'FireGlove', true)
        setProperty('flamePunch.alpha',0.001)
        addLuaSprite('flamePunch',false)
    end

end
function detectParry()
    mattParry = false
    if getProperty('dad.curCharacter') == 'TKOMattDark' or getProperty('dad.curCharacter') == 'Wiik3VoiidMatt' then
        mattParry = true
    end
end
function onEvent(name,v1,v2)
	if name == 'flip echo direction' then
		flipMatt = not flipMatt
    elseif name == 'Change Character' then
        detectParry()
	end
end
function createMatt(type)
    local file = ''
    local anim = 'attack'
    local x = -10
	local y = 0
    if type == nil then
        type = 'attack'
    end
    if not flipMatt then
		x = getProperty('boyfriend.x') - 1000 + (math.random(-150,50))
	else
		x = getProperty('boyfriend.x') - 150 + (math.random(-150,50))
	end
    if type == 'attack' then
        file = 'characters/MattStand_Attack'
        y = getProperty('boyfriend.y') - 150 + math.random(-10,10)
        
    elseif type == 'sword' then
        file = 'characters/wiik3_standslash'
        anim = 'attack'
        y = getProperty('boyfriend.y') - 450 + math.random(-10,10)
        x = x + -400
    elseif type == 'boxing' then
        file = 'characters/Wiik_2_Echo'
        x = x + 400
        y = getProperty('boyfriend.y') - 450 + math.random(-10,10)
    elseif type == 'parry'  then
        file = 'Wiik3Matt'
        if getProperty('dad.curCharacter') == 'TKOMattDark' then
            file = 'characters/TKODarkMatt'
        else
            file = 'characters/Wiik3Matt'
        end
        anim = 'Matt Attack FistThrow'
        x = getProperty('dad.x') - 360
        y = getProperty('dad.y') - 120
    end
    if file == '' then
        return
    end
    local name = 'MattStand'..type..(#matts)
    if type == 'parry' then
        name = 'MattStandParry'
    end
	table.insert(matts,{name,type})
	makeAnimatedLuaSprite(name,file,x,y)
	scaleObject(name,1.5,1.5)
    if string.match(type,'parry',0) == nil then
	    setProperty(name..'.flipX',flipMatt)
    end
	addAnimationByPrefix(name,'anim',anim,24,false)
	objectPlayAnimation(name,'anim',true)
	setObjectOrder(name,getObjectOrder('boyfriendGroup') + 2)
	addLuaSprite(name,false)
end
function onUpdate()
    local songPos = getSongPosition()
    if #mattNotes > 0 then
        for notes = 1,#mattNotes do
            local noteType = mattNotes[notes][1]
            local timeSub = mattNotes[notes][2] - songPos
            if noteType == 'BoxingMatchPunch' and timeSub >= 550 or timeSub >= 350 and noteType ~= 'BoxingMatchPunch' then
                break
            end
            table.remove(mattNotes,notes)
            if timeSub >= 0 then
                if noteType == 'Wiik4Sword' then
                    createMatt('sword')
                elseif noteType == 'BoxingMatchPunch' then
                    createMatt('boxing')
                else
                    createMatt('attack')
                end
            end
        end
    end
    if #matts > 0 then
        for ma = 1,#matts do
            local name = matts[ma][1]
            if luaSpriteExists(name) then
                if getProperty(name..'.animation.curAnim.finished') == true then
                    local type = matts[ma][2]
                    if type ~= 'sword' and type ~= 'parry' then
                        removeLuaSprite(name,true)
                    elseif type == 'sword' then
                        doTweenAlpha(name..'Alpha',name,0,stepCrochet*0.001*4,'cubeIn')
                    elseif type == 'parry' then
                        --removeLuaSprite(name,true)
                        --setProperty('dad.visible',true)
                    end
                    table.remove(matts,ma)
                end
            else
                table.remove(matts,ma)
            end
        end
    end
    if #voiidParrys > 0 and mattParry then
        for parrys = 1,#voiidParrys do
            local time = voiidParrys[parrys]
            if songPos < time - parryTime then
                break
            end
        
            if waitForParry and songPos < time then
                cancelTween('mattParryX')
                createMatt('parry')
                doTweenX('mattParryX','MattStandParry',getProperty('dad.x')-360-450,parryTime*0.001,'cubeOut')

                setProperty('dad.visible',false)
                waitForParry = false
            end
            if not waitForParry then
                if songPos > time + 100 then
                    setProperty('flamePunch.x',getProperty('dad.x')-350)
                    setProperty('flamePunch.y',getProperty('dad.y'))
                    setObjectOrder('flamePunch',getObjectOrder('boyfriendGroup')+3)
                    setProperty('flamePunch.alpha',1)
                    doTweenX('mattParryX','MattStandParry',getProperty('dad.x')-360,parryTime*0.001,'cubeIn')
                    waitForParry = true
                end
                if voiidParrys[parrys - 1] ~= nil then
                    table.remove(voiidParrys,parrys)
                end
            end
            if songPos > time + 700 then
                table.remove(voiidParrys,parrys)
                removeLuaSprite('MattStandParry',true)
                setProperty('dad.visible',true)
            end
        end
    end
end
function onTweenCompleted(tag)
    if string.match(tag,'MattStand') and string.match(tag,'Alpha') then
        local s = string.gsub(tag,'Alpha','')
        removeLuaSprite(s,true)
    end
end
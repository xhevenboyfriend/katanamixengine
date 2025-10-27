function makeNoteCopy(name,id,data)
    local noteTexture = getPropertyFromGroup('notes',id,'texture')
    if noteTexture == '' or noteTexture == nil then
        noteTexture = 'noteSkins/NOTE_assets'
    end
    if getPropertyFromGroup('notes',id,'visible') then
            --makeAnimatedLuaSprite(name,noteTexture,getPropertyFromGroup('strumLineNotes',data,'x'),getPropertyFromGroup('strumLineNotes',data,'y'))
        makeAnimatedLuaSprite(name,noteTexture,getPropertyFromGroup('notes',id,'x'),getPropertyFromGroup('notes',id,'y'))
        local anim = getPropertyFromGroup('notes',id,'animation.frameName')
        addAnimationByPrefix(name,getPropertyFromGroup('notes',id,'animation.curAnim.name'),string.sub(anim,0,string.len(anim) - 3),getPropertyFromGroup('notes',id,'animation.curAnim.frameRate'),getPropertyFromGroup('notes',id,'animation.curAnim.looped'))
        setObjectCamera(name,'hud')
        scaleObject(name,getPropertyFromGroup('notes',id,'scale.x'),getPropertyFromGroup('notes',id,'scale.y'))
        setProperty(name..'.offset.x',getPropertyFromGroup('notes',id,'offset.x'))
        setProperty(name..'.offset.y',getPropertyFromGroup('notes',id,'offset.y'))
        setProperty(name..'.angle',getPropertyFromGroup('notes',id,'angle'))
        setProperty(name..'.alpha',getPropertyFromGroup('notes',id,'alpha'))
        addLuaSprite(name,true)
    end
end


function makeSpriteCopy(tag,sprite,directory,isAnimated)
    local character = false
    if sprite == 'boyfriend' or sprite == 'gf' or sprite == 'dad' then
        character = true
        if directory == nil then
            directory = getProperty(sprite..'.imageFile')
        end
    end
    if isAnimated then
        makeAnimatedLuaSprite(tag,directory,getProperty(sprite..'.x'),getProperty(sprite..'.y'))
        local anim = getProperty(sprite..'.animation.frameName')
        addAnimationByPrefix(tag,'anim',string.sub(anim,0,#anim - 3),getProperty(sprite..'.animation.curAnim.frameRate'),getProperty(sprite..'.animation.curAnim.looped'))
    else
        makeLuaSprite(tag,directory,getProperty(sprite..'.x'),getProperty(sprite..'.y'))
    end
    --setObjectCamera(tag,'hud')

    setProperty(tag..'.angle',getProperty(sprite..'.angle'))
    setProperty(tag..'.alpha',getProperty(sprite..'.alpha'))
    scaleObject(tag,getProperty(sprite..'.scale.x'),getProperty(sprite..'.scale.y'))
    addLuaSprite(tag,false)
    if not character then
        setObjectOrder(tag,getObjectOrder(sprite))
        --scaleObject(tag,getProperty(sprite..'.scale.x'),getProperty(sprite..'.scale.y'))
    else
        setObjectOrder(tag,getObjectOrder(sprite..'Group'))
        --scaleObject(tag,getProperty(sprite..'.scale.x') + (getProperty(sprite..'.jsonScale') - 1),getProperty(sprite..'.scale.y') + (getProperty(sprite..'.jsonScale') - 1))
    end
    setProperty(tag..'.offset.x',getProperty(sprite..'.offset.x'))
    setProperty(tag..'.offset.y',getProperty(sprite..'.offset.y'))
end

function playerDodge(random,data)
    local bfCharacter = getProperty('boyfriend.curCharacter')
    local bfAnims = {
        'Wiik3BFRTX',
        '',
        'TKOBFOnii',
        'Wiik3BFOnii',
        'Wiik2BFRTX',
        'Wiik100BF'
    }

    for bfs = 1,#bfAnims do
        if bfCharacter == bfAnims[bfs] then
            local dodges = {'LEFT','DOWN','UP','RIGHT'}
            if random ~= false then
                playAnim('boyfriend','dodge'..dodges[math.random(1,#dodges)],true)
            else
                playAnim('boyfriend','dodge'..dodges[data + 1],true)
            end
            setProperty('boyfriend.specialAnim',true)
            return
        end
    end
    playAnim('boyfriend','dodge',true)
    setProperty('boyfriend.specialAnim',true)
end
function updateStage()
    if version >= '0.7' then
        setVar('stageLuas',getStageLuas(true))
    else
        local stages = getStageLuas(true)
        local array = '['
        for i, stage in pairs(stages) do
            array = array..'"'..stage
            if i < #stages then
                array = array..'",'
            end
        end
        array = array..'"]'
        runHaxeCode(
            [[
                setVar("stageLuas",]]..array..[[);
                
                return;
            ]]
        )
    end
end
function onCreate()
    if version >= '0.7' then
        setVar('stageLuas',nil)
    else
        runHaxeCode(
            [[
                setVar('stageLuas',[]);
                return;
            ]]
        )
    end
end
function onCreatePost()
    updateStage()
end
function getStageLuas(stages)
    local stageFiles = runHaxeCode(
        [[
            var luaSprites = [];
            
            for(k in game.modchartSprites.keys()){
                var luaObject = game.getLuaObject(k);
                if(luaObject.cameras[0] == game.camGame && game.members.contains(luaObject)){
                    luaSprites.push(k);
                }
            }
            return luaSprites;
        ]]
    )
    
    if stages ~= false and #stageFiles > 0 then
        local copyStage = {}
        local notStage = {
            'mattShield',
            'bfShield',
            'auraMatt',
        }
        local stringFind = {
            'MattStand',
            'Echo',
            'rainGraphic',
            'boyfriendGhost',
            'dadGhost',
            'gfGhost'
        }
        for i,luaN in ipairs(stageFiles) do
            for dont = 1,#notStage do
                if luaN == notStage[dont] then
                    goto next
                end
            end
            for find = 1,#stringFind do
                if string.match(luaN,stringFind[find]) ~= nil then
                    goto next
                end
            end
            table.insert(copyStage,luaN)
            ::next::
        end
        stageFiles = copyStage
    end

    return stageFiles
end
function setStageColorSwap(var,value,tween,time,easing)
    local spriteCreated = getStageLuas()
    --table.insert(spriteCreated,'boyfriend')
    --table.insert(spriteCreated,'dad')
    --table.insert(spriteCreated,'gf')
    for i,stages in pairs(spriteCreated) do
        if not tween then
            setProperty(stages..'.'..var,value)
        else
            if var == 'color' then
                doTweenColor(stages..'Color',stages,value,time,easing)
            end
        end
    end
end
function showOnlyStrums(show)
    if not hideHud then
        setProperty('healthBar.visible',not show)
        setProperty('scoreTxt.visible',not show)
        setProperty('iconP1.visible',not show)
        setProperty('iconP2.visible',not show)

        setProperty('timeBarVoiid.visible',not show and timeBarType ~= 'Disabled')
        setProperty('timeTxtVoiid.visible',not show and timeBarType ~= 'Disabled')

        if version < '0.7' then
            setProperty('healthBarBG.visible',not show)
            setProperty('timeBarBG.visible',not show and timeBarType ~= 'Disabled')
        else
            setProperty('timeBar.bg.visible',not show and timeBarType ~= 'Disabled')
        end
        --setProperty('timeBar.visible',not show and timeBarType ~= 'Disabled')
    end
end
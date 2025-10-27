function onCreate()
    if version < '0.7' then
        setPropertyFromClass('PlayState','SONG.arrowSkin','noteSkins/NOTE_assets')
        setPropertyFromClass('PlayState','SONG.splashSkin','noteSplashes/noteSplashes')
    else
        if getPropertyFromClass('backend.ClientPrefs','data.noteSkin') == 'Default' then
            setPropertyFromClass('states.PlayState','SONG.disableNoteRGB',true)
        end
    end
    precacheImage('noteSplashes/noteSplashes')
end
function onDestroy()
    if version >= '0.7' then
        if getPropertyFromClass('backend.ClientPrefs','data.noteSkin') == 'Default' then
            setPropertyFromClass('states.PlayState','SONG.disableNoteRGB',false)
        end
    else
        setPropertyFromClass('PlayState','SONG.arrowSkin','')
        setPropertyFromClass('PlayState','SONG.splashSkin','')
    end
end
function goodNoteHit(id,data,type,sus)
    --if getPropertyFromGroup('notes',id,'rating') == 'sick' then
    if not sus and getPropertyFromGroup('notes',id,'rating') == 'sick' then
        for splash = 0,getProperty('grpNoteSplashes.length') do
            setPropertyFromGroup('grpNoteSplashes',splash,'shader',nil)
            setPropertyFromGroup('grpNoteSplashes',splash,'scale.x',1.2)
            setPropertyFromGroup('grpNoteSplashes',splash,'scale.y',1.2)
            if version < '0.7' then
                setPropertyFromGroup('grpNoteSplashes',splash,'offset.x',-70)
                setPropertyFromGroup('grpNoteSplashes',splash,'offset.y',-70)
            end
            --updateHitboxFromGroup('grpNoteSplashes',splash)
        end
    end
end
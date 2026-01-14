package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mikolka.compatibility.VsliceOptions;
import mikolka.compatibility.ModsHelper;

class MainMenuState extends MusicBeatState
{
    // Versões mantidas do código original [cite: 4, 10]
    public static var pSliceVersion:String = '3.4';
    public static var funkinVersion:String = '0.7.6';

    var bg:FlxSprite;
    var sideBar:FlxSprite;
    var character:FlxSprite;
    var header:FlxSprite;
    
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = ['PLAY', 'FREEPLAY', 'OPTIONS', 'SHOP'];
    var curSelected:Int = 0;

    override function create()
    {
        // Limpeza de cache baseada no MainMenuState original [cite: 6]
        CacheSystem.clearStoredMemory();
        CacheSystem.clearUnusedMemory();

        persistentUpdate = persistentDraw = true;

        // 1. Fundo Quadriculado (bg.png)
        bg = new FlxSprite().loadGraphic(Paths.image('lobbymainmenu/bg'));
        bg.antialiasing = VsliceOptions.ANTIALIASING; [cite: 8]
        bg.scrollFactor.set(0, 0);
        bg.screenCenter();
        add(bg);

        // 2. Linha/Barra Lateral (line_purple.png)
        sideBar = new FlxSprite(500, 0).loadGraphic(Paths.image('lobbymainmenu/line_purple'));
        sideBar.antialiasing = VsliceOptions.ANTIALIASING;
        sideBar.scrollFactor.set(0, 0);
        add(sideBar);

        // 3. Personagem (nexus.png)
        character = new FlxSprite(650, 150).loadGraphic(Paths.image('lobbymainmenu/nexus'));
        character.antialiasing = VsliceOptions.ANTIALIASING;
        character.scrollFactor.set(0, 0);
        character.setGraphicSize(Std.int(character.width * 0.8));
        add(character);

        // 4. Cabeçalho (menu display.png)
        header = new FlxSprite(40, 40).loadGraphic(Paths.image('lobbymainmenu/menu display'));
        header.antialiasing = VsliceOptions.ANTIALIASING;
        header.scrollFactor.set(0, 0);
        add(header);

        // 5. Botões do Menu (PLAY, FREEPLAY, OPTIONS, SHOP)
        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        for (i in 0...optionShit.length)
        {
            var menuItem:FlxSprite = new FlxSprite(0, 0);
            // Busca cada botão na pasta lobbymainmenu
            menuItem.loadGraphic(Paths.image('lobbymainmenu/' + optionShit[i]));
            menuItem.antialiasing = VsliceOptions.ANTIALIASING;
            menuItem.ID = i;

            // Organização em Grid conforme a screenshot LobbyMenu.png
            var col:Int = i % 2;
            var row:Int = Std.int(i / 2);

            menuItem.x = 60 + (col * 240);
            menuItem.y = 250 + (row * 180);
            
            menuItems.add(menuItem);
        }

        // Rodapé com versões [cite: 10, 11]
        var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);
        fnfVer.scrollFactor.set();
        fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(fnfVer);

        changeSelection();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music.volume < 0.8)
            FlxG.sound.music.volume += 0.5 * elapsed;

        if (controls.UI_LEFT_P) changeSelection(-1);
        if (controls.UI_RIGHT_P) changeSelection(1);
        if (controls.UI_UP_P) changeSelection(-2);
        if (controls.UI_DOWN_P) changeSelection(2);

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new TitleState()); [cite: 1]
        }

        if (controls.ACCEPT)
        {
            var daChoice:String = optionShit[curSelected];
            switch (daChoice)
            {
                case 'FREEPLAY':
                    MusicBeatState.switchState(new mikolka.vslice.freeplay.FreeplayState());
                case 'OPTIONS':
                    MusicBeatState.switchState(new options.OptionsState());
            }
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;
        if (curSelected < 0) curSelected = optionShit.length - 1;
        if (curSelected >= optionShit.length) curSelected = 0;

        menuItems.forEach(function(spr:FlxSprite)
        {
            spr.alpha = 0.6;
            if (spr.ID == curSelected) spr.alpha = 1;
            spr.updateHitbox();
        });

        if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}

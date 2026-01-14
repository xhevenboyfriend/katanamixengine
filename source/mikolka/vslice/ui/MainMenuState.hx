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
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        persistentUpdate = persistentDraw = true;

        // 1. Fundo Quadriculado
        bg = new FlxSprite().loadGraphic(Paths.image('bg'));
        bg.antialiasing = VsliceOptions.ANTIALIASING;
        bg.scrollFactor.set(0, 0);
        bg.screenCenter();
        add(bg);

        // 2. Linha/Barra Lateral Roxa (Atrás do personagem)
        sideBar = new FlxSprite(500, 0).loadGraphic(Paths.image('line_purple'));
        sideBar.antialiasing = VsliceOptions.ANTIALIASING;
        sideBar.scrollFactor.set(0, 0);
        add(sideBar);

        // 3. Personagem (Nexus)
        character = new FlxSprite(650, 150).loadGraphic(Paths.image('nexus'));
        character.antialiasing = VsliceOptions.ANTIALIASING;
        character.scrollFactor.set(0, 0);
        character.setGraphicSize(Std.int(character.width * 0.8)); // Ajuste de escala
        add(character);

        // 4. Cabeçalho (Main Menu Lobby)
        header = new FlxSprite(40, 40).loadGraphic(Paths.image('menu_display'));
        header.antialiasing = VsliceOptions.ANTIALIASING;
        header.scrollFactor.set(0, 0);
        add(header);

        // 5. Botões do Menu (Grid 2x2)
        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        for (i in 0...optionShit.length)
        {
            var offset:Float = 100;
            var menuItem:FlxSprite = new FlxSprite(0, 0);
            menuItem.loadGraphic(Paths.image(optionShit[i]));
            menuItem.antialiasing = VsliceOptions.ANTIALIASING;
            menuItem.ID = i;

            // Posicionamento em Grid 2x2
            // Coluna 0 (Esquerda), Coluna 1 (Direita)
            var col:Int = i % 2;
            var row:Int = Std.int(i / 2);

            menuItem.x = 60 + (col * 240); // Espaçamento horizontal
            menuItem.y = 250 + (row * 180); // Espaçamento vertical
            
            menuItems.add(menuItem);
        }

        // Textos de Versão
        var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);
        fnfVer.scrollFactor.set();
        fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(fnfVer);

        changeSelection();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music.volume < 0.8)
            FlxG.sound.music.volume += 0.5 * elapsed;

        // Controles de navegação básicos
        if (controls.UI_LEFT_P) changeSelection(-1);
        if (controls.UI_RIGHT_P) changeSelection(1);
        if (controls.UI_UP_P) changeSelection(-2);
        if (controls.UI_DOWN_P) changeSelection(2);

        if (controls.ACCEPT)
        {
            var daChoice:String = optionShit[curSelected];
            switch (daChoice)
            {
                case 'PLAY':
                    // Adicione sua lógica de Story Mode aqui
                case 'FREEPLAY':
                    MusicBeatState.switchState(new mikolka.vslice.freeplay.FreeplayState());
                case 'OPTIONS':
                    MusicBeatState.switchState(new options.OptionsState());
                case 'SHOP':
                    // Adicione lógica da loja se houver
            }
        }

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new mikolka.vslice.ui.title.TitleState());
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
            spr.alpha = 0.6; // Botão não selecionado fica mais escuro
            spr.scale.set(1, 1);

            if (spr.ID == curSelected)
            {
                spr.alpha = 1; // Botão selecionado brilha
                spr.scale.set(1.05, 1.05); // Pequeno zoom ao selecionar
            }
            spr.updateHitbox();
        });

        if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}

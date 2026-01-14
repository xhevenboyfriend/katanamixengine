package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mikolka.vslice.ui.mainmenu.DesktopMenuState;
import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.ModsHelper;
import options.OptionsState;
import backend.Paths;
import backend.MusicBeatState;
import backend.DiscordClient;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; 
	public static var pSliceVersion:String = '3.4';
	public static var funkinVersion:String = '0.7.6';

	var bg:FlxSprite;
	var sideBar:FlxSprite;
	var character:FlxSprite;
	var header:FlxSprite;
	var magenta:FlxSprite;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = ['PLAY', 'FREEPLAY', 'OPTIONS', 'SHOP'];
	var curSelected:Int = 0;
	var stickerSubState:Bool;

	public function new(?stickers:Bool = false)
	{
		super();
		stickerSubState = stickers;
	}

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(stickerSubState) ModsHelper.clearStoredWithoutStickers();
		else CacheSystem.clearStoredMemory();
		CacheSystem.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		// 1. Fundo (assets/shared/images/lobbymainmenu/bg.png)
		bg = new FlxSprite().loadGraphic(Paths.image('lobbymainmenu/bg'));
		bg.antialiasing = VsliceOptions.ANTIALIASING;
		bg.screenCenter();
		add(bg);

		// 2. Barra Lateral (assets/shared/images/lobbymainmenu/line_purple.png)
		sideBar = new FlxSprite(550, 0).loadGraphic(Paths.image('lobbymainmenu/line_purple'));
		sideBar.antialiasing = VsliceOptions.ANTIALIASING;
		add(sideBar);

		// 3. Personagem (assets/shared/images/lobbymainmenu/nexus.png)
		character = new FlxSprite(600, 100).loadGraphic(Paths.image('lobbymainmenu/nexus'));
		character.antialiasing = VsliceOptions.ANTIALIASING;
		character.setGraphicSize(Std.int(character.width * 0.8));
		character.updateHitbox();
		add(character);

		// 4. Cabeçalho (assets/shared/images/lobbymainmenu/menu display.png)
		header = new FlxSprite(40, 40).loadGraphic(Paths.image('lobbymainmenu/menu display'));
		header.antialiasing = VsliceOptions.ANTIALIASING;
		add(header);

		// 5. Botões
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.loadGraphic(Paths.image('lobbymainmenu/' + optionShit[i]));
			menuItem.antialiasing = VsliceOptions.ANTIALIASING;
			menuItem.ID = i;

			var col:Int = i % 2;
			var row:Int = Std.int(i / 2);

			menuItem.x = 80 + (col * 260);
			menuItem.y = 280 + (row * 160);
			menuItems.add(menuItem);
		}

		// Versões [cite: 10, 11]
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed; [cite: 15]

		if (controls.UI_LEFT_P) changeSelection(-1);
		if (controls.UI_RIGHT_P) changeSelection(1);
		if (controls.UI_UP_P) changeSelection(-2);
		if (controls.UI_DOWN_P) changeSelection(2);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}

		if (controls.ACCEPT)
		{
			var daChoice:String = optionShit[curSelected];
			switch (daChoice)
			{
				case 'FREEPLAY':
					MusicBeatState.switchState(new mikolka.vslice.freeplay.FreeplayState());
				case 'OPTIONS':
					MusicBeatState.switchState(new OptionsState());
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
		});
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import mikolka.vslice.ui.mainmenu.DesktopMenuState;
import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.ModsHelper;
import options.OptionsState;

// Importações de compatibilidade para Psych Engine (Backend)
#if !LEGACY_PSYCH
import backend.Paths;
import backend.MusicBeatState;
import backend.ClientPrefs;
import backend.DiscordClient;
#else
import Paths;
import MusicBeatState;
import ClientPrefs;
#end

class MainMenuState extends MusicBeatState
{
	#if !LEGACY_PSYCH
	public static var psychEngineVersion:String = '1.0.4';
	#else
	public static var psychEngineVersion:String = '0.6.3';
	#end
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

		// Limpeza de cache conforme o seu script original
		if(stickerSubState) ModsHelper.clearStoredWithoutStickers();
		else CacheSystem.clearStoredMemory();
		CacheSystem.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		// 1. Fundo (bg.png)
		bg = new FlxSprite().loadGraphic(Paths.image('lobbymainmenu/bg'));
		bg.antialiasing = VsliceOptions.ANTIALIASING;
		bg.scrollFactor.set(0, 0);
		bg.screenCenter();
		add(bg);

		// 2. Linha Roxa Lateral (line_purple.png)
		sideBar = new FlxSprite(580, 0).loadGraphic(Paths.image('lobbymainmenu/line_purple'));
		sideBar.antialiasing = VsliceOptions.ANTIALIASING;
		sideBar.scrollFactor.set(0, 0);
		add(sideBar);

		// 3. Personagem (nexus.png)
		character = new FlxSprite(650, 120).loadGraphic(Paths.image('lobbymainmenu/nexus'));
		character.antialiasing = VsliceOptions.ANTIALIASING;
		character.scrollFactor.set(0, 0);
		character.setGraphicSize(Std.int(character.width * 0.85));
		character.updateHitbox();
		add(character);

		// 4. Logo do Menu (menu_display.png) - Lembre-se de renomear o arquivo!
		header = new FlxSprite(60, 50).loadGraphic(Paths.image('lobbymainmenu/menu_display'));
		header.antialiasing = VsliceOptions.ANTIALIASING;
		header.scrollFactor.set(0, 0);
		add(header);

		// 5. Botões (Grid 2x2 como na Screenshot_18)
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.loadGraphic(Paths.image('lobbymainmenu/' + optionShit[i]));
			menuItem.antialiasing = VsliceOptions.ANTIALIASING;
			menuItem.ID = i;

			// Lógica de Grid 2x2
			var col:Int = i % 2;
			var row:Int = Std.int(i / 2);
			menuItem.x = 80 + (col * 240);
			menuItem.y = 280 + (row * 180);
			
			menuItems.add(menuItem);
		}

		// Textos de Versão (Mantendo o padrão do seu original)
		var psychVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, "Psych Engine " + psychEngineVersion, 12);
		var fnfVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		psychVer.scrollFactor.set();
		fnfVer.scrollFactor.set();
		add(psychVer);
		add(fnfVer);

		changeSelection();

		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			MainMenuHooks.unlockFriday();
		#end

		super.create();

		// Suporte para Mobile (Mantido do seu original)
		#if TOUCH_CONTROLS_ALLOWED
		if (controls.mobileC)
			new mobile.states.MobileMenuState(this);
		#end
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P) changeSelection(-1);
			if (controls.UI_RIGHT_P) changeSelection(1);
			if (controls.UI_UP_P) changeSelection(-2);
			if (controls.UI_DOWN_P) changeSelection(2);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectItem();
			}
		}

		super.update(elapsed);
	}

	var selectedSomethin:Bool = false;

	function selectItem()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
		{
			var daChoice:String = optionShit[curSelected];
			switch (daChoice)
			{
				case 'PLAY':
					// Coloque aqui o estado do Story Mode ou Campanha
				case 'FREEPLAY':
					MusicBeatState.switchState(new mikolka.vslice.freeplay.FreeplayState());
				case 'OPTIONS':
					MusicBeatState.switchState(new OptionsState());
				case 'SHOP':
					// Estado da Loja
					selectedSomethin = false; 
			}
		});
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0) curSelected = optionShit.length - 1;
		if (curSelected >= optionShit.length) curSelected = 0;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0.5;
			spr.scale.set(0.9, 0.9);
			if (spr.ID == curSelected)
			{
				spr.alpha = 1;
				spr.scale.set(1.05, 1.05);
			}
			spr.updateHitbox();
		});

		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

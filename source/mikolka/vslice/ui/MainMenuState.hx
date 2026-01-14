package; // Se estiver no P-Slice, talvez precise ser: package mikolka.vslice.ui;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // Ajuste conforme sua versão
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	// Nomes das imagens dos botões na ordem correta
	var optionShit:Array<String> = [
		'PLAY',     // 0
		'FREEPLAY', // 1
		'OPTIONS',  // 2
		'SHOP'      // 3
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if desktop
		// Atualiza o Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		// 1. FUNDO (bg.png)
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(0, 0); // Ajuste conforme necessário
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg')); // Reusando BG para efeito rosa
		magenta.scrollFactor.set(0, 0);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// 2. FAIXA ROXA (line_purple.png) - Lado Direito
		var purpleLine:FlxSprite = new FlxSprite(FlxG.width * 0.5, 0).loadGraphic(Paths.image('mainmenu/line_purple'));
		purpleLine.antialiasing = ClientPrefs.data.antialiasing;
		// Ajuste a posição X para ficar igual ao print
		purpleLine.x = FlxG.width - purpleLine.width + 100; 
		purpleLine.screenCenter(Y);
		add(purpleLine);

		// 3. PERSONAGEM (nexus.png) - Lado Direito
		var charNexus:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/nexus'));
		charNexus.antialiasing = ClientPrefs.data.antialiasing;
		charNexus.setGraphicSize(Std.int(charNexus.width * 0.9)); // Ajuste tamanho se precisar
		charNexus.updateHitbox();
		// Posicionar sobre a linha roxa
		charNexus.x = purpleLine.x + (purpleLine.width / 2) - (charNexus.width / 2);
		charNexus.screenCenter(Y);
		add(charNexus);

		// 4. CABEÇALHO (display.png) - Topo Esquerdo
		var header:FlxSprite = new FlxSprite(50, 30).loadGraphic(Paths.image('mainmenu/display'));
		header.antialiasing = ClientPrefs.data.antialiasing;
		add(header);

		// 5. BOTÕES (Grid 2x2)
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// Configuração das posições base
		var startX:Float = 100;
		var startY:Float = 200;
		var paddingX:Float = 320; // Espaço horizontal entre botões
		var paddingY:Float = 180; // Espaço vertical entre botões

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.loadGraphic(Paths.image('mainmenu/' + optionShit[i]));
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.ID = i;

			// Lógica de Grid:
			// 0 (Play) e 2 (Options) ficam na esquerda
			// 1 (Freeplay) e 3 (Shop) ficam na direita
			var isRightSide:Bool = (i % 2 != 0); // Ímpar = Direita
			var isBottomRow:Bool = (i >= 2);     // Maior que 1 = Linha de baixo

			menuItem.x = startX + (isRightSide ? paddingX : 0);
			menuItem.y = startY + (isBottomRow ? paddingY : 0);

			menuItems.add(menuItem);
		}

		// Texto de versão
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			// Controles de Grade (Grid)
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-2); // Pula 2 para trás (sobe uma linha)
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(2); // Pula 2 para frente (desce uma linha)
			}

			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1); // Vai para esquerda
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1); // Vai para direita
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					// Link de doação se necessário
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'PLAY':
										MusicBeatState.switchState(new StoryMenuState());
									case 'FREEPLAY':
										MusicBeatState.switchState(new FreeplayState());
									case 'OPTIONS':
										// Ajuste para P-Slice ou Engine padrão
										MusicBeatState.switchState(new options.OptionsState());
									case 'SHOP':
										// MusicBeatState.switchState(new ShopState());
										trace("Shop ainda não implementado!");
										selectedSomethin = false; // Retorna controle se não tiver Shop
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		// Lógica de loop da grade
		if (curSelected >= menuItems.length)
			curSelected = curSelected % menuItems.length; // Volta para o início
		if (curSelected < 0)
			curSelected = menuItems.length + curSelected; // Vai para o fim

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				// Item Selecionado: 100% visível e um pouco maior
				spr.alpha = 1;
				spr.scale.set(1.05, 1.05); 
			}
			else
			{
				// Item Não Selecionado: 60% visível
				spr.alpha = 0.6;
				spr.scale.set(1, 1);
			}
		});
	}
}

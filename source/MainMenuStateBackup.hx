package;

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
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
using StringTools;
import FlxVideo;
import flixel.util.FlxTimer;
class MainMenuStateBackup extends MusicBeatState
{
	
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	#if IS_CORRUPTION
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];
#else
var optionShit:Array<String> = [
	'story_mode',
	'freeplay',
	#if MODS_ALLOWED 'mods', #end
	#if ACHIEVEMENTS_ALLOWED 'awards', #end
	'credits',
	#if !switch 'donate', #end
	'options'
];
#end
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var bgMenu:FlxSprite = null;
	var bgGrid:FlxSprite = null;
	var menuItemsDark:FlxGroup;
	var menuItemsLight:FlxGroup;
	var darkbars:FlxGroup;
	var lightbars:FlxGroup;
	var charMenu:FlxSprite = null;
	var charEye:FlxSprite = null;
	var fire:FlxVideo = null;
	override function create()
	{
		#if !IS_CORRUPTION
		if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		#else
		if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenuCorr'), 0);
			}
		#end
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;
		#if IS_CORRUPTION

		var bg = new FlxSprite();
		bg.frames = FlxAtlasFrames.fromSparrow('windose_data/images/menu_bg.png', 'windose_data/images/menu_bg.xml');
		bg.animation.addByPrefix('bg', "halloweem bg0", 24);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.animation.play('bg');
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var back = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(back);

		fire = new FlxVideo();
		fire.playMP4(Paths.video('fire'), true, back);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);


		charMenu = new FlxSprite(0, 0).loadGraphic('windose_data/images/menu.png');
		charMenu.scrollFactor.set();
		charMenu.antialiasing = ClientPrefs.globalAntialiasing;
		add(charMenu);
	
		charEye = new FlxSprite(0, 0).loadGraphic('windose_data/images/menueye.png');
    charEye.scrollFactor.set();
    charEye.antialiasing = ClientPrefs.globalAntialiasing;
    charEye.visible = false;
    add(charEye);

	charMenu.x -= charMenu.width;
    charEye.x -= charEye.width;
		new FlxTimer().start(0.5, function(tmr)
			{
				FlxTween.tween(charMenu, {x: charMenu.x + charMenu.width}, 1.5, {ease: FlxEase.cubeOut});
				FlxTween.tween(charEye, {x: charEye.x + charEye.width}, 1.5, {ease: FlxEase.cubeOut});
			});
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		darkbars = new FlxGroup();
		add(darkbars);
		for (i in 0...4)
			{
				var menuItem:FlxSprite = new FlxSprite(790, 140 + (i * 110)).loadGraphic(FNFAssets.getBitmapData('windose_data/images/notselect.png'));
				menuItem.ID = i;
				darkbars.add(menuItem);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				menuItem.active = false;
			}
		
			lightbars = new FlxGroup();
			add(lightbars);
    
    for (i in 0...4)
    {
        var menuItem = new FlxSprite(660, 145 + (i * 110)).loadGraphic(FNFAssets.getBitmapData('windose_data/images/selected.png'));
        menuItem.ID = i;
        lightbars.add(menuItem);
        menuItem.antialiasing = ClientPrefs.globalAntialiasing;
        menuItem.active = false;
        menuItem.visible = false;
    }
	bgGrid = new FlxSprite(0, 0).loadGraphic(FNFAssets.getBitmapData('windose_data/images/seperators.png'));
    bgGrid.screenCenter();
    bgGrid.scrollFactor.set();
    add(bgGrid);

	menuItemsDark = new FlxGroup();
	add(menuItemsDark);
    
    for (i in 0...4)
    {
        var menuItem = new FlxSprite(750, 170 + (i * 110)).loadGraphic(FNFAssets.getBitmapData('windose_data/images/mainmenu' + i + '.png'));
        menuItem.ID = i;
        menuItemsDark.add(menuItem);
        menuItem.antialiasing = ClientPrefs.globalAntialiasing;
        menuItem.active = false;
    }

	menuItemsLight = new FlxGroup();
	add(menuItemsLight);
    
    for (i in 0...4)
    {
        var menuItem = new FlxSprite(750, 170 + (i * 110)).loadGraphic(FNFAssets.getBitmapData('windose_data/images/mainselected' + i + '.png'));
        menuItem.ID = i;
        menuItemsLight.add(menuItem);
        menuItem.antialiasing = ClientPrefs.globalAntialiasing;
        menuItem.active = false;
        menuItem.visible = false;
    }
		#else


		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);
		#end
		#if IS_CORRUPTION
		var leText:String = "Press 1 to Achievements Menu / Press 2 to Mod Menu.";
		var size:Int = 16;
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		#end
		var funniVerison:Array<String> = CoolUtil.coolTextFile(Paths.txt('verisons'));
		var engineName:String;
		var gameVersion:String;
		engineName = funniVerison[0];
		MainMenuState.RCEVersion = funniVerison[1];

		gameVersion = funniVerison[2];
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, engineName + MainMenuState.RCEVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "v" + gameVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);


		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				#if IS_CORRUPTION
				MusicBeatState.switchState(new TitleStateCorr());
				#else
				MusicBeatState.switchState(new TitleState());
				#end

			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play('windose_data/sounds/confirmMenu' + TitleState.soundExt);
				#if IS_CORRUPTION

	
				charEye.visible = true;
				FlxG.camera.flash(0xFFffffff, 1, null, true);



				new FlxTimer().start(1.1, function(tmr)
				{
					switch (optionShit[curSelected])
					{
						case 'story_mode':
							new FlxTimer().start(1.1, function(tmr)
								{
									if(FreeplayState.vocals != null) FreeplayState.vocals.fadeOut(1.2);
									FlxG.sound.music.fadeOut(1.2);
			
									new FlxTimer().start(1.2, function(tmr)
									{
											FlxG.sound.music.stop();
											if(FreeplayState.vocals != null) FreeplayState.vocals.stop();
											MusicBeatState.switchState(new StoryMenuStateCorr());
									});
								});

						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());

						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							LoadingState.loadAndSwitchState(new options.OptionsState());
					}
				});
				#else 
				if (optionShit[curSelected] == 'donate')
					{
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
					else
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
	
						if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
	
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
										case 'story_mode':
											MusicBeatState.switchState(new StoryMenuState());
	
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										#if MODS_ALLOWED
										case 'mods':
											MusicBeatState.switchState(new ModsMenuState());
										#end
										case 'awards':
											MusicBeatState.switchState(new AchievementsMenuState());
										case 'credits':
											MusicBeatState.switchState(new CreditsState());
										case 'options':
											LoadingState.loadAndSwitchState(new options.OptionsState());
									}
								});
							}
						});
					}
					
				#end
			}

			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			else if (FlxG.keys.justPressed.ONE)
				{
					selectedSomethin = true;
					MusicBeatState.switchState(new AchievementsMenuState());
				}
				else if (FlxG.keys.justPressed.TWO)
					{
						selectedSomethin = true;
						MusicBeatState.switchState(new ModsMenuState());
					}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		#if IS_CORRUPTION
		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;

		
		menuItemsDark.forEach(function(spr)
			{
				spr.visible = true;
				
				if (spr.ID == curSelected)
				{
					spr.visible = false;
				}
			});
	
			menuItemsLight.forEach(function(spr)
			{
				spr.visible = false;
				
				if (spr.ID == curSelected)
				{
					spr.visible = true;
				}
			});
	
			darkbars.forEach(function(spr)
			{
				spr.visible = true;
				
				if (spr.ID == curSelected)
				{
					spr.visible = false;
				}
			});
	
			lightbars.forEach(function(spr)
			{
				spr.visible = false;
				
				if (spr.ID == curSelected)
				{
					spr.visible = true;
				}
			});
		#else
		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		menuItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');
				spr.updateHitbox();
	
				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
					var add:Float = 0;
					if(menuItems.length > 4) {
						add = menuItems.length * 8;
					}
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
					spr.centerOffsets();
				}
			});
		#end
	}
}

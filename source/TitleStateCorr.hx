package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import TitleState;
using StringTools;
class TitleStateCorr extends MusicBeatState
{
	
		public static var initialized:Bool = false;
	
		var blackScreen:FlxSprite;
		var credGroup:FlxGroup;
		var credTextShit:Alphabet;
		var textGroup:FlxGroup;
		var ngSpr:FlxSprite;
		var startedIntro:Bool = false;
		var skippedIntro:Bool = false;
		var introPhase:Int = 0;
		var black:FlxSprite = null;
		var pressText:FlxSprite;
		var creepy:FlxSprite;
		//var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
		//var titleTextAlphas:Array<Float> = [1, .64];
		
		var curWacky:Array<String> = [];
	
		var wackyImage:FlxSprite;
	
		#if TITLE_SCREEN_EASTER_EGG
		var easterEggKeys:Array<String> = [
			'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
		];
		var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		var easterEggKeysBuffer:String = '';
		#end
	
		var mustUpdate:Bool = false;
	
		var titleJSON:TitleData;
	
		public static var updateVersion:String = '';
	
		override public function create():Void
		{
			Paths.clearStoredMemory();
			Paths.clearUnusedMemory();
	
	
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			pressText = new FlxSprite(100, FlxG.height * 0.8);
			pressText.frames = FlxAtlasFrames.fromSparrow(SUtil.getPath() + 'windose_data/images/titleEnter.png', 'windose_data/images/titleEnter.xml');
			pressText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			pressText.animation.addByPrefix('press', "ENTER PRESSED", 24);
			pressText.antialiasing = true;
			pressText.animation.play('idle');
			pressText.updateHitbox();
			pressText.alpha = 0.0001;
			pressText.active = false;
			#if LUA_ALLOWED
			Paths.pushGlobalMods();
			#end
			// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
			WeekData.loadTheFirstEnabledMod();
	
			//trace(path, FileSystem.exists(path));
	
			/*#if (polymod && !html5)
			if (sys.FileSystem.exists('mods/')) {
				var folders:Array<String> = [];
				for (file in sys.FileSystem.readDirectory('mods/')) {
					var path = haxe.io.Path.join(['mods/', file]);
					if (sys.FileSystem.isDirectory(path)) {
						folders.push(file);
					}
				}
				if(folders.length > 0) {
					polymod.Polymod.init({modRoot: "mods", dirs: folders});
				}
			}
			#end*/
	
			FlxG.game.focusLostFramerate = 60;
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			FlxG.keys.preventDefaultKeys = [TAB];
	
			PlayerSettings.init();
	
			curWacky = FlxG.random.getObject(getIntroTextShit());
	
			// DEBUG BULLSHIT
	
			super.create();
	
			FlxG.save.bind('funkin', 'raincandy_u');
	
			ClientPrefs.loadPrefs();
	
	
			Highscore.load();
	
			if(!initialized)
			{
				if(FlxG.save.data != null && FlxG.save.data.fullscreen)
				{
					FlxG.fullscreen = FlxG.save.data.fullscreen;
					//trace('LOADED FULLSCREEN SETTING!!');
				}
				persistentUpdate = true;
				persistentDraw = true;
			}
	
			if (FlxG.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			}
	
			FlxG.mouse.visible = false;
			#if FREEPLAY
			MusicBeatState.switchState(new FreeplayState());
			#elseif CHARTING
			MusicBeatState.switchState(new ChartingState());
			#else
			if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new FlashingState());
			} else {
				#if desktop
				if (!DiscordClient.isInitialized)
				{
					DiscordClient.initialize();
					Application.current.onExit.add (function (exitCode) {
						DiscordClient.shutdown();
					});
				}
				#end
	
				if (initialized){
					startedIntro = true;
					loaded();
					
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						startedIntro = true;
						loaded();
						
					});
				}
			}
			#end
		}
	
		var logoBl:FlxSprite;
		var gfDance:FlxSprite;
		var danceLeft:Bool = false;
		//var titleText:FlxSprite;
		var swagShader:ColorSwap = null;
	
		function startIntro()
		{
			if (!initialized)
			{
				/**/
	
				// HAD TO MODIFY SOME BACKEND SHIT
				// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
				// https://github.com/HaxeFlixel/flixel-addons/pull/348
	
				// var music:FlxSound = new FlxSound();
				// music.loadStream(Paths.music('freakyMenu'));
				// FlxG.sound.list.add(music);
				// music.play();
	
				if(FlxG.sound.music == null) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				}
			}
	
			Conductor.changeBPM(102);
			persistentUpdate = true;
	
			//var bg:FlxSprite = new FlxSprite();
	
			/*if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
				bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
			}else{
				bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			}*/
	
			// bg.antialiasing = ClientPrefs.globalAntialiasing;
			// bg.setGraphicSize(Std.int(bg.width * 0.6));
			// bg.updateHitbox();
			//add(bg);
	
			//logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
			//logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
	
			//logoBl.antialiasing = ClientPrefs.globalAntialiasing;
			//logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			//logoBl.animation.play('bump');
			//logoBl.updateHitbox();
			// logoBl.screenCenter();
			// logoBl.color = FlxColor.BLACK;
	
			//swagShader = new ColorSwap();
			//gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
	
			//var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
			//if(easterEgg == null) easterEgg = ''; //html5 fix
	
			/*switch(easterEgg.toUpperCase())
			{
				#if TITLE_SCREEN_EASTER_EGG
				case 'SHADOW':
					gfDance.frames = Paths.getSparrowAtlas('ShadowBump');
					gfDance.animation.addByPrefix('danceLeft', 'Shadow Title Bump', 24);
					gfDance.animation.addByPrefix('danceRight', 'Shadow Title Bump', 24);
				case 'RIVER':
					gfDance.frames = Paths.getSparrowAtlas('RiverBump');
					gfDance.animation.addByIndices('danceLeft', 'River Title Bump', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					gfDance.animation.addByIndices('danceRight', 'River Title Bump', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				case 'SHUBS':
					gfDance.frames = Paths.getSparrowAtlas('ShubBump');
					gfDance.animation.addByPrefix('danceLeft', 'Shub Title Bump', 24, false);
					gfDance.animation.addByPrefix('danceRight', 'Shub Title Bump', 24, false);
				case 'BBPANZU':
					gfDance.frames = Paths.getSparrowAtlas('BBBump');
					gfDance.animation.addByIndices('danceLeft', 'BB Title Bump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
					gfDance.animation.addByIndices('danceRight', 'BB Title Bump', [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
				#end
	
				default:
				//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
				//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
				//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
					gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
					gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			}
			gfDance.antialiasing = ClientPrefs.globalAntialiasing;
	
			add(gfDance);
			gfDance.shader = swagShader.shader;
			add(logoBl);
			logoBl.shader = swagShader.shader;
	*/
			//titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
			/*
			#if (desktop && MODS_ALLOWED)
			var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
			//trace(path, FileSystem.exists(path));
			if (!FileSystem.exists(path)){
				path = "mods/images/titleEnter.png";
			}
			//trace(path, FileSystem.exists(path));
			if (!FileSystem.exists(path)){
				path = "windose_data/images/titleEnter.png";
			}
			//trace(path, FileSystem.exists(path));
			//titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
			#else
	*/
			//titleText.frames = Paths.getSparrowAtlas('titleEnter');
			/*var animFrames:Array<FlxFrame> = [];
			@:privateAccess {
				titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
				titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
			}
			
			if (animFrames.length > 0) {
				newTitle = true;
				
				titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
				titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
			}
			else {
				newTitle = false;
				
				titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
				titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
			}
			
			titleText.antialiasing = ClientPrefs.globalAntialiasing;
			titleText.animation.play('idle');
			titleText.updateHitbox();
			// titleText.screenCenter(X);
			add(titleText);
	
			var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
			logo.screenCenter();
			logo.antialiasing = ClientPrefs.globalAntialiasing;
			// add(logo);
	*/
			// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
			// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
	
			credGroup = new FlxGroup();
			add(credGroup);
			textGroup = new FlxGroup();
	
			blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			credGroup.add(blackScreen);
	
			credTextShit = new Alphabet(0, 0, "", true);
			credTextShit.screenCenter();
	
			// credTextShit.alignment = CENTER;
	
			credTextShit.visible = false;
	
			ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
			add(ngSpr);
			ngSpr.visible = false;
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			ngSpr.antialiasing = ClientPrefs.globalAntialiasing;
	
			FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
			// credGroup.add(credTextShit);
		}
	
		function getIntroTextShit():Array<Array<String>>
		{
			var fullText:String = Assets.getText(Paths.txt('introText'));
	
			var firstArray:Array<String> = fullText.split('\n');
			var swagGoodArray:Array<Array<String>> = [];
	
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('--'));
			}
	
			return swagGoodArray;
		}
	
		var transitioning:Bool = false;
		private static var playJingle:Bool = false;
		
		var newTitle:Bool = false;
		var titleTimer:Float = 0;
	
		override function update(elapsed:Float)
		{
			if (FlxG.sound.music != null)
				Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);
	
			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
	
			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					pressedEnter = true;
				}
			}
			#end
	
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
	
			if (gamepad != null)
			{
				if (gamepad.justPressed.START)
					pressedEnter = true;
	
				#if switch
				if (gamepad.justPressed.B)
					pressedEnter = true;
				#end
			}
			
			if (newTitle) {
				titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
				if (titleTimer > 2) titleTimer -= 2;
			}
	
			// EASTER EGG
	
			if (startedIntro && !skippedIntro && !transitioning)
				{
					if (pressedEnter && introPhase < 3)
					{
						introPhase += 1;
						FlxG.camera.flash(0xFF000000, 1.5, null, true);
						FlxG.sound.play(SUtil.getPath() + 'windose_data/sounds/confirmMenuintro' + TitleState.soundExt, 0.7);
						startRealIntro();
						pressedEnter = false;
					}
				}
	
				if (pressedEnter && introPhase == 3)
					{
						//:saxe_mafalda: lol
						introPhase += 1;
						FlxG.sound.play(SUtil.getPath() + 'windose_data/sounds/confirmMenuintro' + TitleState.soundExt, 0.7);
						add(black);
						FlxTween.tween(black, {alpha: 1}, 2.2, {
							onComplete: function(twn) 
							{
								skipIntro2();
							}
						});
						pressedEnter = false;
					}
	
					if (startedIntro && skippedIntro && pressedEnter && !transitioning)
						{
							pressText.animation.play('press');
							FlxG.camera.flash(0xFFffffff, 1, null, true);
							if (!initialized)
							{
								initialized = true;
								FlxG.sound.music.fadeOut(1.5);
							}
							FlxG.sound.play(SUtil.getPath() + 'windose_data/sounds/confirmMenuintro' + TitleState.soundExt, 0.7);
							transitioning = true;
							new FlxTimer().start(2, function(tmr)
							{
								
								FlxG.sound.music.stop();
								MusicBeatState.switchState(new MainMenuState());
							});
						}
			if (initialized && pressedEnter && !skippedIntro)
			{
				skipIntro();
			}
	
			super.update(elapsed);
		
		}
		function createCoolText(textArray:Array<String>, ?offset:Float = 0)
		{
			for (i in 0...textArray.length)
			{
				var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
				money.screenCenter(X);
				money.y += (i * 60) + 200 + offset;
				if(credGroup != null && textGroup != null) {
					credGroup.add(money);
					textGroup.add(money);
				}
			}
		}
	
		function addMoreText(text:String, ?offset:Float = 0)
		{
			if(textGroup != null && credGroup != null) {
				var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
				coolText.screenCenter(X);
				coolText.y += (textGroup.length * 60) + 200 + offset;
				credGroup.add(coolText);
				textGroup.add(coolText);
			}
		}
	
		function goDie(time:Float)
			{
	
						FlxTween.tween(blackScreen, {alpha: 0}, time, {
							onComplete: function(twn) 
							{
								
								blackScreen.alpha = 0;
								new FlxTimer().start(1, function(tmr)
									{
										FlxG.camera.flash(0xFF000000, 1.5, null, true);
										
										new FlxTimer().start(0.1, function(tmr)
											{
											startRealIntro();
										});
								
										startedIntro = true;
									});
							}
						});
	
	
			}
	
			
	
		private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
		public static var closedState:Bool = false;
		override function beatHit()
		{
			super.beatHit();
	
			if(!closedState) {
				sickBeats++;
			}
		}
	
		var increaseVolume:Bool = false;
		function skipIntro():Void
		{
				{
					remove(ngSpr);
					remove(credGroup);
	
				}
		}
	
		var logoBumpin:FlxSprite;
		var chains:FlxSprite;
		var intro1:FlxSprite;
		var intro2:FlxSprite;
		var intro3:FlxSprite;
		var intro4:FlxSprite;
		var titleBG:FlxSprite;
		function loaded()
			{
				black = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
					black.scrollFactor.set();
					black.alpha = 0;
				
					FlxG.camera.flash(0xFF000000, 2, null, true);
					
					chains = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/chains.png');
					chains.screenCenter();
					chains.scale.set(0.9, 0.9);
					chains.alpha = 0.5;
					chains.scrollFactor.set();
					add(chains);
				
					intro1 = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/Intro1.png');
					intro1.screenCenter();
					intro1.scale.set(0.48, 0.48);
					intro1.scrollFactor.set();
					add(intro1);
				
					add(pressText);
			}
			function skipIntro2():Void
				{
				if (!skippedIntro)
				{
					skippedIntro = true;
					makeTitle();
					if (black != null)
						black.destroy();
				}
				}
	
	
		function startRealIntro()
			{
				if (introPhase == 1)
				{
					remove(intro1);
					intro1.destroy();
			
					intro2 = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/Intro2.png');
					intro2.screenCenter();
					intro2.scale.set(0.48, 0.48);
					intro2.scrollFactor.set();
					add(intro2);
					
					intro2.x -= 600;
					FlxTween.tween(intro2, {x: intro2.x + 600}, 0.6, {ease: FlxEase.elasticOut});
				}
			
				if (introPhase == 2)
				{
					remove(intro2);
					intro2.destroy();
			
					intro3 = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/Intro3.png');
					intro3.screenCenter();
					intro3.scale.set(0.48, 0.48);
					intro3.scrollFactor.set();
					add(intro3);
					
					intro3.x += 600;
					FlxTween.tween(intro3, {x: intro3.x - 600}, 0.6, {ease: FlxEase.elasticOut});
				}
	
				if (introPhase == 3)
				{
					remove(intro3);
					intro3.destroy();
					remove(chains);
					chains.destroy();
					intro4 = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/Intro4.png');
					intro4.screenCenter();
					intro4.scale.set(0.48, 0.48);
					intro4.scrollFactor.set();
					add(intro4);
				}
			}
	
			function makeTitle()
				{
					remove(pressText);
					
					FlxG.camera.flash(0xFF000000, 2, null, true);
			
	
					FlxG.sound.playMusic(SUtil.getPath() + 'windose_data/music/freakyMenu0' + TitleState.soundExt, 1);
	
					
					titleBG = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/bgback.png');
					titleBG.scale.set(0.68, 0.68);
					titleBG.scrollFactor.set();
					titleBG.screenCenter();
					add(titleBG);
				
						creepy = new FlxSprite(0, 0).loadGraphic(SUtil.getPath() + 'windose_data/images/loadingFunkers.png');
						creepy.scrollFactor.set();
						creepy.antialiasing = true;
						creepy.scale.set(0.21, 0.21);
						creepy.screenCenter();
						creepy.y += 7.78;
						creepy.x -= 300;
					add(creepy);
				
					logoBumpin = new FlxSprite(0, 0);
					logoBumpin.frames = FlxAtlasFrames.fromSparrow(SUtil.getPath() + 'windose_data/images/logoBumpinCorr.png', 'windose_data/images/logoBumpinCorr.xml');
					logoBumpin.animation.addByPrefix('idle', "logo bumpin0", 24);
					logoBumpin.scale.set(0.68, 0.68);
					logoBumpin.scrollFactor.set();
					logoBumpin.screenCenter();
					logoBumpin.animation.play('idle');
					logoBumpin.antialiasing = true;
					logoBumpin.x += 320;
					logoBumpin.y -= 20;
					add(logoBumpin);
				
					add(pressText);
					pressText.active = true;
					pressText.alpha = 1;
					pressText.scale.set(0.35, 0.35);
					pressText.screenCenter();
					pressText.x += 400;
					pressText.y += 150;
				}
	
	}
package;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.system.System;
import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
import flixel.FlxBasic;
import openfl.Lib;

import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.FlxSprite;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;
#if android
import android.Hardware;
#end
class GameOverSubstate extends MusicBeatSubstate
{
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	#if sys
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{


		#if (MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.getPreloadPath('shaders/'),Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end
	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
			if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
				//trace("Function doesn't exist, silently skipping...");
				return;
			}
			try
				{
	
	
			var method = hscriptStates.get(usehaxe).variables.get(func_name);
			switch(args.length) {
				case 0:
					method();
				case 1:
					method(args[0]);
				case 2:
					method(args[0], args[1]);
				case 3:
					method(args[0], args[1], args[2]);
				case 4:
					method(args[0], args[1], args[2], args[3]);
				case 5:
					method(args[0], args[1], args[2], args[3], args[4]);
			}
		}
		catch (e)
		{
			Lib.application.window.alert(e.message, "Pretty Bad :(");
	
		}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		try
			{
				for (key in hscriptStates.keys()) {
					callHscript(func_name, args, key);
				}
	}
	catch (e)
	{
		Lib.application.window.alert(e.message, "Hscript problem hmm");
	
	}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		try
			{
				hscriptStates.get(usehaxe).variables.set(name,value);
	}
	catch (e)
	{
		Lib.application.window.alert(e.message, "Var problem hmm");
	
	}
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		try
			{
				for (key in hscriptStates.keys())
					setHaxeVar(name, value, key);
	}
	catch (e)
	{
		Lib.application.window.alert(e.message, "Var problem hmm");
		
			
	
	}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("Sys", Sys);
		
		interp.variables.set("controls", controls);
		interp.variables.set("FlxRuntimeShader", FlxRuntimeShader);
interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("curBeat", 0);
		interp.variables.set("currentState", this);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("Highscore", Highscore);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Character", Character);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("LoadingState", LoadingState);
		interp.variables.set("DialogueBox", DialogueBox);
		interp.variables.set("DialogueBoxMPlus", DialogueBoxMPlus);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("FlxPoint", FlxPoint);
		interp.variables.set("WeekData", WeekData);
		interp.variables.set("CreditsState", CreditsState);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("Controls", Controls);
		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("Math", Math);
		interp.variables.set("Song", Song);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("resetVariables", resetVariables);
		interp.variables.set("curStep", curStep);
		interp.variables.set("curBeat", curBeat);
		interp.variables.set("colorFromString", FlxColor.fromString);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxObject", FlxObject);
		interp.variables.set("MusicBeatState", MusicBeatState);
		interp.variables.set("MusicBeatSubstate", MusicBeatSubstate);
		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("OptionsState", options.OptionsState);
		interp.variables.set("playingDeathSound", playingDeathSound);
		interp.variables.set("allowDeath", allowDeath);
		interp.variables.set("isDead", isDead);
		interp.variables.set("customing", other);
		#if mobile
		interp.variables.set("addVirtualPad", addVirtualPad);
		interp.variables.set("removeVirtualPad", removeVirtualPad);

		interp.variables.set("addPadCamera", addPadCamera);
		interp.variables.set("_virtualpad", _virtualpad);
		interp.variables.set("dPadModeFromString", dPadModeFromString);
		interp.variables.set("actionModeModeFromString", actionModeModeFromString);

		#end
		interp.variables.set("addVirtualPads", addVirtualPads);
		interp.variables.set("addPadcam", addPadcam);
		interp.variables.set("visPressed", visPressed);
		interp.variables.set("characterName", characterName);
		interp.variables.set("deathSoundName", deathSoundName);
		interp.variables.set("loopSoundName", loopSoundName);
		interp.variables.set("endSoundName", endSoundName);
		interp.variables.set("GameOverSubstate", GameOverSubstate);
		interp.variables.set("coolStartDeath", coolStartDeath);
		interp.variables.set('callAllHscript', function(func_name:String, args:Array<Dynamic>) {
			return callAllHScript(func_name, args);
		});
		interp.variables.set('setHaxeVar', function(name:String, value:Dynamic, usehaxe:String) {
			return setHaxeVar(name, value, usehaxe);
		});
		interp.variables.set('getHaxeVar', function(name:String, usehaxe:String) {
			return getHaxeVar(name, usehaxe);
		});
		interp.variables.set('setAllHaxeVar', function (name:String, value:Dynamic) {
			return setAllHaxeVar(name, value);
		});
		interp.variables.set('addHaxeLibrary', function (libName:String, ?libFolder:String = '') {
			try {
				var str:String = '';
				if(libFolder.length > 0)
					str = libFolder + '.';
				setAllHaxeVar(libName, Type.resolveClass(str + libName));
			}
			catch (e) {
				Lib.application.window.alert(e.message, "ADD LIBRARY FAILED BRUH");
			}
		});
		trace("set stuff");
		try
			{
				interp.execute(program);
				hscriptStates.set(usehaxe,interp);
				callHscript("create", [], usehaxe);
				trace('executed');
	}
	catch (e)
	{
		Lib.application.window.alert(e.message, "OH NO IS GOD DAMN IT HSCRIPT ERROR FROM M+ OH NOOO!!!!!!!1");
	}

	}

	public var boyfriend:Character;
	
	
	public var playingDeathSound:Bool = false;
	public var isDead:Bool = false;
	public var other:Bool = false;


	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var vibrationTime:Int = 500;//milliseconds
	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		vibrationTime = 500;
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);
		callAllHScript('onCreate', []);
		
		super.create();
	}

	function addVirtualPads(dPad:String,act:String){
		#if mobile
		addVirtualPad(dPadModeFromString(dPad),actionModeModeFromString(act));
		#end
	}
	#if mobile
	public function dPadModeFromString(lmao:String):FlxDPadMode{
	switch (lmao){
	case 'up_down':return FlxDPadMode.UP_DOWN;
	case 'left_right':return FlxDPadMode.LEFT_RIGHT;
	case 'up_left_right':return FlxDPadMode.UP_LEFT_RIGHT;
	case 'full':return FlxDPadMode.FULL;
	case 'right_full':return FlxDPadMode.RIGHT_FULL;
	case 'none':return FlxDPadMode.NONE;
	}
	return FlxDPadMode.NONE;
	}
	public function actionModeModeFromString(lmao:String):FlxActionMode{
		switch (lmao){
		case 'a':return FlxActionMode.A;
		case 'b':return FlxActionMode.B;
		case 'd':return FlxActionMode.D;
		case 'a_b':return FlxActionMode.A_B;
		case 'a_b_c':return FlxActionMode.A_B_C;
		case 'a_b_e':return FlxActionMode.A_B_E;
		case 'a_b_7':return FlxActionMode.A_B_7;
		case 'a_b_x_y':return FlxActionMode.A_B_X_Y;
		case 'a_b_c_x_y':return FlxActionMode.A_B_C_X_Y;
		case 'a_b_c_x_y_z':return FlxActionMode.A_B_C_X_Y_Z;
		case 'full':return FlxActionMode.FULL;
		case 'none':return FlxActionMode.NONE;
		}
		return FlxActionMode.NONE;
		}

	#end
	function addPadcam(){
		#if mobile
		addPadCamera();
		#end
	}
	public function visPressed(dumbass:String = ''):Bool{
		#if mobile
		
		return _virtualpad.returnPressed(dumbass);
		#else
		return false;
		#end
	}
	public function new(x:Float, y:Float, camX:Float, camY:Float,?isPlayer:Bool = true)
	{
		super();
		makeHaxeState("ded", "windose_data/scripts/custom_menus/", "GameOverSubstate");
		callAllHScript("startDead", [x, y, camX, camY, isPlayer]);
		PlayState.instance.setOnLuas('inGameOver', true);
		#if android
		if(ClientPrefs.vibration)
		{
			Hardware.vibrate(vibrationTime);
		}
		#end
	/*	if (FNFAssets.exists("windose_data/data/" + PlayState.SONG.song.toLowerCase() + "/gameover", Hscript))
			{
				makeHaxeState("gameover", "windose_data/data/" + PlayState.SONG.song.toLowerCase() + "/", "gameover");
				
			}


			if (FNFAssets.exists("mods/data/" + PlayState.SONG.song.toLowerCase() + "/gameover", Hscript))
			{
				makeHaxeState("gameover", "mods/data/" + PlayState.SONG.song.toLowerCase() + "/", "gameover");
				
			}

			if (FNFAssets.exists("mods/" + Paths.currentModDirectory + "/data/" + PlayState.SONG.song.toLowerCase() + "/modchart", Hscript))
				{
					makeHaxeState("gameover", "mods/" + Paths.currentModDirectory + "/data/" + PlayState.SONG.song.toLowerCase() + "/", "gameover");
					
				}*/
	}


	public var allowDeath:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		callAllHScript("update", [elapsed]);

	}

	override function beatHit()
	{
		super.beatHit();
		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
		//FlxG.log.add('beat');
	}

	override function stepHit()
		{
			super.stepHit();
			setAllHaxeVar('curStep', curStep);
			callAllHScript("stepHit", [curStep]);
		}
	
	public function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}
	function camerabgAlphaShits(cam:FlxCamera)
		{
			cam.bgColor.alpha = 0;
		}
	
}

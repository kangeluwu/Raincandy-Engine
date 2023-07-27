package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import openfl.Lib;
import WeekData;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.addons.display.FlxRuntimeShader;
import sys.FileSystem;
import sys.io.File;
class PauseSubState extends MusicBeatSubstate
{
	//var botplayText:FlxText;
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
			trace("Function doesn't exist, silently skipping...");
			return;
		}
		try{
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
		try{
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	catch (e)
		{
			Lib.application.window.alert(e.message, "Pretty Bad :(");
	
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		try{
		hscriptStates.get(usehaxe).variables.set(name,value);
		}
		catch (e)
			{
				Lib.application.window.alert(e.message, "Pretty Bad :(");
		
			}
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		try{
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("FlxRuntimeShader", FlxRuntimeShader);
interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
		interp.variables.set("controls", controls);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("MusicBeatState", MusicBeatState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("curBeat", 0);
		interp.variables.set("currentState", this);
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("ClientPrefs", ClientPrefs);
		interp.variables.set("FlxStringUtil", FlxStringUtil);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("Highscore", Highscore);
		interp.variables.set("WeekData", WeekData);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("LoadingState", LoadingState);
		interp.variables.set("DialogueBox", DialogueBox);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		#if mobile
		interp.variables.set("addVirtualPad", addVirtualPad);
		interp.variables.set("removeVirtualPad", removeVirtualPad);
		interp.variables.set("addPadCamera", addPadCamera);
		#end
		interp.variables.set("CreditsState", CreditsState);

		interp.variables.set("Controls", Controls);

		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("Math", Math);
		interp.variables.set("Song", Song);

		interp.variables.set("Reflect", Reflect);
		interp.variables.set("curStep", curStep);
		interp.variables.set("curBeat", curBeat);
		interp.variables.set("colorFromString", FlxColor.fromString);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("Paths", Paths);
		interp.variables.set("restartSong", restartSong);
		interp.variables.set("close", close);
		interp.variables.set("resetState", FlxG.resetState);
		interp.variables.set("setCameras", setCameras);
		interp.variables.set("ChartTypeMenu", ChartTypeMenu);
		interp.variables.set("OGcolor", FlxColor.WHITE);
		interp.variables.set("BlackColor", FlxColor.BLACK);
		interp.variables.set("BlueColor", FlxColor.BLUE);
		interp.variables.set("RedColor", FlxColor.RED);
		interp.variables.set("PurpleColor", FlxColor.PURPLE);
		interp.variables.set("GreenColor", FlxColor.GREEN);
		interp.variables.set("YellowColor", FlxColor.YELLOW);
		interp.variables.set("CyanColor", FlxColor.CYAN);
		interp.variables.set("songName", songName);
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
		try{
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("create", [], usehaxe);
		trace('executed');
		}
	}

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();
		makeHaxeState("pause", "windose_data/scripts/custom_menus/", "PauseSubstate");
	}
	function setCameras()
		{
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}
	
	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		callAllHScript('update', [elapsed]);
		super.update(elapsed);
	}
	override function destroy()
		{
			callAllHScript("onDestroy", []);
			super.destroy();
		}
	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

			Main.fpsVar.alpha = 1;
		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

}

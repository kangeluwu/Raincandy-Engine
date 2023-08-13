package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
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
import openfl.display.BlendMode;
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
import tjson.TJSON;
import haxe.Json;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import openfl.Lib;
using StringTools;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
import Type.ValueType;
import flixel.addons.display.FlxRuntimeShader;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var closedState:Bool = false;
	public static var initialized:Bool = false;
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	var haxeVars:Map<String, Dynamic> = [];
	static public var soundExt:String = ".ogg";


	public static var updateVersion:String = '';
	#if HIDDEN_ALLOWED
var doHidden = true;
#else
var doHidden = false;
#end
	#if debug
	var debugTarget = true;
#else
	var debugTarget = false;
#end
#if LUA_ALLOWED
var luaallowed = true;
#else
var luaallowed = false;
#end
#if PSYCH_WATERMARKS
var watermark = true;
#else
var watermark = false;
#end
#if desktop
var desktop = true;
#else
var desktop = false;
#end
#if MODS_ALLOWED
var modsallowed = true;
#else
var modsallowed = false;
#end
#if switch
	var switchTarget = true;
#else
	var switchTarget = false;
#end

#if CHECK_FOR_UPDATES
	var checkupdate = true;
#else
	var checkupdate = false;
#end

#if TITLE_SCREEN_EASTER_EGG
var titleEaster = true;
#else
var titleEaster = false;
#end
#if mobile
var mobile = true;
#else
var mobile = false;
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
	function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
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
		
				MusicBeatState.switchState(new TitleStateBackup());

	}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("doHidden", doHidden);
		interp.variables.set("debugTarget", debugTarget);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("Json", Json);
		interp.variables.set("titleEaster", titleEaster);
		interp.variables.set("closedState", closedState);
		interp.variables.set("switchTarget", switchTarget);
		interp.variables.set("BitmapData", BitmapData);
		interp.variables.set("luaallowed", luaallowed);
		interp.variables.set("modsallowed", modsallowed);
		interp.variables.set("desktop", desktop);
		interp.variables.set("FlxRuntimeShader", FlxRuntimeShader);
interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
		interp.variables.set("Paths", Paths);

		interp.variables.set("watermark", watermark);
		interp.variables.set("OGcolor", FlxColor.WHITE);
		interp.variables.set("BlackColor", FlxColor.BLACK);
		interp.variables.set("BlueColor", FlxColor.BLUE);
		interp.variables.set("RedColor", FlxColor.RED);
		interp.variables.set("PurpleColor", FlxColor.PURPLE);
		interp.variables.set("GreenColor", FlxColor.GREEN);
        interp.variables.set("YellowColor", FlxColor.YELLOW);
		interp.variables.set("CyanColor", FlxColor.CYAN);
		interp.variables.set("initialized", initialized);
		interp.variables.set("soundExt", soundExt);
		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("togglePersistUpdate", togglePersistUpdate);
				interp.variables.set("togglePersistentDraw", togglePersistentDraw);
		interp.variables.set("MainMenuState", MainMenuState);
		#if MODS_ALLOWED
		interp.variables.set("File", File);
		interp.variables.set("FileSystem", FileSystem);
		#end
		interp.variables.set("FlxFrame", FlxFrame);
		interp.variables.set("MusicBeatState", MusicBeatState);
		interp.variables.set("ClientPrefs", ClientPrefs);
		interp.variables.set("ChartingState", editors.ChartingState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("curBeat", 0);
		interp.variables.set("currentTitleState", this);
		interp.variables.set("getRandomObject",getRandomObject);
		interp.variables.set("add", add);
		interp.variables.set("interpolate", interpolate);
		interp.variables.set("remove", remove);
		interp.variables.set("controls", controls);
		#if mobile
		interp.variables.set("addVirtualPad", addVirtualPad);
		interp.variables.set("removeVirtualPad", removeVirtualPad);
		interp.variables.set("addPadCamera", addPadCamera);
		interp.variables.set("addAndroidControls", addAndroidControls);
		interp.variables.set("mobile", mobile);
		#end
		interp.variables.set("insert", insert);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("hscriptPath", SUtil.getPath() + path);
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
		try {
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("create", [], usehaxe);
		trace('executed');
		}

		catch (e)
			{
				Lib.application.window.alert(e.message, "TITLE CRASHED,BACKUP MODE ON!!!11");
				MusicBeatState.switchState(new TitleStateBackup());

			}
	}
	function interpolate(color1:FlxColor, color2:FlxColor, factor:Float = 0.5):FlxColor
		{
			return FlxColor.interpolate(color1, color2, factor);
		}
	function togglePersistUpdate(toggle:Bool)
	{
		persistentUpdate = toggle;
	}
	function togglePersistentDraw(toggle:Bool)
		{
			persistentDraw = toggle;
		}
	function changeCurMusicName(newName:String):String
	{
		Main.curMusicName = newName;
		setAllHaxeVar('curMusicName', newName);
		return (newName);
	}
	
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

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

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
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		PluginManager.init();
		PlayerSettings.init();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/kangeluwu/Raincandy-Engine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.RCEVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

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

			makeHaxeState("title", "windose_data/scripts/custom_menus/", "TitleState");
		}
		#end
	}

	function getRandomObject(object:Dynamic):Array<Dynamic>
		{
			return (FlxG.random.getObject(object));
		}
		override function update(elapsed:Float)
			{
				callAllHScript("update", [elapsed]);
				super.update(elapsed);
			}
			override function stepHit()
				{
					super.stepHit();
					FlxG.log.add(curStep);
					setAllHaxeVar('curStep', curStep);
					callAllHScript('stepHit', [curStep]);
				}
			override function beatHit()
			{
				super.beatHit();
				FlxG.log.add(curBeat);
				setAllHaxeVar('curBeat', curBeat);
				callAllHScript('beatHit', [curBeat]);
			}
}

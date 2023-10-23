package;
import flixel.FlxCamera;
#if desktop
import Discord.DiscordClient;
#end
import haxe.Json;
import openfl.Lib;
import openfl.display.BlendMode;
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.util.FlxAxes;
import flixel.FlxObject;
import flixel.util.FlxTimer;
using StringTools;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.addons.display.FlxRuntimeShader;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
class FreeplayState extends MusicBeatState
{
	public static var vocals:FlxSound = null;
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	var haxeVars:Map<String, Dynamic> = [];
	#if !switch
	var switchTarget:Bool = false;
	#else
	var switchTarget:Bool = true;
	#end

	#if !linux
	var linuxTarget:Bool = false;
	#else
	var linuxTarget:Bool = true;
	#end
	#if ACHIEVEMENTS_ALLOWED
	var achiAllow:Bool = true;
	#else
	var achiAllow:Bool = false;
#end
#if MODS_ALLOWED
var modsAllow:Bool = true;
#else
var modsAllow:Bool = false;
#end
#if CHECK_FOR_UPDATES
	var checkupdate = true;
#else
	var checkupdate = false;
#end
#if PRELOAD_ALL
	var preload = true;
#else
	var preload = false;
#end
#if desktop
var desktop = true;
#else
var desktop = false;
#end
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
#if mobile
var mobile = true;
#else
var mobile = false;
#end
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
public function makeHaxeState(usehaxe:String, path:String, filename:String) {
	trace("opening a haxe state (because we are cool :))");
	var parser = new ParserEx();
	parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
	var program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + path + filename));
	var interp = PluginManager.createSimpleInterp();
	// set vars
	interp.variables.set("preload", preload);
	interp.variables.set("doHidden", doHidden);
	interp.variables.set("debugTarget", debugTarget);
	interp.variables.set("CoolUtil", CoolUtil);
	interp.variables.set("vocals", vocals);
	interp.variables.set("mobile", mobile);
	#if mobile
	interp.variables.set("addVirtualPad", addVirtualPad);
	interp.variables.set("removeVirtualPad", removeVirtualPad);
	interp.variables.set("addPadCamera", addPadCamera);
	interp.variables.set("addAndroidControls", addAndroidControls);
	interp.variables.set("_virtualpad", _virtualpad);
	interp.variables.set("dPadModeFromString", dPadModeFromString);
	interp.variables.set("actionModeModeFromString", actionModeModeFromString);

	#end
	interp.variables.set("addVirtualPads", addVirtualPads);
	interp.variables.set("visPressed", visPressed);
	interp.variables.set("linuxTarget", linuxTarget);
	interp.variables.set("achiAllow", achiAllow);
	interp.variables.set("Json", Json);
	interp.variables.set("Date", Date);
	interp.variables.set("StoryMenuState", StoryMenuState);
	interp.variables.set("FreeplayState", FreeplayState);
	interp.variables.set("FlxRuntimeShader", FlxRuntimeShader);
interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
	interp.variables.set("switchTarget", switchTarget);
	interp.variables.set("Achievements", Achievements);
	interp.variables.set("WeekData", WeekData);
	interp.variables.set("PlayState", PlayState);
	interp.variables.set("modsAllow", modsAllow);
	interp.variables.set("desktop", desktop);
	interp.variables.set("ResetScoreSubState", ResetScoreSubState);
	interp.variables.set("Paths", Paths);
	interp.variables.set("Sys", Sys);
	interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
	interp.variables.set("controls", controls);
	interp.variables.set("OGcolor", FlxColor.WHITE);
	interp.variables.set("BlackColor", FlxColor.BLACK);
	interp.variables.set("BlueColor", FlxColor.BLUE);
	interp.variables.set("RedColor", FlxColor.RED);
	interp.variables.set("PurpleColor", FlxColor.PURPLE);
	interp.variables.set("GreenColor", FlxColor.GREEN);
	interp.variables.set("YellowColor", FlxColor.YELLOW);
	interp.variables.set("CyanColor", FlxColor.CYAN);
	interp.variables.set("FlxObject", FlxObject);
	interp.variables.set("Highscore", Highscore);
	interp.variables.set("FlxCamera", FlxCamera);
	interp.variables.set("openSubState", openSubState);
	interp.variables.set("destroyFreeplayVocals", destroyFreeplayVocals);
	interp.variables.set("FlxTransitionableState", FlxTransitionableState);
	interp.variables.set("MainMenuState", MainMenuState);
	interp.variables.set("FlxTypedGroup", FlxTypedGroup);
	interp.variables.set("HealthIcon", HealthIcon);
	interp.variables.set("flixelSave", FlxG.save);
	interp.variables.set("MainMenuState", MainMenuState);
	interp.variables.set("Math", Math);
	interp.variables.set("FlxFlicker", FlxFlicker);
	interp.variables.set("MusicBeatState", MusicBeatState);
	interp.variables.set("ClientPrefs", ClientPrefs);
	interp.variables.set("ChartTypeMenu", ChartTypeMenu);
	interp.variables.set("ChartingState", editors.ChartingState);
	interp.variables.set("Alphabet", Alphabet);
	interp.variables.set("curBeat", 0);
	interp.variables.set("currentFreeplayState", this);
	interp.variables.set("add", add);
	interp.variables.set("remove", remove);
	interp.variables.set("X", FlxAxes.X);
	interp.variables.set("Application", Application);
	interp.variables.set("togglePersistUpdate", togglePersistUpdate);
	interp.variables.set("togglePersistentDraw", togglePersistentDraw);
	interp.variables.set("destroyFreeplayVocals", destroyFreeplayVocals);
	interp.variables.set("ResetScoreSubState", ResetScoreSubState);
	interp.variables.set("fromRGB", fromRGB);
	interp.variables.set("SongMetadata", SongMetadata);
	interp.variables.set("GameplayChangersSubstate", GameplayChangersSubstate);
	interp.variables.set("coolURL", coolURL);
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
			Lib.application.window.alert(e.message, "FREEPLAY,BACKUP MODE ON!!!11");
			MusicBeatState.switchState(new FreeplayStateBackup());

		}
}
public static function destroyFreeplayVocals() {
	if(vocals != null) {
		vocals.stop();
		vocals.destroy();
	}
	vocals = null;
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
public function visPressed(dumbass:String = ''):Bool{
	#if mobile
	return _virtualpad.returnPressed(dumbass);
	#else
	return false;
	#end
}
function togglePersistUpdate(toggle:Bool)
{
	persistentUpdate = toggle;
}
function camerabgAlphaShits(cam:FlxCamera)
	{
		cam.bgColor.alpha = 0;
	}
function togglePersistentDraw(toggle:Bool)
	{
		persistentDraw = toggle;
	}
	function fromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor
		{
			return FlxColor.fromRGB(red, green, blue,alpha);
		}
		function interpolate(color1:FlxColor, color2:FlxColor, factor:Float = 0.5):FlxColor
			{
				return FlxColor.interpolate(color1, color2, factor);
			}
function changeCurMusicName(newName:String):String
{
	Main.curMusicName = newName;
	setAllHaxeVar('curMusicName', newName);
	return (newName);
}
function coolURL(url:String):String
	{
		FlxG.openURL(url);
		return url;
	}
	override function create()
	{		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		makeHaxeState("freeplay", "windose_data/scripts/custom_menus/", "FreeplayState");		
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		callAllHScript("update", [elapsed]);
	}

	override function stepHit()
	{
		super.stepHit();
		setAllHaxeVar('curStep', curStep);
		callAllHScript("stepHit", [curStep]);
	}

	override function beatHit()
	{
		super.beatHit();
		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}
	function chartConfrim(){
		#if debug
		LoadingState.loadAndSwitchState(new ChartingState());
		#end
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
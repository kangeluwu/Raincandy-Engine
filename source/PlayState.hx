package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end
import math.Vector3;
import customlize.VoicesGroup;
import customlize.SoundGroup;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxFrame;
import flixel.system.scaleModes.RatioScaleMode;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import Lyrics;
import GreenScreenShader;
import openfl.media.Sound;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import Type.ValueType;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import DialogueBoxMPlus;
import Conductor.Rating;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
import seedyrng.Random;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import lime.tools.ApplicationData;
import flixel.system.debug.Window;
import sys.io.Process;
import lime.app.Application;
import openfl.Lib;
import openfl.geom.Matrix;
import lime.ui.Window;
import openfl.geom.Rectangle;
import openfl.display.Sprite;
import lime.tools.ApplicationData;
#if VIDEOS_ALLOWED
#if !ios
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as FlxVideo;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as FlxVideo;
#elseif (hxCodec == "2.6.0") import VideoHandler as FlxVideo;
#else import vlc.VideoHandler as FlxVideo; #end
#else
import PluginManager.FlxVideo as FlxVideo;
import PluginManager.FlxVideoSprite;
#end
#end
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.addons.editors.pex.FlxPexParser;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import Judgement.TUI;
using StringTools;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Sprite;
import openfl.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
import modchart.*;

enum abstract DisplayLayer(Int) from Int to Int {
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}
class PlayState extends MusicBeatState
{
	public var modManager:ModManager;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2, '你在干什么啊(恼)'], //From 0% to 19%
		['Shit', 0.4, '烂透了'], //From 20% to 39%
		['Bad', 0.5, '坏'], //From 40% to 49%
		['Bruh', 0.6, '认真的吗?'], //From 50% to 59%
		['Meh', 0.69, '还行'], //From 60% to 68%
		['Nice', 0.7, '不错'], //69%
		['Good', 0.8, '好'], //From 70% to 79%
		['Great', 0.9, '很好'], //From 80% to 89%
		['Sick!', 1, '酷炸了!'], //From 90% to 99%
		['Perfect!!', 1, '完美!'] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartCharacters:Map<String, ModchartCharacter> = new Map<String, ModchartCharacter>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var customFunctions:Map<String, Dynamic> = new Map();
	public var windowDad:Window;
	var dadWin = new Sprite();
	var dadScrollWin = new Sprite();
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Character> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end
	public var otherCharactersMap:Map<String,Map<String, Character>> = [];
	public var otherCharactersGroups:Map<String,FlxSpriteGroup> = new Map<String, FlxSpriteGroup>();
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var cfDuration:Float = 0.75;
	public var cfIntensity:Float = 1.0;
	public var cfBlend:String = "add";

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var isCorruptUI:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 3000;

	public var vocals:VoicesGroup;
	public var sfx:SoundGroup;
	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var notesToSpawn:Array<Array<Note>> = []; // too lazy to redo all unspawnNotes code so this'll handle the spawning and thats it lol
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;
    public var strumLines:StrumLine = null;
	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;


	//Shader shit lol


	
	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var playerComboBreak:FlxTypedGroup<FlxSprite>;
	public var opponentComboBreak:FlxTypedGroup<FlxSprite>;
	public var totalComboBreak:FlxTypedGroup<FlxSprite>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var grpCrossfades:FlxTypedGroup<FlxSprite>;
	public var grpGFCrossfades:FlxTypedGroup<FlxSprite>;
	public var grpRatings:Map<String,Array<FlxSprite>> = ['combos' => [],
	'rating' => [],
	'nums' => []];
	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var healthInstance:Float = 1;
	public var combo:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:HealthBar;
	var songPercent:Float = 0;

	public var timeBarBG:FlxSprite;
	public var timeBar:HealthBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var botplay:Bool = false;
	public var opponentPlayer:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	//public var botplayTxt:FlxText;
	public var dieEventZooms:Bool = false;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camHUD2:FlxCamera;
	public var camHUDTOP:FlxCamera;
	public var subCams:FlxCamera;
	public var lyricsHUD:FlxCamera;

	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	public var phillyLightsColors:Array<FlxColor> = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite = null;
	public var glowbehind:FlxSprite = null;
	public var BGglowbehind:BGSprite = null;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var blackShits:FlxSprite;
	var phillyWindowEvent:BGSprite = null;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public static var isFixedAspectRatio:Bool = false;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	public var currentTimingShown:FlxText;
	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var stopAutoMoving:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public static var chartType:String = "standard";
	public var genocideMode:Bool = false;

	// Discord RPC variables
	var storyDifficultyText:String = "";
	#if desktop
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;

	public var stressPercent:Float = 0;

	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';
	public var doof:DialogueBox;
	public var doofM:DialogueBoxMPlus;
	public var daNoteStatic:FlxSprite;
	public static var arrowLane:Int = 0;
	public static var arrowLane2:Int = 0;
	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();
    //Hscript shits
	public var modchartMode:Bool = false;
	var isHscript:Bool = false;
	public var hscriptgfhide:Bool = false;
	var disibleIconMoving:Bool = false;
	public var iconMovingType = 'Left';
	public var disabledchangecolor:Bool = false;
	public var hideFUCKINGhealthBarBG:Bool = false;
	
	var hscriptStates:Map<String, Interp> = new Map<String, Interp>();
	var exInterp:InterpEx = new InterpEx();
	var haxeFunctions:Map<String, Void->Void> = [];
	var haxeVars:Map<String, Dynamic> = [];
	var backupNums:Map<String, Int> = new Map<String, Int>();
	public static var interp = new InterpEx();
    public static var hscriptClasses:Array<String> = [];
    public static var hscriptInstances:Array<Dynamic> = [];

	public var isdefault:Bool = false;
	public function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String):Dynamic {
		// if function doesn't exist
			var returnVal:Dynamic = FunkinLua.Function_Continue;
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			//trace("Function doesn't exist, silently skipping...");
			//addTextToDebug(func_name+"Function doesn't exist!",FlxColor.RED);
			return FunkinLua.Function_Continue;
		}
		try
			{


		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		returnVal =  Reflect.callMethod(null,method,args);
	
	}
	catch (e)
	{
		addTextToDebug("Function Issues:" + e.message,FlxColor.RED);
		return FunkinLua.Function_Continue;
	}
	return returnVal;
	}
	public function callAllHScript(func_name:String, args:Array<Dynamic>, ignoreStops = true):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		for (key in hscriptStates.keys()) {
		try
			{
			
					var ret:Dynamic = callHscript(func_name, args, key);
					if(ret == FunkinLua.Function_StopLua && !ignoreStops)
						break;
					
					if(ret != FunkinLua.Function_Continue)
						returnVal = ret;
	}
	catch (e)
		{
			returnVal = null;
			addTextToDebug("Function Issues:" + e.message,FlxColor.RED);
		}

}
return returnVal;

	}
	public function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		try
			{
				hscriptStates.get(usehaxe).variables.set(name,value);
	}
	catch (e)
	{
		addTextToDebug("Variable Issues:" + e.message,FlxColor.RED);
	}
		
	}
	public function getHaxeVar(name:String, usehaxe:String):Dynamic {
				return hscriptStates.get(usehaxe).variables.get(name);
	}
	public function setAllHaxeVar(name:String, value:Dynamic) {
		try
			{
				for (key in hscriptStates.keys())
					setHaxeVar(name, value, key);
	}
	catch (e)
	{
		addTextToDebug("Variable Issues:" + e.message,FlxColor.RED);
	}

	}
	public function getHaxeActor(name:String):Dynamic {
		switch (name) {
			case "boyfriend" | "bf":
				return boyfriend;
			case "girlfriend" | "gf":
				return gf;
			case "dad":
				return dad;
			default:
				return strumLineNotes.members[Std.parseInt(name)];
		}
	}
	public var funni:Bool = false;


function camerabgAlphaShits(cam:FlxCamera)
	{
		cam.bgColor.alpha = 0;
	}
	function addVirtualPads(dPad:String,act:String){
		#if mobile
		addVirtualPad(dPadModeFromString(dPad),actionModeModeFromString(act));
		#end
	}
	
	function getHaxeVirtualPad(dumbass:String = ''):FlxButton
		{
			#if mobile
			var lmao =  Reflect.field(_virtualpad, 'button' + dumbass);
			return lmao;
			#else
			return null;
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
	public function makeHaxeState(usehaxe:String, path:String, filename:String,isArray:Bool = false) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
	parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

		var program;
		if (isArray){
			program = parser.parseString(FNFAssets.getText(SUtil.getPath() + path + filename));
			
		}	
		else{
			program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + path + filename));
		}	
	

		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("variables", variables);
		interp.variables.set("BEHIND_GF", BEHIND_GF);
		interp.variables.set("stressPercent", stressPercent);
		interp.variables.set("camerabgAlphaShits", camerabgAlphaShits);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("FlxObject", FlxObject);
		
		interp.variables.set("BEHIND_BF", BEHIND_BF);
		interp.variables.set("BEHIND_DAD", BEHIND_DAD);
		interp.variables.set("BEHIND_ALL", BEHIND_ALL);
		interp.variables.set("BEHIND_NONE", 0);
		interp.variables.set("difficulty", storyDifficulty);
		interp.variables.set("difficultyText", storyDifficultyText);
		interp.variables.set("refresh", refresh);
		interp.variables.set("Highscore", Highscore);
		interp.variables.set("PhillyGlowGradient", PhillyGlow.PhillyGlowGradient);
		interp.variables.set("PhillyGlowParticle", PhillyGlow.PhillyGlowParticle);
		interp.variables.set("LEFT_TO_RIGHT", FlxBarFillDirection.LEFT_TO_RIGHT);
		interp.variables.set("RIGHT_TO_LEFT", FlxBarFillDirection.RIGHT_TO_LEFT);
		interp.variables.set("TOP_TO_BOTTOM", FlxBarFillDirection.TOP_TO_BOTTOM);
		interp.variables.set("BOTTOM_TO_TOP", FlxBarFillDirection.BOTTOM_TO_TOP);
		interp.variables.set("HORIZONTAL_INSIDE_OUT", FlxBarFillDirection.HORIZONTAL_INSIDE_OUT);
		interp.variables.set("HORIZONTAL_OUTSIDE_IN", FlxBarFillDirection.HORIZONTAL_OUTSIDE_IN);
		interp.variables.set("VERTICAL_INSIDE_OUT", FlxBarFillDirection.VERTICAL_INSIDE_OUT);
		interp.variables.set("VERTICAL_OUTSIDE_IN", FlxBarFillDirection.VERTICAL_OUTSIDE_IN);
		interp.variables.set("FlxTypeText", FlxTypeText);
		interp.variables.set("FlxPexParser", FlxPexParser);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxTrailArea", FlxTrailArea);

		interp.variables.set("FlxEmitter", FlxEmitter);
		interp.variables.set("FlxParticle", FlxParticle);
		interp.variables.set("playerComboBreak", playerComboBreak);
		interp.variables.set("opponentComboBreak", opponentComboBreak);
		interp.variables.set("totalComboBreak", totalComboBreak);
		interp.variables.set("Lyrics", Lyrics);
		interp.variables.set("bpm", Conductor.bpm);
		interp.variables.set("BGSprite", BGSprite);
		interp.variables.set("NormalNote", Note);
		interp.variables.set("Paths", Paths);
		interp.variables.set("WiggleEffect", WiggleEffect);
		interp.variables.set("WiggleEffectType", WiggleEffectType);
		interp.variables.set("StrumNote", StrumNote);
		interp.variables.set("arrowLane", arrowLane);
		interp.variables.set("arrowLane2", arrowLane2);
		interp.variables.set("chartType", chartType);
		#if sys
		interp.variables.set('FlxRuntimeShader', FlxRuntimeShader);
		interp.variables.set('ShaderFilter', ShaderFilter);
		#end
		
		interp.variables.set('FlxGraphic', FlxGraphic);
		interp.variables.set('FlxButton', FlxButton);
		interp.variables.set("songData", SONG);
		interp.variables.set("displayBLACK", funni);
		interp.variables.set("camGame", camGame);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("lyricsHUD", lyricsHUD);
		interp.variables.set("backShitPart1", backShitPart1);
		interp.variables.set("backShitPart2", backShitPart2);
		interp.variables.set("camHUD2", camHUD2);
		interp.variables.set("camHUDTOP", camHUDTOP);
		interp.variables.set("pi", Math.PI);
	    interp.variables.set("Math", Math);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("songData", SONG);
		interp.variables.set("HealthBar", HealthBar);
		interp.variables.set("customHealthBar", customHealthBar);	
		interp.variables.set("customTimeBar", customTimeBar);	
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		#if VIDEOS_ALLOWED
		interp.variables.set("FlxVideo", FlxVideo);
		#end
		interp.variables.set("GreenScreenShader", GreenScreenShader);
		interp.variables.set("switchSong", switchSong);
		interp.variables.set("preacacheSongData", preacacheSongData);
		interp.variables.set("preacacheSongs", preacacheSongs);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("curSection", 0);
		interp.variables.set("FlxSpriteGroup", FlxSpriteGroup);
		interp.variables.set("deathCounter", deathCounter);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("opponentStrums", opponentStrums);
		interp.variables.set("DialogueBoxMPlus", DialogueBoxMPlus);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("GameOverSubstate", GameOverSubstate);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Application", Application.current);

		interp.variables.set("mustHit", false);
		interp.variables.set("botplay", botplay);
		interp.variables.set("opponentPlayer", opponentPlayer);
		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("gf", gf);
		interp.variables.set("dad", dad);
		interp.variables.set("glowbehind", glowbehind);
		interp.variables.set("lightsColors", phillyLightsColors);
		
		interp.variables.set("vocals", vocals);
		interp.variables.set("sfx", sfx);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);
		interp.variables.set("health", health);
		interp.variables.set("ClientPrefs", ClientPrefs);
		
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("startsWith", startsWith);
		interp.variables.set("endsWith", endsWith);
		interp.variables.set("downscroll", ClientPrefs.downScroll);
		interp.variables.set("middleScroll", ClientPrefs.middleScroll);
		interp.variables.set("hscriptPath", SUtil.getPath() + path);
		interp.variables.set("health", health);
		interp.variables.set("scoreTxt", scoreTxt);
 //funny colors0x82FFFFFF
 		interp.variables.set("OGcolor", FlxColor.WHITE);
		interp.variables.set("BlackColor", FlxColor.BLACK);
		interp.variables.set("BlueColor", FlxColor.BLUE);
		interp.variables.set("RedColor", FlxColor.RED);
		interp.variables.set("PurpleColor", FlxColor.PURPLE);
		interp.variables.set("GreenColor", FlxColor.GREEN);
        interp.variables.set("YellowColor", FlxColor.YELLOW);
		interp.variables.set("CyanColor", FlxColor.CYAN);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);

		interp.variables.set("ClientPrefs", ClientPrefs);
		interp.variables.set("skipCountdown", skipCountdown);
//ClientPrefs:啊对对对我是颜色是吧
		interp.variables.set("makeText", function (posx:Float, posy:Float, fwidth:Float, ?text:String, size:Int = 8, embFont:Bool = true) {
			return (new FlxText(posx, posy, fwidth, text, size, embFont)); //make text in hcripts
		});
		interp.variables.set("window", Lib.application.window);
		interp.variables.set("Window", Window);
		interp.variables.set("genocideMode", genocideMode);
		interp.variables.set("popupWindow", popupWindow);
		interp.variables.set("Sprite", Sprite);
		interp.variables.set("animationCopyFrom", animationCopyFrom);
		interp.variables.set("FlxFrame", FlxFrame);

		// give them access to save data, everything will be "fine" ;)
		interp.variables.set("isInCutscene", function () return inCutscene);
		trace("set vars");
		interp.variables.set("camZooming", false);
		// callbacks
		interp.variables.set("storylistStuff", function (song) {});
		interp.variables.set("onEndSong", function (song) {});
		interp.variables.set("start", function (song) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("endUpdate", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("opponentTurn", function () {});
		interp.variables.set("playerTurn", function() {});

		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneSing", function() {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerOneMiss", function() {});
		//interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {});
		interp.variables.set("opponentNoteHit", function(id:Int, direction:Int, noteType:String, isSustainNote:Bool, note:Note) {});
		interp.variables.set("goodNoteHit", function(id:Int, direction:Int, noteType:String, isSustainNote:Bool, note:Note) {});
		interp.variables.set("defaultNoteHit", function(id:Int, direction:Int, noteType:String, isSustainNote:Bool, note:Note,strum:Int) {});

		interp.variables.set("onSpawnNote", function(id:Int, direction:Int, noteType:String, isSustainNote:Bool, note:Note) {});
		//var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			//var leData:Int = Math.round(Math.abs(note.noteData));
			//var leType:String = note.noteType;
			//callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			interp.variables.set("setGlobalVar", setGlobalVar);
			interp.variables.set("getGlobalVar", getGlobalVar);
			interp.variables.set("removeGlobalVar", removeGlobalVar);
			interp.variables.set("makeCrossfades", makeCrossfades);
		interp.variables.set("noteMiss", function(id:Int, direction:Int, noteType:String, isSustainNote:Bool, note:Note) {});
		interp.variables.set("noteMissPress", function(direction:Int) {});
		interp.variables.set("addSprite", function (sprite, position) {
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_ALL != 0)
				remove(grpGFCrossfades);
			if (position & BEHIND_GF != 0)
				remove(gfGroup);
			if ((position & BEHIND_DAD != 0) || (position & BEHIND_BF != 0))
				remove(grpCrossfades);
			if (position & BEHIND_DAD != 0)
				remove(dadGroup);
			if (position & BEHIND_BF != 0)
				remove(boyfriendGroup);
			add(sprite);
			if (position & BEHIND_ALL != 0)
				add(grpGFCrossfades);
			if (position & BEHIND_GF != 0)
				add(gfGroup);
			if ((position & BEHIND_DAD != 0) || (position & BEHIND_BF != 0))
				add(grpCrossfades);
			if (position & BEHIND_DAD != 0)	
				add(dadGroup);
			if (position & BEHIND_BF != 0)
				add(boyfriendGroup); 
			
		});
		interp.variables.set("add", add);
		interp.variables.set("fromRGB", fromRGB);
		interp.variables.set("changeNewUI", changeNewUI);
		interp.variables.set("remove", this.remove);
		interp.variables.set("insert", insert);
		interp.variables.set("replace", replace);
		interp.variables.set("setDefaultZoom", function(zoom:Float){
			defaultCamZoom = zoom;
			FlxG.camera.zoom = zoom;
		});
		interp.variables.set("removeSprite", function(sprite) {
			remove(sprite);
		});
		interp.variables.set("getHaxeActor", getHaxeActor);
		interp.variables.set("scaleChar", function (char:String, amount:Float) {
			switch(char) {
				case 'boyfriend':
					remove(boyfriend);
					boyfriend.setGraphicSize(Std.int(boyfriend.width * amount));
					boyfriend.y *= amount;
					add(boyfriend);
				case 'dad':
					remove(dad);
					dad.setGraphicSize(Std.int(dad.width * amount));
					dad.y *= amount;
					add(dad);
				case 'gf':
					remove(gf);
					gf.setGraphicSize(Std.int(gf.width * amount));
					gf.y *= amount;
					add(gf);
			}
		});
		interp.variables.set('createGlobalCallback', function(name:String, func:Dynamic)
            {
                #if LUA_ALLOWED
                for (script in PlayState.instance.luaArray)
                    if(script != null && script.lua != null && !script.closed)
                        Lua_helper.add_callback(script.lua, name, func);
                #end
                PlayState.instance.customFunctions.set(name, func);
            });
    
            // this one was tested
        interp.variables.set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
            {                
                if(funk != null) funk.addLocalCallback(name, func);
            });
	
		interp.variables.set('StringTools', StringTools);
		interp.variables.set('callAllHScript', function(func_name:String, args:Array<Dynamic>,ignoreStops) {
			 callAllHScript(func_name, args,ignoreStops);
		});
		interp.variables.set('setHaxeVar', function(name:String, value:Dynamic, usehaxe:String) {
			 setHaxeVar(name, value, usehaxe);
		});
		interp.variables.set('getHaxeVar', function(name:String, usehaxe:String) {
			 getHaxeVar(name, usehaxe);
		});
		interp.variables.set('setAllHaxeVar', function (name:String, value:Dynamic) {
			 setAllHaxeVar(name, value);
		});
		interp.variables.set('addHaxeLibrary', function (libName:String, ?libFolder:String = '',varName:String = '') {
			try {
				var str:String = '';
				if(libFolder.length > 0)
					str = libFolder + '.';

				if (varName == null || varName == '')
					varName = libName;
				setAllHaxeVar(varName, Type.resolveClass(str + libName));
			}
			catch (e) {
				addTextToDebug("Adding library Failed:" + e.message,FlxColor.RED);
			}
		});
		//Fow Ending Cutscenes lol
		interp.variables.set("endSong", endSong);
		interp.variables.set("StrumLine", StrumLine);
        for (name in variables.keys())
			interp.variables.set(name, variables.get(name));

		for (name => func in PlayState.instance.customFunctions)
			{
				if(func != null)
					interp.variables.set(name, func);
			}
		trace("set stuff");
		try
			{
		interp.execute(program);
		if (hscriptStates.exists(usehaxe)){
			var curBackupNum = backupNums.get(usehaxe);
			curBackupNum += 1;
			backupNums.set(usehaxe,curBackupNum);
		hscriptStates.set(usehaxe + ' Backup ' + curBackupNum,interp);
		trace('executed');
		callHscript("start", [SONG.song], usehaxe + ' Backup ' + curBackupNum);
		}
		else{
		hscriptStates.set(usehaxe,interp);
		backupNums.set(usehaxe,0);
		trace('executed');
		callHscript("start", [SONG.song], usehaxe);
		}

	}
	catch (e)
	{
		addTextToDebug("Running Issue:" + e.message,FlxColor.RED);
	}
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
	function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return exInterp.createScriptClassInstance(classname, args);
	}
	function makeHaxeExState(usehaxe:String, path:String, filename:String)
	{
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
	parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

		var program = parser.parseModule(FNFAssets.getHscript(SUtil.getPath() + path + filename));
		trace("set stuff");
		exInterp.registerModule(program);

		trace('executed');
	}
	//var uiSmelly:TUI;
	public var instStuff:String = '';
	public var voicesStuff:String = '';
	public var customHealthBar:String = '';
	public var customTimeBar:String = '';
	public var healthBarPath:String = '';
	public var timeBarPath:String = '';
	public var stageData:StageFile;
	var playbackRate:Float = 1;
	public var currentPlayerStrum:Int = 0;
	public var currentOpponentStrum:Int = 1;
	var uiSmelly:TUI;
	var haxeModulePushed:Array<String> = [];
	public var currentChars:Array<Character> = [];
	public var currentStrums:Array<FlxTypedGroup<StrumNote>> = [];
	override public function create()
	{
		#if MODS_ALLOWED
		var modsJson = CoolUtil.parseJson(FNFAssets.getText(Paths.modFolders('stages/custom_Hscript_stages/custom_stages.json')));
		#end
		var stageJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + Paths.getPreloadPath('stages/custom_Hscript_stages/custom_stages.json')));
		Paths.clearStoredMemory();
		options.OptionsState.isFromPlayState = true;
		// for lua
		instance = this;
		#if MODS_ALLOWED
		if (FNFAssets.exists(Paths.modFolders('images/custom_ui/ui.json')))
		Judgement.uiJson = CoolUtil.parseJson(FNFAssets.getText(Paths.modFolders('images/custom_ui/ui.json')));
		
		if (!FNFAssets.exists(Paths.modFolders('images/custom_ui/ui.json'))||
			(FNFAssets.exists(Paths.modFolders('images/custom_ui/ui.json')) 
		&& !Reflect.hasField(Judgement.uiJson, SONG.uiType))
			 )			 #end
		Judgement.uiJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + Paths.getPreloadPath('shared/images/custom_ui/ui.json')));

		uiSmelly = Reflect.field(Judgement.uiJson, SONG.uiType);
		
		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.75;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.5;
		rating.score = 0;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = -1;
		rating.score = -300;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		botplay = ClientPrefs.getGameplaySetting('botplay', false);
		opponentPlayer = ClientPrefs.getGameplaySetting('opponentPlayer', false);
        if (opponentPlayer){
			currentPlayerStrum = 1;
			currentOpponentStrum = 0;
		}
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		lyricsHUD = new FlxCamera();
		lyricsHUD.bgColor.alpha = 0;
		camHUD2 = new FlxCamera();


		camHUD.bgColor.alpha = 0;
		camHUD2.bgColor.alpha = 0;

		camHUDTOP = new FlxCamera();
		camHUDTOP.bgColor.alpha = 0;
		subCams = new FlxCamera();
		subCams.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
                                camGame.bgColor.alpha = 0;


		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(lyricsHUD);
		FlxG.cameras.add(camHUD2);
		FlxG.cameras.add(camHUDTOP);
		FlxG.cameras.add(subCams);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camHUD2;


		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromNewJson('tutorial');

		if (SONG.needsVoices){
			
				for (i in SONG.playerVocalFiles){
		
Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[1] + '-'+ i);

				}
				
					for (i in SONG.opponentVocalFiles){
Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[1] + '-'+ i);
					}
				
			
			
Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[1]);
			
			
		}

		if (SONG.needsSFX){
			for (i in SONG.sfxFiles){
Paths.songStuffer(PlayState.SONG.song,i);

			}
		}
		Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[0]);
		trace(Paths.currentTrackedSounds);
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;
		stageData = StageData.getStageFile(curStage);



		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}
		if(stageData.defaultZoom != null)
		defaultCamZoom = stageData.defaultZoom;
		if(stageData.isPixelStage != null)
		isPixelStage = stageData.isPixelStage;
		if(stageData.boyfriend != null){
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		}
		if(stageData.girlfriend != null){
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		}
		if(stageData.opponent != null){
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		}

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		grpCrossfades = new FlxTypedGroup<FlxSprite>();
		grpGFCrossfades = new FlxTypedGroup<FlxSprite>();


		precacheList.set('hitStatic', 'image');
		switch (curStage)
		{
			
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);
				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

	
	isFixedAspectRatio = false;

	if (isFixedAspectRatio)
		{
			camHUD2.x -= 50; // Best fix ever 2022 (it's just for centering the camera lawl)
			Lib.application.window.resizable = false;
			FlxG.scaleMode = new StageSizeScaleMode();
			FlxG.resizeGame(960, 720);
			FlxG.resizeWindow(960, 720);
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}
		//var usesCustom:String = uiSmelly.altSuffix;
		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}
        /*else if (usesCustom != ''){
			introSoundsSuffix = '-$usesCustom';
		}*/
		add(grpGFCrossfades);
		add(gfGroup); //Needed for blammed lights
		add(grpCrossfades);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camHUD2];
		add(luaDebugGroup);
		#end
        currentChars= [boyfriend,dad,gf];
		var haxefilesPushed:Array<String> = [];
		var haxefoldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('scripts/preloadScripts/')];

		#if MODS_ALLOWED
		haxefoldersToCheck.insert(0, Paths.mods('scripts/preloadScripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			haxefoldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/preloadScripts/'));

		for(mod in Paths.getGlobalMods())
			haxefoldersToCheck.insert(0, Paths.mods(mod + '/scripts/preloadScripts/'));
		#end

		for (folder in haxefoldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.hscript') && !haxefilesPushed.contains(file))
					{
						makeHaxeState('precacheModchart - ' + file.substr(0, file.length - 8), folder, file,true);
						haxefilesPushed.push(file);
					}
					
				}
			}
		}
	

		//AUTO PRECACHE LOL
		var songsReal:Array<String> = [];
        var files = [];
		
       

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = SUtil.getPath() + Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		stopAutoMoving = SONG.disPlayAutoMovingCam;
		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend || !hscriptgfhide)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			gfMap.set(gfVersion, gf);
			startCharacterLua(gf.curCharacter);
			startCharacterHscript(gf.curCharacter);
			setAllHaxeVar('gfName', gf.curCharacter);
			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		setAllHaxeVar('dadName', dad.curCharacter);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		dadMap.set(SONG.player2, dad);
		startCharacterLua(dad.curCharacter);
		startCharacterHscript(dad.curCharacter);
		if (opponentPlayer)
			dad.beingControlled = true;
		boyfriend = new Character(0, 0, SONG.player1, true);
		if (!opponentPlayer)
		boyfriend.beingControlled = true;
		startCharacterPos(boyfriend, true);
		boyfriendGroup.add(boyfriend);
		boyfriendMap.set(SONG.player1, boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		startCharacterHscript(boyfriend.curCharacter);
		setAllHaxeVar('boyfriendName', boyfriend.curCharacter);
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.likeGf) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		if(boyfriend.likeGf) {
			boyfriend.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
			remove(dadGroup);
			remove(boyfriendGroup);
			add(boyfriendGroup); 
			add(dadGroup);
			boyfriend.flipX = true;
		}
		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}


		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.modFolders('data' + songName + '/' + songName + 'Dialogue.txt'); //Checks for vanilla/Senpai dialogue
		var vanillaCheckMod:Bool = false;
		if (OpenFlAssets.exists(file)) {
			vanillaCheckMod = true;	
			dialogue = CoolUtil.coolTextFile(file);
		}
if (!vanillaCheckMod)
	file = Paths.txt(songName + '/' + songName + 'Dialogue');
if (OpenFlAssets.exists(file)) {
		dialogue = CoolUtil.coolTextFile(file);
}


		var filename:Null<String> = null;
	
		if (FNFAssets.exists(SUtil.getPath() + 'windose_data/data/' + SONG.song.toLowerCase() + '/dialog.txt'))
			{
				filename = SUtil.getPath() + 'windose_data/data/' + SONG.song.toLowerCase() + '/dialog.txt';
			}
			else if (FNFAssets.exists(SUtil.getPath() + 'mods/data/' + SONG.song.toLowerCase() + '/dialog.txt'))
				{
					filename = SUtil.getPath() + 'mods/data/' + SONG.song.toLowerCase() + '/dialog.txt';
				}
				else if ((Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0) && FNFAssets.exists(SUtil.getPath() + 'mods/'+ Paths.currentModDirectory +'/data/' + SONG.song.toLowerCase() + '/dialog.txt'))
					{
						filename = SUtil.getPath() + 'mods/'+ Paths.currentModDirectory +'/data/' + SONG.song.toLowerCase() + '/dialog.txt';
					}
			var goodDialog:String;
			if (filename != null) {
				goodDialog = FNFAssets.getText(filename);
			} else {
				goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
			}

			doofM = new DialogueBoxMPlus(false, goodDialog);
			trace('doofensmiz');
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doofM.scrollFactor.set();
			doofM.finishThing = startCountdown;
			doofM.nextDialogueThing = startNextDialogue;
			doofM.skipDialogueThing = skipDialogue;
		doof = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		
		var font:String = "vcr.ttf";
		#if HAD_DIFFERNET_LANGS
		if(ClientPrefs.langType == 'Chinese')
			font = "DinkieBitmap-9px.ttf";
		else if(ClientPrefs.langType == 'English')
			font = "vcr.ttf";
		#end
		Conductor.songPosition = -5000;
		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();


		var	instanceTimeBarBG = new AttachedSprite('custom_ui/' + uiSmelly.uses + '/'  + 'timeBar');
		instanceTimeBarBG.screenCenter(X);
		instanceTimeBarBG.scrollFactor.set();
		instanceTimeBarBG.alpha = 0;

		instanceTimeBarBG.visible = showTime;

		instanceTimeBarBG.color = FlxColor.BLACK;
		instanceTimeBarBG.xAdd = -4;
		instanceTimeBarBG.yAdd = -4;
//preload？？？？
		if (ClientPrefs.downScroll)
			instanceTimeBarBG.y = FlxG.height * 0.9 + 45;

		timeTxt = new FlxText(0, instanceTimeBarBG.y + 6, 0, "", 16);
		timeTxt.setFormat(Paths.font(font), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.visible = showTime;


		timeTxt.screenCenter(X);
		var text = SONG.song;
		#if HAD_DIFFERNET_LANGS
		if(ClientPrefs.langType == 'Chinese')
			text = SONG.songNameChinese;
		else if(ClientPrefs.langType == 'English')
			#end
			text = SONG.song;
		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = text;
		}
		updateTime = showTime;


	timeTxt.y -= 8;
	if(ClientPrefs.timeBarType != 'Song Name')
		timeTxt.y -= 1;
	
		timeTxt.y += 4;
	timeTxt.x -= timeTxt.width / 2;

			timeBar = new HealthBar(instanceTimeBarBG.x + 4, instanceTimeBarBG.y + 8, 'custom_ui/' + uiSmelly.uses + '/'  + 'timeBar', function() return songPercent, 0, 1);
			timeBar.scrollFactor.set();
			timeBar.screenCenter(X);
			timeBar.alpha = 0;
			timeBar.visible = showTime;
			timeBar.setColors(0xFF00FF00, 0xFF808080);
		add(timeBar);
		timeBarBG = timeBar.bg;
		add(timeTxt);
		//timeBarBG.sprTracker = timeBar;
		playerComboBreak = new FlxTypedGroup<FlxSprite>();
		opponentComboBreak = new FlxTypedGroup<FlxSprite>();
		totalComboBreak = new FlxTypedGroup<FlxSprite>();
		add(totalComboBreak);
		totalComboBreak.cameras = [camHUD];
		
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		generateSong(SONG.song);
		//strumLines = new StrumLine(strumLineNotes,notes);
		//add(strumLines);
	
		add(grpNoteSplashes);


			timeTxt.y += 3;
		

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();
		
		
		
		modManager = new ModManager(this);
		
		var eventhaxefilesPushed:Array<String> = [];
		var eventhaxefoldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('custom_events/')];

		#if MODS_ALLOWED
		eventhaxefoldersToCheck.insert(0, Paths.mods('custom_events/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			eventhaxefoldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/custom_events/'));

		for(mod in Paths.getGlobalMods())
			eventhaxefoldersToCheck.insert(0, Paths.mods(mod + '/custom_events/'));
		#end

		for (folder in eventhaxefoldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.hscript') && !eventhaxefilesPushed.contains(file))
					{
						makeHaxeState('event - '+file.substr(0, file.length - 8), folder, file,true);
						eventhaxefilesPushed.push(file);
					}
			
					
				}
			}
		}


			callAllHScript('beforeCut', [SONG.song]);
			
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = SUtil.getPath() + Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = SUtil.getPath() + Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = SUtil.getPath() + Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = SUtil.getPath() + Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollowPos.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		movingCameraSection();

		


		healthBar = new HealthBar(0, FlxG.height * (!ClientPrefs.downScroll ? 0.89 : 0.11), 'custom_ui/' + uiSmelly.uses + '/'  + 'healthBar', function() return healthInstance, 0, 2);
if (!opponentPlayer)
		healthBar.leftToRight = false;
		healthBar.screenCenter(X);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;

		add(healthBar);
		healthBarBG = healthBar.bg;		

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.isPlayState = true;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.isPlayState = true;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);


		if (ClientPrefs.classicStyle){
			scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font(font), 16, FlxColor.WHITE, RIGHT);
		}
		else
		{
		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font(font), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		
		setAllHaxeVar('scoreTxt', scoreTxt);
		setAllHaxeVar('iconP2', iconP2);
		setAllHaxeVar('iconP1', iconP1);
		setAllHaxeVar('healthBar', healthBar);
		setAllHaxeVar('healthBarBG', healthBarBG);
		setAllHaxeVar('timeBar', timeBar);
		setAllHaxeVar('timeBarBG', timeBarBG);
		setAllHaxeVar('timeTxt', timeTxt);
		/* = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = botplay;
		botplayTxt.alpha = 0;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}*/

		if (FileSystem.exists(Paths.json(Paths.formatToSongPath(SONG.song) + '/lyrics'))) {
			trace('ly rics');
			var myLyrics:Array<LyricMeasure> = Lyrics.parseLyrics(Paths.json(Paths.formatToSongPath(SONG.song) + '/lyrics'));
			var lyrics:Lyrics = new Lyrics(myLyrics);
			add(lyrics);
			lyrics.cameras = [lyricsHUD];
		} else if (FileSystem.exists(Paths.modsJson(Paths.formatToSongPath(SONG.song) + '/lyrics'))) {
			trace('ly rics');
			var myLyrics:Array<LyricMeasure> = Lyrics.parseLyrics(Paths.modsJson(Paths.formatToSongPath(SONG.song) + '/lyrics'));
			var lyrics:Lyrics = new Lyrics(myLyrics);
			add(lyrics);

			lyrics.cameras = [lyricsHUD];
		}
		
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
	
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		//botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
	
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		doofM.cameras = [camHUD];
		//strumLines.cameras = [camHUD];
		if (ClientPrefs.classicStyle){
			if (!healthBar.leftToRight)
			healthBar.setColors(0xFFFF0000, 0xFF66FF33);
		
			else
					healthBar.setColors(0xFF66FF33, 0xFFFF0000);
		}else{
			reloadHealthBarColors();
		}
		
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;
		#if mobile
		addAndroidControls();
		#end
		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		#if MODS_ALLOWED
		if (FNFAssets.exists(Paths.modFolders('stages/custom_Hscript_stages/custom_stages.json')) && FNFAssets.exists((Paths.modsHscriptStages(Reflect.field(modsJson, curStage))), Hscript))
			{

		makeHaxeState("stages", Paths.modsHscriptStages('') + curStage + "/", "../"+Reflect.field(modsJson, curStage));
	
			}//HSCRIPT GOD YO
		
			else #end if (FNFAssets.exists((Paths.getHscriptStagePath(Reflect.field(stageJson, curStage))), Hscript))
				{
	
			makeHaxeState("stages", SUtil.getPath() + Paths.getPreloadPath('stages/custom_Hscript_stages/') + curStage + "/", "../"+Reflect.field(stageJson, curStage));
	
				
			
				}//HSCRIPT GOD YO
		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
	
		var haxefilesPushed:Array<String> = [];
		var haxefoldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		haxefoldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			haxefoldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			haxefoldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in haxefoldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.hscript') && !haxefilesPushed.contains(file))
					{
						makeHaxeState(file.substr(0, file.length - 8), folder, file,true);
						haxefilesPushed.push(file);
					}
					
				}
			}
		}
	
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if ((isStoryMode || ClientPrefs.alwaysDoCutscenes)&& !seenCutscene)
		{
			switch (SONG.cutsceneType.toLowerCase())
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollowPos.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'angry-senpai' | 'spirit':
					if(SONG.cutsceneType == 'angry-senpai') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();
					case 'none':
						startCountdown();
					default:
						// schoolIntro(doof);
						customIntro(doofM);


			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		if (ClientPrefs.middleScroll)
			{
				if (currentOpponentStrum == 0){
					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].x += 580;
						}
						for (i in 0...playerStrums.length) {
						playerStrums.members[i].x += 600;
						if(i <= 1) {
						playerStrums.members[i].x -= 65;
						}
						}      
						for (i in 0...strumLineNotes.length) {
							strumLineNotes.members[i].x += 50;
							} 

				}
			}

		callOnLuas('onCreatePost', []);
		callAllHScript('onCreatePost', [SONG.song]);
		super.create();

		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
					#if VIDEOS_ALLOWED
				case 'video':
					Paths.video(key);
					#end
				case 'hscript':
					Paths.hscript(key);
			    case 'idkAssets':
					SUtil.getPath() + Paths.getPreloadPath(key);
				case 'idkModAssets':
					Paths.modFolders(key);	
					//???
			}
		}
		CustomFadeTransition.nextCamera = camHUD2;
		refresh();
	}

	#if sys
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String,?glslVersion:Int = 120):FlxRuntimeShader
	{


		#if (MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1],glslVersion);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function createRuntimePostEffectShader(name:String,?glslVersion:String = '120'):RuntimePostEffectShader
		{
	
	
			#if (MODS_ALLOWED && sys)
			if(!runtimeShaders.exists(name) && !initLuaShader(name))
			{
				FlxG.log.warn('Shader $name is missing!');
				return new RuntimePostEffectShader();
			}
	
			var arr:Array<String> = runtimeShaders.get(name);
			return new RuntimePostEffectShader(arr[0], arr[1],glslVersion);
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

		var foldersToCheck:Array<String> = [ SUtil.getPath() + Paths.getPreloadPath('shaders/'),Paths.mods('shaders/')];
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

	
	public function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function changeNewUI(type:String)
		{
			uiSmelly = Reflect.field(Judgement.uiJson, type);
		}
		public function changeMode(type:Bool)
			{
				if (type){
					opponentPlayer = true;
				
				
				for (dadChar in dadMap.iterator()) {
if (!dadChar.beingControlled)
	dad.beingControlled = true;
				}
				for (bfChar in boyfriendMap.iterator()) {
					if (bfChar.beingControlled)
						bfChar.beingControlled = false;
									}
			
				}
				else if (!type){
					opponentPlayer = false;
				
				
				
				for (dadChar in dadMap.iterator()) {
					if (dadChar.beingControlled)
						dad.beingControlled = false;
									}
									for (bfChar in boyfriendMap.iterator()) {
										if (!bfChar.beingControlled)
											bfChar.beingControlled = true;
														}
				}
			}
	public function addTextToDebug(text:String, color:FlxColor) {

		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));

	}
	public function fromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor
		{
			return FlxColor.fromRGB(red, green, blue,alpha);
		}
		var colors:Array<FlxColor> = [];
	public function reloadHealthBarColors() {
		
			healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			
	}
/*	public function changeHealthStuffsDirections(barDire:String = 'Left'){
		iconMovingType = barDire;
		switch (barDire){
			case 'Left': setBarDirections('healthBar','left_to_right');
			case 'Right': setBarDirections('healthBar','right_to_left');
		}
	}
	public function setBarDirections(barType:String = 'healthBar',barDire:String = 'left_to_right') {
		var curbar = Reflect.getProperty(this, barType);

		curbar.fillDirection = directionsFromString(barDire);
		curbar.updateBar();
		
	}older*/
	
	
	public function directionsFromString(direction:String):FlxBarFillDirection
		{
		switch (direction.trim()){
		case 'right_to_left':	return RIGHT_TO_LEFT;
		case 'top_to_bottom':	return TOP_TO_BOTTOM;
		case 'bottom_to_top':	return BOTTOM_TO_TOP;
		case 'horizontal_inside_out':	return HORIZONTAL_INSIDE_OUT;
		case 'horizontal_outside_in':	return HORIZONTAL_OUTSIDE_IN;
		case 'vertical_inside_out':	return VERTICAL_INSIDE_OUT;
		case 'vertical_out_inside':	return VERTICAL_OUTSIDE_IN;
		}
			return LEFT_TO_RIGHT;
		}
	public function addOtherCharacters(x:Int,y:Int,curMap:String,newCharacters:String,?displayLayer:Int = 0) {
		if(!otherCharactersMap.exists(curMap)) otherCharactersMap.set(curMap,new Map<String, Character>());
			if(!otherCharactersGroups.exists(newCharacters)) {otherCharactersGroups.set(newCharacters,new FlxSpriteGroup(x,y));
				if (displayLayer == 0)
				add(otherCharactersGroups.get(newCharacters));
				else if (displayLayer == 1)
				addBehindGF(otherCharactersGroups.get(newCharacters));
				else if (displayLayer == 2)
					addBehindDad(otherCharactersGroups.get(newCharacters));
				else if (displayLayer == 3)
					addBehindBF(otherCharactersGroups.get(newCharacters));
			}
	
		}
		public function addOtherCharacterToList(curMap:String,curGroup:String,newCharacters:String, ?wasFlip:Bool = false,?wasControl:Bool = false) {
			if(otherCharactersMap.exists(curMap) && otherCharactersGroups.exists(curGroup)) {
			if(!otherCharactersMap.get(curMap).exists(newCharacters)) {
				var newCharacter:Character = new Character(0, 0, newCharacters, wasFlip);
				otherCharactersMap.get(curMap).set(newCharacters, newCharacter);
				otherCharactersGroups.get(curGroup).add(newCharacter);
				startCharacterPos(newCharacter);
				newCharacter.alpha = 0.00001;
				startCharacterLua(newCharacter.curCharacter);
				startCharacterHscript(newCharacter.curCharacter);
				newCharacter.beingControlled = wasControl;
			}
		}
	}
	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend, true);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
					startCharacterHscript(newBoyfriend.curCharacter);
					if (!opponentPlayer)
					newBoyfriend.beingControlled = true;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
					startCharacterHscript(newDad.curCharacter);
					if (opponentPlayer)
						newDad.beingControlled = true;
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
					startCharacterHscript(newGf.curCharacter);
				}
		}
	}

	var hscriptNames:Array<String> = [];
	function startCharacterHscript(name:String)
	{

		var doPush:Bool = false;
		var hscriptFile:String = 'characters/modchart/';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(hscriptFile))) {
			hscriptFile = Paths.modFolders(hscriptFile);
			doPush = true;
		} else {
			hscriptFile =  SUtil.getPath() + Paths.getPreloadPath(hscriptFile);
			if(FileSystem.exists(hscriptFile)) {
				doPush = true;
			}
		}
		#else
		hscriptFile = SUtil.getPath() +  Paths.getPreloadPath(hscriptFile);
		if(Assets.exists(hscriptFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in hscriptNames)
			{
				if(script == name) return;
				makeHaxeState(name, hscriptFile, name + '.hscript',true);
			}
			hscriptNames.push(name);
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = SUtil.getPath() +  Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile =  SUtil.getPath() + Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}
	public function getLuaCharacter(tag:String):ModchartCharacter {
		if(modchartCharacters.exists(tag)) return modchartCharacters.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.likeGf) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String, ?finishfunk:Void->Void = null)
		{
			#if VIDEOS_ALLOWED
			inCutscene = true;
	
			var filepath:String = Paths.video(name);
			#if sys
			if(!FileSystem.exists(filepath))
			#else
			if(!OpenFlAssets.exists(filepath))
			#end
			filepath = name;
			#if sys
			if(!FileSystem.exists(filepath))
			#else
			if(!OpenFlAssets.exists(filepath))
			#end
			{
				FlxG.log.warn('Couldnt find video file: ' + name);
				startAndEnd();
				return;
			}
	
			var video:FlxVideo = new FlxVideo();
				#if (hxCodec >= "3.0.0" || ios)
				// Recent versions
        #if ios
				video.load(filepath);
				video.play();
        #else
				video.play(filepath);
        #end
				video.onEndReached.add(function()
				{
					video.dispose();
					if (finishfunk == null)
						startCountdown();
					else
						finishfunk();
					return;
				}, true);
				#else
				// Older versions
				video.playVideo(filepath);
				video.finishCallback = function()
				{
					if (finishfunk == null)
						startCountdown();
					else
						finishfunk();
					return;
				}
				#end
			#else
			FlxG.log.warn('Platform not supported!');
			startAndEnd();
			return;
			#end
		}
	


	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}
	public function startsWith(key:String, intro:String):Bool
		{
			if (key.startsWith(intro))
				return true;
			else
				return false;
		}

		public function endsWith(key:String, outro:String):Bool
			{
				if (key.endsWith(outro))
					return true;
				else
					return false;
			}
	public function setGlobalVar(key:String, vard:Dynamic):Void
		{
			haxeVars.set(key, vard);
		}
		public function getGlobalFunctions(key:String, curfuntion:Void->Void):Void->Void
			{
				if (haxeFunctions.exists(key))
					return haxeFunctions.get(key);
				else
					return null;
			}
		public function setGlobalFunctions(key:String, curfuntion:Void->Void)
			{
				haxeFunctions.set(key, curfuntion);
			}
			public function removeGlobalFunctions(key:String):Void
				{
					if (haxeFunctions.exists(key)){
						haxeFunctions.remove(key);
					}
					else
						{
							trace("皇帝的新函数");
						}
					}
		public function getGlobalVar(key:String):Null<Dynamic>
		{
			if (haxeVars.exists(key))
				return haxeVars.get(key);
			else
				return null;
		}
	
		public function removeGlobalSprite(key:String, ?destroy:Bool = false):Void
		{
			var spId:FlxSprite;
		
			if ((haxeVars.get(key) is FlxSprite) && haxeVars.exists(key))
			{
				spId = haxeVars.get(key);
				haxeVars.remove(key);
	
				if (destroy)
					spId.destroy();
			}
		}
		public function removeGlobalVar(key:String):Void
			{
				if (haxeVars.exists(key)){
					haxeVars.remove(key);
				}
				else
					{
						trace("皇帝的新变量");
					}
				}
	function customIntro(?dialogueBox:DialogueBoxMPlus) {
		var goodJson = CoolUtil.parseJson(FNFAssets.getText( SUtil.getPath() + Paths.getPreloadPath('scripts/custom_cutscenes/cutscenes.json')));
		#if MODS_ALLOWED var modJson = CoolUtil.parseJson(FNFAssets.getText(Paths.modFolders('scripts/custom_cutscenes/cutscenes.json')));#end

		if (!Reflect.hasField(goodJson, SONG.cutsceneType) #if MODS_ALLOWED && FNFAssets.exists(Paths.modFolders('scripts/custom_cutscenes/cutscenes.json')) && !Reflect.hasField(modJson, SONG.cutsceneType )#end) {
			normalIntro(dialogueBox);
			return;
		}
		inCutscene = true;
		if (Reflect.hasField(goodJson, SONG.cutsceneType))
			{
				makeHaxeState("cutscene",  SUtil.getPath() + Paths.getPreloadPath('scripts/custom_cutscenes/')+SONG.cutsceneType+'/', "../"+Reflect.field(goodJson, SONG.cutsceneType));
			} 
			#if MODS_ALLOWED
		if (FNFAssets.exists(Paths.modFolders('scripts/custom_cutscenes/cutscenes.json')) && Reflect.hasField(modJson, SONG.cutsceneType))
			{
				makeHaxeState("cutscene", Paths.modFolders('scripts/custom_cutscenes/')+SONG.cutsceneType+'/', "../"+Reflect.field(modJson, SONG.cutsceneType));
			}
		#end
		
	}

	function normalIntro(?dialogueBox:DialogueBoxMPlus, intro:Bool=true):Void
		{
			var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);
	
			inCutscene = true;
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				black.alpha -= 0.15;
	
				if (black.alpha > 0)
				{
					tmr.reset(0.3);
				}
				else
				{
					if (dialogueBox != null)
					{
						add(dialogueBox);
					}

	
					remove(black);
				}
			});
		}
		
	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (SONG.cutsceneType == 'angry-senpai' || SONG.cutsceneType == 'spirit')
		{
			remove(black);

			if (SONG.cutsceneType == 'spirit')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (SONG.cutsceneType == 'spirit')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops
		stopAutoMoving = true;
		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
			stopAutoMoving = SONG.disPlayAutoMovingCam;
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	
	public static var startOnTime:Float = 0;
    public var summonNotesAlready:Bool = false;
	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			callAllHScript('onStartCountdown', []);
			for (char in boyfriendMap.iterator()){
				char.onCountdownStart();
				char.onCountdownEnd();
			}
			for (char in dadMap.iterator()){
				char.onCountdownStart();
				char.onCountdownEnd();
			}
			for (char in gfMap.iterator()){
				char.onCountdownStart();
				char.onCountdownEnd();
			}
			return;
		}

		inCutscene = false;
		var haxefilesPushed2:Array<String> = [];
		var haxefoldersToCheck2:Array<String> = [ SUtil.getPath() + Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		haxefoldersToCheck2.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			haxefoldersToCheck2.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			haxefoldersToCheck2.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));
		#end

		for (folder in haxefoldersToCheck2)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.hscript') && !haxefilesPushed2.contains(file))
					{
						makeHaxeState(file.substr(0, file.length - 8), folder, file,true);
						haxefilesPushed2.push(file);
					}
			
				}
			}
		}
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		var ret2:Dynamic = callAllHScript('onStartCountdown', [],false);
		if(ret != FunkinLua.Function_Stop && ret2 != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;
			#if mobile 
			androidc.visible = true;
			#end
			if (!summonNotesAlready){
				summonNotesAlready = true;
				for (i in 0...SONG.strums){
			generateStaticArrows(i,SONG.strums);
				}


			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}
			var recotors = [];
            for (strum in currentStrums){
				recotors.push(strum.members);
			}
			modManager.receptors = recotors;

		}

	
			callOnLuas('preModifierRegister', []);
			modManager.registerDefaultModifiers();
			callOnLuas('postModifierRegister', []);
			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			setAllHaxeVar('startedCountdown', startedCountdown);
			callOnLuas('onCountdownStarted', []);
			callAllHScript('onCountdownStarted', []);
			var swagCounter:Int = 0;

			for (char in boyfriendMap.iterator()){
				char.onCountdownStart();
			}
			for (char in dadMap.iterator()){
				char.onCountdownStart();
			}
			for (char in gfMap.iterator()){
				char.onCountdownStart();
			}
			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}
				for (key in otherCharactersMap.iterator()) {
					if (key != null){
		
						for (character in key.iterator()) {
							if (character != null 
								&& tmr.loopsLeft % character.danceEveryNumBeats == 0 
								&& character.animation.curAnim != null 
								&& !character.animation.curAnim.name.startsWith('sing') 
								&& !character.stunned){
								character.dance();
							}
						}
					}
				}
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();

					for (field in Reflect.fields(Judgement.uiJson)) {
				if (isPixelStage)
					introAssets.set(field, [
						'custom_ui/' + Reflect.field(Judgement.uiJson, field).uses + '/ready-pixel',
						'custom_ui/' + Reflect.field(Judgement.uiJson, field).uses + '/set-pixel',
						'custom_ui/' + Reflect.field(Judgement.uiJson, field).uses+'/date-pixel']);
				else
					introAssets.set(field, [
						'custom_ui/' + Reflect.field(Judgement.uiJson, field).uses + '/ready',
						'custom_ui/' + Reflect.field(Judgement.uiJson, field).uses + '/set',
						'custom_ui/' + Reflect.field(Judgement.uiJson, field).uses +'/go']);
					}
				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;

				for (value in introAssets.keys())
					{
						if (value == SONG.uiType)
						{
							introAlts = introAssets.get(value);
							// ok so apparently a leading slash means absolute soooooo
							if (isPixelStage)
								antialias = false;
						}
					}
				

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}
				var intro3Sound:Sound;
				var intro2Sound:Sound;
				var intro1Sound:Sound;
				var introGoSound:Sound;
				if (FNFAssets.exists( SUtil.getPath() + Paths.getPreloadPath('shared/images/custom_ui/' + uiSmelly.uses + '/intro3' + introSoundsSuffix + '.ogg'))) {
					intro3Sound = FNFAssets.getSound(SUtil.getPath() + Paths.getPreloadPath('shared/images/custom_ui/' + uiSmelly.uses + '/intro3' + introSoundsSuffix + '.ogg'));
					intro2Sound = FNFAssets.getSound(SUtil.getPath() + Paths.getPreloadPath('shared/images/custom_ui/' + uiSmelly.uses + '/intro2' + introSoundsSuffix + '.ogg'));
					intro1Sound = FNFAssets.getSound(SUtil.getPath() + Paths.getPreloadPath('shared/images/custom_ui/' + uiSmelly.uses + '/intro1' + introSoundsSuffix + '.ogg'));
					// apparently this crashes if we do it from audio buffer?
					// no it just understands 'hey that file doesn't exist better do an error'
					introGoSound = FNFAssets.getSound( SUtil.getPath() + Paths.getPreloadPath('shared/images/custom_ui/' + uiSmelly.uses + '/introGo' + introSoundsSuffix + '.ogg'));
				} else if (FNFAssets.exists(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/intro3' + introSoundsSuffix + '.ogg'))) {
					intro3Sound = FNFAssets.getSound(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/intro3' + introSoundsSuffix + '.ogg'));
					intro2Sound = FNFAssets.getSound(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/intro2' + introSoundsSuffix + '.ogg'));
					intro1Sound = FNFAssets.getSound(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/intro1' + introSoundsSuffix + '.ogg'));
					introGoSound = FNFAssets.getSound(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/introGo' + introSoundsSuffix + '.ogg'));
				}else
				{
					intro3Sound = Paths.sound('intro3' + introSoundsSuffix);
					intro2Sound = Paths.sound('intro2' + introSoundsSuffix);
					intro1Sound = Paths.sound('intro1' + introSoundsSuffix);
					introGoSound = Paths.sound('introGo' + introSoundsSuffix);
				}
				var antialias:Bool = (ClientPrefs.globalAntialiasing && !isPixelStage);
				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(intro3Sound, 0.6);
					case 1:
						countdownReady = createCountdownSprite(introAlts[0],antialias);
						FlxG.sound.play(intro2Sound, 0.6);
					case 2:
						countdownSet = createCountdownSprite(introAlts[1],antialias);
						FlxG.sound.play(intro1Sound, 0.6);
					case 3:
						countdownGo = createCountdownSprite(introAlts[2],antialias);
						FlxG.sound.play(introGoSound, 0.6);
					case 4:
						for (char in boyfriendMap.iterator()){
							char.onCountdownEnd();
						}
						for (char in dadMap.iterator()){
							char.onCountdownEnd();
						}
						for (char in gfMap.iterator()){
							char.onCountdownEnd();
						}
				}

				notes.forEachAlive(function(note:Note) {
					var coolMustPress = note.mustPress;
					if(ClientPrefs.opponentStrums || coolMustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !coolMustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				for (note in unspawnNotes){
					var coolMustPress = note.mustPress;
					if(ClientPrefs.opponentStrums || coolMustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !coolMustPress) {
							note.alpha *= 0.35;
						}
					}
				}
				for (char in boyfriendMap.iterator()){
					char.onCountdownStep(swagCounter);
				}
				for (char in dadMap.iterator()){
					char.onCountdownStep(swagCounter);
				}
				for (char in gfMap.iterator()){
					char.onCountdownStep(swagCounter);
				}
				callOnLuas('onCountdownTick', [swagCounter]);
				callAllHScript('onCountdownTick', [swagCounter]);
				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}
	public function createCountdownSprite(image:String, antialias:Bool):FlxSprite
		{
			var spr:FlxSprite = new FlxSprite().loadGraphic(
				FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/' + image + '.png') ? 
				FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/shared/images/' + image + '.png') :
				FNFAssets.getBitmapData(Paths.modFolders('images/' + image + '.png')));
			spr.cameras = [camHUD];
			spr.scrollFactor.set();
			spr.updateHitbox();
	
			if (PlayState.isPixelStage)
				spr.setGraphicSize(Std.int(spr.width * daPixelZoom));
	
			spr.screenCenter();
			spr.antialiasing = antialias;
			insert(members.indexOf(notes), spr);
			FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					remove(spr);
					spr.destroy();
				}
			});
			return spr;
		}
	public function addBehindSprite(obj:FlxObject,obj1:FlxObject)
		{
			insert(members.indexOf(obj1), obj);
		}
	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();

			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
				callAllHScript('onNoteDestroy', [daNote]);
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		if (!ClientPrefs.classicStyle){
			#if HAD_DIFFERNET_LANGS
			if(ClientPrefs.langType == 'English'){
				#end
				scoreTxt.text = 'Score: ' + songScore
				+ ' | Combo Breaks: ' + songMisses
				+ ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + " %"
				+ " | " + (ratingFC == null ? "" : "(" + ratingFC + ")") + accuracyShits(ratingPercent * 100)
				+ " | Rating : " + ratingName;
				#if HAD_DIFFERNET_LANGS	
			}
					else if(ClientPrefs.langType == 'Chinese')
						{
							scoreTxt.text = '得分: ' + songScore
							+ ' | 断连数: ' + songMisses
							+ ' | 准确率: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + " %"
							+ " | " + (ratingFC == null ? "" : "(" + ratingFC + ")") + accuracyShits(ratingPercent * 100)
							+ " | 评分 : " + ratingName;		
						}
						#end
				}
				else
				{
					#if HAD_DIFFERNET_LANGS	
					if(ClientPrefs.langType == 'English')
						#end
				scoreTxt.text = 'Score:' + songScore;
				#if HAD_DIFFERNET_LANGS
					else if(ClientPrefs.langType == 'Chinese')
						scoreTxt.text = '得分:' + songScore;
					#end		
				}
		if(ClientPrefs.scoreZoom && !miss && !botplay)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
	}

	public function setSongTime(time:Float = 0)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		sfx.pause();
		FlxG.sound.music.time = time;
		FlxG.sound.music.play();
		
		vocals.forEachAlive(function(sound:FlxSound) {
			if (Conductor.songPosition <= sound.length)
				{
					sound.time = time;
				}
		  });
		  vocals.play();
		
		  sfx.forEachAlive(function(sound:FlxSound) {
			if (Conductor.songPosition <= sfx.length)
				{
					sfx.time = time;
				}
		  });
		  sfx.play();
		
	
	
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callAllHScript('onNextDialogue', [dialogueCount]);
		callOnLuas('onNextDialogue', [dialogueCount]);
	}


	function skipDialogue() {
		callAllHScript('onSkipDialogue', [dialogueCount]);
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;
	var songGenerated:Bool = false;
    function generateSongF(){
		
		vocals = new VoicesGroup();
var igroneSpilt:Bool = true;
		if (SONG.needsVoices){
        if (SONG.playerVocalFiles.length>0){
				for (i in SONG.playerVocalFiles){
					var fileP:Dynamic = Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[1] + '-'+ i);
					if (Std.isOfType(fileP, Sound) || OpenFlAssets.exists(fileP)) {
						   var snd:FlxSound = new FlxSound();
						   snd.loadEmbedded(fileP);
						   vocals.addPlayerVoice(snd);
					}
				}
				igroneSpilt = false;
			}        
			if (SONG.opponentVocalFiles.length>0){
					for (i in SONG.opponentVocalFiles){
						var fileP:Dynamic = Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[1] + '-'+ i);
						if (Std.isOfType(fileP, Sound) || OpenFlAssets.exists(fileP)) {
							   var snd:FlxSound = new FlxSound();
							   snd.loadEmbedded(fileP);
							   vocals.addOpponentVoice(snd);
						}
			
					}
					igroneSpilt = false;
			}
			
			if (igroneSpilt || (vocals.playerVoices.members.length<=0|| vocals.opponentVoices.members.length<=0)){
				if (!igroneSpilt)
				vocals.clear();
				var snd:FlxSound = new FlxSound();
				snd.loadEmbedded(Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[1]));
		vocals.add(snd);
		trace(snd);
			}
			
		}
		add(vocals);



		sfx = new SoundGroup();
		if (SONG.needsSFX)
			SoundGroup.build(SONG.song,SONG.sfxFiles);

			add(sfx);
			
	
	}
	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.songStuffer(PlayState.SONG.song,PlayState.SONG.songFileNames[0]), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
        vocals.play();
        sfx.play();
		for (char in boyfriendMap.iterator()){
			char.onSongLoaded();
		}
		for (char in dadMap.iterator()){
			char.onSongLoaded();
		}
		for (char in gfMap.iterator()){
			char.onSongLoaded();
		}
		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		

		startOnTime = 0;
		songGenerated = true;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();	
			sfx.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		setAllHaxeVar('songLength', songLength);
		for (char in boyfriendMap.iterator()){
			char.onSongStart();
		}
		for (char in dadMap.iterator()){
			char.onSongStart();
		}
		for (char in gfMap.iterator()){
			char.onSongStart();
		}
		callAllHScript('onSongStart', []);

		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	var stair:Int = 0;
	public var preacacheSongs:Map<String, Map<String,Dynamic>> = new Map<String, Map<String,Dynamic>>();
	
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	public function preacacheSongData(dataPath:String = '')
		{
			if (dataPath == '' || dataPath == null)
				return;
var data:Map<String,Dynamic> = new Map<String,Dynamic>();
var difficulty:String = CoolUtil.getDifficultyFilePath(storyDifficulty);
var preEvents = [];
var precacheNotes = [];
var preNotesToSpawn:Array<Array<Note>> = [];
			var songData = Song.loadFromNewJson(dataPath.toLowerCase() + difficulty, dataPath.toLowerCase());
           data.set("song",songData);
		   movemoveCamDamn = songData.song;
		   var preVocal = new VoicesGroup();
		   var preInst = new FlxSound().loadEmbedded(Paths.songStuffer(songData.song,songData.songFileNames[0]));
		   var igroneSpilt = true;
		   if (songData.needsVoices){
			if (songData.playerVocalFiles.length>0){
				   for (i in songData.playerVocalFiles){
					var fileP:Dynamic = Paths.songStuffer(songData.song,songData.songFileNames[1] + '-'+ i);
						if (Std.isOfType(fileP, Sound) || OpenFlAssets.exists(fileP)) {
							   var snd:FlxSound = new FlxSound();
							   snd.loadEmbedded(fileP);
							   preVocal.addPlayerVoice(snd);
						}

					}
					igroneSpilt = false;
				   }
				   if (songData.opponentVocalFiles.length>0){
					   for (i in songData.opponentVocalFiles){
						var fileP:Dynamic = Paths.songStuffer(songData.song,songData.songFileNames[1] + '-'+ i);
						if (Std.isOfType(fileP, Sound) || OpenFlAssets.exists(fileP)) {
							   var snd:FlxSound = new FlxSound();
							   snd.loadEmbedded(fileP);
							   preVocal.addOpponentVoice(snd);
						}

					   }
					   igroneSpilt = false;
				   }
				}
			   if (igroneSpilt ||(preVocal.playerVoices.members.length<=0|| preVocal.opponentVoices.members.length<=0)){
				if (!igroneSpilt)
				    preVocal.clear();
				   var snd:FlxSound = new FlxSound();
				   snd.loadEmbedded(Paths.songStuffer(songData.song,songData.songFileNames[1]));
				   preVocal.add(snd);
			   }
			   
		   
		   var presfx = new SoundGroup();
		   if (songData.needsSFX){
			SoundGroup.build(songData.song,songData.sfxFiles);
			   
			   }

			FlxG.sound.list.add(preInst);
			trace(preVocal);
			trace(preInst);
	
			var noteData:Array<SwagSection>;
	
			// NEW SHIT
			noteData = songData.notes;
			var playerCounter:Int = 0;
	
			var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
			var random:Random = null;
	
			if (chartType == "chaos")
				{
					random = new Random(null, new seedyrng.Xorshift64Plus());
					if (FlxG.random.bool(50))
		    	{
          #if !ios
		    		if (FlxG.random.bool(50))
		    		{
          #end
		    			var seed = FlxG.random.int(1000000, 9999999); // seed in string numbers
		    			FlxG.log.add('SEED (STRING): ' + seed);
		    			random.setStringSeed(Std.string(seed));
					  #if !ios
		    		}
		    		else
	    			{
	    				var seed = Random.Random.string(7);
	    				FlxG.log.add('SEED (STRING): ' + seed); // seed in string (alphabet edition)
	    				random.setStringSeed(seed);
	    			}
					 #end
	    		}
	    		else
	    		{
	    			var seed = FlxG.random.int(1000000, 9999999); // seed in int
	    			FlxG.log.add('SEED (INT): ' + seed);
	    			random.seed = seed;
	    		}
	}
			var songName:String = Paths.formatToSongPath(songData.song);
			trace(songName);
			var file:String = Paths.json(songName + '/events');
			#if MODS_ALLOWED
			if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) 
			#else
			if (OpenFlAssets.exists(file)) 
			#end
		{
				var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
				trace(eventsData);
				for (curEvent in eventsData) //Event Notes
				{
					for (i in 0...curEvent[1].length)
					{
						var newEventNote:Array<Dynamic> = [curEvent[0], curEvent[1][i][0], curEvent[1][i][1], curEvent[1][i][2], curEvent[1][i][3], curEvent[1][i][4]];
						var subEvent:EventNote = {
							strumTime: newEventNote[0] + ClientPrefs.noteOffset,
							event: newEventNote[1],
							value1: newEventNote[2],
							value2: newEventNote[3],
							value3: newEventNote[4]
						};

						subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
						
						preEvents.push(subEvent);

						eventPushed(subEvent);

					}
				}
			}
			for(i in 0...4)
				preNotesToSpawn[i] = [];
			for (sec in noteData)
			{
				for (preSongNotes in sec.sectionNotes)
				{
					var daStrumTime:Float = preSongNotes[0];
					var fuckYOU = preSongNotes[1];
					if (!songData.igorAutoFix){
					if (!sec.mustHitSection){
						if (fuckYOU < Note.NOTE_AMOUNT*2){
						if (fuckYOU >= Note.NOTE_AMOUNT)
							{
								fuckYOU -= Note.NOTE_AMOUNT;
							}
							else
							{
								fuckYOU += Note.NOTE_AMOUNT;
							}
						}
					}
					}
					var daNoteData:Int = Std.int(fuckYOU % Note.NOTE_AMOUNT);
				
					var daNoteStrum:Int = Math.floor(fuckYOU / Note.NOTE_AMOUNT);
					
					var altNote:Bool = false;
					var crossFade:Bool = false;
					var gottaHitNote:Bool = if (daNoteStrum == currentPlayerStrum) true else false;
	             
					if (preSongNotes[4] || sec.altAnim)
					{
						altNote = true;
					}
	
					
					switch (chartType)
					{
						case "standard":
								daNoteData = Std.int(preSongNotes[1] % Note.NOTE_AMOUNT);
						case "flip":
						
									daNoteData = Note.NOTE_AMOUNT - 1 - Std.int(preSongNotes[1] % Note.NOTE_AMOUNT);
							
	
						case "chaos":
								daNoteData = random.randomInt(0, Note.NOTE_AMOUNT-1);
	
						case "onearrow":
							daNoteData = arrowLane;
						case "stair":
								daNoteData = stair % Note.NOTE_AMOUNT;
							stair++;
						case "dualarrow":
							switch (stair)
							{
								case 0:
									daNoteData = arrowLane;
									stair = 1;
								case 1:
									daNoteData = arrowLane2;
									stair = 0;
							}
						case "dualchaos":
							if (FlxG.random.bool(50))
								daNoteData = arrowLane;
							else
								daNoteData = arrowLane2;
						case "wave":
								switch (stair % 6)
								{
									case 0 | 1 | 2 | 3:
										daNoteData = stair % 6;
									case 4:
										daNoteData = 2;
									case 5:
										daNoteData = 1;
								}
	
							stair++;
					}
	
	
					var oldNote:Note;
					if (precacheNotes.length > 0)
						oldNote = precacheNotes[Std.int(precacheNotes.length - 1)];
					else
						oldNote = null;
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.currentStrum = daNoteStrum;
					swagNote.mustPress = if (daNoteStrum == currentPlayerStrum) true else false;
	                switch (swagNote.currentStrum){
						case 0:
							swagNote.whoShouldSing = 'boyfriend';
							swagNote.whoIsOpponent = 'dad';
							case 1:
								swagNote.whoShouldSing = 'dad';
								swagNote.whoIsOpponent = 'boyfriend';
							default:
								swagNote.whoShouldSing = 'boyfriend';
								swagNote.whoIsOpponent = 'dad';
					}
					swagNote.altNote = altNote;
	
					swagNote.sustainLength = preSongNotes[2];
	
					swagNote.crossFade = crossFade;
					swagNote.altNum = preSongNotes[4] == null ? (swagNote.altNote ? 1 : 0) : preSongNotes[4];
	
					swagNote.gfNote = (sec.gfSection && (preSongNotes[1]%8<4));
					swagNote.noteType = preSongNotes[3];
					if(!Std.isOfType(preSongNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[preSongNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
					swagNote.scrollFactor.set();
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Conductor.stepCrochet;
					precacheNotes.push(swagNote);
					if(preNotesToSpawn[swagNote.noteData]==null)
						preNotesToSpawn[swagNote.noteData] = [];
	
					preNotesToSpawn[swagNote.noteData].push(swagNote);
					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = precacheNotes[Std.int(precacheNotes.length - 1)];
	
							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
							sustainNote.currentStrum = daNoteStrum;
					        sustainNote.mustPress =  if (daNoteStrum == 1) true else false;
							switch (sustainNote.currentStrum){
								case 0:
									sustainNote.whoShouldSing = 'boyfriend';
									sustainNote.whoIsOpponent = 'dad';
							case 1:
								sustainNote.whoShouldSing = 'dad';
								sustainNote.whoIsOpponent = 'boyfriend';
							default:
								sustainNote.whoShouldSing = 'boyfriend';
								sustainNote.whoIsOpponent = 'dad';
							}
							sustainNote.altNote = swagNote.altNote;
							sustainNote.crossFade = swagNote.crossFade;
							sustainNote.altNum = swagNote.altNum;
						
							sustainNote.gfNote = (sec.gfSection && (preSongNotes[1]%8<4));
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							swagNote.tail.push(sustainNote);
							sustainNote.parent = swagNote;
							precacheNotes.push(sustainNote);
							preNotesToSpawn[swagNote.noteData].push(sustainNote);
							if (sustainNote.currentStrum == currentPlayerStrum)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
							else if(ClientPrefs.middleScroll && sustainNote.currentStrum == currentOpponentStrum)
							{
								switch (currentOpponentStrum){
									case 1:
								sustainNote.x += 310;
								if(daNoteData > 1) //Up and Right
								{
									sustainNote.x += FlxG.width / 2 + 25;
								}
                                  case 0:
									sustainNote.x -= 310;
								if(daNoteData <= 1) //Up and Right
								{
									sustainNote.x -= -FlxG.width / 2 - 25;
								}
							}
							}
						
						}
					}

					if (swagNote.currentStrum == currentPlayerStrum)
						{
							swagNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll && swagNote.currentStrum == currentOpponentStrum)
						{
							switch (currentOpponentStrum){
								case 1:
									swagNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								swagNote.x += FlxG.width / 2 + 25;
							}
							  case 0:
								swagNote.x -= 310;
							if(daNoteData <= 1) //Up and Right
							{
								swagNote.x -= -FlxG.width / 2 - 25;
							}
						}
						}
					
					callAllHScript('onPreCreateNote',[swagNote]);
					
					if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}
				
			}
				daBeats += 1;
				
			}
		
			for (curEvent in songData.events) //Event Notes
			{
				for (i in 0...curEvent[1].length)
				{
					var newEventNote:Array<Dynamic> = [curEvent[0], curEvent[1][i][0], curEvent[1][i][1], curEvent[1][i][2], curEvent[1][i][3], curEvent[1][i][4]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3],
						value3: newEventNote[4]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					preEvents.push(subEvent);
					eventPushed(subEvent);
				}
			}
		
			// trace(precacheNotes.length);
			// playerCounter += 1;
	
			precacheNotes.sort(sortByShit);
			if(preEvents.length > 1) { //No need to sort if there's a single one or none at all
			preEvents.sort(sortByTime);
			}

			data.set('eventNotes',preEvents);
			data.set('preCommons',preNotesToSpawn);
			data.set('notes',precacheNotes);
			data.set('voices',preVocal);
			data.set('sfx',presfx);
			data.set('inst',preInst);
			preacacheSongs.set(dataPath,data);
			movemoveCamDamn = PlayState.SONG.song;
		}
	public function switchSong(dataPath:String = '',isEndSong:Bool = false)
		{
			if (dataPath == '' || dataPath == null || !preacacheSongs.exists(dataPath))
				return;
    var preSongData = preacacheSongs.get(dataPath);
    if (isEndSong){
		if (SONG.validScore && !botplay)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
				if (isStoryMode)
					{
						campaignScore += songScore;
						campaignMisses += songMisses;
					
					}
			}
	}

	KillNotes();
	Conductor.songPosition = -5000;
	deathCounter = 0;
	seenCutscene = false;
	curStep = 0;
	curBeat = 0;
	stepsToDo = 0;
	curDecBeat = 0;
	curDecStep = 0;
	curSection = 0;
	lastBeatHit = -1;
	songScore = 0;
	songMisses = 0;
	songHits = 0;
	totalPlayed = 0;
	totalNotesHit = 0;
	health = 1;
	healthInstance = 1;
	ratingFC = null;
	RecalculateRating();
	FlxG.sound.music.pause();
	FlxG.sound.music.volume = 0;
	sfx.pause();
	sfx.volume = 0;
	vocals.pause();
	vocals.volume = 0;
    SONG = preSongData.get('song');
	var songData = SONG;
	Conductor.mapBPMChanges(songData);
	Conductor.changeBPM(songData.bpm);
	stopAutoMoving = songData.disPlayAutoMovingCam;
	songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

	switch(songSpeedType)
	{
		case "multiplicative":
			songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
		case "constant":
			songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
	}

	vocals = preSongData.get('voices');
	sfx = preSongData.get('sfx');
	notesToSpawn = preSongData.get('preCommons');
	unspawnNotes = preSongData.get('notes');
	eventNotes = preSongData.get('eventNotes');
	movemoveCamDamn = SONG.song;
	if (!camMoveFucked.exists(movemoveCamDamn))
		camMoveFucked.set(movemoveCamDamn,[]);
	cameraFocusList = camMoveFucked.get(movemoveCamDamn);
	startedCountdown = false;
	startingSong = true;
	startCountdown();
	callAllHScript('onSwitchSong', [dataPath]);
	}
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = PlayState.SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		movemoveCamDamn = curSong;
			
		notes = new FlxTypedGroup<Note>();
		add(notes);
			generateSongF();
		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var random:Random = null;

		if (chartType == "chaos")
			{
				random = new Random(null, new seedyrng.Xorshift64Plus());
				if (FlxG.random.bool(50))
		    	{
          #if !ios
		    		if (FlxG.random.bool(50))
		    		{
          #end
		    			var seed = FlxG.random.int(1000000, 9999999); // seed in string numbers
		    			FlxG.log.add('SEED (STRING): ' + seed);
		    			random.setStringSeed(Std.string(seed));
					  #if !ios
		    		}
		    		else
	    			{
	    				var seed = Random.Random.string(7);
	    				FlxG.log.add('SEED (STRING): ' + seed); // seed in string (alphabet edition)
	    				random.setStringSeed(seed);
	    			}
					 #end
	    		}
	    		else
	    		{
	    			var seed = FlxG.random.int(1000000, 9999999); // seed in int
	    			FlxG.log.add('SEED (INT): ' + seed);
	    			random.seed = seed;
	    		}
}
		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2], event[1][i][3], event[1][i][4]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3],
						value3: newEventNote[4]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}
		for(i in 0...4)
			notesToSpawn[i] = [];
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var fuckYOU = songNotes[1];
					if (!songData.igorAutoFix){
					if (!section.mustHitSection){
						if (fuckYOU < Note.NOTE_AMOUNT*2){
						if (fuckYOU >= Note.NOTE_AMOUNT)
							{
								fuckYOU -= Note.NOTE_AMOUNT;
							}
							else
							{
								fuckYOU += Note.NOTE_AMOUNT;
							}
						}
					}
					}
					var daNoteData:Int = Std.int(fuckYOU % Note.NOTE_AMOUNT);
				
					var daNoteStrum:Int = Math.floor(fuckYOU / Note.NOTE_AMOUNT);


				var altNote:Bool = false;
				var crossFade:Bool = false;
				var gottaHitNote:Bool = if (daNoteStrum == currentPlayerStrum) true else false;

	
				
				if (songNotes[4] || section.altAnim)
				{
					altNote = true;
				}


				
				switch (chartType)
				{
					case "standard":
							daNoteData = Std.int(songNotes[1] % Note.NOTE_AMOUNT);
					case "flip":
					
								daNoteData = Note.NOTE_AMOUNT - 1 - Std.int(songNotes[1] % Note.NOTE_AMOUNT);
						

					case "chaos":
							daNoteData = random.randomInt(0, Note.NOTE_AMOUNT - 1);

					case "onearrow":
						daNoteData = arrowLane;
					case "stair":
							daNoteData = stair % Note.NOTE_AMOUNT;
						stair++;
					case "dualarrow":
						switch (stair)
						{
							case 0:
								daNoteData = arrowLane;
								stair = 1;
							case 1:
								daNoteData = arrowLane2;
								stair = 0;
						}
					case "dualchaos":
						if (FlxG.random.bool(50))
							daNoteData = arrowLane;
						else
							daNoteData = arrowLane2;
					case "wave":
							switch (stair % 6)
							{
								case 0 | 1 | 2 | 3:
									daNoteData = stair % 6;
								case 4:
									daNoteData = 2;
								case 5:
									daNoteData = 1;
							}

						stair++;
				}


				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.currentStrum = daNoteStrum;
				swagNote.mustPress = if (daNoteStrum == currentPlayerStrum) true else false;
				switch (swagNote.currentStrum){
					case 0:
						swagNote.whoShouldSing = 'boyfriend';
								swagNote.whoIsOpponent = 'dad';
							case 1:
								swagNote.whoShouldSing = 'dad';
								swagNote.whoIsOpponent = 'boyfriend';
							default:
								swagNote.whoShouldSing = 'boyfriend';
								swagNote.whoIsOpponent = 'dad';
				}
				swagNote.altNote = altNote;

				swagNote.sustainLength = songNotes[2];

				swagNote.crossFade = crossFade;
				swagNote.altNum = songNotes[4] == null ? (swagNote.altNote ? 1 : 0) : songNotes[4];

				swagNote.gfNote = (section.gfSection && (songNotes[1]%8<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
			
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				if(notesToSpawn[swagNote.noteData]==null)
					notesToSpawn[swagNote.noteData] = [];

				notesToSpawn[swagNote.noteData].push(swagNote);
				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.currentStrum = daNoteStrum;
					    sustainNote.mustPress = if (daNoteStrum == currentPlayerStrum) true else false;
						switch (sustainNote.currentStrum){
							case 0:
								sustainNote.whoShouldSing = 'boyfriend';
								sustainNote.whoIsOpponent = 'dad';
							case 1:
								sustainNote.whoShouldSing = 'dad';
								sustainNote.whoIsOpponent = 'boyfriend';
							default:
								sustainNote.whoShouldSing = 'boyfriend';
								sustainNote.whoIsOpponent = 'dad';
						}
						sustainNote.altNote = swagNote.altNote;
						sustainNote.crossFade = swagNote.crossFade;
						sustainNote.altNum = swagNote.altNum;
						
						sustainNote.gfNote = (section.gfSection && (songNotes[1]%8<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						//sustainNote.correctionOffset = swagNote.height / 2;
							if(!PlayState.isPixelStage)
								{
								
								//	if(ClientPrefs.downScroll)
									//	sustainNote.correctionOffset = 0;
								}
								
						notesToSpawn[swagNote.noteData].push(sustainNote);
					
								if (sustainNote.currentStrum == currentPlayerStrum)
									{
										sustainNote.x += FlxG.width / 2; // general offset
									}
									else if(ClientPrefs.middleScroll && sustainNote.currentStrum == currentOpponentStrum)
									{
										switch (currentOpponentStrum){
											case 1:
										sustainNote.x += 310;
										if(daNoteData > 1) //Up and Right
										{
											sustainNote.x += FlxG.width / 2 + 25;
										}
										  case 0:
											sustainNote.x -= 310;
										if(daNoteData <= 1) //Up and Right
										{
											sustainNote.x -= -FlxG.width / 2 - 25;
										}
									}
									}
								
								}
							}
		
							if (swagNote.currentStrum == currentPlayerStrum)
								{
									swagNote.x += FlxG.width / 2; // general offset
								}
								else if(ClientPrefs.middleScroll && swagNote.currentStrum == currentOpponentStrum)
								{
									switch (currentOpponentStrum){
										case 1:
											swagNote.x += 310;
									if(daNoteData > 1) //Up and Right
									{
										swagNote.x += FlxG.width / 2 + 25;
									}
									  case 0:
										swagNote.x -= 310;
									if(daNoteData <= 1) //Up and Right
									{
										swagNote.x -= -FlxG.width / 2 - 25;
									}
								}
								}
								callAllHScript('onCreateNote',[swagNote]);
				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
		
		}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2], event[1][i][3], event[1][i][4]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3],
					value3: newEventNote[4]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
		if (!camMoveFucked.exists(movemoveCamDamn))
			camMoveFucked.set(movemoveCamDamn,[]);
		cameraFocusList = camMoveFucked.get(movemoveCamDamn);
		callAllHScript('onSongGenerated', [SONG.song]);
	}
	


	public var outputSprite:FlxSprite = null;
	public var behindValueLOL:FlxSprite;
	public var camMoveFucked:Map<String,Array<String>> = new Map<String,Array<String>>();
	public var cameraFocusList:Array<String> = [];
	public var movemoveCamDamn:String = '';
function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'FocusCamera':

				if (!camMoveFucked.exists(movemoveCamDamn))
					camMoveFucked.set(movemoveCamDamn,[]);
					var damn = camMoveFucked.get(movemoveCamDamn);
				var ID = Std.parseInt(event.value1);
				if(Math.isNaN(ID)) ID = 0;
				switch(ID)
				{
					case 0:
						damn.push("bf");
						case 1:
							damn.push("dad");
						case 2:
							damn.push("gf");
					}
					
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				if (phillyStreet != null)
				insert(members.indexOf(phillyStreet), blammedLightsBlack);
                else
				insert(members.indexOf(glowbehind), blammedLightsBlack);
                
						if (phillyWindowEvent == null && curStage == 'philly')
							{
				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);
							}

				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;


				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	public function generateStaticArrows(player:Int,strumNum:Int = 2):Void
	{
		var strum = new FlxTypedGroup<StrumNote>();
		if (player == 0)
			strum = playerStrums;
		else if (player == 1)
			strum = opponentStrums;
		
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player == 0 && !opponentPlayer)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}
           else
			if (player == 1 && opponentPlayer)
				{
					if(!ClientPrefs.opponentStrums) targetAlpha = 0;
					else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
				}
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : (ClientPrefs.classicStyle ? 0 : STRUM_X), strumLine.y, i, player,strumNum);
			babyArrow.downScroll = ClientPrefs.downScroll;

			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}
			if (player == 1)
				{
					if(ClientPrefs.middleScroll && opponentPlayer)
						{
					babyArrow.x -= 310;
					if(i <= 1) { //Up and Right
						babyArrow.x -= FlxG.width / 2 - 25;
					}
				}

				playerStrums.add(babyArrow);
				}
				else if (player == 0)
				{
					if(ClientPrefs.middleScroll && !opponentPlayer)
					{
						babyArrow.x += 310;
						if(i > 1) { //Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}

					opponentStrums.add(babyArrow);
				}else{
					strum.add(babyArrow);
				}
				
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
			var comboBreakThing = new FlxSprite(babyArrow.x, 0).makeGraphic(Std.int(babyArrow.width), FlxG.height, FlxColor.WHITE);
				comboBreakThing.visible = false;
				comboBreakThing.alpha = 0.6;
				if (player == currentPlayerStrum) {
				playerComboBreak.add(comboBreakThing);
				} else{
				opponentComboBreak.add(comboBreakThing);
				}
				totalComboBreak.add(comboBreakThing);
		}
           currentStrums.push(strum);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				sfx.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			for (char in boyfriendMap.iterator()){
				char.onResume();
			}
			for (char in dadMap.iterator()){
				char.onResume();
			}
			for (char in gfMap.iterator()){
				char.onResume();
			}
			callOnLuas('onResume', []);

			setAllHaxeVar('onResume', []);
			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end
		callAllHScript('onFocus', []);
		
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end
		callAllHScript('onFocusLost', []);
		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;
        
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;

		vocals.forEachAlive(function(sound:FlxSound) {
			if (Conductor.songPosition <= sound.length)
				{
					sound.time = Conductor.songPosition;
				}
		  });
		
		vocals.play();


		sfx.forEachAlive(function(sound:FlxSound) {
			if (Conductor.songPosition <= sfx.length)
				{
					sfx.time = Conductor.songPosition;
				}
		  });
		sfx.play();
	}
	
	public var paused:Bool = false;
	
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	public function popupWindow(customWidth:Int, customHeight:Int, ?customX:Int, ?customName:String) {
        var display = Application.current.window.display.currentMode;
        // PlayState.defaultCamZoom = 0.5;

		if(customName == '' || customName == null){
			customName = 'Opponent.json';
		}

        windowDad = Lib.application.createWindow({
            title: customName,
            width: customWidth,
            height: customHeight,
            borderless: false,
            alwaysOnTop: true

        });
		if(customX == null){
			customX = -10;
		}
        windowDad.x = customX;
	    	windowDad.y = Std.int(display.height / 2);
        windowDad.stage.color = 0xFF010101;
        @:privateAccess
        windowDad.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
        @:privateAccess
        windowDad.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);
        // Application.current.window.x = Std.int(display.width / 2) - 640;
        // Application.current.window.y = Std.int(display.height / 2);

        // var bg = Paths.image(PUT YOUR IMAGE HERE!!!!).bitmap;
        // var spr = new Sprite();

        var m = new Matrix();

        // spr.graphics.beginBitmapFill(bg, m);
        // spr.graphics.drawRect(0, 0, bg.width, bg.height);
        // spr.graphics.endFill();
        FlxG.mouse.useSystemCursor = true;

        //Application.current.window.resize(640, 480);



        dadWin.graphics.beginBitmapFill(dad.pixels, m);
        dadWin.graphics.drawRect(0, 0, dad.pixels.width, dad.pixels.height);
        dadWin.graphics.endFill();
        dadScrollWin.scrollRect = new Rectangle();
	// windowDad.stage.addChild(spr);
        windowDad.stage.addChild(dadScrollWin);
        dadScrollWin.addChild(dadWin);
        dadScrollWin.scaleX = 0.7;
        dadScrollWin.scaleY = 0.7;
        // dadGroup.visible = false;
        // uncomment the line above if you want it to hide the dad ingame and make it visible via the windoe
        Application.current.window.focus();
	    	FlxG.autoPause = false;
    }
	override public function update(elapsed:Float)
	{

	if (isFixedAspectRatio)
			FlxG.fullscreen = false;

		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		callOnLuas('onUpdate', [elapsed]);

		@:privateAccess
        var dadFrame = dad._frame;
        
        if (dadFrame == null || dadFrame.frame == null) return; // prevents crashes (i think???)
            
        var rect = new Rectangle(dadFrame.frame.x, dadFrame.frame.y, dadFrame.frame.width, dadFrame.frame.height);
        
        dadScrollWin.scrollRect = rect;
        dadScrollWin.x = (((dadFrame.offset.x) - (dad.offset.x / 2)) * dadScrollWin.scaleX);
        dadScrollWin.y = (((dadFrame.offset.y) - (dad.offset.y / 2)) * dadScrollWin.scaleY);     

		setAllHaxeVar('camZooming', camZooming);
		setAllHaxeVar('gfSpeed', gfSpeed);
		setAllHaxeVar('health', health);

		callAllHScript('update', [elapsed]);
		healthInstance = FlxMath.lerp(healthInstance, health, CoolUtil.boundTo(elapsed * 24, 0, 1));
		if(phillyGlowParticles != null)
			{
				var i:Int = phillyGlowParticles.members.length-1;
				while (i > 0)
				{
					var particle = phillyGlowParticles.members[i];
					if(particle.alpha < 0)
					{
						particle.kill();
						phillyGlowParticles.remove(particle, true);
						particle.destroy();
					}
					--i;
				}
			}
			
		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;


			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);
		setAllHaxeVar('curDecStep', curDecStep);
		setAllHaxeVar('curDecBeat', curDecBeat);
		/*if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}*/

		if ((controls.PAUSE  #if android || FlxG.android.justReleased.BACK #end )&& startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			var ret2:Dynamic = callAllHScript('onPause', [],false);
			
			if(ret != FunkinLua.Function_Stop && ret2 != FunkinLua.Function_Stop) {
				openPauseMenu();
				for (char in boyfriendMap.iterator()){
					char.onPause();
				}
				for (char in dadMap.iterator()){
					char.onPause();
				}
				for (char in gfMap.iterator()){
					char.onPause();
				}
			}
		}
		#if (sys)
		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			callAllHScript('onTeleportToChart', []);
			if (Main.fpsVar.x != 10)
				Main.fpsVar.x = 10;
			openChartEditor();
		}
#end
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var hitSpeed = 0.50;

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, hitSpeed)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, hitSpeed)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		var iconOffset:Int = 26;
if (!disibleIconMoving){
if (iconMovingType == 'Left'){
			iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
}else{
	iconP1.x = healthBar.barCenter - (150 * iconP1.scale.x - 150) / 2 - iconOffset * 5;
	iconP2.x = healthBar.barCenter + (150 * iconP2.scale.x) / 2 - iconOffset * 4;

}
			/*iconP1.x = healthBar.x -(
		(healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) 
		+ (150 * iconP1.scale.x - 150) / 2 
		- iconOffset);

		iconP2.x = healthBar.x - (
		(healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) 
		- (150 * iconP2.scale.x) / 2 
		- iconOfset * 2);*/
		
}
		if (health < 0)
			health = 0;
		if (!genocideMode)
			{
			if (health > 2)
				health = 2;

			} else {
			var p2ToUse:Float = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			if (iconP2.x - iconP2.width / 2 < healthBar.x && iconP2.x > p2ToUse)
			{
				healthBar.offset.x = iconP2.x - p2ToUse;
			} else {
				
				healthBar.offset.x = 0;
			}
			iconP1.x = healthBar.x + 
			(healthBar.width * (FlxMath.remapToRange((health / 2 * 100), 0, 100, 100, 0) * 0.01)) 
			+ (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = p2ToUse;
			if (health > 3)
				health = 3;
			}

var iconP1s = iconP1;
var iconP2s = iconP2;
if (opponentPlayer){
	iconP1s = iconP2;
 iconP2s = iconP1;
}
			if (healthBar.percent < 20)
				{
					iconP1s.iconState = Dying;
					iconP2s.iconState = Winning;
				}
				else if ((!genocideMode && healthBar.percent > 80) || (genocideMode && (health / 2 * 100) > 100)) {
					iconP2s.iconState = Dying;
					iconP1s.iconState = Winning;
				}
				else {
					iconP2.iconState = Normal;
					iconP1.iconState = Normal;
				}
				#if (sys)
		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			if (Main.fpsVar.x != 10)
				Main.fpsVar.x = 10;
			
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
#end
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed' || ClientPrefs.timeBarType == 'Time Progress') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name' && ClientPrefs.timeBarType != 'Time Progress')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

					if(ClientPrefs.timeBarType == 'Time Progress'){
					    timeTxt.text = '${FlxStringUtil.formatTime(secondsTotal, false)} - ${FlxStringUtil.formatTime(Math.floor(songLength / 1000), false)}';
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();
		modManager.updateTimeline(curDecStep);
		modManager.update(elapsed);

		// TODO: re-do unspawnNotes to be per-column so you can have them spawn at different timings n all that shit w/ modifiers
		/*if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);
				callAllHScript('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote,dunceNote]);
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}*/
		for(column in notesToSpawn){
			if(column[0]!=null){
				var time:Float =spawnTime;
				if (modchartMode&&modManager.register != [])time =  (modManager.getValue("noteSpawnTime", 0) + modManager.getValue("noteSpawnTime", 1)) / 2;
				if (songSpeed < 1)
					time /= songSpeed;
				while (column.length > 0 && column[0].strumTime - Conductor.songPosition < time / ((column[0].multSpeed<1) ? column[0].multSpeed : 1))
				{
					var dunceNote:Note = column[0];
					notes.insert(0, dunceNote);
					dunceNote.spawned = true;
					for (char in boyfriendMap.iterator()){
						char.onNoteIncoming(dunceNote);
					}
					for (char in dadMap.iterator()){
						char.onNoteIncoming(dunceNote);
					}
					for (char in gfMap.iterator()){
						char.onNoteIncoming(dunceNote);
					}
					callOnLuas('onSpawnNote', [
						notes.members.indexOf(dunceNote),
						dunceNote.noteData,
						dunceNote.noteType,
						dunceNote.isSustainNote
					]);
					callAllHScript('onSpawnNote', [
						notes.members.indexOf(dunceNote),
						dunceNote.noteData,
						dunceNote.noteType,
						dunceNote.isSustainNote,
						dunceNote
					]);
					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
					column.splice(column.indexOf(dunceNote), 1);
				}
			}
		}
		if (modchartMode){
        for (curStrums in 0...currentStrums.length){
			var strumTADA = currentStrums[curStrums];
	switch (curStrums){
	case 0:
		strumTADA.forEachAlive(function(strum:StrumNote)
			{
				var pos = modManager.getPos(0, 0, 0, curDecBeat, strum.noteData, 0, strum, [], strum.vec3Cache);
				modManager.updateObject(curDecBeat, strum, pos, 0);
				strum.x = pos.x;
				strum.y = pos.y;
				strum.z = pos.z;
			});
			case 1:
		strumTADA.forEachAlive(function(strum:StrumNote)
			{
				var pos = modManager.getPos(0, 0, 0, curDecBeat, strum.noteData, 1, strum, [], strum.vec3Cache);
				modManager.updateObject(curDecBeat, strum, pos, 1);
				strum.x = pos.x;
				strum.y = pos.y;
				strum.z = pos.z;
			});
	    default:
			strumTADA.forEachAlive(function(strum:StrumNote)
			{
				var pos = modManager.getPos(0, 0, 0, curDecBeat, strum.noteData, strum.player, strum, [], strum.vec3Cache);
				modManager.updateObject(curDecBeat, strum, pos, 0);
				strum.x = pos.x;
				strum.y = pos.y;
				strum.z = pos.z;
			});

	}
	}
}


		if (SONG.notes[curSection] != null)
			{
		if (!stopAutoMoving &&!inCutscene && generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				movingCameraSection();
			}
		}
		if (generatedMusic)
		{
			if (!inCutscene) {
			//	var onActing = opponentPlayer ? dad : boyfriend;
				if(!botplay) {
					if (!opponentPlayer){
				keyShit(true);
					}
			else if (opponentPlayer)
			{
				keyShit(false);
			}
				}  
				if(botplay) {
					var chars = [boyfriend,dad,gf];
					for (char in chars){
				if(char!= null &&
					char.beingControlled &&char.holdTimer > Conductor.stepCrochet * 0.0011 * char.singDuration && char.animation.curAnim.name.startsWith('sing') && !char.animation.curAnim.name.endsWith('miss')) {
					char.dance();
					//Fixed dumbass controlled
					//boyfriend.animation.curAnim.finish();
				}
			}
			}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			if (!modchartMode){
				for (strum in strumLineNotes.members){
					if (strum.vec3Cache == null)
						strum.vec3Cache = new Vector3();
	
					var pos = strum.vec3Cache;
					pos.x = strum.x;
					pos.y = strum.y;
					pos.z = 0;
				}
				
			}
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = currentStrums[daNote.currentStrum];
				var breakGroup:FlxTypedGroup<FlxSprite> = opponentComboBreak;
				if (daNote.currentStrum == currentPlayerStrum)
						breakGroup = playerComboBreak;
				

				var strum:StrumNote = strumGroup.members[daNote.noteData];
				breakGroup.members[daNote.noteData].x = strumGroup.members[daNote.noteData].x;
                if (modchartMode){
				var pN:Int = daNote.currentStrum;
				var pos = modManager.getPos(daNote.strumTime, modManager.getVisPos(Conductor.songPosition, daNote.strumTime, songSpeed),
					daNote.strumTime - Conductor.songPosition, curDecBeat, daNote.noteData, pN, daNote, [], daNote.vec3Cache);
				modManager.updateObject(curDecBeat, daNote, pos, pN);
				pos.x += daNote.offsetX;
				pos.y += daNote.offsetY;
				daNote.x = pos.x;
				daNote.y = pos.y;
				daNote.z = pos.z;

				if (daNote.isSustainNote)
				{
					var futureSongPos = Conductor.songPosition + 75;
					var diff = daNote.strumTime - futureSongPos;
					var vDiff = modManager.getVisPos(futureSongPos, daNote.strumTime, songSpeed);

					var nextPos = modManager.getPos(daNote.strumTime, vDiff, diff, Conductor.getStep(futureSongPos) / 4, daNote.noteData, pN, daNote, [],
						daNote.vec3Cache);
					nextPos.x += daNote.offsetX;
					nextPos.y += daNote.offsetY;
					var diffX = (nextPos.x - pos.x);
					var diffY = (nextPos.y - pos.y);
					var rad = Math.atan2(diffY, diffX);
					var deg = rad * (180 / Math.PI);
					if (deg != 0)
						daNote.mAngle = (deg + 90);
					else
						daNote.mAngle = 0;
				}
			}else{
				daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate,SONG.bpm);

					if (daNote.vec3Cache == null)
						daNote.vec3Cache = new Vector3();
	
					var pos = daNote.vec3Cache;
					pos.x = daNote.x;
					pos.y = daNote.y;
					pos.z = 0;
				
			}
			
			if(daNote.copyAlpha)
				daNote.alpha = strum.alpha * daNote.multAlpha;//Alpha is working in modchart mode idk why auishsacni0osacnioascniocnsaionikvionsadvioniodvnisdoavmoip colorswap buggy 9iadshiojaiocjniocsajiaoscjioasicojioascnuiovsdnfwqertyuiopasdfghjklzxcvbnm123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ

				var coolMustPress = daNote.mustPress;
				//if (opponentPlayer)
				//	coolMustPress = !daNote.mustPress;
				var boyfriendOrOPP = true;
				if (opponentPlayer)
					boyfriendOrOPP = false;

				if (!coolMustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote && daNote.currentStrum == currentOpponentStrum)
				{
					opponentNoteHit(daNote,boyfriendOrOPP);
				}

				if(coolMustPress && botplay && daNote.currentStrum == currentPlayerStrum) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote,boyfriendOrOPP);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && coolMustPress)) {
						goodNoteHit(daNote,boyfriendOrOPP);
					}
				}
                var checkIsPlayerOrOpponentStrum = false;

				if (daNote.currentStrum == currentOpponentStrum)
					checkIsPlayerOrOpponentStrum = true;

				if (daNote.currentStrum == currentPlayerStrum)
					checkIsPlayerOrOpponentStrum = true;

				if (!checkIsPlayerOrOpponentStrum && daNote.wasGoodHit && !daNote.ignoreNote){
					defaultNoteHit(daNote,daNote.currentStrum);
					}
					if (!modchartMode)
				if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

			

				// Kill extremely late notes and cause misses
				if(daNote.garbage){
					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
					callAllHScript('onNoteDestroy', [daNote]);
				}else{
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (coolMustPress && !botplay &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote, !opponentPlayer);
					}

					daNote.active = false;
					daNote.visible = false;

					
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
					callAllHScript('onNoteDestroy', [daNote]);
				}
			}
			});
		}
		checkEventNote();

		if (chartingMode){
		if(!endingSong && !startingSong) {

			if (FlxG.keys.justPressed.PAGEUP)
				changeSection(10);
			if (FlxG.keys.justPressed.PAGEDOWN)
				changeSection(-10);
			if (FlxG.keys.justPressed.ONE) {
				if (Main.fpsVar.x != 10)
					Main.fpsVar.x = 10;
				KillNotes();
				FlxG.sound.music.onComplete();
			}

		}
	}

	
		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', botplay);
		callOnLuas('onUpdatePost', [elapsed]);
		setAllHaxeVar('cameraX', camFollowPos.x);
		setAllHaxeVar('cameraY', camFollowPos.y);
		setAllHaxeVar('botPlay', botplay);
		callAllHScript('onUpdatePost', [elapsed]);
		callAllHScript('updatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			sfx.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}



	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	public static var gameOverChar:String;
	public static var endHealth:Float = 0;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= endHealth) && !practiceMode && !isDead)
		{
			

			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			var ret2:Dynamic = callAllHScript('onGameOver', [],false);
			if(ret != FunkinLua.Function_Stop && ret2 != FunkinLua.Function_Stop) {
				for (char in boyfriendMap.iterator()){
					char.onGameOver();
				}
				for (char in dadMap.iterator()){
					char.onGameOver();
				}
				for (char in gfMap.iterator()){
					char.onGameOver();
				}

				if (opponentPlayer)
					dad.stunned = true;
				else
					boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				sfx.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				

				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				if (opponentPlayer)
					{
						if (Main.fpsVar.x != 10)
							Main.fpsVar.x = 10;
						gameOverChar = dad.curCharacter;
						openSubState(new GameOverSubstate(dad.getScreenPosition().x - dad.positionArray[0], dad.getScreenPosition().y - dad.positionArray[1], camFollowPos.x, camFollowPos.y,dad.isPlayer));
					}
					else{
						if (Main.fpsVar.x != 10)
							Main.fpsVar.x = 10;
						gameOverChar = boyfriend.curCharacter;
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y,boyfriend.isPlayer));
					}
				

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			var value3:String = '';
			if(eventNotes[0].value3 != null)
				value3 = eventNotes[0].value3;

			triggerEventNote(eventNotes[0].event, value1, value2, value3);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String, value3:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.likeGf) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if(boyfriend.likeGf) {
						boyfriend.playAnim('cheer', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1 && !boyfriend.likeGf) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];

				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms && !dieEventZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							if (phillyWindowEvent != null && curStage == 'philly')
								{
							phillyWindowEvent.visible = false;
								}

							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							if (phillyStreet != null)
							phillyStreet.color = FlxColor.WHITE;
							else
							glowbehind.color = FlxColor.WHITE;
						}


					case 1: //turn on
					curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms && !dieEventZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							if (phillyWindowEvent != null && curStage == 'philly')
								{
							phillyWindowEvent.visible = true;
								}
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							if (!disabledchangecolor)
							who.color = charColor;
							else
							who.color = FlxColor.BLACK;//?WHY NOT FUCKING FLXCOLOR.WHITE????
							                           //答:因为模板.
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						if (phillyWindowEvent != null && curStage == 'philly')
							{
						phillyWindowEvent.color = color;
							}
						color.brightness *= 0.5;

							if (phillyStreet != null)
							phillyStreet.color = color;
							else
							glowbehind.color = color;


					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}
			case 'FocusCamera':
				var ID = Std.parseInt(value1);
				if(Math.isNaN(ID)) ID = 0;
				switch(ID)
				{
					case 0:
						moveCamByHand("bf");
						case 1:
						moveCamByHand("dad");
						case 2:
						moveCamByHand("gf");
					}
					var X = Std.parseFloat(value2);
					if(Math.isNaN(X)) X = 0; 
					var Y = Std.parseFloat(value3);
					if(Math.isNaN(X)) Y = 0; 
					camFollow.x += X;
					camFollow.y += Y;
					trace('move move');
					if (cameraFocusList.length > 0)
					cameraFocusList.remove(cameraFocusList[0]);

			case 'Set Camera Zoom':
					var zooms:Float = Std.parseFloat(value1);
					var time:Float = Std.parseFloat(value2);
					if(Math.isNaN(zooms)) zooms = defaultCamZoom;
					if(Math.isNaN(time)) time = Conductor.stepCrochet * 4 / 1000;

FlxTween.tween(FlxG.camera, {zoom: zooms}, time, {onComplete:
						function (twn:FlxTween)
						{
			FlxG.camera.zoom = zooms;
			defaultCamZoom = zooms;
						}
					});

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2, value3];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD, camHUD2];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var oldChar:Character;
				var charType:Int = 0;
				var char:Character = null;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
						oldChar = gf;
					case 'dad' | 'opponent':
						charType = 1;
						oldChar = dad;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
						oldChar = boyfriend;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}
							var wasGf:Bool = boyfriend.likeGf;
							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							char = boyfriend;
							if(!boyfriend.likeGf) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}

							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
							setAllHaxeVar('boyfriend', boyfriend);
							if ((value3 == 'true' || value3 == '1') && oldChar != boyfriend)
								{
									if (boyfriendMap.exists(oldChar.curCharacter))
									{
										removeCharacterFromList(oldChar.curCharacter, charType);
									}
								}
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);
						setAllHaxeVar('boyfriendName', boyfriend.curCharacter);
					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.likeGf;
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.likeGf) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
							setAllHaxeVar('dad', dad);
							if ((value3 == 'true' || value3 == '1') && oldChar != dad)
								{
									if (dadMap.exists(oldChar.curCharacter))
									{
										removeCharacterFromList(oldChar.curCharacter, charType);
									}
								}
						}


						setOnLuas('dadName', dad.curCharacter);
						setAllHaxeVar('dadName', dad.curCharacter);
					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							char = gf;
							if ((value3 == 'true' || value3 == '1') && oldChar != gf)
								{
									if (gfMap.exists(oldChar.curCharacter))
									{
										removeCharacterFromList(oldChar.curCharacter, charType);
									}
								}
								setAllHaxeVar('gf', gf);
							setOnLuas('gfName', gf.curCharacter);
							setAllHaxeVar('gfName', gf.curCharacter);
						}
				}
				
				if (!ClientPrefs.classicStyle)
				reloadHealthBarColors();

				currentChars= [boyfriend,dad,gf];
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Setting Crossfades':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				var val3:String = value3;
				if(Math.isNaN(val1)) val1 = 0.75;
				if(Math.isNaN(val2)) val2 = 1.0;
				if(val3 == '') val3 = 'normal';

				cfDuration = val1;
				cfIntensity = val2;
				cfBlend = val3;

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
				case 'Camera Flash': //Camera Flashing value1: Flash Fade Time, value2: Forced
				var time:Float;
				if (value1 != '')
					time = Std.parseFloat(value1);
				else
					time = 1;
	
				var forced:Bool;
				if (value2 == "true" || value2 == "1")
					forced = true;
				else
					forced = false;
	
				var colorSelected:FlxColor;
				if (value3 == 'black')
					colorSelected = 0xFF000000;
				else if (value3 == 'red')
					colorSelected = 0xFFff0000;
				else if (value3 == 'green')
					colorSelected = 0xFF00ff00;
				else if (value3 == 'blue')
					colorSelected = 0xFF0000ff;
				else if (value3 == 'yellow')
					colorSelected = 0xFFffff00;
				else if (value3 == 'cyan')
					colorSelected = 0xFF00ffff;
				else if (value3 == 'magenta')
					colorSelected = 0xFFff00ff;
				else //white xd
					colorSelected = 0xFFffffff;
	
				FlxG.camera.flash(colorSelected, time, null, forced);
		}
		for (char in boyfriendMap.iterator()){
			char.onSongEvent([eventName, value1, value2, value3]);
		}
		for (char in dadMap.iterator()){
			char.onSongEvent([eventName, value1, value2, value3]);
		}
		for (char in gfMap.iterator()){
			char.onSongEvent([eventName, value1, value2, value3]);
		}
		callOnLuas('onEvent', [eventName, value1, value2, value3]);
		callAllHScript("onEvent", [eventName, value1, value2, value3]);
	}

	public function removeCharacterFromList(charName:String, charType:Int)
		{
			if (charType < 0)
				charType = 0;
	
			if (charType > 2)
				charType = 2;
	
			var chId:Character;
	
			switch (charType)
			{
				case 0:
					if(boyfriendMap.exists(charName)) {
						chId = boyfriendMap.get(charName);
						boyfriendMap.remove(charName);
						chId.destroy();
					}
				case 1:
					if(dadMap.exists(charName)) {
						chId = dadMap.get(charName);
						dadMap.remove(charName);
						chId.destroy();
					}
				case 2:
					if(gfMap.exists(charName)) {
						chId = gfMap.get(charName);
						gfMap.remove(charName);
						chId.destroy();
					}
			}
		}

		

		function movingCameraSection():Void {
			if(SONG.notes[curSection] == null) return;
			lastTarget =camTarget;
			if (gf != null && SONG.notes[curSection].gfSection)
			{
				camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
				camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
				camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
				tweenCamIn();
				callOnLuas('onMovingCamera', ['gf']);
				callAllHScript('onMovingCamera', ['gf']);
				camTarget = 'gf';
				var KYS = 'fuck';
				if (!SONG.disPlayAutoMovingCam){
				if (SONG.notes[curSection].mustHitSection)
					KYS = 'true';

				if (!SONG.notes[curSection].mustHitSection)
					KYS = 'false';
			}
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,KYS,'']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,KYS,'']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,KYS,'']);
				}
				return;
			}
	
			if (!SONG.notes[curSection].mustHitSection)
			{
				moveCamera(true);
				callOnLuas('onMovingCamera', ['dad']);
				callAllHScript('onMovingCamera', ['dad']);
				camTarget = 'dad';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,'false','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,'false','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,'false','']);
				}
			}
			else
			{
				moveCamera(false);
				callOnLuas('onMovingCamera', ['boyfriend']);
				callAllHScript('onMovingCamera', ['boyfriend']);
				camTarget = 'bf';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,'true','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,'true','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMovingCamera',camTarget,'true','']);
				}
			}
		}
		function moveCamByHand(char:String ='bf'):Void {
			lastTarget =camTarget;
			switch (char){
				case 'gf':
			if (gf != null)
			{
				camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
				camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
				camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
				tweenCamIn();
				callOnLuas('onMovingCamera', ['gf']);
				callAllHScript('onMovingCamera', ['gf']);
				camTarget = 'gf';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'fuck','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'fuck','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'fuck','']);
				}
			}
			case 'dad':
	
				moveCamera(true);
				callOnLuas('onMovingCamera', ['dad']);
				callAllHScript('onMovingCamera', ['dad']);
				camTarget = 'dad';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'false','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'false','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'false','']);
				}
			case 'bf':
				moveCamera(false);
				callOnLuas('onMovingCamera', ['boyfriend']);
				callAllHScript('onMovingCamera', ['boyfriend']);
				camTarget = 'bf';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'true','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'true','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'true','']);
				}
			}
		}
		var camTarget:String = 'none';
		var lastTarget:String = 'none';
		function moveCameraSection():Void {
			if(SONG.notes[curSection] == null) return;
			lastTarget =camTarget;
			if (gf != null && SONG.notes[curSection].gfSection)
			{
				callOnLuas('onMoveCamera', ['gf']);
				callAllHScript('onMoveCamera', ['gf']);
				camTarget = 'gf';
				var nuhuhMustHitmoment = 'fuck';
				if (!SONG.disPlayAutoMovingCam){
				if (SONG.notes[curSection].mustHitSection)
					nuhuhMustHitmoment = 'true';

				if (!SONG.notes[curSection].mustHitSection)
					nuhuhMustHitmoment = 'false';
			}
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,nuhuhMustHitmoment,'']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,nuhuhMustHitmoment,'']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,nuhuhMustHitmoment,'']);
				}
				return;
			}
	
			if (!SONG.notes[curSection].mustHitSection)
			{
				callOnLuas('onMoveCamera', ['dad']);
				callAllHScript('onMoveCamera', ['dad']);
				callAllHScript("opponentTurn", []);
				callAllHScript("playerTwoTurn", []);
				camTarget = 'dad';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'false','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'false','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'false','']);
				}
			}
			else
			{
				callOnLuas('onMoveCamera', ['boyfriend']);
				callAllHScript('onMoveCamera', ['boyfriend']);
				callAllHScript("playerTurn", []);
				callAllHScript("playerOneTurn", []);
				camTarget = 'bf';
				for (char in boyfriendMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'true','']);
				}
				for (char in dadMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'true','']);
				}
				for (char in gfMap.iterator()){
					char.onSongEvent(['onMoveCamera',camTarget,'true','']);
				}
			}
		}
	

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
			callAllHScript("opponentTurnMoving", []);
			callAllHScript("playerTwoTurnMoving", []);
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
			callAllHScript("playerTurnMoving", []);
			callAllHScript("playerOneTurnMoving", []);
		}
	}
	function comboBreak(dir:Int, curStrum:Int = 0, rating:String = 'shit') {
	
		if (!ClientPrefs.showComboBreaks)
			return;
		var coolor = switch (rating) {
			case 'miss':
				0xFFDD0A93;
			//case 'wayoff':
			//	wayoffBreakColor;
			case 'shit':
				0xFF175DB3;
			default:
				// just return, as we shouldn't even be here
				return;
		}
		dir = dir % 4;
		var strum = currentStrums[curStrum].members[dir];
		var thingToDisplay = new FlxSprite(strum.x, 0).makeGraphic(Std.int(strum.width), FlxG.height, FlxColor.WHITE);
		if (curStrum == currentPlayerStrum) {
		playerComboBreak.add(thingToDisplay);
		} else if (curStrum == currentOpponentStrum){
		opponentComboBreak.add(thingToDisplay);
		}
		totalComboBreak.add(thingToDisplay);

		thingToDisplay.color = coolor;
		thingToDisplay.alpha = 1;
		thingToDisplay.visible = true;
		FlxTween.tween(thingToDisplay, {alpha: 0}, 1, {onComplete: function(_) {remove(thingToDisplay);}});
	}
	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		sfx.volume = 0;
		sfx.pause();
		isCorruptUI = false;
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	function changeSection(sec:Int):Void
		{
			setSongTime(Conductor.songPosition + sec * 1000);
			clearNotesBefore(Conductor.songPosition);
		}

	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -=  1 * 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 1 * 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		#if mobile 
			androidc.visible = false;
		#end
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;
		deathCounter = 0;
		seenCutscene = false;
		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end
	
		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		var ret2:Dynamic = callAllHScript('onEndSong', [SONG.song],false);
		for (char in boyfriendMap.iterator()){
			char.onSongEnd();
		}
		for (char in dadMap.iterator()){
			char.onSongEnd();
		}
		for (char in gfMap.iterator()){
			char.onSongEnd();
		}
		if((ret != FunkinLua.Function_Stop && ret2 != FunkinLua.Function_Stop) && !transitioning) {
			if (SONG.validScore && !botplay)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{

				openChartEditor();
				
				options.OptionsState.isFromPlayState = false;
				return;

			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				callAllHScript('storylistStuff', [SONG.song]);
				storyPlaylist.remove(storyPlaylist[0]);
				
				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music(ClientPrefs.menuMusic));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					if (Main.fpsVar.x != 10)
						Main.fpsVar.x = 10;
					options.OptionsState.isFromPlayState = false;
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
		
					
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;
					PlayState.SONG = Song.loadFromNewJson(PlayState.storyPlaylist[0], PlayState.storyPlaylist[0],difficulty.substr(1, difficulty.length));
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				if (Main.fpsVar.x != 10)
					Main.fpsVar.x = 10;
				options.OptionsState.isFromPlayState = false;
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music(ClientPrefs.menuMusic));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camHUD2);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
			callAllHScript('onNoteDestroy', [daNote]);
		}
		unspawnNotes = [];
		eventNotes = [];
	}


	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	var timeShown:Int = 0;
	public var showCombo:Bool = ClientPrefs.showCombos;
	public var showComboNum:Bool = ClientPrefs.showCombosNum;
	public var showRating:Bool = ClientPrefs.showCombosRatings;
	public var showMs:Bool = !ClientPrefs.hideMs;
	public var backShitPart1:String = "";
	public var backShitIntro:String = "";
	public var backShitPart2:String = '';
	private function popUpScore(note:Note = null, playerOne:Bool):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));
		var noteDiffSigned:Float = note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset;
		// boyfriend.playAnim('hey');
		if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
			if (!opponentPlayer)vocals.playerVolume = 1;
			else{
				vocals.opponentVolume = 1;
			}
		}
			else
				vocals.volume = 1;
		
		

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
if (!ClientPrefs.classicStyle)
		coolText.x = FlxG.width * 0.35;	
else 
coolText.x = FlxG.width * 0.55;	
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff);
		var ratingNum:Int = 0;

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}
		var healthBonus = 0.0;
		if(!practiceMode) {
			songScore += daRating.score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}

		}

		comboBreak(note.noteData, note.currentStrum, note.rating);

		if (PlayState.isPixelStage && !PlayState.isCorruptUI)
		{
			backShitPart1 = 'pixelUI/';
			backShitPart2 = '-pixel';
		}

		rating.loadGraphic(
			FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/custom_ui/' + uiSmelly.uses + '/' + daRating.image + backShitPart2 + '.png') ? 
							FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/shared/images/custom_ui/' + uiSmelly.uses + '/' + daRating.image + backShitPart2 + '.png') :
							FNFAssets.getBitmapData(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/' + daRating.image + backShitPart2 + '.png')));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(
			FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/custom_ui/' + uiSmelly.uses + '/' + 'combo' + backShitPart2 + '.png') ? 
			FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/shared/images/custom_ui/' + uiSmelly.uses + '/' +'combo' + backShitPart2 + '.png') :
			FNFAssets.getBitmapData(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/' + 'combo' + backShitPart2 + '.png')));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300);
		comboSpr.velocity.y -= FlxG.random.int(140, 160);
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[4];
		comboSpr.y -= ClientPrefs.comboOffset[5];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if(showRating){
			if (!ClientPrefs.classicStyle)
				insert(members.indexOf(strumLineNotes), rating);
				else
				add(rating);
		grpRatings.get('rating').push(rating);
		}
		
		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var msTiming = HelperFunctions.truncateFloat(noteDiffSigned, 3);
		if (botplay)
			msTiming = 0;
		timeShown = 0;
		if (currentTimingShown != null)
			remove(currentTimingShown);

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
		switch (note.rating)
		{
			case 'shit':
				currentTimingShown.color = FlxColor.MAGENTA;
			case 'bad':
				currentTimingShown.color = FlxColor.RED;
			case 'good':
				currentTimingShown.color = FlxColor.GREEN;
			case 'sick':
				currentTimingShown.color = FlxColor.CYAN;
		}
		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 1;
		currentTimingShown.borderColor = FlxColor.BLACK;
		currentTimingShown.text = msTiming + "ms";
		currentTimingShown.size = 20;
		currentTimingShown.visible = !ClientPrefs.hideMs;


		if (currentTimingShown.alpha != 1)
			currentTimingShown.alpha = 1;

		if (!botplay)
			add(currentTimingShown);



		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		
		currentTimingShown.screenCenter();
		currentTimingShown.x = FlxG.width * 0.35 + 100;
		currentTimingShown.y = 40;
		currentTimingShown.acceleration.y = 600;
		currentTimingShown.velocity.y -= 150;

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			if (!ClientPrefs.classicStyle)
				insert(members.indexOf(strumLineNotes), comboSpr);
				else
				add(comboSpr);
			grpRatings.get('combos').push(comboSpr);
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(
				FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/custom_ui/' + uiSmelly.uses + '/' + 'num' + Std.int(i) + backShitPart2 + '.png') ? 
				FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/shared/images/custom_ui/' + uiSmelly.uses + '/' +'num' + Std.int(i) + backShitPart2 + '.png') :
				FNFAssets.getBitmapData(Paths.modFolders('images/custom_ui/' + uiSmelly.uses + '/' + 'num' + Std.int(i) + backShitPart2 + '.png')));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum){
				if (!ClientPrefs.classicStyle)
				insert(members.indexOf(strumLineNotes), numScore);
				else
				add(numScore);
				grpRatings.get('nums').push(numScore);
			}
			if (!ClientPrefs.classicStyle){
			for (ratingStuff in grpRatings.iterator()){
       
       
				for (rating in ratingStuff){
					rating.cameras = [camHUD];
				}
			}
		}
			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					if(showComboNum)
					grpRatings.get('nums').remove(numScore);
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */
currentTimingShown.cameras = [camHUD];
		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween)
			{
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			},
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
			
				coolText.destroy();
				if(showRating)
				grpRatings.get('combos').remove(comboSpr);
				comboSpr.destroy();
				if(showRating)
				grpRatings.get('rating').remove(rating);
				rating.destroy();
				if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
			},
			startDelay: Conductor.crochet * 0.002
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var actingOn:Character = opponentPlayer ? dad : boyfriend;
		//var strums = opponentPlayer ? opponentStrums : playerStrums;
		var strums = currentStrums[currentPlayerStrum];
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!botplay && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!actingOn.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					var coolMustPress = daNote.mustPress;
					if (daNote.canBeHit && coolMustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote, !opponentPlayer);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					callAllHScript('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key,!opponentPlayer);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = strums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callAllHScript('onKeyPress', [key]);
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var strums = currentStrums[currentPlayerStrum];
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!botplay && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = strums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
			callAllHScript('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit(?playerOne:Bool=true):Void
	{
		// HOLDING
		var coolControls = controls;
		var up = coolControls.NOTE_UP;
		var right = coolControls.NOTE_RIGHT;
		var down = coolControls.NOTE_DOWN;
		var left = coolControls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [coolControls.NOTE_LEFT_P, coolControls.NOTE_DOWN_P, coolControls.NOTE_UP_P, coolControls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}
		var actingOn:Character = playerOne ? boyfriend : dad;
		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !actingOn.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				//var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				//If i kill coolShouldPress will case many of script errors damn
				//but you know what idc lol
				var coolShouldPress =  daNote.mustPress;
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit
				&& coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote,playerOne);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (actingOn.holdTimer > Conductor.stepCrochet * 0.001 * actingOn.singDuration && actingOn.animation.curAnim.name.startsWith('sing') && !actingOn.animation.curAnim.name.endsWith('miss'))
			{
				actingOn.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [coolControls.NOTE_LEFT_R, coolControls.NOTE_DOWN_R, coolControls.NOTE_UP_R, coolControls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note,playerOne:Bool):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove

		var actingOn =  boyfriend;
			var onActing =  dad;
			switch (daNote.whoShouldSing){
				case 'boyfriend' | 'bf':
					actingOn = boyfriend;
					case 'girlfriend' | 'gf':
						if (gf!=null)
						actingOn = gf;
						case 'dad'|'dearest':
								actingOn = dad;
				default:
					actingOn = boyfriend;
			}
			switch (daNote.whoIsOpponent){
				case 'boyfriend' | 'bf':
					onActing = boyfriend;
					case 'girlfriend' | 'gf':
						if (gf!=null)
							onActing = gf;
						case 'dad'|'dearest':
							onActing = dad;
				default:
					onActing = dad;
			}
		//var coolMustPress = playerOne ? daNote.mustPress : !daNote.mustPress;
		var coolMustPress = daNote.mustPress;
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && coolMustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		
			health -= daNote.missHealth * healthLoss;


		if(instakillOnMiss)
		{
			if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
				if (!opponentPlayer)vocals.playerVolume = 0;
				else{
					vocals.opponentVolume = 0;
				}
			}
				else
					vocals.volume = 0;
			
			doDeathCheck(true);
		}

		switch (daNote.noteType)
		{
			case "Static Note":

			
				if(actingOn.animation.getByName('hurt') != null) {
					actingOn.playAnim('hurt', true);
					actingOn.specialAnim = true;
				}
				staticHitMiss();

            case "Warning Note" :
			if(actingOn.animation.getByName('hurt') != null) {
				actingOn.playAnim('hurt', true);
				actingOn.specialAnim = true;
			}
			if(onActing.animOffsets.exists('shoot')) {
				onActing.playAnim('shoot', true);
				onActing.specialAnim = true;
			}
			FlxG.sound.play(Paths.sound("shoot"));
		}
		
		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
			if (!opponentPlayer)vocals.playerVolume = 0;
			else{
				vocals.opponentVolume = 0;
			}
		}
			else
				vocals.volume = 0;
		
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = actingOn;
		if(daNote.gfNote) {
			char = gf;
		}
		comboBreak(daNote.noteData,daNote.currentStrum,'miss');
		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
		for (char in boyfriendMap.iterator()){
			char.onNoteMiss(daNote);
		}
		for (char in dadMap.iterator()){
			char.onNoteMiss(daNote);
		}
		for (char in gfMap.iterator()){
			char.onNoteMiss(daNote);
		}
		callAllHScript('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote, daNote]);
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if (playerOne) {
			callAllHScript("playerOneMiss", []);
		} else {
			callAllHScript("playerTwoMiss", []);
		}
	}

	function noteMissPress(direction:Int = 1,playerOne:Bool):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it
		var actingOn = playerOne ? boyfriend : dad;
		if (!actingOn.stunned)
		{

			
				health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
					if (!opponentPlayer)vocals.playerVolume = 0;
					else{
						vocals.opponentVolume = 0;
					}
				}
					else
						vocals.volume = 0;
				
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(actingOn.hasMissAnimations) {
				actingOn.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
				if (!opponentPlayer)vocals.playerVolume = 0;
				else{
					vocals.opponentVolume = 0;
				}
			}
				else
					vocals.volume = 0;
			
		}
		for (char in boyfriendMap.iterator()){
			char.onNoteGhostMiss(direction);
		}
		for (char in dadMap.iterator()){
			char.onNoteGhostMiss(direction);
		}
		for (char in gfMap.iterator()){
			char.onNoteGhostMiss(direction);
		}
		callAllHScript('noteMissPress', [direction]);
		callOnLuas('noteMissPress', [direction]);
		if (playerOne) {
			callAllHScript("playerOneMiss", []);
		} else {
			callAllHScript("playerTwoMiss", []);
		}
	}

	var altNum:Int = 0;
	function opponentNoteHit(note:Note,playerTwo:Bool):Void
	{
		var actingOn =  dad;
		var onActing =  boyfriend;
			switch (note.whoShouldSing){
				case 'boyfriend' | 'bf':
					actingOn = boyfriend;
					case 'girlfriend' | 'gf':
						if (gf!=null)
						actingOn = gf;
						case 'dad'|'dearest':
								actingOn = dad;
				default:
					actingOn = dad;
			}
			switch (note.whoIsOpponent){
				case 'boyfriend' | 'bf':
					onActing = boyfriend;
					case 'girlfriend' | 'gf':
						if (gf!=null)
							onActing = gf;
						case 'dad'|'dearest':
							onActing = dad;
				default:
					onActing = boyfriend;
			}
		
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && actingOn.animOffsets.exists('hey')) {
			if (actingOn.canSing){
			actingOn.playAnim('hey', true);
			actingOn.specialAnim = true;
			actingOn.heyTimer = 0.6;
			}
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;
			altNum = note.altNum;
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altNum = 1;
				}
			}

			if (altNum == 1) {
				altAnim = '-alt';
			} else if (altNum > 1) {
				altAnim = '-' + altNum + 'alt';
			}
			var char:Character = actingOn;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				if(note.bothNote) {
				if (gf != null){
					if (char.canSing){
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
					}
				if (gf.canSing){
				gf.playAnim(animToPlay, true);
				gf.holdTimer = 0;
				}
				}
				}
				else 
						{
							if (char.canSing){
							char.playAnim(animToPlay, true);
							char.holdTimer = 0;
							}
						}
				if(note.noteType == 'Warning Note') {
					if (!playerTwo)
					{
						if (actingOn.canSing){
						if(actingOn.animOffsets.exists('dodge') && !actingOn.likeGf) {
							actingOn.playAnim('dodge', true);
							actingOn.specialAnim = true;
						}
					}
					if (gf.canSing){
						if(gf.animOffsets.exists('dodge') && actingOn.likeGf) {
							gf.playAnim('dodge', true);
							gf.specialAnim = true;
						}
					}
						if (onActing.canSing){
						if(onActing.animOffsets.exists('shoot')) {
							onActing.playAnim('shoot', true);
							onActing.specialAnim = true;
						}
					}
					}
					FlxG.sound.play(Paths.sound("shoot"));
				}
			}


		}

		if (SONG.needsVoices)
			{	if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
				if (opponentPlayer)vocals.playerVolume = 1;
				else{
					vocals.opponentVolume = 1;
				}
			}
				else
					vocals.volume = 1;
			}

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}

		if (!ClientPrefs.classicStyle)
		StrumPlayAnim(true, (Std.int(Math.abs(note.noteData)) % 4), time,note.currentStrum);

		note.hitByOpponent = true;

		if (note.drainNote && health >= 0.05)
			{
            health -=  1 *0.05;
			}

			for (char in boyfriendMap.iterator()){
				char.onNoteHit(note);
			}
			for (char in dadMap.iterator()){
				char.onNoteHit(note);
			}
			for (char in gfMap.iterator()){
				char.onNoteHit(note);
			}
		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		callAllHScript('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note]);
		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}
public var curNoteHitHealth:Float = 0;
function defaultNoteHit(note:Note, strum:Int = 2):Void
	{
		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
	
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;
		var daStrum = note.currentStrum;
		//callOnLuas('defaultNoteHit', [notes.members.indexOf(note), leData, leType, isSus,note]);
		callAllHScript('defaultNoteHit', [notes.members.indexOf(note), leData, leType, isSus, note,daStrum]);
		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
			
		}
		
	}
	function goodNoteHit(note:Note, playerOne:Bool):Void
		{
			var actingOn =  boyfriend;
			var onActing =  dad;
			switch (note.whoShouldSing){
				case 'boyfriend' | 'bf':
					actingOn = boyfriend;
					case 'girlfriend' | 'gf':
						if (gf!=null)
						actingOn = gf;
						case 'dad'|'dearest':
								actingOn = dad;
				default:
					actingOn = boyfriend;
			}
			switch (note.whoIsOpponent){
				case 'boyfriend' | 'bf':
					onActing = boyfriend;
					case 'girlfriend' | 'gf':
						if (gf!=null)
							onActing = gf;
						case 'dad'|'dearest':
							onActing = dad;
				default:
					onActing = dad;
			}

			var altAnim:String = note.animSuffix;
			altNum = note.altNum;
			if (altNum == 1) {
				altAnim = '-alt';
			} else if (altNum > 1) {
				altAnim = '-' + altNum + 'alt';
			}
			if (!note.wasGoodHit)
			{
				if(botplay && (note.ignoreNote || note.hitCausesMiss)) return;
	
				if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
				{
					FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
				}
	
				if(note.hitCausesMiss) {
					noteMiss(note,playerOne);
					if(!note.noteSplashDisabled && !note.isSustainNote) {
						spawnNoteSplashOnNote(note);
					}
	
					if(!note.noMissAnimation)
					{
						switch(note.noteType) {
							case 'Hurt Note': //Hurt note
								if(actingOn.animation.getByName('hurt') != null) {
									actingOn.playAnim('hurt', true);
									actingOn.specialAnim = true;
								}
								/*if(dad.animation.getByName('shoot') != null) {
									dad.playAnim('shoot', true);
									dad.specialAnim = true;
								}*/
						}
					}
	
					note.wasGoodHit = true;
					if (!note.isSustainNote)
					{
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
					return;
				}
	
				if (!note.isSustainNote)
				{
					combo += 1;
					if(combo > 9999) combo = 9999;
					popUpScore(note, playerOne);
				}
				
				switch (note.rating)
				{
					case 'shit':
					
						note.ratingHealAmount = 0.1;
					case 'bad':
		
						note.ratingHealAmount = 0.4;
					case 'good':
						
						note.ratingHealAmount = 0.6;
					case 'sick':
						note.ratingHealAmount = 1;
				}
				curNoteHitHealth = 1 * note.hitHealth * (!note.isSustainNote ? note.ratingHealAmount * healthGain :  healthGain);
				health += curNoteHitHealth;
				
				if(!note.noAnimation) {
					var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
	
					if(note.gfNote)
					{
						if (gf.canSing){
						if(gf != null)
						{
							gf.playAnim(animToPlay, true);
							gf.holdTimer = 0;
						}
					}
					}
					else if (note.bothNote)
					{
	                  if (actingOn.canSing){
						actingOn.playAnim(animToPlay, true);
						actingOn.holdTimer = 0;
					  }
					  if (gf.canSing){
									gf.playAnim(animToPlay, true);
									gf.holdTimer = 0;
					  }
						}
					else {
						if (actingOn.canSing){
								actingOn.playAnim(animToPlay, true);
								actingOn.holdTimer = 0;
						}
							}
	
	
					if(note.noteType == 'Hey!') {
						if (actingOn.canSing){
						if(actingOn.animOffsets.exists('hey') && !actingOn.likeGf) {
							actingOn.playAnim('hey', true);
							actingOn.specialAnim = true;
							actingOn.heyTimer = 0.6;
						}
					}
	
						if(gf != null && gf.animOffsets.exists('cheer') ||actingOn.likeGf && gf.animOffsets.exists('cheer')) {
							if (gf.canSing){
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = 0.6;
							}
						}
					}
	
					if(note.noteType == 'Warning Note') {
						if (playerOne){
							if (actingOn.canSing){
						if(actingOn.animOffsets.exists('dodge') && !actingOn.likeGf) {
							actingOn.playAnim('dodge', true);
							actingOn.specialAnim = true;
						}
					}
					if (gf.canSing){
						if(gf.animOffsets.exists('dodge') && actingOn.likeGf) {
							gf.playAnim('dodge', true);
							gf.specialAnim = true;
						}
					}
						if (onActing.canSing){
						if(onActing.animOffsets.exists('shoot')) {
							onActing.playAnim('shoot', true);
							onActing.specialAnim = true;
						}
					}
					}
					else
						{
							if (onActing.canSing){
							if(onActing.animOffsets.exists('dodge') && !onActing.likeGf) {
								onActing.playAnim('dodge', true);
								onActing.specialAnim = true;
							}
						}
						if (gf.canSing){
							if(gf.animOffsets.exists('dodge') && onActing.likeGf) {
								gf.playAnim('dodge', true);
								gf.specialAnim = true;
							}
						}
						if (actingOn.canSing){
							if(actingOn.animOffsets.exists('shoot')) {
								actingOn.playAnim('shoot', true);
								actingOn.specialAnim = true;
							}
						}
					}
						FlxG.sound.play(Paths.sound("shoot"));
					}
				}
				var strums = currentStrums[note.currentStrum];
				if(botplay) {
					var time:Float = 0.05;
					if (note.tail.length > 0)
						time = 0.15;
					if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
						time += 0.1;
					}
					StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time,note.currentStrum);
				} else {
					strums.forEach(function(spr:StrumNote)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.playAnim('confirm', true);
						}
					});
				}

				note.wasGoodHit = true;
				if (vocals.playerVoices.members.length>0 && vocals.opponentVoices.members.length>0){
					if (opponentPlayer)vocals.playerVolume = 1;
					else{
						vocals.opponentVolume = 1;
					}
				}
					else
						vocals.volume = 1;
				
	
				var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
				//OMG SAYORI
				var leData:Int = Math.round(Math.abs(note.noteData));
				var leType:String = note.noteType;
				for (char in boyfriendMap.iterator()){
					char.onNoteHit(note);
				}
				for (char in dadMap.iterator()){
					char.onNoteHit(note);
				}
				for (char in gfMap.iterator()){
					char.onNoteHit(note);
				}
				callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
				callAllHScript('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus, note]);
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				if (playerOne)
					callAllHScript("playerOneSing", []);
				else
					callAllHScript("playerTwoSing", []);
			}
		}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			
			var strums = currentStrums[note.currentStrum];
			var strum:StrumNote = strums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null && gf.animOffsets.exists('hairBlow'))
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null && gf.animOffsets.exists('hairFall'))
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		

		
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		for (char in boyfriendMap.iterator()){
			char.onStepHit(curStep);
		}
		for (char in dadMap.iterator()){
			char.onStepHit(curStep);
		}
		for (char in gfMap.iterator()){
			char.onStepHit(curStep);
		}
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

		setAllHaxeVar("curStep", curStep);
		callAllHScript("stepHit", [curStep]);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
    var showComboCounter:Bool = ClientPrefs.showComboCounter;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (curBeat % 8 == 7
			
			&& combo > 5
			&& ((SONG.notes[curSection] != null && SONG.notes[curSection].mustHitSection && SONG.notes[curSection+1] != null &&!SONG.notes[curSection+1].mustHitSection)||(cameraFocusList.length > 1 && cameraFocusList[1] != 'bf' && cameraFocusList[0] == 'bf'))&& showComboCounter)
		{
			var animShit:ComboCounter = new ComboCounter(100, 200, combo);
			animShit.scrollFactor.set(0.6, 0.6);
			animShit.zIndex = 1100;
			animShit.cameras = [camHUD];
			add(animShit);

			var frameShit:Float = (1 / 24) * 2; // equals 2 frames in the animation

			new FlxTimer().start(((Conductor.crochet / 1000) * 1.25) - frameShit, function(tmr)
			{
				animShit.forceFinish();
			});
		}
	
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}


		if (ClientPrefs.classicStyle){
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		}
		else
		{
		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		}
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed) == 0 && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}
		if (!boyfriend.animation.curAnim.name.startsWith('sing'))
		{
			boyfriend.dance();
		}
		if (!dad.animation.curAnim.name.startsWith('sing'))
		{
			dad.dance();
		}
		for (key in otherCharactersMap.iterator()) {
			if (key != null){

				for (character in key.iterator()) {
					if (character != null 
						&& curBeat % character.danceEveryNumBeats == 0 
						&& character.animation.curAnim != null 
						&& !character.animation.curAnim.name.startsWith('sing') 
						&& !character.stunned){
						character.dance();
					}
				}
			}
		}
		if (curBeat % 4 == 0)
			{
		curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
			}
		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
					{
						
						phillyWindow.color = phillyLightsColors[curLight];
						phillyWindow.alpha = 1;
					}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;
		for (char in boyfriendMap.iterator()){
			char.onBeatHit(curBeat);
		}
		for (char in dadMap.iterator()){
			char.onBeatHit(curBeat);
		}
		for (char in gfMap.iterator()){
			char.onBeatHit(curBeat);
		}
		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);

		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}
    function changeBpm(curBpm:Float){
		Conductor.changeBPM(curBpm);
		setOnLuas('curBpm', Conductor.bpm);
		setOnLuas('crochet', Conductor.crochet);
		setOnLuas('stepCrochet', Conductor.stepCrochet);
		setAllHaxeVar('curBpm', Conductor.bpm);
		setAllHaxeVar('crochet', Conductor.crochet);
		setAllHaxeVar('stepCrochet', Conductor.stepCrochet);
	}
	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{

			if (!stopAutoMoving && generatedMusic && !endingSong && !isCameraOnForcedPos)
				{
					moveCameraSection();
				}
			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				changeBpm(SONG.notes[curSection].bpm);
			
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
			setAllHaxeVar('mustHitSection', SONG.notes[curSection].mustHitSection);
			setAllHaxeVar('altAnim', SONG.notes[curSection].altAnim);
			setAllHaxeVar('gfSection', SONG.notes[curSection].gfSection);
		}
		for (char in boyfriendMap.iterator()){
			char.onSectionHit(curSection);
		}
		for (char in dadMap.iterator()){
			char.onSectionHit(curSection);
		}
		for (char in gfMap.iterator()){
			char.onSectionHit(curSection);
		}
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
		setAllHaxeVar('curSection', curSection);
		callAllHScript('sectionHit', [curSection]);

	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(ret != FunkinLua.Function_Continue)
				returnVal = ret;
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}


	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}
	function StrumPlayAnim(isOpp:Bool, id:Int, time:Float,daStrum:Int) {
		var spr:StrumNote = null;
		var strums = currentStrums[daStrum % currentStrums.length];
	
			spr = strums.members[id];

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var accuracy:Float = 0.0;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {

		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);
		
		setAllHaxeVar('score', songScore);
		setAllHaxeVar('misses', songMisses);
		setAllHaxeVar('hits', songHits);
		if (badHit)
			updateScore(true); // miss notes shouldn't make the scoretxt bounce -Ghost
		else
			updateScore(false);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		var ret2:Dynamic = callAllHScript('onRecalculateRating', [],false);
		if(ret != FunkinLua.Function_Stop && ret2 != FunkinLua.Function_Stop)
		{
			var rat:Int = 0;
			#if HAD_DIFFERNET_LANGS
			if(ClientPrefs.langType == 'English')
				rat = 0;
		   else if(ClientPrefs.langType == 'Chinese')
		   rat = 2;
		   #end
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][rat]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][rat];
							break;
						}
					}
				}
				accuracy = Highscore.floorDecimal(ratingPercent * 100, 2);
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "MFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}
	public function accuracyShits(accuracy:Float){
		
		var accuracyTxt:String = " N/A";
		var accuracyConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...accuracyConditions.length)
		{
			var b = accuracyConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						accuracyTxt = " AAAAA";
					case 1:
						accuracyTxt = " AAAA:";
					case 2:
						accuracyTxt = " AAAA.";
					case 3:
						accuracyTxt = " AAAA";
					case 4:
						accuracyTxt = " AAA:";
					case 5:
						accuracyTxt = " AAA.";
					case 6:
						accuracyTxt = " AAA";
					case 7:
						accuracyTxt = " AA:";
					case 8:
						accuracyTxt = " AA.";
					case 9:
						accuracyTxt = " AA";
					case 10:
						accuracyTxt = " A:";
					case 11:
						accuracyTxt = " A.";
					case 12:
						accuracyTxt = " A";
					case 13:
						accuracyTxt = " B";
					case 14:
						accuracyTxt = " C";
					case 15:
						accuracyTxt = " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			accuracyTxt = " N/A";
		return accuracyTxt;

	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !botplay) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	override function switchTo(state:FlxState){

		if(isFixedAspectRatio){
			Lib.application.window.resizable = true;
			FlxG.scaleMode = new RatioScaleMode(false);
			FlxG.resizeGame(1280, 720);
			FlxG.resizeWindow(1280, 720);
		}

		return super.switchTo(state);
	}
	public function animationCopyFrom(sprite:Dynamic,copyfrom:Dynamic){
		try{
		sprite.animation.copyFrom(copyfrom.animation);
		}
	}
	public function makeCrossfades(
		toPlayer:Bool,
		char:Character,
		group:FlxTypedGroup<FlxSprite> = null,
		col:FlxColor = null):Void
		{
			if (group == null)
				group = grpCrossfades;
			var cFd:FlxSprite = new FlxSprite();
			var charID:Character;

				charID = char;

	
			cFd.frames = charID.frames;
			cFd.flipX = charID.flipX;
			cFd.animation.copyFrom(charID.animation);
			var animName:String;
			animName = charID.animation.curAnim.name;
	
			cFd.animation.play(animName, false);
	
			cFd.updateHitbox();
	
			if (toPlayer) {
				cFd.setPosition(charID.x - 40, charID.y);
				cFd.velocity.x = 200*FlxG.random.float(1, 1.2);
			} else {
				cFd.setPosition(charID.x + 40, charID.y);
				cFd.velocity.x = -200*FlxG.random.float(0.8, 1.2);
			}
	
			cFd.offset.set(charID.offset.x, charID.offset.y);
	
			cFd.antialiasing = true;
			if (col == null){
			cFd.color = FlxColor.fromRGB(charID.healthColorArray[0], charID.healthColorArray[1], charID.healthColorArray[2]);
			}else{
			cFd.color = col;
			}
			cFd.alpha = cfIntensity;
			cFd.blend = blendModeFromString(cfBlend);
	
			group.add(cFd);
	
			FlxTween.tween(cFd, {alpha: 0}, cfDuration, {onComplete: function (twn:FlxTween) {
				group.remove(cFd, true);
				cFd.destroy();
			}});
		}

	public var curLight:Int = -1;
	public var curLightEvent:Int = -1;


	function staticHitMiss(){
		trace('lol you missed the static note!');
					daNoteStatic = new FlxSprite(0, 0);
					daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic');
					daNoteStatic.animation.addByPrefix('static', "staticANIMATION", 24, false);
					daNoteStatic.animation.play('static');
					daNoteStatic.cameras = [camHUD2];
					add(daNoteStatic);
	
					FlxG.camera.shake(0.005, 0.005);
	
					FlxG.sound.play(Paths.sound("hitStatic1"));
	
					add(daNoteStatic);
	
					new FlxTimer().start(.38, function(trol:FlxTimer) // fixed lmao
					{
						daNoteStatic.alpha = 0;
						trace('ended HITSTATICLAWL');
						remove(daNoteStatic);
					});
				}
}

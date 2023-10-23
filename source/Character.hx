package;
import flixel.graphics.FlxGraphic;
import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
import PlayState;
import editors.ChartingState;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.util.FlxColor;
using StringTools;
import tjson.TJSON;
import hscript.Interp;
import hscript.ParserEx;
import haxe.xml.Parser;
import hscript.InterpEx;
import hscript.Expr;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import openfl.Lib;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
#if VIDEOS_ALLOWED

#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as FlxVideo;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as FlxVideo;
#elseif (hxCodec == "2.6.0") import VideoHandler as FlxVideo;
#else import vlc.VideoHandler as FlxVideo; #end

#end
typedef CharacterFile = {
	var crossColor:FlxColor;
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var hasGunned:Bool;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var inEdtior:Bool = false;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var startedDeath:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;
	public var crossFadeColor:FlxColor = 0xFF00FFFF;
	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 2; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
	public var likeGf:Bool = false;
	public var beingControlled:Bool = false;
	public var hasGun:Bool = false;
	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];
	public var followCamX:Float = 0;
	public var followCamY:Float = 0;
	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;
	public var wasSing:Bool = false;
	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];
	var imagesPath:String = '';

	private var interp:Interp;

	//hscripts stuff pretty fucked up
	
	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	function callInterp(func_name:String, args:Array<Dynamic>) {
		if (interp == null) return;
		if (!interp.variables.exists(func_name)) return;
		var method = interp.variables.get(func_name);
		switch (args.length)
		{
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
		}
	}
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		var hscriptChars:Array<Array<String>> = [];
		if (FNFAssets.exists(SUtil.getPath() + Paths.getLibraryPath("hscriptCharList.txt")))
			hscriptChars.push(CoolUtil.coolTextFile(SUtil.getPath() + Paths.getLibraryPath("hscriptCharList.txt")));
		if (FNFAssets.exists(Paths.modFolders("hscriptCharList.txt")))
			hscriptChars.push(CoolUtil.coolTextFile(Paths.modFolders("hscriptCharList.txt")));

		for (files in hscriptChars){
			for (chars in files){
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':
case chars: var interppath:String = '';

#if MODS_ALLOWED
if(FNFAssets.exists(Paths.modFolders('characters/') + curCharacter, Hscript)) {
	interppath = Paths.modFolders('characters/');
} else {
	interppath = SUtil.getPath() + Paths.getPreloadPath('characters/');
}
#else
interppath = SUtil.getPath() + Paths.getPreloadPath('characters/');
#end

if (FNFAssets.exists(interppath + curCharacter, Hscript)){
interp = Character.getAnimInterp(curCharacter);
}
else{
	interp = null;	
}
callInterp("init", [this]);
		}
	}
}switch (curCharacter)
		{
			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = SUtil.getPath() + Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = SUtil.getPath() + Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				//sparrow
				//packer
				//texture
				#if MODS_ALLOWED
				var modTxtToFind:String = Paths.modsTxt(json.image);
				var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (FileSystem.exists(modTxtToFind) || FileSystem.exists(SUtil.getPath() + txtToFind) || Assets.exists(txtToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
				#end
				{
					
					spriteType = "packer";
				}
				
				#if MODS_ALLOWED
				var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
				var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (FileSystem.exists(modAnimToFind) || FileSystem.exists(SUtil.getPath() + animToFind) || Assets.exists(animToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
				#end
				{
					spriteType = "texture";
				}

				switch (spriteType){
					
					case "packer":
						frames = Paths.getPackerAtlas(json.image);
					
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
					
					case "texture":
						frames = AtlasFrameMaker.construct(json.image);
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				hasGun = json.hasGunned;
				
				positionArray = json.position;
				cameraPosition = json.camera_position;
				crossFadeColor = json.crossColor;
				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;



				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}
						if(anim.offsets == null) 
							crossFadeColor = FlxColor.fromRGB(healthColorArray[0],healthColorArray[1],healthColorArray[2]);
						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}
				//trace('Loaded file to character ' + curCharacter);
				if (curCharacter.startsWith('gf'))
					likeGf = true;
				var interppath:String = '';

		#if MODS_ALLOWED
		if(FNFAssets.exists(Paths.modFolders('characters/') + curCharacter, Hscript)) {
			interppath = Paths.modFolders('characters/');
		} else {
			interppath = SUtil.getPath() + Paths.getPreloadPath('characters/');
		}
		#else
		interppath = SUtil.getPath() + Paths.getPreloadPath('characters/');
		#end

		if (FNFAssets.exists(interppath + curCharacter, Hscript)){
		interp = Character.getAnimInterp(curCharacter);
		}
		else{
			interp = null;	
		}
		callInterp("init", [this]);
		}

		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();

		
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/*// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}*/
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				hasGun = true;

		}
		if (hasGun){
			skipDance = true;
		loadMappedAnims();
		playAnim("shoot1");
		}
		followCamX = positionArray[0];
		followCamY = positionArray[1];
	}

	override function update(elapsed:Float)
	{
		
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
			
			if (beingControlled)
				{
					if (animation.curAnim.name.startsWith('sing'))
						{
							holdTimer += elapsed;
						}
						else
							holdTimer = 0;
			
						if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
						{
							playAnim('idle', true, false, 10);
						}
			
						if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
						{
							playAnim('deathLoop');
						}
				}

				if (hasGun){
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if(animation.curAnim != null && animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}
			

			if (!beingControlled)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		callInterp("update", [elapsed, this]);
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if (interp != null)
				callInterp("dance", [this]);
			else if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{

		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (likeGf)
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
		callInterp("onPlayAnim", [this]);
	}
	
	function loadMappedAnims():Void
	{
		var file:String = curCharacter;
		switch(curCharacter)
		{
			case 'pico-speaker':
				file = 'picospeaker';

		}
		var noteData:Array<SwagSection> = Song.loadFromJson(file, Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		switch(curCharacter)
		{
			case 'pico-speaker':
		TankmenBG.animationNotes = animationNotes;
		}
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	public static function getAnimInterp(char:String):Interp {
		var interp = PluginManager.createSimpleInterp();
		var parser = new hscript.Parser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		var program:Expr;
		var path:String = '';

		#if MODS_ALLOWED
		if(FNFAssets.exists(Paths.modFolders('characters/') + char, Hscript)) {
			path = Paths.modFolders('characters/');
		} else {
			path = SUtil.getPath() + Paths.getPreloadPath('characters/');
		}
		#else
		path = Paths.getPreloadPath('characters/');
		#end
		program = parser.parseString(FNFAssets.getHscript(path + char));

		#if sys
		interp.variables.set('FlxRuntimeShader', FlxRuntimeShader);
		interp.variables.set('ShaderFilter', ShaderFilter);
		#end
		interp.variables.set('FlxGraphic', FlxGraphic);
		interp.variables.set("hscriptPath", path + char + '/');
		interp.variables.set("charName", char);
		
		interp.variables.set("FunkinLua", FunkinLua);
		interp.variables.set("currentPlayState", PlayState.instance);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("GameOverSubstate", GameOverSubstate);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("StoryMenuState", StoryMenuState);
		if (PlayState.SONG != null){
		interp.variables.set("curSong", PlayState.SONG.song);
		interp.variables.set("curStep", PlayState.instance.curStep);
		interp.variables.set("curBeat", PlayState.instance.curBeat);
		interp.variables.set("curSection", PlayState.instance.curSection);
		}
		interp.variables.set("pi", Math.PI);
	
	    interp.variables.set("Math", Math);
		interp.variables.set("Conductor", Conductor);
		try{
		interp.execute(program);
		trace(interp);
		
	}
	catch (e)
	{
		Lib.application.window.alert(e.message, "ITS ERRORS BRUH,WHAT DID U WRITE IN???");
	}
	return interp;
	}
}

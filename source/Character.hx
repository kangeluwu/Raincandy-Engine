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
typedef CharacterFile = {
	var crossColor:Null<FlxColor>;
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var hasGunned:Null<Bool>;
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
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();
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
	public var isAnimateAtlas:Bool = false;
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
	function mixtex(frames1:FlxAtlasFrames, frames2:FlxAtlasFrames) {
		for (frame in frames2.frames){
			frames1.pushFrame(frame);
		}
		return frames1;
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
				var characterPath:String = 'characters/$curCharacter.json';

				var path:String = Paths.getPath(characterPath, TEXT, null, true);
				#if MODS_ALLOWED
				if (!FileSystem.exists(path))
				#else
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getSharedPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
					color = FlxColor.BLACK;
					alpha = 0.6;
				}
				if (curCharacter.startsWith('gf'))
					likeGf = true;
				try
				{
					#if MODS_ALLOWED
					loadCharacterFile(Json.parse(File.getContent(path)));
					#else
					loadCharacterFile(Json.parse(Assets.getText(path)));
					#end
				}
				catch(e:Dynamic)
				{
					trace('Error loading character file of "$character": $e');
				}



		
		}


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

	}
	
	public function loadCharacterFile(json:Dynamic)
		{
							
			var interppath:String = '';
			isAnimateAtlas = false;
	
			#if flxanimate
			var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT, null, true);
			if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
				isAnimateAtlas = true;
			#end
	
			scale.set(1, 1);
			updateHitbox();
	
			if(!isAnimateAtlas)
				frames = Paths.getAtlas(json.image);
			#if flxanimate
			else
			{
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				try
				{
					Paths.loadAnimateAtlas(atlas, json.image);
				}
				catch(e:Dynamic)
				{
					FlxG.log.warn('Could not load atlas ${json.image}: $e');
				}
			}
			#end
	
			imageFile = json.image;
			jsonScale = json.scale;
			if(json.scale != 1) {
				scale.set(jsonScale, jsonScale);
				updateHitbox();
			}
	
			// positioning
			positionArray = json.position;
			cameraPosition = json.camera_position;
	
			// data
			healthIcon = json.healthicon;
			singDuration = json.sing_duration;
			hasGun = (json.hasGunned == null) ? false : json.hasGun;
			flipX = (json.flip_x != isPlayer);
			healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
			if(json.crossColor == null) 
				crossFadeColor = FlxColor.fromRGB(healthColorArray[0],healthColorArray[1],healthColorArray[2]);
			else
				crossFadeColor = json.crossColor;

			originalFlipX = (json.flip_x == true);
	
			// antialiasing
			noAntialiasing = (json.no_antialiasing == true);
			antialiasing = ClientPrefs.antialiasing ? !noAntialiasing : false;
	
			// animations
			animationsArray = json.animations;
			if(animationsArray != null && animationsArray.length > 0) {
				for (anim in animationsArray) {
					var animAnim:String = '' + anim.anim;
					var animName:String = '' + anim.name;
					var animFps:Int = anim.fps;
					var animLoop:Bool = !!anim.loop; //Bruh
					var animIndices:Array<Int> = anim.indices;
	
					if(!isAnimateAtlas)
					{
						if(animIndices != null && animIndices.length > 0)
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						else
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
					}
					#if flxanimate
					else
					{
						if(animIndices != null && animIndices.length > 0)
							atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
						else
							atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
					}
					#end
	
					if(anim.offsets != null && anim.offsets.length > 1) addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
					else addOffset(anim.anim, 0, 0);
				}
			}
			#if flxanimate
			if(isAnimateAtlas) copyAtlasValues();
			#end
			//trace('Loaded file to character ' + curCharacter);
			followCamX = positionArray[0];
			followCamY = positionArray[1];

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

	override function update(elapsed:Float)
	{
		if(isAnimateAtlas) atlas.update(elapsed);

		if(debugMode || (!isAnimateAtlas && animation.curAnim == null) || (isAnimateAtlas && atlas.anim.curSymbol == null))
		{
			super.update(elapsed);
			return;
		}

		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					var anim:String = getAnimationName();
				if(specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}
					heyTimer = 0;
				}
			} else if(specialAnim && isAnimationFinished())
			{
				specialAnim = false;
				dance();
			}

			
			if (beingControlled)
				{
					if (getAnimationName().startsWith('sing'))
						{
							holdTimer += elapsed;
						}
						else
							holdTimer = 0;
			
						if (getAnimationName().endsWith('miss') && isAnimationFinished() && !debugMode)
							{
								dance();
								
							}
			
						if (getAnimationName() == 'firstDeath' && isAnimationFinished() && startedDeath)
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
					if(!isAnimationNull() && isAnimationFinished()) playAnim(getAnimationName(), false, false, animation.curAnim.frames.length - 3);
			}
			

			if (!beingControlled)
			{
				if (getAnimationName().startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			var name:String = getAnimationName();
		if(isAnimationFinished() && animOffsets.exists('$name-loop'))
			playAnim('$name-loop');
		}
		callInterp("update", [elapsed, this]);
	
	}

	inline public function isAnimationNull():Bool
		return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curSymbol == null);

	inline public function getAnimationName():String
	{
		var name:String = '';
		@:privateAccess
		if(!isAnimationNull()) name = !isAnimateAtlas ? animation.curAnim.name : atlas.anim.lastPlayedAnim;
		return (name != null) ? name : '';
	}

	public function isAnimationFinished():Bool
	{
		if(isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.finished : atlas.anim.finished;
	}

	public function finishAnimation():Void
	{
		if(isAnimationNull()) return;

		if(!isAnimateAtlas) animation.curAnim.finish();
		else atlas.anim.curFrame = atlas.anim.length - 1;
	}

	public var animPaused(get, set):Bool;
	private function get_animPaused():Bool
	{
		if(isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.paused : atlas.anim.isPlaying;
	}
	private function set_animPaused(value:Bool):Bool
	{
		if(isAnimationNull()) return value;
		if(!isAnimateAtlas) animation.curAnim.paused = value;
		else
		{
			if(value) atlas.anim.pause();
			else atlas.anim.resume();
		} 

		return value;
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
			if(!isAnimateAtlas) animation.play(AnimName, Force, Reversed, Frame);
		else atlas.anim.play(AnimName, Force, Reversed, Frame);


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
		try
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
	catch(e){}
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
	#if flxanimate
	public var atlas:FlxAnimate;
	public override function draw()
	{
		if(isAnimateAtlas)
		{
			copyAtlasValues();
			atlas.draw();
			return;
		}
		super.draw();
	}

	public function copyAtlasValues()
	{
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor = scrollFactor;
			atlas.scale = scale;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			atlas.antialiasing = antialiasing;
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}

	public override function destroy()
	{
		super.destroy();
		destroyAtlas();
	}

	public function destroyAtlas()
	{
		if (atlas != null)
			atlas = FlxDestroyUtil.destroy(atlas);
	}
	#end
}

package;

import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if flxanimate
import flxanimate.FlxAnimate;
import flxanimate.frames.FlxAnimateFrames;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;

import flash.media.Sound;

using StringTools;
import openfl.display3D.textures.RectangleTexture;

enum abstract PathsFunction(String)
{
  var MUSIC;
  var INST;
  var VOICES;
  var SOUND;
}

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if MODS_ALLOWED
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];
	#end
	public static function stripLibrary(path:String):String
		{
		  var parts:Array<String> = path.split(':');
		  if (parts.length < 2) return path;
		  return parts[1];
		}
	  
		public static function getLibrary(path:String):String
		{
		  var parts:Array<String> = path.split(':');
		  if (parts.length < 2) return 'preload';
		  return parts[0];
		}

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> =
	[
		'windose_data/music/freakyMenu.$SOUND_EXT',
		'windose_data/shared/music/breakfast.$SOUND_EXT',
		'windose_data/shared/music/tea-time.$SOUND_EXT',
	];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
		{
			// clear non local assets in the tracked assets list
			for (key in currentTrackedAssets.keys())
			{
				// if it is not currently contained within the used local assets
				if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
				{
					destroyGraphic(currentTrackedAssets.get(key)); // get rid of the graphic
					currentTrackedAssets.remove(key); // and remove the key from local cache map
				}
			}
	
			// run the garbage collector for good measure lmfao
			System.gc();
		}
	
		// define the locally tracked assets
		public static var localTrackedAssets:Array<String> = [];
	
		@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
		public static function clearStoredMemory()
		{
			// clear anything not in the tracked assets list
			for (key in FlxG.bitmap._cache.keys())
			{
				if (!currentTrackedAssets.exists(key))
					destroyGraphic(FlxG.bitmap.get(key));
			}
	
			// clear all sounds that are cached
			for (key => asset in currentTrackedSounds)
			{
				if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
				{
					Assets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}
			// flags everything to be cleared out next unused memory clear
			localTrackedAssets = [];
			#if !html5 openfl.Assets.cache.clear("songs"); #end
		}
	
		inline static function destroyGraphic(graphic:FlxGraphic)
		{
			// free some gpu memory
			@:privateAccess{
			if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
				graphic.bitmap.__texture.dispose();
		}
			FlxG.bitmap.remove(graphic);
		}
		

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null, ?modsAllowed:Bool = false)
	{
		#if MODS_ALLOWED
		if(modsAllowed)
		{
			var customFile:String = file;
			if (library != null)
				customFile = '$library/$file';

			var modded:String = modFolders(customFile);
			if(FileSystem.exists(modded)) return modded;
		}
		#end

		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	public static function getPathEX(file:String, ?library:Null<String> = null, ?modsAllowed:Bool = false)
		{
			#if MODS_ALLOWED
			if(modsAllowed)
			{
				var customFile:String = file;
				if (library != null)
					customFile = '$library/$file';
	
				var modded:String = modFolders(customFile);
				if(FileSystem.exists(modded)) return modded;
			}
			#end
	
			if (library != null)
				return 'windose_data/$library/$file';
	
			if (currentLevel != null)
			{
				var levelPath:String = '';
				if(currentLevel != 'shared') {
					levelPath = 'windose_data/$currentLevel/$file';
					if (FNFAssets.exists(levelPath))
						return levelPath;
				}
	
				levelPath = 'windose_data/shared/$file';
				if (FNFAssets.exists(levelPath))
					return levelPath;
			}
	
			return getPreloadPath(file);
		}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:windose_data/$library/$file';
		return returnPath;
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'windose_data/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline public static function moddialoguetxt(key:String)
		{
			return modFolders('data/$key.txt');
		}
	inline static public function hscript(key:String, ?library:String)
		{
			#if MODS_ALLOWED
			var file:String = modFolders(key + '.hscript');
			if(FileSystem.exists(file)) {
				return file;
			}
			#end
			
			return getPath('$key.hscript', TEXT, library);
		}

	inline public static function hscriptModchart(key:String, ?library:String)
			{
				#if MODS_ALLOWED
				var file:String = modFolders('data/' + key + '.hscript');
				if(FileSystem.exists(file)) {
					return file;
				}
				#end
				
				return getPath('data/$key.hscript', TEXT, library);
			}
			inline public static function getSharedPath(file:String = '')
				{
					return 'assets/shared/$file';
				}
	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return SUtil.getPath() + 'windose_data/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String,exclude:Bool = false):Sound
	{
		var sound:Sound = returnSound('sounds', key, library,exclude);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}
	
	inline static public function songStuffer(song:String,fileName:String = 'Inst'):Any
		{
			var songKey:String = '${formatToSongPath(song)}/$fileName';
			var voices = returnSound('songs', songKey);
			return voices;
		}
		inline static public function songStufferPath(song:String,fileName:String = 'Inst'):String
			{
				var songKey:String = '${formatToSongPath(song)}/$fileName';
				var path:String ='songs';
				#if MODS_ALLOWED
				var file:String = modsSounds(path, songKey);
				if(FileSystem.exists(file)) {
					return file;
				}
				#end
		
				var gottenPath:String =  SUtil.getPath() + getPath('$path/$songKey.$SOUND_EXT', SOUND, 'songs');
				gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		
					#if !mobile
					var folder:String = '';
					if(path == 'songs') folder = 'songs:';
					#end
					gottenPath = #if !mobile folder + #end getPath('$path/$songKey.$SOUND_EXT', SOUND, 'songs');
			
				return gottenPath;
			}
	inline static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}
		//used for vanilla/M+ engines
		//给原版和M+引擎用的LOL我也不知道为什么
	inline static public function musicinst(song:String, ?library:String):Any
		{
			var songKey:String = '${formatToSongPath(song)}_Inst';
			var inst = returnSound('music', songKey, library);
			return inst;
		}

		inline static public function musicvoices(song:String, ?library:String):Any
			{
				var songKey:String = '${formatToSongPath(song)}_Voices';
				var inst = returnSound('music', songKey, library);
				return inst;
			}
	inline static public function image(key:String, ?library:String, ?allowGPU:Bool = true,exclude:Bool = false):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library, allowGPU,exclude);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if MODS_ALLOWED
		if (!ignoreMods && FileSystem.exists(modFolders(key)))
			return File.getContent(modFolders(key));
		#end

		if (FileSystem.exists(SUtil.getPath() + getPreloadPath(key)))
			return File.getContent(SUtil.getPath() + getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = SUtil.getPath() + getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = SUtil.getPath() + getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return SUtil.getPath() + 'windose_data/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType = null, ?ignoreMods:Bool = false)
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		#end

		if(OpenFlAssets.exists(getPath(key, type))) {
			return true;
		}
		return false;
	}
	#if MODS_ALLOWED
	inline static public function isModPath(key:String)
		{
			
			if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
				return modFolders(key);
			}
			return SUtil.getPath() + getLibraryPath(key);

		}
		#end
	
	inline static public function getSparrowAtlas(key:String, ?library:String, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key,allowGPU);
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key))) {
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library,allowGPU)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library,allowGPU), file('images/$key.xml', library));
		#end
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
		{
			var imageLoaded:FlxGraphic = returnGraphic(key,allowGPU);
			#if MODS_ALLOWED
			var jsonExists:Bool = false;
	
			var json:String = modsImagesJson(key);
			if(FileSystem.exists(json)) jsonExists = true;
	
			return FlxAtlasFrames.fromTexturePackerJson((imageLoaded != null ? imageLoaded : image(key, library,allowGPU)), (jsonExists ? File.getContent(json) : getPath('images/$key.json', TEXT,library)));
			#else
			return FlxAtlasFrames.fromTexturePackerJson(image(key, library,allowGPU), getPath('images/$key.json', TEXT,library));
			#end
		}
		

	inline static public function getPackerAtlas(key:String, ?library:String, ?allowGPU:Bool = true)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key,allowGPU);
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library,allowGPU)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library,allowGPU), file('images/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true)
		{
			if(bitmap == null)
			{
				#if MODS_ALLOWED
				if (FileSystem.exists(file))
					bitmap = BitmapData.fromFile(file);
				else
				#end
				{
					if (OpenFlAssets.exists(file, IMAGE))
						bitmap = OpenFlAssets.getBitmapData(file);
				}
	
				if(bitmap == null) return null;
			}
	
			localTrackedAssets.push(file);
			
		if (allowGPU && ClientPrefs.cacheOnGPU && bitmap.image != null)
			{
				@:privateAccess{
				bitmap.lock();
				if (bitmap.__texture == null)
				{
					bitmap.image.premultiplied = true;
					bitmap.getTexture(FlxG.stage.context3D);
				}
				bitmap.getSurface();
				bitmap.disposeImage();
				bitmap.image.data = null;
				bitmap.image = null;
				bitmap.readable = true;
			}
		}
			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
			newGraphic.persist = true;
			newGraphic.destroyOnNoUse = false;
			currentTrackedAssets.set(file, newGraphic);
			return newGraphic;
		}
		#if flxanimate
		public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
		{
			var changedAnimJson = false;
			var changedAtlasJson = false;
			var changedImage = false;
			
			if(spriteJson != null)
			{
				changedAtlasJson = true;
				spriteJson = File.getContent(spriteJson);
			}
	
			if(animationJson != null) 
			{
				changedAnimJson = true;
				animationJson = File.getContent(animationJson);
			}
	
			// is folder or image path
			if(Std.isOfType(folderOrImg, String))
			{
				var originalPath:String = folderOrImg;
				for (i in 0...10)
				{
					var st:String = '$i';
					if(i == 0) st = '';
	
					if(!changedAtlasJson)
					{
						spriteJson = getTextFromFile('images/$originalPath/spritemap$st.json');
						if(spriteJson != null)
						{
							trace('found Sprite Json');
							changedImage = true;
							changedAtlasJson = true;
							folderOrImg = Paths.image('$originalPath/spritemap$st');
							break;
						}
					}
					else if(Paths.fileExists('images/$originalPath/spritemap$st.png', IMAGE))
					{
						trace('found Sprite PNG');
						changedImage = true;
						folderOrImg = Paths.image('$originalPath/spritemap$st');
						break;
					}
				}
	
				if(!changedImage)
				{
					//trace('Changing folderOrImg to FlxGraphic');
					changedImage = true;
					folderOrImg = Paths.image(originalPath);
				}
	
				if(!changedAnimJson)
				{
					//trace('found Animation Json');
					changedAnimJson = true;
					animationJson = getTextFromFile('images/$originalPath/Animation.json');
				}
			}
	
			//trace(folderOrImg);
			//trace(spriteJson);
			//trace(animationJson);
			spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
		}
	
		/*private static function getContentFromFile(path:String):String
		{
			var onAssets:Bool = false;
			var path:String = Paths.getPath(path, TEXT, true);
			if(FileSystem.exists(path) || (onAssets = true && Assets.exists(path, TEXT)))
			{
				//trace('Found text: $path');
				return !onAssets ? File.getContent(path) : Assets.getText(path);
			}
			return null;
		}*/
		#end

		static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
			{
				var useMod = #if MODS_ALLOWED true; #else false; #end
				var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		
				var myXml:Dynamic = getPath('images/$key.xml', TEXT,true);
				if(OpenFlAssets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod)) #end )
				{
					return getSparrowAtlas(key,library);
				}
				else
				{
					var myJson:Dynamic = getPath('images/$key.json', TEXT,true);
					if(OpenFlAssets.exists(myJson) #if MODS_ALLOWED || (FileSystem.exists(myJson) && (useMod)) #end )
					{
						return getAsepriteAtlas(key,library);
					}
				}
				return getPackerAtlas(key, library);
			}
			inline static public function getFolderPath(file:String, folder = "shared")
				return 'assets/$folder/$file';
	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String,?allowGPU:Bool = true,exclude:Bool = false) {
		var bitmap:BitmapData = null;
		var file:String = null;

		#if MODS_ALLOWED
		file = modsImages(key);
		if (currentTrackedAssets.exists(file))
		{
			localTrackedAssets.push(file);
			return currentTrackedAssets.get(file);
		}
		else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			file = getPath('images/$key.png', IMAGE, library);
		
			if (currentTrackedAssets.exists(file))
			{
				localTrackedAssets.push(file);
				return currentTrackedAssets.get(file);
			}
			else if (OpenFlAssets.exists(file, IMAGE)){
				bitmap = OpenFlAssets.getBitmapData(file);
			}
		}
		
		if (bitmap != null)
		{
			localTrackedAssets.push(file);
			if (exclude)
				excludeAsset(file);
			if (allowGPU && ClientPrefs.cacheOnGPU && bitmap.image != null)
			{
				bitmap.lock();
				@:privateAccess{
				if (bitmap.__texture == null)
				{
					bitmap.image.premultiplied = true;
					bitmap.getTexture(FlxG.stage.context3D);
				}
			
				bitmap.getSurface();
				bitmap.disposeImage();
				bitmap.image.data = null;
				bitmap.image = null;
				bitmap.readable = true;
			}
			}
			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
			newGraphic.persist = true;
			newGraphic.destroyOnNoUse = false;
			currentTrackedAssets.set(file, newGraphic);
			return newGraphic;
		}

		trace('oh no its returning null NOOOO ($file)');
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String,exclude:Bool = false) {
		#if MODS_ALLOWED
		var file:String = modsSounds(path, key);
		if(FileSystem.exists(file)) {
			if(!currentTrackedSounds.exists(file)) {
				currentTrackedSounds.set(file, FNFAssets.getSound(file));
			}
			localTrackedAssets.push(key);
			if (exclude)
				excludeAsset(key);
			return currentTrackedSounds.get(file);
		}
		#end
		// I hate this so god damn much
		var gottenPath:String =  SUtil.getPath() + getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath))
		#if MODS_ALLOWED
			currentTrackedSounds.set(gottenPath, FNFAssets.getSound(#if !mobile './' + #end gottenPath));
		#else
		{
			#if !mobile
			var folder:String = '';
			if(path == 'songs') folder = 'songs:';
#end
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(#if !mobile folder + #end getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		#end
		if (exclude)
			excludeAsset(gottenPath);
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	inline public static function getHscriptStagePath(file:String = '')
		{
			return SUtil.getPath() + 'windose_data/stages/custom_Hscript_stages/$file';
		}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '') {
		return SUtil.getPath() + 'mods/' + key;
	}

	inline static public function modsFont(key:String) {
		return modFolders('fonts/' + key);
	}
	inline static public function modsHscriptStages(key:String) {
		return modFolders('stages/custom_Hscript_stages/' + key);
	}

	inline static public function modsImagesJson(key:String) {
		return modFolders('images/' + key + '.json');
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}


	
	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	/* Goes unused for now

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.frag');
	}
	inline static public function modsShaderVertex(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.vert');
	}
	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/' + key + '.json');
	}*/

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}

		for(mod in getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;

		}
		return SUtil.getPath() + 'mods/' + key;
	}

	public static var globalMods:Array<String> = [];

	static public function getGlobalMods()
		return globalMods;

	static public function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					var folder = dat[0];
					var path = Paths.mods(folder + '/pack.json');
					if(FileSystem.exists(path)) {
						try{
							var rawJson:String = File.getContent(path);
							if(rawJson != null && rawJson.length > 0) {
								var stuff:Dynamic = Json.parse(rawJson);
								var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
								if(global)globalMods.push(dat[0]);
							}
						} catch(e:Dynamic){
							trace(e);
						}
					}
				}
			}
		}
		return globalMods;
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}

	
	inline public static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true)
		{
			var foldersToCheck:Array<String> = [];
			if(FileSystem.exists(path + fileToFind))
				foldersToCheck.push(path + fileToFind);
	
			if(Paths.currentLevel != null && Paths.currentLevel != path)
			{
				var pth:String = Paths.getFolderPath(fileToFind, Paths.currentLevel);
				if(FileSystem.exists(pth))
					foldersToCheck.push(pth);
			}
	
			#if MODS_ALLOWED
			if(mods)
			{
				// Global mods first
				for(mod in getGlobalMods())
				{
					var folder:String = Paths.mods(mod + '/' + fileToFind);
					if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(folder);
				}
	
				// Then "RCE/mods/" main folder
				var folder:String = Paths.mods(fileToFind);
				if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(Paths.mods(fileToFind));
	
				// And lastly, the loaded mod's folder
				if(Paths.currentModDirectory != null && currentModDirectory.length > 0)
				{
					var folder:String = Paths.mods(currentModDirectory + '/' + fileToFind);
					if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(folder);
				}
			}
			#end
			return foldersToCheck;
		}

		inline public static function mergeAllTextsNamed(path:String, ?defaultDirectory:String = null, allowDuplicates:Bool = false)
			{
				if(defaultDirectory == null) defaultDirectory = '';
				defaultDirectory = defaultDirectory.trim();
				if(!defaultDirectory.endsWith('/')) defaultDirectory += '/';
				if(!defaultDirectory.startsWith(SUtil.getPath() + 'windose_data/')) defaultDirectory = SUtil.getPath() + 'windose_data/$defaultDirectory';
		
				var mergedList:Array<String> = [];
				var paths:Array<String> = directoriesWithFile(defaultDirectory, path);
		
				var defaultPath:String = defaultDirectory + path;
				if(paths.contains(defaultPath))
				{
					paths.remove(defaultPath);
					paths.insert(0, defaultPath);
				}
		
				for (file in paths)
				{
					var list:Array<String> = CoolUtil.coolTextFile(file);
					for (value in list)
						if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
							mergedList.push(value);
				}
				return mergedList;
			}
	#end
}

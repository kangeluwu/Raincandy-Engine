package util;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.system.FlxSound;
import flixel.FlxBasic;
import lime.system.System;
import flixel.util.FlxSort;
import flixel.math.FlxPoint;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import tjson.TJSON;
import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets;
#end
import flixel.FlxSprite;
using StringTools;
import flixel.util.FlxColor;
class CoolUtil
{
	
	inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);


	public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point == null ? FlxPoint.weak() : point;
		p.set((x * Math.cos(angle)) - (y * Math.sin(angle)), (x * Math.sin(angle)) + (y * Math.cos(angle)));
		return p;
	}
	inline public static function clamper(n:Float, l:Float, h:Float)
		{
			if (n > h)
				n = h;
			if (n < l)
				n = l;
	
			return n;
		}
	
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	public static final HSCRIPT_EXT:Array<String> = ['hscript', 'hxs'];

	public static final JSON_EXT:Array<String> = ['json', 'jsonc'];

	
   public static inline function byZIndex(order:Int, a:FlxBasic, b:FlxBasic):Int
	{
	  if (a == null || b == null) return 0;
	  return FlxSort.byValues(order, a.zIndex, b.zIndex);
	}

	public static function coolDynamicTextFile(path:String):Array<String>
	{
		return coolTextFile(path);
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	public static function clamp(mini:Float, maxi:Float, value:Float):Float {
		return Math.min(Math.max(mini,value), maxi);
	}
	// can either return an array or a dynamic
	public static function parseJson(json:String):Dynamic {
		// the reason we do this is to make it easy to swap out json parsers
		return TJSON.parse(json);
	}
	public static function stringifyJson(json:Dynamic, ?fancy:Bool = true):String {
		// use tjson to prettify it
		var style:String = if (fancy) 'fancy' else null;
		return TJSON.encode(json,style);
	}
	// include all helper functions to keep shit in the same place

	inline public static function quantizeAlpha(f:Float, interval:Float)
		{
			return Std.int((f + interval / 2) / interval) * interval;
		}
		
	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}
	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static function getDiffString(num:Null<Int> = null):String
		{
			return difficulties[num == null ? PlayState.storyDifficulty : num].toUpperCase();
		}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	inline public static function colorFromString(color:String):FlxColor
		{
			var hideChars = ~/[\t\n\r]/;
			var color:String = hideChars.split(color).join('').trim();
			if(color.startsWith('0x')) color = color.substring(color.length - 6);
	
			var colorNum:Null<FlxColor> = FlxColor.fromString(color);
			if(colorNum == null) colorNum = FlxColor.fromString('#$color');
			return colorNum != null ? colorNum : FlxColor.WHITE;
		}

		
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
		{
			if(decimals < 1)
				return Math.floor(value);
	
			var tempMult:Float = 1;
			for (i in 0...decimals)
				tempMult *= 10;
	
			var newValue:Float = Math.floor(value * tempMult);
			return newValue / tempMult;
		}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	
	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	
	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'Raincandy_U'):String {
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
}

class FlxTools {
	// Load a graphic and ensure it exists
	static public function loadGraphicDynamic(s:FlxSprite, path:String, animated:Bool=false, width:Int=0, height:Int=0, unique:Bool=false, ?key:String):FlxSprite {
		var sus:BitmapData = FNFAssets.getBitmapData(path);
		s.loadGraphic(sus,animated,width,height,unique,key);
		return s;
	}
}

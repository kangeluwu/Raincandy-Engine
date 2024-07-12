package editors;
import flixel.text.FlxText;
import flixel.FlxSprite;

#if desktop
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;

import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import customlize.*;
import haxe.format.JsonParser;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import openfl.utils.Assets as OpenFlAssets;
import lime.media.AudioBuffer;
import haxe.io.Bytes;
import flash.geom.Rectangle;
import flixel.util.FlxSort;
#if sys
import sys.io.File;
import sys.FileSystem;
import flash.media.Sound;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import tjson.TJSON;
#end

using StringTools;

import hscript.InterpEx;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.ClassDeclEx;

@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)


class ChartingStateDEBUGMODE extends customlize.CustomState
{
	public static var noteTypeList:Array<String> = //Used for backwards compatibility with 0.1 - 0.3.2 charts, though, you should add your hardcoded custom note types here too.
	[
		'',
		'Alt Animation',
		'Hey!',
		'Hurt Note',
		'Death Note',
		'GF Sing',
		'Both Sing',
		'Drain Note',
		'Static Note',
		'Warning Note',
		'No Animation'
	];
	public var ignoreWarnings = false;
	public static var goToPlayState:Bool = false;
	public static var curSec:Int = 0;
	public static var lastSection:Int = 0;
	private static var lastSong:String = '';
	public static var GRID_SIZE:Int = 40;
	public static var quantization:Int = 16;
	public static var curQuant = 3;
	public var quantizations:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];
	public static var vortex:Bool = false;
	public var mouseQuant:Bool = false;
	public var lilStage:FlxSprite;
	public var lilBf:FlxSprite;
	public var lilOpp:FlxSprite;
	
	override function makeHaxeState(usehaxe:String, path:String, filename:String,interp = null) {
	interp = PluginManager.createSimpleInterp();
	interp.variables.set("noteTypeList", noteTypeList);
	interp.variables.set("ignoreWarnings", ignoreWarnings);
	interp.variables.set("goToPlayState", goToPlayState);
	interp.variables.set("curSec", curSec);
	interp.variables.set("lastSection", lastSection);
	interp.variables.set("lastSong", lastSong);
	interp.variables.set("StageData", StageData);
	interp.variables.set("LoadingState", LoadingState);
	interp.variables.set("StrumNote", StrumNote);
	interp.variables.set("Note", Note);
	interp.variables.set("curQuant", curQuant);
	interp.variables.set("quantizations", quantizations);
	interp.variables.set("vortex", vortex);
	interp.variables.set("mouseQuant", mouseQuant);
	interp.variables.set("lilBf", lilBf);
	interp.variables.set("lilStage", lilStage);
	interp.variables.set("lilOpp", lilOpp);
		interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
		interp.variables.set("GRID_SIZE", GRID_SIZE);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Math", Math);
		interp.variables.set("Math", Math);
		interp.variables.set("lastSection", lastSection);
		interp.variables.set("instance", this);
		interp.variables.set("Song", Song);
		interp.variables.set("Path", haxe.io.Path);
		interp.variables.set("EditorPlayState", editors.EditorPlayState);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxObject", FlxObject);
		interp.variables.set("FlxUITabMenu", FlxUITabMenu);
		interp.variables.set("FlxUICheckBox", FlxUICheckBox);
		interp.variables.set("FlxUIDropDownMenuCustom", FlxUIDropDownMenuCustom);
		interp.variables.set("FlxUIInputText", FlxUIInputText);
		interp.variables.set("getStepperTextField", getStepperTextField);
		interp.variables.set("getButtons", getButtons);
		interp.variables.set("FlxButton", FlxButton);
		interp.variables.set("Prompt", Prompt);
		#if discord
		interp.variables.set("discord", true);
		interp.variables.set("DiscordClient", DiscordClient);
		#else
		interp.variables.set("discord", false);
		#end
		interp.variables.set("FlxUINumericStepper", FlxUINumericStepper);
		interp.variables.set("SoundGroup", SoundGroup);
		interp.variables.set("VoicesGroup", VoicesGroup);
		interp.variables.set("getNULLBUFF", getNULLBUFF);
		interp.variables.set("dataToBytes", dataToBytes);
		interp.variables.set("getBuff", getBuff);
		interp.variables.set("MasterEditorMenu", editors.MasterEditorMenu);
		interp.variables.set("Map", haxe.ds.StringMap);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("Rectangle", Rectangle);
		interp.variables.set("Bytes", Bytes);
		interp.variables.set("OpenFlAssets", OpenFlAssets);
		interp.variables.set("FileSystem", sys.FileSystem);
		interp.variables.set("IoPath", haxe.io.Path);
		interp.variables.set("checkBoxEvent", FlxUICheckBox.CLICK_EVENT);
		interp.variables.set("numericStepperEvent", FlxUINumericStepper.CHANGE_EVENT);
		interp.variables.set("inputTextEvent", FlxUIInputText.CHANGE_EVENT);
		interp.variables.set("updateBeat", updateBeat);
		interp.variables.set("updateCurStep", updateCurStep);
		interp.variables.set("updateSection", updateSection);
		interp.variables.set("rollbackSection", rollbackSection);
		interp.variables.set("Sound", Sound);
		interp.variables.set("curDecBeat", curDecBeat);
		interp.variables.set("curDecStep", curDecStep);
		interp.variables.set("AudioBuffer", AudioBuffer);
		interp.variables.set("FileReference", FileReference);
		interp.variables.set("readDirectory", FileSystem.readDirectory);
		interp.variables.set("isDirectory", FileSystem.isDirectory);
		interp.variables.set("AudioBuffer", AudioBuffer);
		#if (lime_cffi && !macro)
		interp.variables.set("canSPAWNWAVE", true);
		#else 
		interp.variables.set("canSPAWNWAVE", false);
		#end
		super.makeHaxeState(usehaxe, path, filename,interp);
	}
	function getStepperTextField(stepper:FlxUINumericStepper):Dynamic
		{
			@:privateAccess
			return stepper.text_field;
		}
		function getButtons(stepper:FlxUINumericStepper):Dynamic
			{
				@:privateAccess
				return [stepper.button_plus,stepper.button_minus];
			}
    function getNULLBUFF(sound:FlxSound){
		return (sound._sound != null && sound._sound.__buffer != null);
	}
	public function dataToBytes(data:lime.utils.UInt8Array):Bytes
		{
			return data.toBytes();
		}
	
	function getBuff(sound:FlxSound){
		return sound._sound.__buffer;
	}
	override function create()
		{
			CustomState.customStateScriptPath =SUtil.getPath()+'windose_data/scripts/custom_menus/';
			CustomState.customStateScriptName = 'ChartingState';
			super.create();
		}
	
		override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
		{
			callAllHScript("getEvent", [id, sender, data, params]);
		}
	
	
}


package;

import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.system.frontEnds.SoundFrontEnd;
import openfl.display.DisplayObject;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.math.FlxRect;
import animateatlas.AtlasFrameMaker;
import flixel.text.FlxText;
import flixel.FlxState;
import Shaders;
import openfl.filters.ShaderFilter;
import openfl.display.Stage;
import flixel.system.scaleModes.*;
import flixel.FlxGame;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.addons.effects.FlxTrail;
import hscript.InterpEx;
import hscript.Interp;
import Type.ValueType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.IFlxEffect;
import flixel.FlxG;
#if VIDEOS_ALLOWED
#if !ios
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as FlxVideo;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as FlxVideo;
#elseif (hxCodec == "2.6.0") import VideoHandler as FlxVideo;
#else import vlc.VideoHandler as FlxVideo; #end
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideoSprite; #end
#else
import hxvlc.flixel.FlxVideo as Video;
import hxvlc.flixel.FlxVideoSprite as VideoSprite;
#end
#end
#if mobile
import flixel.group.FlxGroup;
import android.FlxHitbox;
import android.FlxVirtualPad;
import flixel.ui.FlxButton;
#end
import hscript.Parser;
import openfl.utils.AssetType;
import hscript.ParserEx;
import hscript.ClassDeclEx;
import plugins.tools.MetroSprite;
import flixel.math.FlxPoint;
#if ios
#if VIDEOS_ALLOWED
class FlxVideo extends Video
{
var path:String = "";
var loaded:Bool = false;
    public override function load(loc:String,?options:Array<String>):Bool
    {
    path=loc;
    var exists = super.load(loc,options);
    if (exists)
    loaded = true;
    return super.load(loc,options);
		}
    public override function play():Bool
        {
        if(!loaded && path != null && path != '')
           load(path);
         return super.play();
        }
}
class FlxVideoSprite extends VideoSprite
{
    var sillypath:String = "";
var loaded:Bool = false;
    public override function load(loc:String,?options:Array<String>):Bool
    {
    sillypath=loc;
    var exists = super.load(loc,options);
    if (exists)
    loaded = true;
    return super.load(loc,options);
		}
    public override function play():Bool
        {
        if(!loaded && sillypath != null && sillypath != '')
           load(sillypath);
         return super.play();
        }
}
#end
#end
class PluginManager {
    public static var interp = new InterpEx();
    public static var hscriptClasses:Array<String> = [];
    public static var hscriptInstances:Array<Dynamic> = [];
    //private static var nextId:Int = 1;
	@:access(hscript.InterpEx)
    public static function init() 
    {
        //checks if the text file that has the names of the classes stored exists, otherwise this function will do nothing.
        if (!FNFAssets.exists("windose_data/scripts/plugin_classes/classes.txt"))
            return;
        
        //split lines of text, given to separate them into different names. something basic but powerful.
        var filelist = hscriptClasses = CoolUtil.coolTextFile("windose_data/scripts/plugin_classes/classes.txt");
		addVarsToInterp(interp); //this little thing is responsible for adding the corresponding variables.
        HscriptGlobals.init();
        for (file in filelist) {
            if (FNFAssets.exists("windose_data/scripts/plugin_classes/" + file + ".hx")) {
				interp.addModule(FNFAssets.getText("windose_data/scripts/plugin_classes/" + file + '.hx'));
            }
        }
        trace(InterpEx._scriptClassDescriptors);
    }

    /**
     * Create a simple interp, that already added all the needed shit
     * This is what has all the default things for hscript.
     * @see https://github.com/TheDrawingCoder-Gamer/Funkin/wiki/HScript-Commands
     * @return Interp
     */
    public static function createSimpleInterp():Interp {
        var reterp = new Interp();
        reterp = addVarsToInterp(reterp);
        return reterp;
    }
    public static function createSimpleInterpEx():InterpEx {
        var reterp = new InterpEx();
        reterp = addVarsToInterpEx(reterp);
        return reterp;
    }
    public static function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return interp.createScriptClassInstance(classname, args);
	}
    static function addingBasicStuffsIthink<T:Interp>(interp:T):T{
        interp.variables.set("BaseScaleMode", BaseScaleMode);
        interp.variables.set("FillScaleMode", FillScaleMode);
        interp.variables.set("BuildingEffect", BuildingEffect);
        interp.variables.set("BuildingShader", BuildingShader);
        interp.variables.set("FixedScaleAdjustSizeScaleMode", FixedScaleAdjustSizeScaleMode);
        interp.variables.set("FixedScaleMode", FixedScaleMode);
        interp.variables.set("PixelPerfectScaleMode", PixelPerfectScaleMode);
        interp.variables.set("RatioScaleMode", RatioScaleMode);
        interp.variables.set("RelativeScaleMode", RelativeScaleMode);
        interp.variables.set("StageSizeScaleMode", StageSizeScaleMode);
        interp.variables.set("FlxPoint", FlxPoint);
        interp.variables.set("Sound", flash.media.Sound);
        interp.variables.set("OpenFlAssets", OpenFlAssets);
        interp.variables.set("Assets", Assets);
        interp.variables.set("FlxTweenUtil", util.FlxTweenUtil);
        interp.variables.set("FlxTiledSprite", flixel.addons.display.FlxTiledSprite);
        interp.variables.set("FlxEffectSprite", FlxEffectSprite);
        interp.variables.set("AttachedFlxText", editors.ChartingState.AttachedFlxText);
		interp.variables.set("FlxOutlineEffect", FlxOutlineEffect);
        interp.variables.set("FlxRainbowEffect", FlxRainbowEffect);
        interp.variables.set("WindowUtil", util.WindowUtil);
        interp.variables.set("FlxShakeEffect", FlxShakeEffect);
        interp.variables.set("FlxTrailEffect", FlxTrailEffect);
        interp.variables.set("CustomSpriteGroup", customlize.CustomSpriteGroup);
		interp.variables.set("FlxWaveEffect", FlxWaveEffect);
        interp.variables.set("IFlxEffect", IFlxEffect);
        interp.variables.set("SpectralAnalyzer", funkin.vis.dsp.SpectralAnalyzer);
        interp.variables.set("LimeAudioClip", funkin.vis.audioclip.frontends.LimeAudioClip);
        interp.variables.set("FlxGlitchDirection", FlxGlitchDirection);
        interp.variables.set("FlxOutlineMode", FlxOutlineMode);
        interp.variables.set("FlxWaveMode", FlxWaveMode);
        interp.variables.set("FlxWaveDirection", FlxWaveDirection);
        interp.variables.set("FlxGlitchEffect", FlxGlitchEffect);
        interp.variables.set("StickerSubState", StickerSubState);
        interp.variables.set("ColorSwap", ColorSwap);
        interp.variables.set("Lambda", Lambda);
        interp.variables.set("getSoundChannel", function(soundchannel){
            @:privateAccess
            return soundchannel._channel.__source;
        });
        interp.variables.set("createNewCamera", function(bgColor = null){
         var camera = new FlxCamera();
         if (bgColor != null)
            camera.bgColor = bgColor;
         else
            camera.bgColor.alpha = 0;
            return camera;
        });
        #if flxanimate
        interp.variables.set("FlxAnimate", flxanimate.FlxAnimate);
        interp.variables.set("FlxAnim", flxanimate.animate.FlxAnim);
        interp.variables.set("FlxAtlasSprite", flxanimate.FlxAtlasSprite);
        interp.variables.set("CustomAtlasSprite", customlize.CustomAtlasSprite);
        #end
        interp.variables.set("MathUtil", MathUtil);
        interp.variables.set("RuntimePostEffectShader", RuntimePostEffectShader);
        interp.variables.set("RuntimeRainShader", RuntimeRainShader);
        interp.variables.set("CustomSprite", customlize.CustomSprite);
        interp.variables.set("FlxStarField3D", flixel.addons.display.FlxStarField.FlxStarField3D);
        interp.variables.set("FlxStarField2D", flixel.addons.display.FlxStarField.FlxStarField2D);
        interp.variables.set("Map", haxe.ds.StringMap);
        interp.variables.set("String", String);
        interp.variables.set("FlxColor", CustomFlxColor);
        interp.variables.set("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
        return interp;
        
    }
    public static function addVarsToInterp<T:Interp>(interp:T):T {
        interp.variables.set('pushCameraShader', function(cam,value){
			@:privateAccess
			cam._filters.push(value);
		});
        interp.variables.set("mixTex", function(frames1:FlxAtlasFrames, frames2:FlxAtlasFrames) {
            for (frame in frames2.frames){
                frames1.pushFrame(frame);
            }
            return frames1;
        });
        interp.variables.set("SUtil", SUtil);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("FlxSprite", DynamicSprite);
        interp.variables.set("MetroSprite", MetroSprite);
        interp.variables.set("AttachedSprite", AttachedSprite);
		interp.variables.set("FlxSound", DynamicSound);
		interp.variables.set("FlxAtlasFrames", DynamicSprite.DynamicAtlasFrames);
		interp.variables.set("FlxGroup", flixel.group.FlxGroup);
		interp.variables.set("FlxAngle", flixel.math.FlxAngle);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
		interp.variables.set("TitleState", TitleState);
        #if mobile
        interp.variables.set("FlxActionMode", FlxActionMode);
        interp.variables.set("FlxDPadMode", FlxDPadMode);
        interp.variables.set("FlxVirtualPad", FlxVirtualPad);
        #end

		interp.variables.set("makeRangeArray", CoolUtil.numberArray);
		interp.variables.set("FNFAssets", FNFAssets);
        interp.variables.set("Paths", Paths);
        interp.variables.set("CoolUtil", CoolUtil);
        interp.variables.set("Main", Main);
        interp.variables.set("Reflect", Reflect);
        interp.variables.set("AtlasFrameMaker", AtlasFrameMaker);
        interp.variables.set("FlxCamera", FlxCamera);
        interp.variables.set("Function_Continue", FunkinLua.Function_Continue);
		interp.variables.set("Function_Stop", FunkinLua.Function_Stop);
		interp.variables.set("Function_StopHscript", FunkinLua.Function_StopLua);
        #if VIDEOS_ALLOWED
       // interp.variables.set("MP4Handler", MP4Handler);
        interp.variables.set("FlxVideo", FlxVideo);
        interp.variables.set("FlxVideoSprite", FlxVideoSprite);
#end

		// : )
		interp.variables.set("FlxG", HscriptGlobals);
		interp.variables.set("FlxTimer", flixel.util.FlxTimer);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);

		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("Character", Character);
        interp.variables.set("FlxText", FlxText);
        interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
        #if mobile
        interp.variables.set("FlxActionMode", FlxActionMode);
        interp.variables.set("FlxDPadMode", FlxDPadMode);
        interp.variables.set("FlxVirtualPad", FlxVirtualPad);
        #end
        #if mobile
        interp.variables.set("mobile", true);
#else
interp.variables.set("mobile", false);
#end
#if android
interp.variables.set("android", true);
#else
interp.variables.set("android", false);
#end
        interp.variables.set("FlxBackdrop", FlxBackdrop);
        interp.variables.set("privateAccess", privateAccess);
        interp.variables.set("FlxRect", FlxRect);
        interp.variables.set("FlixG", FlxG);
        interp.variables.set("getAudiosampleRate", getAudiosampleRate);
        interp.variables.set("PluginManager", PluginManager);
        interp.variables.set("callExternClass", instanceExClass); //Call modules?? :D

		interp.variables.set("ModManager", modchart.ModManager);
		interp.variables.set("Modifier", modchart.Modifier);
		interp.variables.set("SubModifier", modchart.SubModifier);
		interp.variables.set("NoteModifier", modchart.NoteModifier);
		interp.variables.set("EventTimeline", modchart.EventTimeline);
		interp.variables.set("StepCallbackEvent", modchart.events.StepCallbackEvent);
		interp.variables.set("CallbackEvent", modchart.events.CallbackEvent);
		interp.variables.set("ModEvent", modchart.events.ModEvent);
		interp.variables.set("EaseEvent", modchart.events.EaseEvent);
		interp.variables.set("SetEvent", modchart.events.SetEvent);
        //interp.variables.set("GitarooPause", GitarooPause);
		#if debug
		interp.variables.set("debug", true);
		#else
		interp.variables.set("debug", false);
		#end
        addingBasicStuffsIthink(interp);
        return interp;
    }
    public static function privateAccess(?funtion:Void->Void = null)
		{
			if (funtion != null){
			@:privateAccess{
			funtion();
            }
			}
		}
            public static function getAudiosampleRate(sound:FlxSound):Int
		{
			@:privateAccess
       return sound._sound.__buffer.sampleRate;
			
		}
    public static function addVarsToInterpEx<T:InterpEx>(interp:T):T {
        interp.variables.set("SUtil", SUtil);
        interp.variables.set('pushCameraShader', function(cam,value){
			@:privateAccess
			cam._filters.push(value);
		});
        interp.variables.set("mixTex", function(frames1:FlxAtlasFrames, frames2:FlxAtlasFrames) {
            for (frame in frames2.frames){
                frames1.pushFrame(frame);
            }
            return frames1;
        });
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("FlxSprite", DynamicSprite);
        interp.variables.set("AttachedSprite", AttachedSprite);
        interp.variables.set("MetroSprite", MetroSprite);
		interp.variables.set("FlxSound", DynamicSound);
		interp.variables.set("FlxAtlasFrames", DynamicSprite.DynamicAtlasFrames);
		interp.variables.set("FlxGroup", flixel.group.FlxGroup);
		interp.variables.set("FlxAngle", flixel.math.FlxAngle);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
        interp.variables.set("getAudiosampleRate", getAudiosampleRate);
		interp.variables.set("TitleState", TitleState);
		interp.variables.set("makeRangeArray", CoolUtil.numberArray);
		interp.variables.set("FNFAssets", FNFAssets);
        interp.variables.set("CoolUtil", CoolUtil);
        interp.variables.set("Main", Main);
        interp.variables.set("AtlasFrameMaker", AtlasFrameMaker);
        interp.variables.set("FlxCamera", FlxCamera);
        interp.variables.set("Reflect", Reflect);
        #if VIDEOS_ALLOWED
       // interp.variables.set("MP4Handler", MP4Handler);
        interp.variables.set("FlxVideo", FlxVideo);
        interp.variables.set("FlxVideoSprite", FlxVideoSprite);
#end
interp.variables.set("Paths", Paths);
		// : )
		interp.variables.set("FlxG", HscriptGlobals);
		interp.variables.set("FlxTimer", flixel.util.FlxTimer);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("Character", Character);
        interp.variables.set("FlxText", FlxText);
        interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
        interp.variables.set("FlxBackdrop", FlxBackdrop);
        interp.variables.set("Function_Continue", FunkinLua.Function_Continue);
        interp.variables.set("Function_Stop", FunkinLua.Function_Stop);
		interp.variables.set("Function_StopHscript", FunkinLua.Function_StopLua);
        interp.variables.set("FlxRect", FlxRect);
        interp.variables.set("FlixG", FlxG);
        interp.variables.set("PluginManager", PluginManager);
        interp.variables.set("Paths", Paths);
        interp.variables.set("callExternClass", instanceExClass); //Call modules?? :D
        interp.variables.set("privateAccess", privateAccess);
        //interp.variables.set("GitarooPause", GitarooPause);
		#if debug
		interp.variables.set("debug", true);
		#else
		interp.variables.set("debug", false);
		#end
        addingBasicStuffsIthink(interp);
        return interp;
    }
}
class HscriptGlobals {
    public static var VERSION = FlxG.VERSION;
    public static var autoPause(get, set):Bool;
    public static var bitmap(get, never):BitmapFrontEnd;
    // no bitmapLog
    public static var camera(get ,set):FlxCamera;
    public static var cameras(get, never):CameraFrontEnd;
    // no console frontend
    // no debugger frontend
    public static var drawFramerate(get, set):Int;
    public static var elapsed(get, never):Float;
    public static var fixedTimestep(get, set):Bool;
    public static var fullscreen(get, set):Bool;
    public static var game(get, never):FlxGame;
    public static var gamepads(get, never):FlxGamepadManager;
    public static var height(get, never):Int;
    public static var initialHeight(get, never):Int;
    public static var initialWidth(get, never):Int;
    public static var initialZoom(get, never):Float;
    public static var inputs(get, never):InputFrontEnd;
    public static var keys(get, never):FlxKeyboard;
    // no log
    public static var maxElapsed(get, set):Float;
    public static var mouse = FlxG.mouse;
    // no plugins
    public static var random= FlxG.random;
    public static var renderBlit(get, never):Bool;
    public static var renderMethod(get, never):FlxRenderMethod;
    public static var renderTile(get, never):Bool;
    // no save because there are other ways to access it and i don't trust you guys
    public static var sound(default, null):HscriptSoundFrontEndWrapper = new HscriptSoundFrontEndWrapper(FlxG.sound);
    public static var stage(get, never):Stage;
    public static var state(get, never):FlxState;
    // no swipes because no mobile : )
    public static var timeScale(get, set):Float;
    // no touch because no mobile : )
    public static var updateFramerate(get,set):Int;
    // no vcr : )
    // no watch : )
    public static var width(get, never):Int;
    public static var worldBounds(get, never):FlxRect;
    public static var worldDivisions(get, set):Int;
    public static function init() {
        sound = new HscriptSoundFrontEndWrapper(FlxG.sound);
    }
    static function get_bitmap() {
        return FlxG.bitmap;
    }
    static function get_cameras() {
        return FlxG.cameras;
    }
    static function get_autoPause():Bool {
        return FlxG.autoPause;
    }
    static function set_autoPause(b:Bool):Bool {
        return FlxG.autoPause = b;
    }
	static function get_drawFramerate():Int
	{
		return FlxG.drawFramerate;
	}

	static function set_drawFramerate(b:Int):Int
	{
		return FlxG.drawFramerate = b;
	}
    static function get_elapsed():Float {
        return FlxG.elapsed;
    }
	static function get_fixedTimestep():Bool
	{
		return FlxG.fixedTimestep;
	}

	static function set_fixedTimestep(b:Bool):Bool
	{
		return FlxG.fixedTimestep = b;
	}
	static function get_fullscreen():Bool
	{
		return FlxG.fullscreen;
	}

	static function set_fullscreen(b:Bool):Bool
	{
		return FlxG.fullscreen = b;
	}
    static function get_height():Int {
        return FlxG.height;
    }
    static function get_initialHeight():Int {
        return FlxG.initialHeight;
    }
    static function get_camera():FlxCamera {
        return FlxG.camera;
    }
    static function set_camera(c:FlxCamera):FlxCamera {
        return FlxG.camera = c;
    }
    static function get_game():FlxGame {
        return FlxG.game;
    }
    static function get_gamepads():FlxGamepadManager {
        return FlxG.gamepads;
    }
    static function get_initialWidth():Int {
        return FlxG.initialWidth;
    }
    static function get_initialZoom():Float {
        return FlxG.initialZoom;
    }
    static function get_inputs() {
        return FlxG.inputs;
    }
    static function get_keys() {
        return FlxG.keys;
    }
    static function set_maxElapsed(s) {
        return FlxG.maxElapsed = s;
    }
    static function get_maxElapsed() {
        return FlxG.maxElapsed;
    }
    static function get_renderBlit() {
        return FlxG.renderBlit;
    }
    static function get_renderMethod() {
        return FlxG.renderMethod;
    }
    static function get_renderTile() {
        return FlxG.renderTile;
    }
    static function get_stage() {
        return FlxG.stage;
    }
    static function get_state() {
        return FlxG.state;
    }
    static function set_timeScale(s) {
        return FlxG.timeScale = s;
    }
    static function get_timeScale() {
        return FlxG.timeScale;
    }
    static function set_updateFramerate(s) {
        return FlxG.updateFramerate = s;
    }
    static function get_updateFramerate() {
        return FlxG.updateFramerate;
    }
    static function get_width() {
        return FlxG.width;
    }
    static function get_worldBounds() {
        return FlxG.worldBounds;
    }
    static function get_worldDivisions() {
        return FlxG.worldDivisions;
    }
	static function set_worldDivisions(s)
	{
		return FlxG.worldDivisions = s;
	}

    public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
        return FlxG.addChildBelowMouse(Child, IndexModifier);
    }
    public static function addPostProcess(postProcess) {
        return FlxG.addPostProcess(postProcess);
    }
    public static function collide(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback) {
        return FlxG.collide(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback);
    }
    // no open url because i don't trust you guys

	public static function overlap(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback, ?ProcessCallback)
	{
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
	}
    public static function pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance = 255, ?Camera) {
        return FlxG.pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance, Camera);
    }
    public static function removeChild<T:DisplayObject>(Child:T):T {
        return FlxG.removeChild(Child);
    }
    public static function removePostProcess(postProcess) {
        FlxG.removePostProcess(postProcess);
    }
    // no reset game or reset state because i don't trust you guys
    public static function resizeGame(Width, Height) {
        FlxG.resizeGame(Width, Height);
    }
    public static function resizeWindow(Width, Height) {
        FlxG.resizeWindow(Width, Height);
    }
    // no switch state because i don't trust you guys
}

class HscriptSoundFrontEndWrapper {

    var wrapping:SoundFrontEnd;
    public var defaultMusicGroup(get, set):FlxSoundGroup;
    public var defaultSoundGroup(get, set):FlxSoundGroup;
    public var list(get, never):FlxTypedGroup<FlxSound>;
    public var music (get, set):FlxSound;
    // no mute keys because why do you need that
    // no muted because i don't trust you guys
    // no soundtray enabled because i'm lazy 
    // no volume because i don't trust you guys
    function get_defaultMusicGroup() {
        return wrapping.defaultMusicGroup;
    }
    function set_defaultMusicGroup(a) {
        return wrapping.defaultMusicGroup = a;
    }
    function get_defaultSoundGroup() {
        return wrapping.defaultSoundGroup;
    }
    function set_defaultSoundGroup(a) {
        return wrapping.defaultSoundGroup = a;
    }
    function get_list() {
        return wrapping.list;
    }
    function get_music() {
        return wrapping.music;
    }
    function set_music(a) {
        return wrapping.music = a;
    }
    public function load(?EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = false, AutoPlay = false, ?URL, ?OnComplete) {
        if ((EmbeddedSound is String)) {
            var sound = FNFAssets.getSound(SUtil.getPath() + EmbeddedSound);
            return wrapping.load(sound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
        }
        return wrapping.load(EmbeddedSound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
    }
    public function pause() {
        wrapping.pause();
    }
    public function play(EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = true, ?OnComplete) {
        if ((EmbeddedSound is String)) {
            var sound = FNFAssets.getSound(SUtil.getPath() + EmbeddedSound);
            return wrapping.play(sound, Volume, Looped, Group, AutoDestroy, OnComplete);
        }
        return wrapping.play(EmbeddedSound, Volume, Looped, Group, AutoDestroy, OnComplete);
    }

    public function playMusic(Music:FlxSoundAsset,Volume= 1.0, Looped = true, ?Group ) {
        if ((Music is String)) {
            var sound = FNFAssets.getSound(Music);
            wrapping.playMusic(sound, Volume, Looped, Group);
            return;
        }
        wrapping.playMusic(Music, Volume, Looped, Group);        

    }
    public function resume() {
        wrapping.resume();
    }
    public function new(wrap:SoundFrontEnd) {
        wrapping = wrap;
    }
}


// stupidity
//from troll engine -https://github.com/riconuts/troll-engine-
class CustomFlxColor
{
	// These aren't part of FlxColor but i thought they could be useful
	// honestly we should replace source/flixel/FlxColor.hx or w/e with one with these funcs
	public static function toRGBArray(color:FlxColor)
		return [color.red, color.green, color.blue];

	public static function lerp(from:FlxColor, to:FlxColor, ratio:Float) // FlxColor.interpolate() exists -_-
		return FlxColor.fromRGBFloat(flixel.math.FlxMath.lerp(from.redFloat, to.redFloat, ratio), flixel.math.FlxMath.lerp(from.greenFloat, to.greenFloat, ratio),
    flixel.math.FlxMath.lerp(from.blueFloat, to.blueFloat, ratio), flixel.math.FlxMath.lerp(from.alphaFloat, to.alphaFloat, ratio));

	////
	public static function get_red(color:FlxColor)
		return color.red;

	public static function get_green(color:FlxColor)
		return color.green;

	public static function get_blue(color:FlxColor)
		return color.blue;

	public static function set_red(color:FlxColor, val)
	{
		color.red = val;
		return color;
	}

	public static function set_green(color:FlxColor, val)
	{
		color.green = val;
		return color;
	}

	public static function set_blue(color:FlxColor, val)
	{
		color.blue = val;
		return color;
	}

	public static function get_rgb(color:FlxColor)
		return color.rgb;

	public static function get_redFloat(color:FlxColor)
		return color.redFloat;

	public static function get_greenFloat(color:FlxColor)
		return color.greenFloat;

	public static function get_blueFloat(color:FlxColor)
		return color.blueFloat;

	public static function set_redFloat(color:FlxColor, val)
	{
		color.redFloat = val;
		return color;
	}

	public static function set_greenFloat(color:FlxColor, val)
	{
		color.greenFloat = val;
		return color;
	}

	public static function set_blueFloat(color:FlxColor, val)
	{
		color.blue = val;
		return color;
	}

	//
	public static function get_hue(color:FlxColor)
		return color.hue;

	public static function get_saturation(color:FlxColor)
		return color.saturation;

	public static function get_lightness(color:FlxColor)
		return color.lightness;

	public static function get_brightness(color:FlxColor)
		return color.brightness;

	public static function set_hue(color:FlxColor, val)
	{
		color.hue = val;
		return color;
	}

	public static function set_saturation(color:FlxColor, val)
	{
		color.saturation = val;
		return color;
	}

	public static function set_lightness(color:FlxColor, val)
	{
		color.lightness = val;
		return color;
	}

	public static function set_brightness(color:FlxColor, val)
	{
		color.brightness = val;
		return color;
	}

	//
	public static function get_cyan(color:FlxColor)
		return color.cyan;

	public static function get_magenta(color:FlxColor)
		return color.magenta;

	public static function get_yellow(color:FlxColor)
		return color.yellow;

	public static function get_black(color:FlxColor)
		return color.black;

	public static function set_cyan(color:FlxColor, val)
	{
		color.cyan = val;
		return color;
	}

	public static function set_magenta(color:FlxColor, val)
	{
		color.magenta = val;
		return color;
	}

	public static function set_yellow(color:FlxColor, val)
	{
		color.yellow = val;
		return color;
	}

	public static function set_black(color:FlxColor, val)
	{
		color.black = val;
		return color;
	}

	//
	public static function getAnalogousHarmony(color:FlxColor)
		return color.getAnalogousHarmony();

	public static function getComplementHarmony(color:FlxColor)
		return color.getComplementHarmony();

	public static function getSplitComplementHarmony(color:FlxColor)
		return color.getSplitComplementHarmony();

	public static function getTriadicHarmony(color:FlxColor)
		return color.getTriadicHarmony();

	public static function getDarkened(color:FlxColor)
		return color.getDarkened();

	public static function getInverted(color:FlxColor)
		return color.getInverted();

	public static function getLightened(color:FlxColor)
		return color.getLightened();

	public static function to24Bit(color:FlxColor)
		return color.to24Bit();

	public static function getColorInfo(color:FlxColor)
		return color.getColorInfo;

	public static function toHexString(color:FlxColor)
		return color.toHexString();

	public static function toWebString(color:FlxColor)
		return color.toWebString();

	//
	public static final fromCMYK = FlxColor.fromCMYK;
	public static final fromHSL = FlxColor.fromHSL;
	public static final fromHSB = FlxColor.fromHSB;
	public static final fromInt = FlxColor.fromInt;
	public static final fromRGBFloat = FlxColor.fromRGBFloat;
	public static final fromString = FlxColor.fromString;
	public static final fromRGB = FlxColor.fromRGB;

	public static final getHSBColorWheel = FlxColor.getHSBColorWheel;
	public static final interpolate = FlxColor.interpolate;
	public static final gradient = FlxColor.gradient;

	public static final TRANSPARENT:Int = FlxColor.TRANSPARENT;
	public static final BLACK:Int = FlxColor.BLACK;
	public static final WHITE:Int = FlxColor.WHITE;
	public static final GRAY:Int = FlxColor.GRAY;

	public static final GREEN:Int = FlxColor.GREEN;
	public static final LIME:Int = FlxColor.LIME;
	public static final YELLOW:Int = FlxColor.YELLOW;
	public static final ORANGE:Int = FlxColor.ORANGE;
	public static final RED:Int = FlxColor.RED;
	public static final PURPLE:Int = FlxColor.PURPLE;
	public static final BLUE:Int = FlxColor.BLUE;
	public static final BROWN:Int = FlxColor.BROWN;
	public static final PINK:Int = FlxColor.PINK;
	public static final MAGENTA:Int = FlxColor.MAGENTA;
	public static final CYAN:Int = FlxColor.CYAN;
}
package customlize;
#if flxanimate
import flixel.FlxSprite;
import flixel.util.FlxSignal;
import flxanimate.FlxAtlasSprite;
import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;
import flxanimate.FlxAnimate.Settings;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import hscript.Expr;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import lime.system.System;
import flixel.FlxSprite;
import flixel.FlxCamera;
import lime.utils.Assets;
import Section.SwagSection;
import flixel.system.FlxSound;
import Song.SwagSong;
import flixel.FlxBasic;
import openfl.geom.Matrix;
import flixel.FlxGame;
import flixel.graphics.FlxGraphic;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrailArea;
import openfl.filters.ShaderFilter;
import flixel.math.FlxPoint;
import flash.geom.Rectangle;
import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import haxe.Json;
import openfl.events.IOErrorEvent;
import flixel.util.FlxSort;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxAxes;
import haxe.io.Bytes;
import flixel.ui.FlxSpriteButton;
import haxe.format.JsonParser;
import flixel.animation.FlxAnimation;
import lime.utils.UInt8Array;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

#if desktop
import Sys;
import sys.FileSystem;
#end

#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import Song.SwagSong;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end

import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;

import openfl.net.FileReference;
import flixel.util.FlxStringUtil;
import flixel.addons.text.FlxTypeText;
import flixel.input.FlxKeyManager;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
#if desktop
import Discord.DiscordClient;
#end
import lime.app.Application;
import openfl.Lib;
import lime.system.Clipboard;
import flixel.addons.ui.FlxUIState;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import flixel.addons.editors.pex.FlxPexParser;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import haxe.Json;
import tjson.TJSON;
using StringTools;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
#if VIDEOS_ALLOWED
import hxcodec.flixel.FlxVideo as FlxVideo;
#end


class CustomAtlasSprite extends flxanimate.FlxAtlasSprite
{
  public var interp:Interp = new Interp();
  public static var instance:CustomAtlasSprite;
  // playAnim stolen from Character.hx, cuz im lazy lol!
  // TODO: Switch this class to use SwagSprite instead.
  public var animOffsets:Map<String, Array<Dynamic>>;

  public function new(x:Float, y:Float,hscriptPath:String,args:Array<Dynamic>)
  {
    instance = this;
    animOffsets = new Map<String, Array<Dynamic>>();

    anim.callback = function(name, number) {
      switch (name)
      {

        default:
      }
    };
    anim.onComplete = onFinishAnim;

    if (hscriptPath != null && hscriptPath != '')
      interp = initHScript(hscriptPath);
  callInterp("init", args);
  callInterp("onCreate", args);
    super(x, y);

  
  }

  public function initHScript(name:String){
    var interp = PluginManager.createSimpleInterp();
var parser = new hscript.Parser();
var program:Expr = null;
    if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
    if (FNFAssets.exists(SUtil.getPath() + 'mods'+Paths.currentModDirectory + '/scripts/custom_sprites/atlas/' + name, Hscript))
  program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + 'mods'+Paths.currentModDirectory + '/scripts/custom_sprites/atlas/' + name));

    if (FNFAssets.exists(SUtil.getPath() + 'mods/scripts/custom_sprites/' + name, Hscript))
  program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + 'mods/scripts/custom_sprites/atlas/' + name));
    
    if (FNFAssets.exists(SUtil.getPath() + 'windose_data/scripts/custom_sprites/' + name, Hscript))
  program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + 'windose_data/scripts/custom_sprites/atlas/' + name));

   

   

    interp.variables.set("angle", angle);
    interp.variables.set("x", x);
    interp.variables.set("y", y);
    interp.variables.set("color", color);
    interp.variables.set("pixels", pixels);
    interp.variables.set("frame", frame);
    interp.variables.set("frameWidth", frameWidth);
    interp.variables.set("frameHeight", frameHeight);
    interp.variables.set("numFrames", numFrames);
    interp.variables.set("frames", frames);
    interp.variables.set("graphic", graphic);
    interp.variables.set("bakedRotationAngle", bakedRotationAngle);
    interp.variables.set("alpha", alpha);
    interp.variables.set("facing", facing);
    interp.variables.set("flipX", flipX);
    interp.variables.set("flipY", flipY);
    interp.variables.set("origin", origin);
    interp.variables.set("offset", offset);
    interp.variables.set("scale", scale);
    interp.variables.set("this", this);
    interp.variables.set("blend", blend);
    interp.variables.set("colorTransform", colorTransform);
    interp.variables.set("useColorTransform", useColorTransform);
    interp.variables.set("clipRect", clipRect);
    interp.variables.set("addOffset", addOffset);
    interp.variables.set("anim", anim);
    interp.variables.set("shader", shader);
    interp.variables.set("pixels", pixels);
    interp.variables.set("dirty", dirty);
    interp.variables.set("antialiasing", antialiasing);
    interp.variables.set("useFramePixels", useFramePixels);
    interp.variables.set("framePixels", framePixels);
    interp.variables.set("animation", animation);
    interp.variables.set("listAnimations", listAnimations);

    interp.variables.set("onAnimationFinish", onAnimationFinish);
    interp.variables.set("initHScript", initHScript);
    interp.variables.set("currentAnimation", currentAnimation);
interp.execute(program);
trace(interp);
return interp;
}
public function callInterp(func_name:String, args:Array<Dynamic>) {
  if (interp == null) return;
  if (!interp.variables.exists(func_name)) return;
  var method = interp.variables.get(func_name);
      Reflect.callMethod(null,method,args);
}
  override public function listAnimations():Array<String>
  {
    var anims:Array<String> = [];
    @:privateAccess
    for (animKey in anim.symbolDictionary)
    {
      anims.push(animKey.name);
    }
    return anims;
  }

  override public function playAnimation(id:String, restart:Bool = false, ignoreOther:Bool = false, ?loop:Bool = false):Void
    {
      callInterp("playAnimation", [id,restart,ignoreOther,loop]);
        super.playAnimation(id,restart,ignoreOther,loop);
    }
  override public function destroy():Void
    {
        callInterp("destroy", []);
        super.destroy();
    }
    override public function loadAtlas(path:String)
      {
          callInterp("loadAtlas", [path]);
          super.loadAtlas(path);
      }
      override public function loadAtlasEx(img:FlxGraphicAsset, pathOrStr:String = null, myJson:Dynamic = null)
        {
            callInterp("loadAtlasEx", [img,pathOrStr,myJson]);
            super.loadAtlasEx(img,pathOrStr,myJson);
        }
  public override function update(elapsed:Float):Void
  {
    callInterp("update", [elapsed]);
    super.update(elapsed);
  }
  public override function updateAnimation(elapsed:Float):Void
    {
      callInterp("updateAnimation", [elapsed]);
      super.updateAnimation(elapsed);
    }
  function onFinishAnim():Void
  {
    var name = anim.curSymbol.name;
    callInterp("onFinishAnim", [name]);
  }

	override public function setTheSettings(?Settings:Settings):Void
    {
      callInterp("setTheSettings", [Settings]);
      super.setTheSettings(Settings);
    }
  

  public inline function addOffset(name:String, x:Float = 0, y:Float = 0)
  {
    animOffsets[name] = [x, y];
  }

  override public function getCurrentAnimation():String
  {
    if (this.anim == null || this.anim.curSymbol == null) return "";
    return this.anim.curSymbol.name;
  }

  public function playAnim(id:String, ?Force:Bool = false, ?Reverse:Bool = false, ?Frame:Int = 0):Void
  {
    anim.play(id, Force, Reverse, Frame);
    applyAnimOffset();
  }

  function applyAnimOffset()
  {
    var AnimName = getCurrentAnimation();
    var daOffset = animOffsets.get(AnimName);
    if (animOffsets.exists(AnimName))
    {
      var xValue = daOffset[0];
      var yValue = daOffset[1];

      offset.set(xValue, yValue);
    }
    else
    {
      offset.set(0, 0);
    }
  }

}
#end
package;

import flixel.util.FlxTimer.FlxTimerManager;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxStrip;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import openfl.geom.Vector3D;
import flixel.util.FlxSpriteUtil;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxCamera;
import math.*;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.util.FlxSort;
import openfl.Vector;
import openfl.geom.ColorTransform;
import openfl.display.Shader;
import flixel.graphics.FlxGraphic;
import modchart.ModManager;
import flixel.system.FlxAssets.FlxShader;


import PlayState;
import Note;
import StrumNote;

using StringTools;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic.IFlxBasic;
import flixel.animation.FlxAnimationController;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;

using flixel.util.FlxColorTransformUtil;

class StrumLine extends FlxSprite
{
    public var strumGroup:FlxTypedGroup<StrumNote>;
    public var notes:FlxTypedGroup<Note>;
    public var curSplash:FlxTypedGroup<NoteSplash> = null;
    public var drawQueue:Array<FlxSprite> = [];
    public function new(daStrumGroup:FlxTypedGroup<StrumNote>, daNotes:FlxTypedGroup<Note>,splashes:FlxTypedGroup<NoteSplash>=null)
    {
        super(0,0);
        strumGroup = daStrumGroup;
        notes = daNotes;
        if (splashes != null){
            curSplash = splashes;
            splashes.visible = false;
        }
        daStrumGroup.visible = false;
        daNotes.visible = false;
    }

    override function update(elapsed:Float) 
    {
       preDraw();
        super.update(elapsed);
    }
    function preDraw(){
        if (!active || !exists) return;
        try {
         
        
        drawQueue = [];
        for (strum in strumGroup.members){
            drawQueue.push(strum);
            strum.cameras = this.cameras;
        }
        for (note in notes.members){
            if (note !=null && note.alive){
            drawQueue.push(note);
            note.cameras = this.cameras;
            }
        }
        for (spla in curSplash.members){
            if (spla !=null && spla.alive){
            drawQueue.push(spla);
            spla.cameras = this.cameras;
            }
        }
    }
        catch(e) {
            trace(e);
        }
    }

    override public function draw()
    {
        if (alpha == 0 || !visible)
            return;

      
        try {
         
         for (stuff in drawQueue){
            if (stuff !=null){
            @:privateAccess
            stuff.checkEmptyFrame();
            @:privateAccess
            if (stuff.alpha == 0 || stuff._frame.type == FlxFrameType.EMPTY)
                return;
    
            if (stuff.dirty) // rarely
                @:privateAccess    stuff.calcFrame(stuff.useFramePixels);
    
            for (camera in cameras)
            {
                if (!camera.visible || !camera.exists || !stuff.isOnScreen(camera))
                    continue;
           
               var off = new FlxPoint(0,0);
               off.set(stuff.offset.x+offset.x+x,stuff.offset.y+offset.y+y);
               // trace(p);
                stuff.getScreenPosition(stuff._point, camera).subtractPoint(off);
                @:privateAccess{
                if (stuff.isSimpleRender(camera))
                    drawObjectSimple(camera,stuff);
                else
                    drawObjectComplex(camera,stuff);
            }
                #if FLX_DEBUG
                FlxBasic.visibleCount++;
                #end
            }
     
    
            #if FLX_DEBUG
            if (FlxG.debugger.drawDebug)
                stuff.drawDebug();
            #end
         
        }
      
        }
        } catch(e) {
           // trace(e);
        }
        //draw notes to screen
    }
    public function copyStrumLine():StrumLine
        {
           var newStrum = new StrumLine(this.strumGroup,this.notes,this.curSplash);
           newStrum.cameras = this.cameras;
            return newStrum;
        }/*
        override function set_color(color:FlxColor):Int
        {
           
            for (stuff in drawQueue){
                if (stuff !=null){
                    var r = stuff.colorTransform.redMultiplier * this.color.redFloat;
                    var g = stuff.colorTransform.greenMultiplier * this.color.greenFloat;
                    var b = stuff.colorTransform.blueMultiplier * this.color.blueFloat;
                    var a = stuff.colorTransform.alphaMultiplier * this.alpha;
                    stuff.setColorTransform(r,g,b,a);
            }
        }
        return super.set_color(color);
    }
    override function set_alpha(Alpha:Float):Float
        {
            
            for (stuff in drawQueue){
                if (stuff !=null){
           // if (stuff.useColorTransform){
            var r = stuff.colorTransform.redMultiplier * this.color.redFloat;
            var g = stuff.colorTransform.greenMultiplier * this.color.greenFloat;
            var b = stuff.colorTransform.blueMultiplier * this.color.blueFloat;
            var a = stuff.colorTransform.alphaMultiplier * this.alpha;
                stuff.setColorTransform(r,g,b,a);
              //  }
            }
        }
        return super.set_alpha(Alpha);
    }*/
    @:noCompletion
	function drawObjectSimple(camera:FlxCamera,obj:FlxSprite):Void
	{
        var transfarm:ColorTransform = new ColorTransform();
        transfarm.redMultiplier = (obj.colorTransform.redMultiplier + this.colorTransform.redMultiplier)/2;
        transfarm.greenMultiplier = (obj.colorTransform.greenMultiplier + this.colorTransform.greenMultiplier)/2;
        transfarm.blueMultiplier = (obj.colorTransform.blueMultiplier + this.colorTransform.blueMultiplier)/2;
        transfarm.redOffset = (obj.colorTransform.redOffset + this.colorTransform.redOffset)/2;
        transfarm.greenOffset = (obj.colorTransform.greenOffset + this.colorTransform.greenOffset)/2;
        transfarm.blueOffset = (obj.colorTransform.blueOffset + this.colorTransform.blueOffset)*2;
        transfarm.alphaOffset = (obj.colorTransform.alphaOffset + this.colorTransform.blueOffset)*2;
        transfarm.alphaMultiplier = obj.colorTransform.alphaMultiplier * this.alpha;
        @:privateAccess{
		if (obj.isPixelPerfectRender(camera))
			obj._point.floor();

		obj._point.copyToFlash(obj._flashPoint);
		camera.copyPixels(obj._frame, obj.framePixels, obj._flashRect, obj._flashPoint, transfarm, obj.blend, obj.antialiasing);
}
	}

	@:noCompletion
	function drawObjectComplex(camera:FlxCamera,obj:FlxSprite):Void
	{
        var transfarm:ColorTransform = new ColorTransform();
        transfarm.redMultiplier = (obj.colorTransform.redMultiplier + this.colorTransform.redMultiplier)/2;
        transfarm.greenMultiplier = (obj.colorTransform.greenMultiplier + this.colorTransform.greenMultiplier)/2;
        transfarm.blueMultiplier = (obj.colorTransform.blueMultiplier + this.colorTransform.blueMultiplier)/2;
        transfarm.redOffset = (obj.colorTransform.redOffset + this.colorTransform.redOffset)/2;
        transfarm.greenOffset = (obj.colorTransform.greenOffset + this.colorTransform.greenOffset)/2;
        transfarm.blueOffset = (obj.colorTransform.blueOffset + this.colorTransform.blueOffset)*2;
        transfarm.alphaOffset = (obj.colorTransform.alphaOffset + this.colorTransform.blueOffset)*2;
        transfarm.alphaMultiplier = obj.colorTransform.alphaMultiplier * this.alpha;
        @:privateAccess{
            obj._frame.prepareMatrix(obj._matrix, FlxFrameAngle.ANGLE_0, obj.checkFlipX(), obj.checkFlipY());
            obj._matrix.translate(-obj.origin.x, -obj.origin.y);
            obj._matrix.scale(obj.scale.x, obj.scale.y);

		if (obj.bakedRotationAngle <= 0)
		{
			obj.updateTrig();

			if (obj.angle != 0)
				obj._matrix.rotateWithTrig(obj._cosAngle, obj._sinAngle);
		}

		obj._point.add(obj.origin.x, obj.origin.y);
		obj._matrix.translate(obj._point.x, obj._point.y);

		if (obj.isPixelPerfectRender(camera))
		{
			obj._matrix.tx = Math.floor(obj._matrix.tx);
			obj._matrix.ty = Math.floor(obj._matrix.ty);
		}

		camera.drawPixels(obj._frame, obj.framePixels, obj._matrix, transfarm, obj.blend, obj.antialiasing, obj.shader);
	}
}
}

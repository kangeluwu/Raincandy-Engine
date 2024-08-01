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

import PlayState;
import Note;
import StrumNote;

using StringTools;

class StrumLine extends FlxSprite
{
    public var strumGroup:FlxTypedGroup<StrumNote>;
    public var notes:FlxTypedGroup<Note>;
    public function new(strumGroup:FlxTypedGroup<StrumNote>, notes:FlxTypedGroup<Note>) 
    {
        super(0,0);
        this.strumGroup = strumGroup;
        this.notes = notes;
        strumGroup.visible = false;
        notes.visible = false;
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
    }


    override public function draw()
    {
        if (alpha == 0 || !visible)
            return;

        strumGroup.cameras = cameras;
        notes.cameras = cameras;
        
        try {
            for (strum in strumGroup.members){
                strum.alpha *= alpha;
                strum.draw();
            }
            for (note in notes.members){
                if (note!=null && note.alive){
                note.alpha *= alpha;
                note.draw();
                }
            }
        } catch(e) {
            trace(e);
        }
        //draw notes to screen
    }

   

}

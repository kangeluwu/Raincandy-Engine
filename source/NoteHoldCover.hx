package;
//VICEVERSA SUSTAIN NOTE SPLASHES LOL
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import math.*;
import flixel.math.FlxPoint;
using StringTools;
import flixel.addons.effects.FlxSkewedSprite;
class NoteHoldCover extends FlxSprite
{
	public var names:Array<String> = ['Purple','Blue','Green','Red'];
	public var colorSwap:ColorSwap;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var angleAdd:Float = 0;
	public var sprTracker:FlxSprite;
	public var noteData:Int = 0;
	public var resetAnim:Float = 0;
	public var playHoldEnd:Bool = false;
	public var started:Bool = false;
	public function new(?X:Float = 0, ?Y:Float = 0,noteNum:Int = 0)
		{
          super(X,Y);
		  noteData = noteNum;
		  reloadHold();
		  antialiasing = ClientPrefs.globalAntialiasing;
		}
	public function setHoldPos(daNote:StrumNote = null){
		if (daNote!=null){
		sprTracker = daNote;
        xAdd = -Note.swagWidth * 0.95;
        yAdd = -Note.swagWidth + 14;

        colorSwap = new ColorSwap();
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
        shader = colorSwap.shader;
		}
	}
	public function reloadHold(texture:String = '')
		{
			frames = Paths.getSparrowAtlas(texture + 'holdCover' + names[noteData]);
			animation.addByPrefix('start', 'holdCoverStart' + names[noteData],24,false);
			animation.addByPrefix('covering', 'holdCover' + names[noteData] + '0',24,true);
			animation.addByPrefix('end', 'holdCoverEnd' + names[noteData],24,false);
			animation.play('start');
			updateHitbox();
			alpha = 0.000001;
			animation.finishCallback = function (name){
				if (name == 'start'){
					animation.play('covering',true);
                }
                if (name == 'end'){
                    alpha = 0.0001;
                }
                };
		}
		
	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				if (playHoldEnd){
				animation.play('end');
				}
				else 
				alpha = 0.0001;
				resetAnim = 0;
				playHoldEnd = false;
				started = false;
			}
		}
		centerOrigin();
		if (sprTracker != null) {
		setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
		scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);
		}
		super.update(elapsed);
	}

}

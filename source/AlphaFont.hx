package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flash.media.Sound;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
class AlphaFont extends FlxText
{

    public var delay:Float = 0.05;
	public var paused:Bool = false;
	public var itemType:String = "Classic";
	// for menu shit
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;
    public var yMulti:Float = 1;
    
	public var isStepped:Bool = true;
	public var isWheel:Bool = false;
	public var groupX:Float = 90;
	public var groupY:Float = 0.48;
    public function new(x:Float, y:Float, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true,itemType:String = 'Classic')
        {
            super(x, y, fieldWidth, text, size, embeddedFont);
            this.itemType = itemType;
            forceX = Math.NEGATIVE_INFINITY;
        }
        override function update(elapsed:Float)
            {
                if (isMenuItem)
                    {
                        var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
            
                        var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
            
                        switch (itemType) {
                            case "Classic":
                                y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * groupY) + yAdd, lerpVal);
                                if(forceX != Math.NEGATIVE_INFINITY) {
                                    x = forceX;
                                } else {
                                    x = FlxMath.lerp(x, (targetY * 20) + groupX + xAdd, lerpVal);
                                }
                            case "Vertical":
                                y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.5) + yAdd, lerpVal);
                                // x = FlxMath.lerp(x, (targetY * 0) + 308, 0.16 / 2);
                            case "C-Shape":
                                // not actually a wheel, just trying to imitate mic'd up
                                // use exponent because circles????
                                // using equation of a sideways parabola.
                                // x = a(y-k)^2 + h
                                // k is probably inaccurate because, well, the coordinate system
                                // is flipped veritcally.
                                // We still use lerp as that just makes it move smoothly.
                                // I'm going to add instead and see how that works.
            
                                // :grief: i give up time to steal code
                                y = FlxMath.lerp(y, (scaledY * 65) + (FlxG.height * 0.39) + yAdd, lerpVal);
            
                                x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1) + xAdd, lerpVal);
                                if (scaledY < 0)
                                    x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1) + xAdd, lerpVal);
            
                                if (x > FlxG.width + 30 + xAdd)
                                    x = FlxG.width + 30 + xAdd;
            
                            case "D-Shape":
                                y = FlxMath.lerp(y, (scaledY * 90) + (FlxG.height * 0.45) + yAdd,lerpVal);
            
                                x = FlxMath.lerp(x, Math.exp(Math.abs(scaledY * 0.8)) * -70 + (FlxG.width * 0.35) + xAdd, lerpVal);
            
                                if (x < -900 + xAdd)
                                    x = -900 + xAdd;
                        }
                    }
                super.update(elapsed);
            }
}
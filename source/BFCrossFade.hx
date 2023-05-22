package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.animation.FlxAnimation;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flash.display.BitmapData;
import flash.display.BlendMode;
class BFCrossFade extends FlxSprite
{ 
    public var duration:Float = 0.75;
    public function new(character:Boyfriend, group:FlxTypedGroup<BFCrossFade>, ?isDad:Bool = false)
    {
        blend = "add";
        super();
        frames = character.frames;
		alpha = 1;
		setGraphicSize(Std.int(character.width), Std.int(character.height));
		scrollFactor.set(character.scrollFactor.x,character.scrollFactor.y);
		updateHitbox();
		flipX = character.flipX;
		flipY = character.flipY;
		
				x = character.x + FlxG.random.float(0,60);
				y = character.y + FlxG.random.float(-50, 50);

		offset.x = character.offset.x;
		offset.y = character.offset.y; 
		animation.add('cur', character.animation.curAnim.frames, 24, false);
		animation.play('cur', true);
        animation.curAnim.curFrame = character.animation.curAnim.curFrame;

			switch(character.curCharacter)
			{
				case 'gf-pixel':
					color = 0xFFa5004d;
					antialiasing = false;
				case 'monster' | 'monster-christmas':
					color = 0xFF981b3a;
					antialiasing = FlxG.save.data.globalAntialiasing;
				case 'bf' | 'bf-car' | 'bf-christmas':
					color = 0xFF1b008c;
					antialiasing = FlxG.save.data.globalAntialiasing;
				case 'bf-pixel':
					color = 0xFF00368c;
					antialiasing = false;
				case 'senpai' | 'senpai-angry':
					color = 0xFFffaa6f;
					antialiasing = false;
                    default:
                        color = FlxColor.fromRGB(character.healthColorArray[0], character.healthColorArray[1], character.healthColorArray[2]);
                        color = FlxColor.subtract(color, 0x00333333);
                        antialiasing = FlxG.save.data.globalAntialiasing;
						}

					antialiasing = FlxG.save.data.globalAntialiasing;
	
		var fuck = FlxG.random.bool(70);
		
		var velo = 12 * 5;
		
				if (isDad) {
					if (fuck) velocity.x = -velo;
					else velocity.x = velo;
				}
				else {
					if (fuck) velocity.x = velo;
					else velocity.x = -velo;
				}	
		
	
		FlxTween.tween(this, {alpha: 0}, duration, {
			onComplete: function(twn:FlxTween)
			{
				kill();
				destroy();
			}
		});

		group.add(this);
    }
}
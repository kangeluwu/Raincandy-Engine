package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;
import flixel.FlxSprite;
class AccelModifier extends NoteModifier { // this'll be boost in ModManager
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }

	override function getName()
		return 'boost';

  override function getPos(time:Float, visualDiff:Float, timeDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite){
    var wave = getSubmodValue("wave",player);
    var brake = getSubmodValue("brake",player);
    var boost = getValue(player);
    var effectHeight = 500;

    var yAdjust:Float = 0;
		var reverse:Dynamic = modMgr.register.get("reverse");
		var reversePercent = reverse.getReverseValue(data,player);
    var mult = CoolUtil.scale(reversePercent,0,1,1,-1);

    if(brake!=0){
      var scale = CoolUtil.scale(visualDiff, 0, effectHeight, 0, 1);
      var off = visualDiff * scale;
      yAdjust += CoolUtil.clamper(brake * (off - visualDiff),-400,400);
    }

    if(boost!=0){
      //((fYOffset+fEffectHeight/1.2f)/fEffectHeight);
      var off = visualDiff * 1.5 / ((visualDiff + effectHeight/1.2)/effectHeight);
      yAdjust += CoolUtil.clamper(boost * (off - visualDiff),-400,400);
    }

    yAdjust += wave * 20 * FlxMath.fastSin(visualDiff/38);

    pos.y += yAdjust * mult;
    return pos;
  }

  override function getSubmods(){
    var subMods:Array<String> = ["brake","wave"];
    return subMods;
  }
}

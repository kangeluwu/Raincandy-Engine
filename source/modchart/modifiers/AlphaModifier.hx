package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;
import modchart.Modifier.RenderInfo; 
import flixel.FlxG;
class AlphaModifier extends NoteModifier {
	override function getName()
		return 'stealth';

	override function ignorePos()
		return true;

  public static var fadeDistY = 120;

  public function getHiddenSudden(player:Int=-1){
    return getSubmodValue("hidden",player) * getSubmodValue("sudden",player);
  }

  public function getHiddenEnd(player:Int=-1){
    return (FlxG.height* 0.5) + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,-1,-1.25) + (FlxG.height* 0.5) * getSubmodValue("hiddenOffset",player);
  }

  public function getHiddenStart(player:Int=-1){
    return (FlxG.height* 0.5) + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,0,-0.25) + (FlxG.height* 0.5) * getSubmodValue("hiddenOffset",player);
  }

  public function getSuddenEnd(player:Int=-1){
    return (FlxG.height* 0.5) + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,1,1.25) + (FlxG.height* 0.5) * getSubmodValue("suddenOffset",player);
  }

  public function getSuddenStart(player:Int=-1){
    return (FlxG.height* 0.5) + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,0,0.25) + (FlxG.height* 0.5) * getSubmodValue("suddenOffset",player);
  }

  function getVisibility(yPos:Float,player:Int,note:Note):Float{
    var distFromCenter = yPos;
    var alpha:Float = 0;

    if((yPos-50)<0 && getSubmodValue("stealthPastReceptors", player)==0)
      return 1.0;


    var time = Conductor.songPosition/1000;

    if(getSubmodValue("hidden",player)!=0){
      var hiddenAdjust = CoolUtil.clamper(CoolUtil.scale(yPos,getHiddenStart(player),getHiddenEnd(player),0,-1),-1,0);
      alpha += getSubmodValue("hidden",player)*hiddenAdjust;
    }

    if(getSubmodValue("sudden",player)!=0){
      var suddenAdjust = CoolUtil.clamper(CoolUtil.scale(yPos,getSuddenStart(player),getSuddenEnd(player),0,-1),-1,0);
      alpha += getSubmodValue("sudden",player)*suddenAdjust;
    }

    if(getValue(player)!=0)
      alpha -= getValue(player);


    if(getSubmodValue("blink",player)!=0){
      var f = CoolUtil.quantizeAlpha(FlxMath.fastSin(time*10),0.3333);
      alpha += CoolUtil.scale(f,0,1,-1,0);
    }

    if(getSubmodValue("randomVanish",player)!=0){
      var realFadeDist:Float = 240;
      // TODO: make this randomize the notes
      alpha += CoolUtil.scale(Math.abs(distFromCenter),realFadeDist,2*realFadeDist,-1,0)*getSubmodValue("randomVanish",player);
    }

    return CoolUtil.clamper(alpha+1,0,1);
  }

  function getGlow(visible:Float){
    var glow = CoolUtil.scale(visible, 1, 0.5, 0, 1.3);
    return CoolUtil.clamper(glow,0,1);
  }

  function getAlpha(visible:Float){
    var alpha = CoolUtil.scale(visible, 0.5, 0, 1, 0);
    return CoolUtil.clamper(alpha,0,1);
  }

  override function shouldExecute(player:Int, val:Float)return true;
	override function ignoreUpdateReceptor()return false;
	override function ignoreUpdateNote()return false;
	override function isRenderMod()return false;

	override function updateNote(beat:Float, note:Note, pos:Vector3, player:Int){
    @:privateAccess
		var pos = modMgr.getPos(note.strumTime, modMgr.getVisPos(Conductor.songPosition, note.strumTime, PlayState.instance.songSpeed),
			note.strumTime - Conductor.songPosition,
			PlayState.instance.curDecBeat, note.noteData,
			player, note, ["reverse", "receptorScroll", "transformY"]);
    var speed = PlayState.instance.songSpeed * note.multSpeed;
		var yPos:Float = modMgr.getVisPos(Conductor.songPosition, note.strumTime, speed) + 50;


		note.colorSwap.flash = 0;
		var alphaMod = (1 - getSubmodValue("alpha", player)) * (1 - getSubmodValue('alpha${note.noteData}', player)) * (1 - getSubmodValue("noteAlpha", player)) * (1 - getSubmodValue('noteAlpha${note.noteData}', player));
		var alpha = getVisibility(yPos,player,note);

    if(getSubmodValue("dontUseStealthGlow",player)==0){
			note.alphaMod = getAlpha(alpha);
			note.colorSwap.flash = getGlow(alpha);
    }else
			note.alphaMod = alpha;
    
    
		note.alphaMod *= alphaMod;	
    
  }

  override function updateReceptor(beat:Float, receptor:StrumNote, pos:Vector3, player:Int){
		var alpha = (1 - getSubmodValue("alpha", player)) * (1 - getSubmodValue('alpha${receptor.noteData}', player));
		if (getSubmodValue("dark", player) != 0 || getSubmodValue('dark${receptor.noteData}',player)!=0){
			alpha = alpha * (1 - getSubmodValue("dark", player)) * (1 - getSubmodValue('dark${receptor.noteData}',player));
    }
		receptor.colorSwap.daAlpha = alpha;

  }
/*
  override function getExtraInfo(time:Float, diff:Float, tDiff:Float, beat:Float, info:RenderInfo, obj:flixel.FlxSprite, player:Int, data:Int):RenderInfo
    {
      var alpha:Float = info.alpha;
      if (Std.isOfType(obj,Note)){
        var note:Note = cast obj;
        var yPos:Float = 50 + diff;
  
        var alphaMod = 
        (1 - getSubmodValue("alpha",player)) * (1 - getSubmodValue('alpha${note.noteData}',player)) * (1 - getSubmodValue("noteAlpha", player))* (1 - getSubmodValue('noteAlpha${note.noteData}', player));
        var vis = getVisibility(yPos, player, note);
  
        if (getSubmodValue("dontUseStealthGlow", player) == 0)
        {
          alpha *= getAlpha(vis);
          info.glow = getGlow(vis);
        }
        else
          alpha *= vis;
  
        alpha *= alphaMod;	
      }
      else if (Std.isOfType(obj,StrumNote)){
        var receptor:StrumNote = cast obj;
        alpha *= (1 - getSubmodValue("alpha", player)) * (1 - getSubmodValue('alpha${receptor.noteData}', player));
  
        if (getSubmodValue("dark", player) != 0 || getSubmodValue('dark${receptor.noteData}', player) != 0)
        {
          var vis = (1 - getSubmodValue("dark", player)) * (1 - getSubmodValue('dark${receptor.noteData}', player));
          if (getSubmodValue("hideDarkGlow", player) == 0)
          {
            alpha *= getAlpha(vis);
            info.glow = getGlow(vis);
          }else
            alpha *= vis;
        }
      }else 
        alpha *= (1 - getSubmodValue("alpha", player)) * (1 - getSubmodValue('alpha${data}', player));
          
      
  
      info.alpha = alpha;
  
      return info;
    }
*/
  override function getSubmods(){
    var subMods:Array<String> = ["noteAlpha", "alpha", "hidden","hiddenOffset","sudden","suddenOffset","blink","randomVanish","dark", "hideDarkGlow","dontUseStealthGlow","stealthPastReceptors"];
    for(i in 0...4){
			subMods.push('noteAlpha$i');
			subMods.push('alpha$i');
			subMods.push('dark$i');
    }
    return subMods;
  }
}

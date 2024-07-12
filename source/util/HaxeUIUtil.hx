package util;

import haxe.ui.tooltips.ToolTipRegionOptions;

class HaxeUIUtil
{
  public static function buildTooltip(text:String, ?left:Float, ?top:Float, ?width:Float, ?height:Float):ToolTipRegionOptions
  {
    return {
      tipData: {text: text},
      left:  if (left == null ) [] else 0.0,
      top:if (top == null ) [] else 0.0,
      width: if (width == null ) [] else 0.0,
      height: if (height == null ) [] else 0.0
    }
  }
}

import flixel.FlxSprite;
class CustomSprite extends DynamicSprite
{
    public var variables:Map<String,Dynamic>;
    override public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset,args:Array<Dynamic>)
        {
            super(x,y,simpleGraphic);
            
            var func = variables.get("create");
            if (args == null)
                func();
            else
            Reflect.callMethod(null,func,args);
        }

}
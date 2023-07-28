import flixel.FlxSprite;

// the thing that pops up when you hit a note
typedef TUI = {
	var uses:String;
};
class Judgement extends FlxSprite {
	public static var uiJson:Dynamic;
    public function new(X:Float, Y:Float, Judged:String, Display:String, early:Bool, isPixel:Bool) {
        super(X, Y);
		var curUItype:TUI = Reflect.field(uiJson, PlayState.SONG.uiType);
		var paths:String = Paths.getPreloadPath('shared/images/custom_ui/');
		var modpaths:String = Paths.modFolders('images/custom_ui/');
			// assume that it does have it and pray
			// if this is set it should already exist so not my problem :hueh:
			if (PlayState.isPixelStage && FNFAssets.exists(SUtil.getPath() + paths + curUItype.uses + '/$Judged-pixel.png'))
			{
				var lord = FNFAssets.getBitmapData(SUtil.getPath() + paths + curUItype.uses + '/$Judged-pixel.png');
				loadGraphic(lord);
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			}
			else if (PlayState.isPixelStage && FNFAssets.exists(modpaths + curUItype.uses + '/$Judged-pixel.png'))
				{
					var lord = FNFAssets.getBitmapData(modpaths + curUItype.uses + '/$Judged-pixel.png');
					loadGraphic(lord);
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;
				}
				else if (FNFAssets.exists(modpaths + curUItype.uses + '/$Judged-pixel.png'))
				{
					var lord = FNFAssets.getBitmapData(modpaths + curUItype.uses + '/$Judged.png');
					loadGraphic(lord);
				}
				else
					{
						var lord = FNFAssets.getBitmapData(SUtil.getPath() + paths + curUItype.uses + '/$Judged.png');
						loadGraphic(lord);
					}
        
		updateHitbox();
    }
}
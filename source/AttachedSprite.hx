package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
using StringTools;

class AttachedSprite extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var angleAdd:Float = 0;
	public var alphaMult:Float = 1;

	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;

	public function new(?file:String = null, ?anim:String = null, ?library:String = null, ?loop:Bool = false)
	{
		super();

		
		if(anim != null) {
			frames = FlxAtlasFrames.fromSparrow(
			(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + file + '.png') || FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/' + file + '.png')) ? 
			(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + file + '.png') ? 
			FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/' + file + '.png') : 
			FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/shared/images/' + file + '.png')):
			FNFAssets.getBitmapData(Paths.modFolders('images/' + file + '.png')), 

			(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + file + '.xml') || FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/' + file + '.xml')) ? 
			(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + file + '.xml') ? 
			FNFAssets.getText(SUtil.getPath() + 'windose_data/images/' + file + '.xml') : 
			FNFAssets.getText(SUtil.getPath() + 'windose_data/shared/images/' + file + '.xml')) :
			FNFAssets.getText(Paths.modFolders('images/' + file + '.xml')));
			animation.addByPrefix('idle', anim, 24, loop);
			animation.play('idle');
		} else if(file != null) {
			loadGraphic(
				(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + file + '.png') || FNFAssets.exists(SUtil.getPath() + 'windose_data/shared/images/' + file + '.png')) ? 
				(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + file + '.png') ? 
				FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/' + file + '.png') : 
				FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/shared/images/' + file + '.png')):
			FNFAssets.getBitmapData(Paths.modFolders('images/' + file + '.png')));
		}
		antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
	
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);

			if(copyAngle)
				angle = sprTracker.angle + angleAdd;

			if(copyAlpha)
				alpha = sprTracker.alpha * alphaMult;

			if(copyVisible) 
				visible = sprTracker.visible;
		}
	}
}

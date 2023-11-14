package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
using StringTools;
enum abstract IconState(Int) from Int to Int {
	var Normal;
	var Dying;
	var Winning;
}
class HealthIcon extends FlxSprite
{
	public var isAnimated:Bool = false;
	public var isPlayState:Bool = false;
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	/*"private"*/ var nameAnimate:String = 'normal';
	public var iconState(default, set):IconState = Normal;
	function set_iconState(x:IconState):IconState {
		if (isAnimated){
			switch (x) {
			case Normal:
				nameAnimate = 'normal';
			case Dying:
				// if we set it out of bounds it doesn't realy matter as it goes to normal anyway
				nameAnimate = 'dying';
			case Winning:
				// we DO do it here here we want to make sure it isn't silly
					nameAnimate = 'winning';

			}
		}else{
				switch (x) {
			case Normal:
				animation.curAnim.curFrame = 0;
			case Dying:
				// if we set it out of bounds it doesn't realy matter as it goes to normal anyway
				animation.curAnim.curFrame = 1;
			case Winning:
				// we DO do it here here we want to make sure it isn't silly
				if (animation.curAnim.frames.length >= 3) {
					animation.curAnim.curFrame = 2;
				} else {
					animation.curAnim.curFrame = 0;
				}
			}
			}
		
		return iconState = x;
	}
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isAnimated)
		animation.play(nameAnimate);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);


	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public var iconOffsets:Array<Float> = [0, 0];
	public var iconoffsetsfnf:Array<Float> = null;
	public function changeIcon(char:String) {
		if(this.char != char) {
			
			
		    var iconJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson(SUtil.getPath() + "windose_data/images/icons/icons"));
			var iconmodJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson(Paths.modFolders("images/icons/icons")));
			var iconStrings:Array<String> = [];
			var iconFrames:Array<Int> = [];
			var iconString:Array<String> = [];
			var iconWidth:Null<Float> = 150;
			var iconHeight:Null<Float> = 150;
			
			//MAKE SURE NOT CRASH

			if (Reflect.hasField(iconJson, char))
				{
					iconFrames = Reflect.field(iconJson, char).frames;
					iconString = Reflect.field(iconJson, char).frameNames;
					iconWidth = Reflect.field(iconJson, char).width;
					iconHeight = Reflect.field(iconJson, char).height;
					iconoffsetsfnf = Reflect.field(iconJson, char).offsets;
				}
				else if (FNFAssets.exists(Paths.modFolders("images/icons/icons.json"))&&Reflect.hasField(iconmodJson, char))
					{
						iconFrames = Reflect.field(iconmodJson, char).frames;
						iconString = Reflect.field(iconmodJson, char).frameNames;
						iconWidth = Reflect.field(iconmodJson, char).width;
				     	iconHeight = Reflect.field(iconmodJson, char).height;
						iconoffsetsfnf = Reflect.field(iconmodJson, char).offsets;
					}
				else
				{
					
					iconFrames = [0, 1, 0];
					iconString = ['normal', 'dying', 'normal'];
					iconWidth = 0;
					iconHeight = 0;
				}

				
				if (iconoffsetsfnf == null)
					iconoffsetsfnf = [0,0,0];
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var xml:String = name + '.xml';
			if(FNFAssets.exists(SUtil.getPath() + 'windose_data/images/' + xml) || FNFAssets.exists(Paths.modFolders('images/' + xml)))
				{
					isAnimated = true;
					frames = Paths.getSparrowAtlas(name);
					animation.addByPrefix('normal', iconString[0], 24, true, isPlayer);
					animation.addByPrefix('dying', iconString[1], 24, true, isPlayer);
					animation.addByPrefix('winning', iconString[2], 24, true, isPlayer);
                    animation.play(nameAnimate);
				}
				else
				{
					isAnimated = false;
					var file:Dynamic = Paths.image(name);
					loadGraphic(file); //Load stupidly first for getting the file size
if (iconWidth <= 0 || iconWidth == null || iconWidth > width / 2)
					iconWidth = width / 2;
				if (iconHeight <= 0 || iconHeight == null || iconHeight > height)
					iconHeight = height;
					loadGraphic(file, true, Math.floor(iconWidth), Math.floor(iconHeight)); //Then load it fr
				
		
					animation.add(char, iconFrames, 0, false, isPlayer);
					animation.play(char);

				}

			this.char = char;
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();
			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		if (isPlayState){
		offset.x = iconOffsets[0] + (isPlayer ? iconoffsetsfnf[0] : iconoffsetsfnf[2]);
		offset.y = iconOffsets[1] + iconoffsetsfnf[1];
		}
		else
			{
				offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
			}
	}

	public function getCharacter():String {
		return char;
	}
}

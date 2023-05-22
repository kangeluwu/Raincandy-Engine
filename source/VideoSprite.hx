package;
//什么?这不是MP4Sprite，这是一个FlxVideo!我们这个FlxVideo体积小方便携带，拆开一包，放水里就变大，怎么扯都扯不坏，用来擦脸，擦嘴都是很好用的，你看打开以后像MP4一样大小，放在水里遇水变大变高，吸水性很强的。
import flixel.FlxSprite;
import FlxVideo;
class VideoSprite extends FlxSprite
{
	public var readyCallback:Void->Void;
	public var finishCallback:Void->Void;
	public var video:FlxVideo;

	public function new(x:Float = 0, y:Float = 0, width:Float = FlxG.stage.stageHeight * (16 / 9), height:Float = FlxG.stage.stageHeight)
	{
		super(x, y);

		video = new FlxVideo(width, height);
		

		video.onVLCVideoReady = function()
		{

			if (readyCallback != null)
				readyCallback();
		}

		video.finishCallback = function()
		{
			kill();
			if (finishCallback != null)
				finishCallback();

		};
	}

	public function playMP4(path:String, ?repeat:Bool = false, pauseMusic:Bool = false)
	{
		video.playMP4(path, repeat, this);
	}

	public function pause()
	{
		video.pause();
	}

	public function resume()
	{
		video.resume();
	}
}

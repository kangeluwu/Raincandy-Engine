import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.FlxG;
/**
 * FlxSound that automatically handles loading sound dynamically. 
 */
class DynamicSound extends FlxSound {
    override public function loadEmbedded(EmbeddedSound:FlxSoundAsset, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:() -> Void):FlxSound {
        if ((EmbeddedSound is String)) {
            var goodSound = FNFAssets.getSound(EmbeddedSound);
            return super.loadEmbedded(goodSound, Looped, AutoDestroy, OnComplete);
        }
        return super.loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
    }
    public var muted(default, set):Bool = false;

    function set_muted(value:Bool):Bool
    {
      if (value == muted) return value;
      muted = value;
      updateTransform();
      return value;
    }
    @:allow(flixel.sound.FlxSoundGroup)
    override function updateTransform():Void
    {
      if (_transform != null)
      {
        _transform.volume = #if FLX_SOUND_SYSTEM ((FlxG.sound.muted || this.muted) ? 0 : 1) * FlxG.sound.volume * #end
          (group != null ? group.volume : 1) * _volume * _volumeAdjust;
      }
  
      if (_channel != null)
      {
        _channel.soundTransform = _transform;
      }
    }
  
}
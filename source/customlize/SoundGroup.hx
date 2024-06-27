package customlize;

import flixel.group.FlxGroup.FlxTypedGroup;
import DynamicSound;
import flixel.tweens.FlxTween;
import flixel.FlxG;
/**
 * A group of DynamicSounds that are all synced together.
 * Unlike FlxSoundGroup, you can also control their time and pitch.
 */
class SoundGroup extends FlxTypedGroup<DynamicSound>
{
  public var time(get, set):Float;

  public var volume(get, set):Float;

  public var muted(get, set):Bool;

  public var pitch(get, set):Float;

  public var playing(get, never):Bool;

  public function new()
  {
    super();
  }

  @:deprecated("Create sound files and call add() instead")
  public static function build(song:String, ?files:Array<String> = null):SoundGroup
  {
    var result = new SoundGroup();

    if (files == null)
    {
      // Add an empty voice.
      result.add(new DynamicSound());
      return result;
    }

    for (sndFile in files)
    {
      var snd:DynamicSound = new DynamicSound();
      snd.loadEmbedded(Paths.songStuffer(song, '$sndFile'));
      result.add(snd); // adds it to main group for other shit
      FlxG.sound.list.add(snd);
    }

    return result;
  }

  /**
   * Finds the largest deviation from the desired time inside this SoundGroup.
   *
   * @param targetTime	The time to check against.
   * 						If none is provided, it checks the time of all members against the first member of this SoundGroup.
   * @return The largest deviation from the target time found.
   */
  public function checkSyncError(?targetTime:Float):Float
  {
    var error:Float = 0;

    forEachAlive(function(snd) {
      if (targetTime == null) targetTime = snd.time;
      else
      {
        var diff:Float = snd.time - targetTime;
        if (Math.abs(diff) > Math.abs(error)) error = diff;
      }
    });
    return error;
  }

  /**
   * Add a sound to the group.
   */
  public override function add(sound:DynamicSound):DynamicSound
  {
    var result:DynamicSound = super.add(sound);

    if (result == null) return null;

    // We have to play, then pause the sound to set the time,
    // else the sound will restart immediately when played.
    // TODO: Past me experienced that issue but present me didn't? Investigate.
    // result.play(true, 0.0);
    // result.pause();
    result.time = this.time;

    result.onComplete = function() {
      this.onComplete();
    }

    // Apply parameters to the new sound.
    result.pitch = this.pitch;
    result.volume = this.volume;
    FlxG.sound.list.add(result);
    return result;
  }

  public dynamic function onComplete():Void {}

  /**
   * Pause all the sounds in the group.
   */
  public function pause()
  {
    forEachAlive(function(sound:DynamicSound) {
      sound.pause();
    });
  }

  /**
   * Play all the sounds in the group.
   */
  public function play(forceRestart:Bool = false, startTime:Float = 0.0, ?endTime:Float)
  {
    forEachAlive(function(sound:DynamicSound) {
      sound.play(forceRestart, startTime, endTime);
    });
  }

  /**
   * Resume all the sounds in the group.
   */
  public function resume()
  {
    forEachAlive(function(sound:DynamicSound) {
      sound.resume();
    });
  }

  /**
   * Fade in all the sounds in the group.
   */
  public function fadeIn(duration:Float, ?from:Float = 0.0, ?to:Float = 1.0, ?onComplete:FlxTween->Void):Void
  {
    forEachAlive(function(sound:DynamicSound) {
      sound.fadeIn(duration, from, to, onComplete);
    });
  }

  /**
   * Fade out all the sounds in the group.
   */
  public function fadeOut(duration:Float, ?to:Float = 0.0, ?onComplete:FlxTween->Void):Void
  {
    forEachAlive(function(sound:DynamicSound) {
      sound.fadeOut(duration, to, onComplete);
    });
  }

  /**
   * Stop all the sounds in the group.
   */
  public function stop():Void
  {
    if (members != null)
    {
      forEachAlive(function(sound:DynamicSound) {
        sound.stop();
      });
    }
  }

  public override function destroy():Void
  {
    stop();
    super.destroy();
  }

  /**
   * Remove all sounds from the group.
   */
  public override function clear():Void
  {
    this.stop();

    super.clear();
  }

  function get_time():Float
  {
    if (getFirstAlive() != null)
    {
      return getFirstAlive().time;
    }
    else
    {
      return 0;
    }
  }

  function set_time(time:Float):Float
  {
    forEachAlive(function(snd:DynamicSound) {
      // account for different offsets per sound?
      snd.time = time;
    });

    return time;
  }

  function get_playing():Bool
  {
    if (getFirstAlive() != null)
    {
      return getFirstAlive().playing;
    }
    else
    {
      return false;
    }
  }

  function get_volume():Float
  {
    if (getFirstAlive() != null)
    {
      return getFirstAlive().volume;
    }
    else
    {
      return 1;
    }
  }

  // in PlayState, adjust the code so that it only mutes the player1 vocal tracks?
  function set_volume(volume:Float):Float
  {
    forEachAlive(function(snd:DynamicSound) {
      snd.volume = volume;
    });

    return volume;
  }

  function get_muted():Bool
  {
    if (getFirstAlive() != null) return getFirstAlive().muted;
    else
      return false;
  }

  function set_muted(muted:Bool):Bool
  {
    forEachAlive(function(snd:DynamicSound) {
      snd.muted = muted;
    });

    return muted;
  }

  function get_pitch():Float
  {
    #if FLX_PITCH
    if (getFirstAlive() != null) return getFirstAlive().pitch;
    else
    #end
    return 1;
  }

  function set_pitch(val:Float):Float
  {
    #if FLX_PITCH
    trace('Setting audio pitch to ' + val);
    forEachAlive(function(snd:DynamicSound) {
      snd.pitch = val;
    });
    #end
    return val;
  }
}

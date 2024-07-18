package;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.graphics.frames.FlxFramesCollection;
import util.assets.FlxAnimationUtil;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class NoteHoldCover extends FlxTypedSpriteGroup<FlxSprite>
{
  static final FRAMERATE_DEFAULT:Int = 24;

  static var glowFrames:FlxFramesCollection;

  public var holdNote:Note;
  public var colorSwap:ColorSwap = null;
  var glow:FlxSprite;
  var sparks:FlxSprite;
  public function new(x:Float = 0, y:Float = 0, ?note:Note = null)
  {
    super(x, y);
    holdNote = note;
    setup();
    colorSwap = new ColorSwap();
		shader = colorSwap.shader;
  }

  public static function preloadFrames():Void
  {
    glowFrames = null;
    for (colorName in Note.colors)
    {
      var directionName = colorName.toTitleCase();

      var atlas:FlxFramesCollection = Paths.getSparrowAtlas('holdCover${directionName}');
      atlas.parent.persist = true;

      if (glowFrames != null)
      {
        glowFrames = FlxAnimationUtil.combineFramesCollections(glowFrames, atlas);
      }
      else
      {
        glowFrames = atlas;
      }
    }
  }

  /**
   * Add ALL the animations to this sprite. We will recycle and reuse the FlxSprite multiple times.
   */
  function setup():Void
  {
    glow = new FlxSprite();
    add(glow);
    if (glowFrames == null) preloadFrames();
    glow.frames = glowFrames;

    for (daColor in Note.colors)
    {
      var directionName = CoolUtil.capitalize(daColor);

      glow.animation.addByPrefix('holdCoverStart$directionName', 'holdCoverStart${directionName}0', FRAMERATE_DEFAULT, false, false, false);
      glow.animation.addByPrefix('holdCover$directionName', 'holdCover${directionName}0', FRAMERATE_DEFAULT, true, false, false);
      glow.animation.addByPrefix('holdCoverEnd$directionName', 'holdCoverEnd${directionName}0', FRAMERATE_DEFAULT, false, false, false);
    }

    glow.animation.finishCallback = this.onAnimationFinished;

    if (glow.animation.getAnimationList().length < 3 * 4)
    {
      trace('WARNING: NoteHoldCover failed to initialize all animations.');
    }
  }

  public override function update(elapsed):Void
  {
    super.update(elapsed);
  }
  public function setupNoteCover(x:Float, y:Float, note:Note = null, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
    setPosition(x, y);
    if (note != null)
      holdNote = note;
    holdNote.cover = this;
    colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
	}

  public function playStart():Void
  {
    var direction:String = note.colors[holdNote.noteData];
    glow.animation.play('holdCoverStart${CoolUtil.capitalize(colorName)}');
  }

  public function playContinue():Void
  {
    var direction:String = note.colors[holdNote.noteData];
    glow.animation.play('holdCover${CoolUtil.capitalize(colorName)}');
  }

  public function playEnd():Void
  {
    var direction:String = note.colors[holdNote.noteData];
    glow.animation.play('holdCoverEnd${CoolUtil.capitalize(colorName)}');
  }

  public override function kill():Void
  {
    super.kill();

    this.visible = false;

    if (glow != null) glow.visible = false;
    if (sparks != null) sparks.visible = false;
  }

  public override function revive():Void
  {
    super.revive();

    this.visible = true;
    this.alpha = 1.0;

    if (glow != null) glow.visible = true;
    if (sparks != null) sparks.visible = true;
  }

  public function onAnimationFinished(animationName:String):Void
  {
    if (animationName.startsWith('holdCoverStart'))
    {
      playContinue();
    }
    if (animationName.startsWith('holdCoverEnd'))
    {
      // *lightning* *zap* *crackle*
      this.visible = false;
      this.kill();
    }
  }
}

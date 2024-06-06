package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
import lime.utils.Log;

class RuntimePostEffectShader extends FlxRuntimeShader
{
  @:glVertexHeader('
		// normalized screen coord
		//   (0, 0) is the top left of the window
		//   (1, 1) is the bottom right of the window
		varying vec2 screenCoord;
	', true)
  @:glVertexBody('
		screenCoord = vec2(
			openfl_TextureCoord.x > 0.0 ? 1.0 : 0.0,
			openfl_TextureCoord.y > 0.0 ? 1.0 : 0.0
		);
	')
  @:glFragmentHeader('
		// normalized screen coord
		//   (0, 0) is the top left of the window
		//   (1, 1) is the bottom right of the window
		varying vec2 screenCoord;

		// equals (FlxG.width, FlxG.height)
		uniform vec2 uScreenResolution;

		// equals (camera.viewLeft, camera.viewTop, camera.viewRight, camera.viewBottom)
		uniform vec4 uCameraBounds;

		// screen coord -> world coord conversion
		// returns world coord in px
		vec2 screenToWorld(vec2 screenCoord) {
			float left = uCameraBounds.x;
			float top = uCameraBounds.y;
			float right = uCameraBounds.z;
			float bottom = uCameraBounds.w;
			vec2 scale = vec2(right - left, bottom - top);
			vec2 offset = vec2(left, top);
			return screenCoord * scale + offset;
		}

		// world coord -> screen coord conversion
		// returns normalized screen coord
		vec2 worldToScreen(vec2 worldCoord) {
			float left = uCameraBounds.x;
			float top = uCameraBounds.y;
			float right = uCameraBounds.z;
			float bottom = uCameraBounds.w;
			vec2 scale = vec2(right - left, bottom - top);
			vec2 offset = vec2(left, top);
			return (worldCoord - offset) / scale;
		}

		// internally used to get the maximum `openfl_TextureCoordv`
		vec2 bitmapCoordScale() {
			return openfl_TextureCoordv / screenCoord;
		}

		// internally used to compute bitmap coord
		vec2 screenToBitmap(vec2 screenCoord) {
			return screenCoord * bitmapCoordScale();
		}

		// samples the frame buffer using a screen coord
		vec4 sampleBitmapScreen(vec2 screenCoord) {
			return texture2D(bitmap, screenToBitmap(screenCoord));
		}

		// samples the frame buffer using a world coord
		vec4 sampleBitmapWorld(vec2 worldCoord) {		
			return sampleBitmapScreen(worldToScreen(worldCoord));
		}
	', true)
  public function new(fragmentSource:String = null, vertexSource:String = null,glVersion:String = null)
  {
    super(fragmentSource, vertexSource, Std.parseInt(glVersion));
    uScreenResolution.value = [FlxG.width, FlxG.height];
  }

  // basically `updateViewInfo(FlxG.width, FlxG.height, FlxG.camera)` is good
  public function updateViewInfo(screenWidth:Float, screenHeight:Float, camera:FlxCamera):Void
  {
    uScreenResolution.value = [screenWidth, screenHeight];
	@:privateAccess{
	
   var daValue = [
	camera.scroll.x + camera.viewOffsetX,
	camera.scroll.y + camera.viewOffsetY,
	camera.scroll.x + (camera.width - camera.viewOffsetX),
	camera.scroll.y + (camera.height - camera.viewOffsetX)
];
uCameraBounds.value = daValue;
	}
	
  }

  override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
  {
    try
    {
      final res = super.__createGLProgram(vertexSource, fragmentSource);
      return res;
    }
    catch (error)
    {
      Log.warn(error); // prevent the app from dying immediately
      return null;
    }
  }
}

package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class DefaultSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Default Settings';
		rpcTitle = 'Default Settings Menu'; //for Discord Rich Presence

		#if HAD_DIFFERNET_LANGS
	var option:Option = new Option('language',
		"Which language do you prefer for the Storymenu Dialog and PlayState UI?",
		'langType',
		'string',
		'English',
		['English', 'Chinese']);
	addOption(option);
	#end
	var option:Option = new Option('Classic Style',
		'If checked, Used the Vanilla Engine Style.', 
		'classicStyle', 
		'bool', 
		false); 
	addOption(option);

    var option:Option = new Option('Skip Chart Type Menu',
'If checked, Skip select chart type menu.', 
'skipChartTypeMenu', 
'bool', 
false); 
addOption(option);

var option:Option = new Option('Skip Haxe Intro Splashes',
'If checked, Skip Haxe Intro Splashes Anim.', 
'skipSplash', 
'bool', 
false); 
addOption(option);
		super();
	}


}
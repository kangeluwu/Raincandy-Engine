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

class OptionsState extends MusicBeatState
{
	public var options:Array<String> = [];
	public var grpOptions:FlxTypedGroup<Alphabet>;
	public var pageOptions:Array<FlxTypedGroup<Alphabet>> = [];
	public static var curSelected:Int = 0;
	public static var curPageSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public var pages:Array<Array<String>> = [['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'],['Default Settings']];
	public static var isFromPlayState:Bool = false;
	var pageText:Alphabet;
	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new options.NotesSubState());
			case 'Change Gameplay stuffs':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new GameplayChangersSubstate());
			case 'Controls':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new options.ControlsSubState());
					
				
			case 'Graphics':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new options.GameplaySettingsSubState());
				case 'Default Settings':
				#if mobile
				removeVirtualPad();
				#end
				openSubState(new options.DefaultSettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var lastPage:Int = 0;
	static var lastCurSelected:Array<Int> = [0,0];
	override function create() {
		options = pages[curPageSelected];
		if (isFromPlayState)
			pages[1].push('Change Gameplay stuffs');
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end
	

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
	bg.color = 0xFFea71fd;
	bg.screenCenter();
	bg.antialiasing = ClientPrefs.globalAntialiasing;
	add(bg);


		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

        for (arrays in pages){
			var grpOption = new FlxTypedGroup<Alphabet>();

		for (i in 0...arrays.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, arrays[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (arrays.length / 2))) + 50;
			grpOption.add(optionText);
		}
		pageOptions.push(grpOption);
		add(grpOption);
		for (item in grpOption.members) {
			item.alpha = 0.0001;
		}
	}

	grpOptions = pageOptions[curPageSelected];
	for (item in grpOptions.members) {
		item.alpha = 1;
	}
		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);
		#if android
		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press C to Go In Mobile Controls Menu', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);
		#end
		pageText = new Alphabet(0, 0, "Page - " + (curPageSelected + 1), true, false,0.05,0.5);
		add(pageText);
		pageText.scale.set(0.5,0.5);
		pageText.updateHitbox();
		pageText.alpha = 0.5;
		changePage();
		ClientPrefs.saveSettings();
		#if mobile
		addVirtualPad(FULL, A_B_C);
		#end
		super.create();
	}
	

	
	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if mobile
		addVirtualPad(FULL, A_B_C);
                #end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.UI_LEFT_P) {
			changePage(-1);
		}
		if (controls.UI_RIGHT_P) {
			changePage(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (isFromPlayState)
			MusicBeatState.switchState(new PlayState());
			else
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
		#if mobile
		if (_virtualpad.buttonC.justPressed) {
			MusicBeatState.switchState(new android.AndroidControlsMenu());
		}
		#end
	}
	function changePage(change:Int = 0) {
		for (item in grpOptions.members) {
			item.alpha = 0.0001;
		}
		lastCurSelected[lastPage] = curSelected;
		curPageSelected += change;
		if (curPageSelected < 0)
			curPageSelected = pages.length - 1;
		if (curPageSelected >= pages.length)
			curPageSelected = 0;
		lastPage = curPageSelected;
		curSelected = lastCurSelected[curPageSelected];
		options = pages[curPageSelected];
		grpOptions = pageOptions[curPageSelected];
		for (item in grpOptions.members) {
			item.alpha = 1;
		}
		pageText.changeText("Page - " + (curPageSelected + 1));
		changeSelection();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
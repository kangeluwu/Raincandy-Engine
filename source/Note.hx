package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
using StringTools;
import flixel.text.FlxText;
typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String,
	value3:String
}

class Note extends FlxSprite
{
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			//trace("Function doesn't exist, silently skipping...");
			return;
		}
		try
			{
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
			case 3:
				method(args[0], args[1], args[2]);
			case 4:
				method(args[0], args[1], args[2], args[3]);
			case 5:
				method(args[0], args[1], args[2], args[3], args[4]);
		}
	}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		try
			{
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		try
			{
		hscriptStates.get(usehaxe).variables.set(name,value);
			}
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		try
			{
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
}
	function makeHaxeNote(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe note (because we are cool :))");
		var parser = new ParserEx();
	parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		var program = parser.parseString(FNFAssets.getHscript(SUtil.getPath() + path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("Sys", Sys);

		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("curNote", this);
		interp.variables.set("customDatas", extraData);
		interp.variables.set("oppMode", oppMode);
		interp.variables.set("strumTime", strumTime);
		interp.variables.set("mustPress", mustPress);
		interp.variables.set("noteData", noteData);
		interp.variables.set("canBeHit", canBeHit);
		interp.variables.set("tooLate", tooLate);
		interp.variables.set("wasGoodHit", wasGoodHit);
		interp.variables.set("ignoreNote", ignoreNote);
		interp.variables.set("hitByOpponent", hitByOpponent);
		interp.variables.set("isPixelNote", isPixelNote);
		interp.variables.set("noteWasHit", noteWasHit);
		interp.variables.set("prevNote", prevNote);
		interp.variables.set("nextNote", nextNote);
		interp.variables.set("spawned", spawned);
		interp.variables.set("tail", tail);
		interp.variables.set("parent", parent);
		interp.variables.set("sustainLength", sustainLength);
		interp.variables.set("isSustainNote", isSustainNote);
		interp.variables.set("noteType", noteType);
		interp.variables.set("eventName", eventName);
		interp.variables.set("eventVal1", eventVal1);
		interp.variables.set("eventVal2", eventVal2);
		interp.variables.set("eventVal3", eventVal3);
		interp.variables.set("colorSwap", colorSwap);
		interp.variables.set("ColorSwap", ColorSwap);
		interp.variables.set("inEditor", inEditor);
		interp.variables.set("animSuffix", animSuffix);
		interp.variables.set("earlyHitMult", earlyHitMult);
		interp.variables.set("lateHitMult", lateHitMult);
		interp.variables.set("lowPriority", lowPriority);
		interp.variables.set("swagWidth", swagWidth);
		interp.variables.set("PURP_NOTE", PURP_NOTE);
		interp.variables.set("GREEN_NOTE", GREEN_NOTE);
		interp.variables.set("BLUE_NOTE", BLUE_NOTE);
		interp.variables.set("RED_NOTE", RED_NOTE);
		interp.variables.set("NOTE_AMOUNT", NOTE_AMOUNT);
		interp.variables.set("noteSplashDisabled", noteSplashDisabled);
		interp.variables.set("noteSplashTexture", noteSplashTexture);
		interp.variables.set("noteSplashHue", noteSplashHue);

		interp.variables.set("noteSplashSat", noteSplashSat);
		interp.variables.set("noteSplashBrt", noteSplashBrt);
		interp.variables.set("crossFade", crossFade);

		interp.variables.set("offsetX", offsetX);
		interp.variables.set("offsetY", offsetY);

		
		interp.variables.set("multAlpha", multAlpha);
		interp.variables.set("offsetAngle", offsetAngle);
		interp.variables.set("multSpeed", multSpeed);
		interp.variables.set("copyX", copyX);
		interp.variables.set("copyY", copyY);
		interp.variables.set("copyAngle", copyAngle);
		interp.variables.set("copyAlpha", copyAlpha);
		interp.variables.set("altNote", altNote);
		interp.variables.set("altNum", altNum);
		interp.variables.set("hitHealth", hitHealth);
		interp.variables.set("missHealth", missHealth);
		interp.variables.set("rating", rating);
		interp.variables.set("ratingMod", ratingMod);
		interp.variables.set("ratingDisabled", ratingDisabled);
		interp.variables.set("texture", texture);
		interp.variables.set("noAnimation", noAnimation);
		interp.variables.set("noMissAnimation", noMissAnimation);
		interp.variables.set("hitCausesMiss", hitCausesMiss);
		interp.variables.set("distance", distance);
		interp.variables.set("drainNote", drainNote);
		interp.variables.set("staticNote", staticNote);
		interp.variables.set("gfNote", gfNote);
		interp.variables.set("bothNote", bothNote);
		interp.variables.set("warningNote", warningNote);
		interp.variables.set("resizeByRatio", resizeByRatio);
		interp.variables.set("reloadNote", reloadNote);
		interp.variables.set("originalHeightForCalcs", originalHeightForCalcs);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("Highscore", Highscore);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Character", Character);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("LoadingState", LoadingState);
		interp.variables.set("DialogueBox", DialogueBox);
		interp.variables.set("DialogueBoxMPlus", DialogueBoxMPlus);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("WeekData", WeekData);
		interp.variables.set("CreditsState", CreditsState);
		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("Math", Math);
		interp.variables.set("ClientPrefs", ClientPrefs);
		interp.variables.set("Song", Song);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("ratingHealAmount", ratingHealAmount);
		interp.variables.set("ratingDamageAmount", ratingDamageAmount);
		interp.variables.set("colorFromString", FlxColor.fromString);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("MusicBeatState", MusicBeatState);
		interp.variables.set("MusicBeatSubstate", MusicBeatSubstate);
		interp.variables.set("OptionsState", options.OptionsState);

		trace("set stuff");
		try
			{
				interp.execute(program);
				hscriptStates.set(usehaxe,interp);

				trace('executed');
	}
	catch (e)
	{
		openfl.Lib.application.window.alert(e.message, "OH NO IS GOD DAMN IT HSCRIPT ERROR FROM M+ OH NOOO!!!!!!!1");
	}

	}
	public var extraData:Map<String,Dynamic> = [];
	public var oppMode:Bool = false;
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var isPixelNote:Bool = PlayState.isPixelStage;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';
	public var eventVal3:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';



	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;
	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var crossFade:Bool = false;
	
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;
	public var ratingDamageAmount:Null<Float> = null;
	public var ratingHealAmount:Null<Float> = null;
	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var altNote:Bool = false;
	public var altNum:Int = 0;
	
	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;

	public var drainNote:Bool = false;
	public var staticNote:Bool = false;
	public var gfNote:Bool = false;
	public var warningNote:Bool = false;
	public var bothNote:Bool = false;
	public var isend:Bool = false;
	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
		if(isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}
	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
     var must:Bool = oppMode ? !mustPress: mustPress;
		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = must;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;

					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
					case 'Death Note':
						ignoreNote = must;
						reloadNote('NUKE');
						noteSplashTexture = 'HURTnoteSplashes';
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						lowPriority = true;
	
						if(isSustainNote) {
							missHealth = 0.7;
						} else {
							missHealth = 1;
						}
						hitCausesMiss = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
				case 'Both Sing':
					bothNote = true;
				case 'Drain Note':
					drainNote = true;

				case 'Warning Note':
					warningNote = true;
					hitHealth = 0;
					missHealth = 0.5;
					reloadNote('WARNING');
					noteSplashTexture = 'WARNINGnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;
				case 'Static Note':
					staticNote = true;
					noteSplashTexture = 'STATICnoteSplashes';
					reloadNote('STATIC');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		var interppath:String = '';
		#if MODS_ALLOWED
if(FNFAssets.exists(Paths.modFolders('custom_notetypes/') + noteType, Hscript)) {
	interppath = Paths.modFolders('custom_notetypes/');
} else {
	interppath = SUtil.getPath() + Paths.getPreloadPath('custom_notetypes/');
}
#else
interppath = SUtil.getPath() + Paths.getPreloadPath('custom_notetypes/');
#end

if (FNFAssets.exists(interppath + noteType, Hscript)){
	makeHaxeNote(noteType,interppath,noteType);
}
else{
	//do Nothing...
}
		callAllHScript('setNoteTypes', [value]);
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();
		
		


		if (prevNote == null)
			prevNote = this;
		if(isSustainNote && !animation.curAnim.name.endsWith('end'))
			isend=true;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		callAllHScript('new', [strumTime, noteData, prevNote, sustainNote, inEditor,this]);
		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;
		
		this.noteData = noteData % NOTE_AMOUNT;
		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4) {
				noteType = 'Hurt Note';
			}
			if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6) {
				//isLiftNote = true;
				//I HATE LIFT NOTE EEEEEEEEEEEEEEEE
				noteType = 'No Animation';
			}
			// die : )
			if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8) {
				noteType = 'Death Note';
			}
		if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10) {
			noteType = 'Static Note';
		}
		if (noteData >= NOTE_AMOUNT * 10 && noteData < NOTE_AMOUNT * 12) {
			noteType = 'Warning Note';
		}
		if (noteData >= NOTE_AMOUNT * 12 && noteData < NOTE_AMOUNT * 14) {
			noteType = 'GF Sing';
		}
		if (noteData >= NOTE_AMOUNT * 14 && noteData < NOTE_AMOUNT * 16) {
			noteType = 'Both Sing';
		}
		if (noteData >= NOTE_AMOUNT * 16 && noteData < NOTE_AMOUNT * 18) {
			noteType = 'Drain Note';
		}
		if (noteData >= NOTE_AMOUNT * 18) {
			noteType = '';
		}
			x += swagWidth * (noteData % NOTE_AMOUNT);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % NOTE_AMOUNT)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if(prevNote!=null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			switch (noteData % NOTE_AMOUNT)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			offsetX -= width / 2;

			if (isPixelNote)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData % NOTE_AMOUNT)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(isPixelNote) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(isPixelNote) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
		callAllHScript('onCreate', [strumTime, noteData, prevNote, sustainNote, inEditor,this]);
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	public function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';

		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if(isPixelNote) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;

				/*if(animName != null && !animName.endsWith('end'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / height);
					lastScaleY *= lastNoteScaleToo;
				}*/
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
		callAllHScript('reloadNotes', [prefix, texture, suffix,this]);
	}

	function loadNoteAnims() {
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		callAllHScript('onloadNoteAnims', [this,noteType]);
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		} else {
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
		callAllHScript('onloadPixelNoteAnims', [this,noteType]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		callAllHScript('update', [elapsed,this]);
		if ((mustPress && !oppMode) || (oppMode && !mustPress))
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
		callAllHScript('updatePost', [elapsed,this]);
	}
}

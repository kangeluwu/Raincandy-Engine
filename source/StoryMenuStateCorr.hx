package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;
import flixel.system.FlxSound;
using StringTools;
import tjson.TJSON;
import openfl.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import FlxVideo;
typedef WeekStateJson = {
	var ?isFull: Array<Bool>;
	var ?weekState: Array<Bool>;
	var ?dayNums: Array<Int>;
	var ?videoLink: Array<Array<String>>;
}
class StoryMenuStateCorr extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;
	var staticSprite:FlxSprite;
	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;
	var back:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var videos:Array<FlxVideo> = [];
	//var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var sprInfo:FlxSprite;
	var loadedWeeks:Array<WeekData> = [];
	var canMove:Bool = false;
	var vixtin:FlxSprite;
	var blackScr:FlxSprite;
	var canon:FlxSprite;

	var isPlayable:Array<Bool> = [];
	var isFullWeeks:Array<Bool> = [];
	var playable:FlxSprite;
	var watchable:FlxSprite;
	var daySpr:FlxSprite;
	var full:FlxSprite;
    var weekMusic:Array<FlxSound> = [];
	var curDays:Array<Int> = [];
	var yTargets:Array<Int> = [];
	var curDay:Int = 0;
	var weekLink:Array<Array<String>> = [];
	var tweenStatic:FlxTween;
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		var weekStateJson:WeekStateJson = TJSON.parse(Assets.getText(SUtil.getPath() + 'windose_data/data/previewVedio.json'));
		for (state in weekStateJson.weekState)
			isPlayable.push(state);
		for (weekLinks in weekStateJson.videoLink)
			weekLink.push(weekLinks);
		for (days in weekStateJson.dayNums)
			curDays.push(days);
		isFullWeeks = weekStateJson.isFull;

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 396, 0xFF000000);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgSprite);

		back = new FlxSprite(0, 56).makeGraphic(FlxG.width, 396, FlxColor.BLACK);
		back.setGraphicSize(FlxG.width, 396);
		staticSprite = new FlxSprite(0, 0);
		staticSprite.frames = FlxAtlasFrames.fromSparrow(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/daSTAT.png'), FNFAssets.getText(SUtil.getPath() + 'windose_data/images/daSTAT.xml'));
		staticSprite.animation.addByPrefix('FLASH', 'staticFLASH0', 24, true);
		staticSprite.animation.play('FLASH', true);
		staticSprite.screenCenter(X);
		staticSprite.alpha = 0.0001;
		staticSprite.setGraphicSize(FlxG.width, 396);
		staticSprite.scrollFactor.set();
		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);
		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
	

		//grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;

		var musicUse:String = 'windose_data/music/weekTheme/CMENU0.ogg';
		if (FlxG.sound.music != null)
		{
FlxG.sound.playMusic(FNFAssets.getSound(musicUse));
}

weekMusic[0] = FlxG.sound.music;
		
for (i in 1...WeekData.weeksList.length)
		{
			weekMusic[i] = new FlxSound();
			weekMusic[i].loadEmbedded(Paths.music('weekTheme/CMENU' + i), true);
			weekMusic[i].volume = 0;
			weekMusic[i].group = FlxG.sound.defaultMusicGroup;
			weekMusic[i].play();

			FlxG.sound.list.add(weekMusic[i]);
		}
		for (i in 0...WeekData.weeksList.length)
		{
			videos[i] = new FlxVideo();
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.targetY = num;
				grpWeekText.add(weekThing);
	
			//	weekThing.screenCenter(X);
				weekThing.x = (FlxG.width - weekThing.width) / 2;
				weekThing.x -= 410;
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		//var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		//for (char in 0...3)
		//{
		////	var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
		///	weekCharacterThing.y += 70;
		///	grpWeekCharacters.add(weekCharacterThing);
		//}

		difficultySelectors = new FlxGroup();
		
		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 50, grpWeekText.members[0].y + 14);
		leftArrow.loadGraphic(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/selectionArrowLEFT.png'));
		leftArrow.centerOffsets();
		leftArrow.scale.y = 0.9;
		leftArrow.antialiasing = true;
		leftArrow.x -= 80;
		// leftArrow.frames = ui_tex;
		// leftArrow.animation.addByPrefix('idle', "arrow left");
		// leftArrow.animation.addByPrefix('press', "arrow push left");
		// leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.loadGraphic(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/selectionArrowRIGHT.png'));
		rightArrow.centerOffsets();
		rightArrow.scale.y = 0.9;
		rightArrow.antialiasing = true;
		difficultySelectors.add(rightArrow);


		sprInfo = new FlxSprite(leftArrow.x, leftArrow.y + 110);
		sprInfo.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprInfo);
		sprInfo.x += (308 - sprDifficulty.width) / 3;
		//add(grpWeekCharacters);

		/*var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;*/
		//add(txtTracklist);
		// add(rankText);
		





		playable = new FlxSprite(0, 0).loadGraphic(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/playable.png'));
		playable.scrollFactor.set();
		playable.active = false;
		playable.screenCenter();
		playable.y += 165;
		playable.x += 450;
		playable.antialiasing = true;
		playable.scale.set(0.9, 0.9);
		playable.visible = false;



		watchable = new FlxSprite(0, 0).loadGraphic(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/watchable.png'));
		watchable.scrollFactor.set();
		watchable.active = false;
		watchable.screenCenter();
		watchable.y += 165;
		watchable.x += 450;
		watchable.antialiasing = true;
		watchable.scale.set(0.9, 0.9);


		sprInfo.alpha = 0;
		sprDifficulty.alpha = 0;




			daySpr = new FlxSprite(leftArrow.x + 85, leftArrow.y + 20);
			daySpr.visible = false;
			daySpr.alpha = 0;


//DUMB HAHA I HATE MYSELF:(
			full = new FlxSprite(leftArrow.x + 85, leftArrow.y + 20).loadGraphic(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/day0.png'));
			full.visible = false;
			full.alpha = 0;



			add(bgYellow);

			add(difficultySelectors);
			add(playable);
			add(watchable);
			
			add(daySpr);
			add(full);
			add(back);
			add(blackBarThingie);
			add(scoreText);
			add(txtWeekTitle);

		changeWeek();
		changeDifficulty();

		add(staticSprite);
		blackScr = new FlxSprite(0, 0).loadGraphic(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/black.png'));
		blackScr.screenCenter();
		blackScr.scrollFactor.set();
		blackScr.active = false;
		add(blackScr);
		
		vixtin = new FlxSprite(0, 0);
		vixtin.frames = FlxAtlasFrames.fromSparrow(FNFAssets.getBitmapData(SUtil.getPath() + 'windose_data/images/selectyourvixty.png'), FNFAssets.getText(SUtil.getPath() + 'windose_data/images/selectyourvixty.xml'));
		vixtin.animation.addByPrefix('select', 'select', 24, true);
		vixtin.animation.play('select', true);
		vixtin.scale.set(0.7, 0.7);
		vixtin.screenCenter();
		vixtin.scrollFactor.set();
		add(vixtin);

		new FlxTimer().start(3, function(tmr)
		{
			canMove = true;
			FlxTween.tween(vixtin, {alpha: 0}, 2, {
			onComplete: function(twn) 
			{
				vixtin.destroy();
			}});
			FlxTween.tween(blackScr, {alpha: 0}, 2, {
			onComplete: function(twn) 
			{
				blackScr.destroy();
			}});
		});
		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		staticSprite.setGraphicSize(FlxG.width, 396);
		staticSprite.y = -114;
		staticSprite.screenCenter(X);
		back.setGraphicSize(706, 396);
		back.screenCenter(X);
		back.y = -114;
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek && canMove)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			/*if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');
*/
			if (controls.UI_RIGHT_P && isPlayable[curWeek])
				changeDifficulty(1);
			else if (controls.UI_LEFT_P && isPlayable[curWeek])
				changeDifficulty(-1);

			if (controls.UI_RIGHT_P && !isPlayable[curWeek] && !isFullWeeks[curWeek])
				changeDay(1);
			if (controls.UI_LEFT_P && !isPlayable[curWeek] && !isFullWeeks[curWeek])
			   changeDay(-1);
			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				if (isPlayable[curWeek])
					selectWeek();
				else
					selectWatchDay();
			}
			

			for (i in 0...WeekData.weeksList.length)
				{
					if (i == curWeek){
						weekMusic[i].volume = 1;
					}
					else {
						weekMusic[i].volume = 0;
					}
		
		
				}
		}

		if (controls.BACK && !movedBack && !selectedWeek && canMove)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new MainMenuState());
			for (i in 0...WeekData.weeksList.length)
				{
						if (videos[i].bitmap != null){
							videos[i].nodispose = false;
							videos[i].bitmap.repeat = 0;
						videos[i].onVLCComplete();
						}
	
		}
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	function selectWatchDay()
		{
			FlxG.sound.play(SUtil.getPath() + 'windose_data/sounds/confirmMenu' + TitleState.soundExt);
			FlxG.openURL(weekLink[curWeek][curDay]);
	
		}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;
	var playing:FlxTimer;
	function videos114514() {
		staticSprite.alpha = 1;
		
		if(tweenStatic != null) tweenStatic.cancel();
		if(playing != null) playing.cancel();
		tweenStatic = FlxTween.tween(staticSprite, {alpha: 0.00001}, 2, {startDelay: 3,onComplete: function(twn:FlxTween)
			{
				tweenStatic = null;
			}});
		playing = new FlxTimer().start(3, function(tmr)
				{
					for (i in 0...WeekData.weeksList.length)
						{
							if (i == curWeek){
								if (FileSystem.exists(Paths.video('MenuVideo' + curWeek)))
									{
								videos[i].playMP4(Paths.video('MenuVideo' + curWeek), false, back);
									}
							}
							else {
								if (videos[i].bitmap != null)
								videos[i].kill();
							}
							videos[i].nodispose = true;
				}
				playing = null;
				});
		
}
	function changeDay(change:Int = 0)
		{


			curDay += change;
			//Wanna try my new FUNNITHINGS LOL?
			if (curDay < 0)
				curDay = curDays[curWeek] - 1;
			if (curDay > curDays[curWeek] - 1)
				curDay = 0;
			var newImage:FlxGraphic;
			
	for (i in 0...curDays[curWeek])
		{

				newImage = Paths.image('day'+ (curDay+1));
//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));


if(daySpr.graphic != newImage)
{
	if (daySpr != null){


           daySpr.loadGraphic(newImage);
			
		daySpr.visible = true;
		daySpr.alpha = 0;
		daySpr.y = leftArrow.y - 20;

		FlxTween.tween(daySpr, {y: leftArrow.y + 20, alpha: 1}, 0.07);
		
		}
		}
	}
	}

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].animation.play('press',true);
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	var theTween:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/corrs/' + Paths.formatToSongPath(diff));
		var newInfoImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff) + 'info');
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		if(sprInfo.graphic != newInfoImage)
			{
				sprInfo.loadGraphic(newInfoImage);

				sprInfo.alpha = 1;
	
				if(theTween != null) theTween.cancel();
				theTween = FlxTween.tween(sprInfo, {alpha: 0}, 2.2, {onComplete: function(twn:FlxTween)
				{
					theTween = null;
				}});
			}
		
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function resyncMusics()
		{ 
			weekMusic[curWeek].pause();
			
			weekMusic[curWeek].time = FlxG.sound.music.time;
			weekMusic[curWeek].play();
		}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		resyncMusics();
		videos114514();

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		bgSprite.visible = false;

		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		difficultySelectors.visible = unlocked;

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		
		playable.visible = false;
    	watchable.visible = false;
		var bullShit:Int = 0;
		if (isPlayable[curWeek])
		{
			playable.visible = true;
			changeDifficulty(0);
				daySpr.visible = false;
				full.visible = false;
			sprDifficulty.alpha = 1;
			sprInfo.visible = true;
		}
		else
		{

			watchable.visible = true;

					if (isFullWeeks[curWeek]){
						daySpr.visible = false;
						full.visible = true;
						full.alpha = 1;
					}
					else{
						daySpr.visible = true;
						full.visible = false;
						full.alpha = 0;
						changeDay(0);
					}
			



			sprDifficulty.alpha = 0;
			sprInfo.visible = false;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		/*var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}
*/
		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		/*txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
*/
		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}

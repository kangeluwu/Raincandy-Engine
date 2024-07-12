package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SongFilesOMG =
{
	var fileName:Null<String>;
	var wasPlayer:Null<Bool>;
	var wasOpponent:Null<Bool>;
	var wasBGM:Null<Bool>;
}


typedef PlayData = {
	var characters:CharData;
	var stage:String;
}
typedef CharData = {
	var player:String;
	var girlfriend:String;
	var opponent:String;
}
typedef SwagSong =
{
	var playerVocalFiles:Null<Array<String>>;
	var opponentVocalFiles:Null<Array<String>>;
	var sfxFiles:Null<Array<String>>;
	var songFileNames:Null<Array<String>>;
	var song:String;
	var notes:Array<SwagSection>;
	var songNameChinese:String;
	var events:Array<Dynamic>;
	var bpm:Float;
	var uiType:String;
	var needsVoices:Bool;
	var disPlayAutoMovingCam:Null<Bool>;
	var needsSFX:Null<Bool>;
	var speed:Float;
	var cutsceneType:String;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
	var composer:String;
	var igorAutoFix:Null<Bool>;
	var strums:Null<Int>;
	//var mania:Null<Int>;
}

class Song
{
	public var uiType:String = 'normal';
	public var song:String;
	/**
	 public var songFileNames:Array<SongFilesOMG> = [
		{
		fileName : 'Inst',
		wasBGM : true,
		wasPlayer : false;
		wasOpponent : false;
	},
	{
		fileName : 'Voices',
		wasBGM : true,
		wasPlayer : false;
		wasOpponent : false;
	}];
	 */
	public var playerVocalFiles:Array<String> = [];
	public var opponentVocalFiles:Array<String> = [];
	public var sfxFiles:Array<String> = [];
	public var songFileNames:Array<String> = ['Inst','Voices'];
	public var basedOldMode:Bool = false;
	public var igorAutoFix:Bool = false;
	public var songNameChinese:String = '';
	public var composer:String = null;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var needsSFX:Bool = false;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var speed:Float = 1;
	public var strums:Int = 2;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var cutsceneType:String = "none";
	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
	
		//if (songJson.mania == null) {
		//	songJson.mania = 0;
		//}
		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(song, notes, bpm, basedOldMode:Bool = false)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.basedOldMode = basedOldMode;
	}
    public static function parse(jsonInput:String, ?folder:String,backend:String = ''){
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong+backend);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			#if sys
			rawJson = File.getContent(SUtil.getPath() + Paths.json(formattedFolder + '/' + formattedSong+backend)).trim();
			#else
			rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong+backend)).trim();
			#end
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

	return rawJson;
	}
	public static function loadFromNewJson(jsonInput:String = '', ?folder:String = '',difficu:String = 'normal'):SwagSong
		{

			var songJsonDA = null;
			var metaDataDA = null;
			var songJson = null;
			var metaData = null;
			try{
				songJsonDA = parse(jsonInput,folder,'-chart');
			    metaDataDA = parse(jsonInput,folder,'-metadata');
				songJson = Json.parse(songJsonDA);
				metaData = Json.parse(metaDataDA);
				trace(metaData);
			}
			catch(e){
				trace('NEW CHARTING FILE NOT EXISTS! USING OLD ONE...');
				if (difficu.toLowerCase() == 'normal' || difficu == '')
					difficu = '';
				else
					difficu = '-'+difficu;
				return loadFromJson(jsonInput+difficu.toLowerCase(),folder);
				
			}
			var fuck  = metaData;
			var playData = fuck.playData;
			trace(playData);
			var phantomFear = fuck.playerVocalFiles;

			var charData = playData.characters;
			var oF = fuck.opponentVocalFiles;
			if (phantomFear == null) {
				phantomFear = [charData.player];
			}
			if (oF == null) oF = [charData.opponent];
			var data:SwagSong = {
				song: fuck.songName,
				notes: [],
				events: [],
				songFileNames: ['Inst','Voices'],
				playerVocalFiles:phantomFear,
				sfxFiles: [],
				opponentVocalFiles: oF,
				bpm: fuck.timeChanges[0].bpm,
				needsVoices: true,
				disPlayAutoMovingCam: true,
				needsSFX: false,
				igorAutoFix: false,
				arrowSkin: '',
				splashSkin: 'noteSplashes',//idk it would crash if i didn't
				player1: charData.player,
				player2: charData.opponent,
				gfVersion: charData.girlfriend,
				cutsceneType: "none",
				uiType: 'normal',
				speed: Reflect.getProperty(songJson.scrollSpeed,difficu.toLowerCase()),
				composer: fuck.artist,
				songNameChinese: fuck.songName,
				stage: playData.stage,
				validScore: false,
				strums: 2
			};
       var sec:SwagSection = {
		sectionBeats: 4.0,
		bpm: fuck.timeChanges[0].bpm,
		changeBPM: false,
		mustHitSection: true,
		gfSection: false,
		sectionNotes: [],
		typeOfSection: 0,
		altAnim: false,
		altAnimNum: 0,
	crossfadeBf: false,
	crossfadeDad: false
};
			if (Reflect.hasField(songJson.notes,difficu.toLowerCase()))
				{
                    var lmfao:Array<Dynamic> = Reflect.getProperty(songJson.notes,difficu.toLowerCase());
					for (fuckyou in lmfao){
						if (fuckyou.l == null)fuckyou.l = 0;
						if (fuckyou.k == null)fuckyou.k = '';
						var kind = fuckyou.k;
						switch (kind.toLowerCase()){
							case 'normal':
								kind = '';
						}
						sec.sectionNotes.push([fuckyou.t,fuckyou.d,fuckyou.l,kind]);
					}
				}
				var ev:Array<Dynamic> = songJson.events;

				var eventList:Map<String,Array<Array<String>>> = new Map<String,Array<Array<String>>>();
						for (fuckyou in ev){
							var value1 = '';
							var value2 = '';
							var value3 = '';

						    var values:Array<String> = Reflect.fields(fuckyou.v);
						
							switch (fuckyou.e){
								case 'FocusCamera':
									value1 = Std.string(Reflect.field(fuckyou.v,'char'));
									if (Reflect.hasField(fuckyou.v,'x')) value2 = Std.string(Reflect.field(fuckyou.v,'x'));
									if (Reflect.hasField(fuckyou.v,'y')) value3 = Std.string(Reflect.field(fuckyou.v,'y'));
								default:
							switch (values.length){
								case 1:
								value1 = Std.string(Reflect.field(fuckyou.v,values[0]));
								case 2:
									value1 = Std.string(Reflect.field(fuckyou.v,values[0]));
									value2 = Std.string(Reflect.field(fuckyou.v,values[1]));
								case 3:
									value1 = Std.string(Reflect.field(fuckyou.v,values[0]));
									value2 = Std.string(Reflect.field(fuckyou.v,values[1]));
									value3 = Std.string(Reflect.field(fuckyou.v,values[2]));
									
							}
							}
						if (!eventList.exists(Std.string(fuckyou.t)))
							eventList.set(Std.string(fuckyou.t),[]);

						eventList.get(Std.string(fuckyou.t)).push([fuckyou.e,value1,value2,value3]);
					}
					for (i in eventList.keys())
					data.events.push([Std.parseFloat(i),eventList.get(i)]);
					data.notes.push(sec);
					return data;
		}
		
	public static function loadFromJson(jsonInput:String = '', ?folder:String = '',song:Dynamic = null):SwagSong
	{
		var songJson = null;

		if (song == null){
			songJson = parseJSONshit(parse(jsonInput,folder));
		}else{
			songJson = song;
		}
	
		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		if (songJson.song != null){
			if (songJson.playerVocalFiles == null) songJson.playerVocalFiles = [];
			if (songJson.opponentVocalFiles == null) songJson.opponentVocalFiles = [];
			if (songJson.sfxFiles == null) songJson.sfxFiles = [];
			if (songJson.strums == null) songJson.strums = 2;
			if (songJson.igorAutoFix == null) {
				switch (songJson.song.toLowerCase()) {
					case 'monster' | 'winter horrorland' | 'winter-horrorland' | 'Tutorial' | 'bopeebo' | 'fresh' | 'dad battle' | 'dadbattle' | 'dad-battle' |
					'spookeez' | 'south' | 
					'philly-nice' | 'philly nice' | 'pico' | 'blammed' |
					'milf' | 'high' | 'satin panties'| 'satin-panties' |
					'cocoa' | 'eggnog' |
					'senpai' | 'roses' | 'thorns' | 
					'ugh' | 'stress' | 'guns' |
					'darnell' | 'lit-up' | 'litup' | 'lits up' | 'lit up' | 'lits-up' | '2hot' | 'blazin':
					songJson.igorAutoFix = false;
						default:
							songJson.igorAutoFix = false;
				}
			}
			if (songJson.disPlayAutoMovingCam == null) {
				switch (songJson.song.toLowerCase()) {
					case 'monster' | 'winter horrorland' | 'winter-horrorland' | 'Tutorial' | 'bopeebo' | 'fresh' | 'dad battle' | 'dadbattle' | 'dad-battle' |
					'spookeez' | 'south' | 
					'philly-nice' | 'philly nice' | 'pico' | 'blammed' |
					'milf' | 'high' | 'satin panties'| 'satin-panties' |
					'cocoa' | 'eggnog' |
					'senpai' | 'roses' | 'thorns' | 
					'ugh' | 'stress' | 'guns' :
					songJson.disPlayAutoMovingCam = false;
					case 'darnell' | 'lit-up' | 'litup' | 'lits up' | 'lit up' | 'lits-up' | '2hot' | 'blazin':
						
					songJson.disPlayAutoMovingCam = true;
						default:
							songJson.disPlayAutoMovingCam = false;
				}
			}
			if (songJson.songFileNames == null) songJson.songFileNames = ['Inst','Voices'];
		if (songJson.uiType == null) {

			songJson.uiType = switch (songJson.song.toLowerCase()) {
				default:
					'normal';
			}
		}
		if (songJson.songNameChinese == null){
			songJson.songNameChinese = switch (songJson.song.toLowerCase()) {
				default:
					songJson.song;
			
			}
		}
		if (songJson.stage == null) {
			// sw-switch case :fuckboy:
			songJson.stage = switch (songJson.song.toLowerCase()) {
				case 'spookeez' | 'monster' | 'south':
					'spooky';
				case 'philly-nice' | 'philly nice' | 'pico' | 'blammed':
					'philly';
				case 'milf' | 'high' | 'satin panties'| 'satin-panties':
					'limo';
				case 'cocoa' | 'eggnog':
					'mall';
				case 'winter horrorland' | 'winter-horrorland':
					'mallEvil';
				case 'senpai' | 'roses':
					'school';
				case 'thorns':
					'schoolEvil';
				case 'ugh' | 'stress' | 'guns':
					'tank';
				default:
					'stage';
			
			}
		}
		
		
		if (songJson.cutsceneType == null) {
			switch (songJson.song.toLowerCase()) {
				case 'roses':
					songJson.cutsceneType = "angry-senpai";
				case 'senpai':
					songJson.cutsceneType = "senpai";
				case 'monster':
					songJson.cutsceneType = 'monster';
				case 'thorns':
					songJson.cutsceneType = 'spirit';
				case 'winter horrorland' | 'winter-horrorland':
					songJson.cutsceneType = 'winter-horrorland';
					case 'ugh':
						songJson.cutsceneType = 'ugh';
					case 'guns':
						songJson.cutsceneType = 'guns';
					case 'stress':
						songJson.cutsceneType = 'stress';
				default:
					songJson.cutsceneType = 'none';
			}
		}
		if (songJson.composer == null) {
			switch (songJson.song.toLowerCase()) {
				case 'monster' | 'winter horrorland' | 'winter-horrorland':
					songJson.composer = 'bassetfilms';
				case 'Tutorial' | 'bopeebo' | 'fresh' | 'dad battle' | 'dadbattle' | 'dad-battle' |
				'spookeez' | 'south' | 
				'philly-nice' | 'philly nice' | 'pico' | 'blammed' |
				'milf' | 'high' | 'satin panties'| 'satin-panties' |
				'cocoa' | 'eggnog' |
				'senpai' | 'roses' | 'thorns' | 
				'ugh' | 'stress' | 'guns' |
				'darnell' | 'lit-up' | 'litup' | 'lits up' | 'lit up' | 'lits-up' | '2hot' | 'blazin':
					songJson.composer = 'Kawai Sprite';
					default:
					songJson.composer = 'IDK';
			}
		}

		if (songJson.gfVersion == null) {
			// are you kidding me did i really do song to lowercase
			switch (songJson.stage) {
				
					case 'limo':
						songJson.gfVersion = 'gf-car';
					case 'mall':
						songJson.gfVersion = 'gf-christmas';
					case 'mallEvil':
						songJson.gfVersion = 'gf-christmas';
					case 'school' 
					| 'schoolEvil':
					songJson.gfVersion = 'gf-pixel';
					case 'tank':
						songJson.gfVersion = 'gf-tankmen';
						if (songJson.song.toLowerCase() == "stress") {
							songJson.gfVersion = "pico-speaker";
						}
				
				default:
					songJson.gfVersion = 'gf';
			}

		}

	}
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}

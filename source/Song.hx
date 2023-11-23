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

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var songNameChinese:String;
	var events:Array<Dynamic>;
	var bpm:Float;
	var uiType:String;
	var needsVoices:Bool;
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
	//var mania:Null<Int>;
}

class Song
{
	public var uiType:String = 'normal';
	public var song:String;
	public var songNameChinese:String = '';
	public var composer:String = null;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var speed:Float = 1;
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

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			#if sys
			rawJson = File.getContent(SUtil.getPath() + Paths.json(formattedFolder + '/' + formattedSong)).trim();
			#else
			rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
			#end
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
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

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		if (songJson.song != null){
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
				'ugh' | 'stress' | 'guns':
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

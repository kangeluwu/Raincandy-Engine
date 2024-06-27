package;

import openfl.media.Sound;
import title.*;
import config.*;
import transition.data.*;

import flixel.FlxState;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.system.System;
//import openfl.utils.Future;
//import flixel.addons.util.FlxAsyncLoop;
import flixel.system.FlxSound;
using StringTools;
import sys.FileSystem;
import sys.io.File;
class Startup extends FlxState
{

    var splash:FlxSprite;
    //var dummy:FlxSprite;
    var loadingText:FlxText;

    var songsCached:Bool;
    public static final musics:Array<String> =   []; //Start of the non-gameplay songs.



    var graphicsCached:Bool;
    var startCachingGraphics:Bool = false;
    var gfxI:Int = 0;
    var musicxI:Int = 0;
    public static final graphics:Array<String> =    [];

    var cacheStart:Bool = false;
    var dummyMusic:FlxSound;
    public static var thing = false;
    var realstart:Bool = false;
	override function create()
	{

        FlxG.mouse.visible = false;


        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
        #if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

        WeekData.loadTheFirstEnabledMod();
        FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys =  TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys =  TitleState.volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PluginManager.init();
		PlayerSettings.init();

     
        FlxG.save.bind('funkin', 'ninjamuffin99');
        ClientPrefs.loadPrefs();
        /*Switched to a new custom transition system.
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;
        
        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), 
            {asset: diamond, width: 32, height: 32},  new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        */



        Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
        FlxG.mouse.visible = false;

        
        

        loadingText = new FlxText(5, FlxG.height - 30, 0, "", 24);
        loadingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadingText);


    
        dummyMusic = new FlxSound().loadEmbedded(Paths.sound('Boot'));
        super.create();
        new FlxTimer().start(1.1, function(tmr:FlxTimer)
            {
                folderCaches();
    });
    }
    var folders:Array<String> = [SUtil.getPath() + Paths.getPreloadPath() #if MODS_ALLOWED , SUtil.getPath() + 'mods/' #end];
    var cachedFolders:Array<String> = [SUtil.getPath() + Paths.getPreloadPath() #if MODS_ALLOWED , SUtil.getPath() + 'mods/' #end];
    function folderCaches(){
        loadingText.text = "Caching Folders...";
        for (curFolders in folders){
        for(folder in FileSystem.readDirectory(curFolders)){
            var path = haxe.io.Path.join([curFolders, folder]) + '/';
			if (FileSystem.exists(path) && FileSystem.isDirectory(path) && !folders.contains(path)){
                folders.push(path);
            }
           
            if (FileSystem.exists(path) && FileSystem.isDirectory(path) && !cachedFolders.contains(path))
                cachedFolders.push(path);
                
            }
        }

        classification();
    }

    function classification(){
        for (folder in cachedFolders){
        for(file in FileSystem.readDirectory(folder)){
         if (file.endsWith('.png'))
            graphics.push(file);
         if (file.endsWith('.ogg'))
            musics.push(file);

        }
      
    }
    trace(graphics);
    trace(musics);
    realstart = true;
    }
    override function update(elapsed) 
    {
        
        if(!cacheStart && realstart){
            preload();
            cacheStart = true;
         }

         if(songsCached && graphicsCached){
            
            System.gc();

            new FlxTimer().start(0.3, function(tmr:FlxTimer)
            {
                loadingText.text = "Done!";
                new FlxTimer().start(1.1, function(tmr:FlxTimer)
                    {
    

                                FlxG.switchState(new TitleState()); 
                         
                    });
            });
        }
        if(!songsCached && cacheStart)
        preloadMusic();

        if(startCachingGraphics){
            if(gfxI >= graphics.length){
                loadingText.text = "Graphic cached...";
                startCachingGraphics = false;
                graphicsCached = true;
            }
            else{
                FNFAssets.getGraphicData(graphics[gfxI]);
                FlxG.bitmap.add(FNFAssets.getBitmapData(graphics[gfxI]));
                gfxI++;
                loadingText.text = graphics[gfxI] + " Graphic caching...";
            }
        }
        
        super.update(elapsed);

    }

    function preload(){

        loadingText.text = "Caching Assets...";
        
        if(!songsCached){ 
            #if sys sys.thread.Thread.create(() -> { #end
                preloadMusic();
            #if sys }); #end
        }
        

        /*if(!charactersCached){
            var i = 0;
            var charLoadLoop = new FlxAsyncLoop(characters.length, function(){
                ImageCache.add(Paths.file(characters[i], "images", "png"));
                i++;
            }, 1);
        }

        for(x in characters){
            
            //trace("Chached " + x);
        }
        loadingText.text = "Characters cached...";
        charactersCached = true;*/


        

    }

    function preloadMusic(){
        if(musicxI >= musics.length){
            loadingText.text = "Music cached...";
            songsCached = true;
            if(!graphicsCached){
                startCachingGraphics = true;
            }
        }
        else{
            FNFAssets.getSound(musics[musicxI]);
            FlxG.sound.cache(musics[musicxI]);
            musicxI++;
            loadingText.text = musics[musicxI] + " caching...";
        }
       
        

    }



}

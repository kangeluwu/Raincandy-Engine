package;

#if android
import android.Tools;
import android.Permissions;
import android.PermissionsList;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import flash.system.System;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */

using StringTools;

class SUtil
{
	#if android
	private static var aDir:String = null; // android dir
	#end

	public static function getPath():String
	{
		#if android
		if (aDir != null && aDir.length > 0)
			return aDir;
		else
			return aDir = Tools.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
		#else
		return '';
		#end
	}

	public static function doTheCheck()
	{
		#if android
		if (!Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE) || !Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE))
		{
			Permissions.requestPermissions([PermissionsList.READ_EXTERNAL_STORAGE, PermissionsList.WRITE_EXTERNAL_STORAGE]);
			SUtil.applicationAlert('Permissions', "if you acceptd the permissions all good if not expect a crash" + '\n' + 'Press Ok to see what happens');
		}

		if (Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE) || Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE))
		{
			if (!FileSystem.exists(Tools.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file')))
				FileSystem.createDirectory(Tools.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file'));

			if (FileSystem.exists('windose_data') && FileSystem.isDirectory('windose_data') && !FileSystem.exists(SUtil.getPath() + 'windose_data')){
				SUtil.copyContent('windose_data',SUtil.getPath() + 'windose_data');
			}
			if (FileSystem.exists('mods') && FileSystem.isDirectory('mods') && !FileSystem.exists(SUtil.getPath() + 'mods')){
				SUtil.copyContent('mods',SUtil.getPath() + 'mods');
			}
			if (!FileSystem.exists(SUtil.getPath() + 'windose_data') && !FileSystem.exists(SUtil.getPath() + 'mods'))
			{
				SUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the files from the .APK!\nPlease watch the tutorial by pressing OK.");
				CoolUtil.browserLoad('https://b23.tv/qnuSteM');
				System.exit(0);
			}
			else
			{
				if (!FileSystem.exists(SUtil.getPath() + 'windose_data'))
				{
					SUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the assets/windose_data folder from the .APK!\nPlease watch the tutorial by pressing OK.");
					CoolUtil.browserLoad('https://b23.tv/qnuSteM');
					System.exit(0);
				}

				if (!FileSystem.exists(SUtil.getPath() + 'mods'))
				{
					SUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the assets/mods folder from the .APK!\nPlease watch the tutorial by pressing OK.");
					CoolUtil.browserLoad('https://b23.tv/qnuSteM');
					System.exit(0);
				}
			}
			if (!FileSystem.exists(SUtil.getPath() + "crash")){
				FileSystem.createDirectory(SUtil.getPath() + "crash");
			}
			if (!FileSystem.exists(SUtil.getPath() + "saves")){
				FileSystem.createDirectory(SUtil.getPath() + "saves");
			}
		}
		#elseif mobile
		

		if (!FileSystem.exists('./windose_data/') && !FileSystem.exists(SUtil.getPath() + './mods/'))
		{
			SUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the files from the .APK!\nPlease watch the tutorial by pressing OK.");
			CoolUtil.browserLoad('https://b23.tv/qnuSteM');
			System.exit(0);
		}
		else
		{
			if (FileSystem.exists('windose_data') && !FileSystem.exists(SUtil.getPath() + 'windose_data')){
				SUtil.copyContent('windose_data',SUtil.getPath() + 'windose_data');
			}
			if (FileSystem.exists('mods') && !FileSystem.exists(SUtil.getPath() + 'mods')){
				SUtil.copyContent('mods',SUtil.getPath() + 'mods');
			}
			if (!FileSystem.exists('./windose_data/'))
			{
				SUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the assets/windose_data folder from the .APK!\nPlease watch the tutorial by pressing OK.");
				CoolUtil.browserLoad('https://b23.tv/qnuSteM');
				System.exit(0);
			}

			if (!FileSystem.exists('./mods/'))
			{
				SUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the assets/mods folder from the .APK!\nPlease watch the tutorial by pressing OK.");
				CoolUtil.browserLoad('https://b23.tv/qnuSteM');
				System.exit(0);
			}
		}
		if (!FileSystem.exists("./crash/")){
			FileSystem.createDirectory("./crash/");
		}
		if (!FileSystem.exists("./saves/")){
			FileSystem.createDirectory("./saves/");
		}
		if (!FileSystem.exists("./mods/") && !FileSystem.exists("./windose_data/")){
			File.saveContent("./Paste the Assets and Mods folders here.txt", "the file name says all");
		}
		#end
	}

//	public static function gameCrashCheck()
//	{
//		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
//	}

/*	public static function onCrash(e:UncaughtErrorEvent):Void bruh we had one crash handler
	{
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		var path:String = "crash/" + "crash_" + dateNow + ".txt";
		var errMsg:String = "";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += e.error;

		if (!FileSystem.exists(SUtil.getPath() + "crash"))
		FileSystem.createDirectory(SUtil.getPath() + "crash");

		File.saveContent(SUtil.getPath() + path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		Sys.println("Making a simple alert ...");

		SUtil.applicationAlert("Uncaught Error :(!", errMsg);
		System.exit(0);
	}
*/
	private static function applicationAlert(title:String, description:String)
	{
		Application.current.window.alert(description, title);
	}

	#if mobile
	static public function saveContent(fileName:String = "file", fileData:String = "you forgot something to add in your code", fileExtension:String = "" ){
		#if android
		#if MODS_ALLOWED
		if (!FileSystem.exists(SUtil.getPath() + "saves")){
			FileSystem.createDirectory(SUtil.getPath() + "saves");
		}

		File.saveContent(SUtil.getPath() + "saves/" + fileName + fileExtension, fileData);
		SUtil.applicationAlert("Done Action :)", "File Saved Successfully!");
		#else
		openfl.system.System.setClipboard(fileData);
		SUtil.applicationAlert("Done Action :)", "Data Saved to Clipboard Successfully!");
		#end
		#else
		#if MODS_ALLOWED
		if (!FileSystem.exists("./saves/")){
			FileSystem.createDirectory("./saves/");
		}

		File.saveContent("./saves/" + fileName + fileExtension, fileData);
		SUtil.applicationAlert("Done Action :)", "File Saved Successfully!");
		#else
		openfl.system.System.setClipboard(fileData);
		SUtil.applicationAlert("Done Action :)", "Data Saved to Clipboard Successfully!");
		
		#end
		#end
	}
    
    public static function AutosaveContent(fileName:String = 'file', fileData:String = "you forgot something to add in your code", fileExtension:String = "")
	{
		#if android
		#if MODS_ALLOWED
		if (!FileSystem.exists(SUtil.getPath() + "saves")){
			FileSystem.createDirectory(SUtil.getPath() + "saves");
		}

		File.saveContent(SUtil.getPath() + "saves/" + fileName + fileExtension, fileData);
		//SUtil.applicationAlert("Done Action :)", "File Saved Successfully!");
		#else
		openfl.system.System.setClipboard(fileData);
		//SUtil.applicationAlert("Done Action :)", "Data Saved to Clipboard Successfully!");
		#end
		#else
		#if MODS_ALLOWED
		if (!FileSystem.exists("./saves/")){
			FileSystem.createDirectory("./saves/");
		}

		File.saveContent("./saves/" + fileName + fileExtension, fileData);
		//SUtil.applicationAlert("Done Action :)", "File Saved Successfully!");
		#else
		openfl.system.System.setClipboard(fileData);
		//SUtil.applicationAlert("Done Action :)", "Data Saved to Clipboard Successfully!");
		
		#end
		#end
	}
	
	public static function saveClipboard(fileData:String = 'you forgot something to add in your code')
	{
		openfl.system.System.setClipboard(fileData);
		SUtil.applicationAlert('Done :)!', 'Data Saved to Clipboard Successfully!');
	}

	static public function copyContent(copyPath:String, savePath:String) {
		if (!FileSystem.exists(savePath)){
			var bytes = OpenFlAssets.getBytes(copyPath);
			File.saveBytes(savePath, bytes);
		}
	}
	#end
} 
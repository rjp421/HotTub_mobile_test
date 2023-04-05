package me.whohacked.app
{
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
	
	public class AppWide_Singleton
	{
		// version 4, date 02-17-2018, build 01
		public var version:Number = 40217201801;
		public var debugMode:Boolean = true;
		
		public var localCamera:Camera;
		public var localMic:Microphone;
		public var isMediaPrivate:Boolean = false;
		
		public var appInfoObj:Object;
		public var userInfoObj:Object;
		public var compatibilityInfoObj:Object;
		public var clientStatsInfoObj:Object;
		
		public var userList_AC:ArrayCollection;
		public var usersWithVideoOn_A:Array;
		public var dockedUserIDs_A:Array;
		
		public var camSpotIDs_A:Array;
		public var largeCamIDs_A:Array;
		public var numTotalCamSpots:Number;
		public var numVisibleCamSpots:Number;
		public var backgroundCamSpotIDs_A:Array;
		
		public var openPopUps_A:Array;
		
		public var mediaSO:SharedObject;
		public var usersSO:SharedObject;
		
		private var __appWideEventDispatcher:AppWideEventDispatcher_Singleton;
		private var __initialized:Boolean = false;
		private static var __instance:AppWide_Singleton;
		
		
		
		public function AppWide_Singleton()
		{
			if (__instance)
				throw new Error("AppWide_Singleton is a singleton class, use .getInstance() instead!");
			
			init(); // instantiate the initial components
		}
		
		
		private function init():void // instantiate the static variables
		{
			if (!__initialized) // if this Singleton has not been instantiated yet
			{
				__initialized = true; // the class has now been instantiated
			}
			
			appInfoObj = {};
			compatibilityInfoObj = {};
			clientStatsInfoObj = {};
			
			userInfoObj = {};
			userInfoObj.clientID = 0;
			userInfoObj.acctID = 0;
			userInfoObj.acctName = '';
			userInfoObj.userID = 0;
			userInfoObj.userName = '';
			userInfoObj.adminType = 'notadmin';
			userInfoObj.isMyVideoOn = false;
			userInfoObj.isMyAudioOn = false;
			
			userInfoObj.viewedByUserIDs_A = [];
			userInfoObj.heardByUserIDs_A = [];
			userInfoObj.ignores = {};
			
			appInfoObj.version = this.version;
			appInfoObj.previousClientID = 0;
			appInfoObj.debugMode = this.debugMode;
			
			userList_AC = new ArrayCollection();
			userList_AC.enableAutoUpdate();
			
			openPopUps_A = [];
			dockedUserIDs_A = [];
			usersWithVideoOn_A = [];
			
			camSpotIDs_A = [];
			largeCamIDs_A = [];
			backgroundCamSpotIDs_A = [];
			
			numTotalCamSpots = 0;
			numVisibleCamSpots = 0;
			
			localCamera = null;
			localMic = null;
			
			__appWideEventDispatcher = AppWideEventDispatcher_Singleton.getInstance();
			__appWideEventDispatcher.addEventListener('onApplicationComplete', onApplicationComplete, false,0,true);
			__appWideEventDispatcher.addEventListener('appClose', appClose, false,0,true);
		}
		
		
		private function onApplicationComplete(event:Event):void
		{
			debugMsg("onApplicationComplete->  ");
			
			setAppInfo("login", "");
			setAppInfo("pass", "");
			setAppInfo("defaultQuality", "hd");
			setAppInfo("chatDebugMode", false);
			
			setAppInfo("isBanned", false);
			setAppInfo("isSavePasswordChecked", false);
			
			setAppInfo("isAllCamsOffChecked", false);
			setAppInfo("isAllAudioOffChecked", true);
			setAppInfo("isAllFontSizeChecked", true);
			setAppInfo("isAutoFillCamsChecked", true);
			
			setAppInfo("fontBold", false);
			setAppInfo("fontItalics", false);
			setAppInfo("fontUnderline", false);
			setAppInfo("fontColor", 000000);
			setAppInfo("fontSize", 24);
		}
		
		
		private function onApplicationStateChange(event:Event):void
		{
			debugMsg("onApplicationStateChange->  applicationState: "+appInfoObj.applicationState);
			
			event = null;
		}
		
		
		public function setAppInfo(arg:String, val:*):void
		{
			debugMsg("setAppInfo->  " +  arg + " = " + val);
			
			if (arg == 'debugMode') debugMode = val;
			
			appInfoObj[arg] = val;
			
			val = null;
			arg = null;
		}
		
		
		public function setCompatibilityInfo(arg:String, val:*):void
		{
			debugMsg("setCompatibilityInfo->  " +  arg + " = " + val);
			
			compatibilityInfoObj[arg] = val;
			
			val = null;
			arg = null;
		}
		
		
		public static function getInstance():AppWide_Singleton
		{
			if(__instance==null)
			{
				__instance = new AppWide_Singleton();
			}
			return __instance;
		}
		
		
		public static function getLocalCamera():Camera
		{
			if(__instance==null)
			{
				__instance = new AppWide_Singleton();
			}
			return __instance.localCamera;
		}
		
		
		public static function getAppInfoObj():Object
		{
			if(__instance==null)
			{
				__instance = new AppWide_Singleton();
			}
			return __instance.appInfoObj;
		}
		
		
		public static function getUserInfoObj():Object
		{
			if(__instance==null)
			{
				__instance = new AppWide_Singleton();
			}
			return __instance.userInfoObj;
		}
		
		
		public static function getUserList_AC():ArrayCollection
		{
			if(__instance==null)
			{
				__instance = new AppWide_Singleton();
			}
			return __instance.userList_AC;
		}
		
		
		public function getUserObj():Object
		{
			var x:Object = {};
			return x;
		}
		
		
		
		
		private function onUserLoggedIn():void
		{
		}
		
		
		private function beginLogout():void
		{
		}
		
		
		
		private function appClose(event:Event):void
		{
			debugMsg("appClose->  ");
			
			// clear the user list
			userList_AC.removeAll();
			
			// clear the dockedUserIDs_A
			// and usersWithVideoOn_A
			// TODO:
			// do this during clearCamSpot on close?
			//dockedUserIDs_A.splice(0);
			//usersWithVideoOn_A.splice(0);
			
			// reset the userInfoObj
			userInfoObj.clientID = 0;
			userInfoObj.acctID = 0;
			userInfoObj.acctName = '';
			userInfoObj.userID = 0;
			userInfoObj.userName = '';
			userInfoObj.adminType = 'notadmin';
			userInfoObj.isMyVideoOn = false;
			userInfoObj.isMyAudioOn = false;
			userInfoObj.viewedByUserIDs_A.splice(0);
			userInfoObj.heardByUserIDs_A.splice(0);
			userInfoObj.ignores = {};
			
			localCamera = null;
			localMic = null;
			
			event = null;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function debugMsg(str:String):void
		{
			AppWideDebug_Singleton.getInstance().newDebugMessage('AppWideSingleton', str);
			str = null;
		}
		
		
		
		
		
	} // end class
} // end package
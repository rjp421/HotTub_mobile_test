package me.whohacked.app
{
	import flash.events.EventDispatcher;
	
	import me.whohacked.events.CustomEvent;
	
	public class AppWideDebug_Singleton extends EventDispatcher
	{
		
		private var __initialized:Boolean = false;
		private static var __instance:AppWideDebug_Singleton;
		
		
		public function AppWideDebug_Singleton()
		{
			if (__instance)
				throw new Error("AppWideDebug_Singleton is a singleton class, use .getInstance() instead!");
			
			init(); // instantiate the initial components
		}
		
		
		private function init():void // instantiate the static variables
		{
			if (!__initialized) // if this Singleton has not been instantiated yet
			{
				__initialized = true; // the class has now been instantiated
			}
		}
		
		
		public static function getInstance():AppWideDebug_Singleton
		{
			if(__instance==null)
			{
				__instance = new AppWideDebug_Singleton();
			}
			
			return __instance;
		}
		
		
		public function newDebugMessage(_src:String, _msg:String):void
		{
			var _appWideSingleton:AppWide_Singleton = AppWide_Singleton.getInstance();
			
			if ((!_src) || 
				(!_appWideSingleton.appInfoObj.debugMode) && 
				(!_appWideSingleton.appInfoObj.chatDebugMode)) 
				return;
			
			var msgObj:Object;
			var tmpArr:Array = _src.split(".");
			var tmpStr:String = tmpArr[tmpArr.length-1];
			
			if (tmpStr.indexOf("]")!=-1)
			{
				_src = tmpStr.split("]")[0].split(" ")[1];
				msgObj = {src:_src, msg:_msg};
			} else {
				msgObj = {src:tmpStr, msg:_msg};
			}
			
			if (_appWideSingleton.appInfoObj.debugMode)
			{
				trace("[" +new Date().toLocaleString() + "]  " + msgObj.src+" | "+msgObj.msg);
			}
			
			if (_appWideSingleton.appInfoObj.chatDebugMode)
			{
				msgObj.isDebugMessage = true;
				
				AppWideEventDispatcher_Singleton.getInstance().dispatchEvent(new CustomEvent('receiveChatMessage', false,false, msgObj));
			}
			
			tmpStr = null;
			tmpArr = null;
			msgObj = null;
			_msg = null;
			_src = null;
		}
		
		
		
	} // end class
} // end package
/*
flex45_fms_videochat v1.0 by b0nghitter
http://www.toketub.tv
*/
package me.whohacked.net
{
	import flash.net.Responder;
	
	import me.whohacked.app.AppWideDebug_Singleton;
	import me.whohacked.app.AppWideEventDispatcher_Singleton;
	import me.whohacked.events.CustomEvent;
	
	//import flash.net.ObjectEncoding;
	
	
	public class NetConnectionManager_Singleton
	{
		
		private static var __instance:NetConnectionManager_Singleton;
		
		private var __initialized:Boolean = false;
		private var __appWideEventDispatcher:AppWideEventDispatcher_Singleton;
		private var __nc:AppWideNetConnection;
		
		
		
		public function NetConnectionManager_Singleton()
		{
			if (__instance)
				throw new Error("NetConnectionManager_Singleton is a singleton class, use .getInstance() instead!");
			
			init(); // instantiate the initial components
		}
		
		
		private function init():void // instantiate the static variables
		{
			if (!__initialized) // if this Singleton has not been instantiated yet
			{
				__initialized = true; // the class has now been instantiated
			}
			
			__appWideEventDispatcher = AppWideEventDispatcher_Singleton.getInstance();
			
			__nc = new AppWideNetConnection();
		}
		
		
		
		public static function getInstance():NetConnectionManager_Singleton
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
			
			return __instance;
		}
		
		
		public static function connect(fmsProtocol:String, fmsServer:String=null, fmsApp:String=null, fmsAppInstance:String="_definst_", params:Object=null):void
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
			
			createNetConnection(fmsProtocol, fmsServer, fmsApp, fmsAppInstance, params);
		}
		
		
		public static function createNetConnection(fmsProtocol:String, fmsServer:String=null, fmsApp:String=null, fmsAppInstance:String="_definst_", params:Object=null):void
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
			
			if (!__instance.__nc.connected)
			{
				__instance.debugMsg("createNetConnection->  fmsServer: "+fmsServer+"  fmsApp: "+fmsApp+"  fmsAppInstance: "+fmsAppInstance+"  params: "+params);
				
				// dispatch a custom .Connecting event
				var eventObj:Object = {info:{code:"NetConnection.Connect.Connecting", level:"Status"}};
				
				//nc.objectEncoding = ObjectEncoding.AMF0; // used for server-side stream debugging only
				__instance.__nc.connect(fmsProtocol + "://" + fmsServer + "/" + fmsApp + "/" + fmsAppInstance, params);
				
				// NetConnection Status Event handler
				__instance.__appWideEventDispatcher.dispatchEvent(new CustomEvent("onNCStatus", false,false, eventObj));
			}
		}
		
		
		public static function disconnect():void
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
			
			if (__instance.__nc.connected)
			{
				__instance.__nc.close(); // disconect the NetConnection if connected
			}
		}
		
		
		public static function getNetConnection():AppWideNetConnection
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
			
			return __instance.__nc;
		}
		
		
		// close and nullify everything for garbage collection, unused atm
		public static function clean():void
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
		}
		
		
		public static function callServerMethod(method:String='', responder:Responder=null, obj:Object=null):void
		{
			if (__instance==null)
			{
				__instance = new NetConnectionManager_Singleton();
			}
			
			//debugMsg("callServerMethod-|>  responder: "+responder+"  method: "+method+"  obj: "+obj);
			if (__instance.__nc.connected)
			{
				__instance.__nc.call(method, responder, obj);
			}
		}
		
		
		
		
		
		
		
		
		
		private function debugMsg(str:String):void
		{
			AppWideDebug_Singleton.getInstance().newDebugMessage('NetConnectionManager',str);
			str = null;
		}
		
		
	} // end class
} // end package
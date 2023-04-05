package me.whohacked.net
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	
	import me.whohacked.app.AppWideEventDispatcher_Singleton;
	import me.whohacked.events.CustomEvent;
	
	
	public class AppWideNetConnection extends NetConnection
	{
		
		public var __appWideEventDispatcher:AppWideEventDispatcher_Singleton;
		
		
		
		public function AppWideNetConnection()
		{
			super();
			
			this.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus, false,0,true); // listen for events from the NetConnection
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false,0,true); // listen for SecurityError
			this.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false,0,true); // listen for AsyncError
			this.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false,0,true); // listen for IOError
			
			this.client = new NetConnectionClient();
			
			__appWideEventDispatcher = AppWideEventDispatcher_Singleton.getInstance();
		}
		
		
		private function onNetConnectionStatus(event:NetStatusEvent):void
		{
			trace("AppWideNetConnection | onNCStatus->  info.level: "+event.info.level+"  info.type: "+event.type+"  info.code: "+event.info.code);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("onNCStatus",false,false, event.clone()));
		}
		
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("AppWideNetConnection | onSecurityError->  " + event.text);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("onNCStatus",false,false, event.clone()));
		}
		
		
		private function onAsyncError(event:AsyncErrorEvent):void
		{
			trace("AppWideNetConnection | onAsyncError->  " + event.error.message);
			
			//__appWideEventDispatcher.dispatchEvent(new CustomEvent("onNCStatus",false,false, event.clone()));
		}
		
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("AppWideNetConnection | onIOError->  " + event.text);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("onNCStatus",false,false, event.clone()));
		}
		
		
	} // end class
} // end package
package me.whohacked.net
{
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	
	import me.whohacked.app.AppWideEventDispatcher_Singleton;
	import me.whohacked.events.CustomEvent;
	
	
	public class NetConnectionManager_old extends NetConnection
	{
		
		
		public function NetConnectionManager_old()
		{
			super();
			addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		
		public function createNetConnection(command:String, ... arguments):void
		{
			arguments.unshift(command);
			super.connect.apply(this, arguments);
			trace("|###| NetConnectionManager.createNetConnection |###|>  command: "+command+"  arguments: "+arguments);
		}
		
		
		protected function onConnectionStatus(event:NetStatusEvent):void
		{
			trace("|###| NetConnectionManager.onConnectionStatus |###|>  " + event.info.code);
			
			var infoObjectsArray:Array = event.info.code.split(".");
			
			if (infoObjectsArray[1] == "Connect"){
				switch (infoObjectsArray[2]){
					case "Success":
						dispatchEvent(new CustomEvent("onConnect", false, false, event.info));
						trace("|###| NetConnectionManager.onConnectionStatus |###|>  CONNECTION SUCCESSFULL!");
						break;
					case "Failed":
						dispatchEvent(new CustomEvent("onFailed", false, false, event.info));
						trace("|###| NetConnectionManager.onConnectionStatus |###|>  CONNECTION FAILED!");
						break;
					case "Rejected":
						dispatchEvent(new CustomEvent("onRejected", false, false, event.info));
						trace("|###| NetConnectionManager.onConnectionStatus |###|>  CONNECTION REJECTED!");
						break;
					case "Closed":
						dispatchEvent(new CustomEvent("onClosed", false, false, event.info));
						trace("|###| NetConnectionManager.onConnectionStatus |###|>  CONNECTION CLOSED!");
						break;
				}
			}
		}		
		
		
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("|###| NetConnectionManager.onSecurityError |###|>  " + event.text);
		}
		
		
		protected function onAsyncError(event:AsyncErrorEvent):void
		{
			trace("|###| NetConnectionManager.onAsyncError |###|>  " + event.error.message);
		}
		
		
		protected function onIOError(event:IOErrorEvent):void
		{
			trace("|###| NetConnectionManager.onIOError |###|>  " + event.text);
		}
		
		
	}
	
}
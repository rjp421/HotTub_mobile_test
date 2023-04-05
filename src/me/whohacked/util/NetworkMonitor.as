package me.whohacked.util
{
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	import air.net.URLMonitor;
	
	
	public class NetworkMonitor
	{
		
		[Bindable]
		public var online:Boolean = false;
		
		protected var monitor:URLMonitor;
		
		
		public function NetworkMonitor()
		{
			monitor = new URLMonitor(new URLRequest('http://www.adobe.com'));
			monitor.addEventListener(StatusEvent.STATUS, onStatusUpdate);
			monitor.pollInterval = 10000;
			monitor.start();
		}
		
		
		protected function onStatusUpdate(event:Event):void
		{
			online = monitor.available;
		}
		
		
	}
}
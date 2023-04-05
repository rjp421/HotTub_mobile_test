/*
	FMS videochat by rjp421
*/

/* THIS CLASS IS BASED ON CODE FROM http://www.FMSGuru.com A GREAT RESOURCE FOR FMS */

package me.whohacked.events
{
	import flash.events.Event;
	
	public class DebugEvent extends Event
	{
		
		public var eventObj:Object;
		
		
		public function DebugEvent(type:String, bubbles:Boolean, cancelable:Boolean, _eventObj:Object)
		{
			//trace("|###| DebugEvent |###|>  LOADED | type: "+type+" eventObj: "+_eventObj);
			super(type, bubbles, cancelable);
			eventObj = _eventObj;
		}
		
		
		override public function clone():Event
		{
			return new DebugEvent(type, bubbles, cancelable, eventObj);
		}
		
		
		override public function toString():String
		{
			return formatToString("DebugEvent", "type", "bubbles", "cancelable", "eventPhase", "eventObj");
		}
		
	}
}
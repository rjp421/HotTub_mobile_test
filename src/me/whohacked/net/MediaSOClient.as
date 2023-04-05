/*
BongTVLive.com Hot Tub 2.0 beta7 by b0nghitter
*/
package me.whohacked.net
{
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import me.whohacked.app.AppWideEventDispatcher_Singleton;
	import me.whohacked.events.CustomEvent;
	
	
	public class MediaSOClient extends EventDispatcher
	{
		
		private var __appWideEventDispatcher:AppWideEventDispatcher_Singleton;
		
		
		public function MediaSOClient(target:IEventDispatcher=null)
		{
			__appWideEventDispatcher = AppWideEventDispatcher_Singleton.getInstance();
		}
		
		
		public function userVideoOn(_userID:Number):void
		{
			//trace("|###| MediaSOClient.userVideoOn |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userVideoOn", false,false, {userID:_userID}));
		}
		
		
		public function userVideoOff(_userID:Number):void
		{
			//trace("|###| MediaSOClient.userVideoOff |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userVideoOff", false,false, {userID:_userID}));
		}
		
		
		public function userAudioOn(_userID:Number):void
		{
			//trace("|###| MediaSOClient.userAudioOn |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userAudioOn", false,false, {userID:_userID}));
		}
		
		
		public function userAudioOff(_userID:Number):void
		{
			//trace("|###| MediaSOClient.userAudioOff |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userAudioOff", false,false, {userID:_userID}));
		}
		
		
		
		
		
	}//end class
}//end package
/*
BongTVLive.com Hot Tub 2.0 beta7 by b0nghitter
*/
package me.whohacked.net
{
	
		
	import me.whohacked.app.AppWideDebug_Singleton;
	import me.whohacked.app.AppWideEventDispatcher_Singleton;
	import me.whohacked.events.CustomEvent;
	
	
	public class NetConnectionClient
	{
		
		private var __appWideEventDispatcher:AppWideEventDispatcher_Singleton;
		
		
		
		public function NetConnectionClient()
		{
			debugMsg("->  LOADED");
			
			__appWideEventDispatcher = AppWideEventDispatcher_Singleton.getInstance();
		}
		
		
		public function loginFail(reason:String):void
		{
			debugMsg("loginFail->  LOGIN FAILED  reason: "+reason);
			
			var msgObj:Object = new Object();
			msgObj.reason = reason;
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("loginFailed", false, false, msgObj));
			
			msgObj = null; 
			reason = null;
		}
		
		
		// listen for setUserID from the server, then dispatch createLobby along with the userID
		public function setUserID(clientID:String, acctID:String, userID:String, userName:String, userListObj:Object, blockedUsersObj:Object):void
		{
			debugMsg("setUserID->  clientID: "+clientID+"  acctID: "+acctID+"  userID: "+userID+"  userName: "+userName/*+"  userListObj: "+userListObj*/);
			
			var tmpObj:Object = new Object();
			tmpObj.clientID = clientID;
			tmpObj.acctID = acctID;
			tmpObj.userID = userID;
			tmpObj.userName = userName;
			tmpObj.userListObj = userListObj;
			tmpObj.blockedUsersObj = blockedUsersObj;
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("onSetUserID", false, false, tmpObj));
			
			tmpObj = null;
			blockedUsersObj = null;
			userListObj = null;
			userName = null;
			userID = null;
			acctID = null;
			clientID = null;
		}
		
		
		public function receiveMessage(msgObj:Object):void
		{
			//debugMsg("receiveMessage->  userName: "+msgObj.userName+"  msg: "+msgObj.msg);
			__appWideEventDispatcher.dispatchEvent(new CustomEvent('receiveChatMessage', false, false, msgObj));
			
			msgObj = null;
		}
		
		
		public function receivePrivateMessage(msgObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("receivePrivateMessage", false, false, msgObj));
			
			msgObj = null;
		}
		
		
		public function receiveBannedUsers(bannedUsersObj:Object):void
		{
			//debugMsg("NetConnectionClient.receiveBannedUsers|>  bannedUsersObj: "+bannedUsersObj);
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("receiveBannedUsers", false, false, bannedUsersObj));
			bannedUsersObj = null;
		}
		
		
		public function showAdminMessage(msgObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("showAdminMessage", false, false, msgObj));
			msgObj = null;
		}
		
		
		public function setHost(userID:Number):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("setHost", false, false, {userID:userID}));
		}
		
		
		public function kicked(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("kicked", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function banned(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("banned", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function ignoredUser(ignoreInfo:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("ignoredUser", false, false, ignoreInfo));
			ignoreInfo = null;
		}
		
		
		public function unignoredUser(ignoreInfo:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("unignoredUser", false, false, ignoreInfo));
			ignoreInfo = null;
		}
		
		
		public function getUserIP(ip:String):void
		{
			var ipInfo:Object = new Object();
			ipInfo.ip = ip;
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("getUserIP", false, false, ipInfo));
			
			ip = null;
			ipInfo = null;
		}
		
		
		public function userAskingPermissionToView(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userAskingPermissionToView", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userStartedViewing(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userStartedViewing", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userStoppedViewing(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userStoppedViewing", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userStartedListening(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userStartedListening", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userStoppedListening(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userStoppedListening", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userList_onGetUserList(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userListPanel_onGetUserList", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userList_addUser(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userListPanel_addUser", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		public function userList_removeUser(tmpObj:Object):void
		{
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("userListPanel_removeUser", false, false, tmpObj));
			tmpObj = null;
		}
		
		
		
		public function userVideoOn(_userID:Number):void
		{
			//trace("|###| NetConnectionClient.userVideoOn |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userVideoOn", false,false, {userID:_userID}));
		}
		
		
		public function userVideoOff(_userID:Number):void
		{
			//trace("|###| NetConnectionClient.userVideoOff |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userVideoOff", false,false, {userID:_userID}));
		}
		
		
		public function userAudioOn(_userID:Number):void
		{
			//trace("|###| NetConnectionClient.userAudioOn |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userAudioOn", false,false, {userID:_userID}));
		}
		
		
		public function userAudioOff(_userID:Number):void
		{
			//trace("|###| NetConnectionClient.userAudioOff |###|>  userID: " + _userID);
			
			__appWideEventDispatcher.dispatchEvent(new CustomEvent("mediaSOClient_userAudioOff", false,false, {userID:_userID}));
		}
		
		
		public function close():void
		{
		}
		
		
		
		public function onBWCheck(... rest):Number
		{
			debugMsg("onBWCheck->  CALLED");
			return 0;
		}
		
		
		public function onBWDone(... rest):void
		{
			var bitrate:Number;
			if (rest.length > 0)
			{
				bitrate = rest[0];
			}
			debugMsg("onBWDone->  BANDWIDTH = "+bitrate+" Kbit/s");
		}
		
		
		
		private function debugMsg(str:String):void
		{
			AppWideDebug_Singleton.getInstance().newDebugMessage('NetConnectionClient',str);
			
			str = null;
		}
		
		
		
	}// end class
}// end package
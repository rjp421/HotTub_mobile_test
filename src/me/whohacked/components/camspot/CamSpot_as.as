import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.DragSource;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.managers.DragManager;

import spark.components.Group;

import me.whohacked.app.AppWideDebug_Singleton;
import me.whohacked.app.AppWide_Singleton;
import me.whohacked.events.CustomEvent;
import me.whohacked.net.NetConnectionManager_Singleton;


private var __camSpot_Video:Video;
private var __camSpot_NS:NetStream;
private var __appWideSingleton:AppWide_Singleton;
private var __camSpot_ST:SoundTransform;

public var isPlayingVideo:Boolean = false;
public var isPlayingAudio:Boolean = false;
public var wasPlayingVideo:Boolean = false;
public var wasPlayingAudio:Boolean = false;
public var isHidden:Boolean = false;


public var userInfoObj:Object;
public var userMetaData:Object;
public var currentDragSource:DragSource;


[@Embed(source='../../assets/videoOn.png')]
[Bindable]
private var videoOnImg:Class;

[@Embed(source='../../assets/videoOff.png')]
[Bindable]
private var videoOffImg:Class;

[@Embed(source='../../assets/audioOn.png')]
[Bindable]
private var audioOnImg:Class;

[@Embed(source='../../assets/audioOff.png')]
[Bindable]
private var audioOffImg:Class;

[@Embed(source='../../assets/arrow.png')]
[Bindable]
private var arrowImg:Class;

[@Embed(source='../../assets/x.png')]
[Bindable]
private var xImg:Class;

[@Embed(source='../../assets/images/whohackedmechat_greycamspotbg_dropshadow_320x240.png')]
[Bindable]
private var camSpotBGImg:Class;




private function camSpotCreationCompleteHandler(event:FlexEvent):void
{
	__appWideSingleton = AppWide_Singleton.getInstance();
	__appWideSingleton.numTotalCamSpots++;
	__appWideSingleton.numVisibleCamSpots++;
	
	//this.id = 'camSpot' + (__appWideSingleton.camSpotIDs_A.length + 1);
	
	debugMsg("camSpotCreationCompleteHandler->  LOADED  id: " + this.id);
	
	if (__appWideSingleton.camSpotIDs_A.indexOf(this.id) == -1)
	{
		__appWideSingleton.camSpotIDs_A.push(this.id);
		__appWideSingleton.camSpotIDs_A.sort();
	}
	
	/* if the cam is large */
	if ((width >= 320) || (height >= 320))
	{
		/* add it to the large cams array */
		__appWideSingleton.largeCamIDs_A.push(this.id);
		__appWideSingleton.largeCamIDs_A.sort();
		
		userName_L.width = (camSpot_UIC.width - 40);
		userName_L.height = 18;
		
		userName_L.setStyle("fontSize", 18);
		
		camSpotVolume_VS.height = 80;
	} else {
		userName_L.width = (camSpot_UIC.width - 20);
		
		arrowImgBtn.toolTip = "Swap with a large cam";
		
		camSpot_mainGroup.width = 160;
		camSpot_mainGroup.height = 120;
		camSpotGroup.width = 160;
		camSpotGroup.height = 120;
		camSpot_UIC.width = 160;
		camSpot_UIC.height = 120;
		
		btnVGroup.width = 15;
		
		xImgBtn.width = 15;
		xImgBtn.height = 15;
		arrowImgBtn.width = 15;
		arrowImgBtn.height = 15;
		videoOnOffBtn.width = 15;
		videoOnOffBtn.height = 15;
		audioOnOffBtn.width = 15;
		audioOnOffBtn.height = 15;
		camSpotVolume_VS.width = 15;
	}
	
	if (!__camSpot_Video)
	{
		// add the video to the camSpot_UIC
		__camSpot_Video = new Video(camSpot_UIC.width, camSpot_UIC.height);
		camSpot_UIC.addChild(__camSpot_Video);
	}
	
	__camSpot_Video.width = camSpot_UIC.width;
	__camSpot_Video.height = camSpot_UIC.height;
	
	setupUserInfoObj();
}


private function setupUserInfoObj():void
{
	// setup the default userInfoObj vars
	userInfoObj = new Object();
	userInfoObj.acctID = '0';
	userInfoObj.acctName = "";
	userInfoObj.userID = '0';
	userInfoObj.userName = "";
	userInfoObj.defaultQuality = "high";
	userInfoObj.isPrivate = false;
	userInfoObj.isUsersVideoOn = false;
	userInfoObj.isUsersAudioOn = false;
	userInfoObj.viewedByUserIDs_A = [];
	userInfoObj.heardByUserIDs_A = [];
	userInfoObj.volume = 0.7;
	
	userMetaData = new Object();
}


// if no NetStream exists, setup the NetStream and connect it 
// to the NetConnection, else remove and recreate the NetStream
// this is a NetStream FROM the server
private function setupNetStream():void
{
	// create/connect the NetStream if it hasnt been created yet
	if (!__camSpot_NS)
	{
		debugMsg("setupNetStream->  CREATING NEW NetStream");
		
		__camSpot_NS = new NetStream(NetConnectionManager_Singleton.getNetConnection());
		
		// listen for NetStatusEvents on the NetStream
		if (!__camSpot_NS.hasEventListener(NetStatusEvent.NET_STATUS)) { __camSpot_NS.addEventListener(NetStatusEvent.NET_STATUS, netStreamStatusEventHandler, false,0,true); }
		if (!__camSpot_NS.hasEventListener(AsyncErrorEvent.ASYNC_ERROR)) { __camSpot_NS.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netStreamAsyncErrorHandler, false,0,true); }
		
		// set the NetStreams client to this so this class will handle function calls over the NetStream
		__camSpot_NS.client = this;
		
		// set the buffer time of the NetStream. live streams usually use 0)
		__camSpot_NS.inBufferSeek = true; // TEST
		__camSpot_NS.useJitterBuffer = true;
		__camSpot_NS.bufferTime = 0.000; // was 0.05
		__camSpot_NS.bufferTimeMax = 0.000;
		__camSpot_NS.maxPauseBufferTime = 0.000;
		__camSpot_NS.backBufferTime = 0.000;
		
		if (!__camSpot_ST) 
			__camSpot_ST = new SoundTransform();
	} else {
		debugMsg("setupNetStream->  RESETTING __camSpot_NS: "+__camSpot_NS);
		// reset and remove the NetStream
		__camSpot_NS.attachCamera(null);
		__camSpot_NS.attachAudio(null);
		//__camSpot_NS.play(false);
		__camSpot_NS.close();
		__camSpot_NS.dispose();
		
		if ((__camSpot_NS) && (__camSpot_NS.hasEventListener(NetStatusEvent.NET_STATUS))) { __camSpot_NS.removeEventListener(NetStatusEvent.NET_STATUS, netStreamStatusEventHandler); }
		if ((__camSpot_NS) && (__camSpot_NS.hasEventListener(AsyncErrorEvent.ASYNC_ERROR))) { __camSpot_NS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netStreamAsyncErrorHandler); }
		
		__camSpot_NS = null;
		
		// now recreate a new NetStream
		setupNetStream();
	}
}


public function isPlaying():Boolean
{
	if (isPlayingVideo || isPlayingAudio)
	{
		return true;
	} else {
		return false;
	}
}


// called when a user clicks a CamSpot and its userInfoObj.userID != 0
private function camSpotClickHandler(event:MouseEvent):void
{
}


private function formatUserName():void
{
	if ((userInfoObj.userID == __appWideSingleton.userInfoObj.userID) && (__appWideSingleton.appInfoObj.debugMode))
	{
		//statsBtn.visible = true;
	}
	userName_L.text = userInfoObj.userName;
}


public function attachUser(userObj:Object):void
{
	// check if the userObj is not the same user
	if (userObj.userID == userInfoObj.userID) return;
	
	// set the user object
	userInfoObj = userObj;
	
	if (__appWideSingleton.dockedUserIDs_A.indexOf("user_" + userInfoObj.userID) == -1)
		__appWideSingleton.dockedUserIDs_A.push("user_" + userInfoObj.userID);
	
	// show the video if it doesn't exist yet
	if (!camSpot_UIC.contains(__camSpot_Video))
		camSpot_UIC.addChild(__camSpot_Video);
	
	if (!xImgBtn.source) xImgBtn.source = new xImg();
	if (!arrowImgBtn.source) arrowImgBtn.source = new arrowImg();
	
	// show the userName
	formatUserName();
	
	// play the local camera if this is the local user
	if (userInfoObj.userID == __appWideSingleton.userInfoObj.userID)
	{
		__camSpot_Video.attachCamera(__appWideSingleton.localCamera);
	} else {
		// else play the remote stream
		// setup the NetStream
		setupNetStream();
		
		// attach the NetStream
		__camSpot_Video.attachNetStream(__camSpot_NS);
		
		// play the NetStream
		__camSpot_NS.play("user_" + userInfoObj.userID, -1, -1, true);
		
		// dont buffer anything when pausing, since this is live
		__camSpot_NS.useJitterBuffer = true;
		__camSpot_NS.inBufferSeek = false; // TEST
		__camSpot_NS.bufferTime = 0.000;
		__camSpot_NS.bufferTimeMax = 0.000;
		__camSpot_NS.backBufferTime = 0.000;
		__camSpot_NS.maxPauseBufferTime = 0.000;
		
		// check whether the users video is on/off
		if (userInfoObj.isUsersVideoOn)
		{
			if (__appWideSingleton.appInfoObj.isAllCamsOffChecked)
			{
				// dont play the video
				playMedia("video",false);
			} else {
				// play the video
				playMedia("video",true);
			}
		} else {
			videoOnOffBtn.source = null;
			videoOnOffBtn.source = new videoOffImg();
		}
		
		// if allAudioOffOnJoin_CB is selected
		if (!__appWideSingleton.appInfoObj.isAllAudioOffChecked)
		{
			// check whether the users audio is on/off
			if (userInfoObj.isUsersAudioOn)
			{
				if (userInfoObj.isPlayingAudio)
				{
					// already playing the audio before switching cams
					playMedia("audio",true);
				} else {
					// dont play the audio
					playMedia("audio",false);
				}
			} else {
				// play the audio
				playMedia("audio",true);
			}
		} else {
			playMedia("audio",false);
		}
	}
	
	userObj = null;
}


private function playMedia(media:String, onOff:Boolean):void
{
	debugMsg("playMedia->  media: "+media+"  onOff: "+onOff);
	
	switch (media)
	{
		case "video":
			__camSpot_NS.receiveVideo(onOff);
			
			isPlayingVideo = onOff;
			
			userInfoObj.isPlayingVideo = onOff;
			
			if (onOff)
			{
				if ((__camSpot_NS.videoStreamSettings) && 
					(__camSpot_NS.videoStreamSettings.codec != 'H264Avc'))
				{
					// set the FPS depending on the defaultQuality
					switch (__appWideSingleton.appInfoObj.defaultQuality)
					{
						case "low" :
							__camSpot_NS.receiveVideoFPS(1);
							break;
						case "medium" :
							__camSpot_NS.receiveVideoFPS(3);
							break;
						case "high" :
							__camSpot_NS.receiveVideoFPS(6);
							break;
						case "hd" :
							__camSpot_NS.receiveVideoFPS(8);
							break;
						default :
							__camSpot_NS.receiveVideoFPS(6);
							break;
					}
				}
				
				videoOnOffBtn.source = null;
				videoOnOffBtn.source = new videoOnImg();
				
				// TEMP:
				parentApplication.loginView.nc.call('mediaManager.startViewingUser', null, __appWideSingleton.userInfoObj.clientID, userInfoObj.userID);
			} else {
				videoOnOffBtn.source = null;
				videoOnOffBtn.source = new videoOffImg();
				
				// TEMP:
				parentApplication.loginView.nc.call('mediaManager.stopViewingUser', null, __appWideSingleton.userInfoObj.clientID, userInfoObj.userID);
			}
			break;
		case "audio":
			__camSpot_NS.receiveAudio(onOff);
			
			isPlayingAudio = onOff;
			
			userInfoObj.isPlayingAudio = onOff;
			
			if (onOff)
			{
				audioOnOffBtn.source = null;
				audioOnOffBtn.source = new audioOnImg();
				
				// set the volume
				if (!userInfoObj.volume) userInfoObj.volume = 0.7;
				
				camSpotVolume_VS.value = userInfoObj.volume;
				
				__camSpot_ST = __camSpot_NS.soundTransform;
				
				__camSpot_ST.volume = userInfoObj.volume;
				
				__camSpot_NS.soundTransform = __camSpot_ST;
				
				// TEMP:
				parentApplication.loginView.nc.call('mediaManager.startListeningToUser', null, __appWideSingleton.userInfoObj.clientID, userInfoObj.userID);
			} else {
				audioOnOffBtn.source = null;
				audioOnOffBtn.source = new audioOffImg();
				
				// TEMP:
				parentApplication.loginView.nc.call('mediaManager.stopListeningToUser', null, __appWideSingleton.userInfoObj.clientID, userInfoObj.userID);
			}
			break;
	}
	
	media = null;
}


public function switchCamSpot(userObj:Object):void
{
	if (userObj.userID != userInfoObj.userID)
	{
		debugMsg("switchCamSpot->  userObj.userID: "+userObj.userID+"  userInfoObj.userID: "+userInfoObj.userID);
		
		if (userObj.fromCamSpot != "autoDock" && userObj.fromCamSpot != "newUserSelected")
		{
			parentDocument[userObj.fromCamSpot].clearCamSpot();
		}
		
		attachUser(userObj);
	}
	
	userObj = null;
}


public function clearCamSpot():void
{
	debugMsg("clearCamSpot->  __camSpot_NS: "+__camSpot_NS+"  camSpot_Video: "+__camSpot_Video+"  userID: "+userInfoObj.userID + "  dockedUserIDs_A.indexOf: " + __appWideSingleton.dockedUserIDs_A.indexOf("user_" + userInfoObj.userID));
	
	if (isUserDocked(userInfoObj.userID))
		__appWideSingleton.dockedUserIDs_A.splice(__appWideSingleton.dockedUserIDs_A.indexOf("user_" + userInfoObj.userID), 1);
	
	if (userInfoObj.userID != 0)
	{
		if (userInfoObj.userID == __appWideSingleton.userInfoObj.userID)
		{
			__camSpot_Video.attachCamera(null);
		} else {
			__camSpot_Video.attachNetStream(null);
		}
		
		if (camSpot_UIC.contains(__camSpot_Video))
		{
			camSpot_UIC.removeChild(__camSpot_Video);
		}
		
		if (__camSpot_NS) 
		{
			if (NetConnectionManager_Singleton.getNetConnection().connected)
			{
				__camSpot_NS.close();
				__camSpot_NS.dispose();
			}
			
			__camSpot_NS = null;
		}
		
		userName_L.text = null;
		xImgBtn.source = null;
		arrowImgBtn.source = null;
		videoOnOffBtn.source = null;
		audioOnOffBtn.source = null;
		isPlayingVideo = false;
		isPlayingAudio = false;
		wasPlayingVideo = false;
		wasPlayingAudio = false;
		
		userInfoObj = null;
		userMetaData = null;
		setupUserInfoObj();
	}
}


private function isUserDocked(userID:Number):Boolean
{
	return __appWideSingleton.dockedUserIDs_A.indexOf("user_" + userID) != -1;
}


private function xImgBtn_clickHandler(event:MouseEvent):void
{
	clearCamSpot();
	event = null;
}


/*
private function arrowImgBtn_clickHandler(event:MouseEvent):void
{
if (this.id == "camSpot1")
{
parentDocument.dockCamSpot(userInfoObj,this.id);
} else {
parentDocument.switchToMain(userInfoObj,this.id);
}
event = null;
}
*/


private function videoOnOffBtn_clickHandler(event:MouseEvent):void
{
	//debugMsg("videoOnOffBtn_clickHandler->  userName: "+userInfoObj.userName);
	
	// pause
	if (isPlayingVideo)
	{
		__camSpot_NS.receiveVideo(false);
		
		isPlayingVideo = false;
		
		userInfoObj.isPlayingVideo = false;
		
		videoOnOffBtn.source = null;
		videoOnOffBtn.source = new videoOffImg();
	} else {
		// play
		__camSpot_NS.receiveVideo(true);
		
		isPlayingVideo = true;
		
		userInfoObj.isPlayingVideo = true;
		
		videoOnOffBtn.source = null;
		videoOnOffBtn.source = new videoOnImg();
	}
	
	event = null;
}


// TODO for mobile, show the volume bar for a period of time
private function audioOnOffBtn_clickHandler(event:MouseEvent):void
{
	debugMsg("audioOnOffBtn_clickHandler->  userName: "+userInfoObj.userName);
	
	// pause
	if (isPlayingAudio)
	{
		__camSpot_NS.receiveAudio(false);
		
		isPlayingAudio = false;
		
		userInfoObj.isPlayingAudio = false;
		
		audioOnOffBtn.source = null;
		audioOnOffBtn.source = new audioOffImg();
	} else {
		// play
		__camSpot_NS.receiveAudio(true);
		
		isPlayingAudio = true;
		
		userInfoObj.isPlayingAudio = true;
		
		audioOnOffBtn.source = null;
		audioOnOffBtn.source = new audioOnImg();
		
	}
	
	event = null;
}




private function statsBtn_clickHandler(event:MouseEvent):void
{
	/*if(__appWideSingleton.userInfoObj.isMyVideoOn)
	{
	var cam:Camera = AppWide_Singleton.getLocalCamera();
	debugMsg("cam.name: "+cam.name);
	debugMsg("cam.quality: "+cam.quality);
	debugMsg("cam.bandwidth: "+cam.bandwidth);
	debugMsg("cam.(max)fps: "+cam.fps);
	debugMsg("cam.currentFPS: "+cam.currentFPS);
	debugMsg("cam.motionLevel: "+cam.motionLevel);
	debugMsg("cam.activityLevel: "+cam.activityLevel);
	debugMsg("cam.keyFrameInterval: "+cam.keyFrameInterval);
	debugMsg("cam.loopback: "+cam.loopback);
	debugMsg("cam.width: "+cam.width);
	debugMsg("cam.height: "+cam.height);
	//debugMsg("cam.: "+cam.);
	}*/
	
	event = null;
}




/**************** CamSpot Drag & Drop ******************/


private function dragEnterHandler(event:DragEvent):void
{
	//debugMsg("dragEnterHandler->  toCamSpot: "+event.dragSource.dataForFormat("userInfoObj").toCamSpot+"  hasLeftOrigin: "+event.dragSource.dataForFormat("userInfoObj").hasLeftOrigin+"  event.currentTarget.parent: "+event.currentTarget.parent+"  event.dragInitiator.parent: "+event.dragInitiator.parent+"  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
	
	if (event.dragSource.hasFormat("userInfoObj") && (event.currentTarget.parent != event.dragInitiator.parent))
	{
		// Get the drop target component from the event object.
		var dropTarget:Group = event.currentTarget as Group;
		
		// Accept the drop.
		DragManager.acceptDragDrop(dropTarget);
		
		// set the toCamSpot
		event.dragSource.dataForFormat("userInfoObj").toCamSpot = this.id;
		
		// create a DragSource object
		//var dragSource:DragSource = new DragSource();
		
		// Add the data to the object.
		event.dragSource.addData(event.dragSource.dataForFormat("userInfoObj"), "userInfoObj");
		
		//debugMsg("dragEnterHandler->  toCamSpot: "+event.dragSource.dataForFormat("userInfoObj").toCamSpot+"  event.currentTarget.parent: "+event.currentTarget.parent+"  event.dragInitiator.parent: "+event.dragInitiator.parent+"  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
		
		//dragSource = null;
	}
	
	event = null;
}


private function dragExitHandler(event:DragEvent):void
{
	//debugMsg("dragExitHandler->  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
	
	// set hasLeftOrigin to true
	//if (event.dragSource.dataForFormat("userInfoObj").fromCamSpot == this.id)
	//{
	event.dragSource.dataForFormat("userInfoObj").hasLeftOrigin = true;
	
	// create a DragSource object
	//var dragSource:DragSource = new DragSource();
	
	// Add the data to the object.
	event.dragSource.addData(event.dragSource.dataForFormat("userInfoObj"), "userInfoObj");
	
	//debugMsg("dragExitHandler->  toCamSpot: "+event.dragSource.dataForFormat("userInfoObj").toCamSpot+"  hasLeftOrigin: "+event.dragSource.dataForFormat("userInfoObj").hasLeftOrigin+"  event.currentTarget.parent: "+event.currentTarget.parent+"  event.dragInitiator.parent: "+event.dragInitiator.parent+"  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
	
	//dragSource = null;
	//}
	
	event = null;
}


private function dragDropHandler(event:DragEvent):void
{
	//debugMsg("dragDropHandler->  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
	
	if (event.currentTarget.parent != event.dragInitiator.parent)
	{
	}
	
	event = null;
}


private function dragCompleteHandler(event:DragEvent):void
{
	//debugMsg("dragCompleteHandler->  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget+"  toCamSpot: "+event.dragSource.dataForFormat("userInfoObj").toCamSpot+"  hasLeftOrigin: "+event.dragSource.dataForFormat("userInfoObj").hasLeftOrigin);
	
	if (event.dragSource.dataForFormat("userInfoObj").toCamSpot == "") 
	{
		if ((event.dragSource.dataForFormat("userInfoObj").hasLeftOrigin) ||
			(event.dragSource.dataForFormat("userInfoObj").fromCamSpot != this.id)) 
			clearCamSpot();
		return;
	}
	
	if (event.dragSource.dataForFormat("userInfoObj").toCamSpot != this.id)
	{
		debugMsg("dragCompleteHandler->  toCamSpotObj.userID: "+parentDocument[event.dragSource.dataForFormat("userInfoObj").toCamSpot].userInfoObj.userID+"  toCamSpot: "+event.dragSource.dataForFormat("userInfoObj").toCamSpot+"  hasLeftOrigin: "+event.dragSource.dataForFormat("userInfoObj").hasLeftOrigin+"  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
		
		// if the toCamSpot is not empty
		if (parentDocument[event.dragSource.dataForFormat("userInfoObj").toCamSpot].userInfoObj.userID != 0)
		{
			// switch cam spots
			var tmpUserObj:Object = parentDocument[event.dragSource.dataForFormat("userInfoObj").toCamSpot].userInfoObj;
			parentDocument[event.dragSource.dataForFormat("userInfoObj").toCamSpot].clearCamSpot();
			parentDocument[event.dragSource.dataForFormat("userInfoObj").toCamSpot].switchCamSpot(event.dragSource.dataForFormat("userInfoObj"));
			
			clearCamSpot();
			
			attachUser(tmpUserObj);
			
			tmpUserObj = null;
		} else {
			// move the currently playing user to the toCamSpot
			parentDocument[event.dragSource.dataForFormat("userInfoObj").toCamSpot].switchCamSpot(event.dragSource.dataForFormat("userInfoObj"));
			clearCamSpot();
		}
	}
	
	currentDragSource = null;
	
	event = null;
}


private function mouseDownHandler(event:MouseEvent):void
{
	if (userInfoObj.userID != 0)
	{
		//debugMsg("mouseDownHandler->  event.type: "+event.type+"  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
		// create a DragSource object
		var dragSource:DragSource = new DragSource();
		
		// Get the drag initiator component from the event object.
		var dragInitiator:Group = event.currentTarget as Group;
		
		// set the userInfoObj as the dragItem
		var dragItem:Object = userInfoObj;
		
		dragItem.hasDraggedOutOfSource = false;
		dragItem.fromCamSpot = this.id;
		dragItem.toCamSpot = "";
		dragItem.hasLeftOrigin = false; // has this been dragged out of the originating camspot
		
		// Add the data to the object.
		dragSource.addData(dragItem, "userInfoObj");
		
		// Call the DragManager doDrag() method to start the drag. 
		DragManager.doDrag(dragInitiator, dragSource, event);
		
		currentDragSource = dragSource;
		
		dragSource = null;
		dragItem = null;
		dragInitiator = null;
	} else {
		camSpotClickHandler(event);
	}
	event = null;
}


private function mouseUpHandler(event:MouseEvent):void
{
	if (userInfoObj.userID != 0)
	{
		debugMsg("mouseUpHandler->  event.target: "+event.target+"  event.currentTarget: "+event.currentTarget);
	}
	event = null;
}


private function camSpotGroup_mouseOverHandler(event:MouseEvent):void
{
	camSpotGroup.alpha = 0.75;
	//camSpotGroup.setStyle("backgroundColor","#19B819");
	event = null;
}


private function camSpotGroup_mouseOutHandler(event:MouseEvent):void
{
	camSpotGroup.alpha = 1;
	//camSpotGroup.setStyle("backgroundColor","#393939");
	if (event.relatedObject==camSpotVolume_VS.track || event.relatedObject==camSpotVolume_VS.thumb || event.relatedObject==null)
	{
		// mouseOut into another button, the volume slider, or this camSpot_BC, do nothing..
	} else {
		camSpotVolume_VS.visible = false;
	}
	
	if (currentDragSource)
	{
		currentDragSource.dataForFormat("userInfoObj").hasLeftOrigin = true;
		currentDragSource.addData(currentDragSource.dataForFormat("userInfoObj"), "userInfoObj");
	}
	
	event = null;
}


private function camSpot_mainGroup_mouseOverHandler(event:MouseEvent):void
{
	xImgBtn.alpha = 1;
	arrowImgBtn.alpha = 1;
	videoOnOffBtn.alpha = 1;
	audioOnOffBtn.alpha = 1;
	event = null;
}


private function camSpot_mainGroup_mouseOutHandler(event:MouseEvent):void
{
	xImgBtn.alpha = 0.2;
	arrowImgBtn.alpha = 0.2;
	videoOnOffBtn.alpha = 0.2;
	audioOnOffBtn.alpha = 0.2;
	event = null;
}


private function audioOnOffBtn_mouseOverHandler(event:MouseEvent):void
{
	//debugMsg("audioOnOffBtn_mouseOverHandler->  target: "+event.target+"  currentTarget: "+event.currentTarget);
	if (!camSpotVolume_VS.visible)
	{
		camSpotVolume_VS.visible = true;
	}
	event = null;
}


private function audioOnOffBtn_mouseOutHandler(event:MouseEvent):void
{
	//debugMsg("audioOnOffBtn_mouseOutHandler->  target: "+event.target+"  currentTarget: "+event.currentTarget+"  relatedObject: "+event.relatedObject);
	if (event.relatedObject==camSpotVolume_VS.track||event.relatedObject==camSpotVolume_VS.thumb/*||event.relatedObject==null*/)
	{
		// mouseOut into another button, the volume slider, or this camSpot_BC, do nothing..
	} else {
		camSpotVolume_VS.visible = false;
	}
	event = null;
}


private function camSpotVolume_VS_mouseOutHandler(event:MouseEvent):void
{
	//debugMsg("camSpotVolume_VS_mouseOutHandler->  target: "+event.target+"  currentTarget: "+event.currentTarget+"  relatedObject: "+event.relatedObject);
	if (event.relatedObject == camSpotVolume_VS.thumb || event.relatedObject == camSpotVolume_VS.track)
	{
		// if the mouse is leaving the slider and into any of the buttons or the slider track/thumb, do nothing..
	} else {
		camSpotVolume_VS.visible = false;
	}
	event = null;
}


private function camSpotVolume_VS_changeHandler(event:Event):void
{
	//debugMsg("camSpotVolume_VS_changeHandler->  VOLUME CHANGED TO: "+event.target.value);
	
	// set the NetStreams soundTransform property to the camSpot_ST
	__camSpot_ST = __camSpot_NS.soundTransform;
	__camSpot_ST.volume = event.target.value;
	__camSpot_NS.soundTransform = __camSpot_ST;
	
	userInfoObj.volume = event.target.value;
	
	event = null;
}















/*************** NetStream event/.client handlers ******************/

private function netStreamStatusEventHandler(event:NetStatusEvent):void
{
	debugMsg("netStreamStatusEventHandler->  code: "+event.info.code);
	
	var code:String = event.info.code;
	switch (code)
	{
		case "NetStream.Play.Start" :
			// playback has started
			break;
		case "NetStream.Play.Stop" :
			// playback has stopped
			clearCamSpot();
			break;
		case "NetStream.Play.StreamNotFound" :
			// usually means bad streamName.. create an error alert for the user
			break;
		case "NetStream.Play.Complete" :
			// VOD video has ended
			break;
		case "NetStream.Play.PublishNotify" :
			break;
		case "NetStream.Play.UnpublishNotify" :
			clearCamSpot();
			break;
		case "NetStream.Video.DimensionChange" :
			//debugMsg("netStreamStatusEventHandler->  ");
			break;
		default :
			debugMsg("netStreamStatusEventHandler->  UNHANDLED CASE: "+event.info.code);
			break;
	}
	
	event.stopPropagation();
	
	event = null;
}


private function netStreamAsyncErrorHandler(event:AsyncErrorEvent):void
{ 
	debugMsg("netStreamAsyncErrorHandler->  errorID: "+event.errorID+"  error: "+event.error+"  text: "+event.text);
	
	event.stopPropagation();
	
	event = null;
}


private function onPlayStatus(infoObj:Object):void
{
	// check if infoObj is not null
	if (!infoObj) return;
	
	debugMsg("onPlayStatus->  code: "+infoObj.code);
	
	if (infoObj.code == "NetStream.Play.Complete")
	{
		// VOD video has ended
	}
	
	// trace debug info
	for (var i:* in infoObj)
	{
		debugMsg("onPlayStatus->\t"+i+": "+infoObj[i]);
	}
	
	infoObj = null;
}


public function onMetaData(infoObj:Object):void
{
	// check if infoObj is not null
	if (!infoObj) return;
	
	// set the users MetaData
	userMetaData = infoObj;
	userMetaData.camSpotID = this.id;
	userMetaData.inBufferSeek = __camSpot_NS.inBufferSeek;
	userMetaData.useJitterBuffer = __camSpot_NS.useJitterBuffer;
	userMetaData.maxPauseBufferTime = __camSpot_NS.maxPauseBufferTime;
	userMetaData.backBufferTime = __camSpot_NS.backBufferTime;
	userMetaData.backBufferLength = __camSpot_NS.backBufferLength;
	userMetaData.bufferTimeMax = __camSpot_NS.bufferTimeMax;
	userMetaData.bufferTime = __camSpot_NS.bufferTime;
	userMetaData.bufferLength = __camSpot_NS.bufferLength;
	userMetaData.liveDelay = __camSpot_NS.liveDelay;
	userMetaData.useHardwareDecoder = __camSpot_NS.useHardwareDecoder;
	
	// trace debug info
	for (var i:* in infoObj)
	{
		debugMsg("onMetaData->\t"+i+": "+infoObj[i]);
	}
	
	infoObj = null;
}


public function onTextData(infoObj:Object):void
{
	// check if infoObj is not null
	if (!infoObj) return;
	
	// trace debug info
	for (var i:* in infoObj)
	{
		debugMsg("onTextData->\t"+i+": "+infoObj[i]);
	}
	
	infoObj = null;
}


public function onXMPData(infoObj:Object):void
{
	// check if infoObj is not null
	if (!infoObj) return;
	
	// trace debug info
	for (var i:* in infoObj)
	{
		debugMsg("onXMPData->\t"+i+": "+infoObj[i]);
	}
	
	infoObj = null;
}


public function onFI(infoObj:Object):void
{
	// check if infoObj is not null
	if (!infoObj) return;
	
	var timecode:String;
	for (var i:* in infoObj)
	{
		if (i == "tc")
		{
			timecode = infoObj.tc; // string formatted HH:MM:SS:FF
		}
	}
	
	infoObj = null;
}












private function debugMsg(str:String):void
{
	AppWideDebug_Singleton.getInstance().newDebugMessage(this.id, str);
	str = null;
}


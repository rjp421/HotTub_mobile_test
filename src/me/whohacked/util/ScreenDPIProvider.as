package me.whohacked.util
{
	
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	
		
	public class ScreenDPIProvider extends RuntimeDPIProvider
	{
		
		
		public function ScreenDPIProvider()
		{
			super();
		}
		
		
		override public function get runtimeDPI():Number
		{
			/* A tablet reporting an incorrect DPI of 240. We could use
			Capabilities.manufacturer to check the tablet's OS as well. */
			if (Capabilities.screenDPI == 240 && 
				Capabilities.screenResolutionY == 1024 && 
				Capabilities.screenResolutionX == 600)
			{
				return DPIClassification.DPI_160;
			}
			
			if (Capabilities.screenDPI < 200)
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_160);
				return DPIClassification.DPI_160;
			
			if (Capabilities.screenDPI <= 280)
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_240);
				return DPIClassification.DPI_240;
			
			if (Capabilities.screenDPI <= 400)
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_320);
				return DPIClassification.DPI_320;
			
			// for now, dont support DPI's higher than 320 - TESTING
			//return DPIClassification.DPI_320;
			
			if (Capabilities.screenDPI <= 560)
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_480);
				return DPIClassification.DPI_480;
			
			trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_640);
			return DPIClassification.DPI_640;
		}
		
		
		
		
		
		
		
		
		
		
	}// end class
}// end package
package me.whohacked.util
{
	
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	
	
	public class DPITestClass extends RuntimeDPIProvider
	{
		
		
		public function DPITestClass()
		{
			super();
		}
		
		
		override public function get runtimeDPI():Number
		{
			// for now, dont support DPI's higher than 320 (retina HD)
			/* A tablet reporting an incorrect DPI of 240. We could use
			Capabilities.manufacturer to check the tablet's OS as well. */
			
			// TEST:
			// n7 2013
			if (Capabilities.screenDPI == 320 && 
				Capabilities.screenResolutionY == 1200 && 
				Capabilities.screenResolutionX == 1920)
			{
				return DPIClassification.DPI_320;
			}
			
			
			if (Capabilities.screenDPI < 200)
			{
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_160);
				return DPIClassification.DPI_160;
			}
			
			if (Capabilities.screenDPI <= 280)
			{
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_240);
				return DPIClassification.DPI_240;
			}
			
			if (Capabilities.screenDPI <= 400)
			{
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_320);
				return DPIClassification.DPI_320;
			}
			
			/*
			if (Capabilities.screenDPI <= 560)
			{
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_480);
				return DPIClassification.DPI_480;
			}
			if (Capabilities.screenDPI <= 640)
			{
				trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_640);
				return DPIClassification.DPI_640;
			}
			*/
			trace("DPITestClass | get runtimeDPI->  RETURNING: "+DPIClassification.DPI_320);
			return DPIClassification.DPI_320;
		}
		
		
		
		
		
		
		
	}// end class
}// end package
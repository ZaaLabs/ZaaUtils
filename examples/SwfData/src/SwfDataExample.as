/*******************************************************************************
 * ZaaUtils
 * Copyright (c) 2010 ZaaLabs, Ltd.
 * For more information see http://www.zaalabs.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the license.txt file at the root directory of this library.
 ******************************************************************************/
package
{
	import com.zaalabs.utils.SwfData;
	
	import flash.display.Sprite;
	
	[SWF(backgroundColor="0x969696")]
	public class SwfDataExample extends Sprite
	{
		public function SwfDataExample()
		{
			var data:SwfData = new SwfData(loaderInfo.bytes);
			trace("version \t"+data.version);
			trace("frameRate \t"+data.frameRate);
			trace("frameCount \t"+data.frameCount);
			trace("fileLength \t"+data.fileLength);
			trace("bgColor \t0x"+data.backgroundColor.toString(16));
		}
	}
}
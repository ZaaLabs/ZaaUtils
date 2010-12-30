/*******************************************************************************
 * ZaaUtils
 * Copyright (c) 2010 ZaaLabs, Ltd.
 * For more information see http://www.zaalabs.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the license.txt file at the root directory of this library.
 ******************************************************************************/
package com.zaalabs.utils
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    public class SwfData
    {
        // Obviously this is only a few of the possible 64 tag types
        // More information can be found here:
        // http://www.adobe.com/content/dam/Adobe/en/devnet/swf/pdf/swf_file_format_spec_v10.pdf
        // The Reverse index of tag values is especially helpful
        private const End:uint                  = 0;
        private const ShowFrame:uint            = 1;
        private const SetBackgroundColor:uint   = 9;

        protected var _stream:ByteArray;
        protected var _compressedBytes:ByteArray;

        public var signature:String;
        public var version:uint;
        public var fileLength:uint;
        public var frameRate:Number;
        public var frameCount:uint;

        // Tags
        public var backgroundColor:uint;

        public function SwfData(stream:ByteArray)
        {
            _stream = stream;

            parseHeader();
            parseTags();
        }

        protected function parseHeader():void
        {
            // First 8 bytes are uncompressed
            var header:ByteArray = new ByteArray();
            header.endian = Endian.LITTLE_ENDIAN;
            _stream.readBytes(header, 0, 8);

            signature = header.readUTFBytes(3);
            version = header.readByte();
            fileLength = header.readUnsignedInt();

            // Handle if there are compressed bytes
            _compressedBytes = new ByteArray();
            _compressedBytes.endian = Endian.LITTLE_ENDIAN;
            _stream.readBytes(_compressedBytes);
            if(signature == "CWS")
            {
                _compressedBytes.uncompress();
            }

            // Figure out the framesize (Not entirely working right now so we're skipping it)
            var fbyte:uint = _compressedBytes.readUnsignedByte();
            var rect_bitlength:uint = fbyte >> 3;
            var total_bits:uint = rect_bitlength * 4;
            var next_bytes:uint = Math.ceil(total_bits / 8);
            for(var i:int = 0; i < next_bytes; i++)
            {
                _compressedBytes.readUnsignedByte();
            }

            // Frame rate and count
            frameRate = _compressedBytes.readUnsignedShort() / 256;
            frameCount = _compressedBytes.readUnsignedShort();
        }

        protected function parseTags():void
        {
            while(true)
            {
                var tagCodeLen:Number = _compressedBytes.readUnsignedShort();
                var tagCode:uint = tagCodeLen >> 6;
                var tagLen:uint = tagCodeLen & 0x3F;

                // Check for RecordHeader(long)
                if(tagLen >= 63)
                {
                    tagLen = _compressedBytes.readUnsignedInt();
                }

                switch(tagCode)
                {
                    case End:
                        return;
                    case ShowFrame:
                        break;
                    case SetBackgroundColor:
                        var r:uint = _compressedBytes.readUnsignedByte();
                        var g:uint = _compressedBytes.readUnsignedByte();
                        var b:uint = _compressedBytes.readUnsignedByte();
                        backgroundColor = r << 16 | g << 8 | b;
                        break;
                    default:
                        //trace("Unknown tagCode: "+tagCode+" length of: "+tagLen);
                        _compressedBytes.readBytes(new ByteArray(), 0, tagLen);
                }
            }
        }
    }
}
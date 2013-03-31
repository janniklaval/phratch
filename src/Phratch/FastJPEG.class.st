"
I provide fast JPEG compression and decompression. I require the VM extension JPEGReadWriter2Plugin, which is usually installed in same directory as the Squeak virtual machine.

JPEGReadWriter2Plugin is based on LIBJPEG library. This sentence applies to that library:

   ""This software is based in part on the work of the Independent JPEG Group"".

The LIBJPEG license allows it to be used free for any purpose so long as its origin and copyright are acknowledged. You can read more about LIBJPEG and get the complete source code at www.ijg.org.

"
Class {
	#name : #FastJPEG,
	#superclass : #Object,
	#category : #'Phratch-Objects'
}

{ #category : #'image operations' }
FastJPEG class >> compress: aForm quality: quality [
	"Encode the given Form and answer the compressed ByteArray. Quality goes from 0 (low) to 100 (high)."

	^ self compress: aForm quality: quality progressive: false

]

{ #category : #'image operations' }
FastJPEG class >> compress: aForm quality: quality progressive: progressiveFlag [
	"Encode the given Form and answer the compressed ByteArray. Quality goes from 0 (low) to 100 (high). If progressiveFlag is true, then create a progressive-scan JPEG which is a bit larger but causes a low-resolution version to appear in browsers while the rest of the data is being fetched."

	| sourceForm jpegCompressStruct jpegErrorMgr2Struct buffer byteCount |
	aForm unhibernate.
	"Odd width images of depth 16 give problems; avoid them. Make sure depth is 16 or 32."
	sourceForm := (aForm depth = 32) | (aForm width even & (aForm depth = 16))
		ifTrue: [aForm]
		ifFalse: [aForm asFormOfDepth: 32].
	jpegCompressStruct := ByteArray new: self primJPEGCompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	buffer := ByteArray new: ((2 * sourceForm width * sourceForm height) max: 1000).  "larger than compressed size..."
	byteCount := self primJPEGWriteImage: jpegCompressStruct 
		onByteArray: buffer
		form: sourceForm
		quality: quality
		progressiveJPEG: progressiveFlag
		errorMgr: jpegErrorMgr2Struct.
	byteCount = 0 ifTrue: [self error: 'buffer too small for compressed data'].
	^ buffer copyFrom: 1 to: byteCount

]

{ #category : #testing }
FastJPEG class >> isPluginPresent [

	^ self primJPEGPluginIsPresent

]

{ #category : #primitives }
FastJPEG class >> primImageHeight: aJPEGCompressStruct [

	<primitive: 'primImageHeight' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primImageWidth: aJPEGCompressStruct [

	<primitive: 'primImageWidth' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primJPEGCompressStructSize [

	<primitive: 'primJPEGCompressStructSize' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primJPEGDecompressStructSize [

	<primitive: 'primJPEGDecompressStructSize' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primJPEGErrorMgr2StructSize [

	<primitive: 'primJPEGErrorMgr2StructSize' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primJPEGPluginIsPresent [

	<primitive: 'primJPEGPluginIsPresent' module: 'JPEGReadWriter2Plugin'>
	^ false

]

{ #category : #primitives }
FastJPEG class >> primJPEGReadHeader: aJPEGDecompressStruct fromByteArray: source errorMgr: aJPEGErrorMgr2Struct [

	<primitive: 'primJPEGReadHeaderfromByteArrayerrorMgr' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primJPEGReadImage: aJPEGDecompressStruct fromByteArray: source onForm: form doDithering: ditherFlag errorMgr: aJPEGErrorMgr2Struct [

	<primitive: 'primJPEGReadImagefromByteArrayonFormdoDitheringerrorMgr' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
FastJPEG class >> primJPEGWriteImage: aJPEGCompressStruct onByteArray: destination form: form quality: quality progressiveJPEG: progressiveFlag errorMgr: aJPEGErrorMgr2Struct [

	<primitive: 'primJPEGWriteImageonByteArrayformqualityprogressiveJPEGerrorMgr' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #'image operations' }
FastJPEG class >> uncompress: aByteArray [
	"Uncompress an image from the given ByteArray and return the resulting 32-bit Form."

	^ self uncompress: aByteArray doDithering: false

]

{ #category : #'image operations' }
FastJPEG class >> uncompress: aByteArray doDithering: ditherFlag [
	"Uncompress an image from the given ByteArray and return the resulting Form. If ditherFlag = true, do ordered dithering into a Form of depth 16. Otherwise, return a Form of depth 32."

	| jpegDecompressStruct jpegErrorMgr2Struct w h result |
	jpegDecompressStruct := ByteArray new: self primJPEGDecompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	self 
		primJPEGReadHeader: jpegDecompressStruct 
		fromByteArray: aByteArray
		errorMgr: jpegErrorMgr2Struct.
	w := self primImageWidth: jpegDecompressStruct.
	h := self primImageHeight: jpegDecompressStruct.

	(ditherFlag and: [w odd not])  "odd width images of depth 16 do not work"
		ifTrue: [result := Form extent: w@h depth: 16]
		ifFalse: [result := Form extent: w@h depth: 32].

	self primJPEGReadImage: jpegDecompressStruct
		fromByteArray: aByteArray
		onForm: result
		doDithering: ditherFlag
		errorMgr: jpegErrorMgr2Struct.

	^ result

]

{ #category : #'image operations' }
FastJPEG class >> uncompress: aByteArray into: aForm [
	"Uncompress an image from the given ByteArray into the given Form. Fail if the given Form has the wrong dimensions or depth < 16. If aForm has depth 16, do ordered dithering."

	self uncompress: aByteArray
		into: aForm
		doDithering: (aForm depth = 16).

]

{ #category : #'image operations' }
FastJPEG class >> uncompress: aByteArray into: aForm doDithering: ditherFlag [
	"Uncompress an image from the given ByteArray into the given Form. Fail if aForm has the wrong dimensions or depth < 16. If aForm has depth 16 and ditherFlag = true, do ordered dithering."

	| jpegDecompressStruct jpegErrorMgr2Struct w h |
	aForm unhibernate.
	jpegDecompressStruct := ByteArray new: self primJPEGDecompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	self 
		primJPEGReadHeader: jpegDecompressStruct 
		fromByteArray: aByteArray
		errorMgr: jpegErrorMgr2Struct.
	w := self primImageWidth: jpegDecompressStruct.
	h := self primImageHeight: jpegDecompressStruct.
	((aForm width = w) & (aForm height = h)) ifFalse: [
		^ self error: 'form dimensions do not match'].

	"odd width images of depth 16 give problems; avoid them"
	w odd
		ifTrue: [
			aForm depth = 32 ifFalse: [^ self error: 'must use depth 32 with odd width']]
		ifFalse: [
			((aForm depth = 16) | (aForm depth = 32)) ifFalse: [^ self error: 'must use depth 16 or 32']].

	self primJPEGReadImage: jpegDecompressStruct
		fromByteArray: aByteArray
		onForm: aForm
		doDithering: ditherFlag
		errorMgr: jpegErrorMgr2Struct.

]

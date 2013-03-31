Class {
	#name : #LowResPlugin,
	#superclass : #InterpreterPlugin,
	#classVars : [
		'TestFileName'
	],
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #testing }
LowResPlugin class >> benchAll [
	"LowResPlugin benchAll"

	^ {
	LowResPlugin benchmarkMixed.
	LowResPlugin benchmarkMixed2.
	LowResPlugin benchmarkMixed3.
	LowResPlugin benchmarkMixed4.
	LowResPlugin benchmarkAveraged.
	LowResPlugin benchmarkAveraged2.
	LowResPlugin benchmarkAveraged3.
	LowResPlugin benchmarkMagnify.
	LowResPlugin benchmarkRaw.
	LowResPlugin benchmarkScale.
	LowResPlugin benchmark2Raw.
	LowResPlugin benchmark2Avg.
}
]

{ #category : #testing }
LowResPlugin class >> benchmark2Avg [

	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: f extent // 2 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i |
		self primHalf2Average: f bits w: f width h:  f height
			into: fOut bits w: fOut width h: fOut height
			srcX: 0 srcY: 0
			dstX: 0 dstY: 0 dstW: f width // 2 dstH: f height // 2].

	^ Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmark2Raw [

	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: f extent // 2 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i |
		self primHalf2Raw: f bits w: f width h:  f height
			into: fOut bits w: fOut width h: fOut height
			srcX: 0 srcY: 0
			dstX: 0 dstY: 0 dstW: f width // 2 dstH: f height // 2].

	^ Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkAveraged [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfAveraged: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkAveraged2 [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfAveraged2: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkAveraged3 [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfAveraged3: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkMagnify [
	| f start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		f magnifyBy: 0.5 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkMixed [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfMixed: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkMixed2 [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfMixed2: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkMixed3 [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfMixed3: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkMixed4 [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfMixed4: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkRaw [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		self primHalfRaw: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10 ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> benchmarkScale [
	| f fOut start |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.

	start := Time millisecondClockValue.
	1 to: 1000 do: [:i|
		ScratchPlugin primScale: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height. ].
	^Time millisecondClockValue - start.
]

{ #category : #testing }
LowResPlugin class >> halfTestAverage2 [
	"self halfTestAverage2"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: f extent // 2 depth: 32.
	self
		primHalf2Average: f bits w: f width h:  f height
		into: fOut bits w: fOut width h: fOut height
		srcX: 0 srcY: 0
		dstX: 0 dstY: 0 dstW: f width // 2 dstH: f height // 2.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestAveraged [
	"self halfTestAveraged"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfAveraged: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestAveraged2 [
	"self halfTestAveraged2"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfAveraged2: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestAveraged3 [
	"self halfTestAveraged3"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfAveraged3: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestMixed [
	"self halfTestMixed"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfMixed: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestMixed2 [
	"self halfTestMixed2"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfMixed2: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestMixed3 [
	"self halfTestMixed3"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfMixed3: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestMixed4 [
	"self halfTestMixed4"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfMixed4: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestRaw [
	"self halfTestRaw"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (0.5 * f extent) rounded + 20 depth: 32.
	self primHalfRaw: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #testing }
LowResPlugin class >> halfTestRaw2 [
	"self halfTestRaw2"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: f extent // 2 depth: 32.
	self
		primHalf2Raw: f bits w: f width h:  f height
		into: fOut bits w: fOut width h: fOut height
		srcX: 0 srcY: 0
		dstX: 0 dstY: 0 dstW: f width // 2 dstH: f height // 2.
	fOut display.


]

{ #category : #primitives }
LowResPlugin class >> primHalf2Average: srcBits w: srcW h: srcH into: dstBits w: dstW h: dstH srcX: x1 srcY: y1 dstX: x2 dstY: y2 dstW: w dstH: h [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSize2Average' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalf2Raw: srcBits w: srcW h: srcH into: dstBits w: dstW h: dstH srcX: x1 srcY: y1 dstX: x2 dstY: y2 dstW: w dstH: h [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSize2Raw' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfAveraged2: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeAveraged2' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfAveraged3: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeAveraged3' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfAveraged: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeAveraged' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfMixed2: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeMixed2' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfMixed3: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeMixed3' module: 'LowResPlugin'>

]

{ #category : #primitives }
LowResPlugin class >> primHalfMixed4: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeMixed4' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfMixed: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeMixed' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
LowResPlugin class >> primHalfRaw: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at half-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeRaw' module: 'LowResPlugin'>
	self primitiveFailed

]

{ #category : #'primitive failure' }
LowResPlugin class >> primitiveFailed [
	"bring up an error - for debugging purposes"

	self error: 'primitive failed'.

]

{ #category : #scaling }
LowResPlugin class >> scale2: srcForm into: dstForm [

	self primHalfMixed3: srcForm bits w: srcForm width h: srcForm height
		into: dstForm bits w: dstForm width h: dstForm height
		x: 0 y: 0.

]

{ #category : #scaling }
LowResPlugin class >> scale: srcForm into: dstForm [

false ifTrue: [^ self].
	srcForm unhibernate.
	dstForm unhibernate.
	self primHalfMixed3: srcForm bits w: srcForm width h: srcForm height
		into: dstForm bits w: dstForm width h: dstForm height
		x: 0 y: 0.

]

{ #category : #scaling }
LowResPlugin class >> scale: srcForm into: dstForm at: aPoint [

	srcForm unhibernate.
	dstForm unhibernate.
	((srcForm depth = 32) & (dstForm depth = 32)) ifFalse: [^ self].

	self primHalfMixed3: srcForm bits w: srcForm width h: srcForm height
		into: dstForm bits w: dstForm width h: dstForm height
		x: aPoint x y: aPoint y.

]

{ #category : #testing }
LowResPlugin class >> testFileName: aString [
	"Set the name of an image file for testing."
	"self testFileName: 'hammy.jpg'"
	"self testFileName: 'JohnMugShotBW.jpg'"
	"self testFileName: 'Draco.jpg'"
	"self testFileName: 'Scratch.bmp'"

	TestFileName := aString.

]

{ #category : #private }
LowResPlugin >> checkedUnsignedIntPtrOf: oop [
	"Return an unsigned int pointer to the first indexable word of oop, which must be a words object."

	self inline: true.
	self returnTypeC: 'unsigned int *'.

	interpreterProxy success: (interpreterProxy isWords: oop).
	interpreterProxy failed ifTrue: [^ 0].
	^ self cCoerce: (interpreterProxy firstIndexableField: oop) to: 'unsigned int *'

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSize2Average [

	| in inW inH out outW outH srcX srcY dstX dstY dstW dstH srcIndex dstIndex pixel r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	in := self checkedUnsignedIntPtrOf: (interpreterProxy stackValue: 11).
	inW := interpreterProxy stackIntegerValue: 10.
	inH := interpreterProxy stackIntegerValue: 9.
	out := self checkedUnsignedIntPtrOf: (interpreterProxy stackValue: 8).
	outW := interpreterProxy stackIntegerValue: 7.
	outH := interpreterProxy stackIntegerValue: 6.
	srcX := interpreterProxy stackIntegerValue: 5.
	srcY := interpreterProxy stackIntegerValue: 4.
	dstX := interpreterProxy stackIntegerValue: 3.
	dstY := interpreterProxy stackIntegerValue: 2.
	dstW := interpreterProxy stackIntegerValue: 1.
	dstH := interpreterProxy stackIntegerValue: 0.

	interpreterProxy success: (srcX >= 0) & (srcY >= 0).
	interpreterProxy success: (srcX + (2 * dstW)) <= inW.
	interpreterProxy success: (srcY + (2 * dstH)) <= inH.
	interpreterProxy success: (dstX >= 0) & (dstY >= 0).
	interpreterProxy success: (dstX + dstW) <= outW.
	interpreterProxy success: (dstY + dstH) <= outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: dstH - 1 do: [:y |
		srcIndex := (inW * (srcY + (2 * y))) + srcX.
		dstIndex := (outW * (dstY + y)) + dstX.
		0 to: dstW - 1 do: [:x |
			pixel := in at: srcIndex.
			r := pixel bitAnd: 16rFF0000.
			g := pixel bitAnd: 16rFF00.
			b := pixel bitAnd: 16rFF.

			pixel := in at: srcIndex + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			pixel := in at: srcIndex + inW.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			pixel := in at: srcIndex + inW + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			"store combined RGB into target bitmap"
			out at: dstIndex put:
				(((r bitShift: -2) bitAnd: 16rFF0000) bitOr:
				(((g bitShift: -2) bitAnd: 16rFF00) bitOr: (b bitShift: -2))).

			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1]].

	interpreterProxy pop: 12.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSize2Raw [

	| in inW inH out outW outH srcX srcY dstX dstY dstW dstH srcIndex dstIndex p1 p2 r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	in := self checkedUnsignedIntPtrOf: (interpreterProxy stackValue: 11).
	inW := interpreterProxy stackIntegerValue: 10.
	inH := interpreterProxy stackIntegerValue: 9.
	out := self checkedUnsignedIntPtrOf: (interpreterProxy stackValue: 8).
	outW := interpreterProxy stackIntegerValue: 7.
	outH := interpreterProxy stackIntegerValue: 6.
	srcX := interpreterProxy stackIntegerValue: 5.
	srcY := interpreterProxy stackIntegerValue: 4.
	dstX := interpreterProxy stackIntegerValue: 3.
	dstY := interpreterProxy stackIntegerValue: 2.
	dstW := interpreterProxy stackIntegerValue: 1.
	dstH := interpreterProxy stackIntegerValue: 0.

	interpreterProxy success: (srcX >= 0) & (srcY >= 0).
	interpreterProxy success: (srcX + (2 * dstW)) <= inW.
	interpreterProxy success: (srcY + (2 * dstH)) <= inH.
	interpreterProxy success: (dstX >= 0) & (dstY >= 0).
	interpreterProxy success: (dstX + dstW) <= outW.
	interpreterProxy success: (dstY + dstH) <= outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: dstH - 1 do: [:y |
		srcIndex := (inW * (srcY + (2 * y))) + srcX.
		dstIndex := (outW * (dstY + y)) + dstX.
		0 to: dstW - 1 do: [:x |
			p1 := in at: srcIndex.
			p2 := in at: srcIndex + inW + 1.

			r := (((p1 bitAnd: 16rFF0000) + (p2 bitAnd: 16rFF0000)) bitShift: -1) bitAnd: 16rFF0000.
			g := (((p1 bitAnd: 16rFF00) + (p2 bitAnd: 16rFF00)) bitShift: -1) bitAnd: 16rFF00.
			b := ((p1 bitAnd: 16rFF) + (p2 bitAnd: 16rFF)) bitShift: -1.

			"store combined RGB into target bitmap"
			out at: dstIndex put: (r bitOr: (g bitOr: b)).

			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1]].

	interpreterProxy pop: 12.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeAveraged [

	| in out inOop outOop inW inH outW outH dstX dstY baseIndex outPix p1 p2 p3 p4 r g b i |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + ( inW / 2)) < outW.
	interpreterProxy success: (dstY + ( inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		baseIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |

			"get source pixels, if on edge take the last ones within"
			p1 := in at: x + (y * inW). 

			(x = (inW - 1)) 
				ifTrue:[p2 := p1] 
				ifFalse: [p2 := in at: (x + 1) + (y * inW)].

			(y = (inH -1 ))
				ifTrue: [p3 := p1.
					(x = (inW - 1)) 
						ifTrue: [ p4 := p1]
						ifFalse: [ p4 := p2]]
				ifFalse: [p3 := in at: x + ( y + 1 * inW).
					(x = (inW - 1)) 
						ifTrue: [p4 := p3 ]
						ifFalse: [p4 := in at: (x +1) + (y + 1 * inW)]].

			"average rgb values in place, ignore alpha"
			r := (((p1 bitAnd: 16rFF0000)
				+ (p2 bitAnd: 16rFF0000)
				+ (p3 bitAnd: 16rFF0000)
				+ (p4 bitAnd: 16rFF0000))
				/ 4)	bitAnd: 16rFF0000.

			g := (((p1 bitAnd: 16rFF00)
				+ (p2 bitAnd: 16rFF00)
				+ (p3 bitAnd: 16rFF00)
				+ (p4 bitAnd: 16rFF00))
				/ 4) bitAnd: 16rFF00.

			b := (((p1 bitAnd: 16rFF)
				+ (p2 bitAnd: 16rFF)
				+ (p3 bitAnd: 16rFF)
				+ (p4 bitAnd: 16rFF))
				/ 4) bitAnd: 16rFF.

			"assemble the output pixel"
			outPix := r bitOr: (g bitOr: b).

			"store into target bitmap"
			i:= baseIndex + ( x/2).
			out at: i put: outPix.]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeAveraged2 [

	| in out inOop outOop inW inH outW outH dstX dstY srcIndex dstIndex p1 p2 p3 p4 r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + (inW / 2)) < outW.
	interpreterProxy success: (dstY + (inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		srcIndex := y * inW.
		dstIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |
			p1 := in at: srcIndex.
			p2 := in at: srcIndex + 1.
			p3 := in at: srcIndex + inW.
			p4 := in at: srcIndex + inW + 1.

			r := (((p1 bitAnd: 16rFF0000)
				+ (p2 bitAnd: 16rFF0000)
				+ (p3 bitAnd: 16rFF0000)
				+ (p4 bitAnd: 16rFF0000))
					bitShift: -2) bitAnd: 16rFF0000.

			g := (((p1 bitAnd: 16rFF00)
				+ (p2 bitAnd: 16rFF00)
				+ (p3 bitAnd: 16rFF00)
				+ (p4 bitAnd: 16rFF00))
					bitShift: -2) bitAnd: 16rFF00.

			b := (((p1 bitAnd: 16rFF)
				+ (p2 bitAnd: 16rFF)
				+ (p3 bitAnd: 16rFF)
				+ (p4 bitAnd: 16rFF))
					bitShift: -2) bitAnd: 16rFF.

			"store combined RGB into target bitmap"
			out at: dstIndex put: ((r bitOr: g) bitOr: b).

			"increment indices"
			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1.
	]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeAveraged3 [

	| in out inOop outOop inW inH outW outH dstX dstY srcIndex dstIndex pixel r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + (inW / 2)) < outW.
	interpreterProxy success: (dstY + (inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		srcIndex := y * inW.
		dstIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |
			pixel := in at: srcIndex.
			r := pixel bitAnd: 16rFF0000.
			g := pixel bitAnd: 16rFF00.
			b := pixel bitAnd: 16rFF.

			pixel := in at: srcIndex + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			pixel := in at: srcIndex + inW.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			pixel := in at: srcIndex + inW + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			"store combined RGB into target bitmap"
			out at: dstIndex put:
				(((r bitShift: -2) bitAnd: 16rFF0000) bitOr:
				(((g bitShift: -2) bitAnd: 16rFF00) bitOr: (b bitShift: -2))).

			"increment indices"
			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1.
	]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeMixed [

	| in out inOop outOop inW inH outW outH dstX dstY baseIndex outPix p1 p2 r g b i |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + ( inW / 2)) < outW.
	interpreterProxy success: (dstY + ( inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		baseIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |

			"get source pixels, pick diagonal ones, ignore others"
			p1 := in at: x + (y * inW). 

			((x < (inW - 1)) & (y < (inH -1 )))
				ifTrue:[
					p2 := in at: (x +1) + (y + 1 * inW).

					"average rgb values of both picked pixels in place, ignore alpha"
					r := (((p1 bitAnd: 16rFF0000)
						+ (p2 bitAnd: 16rFF0000))
						/ 2) bitAnd: 16rFF0000.

					g := (((p1 bitAnd: 16rFF00)
						+ (p2 bitAnd: 16rFF00))
						/ 2) bitAnd: 16rFF00.

					b := (((p1 bitAnd: 16rFF)
						+ (p2 bitAnd: 16rFF))
						/ 2) bitAnd: 16rFF.

					"assemble the output pixel"
					outPix := r bitOr: (g bitOr: b) ]

				ifFalse: [outPix := p1]. "if on edge, just take the current pixel and skip the averaging"

			"store into target bitmap"
			i:= baseIndex + ( x/2).
			out at: i put: outPix.]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeMixed2 [

	| in out inOop outOop inW inH outW outH dstX dstY srcIndex dstIndex pixel r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + (inW / 2)) < outW.
	interpreterProxy success: (dstY + (inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		srcIndex := y * inW.
		dstIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |
			pixel := in at: srcIndex.
			r := pixel bitAnd: 16rFF0000.
			g := pixel bitAnd: 16rFF00.
			b := pixel bitAnd: 16rFF.

			pixel := in at: srcIndex + inW + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			"store combined RGB into target bitmap"
			out at: dstIndex put:
				(((r bitShift: -1) bitAnd: 16rFF0000) bitOr:
				(((g bitShift: -1) bitAnd: 16rFF00) bitOr: (b bitShift: -1))).

			"increment indices"
			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1.
	]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeMixed3 [

	| in out inOop outOop inW inH outW outH dstX dstY srcIndex dstIndex p1 p2 r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + (inW / 2)) < outW.
	interpreterProxy success: (dstY + (inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		srcIndex := y * inW.
		dstIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |
			p1 := in at: srcIndex.
			p2 := in at: srcIndex + inW + 1.

			r := (((p1 bitAnd: 16rFF0000) + (p2 bitAnd: 16rFF0000)) bitShift: -1) bitAnd: 16rFF0000.
			g := (((p1 bitAnd: 16rFF00) + (p2 bitAnd: 16rFF00)) bitShift: -1) bitAnd: 16rFF00.
			b := ((p1 bitAnd: 16rFF) + (p2 bitAnd: 16rFF)) bitShift: -1.

			"store combined RGB into target bitmap"
			out at: dstIndex put: (r bitOr: (g bitOr: b)).

			"increment indices"
			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1.
	]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeMixed4 [

	| in out inOop outOop inW inH outW outH dstX dstY srcIndex dstIndex p1 p2 r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + (inW / 2)) < outW.
	interpreterProxy success: (dstY + (inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		srcIndex := y * inW.
		dstIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |
			p1 := in at: srcIndex.
			p2 := in at: srcIndex + inW + 1.

			r := (((p1 bitShift: -16) + (p2 bitShift: -16)) bitShift: 15) bitAnd: 16rFF0000.
			g := (((p1 bitShift: -8) + (p2 bitShift: -8)) bitShift: 7) bitAnd: 16rFF00.
			b := ((p1 + p2) bitShift: -1) bitAnd: 16rFF.

			"store combined RGB into target bitmap"
			out at: dstIndex put: (r bitOr: (g bitOr: b)).

			"increment indices"
			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1.
	]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #scaling }
LowResPlugin >> primitiveHalfSizeRaw [

	| in out inOop outOop inW inH outW outH dstX dstY baseIndex pix i |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + ( inW / 2)) < outW.
	interpreterProxy success: (dstY + ( inH / 2)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 by: 2 do: [:y |
		baseIndex := ((dstY + (y/2)) * outW) + dstX.
		0 to: inW - 1 by: 2 do: [:x |
			pix := in at: x + (y * inW).
			i := baseIndex + ( x/2).
			out at: i put: pix.]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

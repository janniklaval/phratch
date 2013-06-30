"
I display a graph of numbers, normalized so the full range of values just fits my height. I support a movable cursor that can be dragged with the mouse.

Implementation notes: Some operations on me may be done at sound sampling rates (e.g. 11-44 thousand times/second). To allow such high bandwidth application, certain operations that change my appearance do not immediately report a damage rectangle. Instead, a flag is set indicating that my display needs to refreshed and a step method reports the damage rectangle if that flag is set. Also, I cache a bitmap of my graph to allow the cursor to be moved without redrawing the graph.

All indices, like startIndex, cursor, etc are in terms of the graph data.

IMPORTANT!  The current implementation cannot stand alone, it needs to be a submorph of SoundEditor.

"
Class {
	#name : #PhratchGraphMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'data',
		'dataColor',
		'playCursorColor',
		'playing',
		'cursorColor',
		'cursorColorAtZeroCrossings',
		'startIndex',
		'minVal',
		'maxVal',
		'selection',
		'scale',
		'cachedForm',
		'hasChanged',
		'ruler',
		'viewer',
		'trueCalls',
		'falseCalls',
		'negVals',
		'posVals',
		'editor'
	],
	#classVars : [
		'MinScale'
	],
	#category : #'Phratch-Sound'
}

{ #category : #'instance creation' }
PhratchGraphMorph class >> MinScale [

	^MinScale
]

{ #category : #'instance creation' }
PhratchGraphMorph class >> MinScale: aNumber [

	"aNumber should be equal to: viewer extent x/ graph data size"
	MinScale := aNumber asFloat.

]

{ #category : #'instance creation' }
PhratchGraphMorph class >> openOn: dataCollection [
	"Open a new GraphMorph on the given sequencable collection of data."

	^ (self new data: dataCollection) openInWorld

]

{ #category : #menu }
PhratchGraphMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'open wave editor' action: #openWaveEditor.
	aCustomMenu add: 'read file' action: #readDataFromFile.

]

{ #category : #initialization }
PhratchGraphMorph >> addRuler [

	ruler := PhratchRulerMorph graphMorph: self.
	self addMorphBack: ruler.
	ruler position: self bottomLeft.

]

{ #category : #menu }
PhratchGraphMorph >> adjustSelection [
	"Adjust the selection, if any, to the current cursor position. Do nothing if there is no selection."

	editor selectionNil ifTrue: [^ self].
	editor selection: editor cursor scd: editor startSelection.


]

{ #category : #commands }
PhratchGraphMorph >> appendValue: aPointOrNumber [

	| newVal |
	(data isKindOf: OrderedCollection) ifFalse: [data := data asOrderedCollection].
	newVal := self asNumber: aPointOrNumber.
	data addLast: newVal.
	newVal < minVal ifTrue: [minVal := newVal].
	newVal > maxVal ifTrue: [maxVal := newVal].
	self cursor: data size.
	self flushCachedForm.

]

{ #category : #private }
PhratchGraphMorph >> calculateDataArray [

	| currIndex neg pos |

	negVals := OrderedCollection new.
	posVals := OrderedCollection new.

	data isEmpty ifTrue: [^ self].
	currIndex:= neg:=pos := 0.

	(1 to: data size) do: [ :i |
		((i * scale) truncated > currIndex)
			ifTrue: [
			
					currIndex := (i*scale) truncated.		
					neg := neg min: (data at: i).
					pos := pos max: (data at: i).
			
					posVals add: pos.
					negVals	add: neg.
		
					pos := neg := 0.]
			ifFalse: [
						neg := neg min: (data at: i).
						pos := pos max: (data at: i).].].
]

{ #category : #commands }
PhratchGraphMorph >> centerCursor [
	"Scroll so that the cursor is as close as possible to the center of my window."

	| w |

	w := self width - (2 * borderWidth).
	self startIndex: ((editor cursor - (w // (scale*2))) max: 1).

]

{ #category : #commands }
PhratchGraphMorph >> clear [

	self startIndex: 1.
	self cursor: 1.
	self data: OrderedCollection new.

]

{ #category : #accessing }
PhratchGraphMorph >> color: aColor [

	super color: aColor.
	self flushCachedForm.

]

{ #category : #viewing }
PhratchGraphMorph >> computeSlider [
	
	editor slider sliderThickness: ((bounds width//scale)/data size)*(editor slider extent x).
	editor slider changed.
]

{ #category : #accessing }
PhratchGraphMorph >> cursor [

	^ editor cursor

]

{ #category : #accessing }
PhratchGraphMorph >> cursor: aNumber [


	editor cursor: aNumber.

]

{ #category : #accessing }
PhratchGraphMorph >> cursorAtEnd [

	^editor cursor truncated >= data size

]

{ #category : #accessing }
PhratchGraphMorph >> cursorColor [

	^ cursorColor

]

{ #category : #accessing }
PhratchGraphMorph >> cursorColor: aColor [

	cursorColor := aColor.
	self flushCachedForm.

]

{ #category : #accessing }
PhratchGraphMorph >> cursorColorAtZeroCrossing [

	^ cursorColorAtZeroCrossings

]

{ #category : #accessing }
PhratchGraphMorph >> cursorColorAtZeroCrossings: aColor [

	cursorColorAtZeroCrossings := aColor.
	self flushCachedForm.

]

{ #category : #accessing }
PhratchGraphMorph >> cursorWrapped: aNumber [

	| sz |
	editor cursor ~= aNumber ifTrue: [
		editor cursor: aNumber.
		sz := data size.
		sz = 0
			ifTrue: [editor cursor: 1]
			ifFalse: [
				((editor cursor >= (sz + 1)) or: [editor cursor < 0]) ifTrue: [
					 editor cursor: editor cursor - ((editor cursor // sz) * sz)].
				editor cursor < 1 ifTrue: [editor cursor: sz + editor cursor]].
		"assert: 1 <= cursor < data size + 1"
		hasChanged := true].

]

{ #category : #accessing }
PhratchGraphMorph >> customScale [
	"Called when the user wants to input a scale value."

	| answer |
	answer := UIManager request: 'Please type desired scale:' initialAnswer: '2x'.
	answer size = 0 ifTrue: [^ self].
	answer := answer copyWithout: $x.
	self zoom: answer asNumber.

]

{ #category : #accessing }
PhratchGraphMorph >> data [

	^ data

]

{ #category : #accessing }
PhratchGraphMorph >> data: aCollection [

	data := aCollection.
	maxVal := minVal := 0.
	data do: [:x |
		x < minVal ifTrue: [minVal := x].
		x > maxVal ifTrue: [maxVal := x]].

	self flushCachedForm.

]

{ #category : #accessing }
PhratchGraphMorph >> dataColor [

	^ dataColor

]

{ #category : #accessing }
PhratchGraphMorph >> dataColor: aColor [

	dataColor := aColor.
	self flushCachedForm.

]

{ #category : #private }
PhratchGraphMorph >> drawCursorOn: aCanvas [

	| ptr x r c |
	ptr := (editor cursor asInteger max: 1) min: data size.
	c := cursorColor.
	((ptr > 1) and: [ptr < data size]) ifTrue: [
		(data at: ptr) sign ~= (data at: ptr + 1) sign
			ifTrue: [c := cursorColorAtZeroCrossings]].
	r := self innerBounds.
	x := r left + ((ptr - startIndex)*scale).
	((x >= r left) and: [x <= r right]) ifTrue: [
		aCanvas fillRectangle: (x@r top corner: x + 1@r bottom) color: c].

]

{ #category : #private }
PhratchGraphMorph >> drawDataOn: aCanvas [

	| x start end left right yScale baseLine top bottom |
	super drawOn: aCanvas.

	viewer ifTrue: [self drawViewOn: aCanvas.].
	self drawSelectionOn: aCanvas.

	(posVals isNil) ifTrue: [^ self].

	maxVal = minVal ifTrue: [yScale := 1.] 
					ifFalse: [yScale := (bounds height - (2 * borderWidth)) asFloat / (maxVal - minVal)].
	baseLine := bounds bottom - borderWidth + (minVal * yScale) truncated.

	left := 0. right := 10.
	x := bounds left + borderWidth.

	start := (startIndex*scale) truncated min: data size max: 1.
	end := start + bounds width min: data size.

	start to: end do: [:i |
		i > posVals size ifTrue: [^self].
					
		left := x truncated. right := x + 1.
		right > (bounds right - borderWidth) ifTrue: [^ self].

		top := baseLine min: (baseLine - (yScale*(posVals at: i))) truncated.
		bottom := (baseLine max: baseLine - (yScale*(negVals at: i))) truncated.
											
		aCanvas fillRectangle: (left@top corner: right@bottom) color: dataColor.
		x := x + 1].
]

{ #category : #drawing }
PhratchGraphMorph >> drawOn: aCanvas [

	| c |

	cachedForm = nil ifTrue:  [
		c := FormCanvas extent: bounds extent.
		c translateBy: bounds origin negated
			during:[:tempCanvas| self drawDataOn: tempCanvas].
		cachedForm := c form].
	aCanvas paintImage: cachedForm at: bounds origin.
	self drawCursorOn: aCanvas.
	self drawPlayCursorOn: aCanvas.
	
]

{ #category : #private }
PhratchGraphMorph >> drawPlayCursorOn: aCanvas [

	| ptr x r c |

	editor playCursor ifNil: [^self].
	(editor endPlaying ~= data size) & (editor playCursor >= (editor endPlaying)) ifTrue: [^self].

	ptr := (editor playCursor asInteger max: 1) min: data size.
	c := cursorColor.
	r := self innerBounds.
	x := r left + ((ptr - startIndex)*scale).
	((x >= r left) and: [x <= r right]) ifTrue: [
		aCanvas fillRectangle: (x@r top corner: x + 1@r bottom) color: c].

]

{ #category : #private }
PhratchGraphMorph >> drawSelectionOn: aCanvas [

	| x y lightColor darkColor v1 v2 offsetX s1 s2 bottom |

	editor selectionNil ifTrue: [^ self].

	lightColor := Color lightBlue. "(Color r: 0.2 g: 1.0 b: 0.907)."
	darkColor := lightColor darker darker darker.

	v1 := (editor graph startIndex asInteger max: 1) min: data size.
	v2 := v1 + (bounds width/(editor graph scale)) min: data size.
	

	offsetX := bounds left + borderWidth.
	x := (offsetX + ((selection first - startIndex)*scale)).
	y := bounds top + borderWidth.

	viewer 
		ifFalse: [
			selection first > v2 ifTrue: [^ self].  "selection is not visible"
			selection last < v1 ifTrue: [^ self].  "selection is not visible"

			aCanvas
				fillRectangle: (x@y extent: ((selection last - selection first)*scale)@(self height - (2 * borderWidth)))
				color: lightColor. "lightYellow"]
		ifTrue: [
			s1 := selection first.
			s2 := selection second.

			bottom := self height - (2 * borderWidth).


			((s1 max: s2) <= v1) | ((s1 min: s2) >= v2)
				ifTrue: [^aCanvas 				
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((s2-s1)*scale)@bottom)
							color: darkColor.].
			
			(s1 <= v1) & (s2 >= v2)
				ifTrue: [^aCanvas fillRectangle: ((offsetX + (s1*scale))@y extent: ((v1-s1)*scale)@bottom)
								color: darkColor;
								fillRectangle: ((offsetX + (v1*scale))@y extent: ((v2-v1)*scale)@bottom)
								color: lightColor;
								fillRectangle: (( offsetX + (v2*scale))@y extent: ((s2-v2)*scale)@bottom)
								color: darkColor.].
			
			(s1 >= v1) & (s2 <= v2)
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((s2-s1)*scale)@bottom)
							color: lightColor.].
	
			(s1 < v1) & (s2 > v1) & (s2 < v2)
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((v1-s1)*scale)@bottom)
							color: darkColor;
							fillRectangle: ((offsetX + (v1*scale))@y extent: ((s2- v1)*scale)@bottom)
							color: lightColor.].
		
			(s1 >= v1) & (s2 >= v2) 
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((v2-s1)*scale)@bottom)
							color: lightColor;
							fillRectangle: ((offsetX + (v2*scale))@y extent: ((s2 - v2)*scale)@bottom)
							color: darkColor.].

			"Transcript show: 'no category :(';cr."

			].




]

{ #category : #private }
PhratchGraphMorph >> drawViewOn: aCanvas [

	"highlights the part of the graph morph we're viewing."
	| y ex start x |

	viewer ifFalse: [^self].
	
	
	start := ((editor graph startIndex*bounds width)/data size) truncated min: data size.
	ex:= ((editor slider sliderThickness/editor slider extent x)*(bounds width)) min: data size.

	x := (bounds left + borderWidth + start).
	y := bounds top + borderWidth.

	aCanvas
		fillRectangle: (x@y extent: ex@(self height - (2 * borderWidth)))
		color: Color white. "lightYellow".

]

{ #category : #accessing }
PhratchGraphMorph >> editor [

	^editor
]

{ #category : #accessing }
PhratchGraphMorph >> editor: aSoundEditor [

	editor := aSoundEditor.
]

{ #category : #private }
PhratchGraphMorph >> flushCachedForm [

	cachedForm := nil.
	hasChanged := true.
 
]

{ #category : #events }
PhratchGraphMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #drawing }
PhratchGraphMorph >> hasChanged: aBoolean [
	
	hasChanged := aBoolean.
]

{ #category : #initialization }
PhratchGraphMorph >> initialize [

	super initialize.
	self color: (Color r: 0.8 g: 0.8 b: 0.6).
	self extent: 365@80.
	self borderWidth: 2.
	dataColor := Color darkGray.
	cursorColor := Color red.
	playCursorColor := Color blue.
	cursorColorAtZeroCrossings := Color red.
	startIndex := 1.
	viewer := false.
	selection := {nil. nil}.
	scale := 1.0.
	hasChanged := false.
	posVals := negVals := nil.

	self data:
		((0 to: 360 - 1) collect:
			[:x | (100.0 * (x degreesToRadians sin)) asInteger]).

	
	

]

{ #category : #accessing }
PhratchGraphMorph >> interpolatedValueAtCursor [

	| sz prev frac next |
	data isEmpty ifTrue: [^ 0].
	sz := data size.
	owner cursor < 0 ifTrue: [^ data at: 1].  "just to be safe, though cursor shouldn't be negative"
	prev := owner cursor truncated.
	frac := owner cursor - prev.
	prev < 1 ifTrue: [prev := sz].
	prev > sz ifTrue: [prev := 1].
	"assert: 1 <= prev <= sz"
	frac = 0 ifTrue: [^ data at: prev].  "no interpolation needed"

	"interpolate"
	next := prev = sz ifTrue: [1] ifFalse: [prev + 1].
	^ ((1.0 - frac) * (data at: prev)) + (frac * (data at: next))

]

{ #category : #private }
PhratchGraphMorph >> keepIndexInView: index [

	| w newStart |

	w := bounds width - (2 * borderWidth).
	index < startIndex ifTrue: [
		newStart := index - w//scale + 1.
		^ self startIndex: (newStart max: 1)].
	index > (startIndex + w//scale) ifTrue: [
		^ self startIndex: (index min: data size)].

]

{ #category : #accessing }
PhratchGraphMorph >> lastValue [

	data size = 0 ifTrue: [^ 0].
	^ data last

]

{ #category : #accessing }
PhratchGraphMorph >> lastValue: aNumber [

	self appendValue: aNumber.

]

{ #category : #'change reporting' }
PhratchGraphMorph >> layoutChanged [

	super layoutChanged.
	cachedForm := nil.

]

{ #category : #commands }
PhratchGraphMorph >> loadSineWave [

	self loadSoundData: FMSound sineTable.

]

{ #category : #commands }
PhratchGraphMorph >> loadSound: aSound [

	self loadSoundData: aSound samples.

]

{ #category : #commands }
PhratchGraphMorph >> loadSoundData: aCollection [

	| factor absV newData |
	factor := 0.
	aCollection do: [:v | (absV := v abs) > factor ifTrue: [scale := absV]].
	scale := 100.0 / factor.
	newData := OrderedCollection new: aCollection size.
	1 to: aCollection size do: [:i | newData addLast: (factor * (aCollection at: i))].

	self data: newData.
	self startIndex: 1.
	self cursor: 1.

]

{ #category : #events }
PhratchGraphMorph >> mouseDown: evt [

	"Handles mouse down and drag events.  Updates the cursor's position and sets the selection to an array containing two copies of the current cursor value."
	| x s |

	 x := evt cursorPoint x - (bounds left + borderWidth).

	s := editor startSelection.
	editor startSelection: editor cursor.  
	editor cursor: startIndex + (x/scale).
		
	evt shiftPressed
		ifTrue: [  editor selectionNil 
					ifFalse: [
						editor startSelection: s.
				  		self adjustSelection.].]
		ifFalse: [
				 ((editor selectionNil not) and: [(selection at: 2) - (selection at: 1) > 3])
						ifTrue: [ editor selection: nil.
			  				      self flushCachedForm.
				 				 self changed.].
			  	 editor startSelection: editor cursor.
				 editor selection: {editor cursor. editor cursor}.].


	 
	
	
]

{ #category : #events }
PhratchGraphMorph >> mouseMove: evt [

	"Updates the cursor position as the mouse moves.  Adjusts the selection only if the mouse is currently being pressed"
	| x w |

	x := evt cursorPoint x - (bounds left + borderWidth).
	w := self width - (2 * borderWidth).

	(viewer not and: [x < 0]) ifTrue: [
		editor cursor: startIndex + (x /scale).
		self adjustSelection.
		editor slider setValue: (startIndex/data size).
		^ self startIndex: self editor cursor].
	(viewer not and: [x > w]) ifTrue: [
		editor cursor: startIndex + (x /scale).
		self adjustSelection.
		editor slider setValue: (startIndex/data size).
		^ self startIndex: editor cursor - (w/scale) truncated.
		"^ editor cursor = data size
			ifTrue: [ self startIndex: editor cursor - (w/(scale*2)) truncated.]
			ifFalse: [ self startIndex: editor cursor - (w/scale) truncated.]."].


	evt anyButtonPressed 
		ifTrue: [editor cursor: (startIndex + (x/scale) truncated).
				self adjustSelection.]

]

{ #category : #events }
PhratchGraphMorph >> mouseUp: evt [

	((editor selectionNil not) and: [(selection at: 2) - (selection at: 1) <=3])
		ifTrue: [editor selection: nil.
				editor startSelection: nil.].

]

{ #category : #menu }
PhratchGraphMorph >> openWaveEditor [

	| factor scaledData |
	self data: data.  "make sure maxVal and minVal are current"
	factor := 32767 // ((minVal abs max: maxVal abs) max: 1).
	scaledData := SoundBuffer newMonoSampleCount: data size.
	1 to: data size do: [:i | scaledData at: i put: (factor * (data at: i)) truncated].
	(SimpleWaveEditor new
		data: scaledData;
		samplingRate: 11025) openInWorld.

]

{ #category : #commands }
PhratchGraphMorph >> playOnce [

	| factor absV scaledData |
	data isEmpty ifTrue: [^ self].  "nothing to play"
	factor := 1.
	data do: [:v | (absV := v abs) > factor ifTrue: [factor := absV]].
	factor := 32767.0 / factor.
	scaledData := SoundBuffer newMonoSampleCount: data size.
	1 to: data size do: [:i |
		scaledData at: i put: (factor * (data at: i)) truncated].
	(SampledSound samples: scaledData samplingRate: 11025) play.

]

{ #category : #menu }
PhratchGraphMorph >> readDataFromFile [

	| result fName menu |
	menu := MenuMorph new defaultTarget: self.
	#(aif aiff au wav) do:[:aVarName |
		menu add: aVarName
			target: self 
			selector: #readDataKind:
			argument: aVarName.
	].
	menu localize; popUpInWorld.
	
]

{ #category : #menu }
PhratchGraphMorph >> readDataKind: aKind [
	
	| fName |
	fName :=  FileSystem workingDirectory / 'Sound' / aKind.
	self data: (SampledSound fromFileNamed: fName) samples.


]

{ #category : #commands }
PhratchGraphMorph >> reverse [

	data := data reversed.
	self flushCachedForm.

]

{ #category : #accessing }
PhratchGraphMorph >> ruler [

	^ruler.
]

{ #category : #accessing }
PhratchGraphMorph >> scale [
	
	^scale.
]

{ #category : #accessing }
PhratchGraphMorph >> scale: aNumber [

	"setting the absolute scale of how the graph is display.  It is relative to MinScale, the minimum scale possible, which is the scale value of the viewer."

	aNumber < 1 ifTrue: [^self].
	scale := (aNumber*MinScale) asFloat min: 1.
	
	self calculateDataArray.
	self flushCachedForm; changed.
	editor viewer flushCachedForm; changed.

	editor updateSlider.

]

{ #category : #accessing }
PhratchGraphMorph >> selection [

	^ selection

]

{ #category : #accessing }
PhratchGraphMorph >> selection: anArrayOrNil [
	"Set the selection to the given (startIndex, stopIndex) pair to to nil."

	anArrayOrNil
		ifNil: [	selection at: 1 put: nil. selection at: 2 put: nil]
		ifNotNil: [ selection := anArrayOrNil.].


]

{ #category : #viewing }
PhratchGraphMorph >> setScale [

	| menu choice |

	menu := MenuMorph new defaultTarget: self.
	menu add: '1x' target: self selector: #setScaleBy: argument: 1;
		   add: '2x' target: self selector: #setScaleBy: argument: 2;
		   add: '3x' target: self selector: #setScaleBy: argument: 3;
		   add: '4x' target: self selector: #setScaleBy: argument: 4;
		   add: '5x' target: self selector: #setScaleBy: argument: 5;
		   add: 'other' target: self selector: #setScaleBy: argument: #customScale.
	menu popUpInWorld.
	
	
]

{ #category : #'as yet unclassified' }
PhratchGraphMorph >> setScaleBy: choice [

	choice = #customScale 
		ifFalse: [self scale: choice.]	
		ifTrue: [ self customScale].
]

{ #category : #accessing }
PhratchGraphMorph >> startIndex [

	^ startIndex

]

{ #category : #accessing }
PhratchGraphMorph >> startIndex: aNumber [

	startIndex ~= aNumber ifTrue:  [
		startIndex := aNumber asInteger.
		self flushCachedForm].

]

{ #category : #stepping }
PhratchGraphMorph >> step [
	"Make a deferred damage rectangle if I've changed. This allows applications to call methods that invalidate my display at high-bandwidth without paying the cost of doing the damage reporting on ever call; they can merely set hasChanged to true."

	super step.
	
	hasChanged == nil ifTrue: [hasChanged := false].
	hasChanged ifTrue: [
		self changed.
		hasChanged := false].

]

{ #category : #stepping }
PhratchGraphMorph >> stepTime [

	^150
]

{ #category : #accessing }
PhratchGraphMorph >> valueAtCursor [

	data isEmpty ifTrue: [^ 0].
	^ data at: ((editor cursor truncated max: 1) min: data size).

]

{ #category : #accessing }
PhratchGraphMorph >> valueAtCursor: aPointOrNumber [

	data isEmpty ifTrue: [^ 0].
	data
		at: ((editor cursor truncated max: 1) min: data size)
		put: (self asNumber: aPointOrNumber).
	self flushCachedForm.

]

{ #category : #viewing }
PhratchGraphMorph >> viewSelection [

	| diff |
	selection ifNil: [^self].
	scale := (MinScale*(data size/(selection second - selection first)) asFloat min: 1).
	self calculateDataArray.

	diff := (selection second - selection first) - bounds width.
	diff < 0
		ifTrue: [ self startIndex: selection first asInteger + (diff//2)]
		ifFalse: [self startIndex: selection first asInteger.].
	
	
	editor updateSlider.


	
]

{ #category : #accessing }
PhratchGraphMorph >> viewer: aBoolean [

	viewer := aBoolean. "whether or not this graphMorph is the viewer graph Morph"
	
	viewer ifFalse: [self color: Color white.].
]

{ #category : #viewing }
PhratchGraphMorph >> zoom: aNumber [

	scale := ((scale*aNumber asFloat) max: MinScale asFloat) min: 1.
	
	self calculateDataArray.
	self flushCachedForm; changed.
	editor viewer flushCachedForm; changed.

	editor updateSlider.
]

{ #category : #viewing }
PhratchGraphMorph >> zoomIn [

	self zoom: 2.
]

{ #category : #viewing }
PhratchGraphMorph >> zoomOut [

	self zoom: 0.5.
]

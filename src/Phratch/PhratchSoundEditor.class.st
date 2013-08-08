"
A sound editor, based on the wave editor.  It can be brought up by the SoundMorph.  When the soundEditor is brought up, it is created with a copy of the sound in the sound morph. It contains the sound of the soundmorph and is capable of editing that sound.  That sound is set in the method ""sound:""

""viewing""
graph 					GraphMorph			
viewer					GraphMorph
selection 				    Array				an array of 2 #s that are the start and end of the selection.  This and the next 2 												variables are in terms of indices of the graph data
startSelection 			   Number				a number indicating the constant pt in a selection (mouse down loc)
cursor					   Number				a number indicating the location of the cursor

""Scrolling in view""
scrollDelta			        Number				a number telling us how much to scroll by, used in stepping to allow scrolling by 												buttons
slider					   slider morph			a slider for the graph
time					   a number			where we are in the graph in terms os msecs
deltaVal 					number				how much the cursor scrolls by, scrolldelta is set to +- this value
fwdButton 					button				scolling
backButton     				button				scrolling

""Playing variables"" 
origSamplingRate 		  big number			indicates the sampling rate of the song @ loading
												so u can reset to that sampling rate.
samplingRate 	         another big number		indicates current sampling rate.	
(2 above aren't currently used)

volume					   slider morph			indicates volume, (0 to 1.0)		
preview						boolean 			whether we're in play all mode or play 	from 												cursor mode, where the cursor moves along with 												the music
""Sound manipulation""
snd 						SampledSound		Current sound used for playing from cursor + selection
completeSnd 				SampledSound		The entire song after editing (doesn't change with playing)
soundMorphSound   			SampledSound		a ref to the sound of the SoundMorph that created this, 
												so that u can change the sound within that sound editor

""Editing tools""
copy						SoundBuffer		the portion of the graph data that has been copied
undoSound 					SampledSound		the sound before any cuts/pastes crops
undoSel 					Array				a copy of the selection bf any cut/paste/crop


rateSlider 					currently not implemented
keyboard
"
Class {
	#name : #PhratchSoundEditor,
	#superclass : #AlignmentMorph,
	#instVars : [
		'client',
		'soundName',
		'graph',
		'viewer',
		'selection',
		'startSelection',
		'playCursor',
		'cursor',
		'origSamplingRate',
		'samplingRate',
		'slider',
		'volume',
		'snd',
		'completeSnd',
		'copy',
		'time',
		'scrollDelta',
		'deltaVal',
		'fwdButton',
		'backButton',
		'undoSound',
		'undoSel',
		'undoCursor',
		'undoScale',
		'endPlaying'
	],
	#category : #'Phratch-Sound'
}

{ #category : #icons }
PhratchSoundEditor class >> downArrow [

	^ Form
		extent: 10@12
		depth: 4
		fromArray: #(3722304989 3707764736 3722304989 3707764736 3704479196 3170893824 3692739489 3170893824 3550548241 1023410176 3720417563 3707764736 3711570339 3707764736 3722121645 3707764736 3722252605 3707764736 3722296285 3707764736 3722261469 3707764736 3722304989 3707764736)
		offset: 0@0

]

{ #category : #'instance creation' }
PhratchSoundEditor class >> openOn: dataCollection [
	"Open a new WaveEditor on the given sequencable collection of data."

	^ (self new data: dataCollection) openInWorld

]

{ #category : #icons }
PhratchSoundEditor class >> upArrow [
	"Uparrow form used in slider." 

	^ Form
		extent: 6@3
		fromArray: #(2r11e28 2r1111e27 2r111111e26)
		offset: 0@0

]

{ #category : #initialization }
PhratchSoundEditor >> addControls [

	| b r spacer |
	b := SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners;
		yourself.
	b borderColor: #raised; borderWidth: 3.
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	spacer := Morph new color: r color; extent: 40@5;
		yourself.  "spacer"
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'undo';		actionSelector: #undo;
		yourself).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'copy';		actionSelector: #copy;
		yourself).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'paste';		actionSelector: #paste;
		yourself).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'cut';		actionSelector: #cut;
		yourself).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'crop';		actionSelector: #crop;
		yourself).	
	r addMorphBack: (spacer fullCopy width: 25).
	r addMorphBack: (b copy target: graph;
							label: 'zoom selection';	actionSelector: #viewSelection;
		yourself).

	r addMorphBack: (spacer fullCopy width: 25).
	r addMorphBack: (b fullCopy label: 'okay';			actionSelector: #save;
		yourself).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'cancel';		actionSelector: #cancel;
		yourself).

	self addMorphBack: r.


]

{ #category : #initialization }
PhratchSoundEditor >> addGraph [

	| r |
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: graph.
	r addMorphBack: (AlignmentMorph newSpacer: r color).
	self addMorphBack: r.

]

{ #category : #initialization }
PhratchSoundEditor >> addPlayButtons [

	| b r m space n scaleSelector |
	b := SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners;
		yourself.
	b borderColor: #raised; borderWidth: 3.
	r := AlignmentMorph newColumn.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #topCenter.

	m := AlignmentMorph newRow.
	m color: Color transparent; borderWidth: 0; inset: 0.
	m hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	m centering: #center; cellPositioning: #leftCenter.

	space := Morph new color: r color; extent: 3@5;
		yourself.

	n := StringMorph new contents: 'Zoom to: '.
	m addMorphBack: n.

	scaleSelector :=  (IconicButton new
		labelGraphic: self class downArrow;
		extent: 15@15;
		color: Color transparent;
		borderWidth: 0;
		target: graph;
		actWhen: #buttonDown;
		actionSelector: #setScale;
		yourself).
	m addMorphBack: scaleSelector.
	m addMorphBack: (Morph new color: r color; extent: 5@5;
		yourself).
	m addMorphBack: (b copy target: graph; label: '+';			actionSelector: #zoomIn;
		yourself).
	m addMorphBack: (Morph new color: r color; extent: 5@5;
		yourself).
	m addMorphBack: (b copy target: graph; label: '-';			actionSelector: #zoomOut;
		yourself).

	"n := UpdatingStringMorph new
	target: graph;
	getSelector: #scale; 
	growable: false; width: 25; step.
	m addMorphBack: n."


	m addMorphBack: (Morph new color: r color; extent: 50@5;
		yourself).
	
	
	m addMorphBack: (b fullCopy label: 'Play All';			actionSelector: #playAll;
		yourself).
	m addMorphBack: space copy.
	m addMorphBack: (b fullCopy label: 'Play';				actionSelector: #playAfterCursor;
		yourself).
	m addMorphBack: space copy.
	m addMorphBack: (b fullCopy label: 'Stop';				actionSelector: #stop;
		yourself).

	m addMorphBack: (Morph new color: r color; extent: 50@5;
		yourself).
	m addMorphBack: (StringMorph new contents: 'Volume').
	m addMorphBack: space copy.
	
	volume := SimpleSliderMorph new
	color: Color veryVeryLightGray;
	extent: 60@2;
	target: self;
	actionSelector: #setVolume:;
		yourself.

	m addMorphBack: volume.

	m addMorphBack: (Morph new color: r color; extent: 50@5;
		yourself).

	r addMorphBack: (Morph new color: r color; extent: 5@5;
		yourself).
	r addMorphBack: m.
	

	self addMorphBack: r.


]

{ #category : #initialization }
PhratchSoundEditor >> addSlider [

	| r m spacer |
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.	
	
	spacer := Morph new color: r color; extent: (graph left -10)@5;
		yourself.
	backButton := self makeSliderButton: 10@13.
	backButton addMorphCentered: (ImageMorph new form: (self class upArrow rotateBy: #left centerAt: 0@0)).

	fwdButton := self makeSliderButton: 10@13.
	fwdButton addMorphCentered: (ImageMorph new form: (self class upArrow rotateBy: #right centerAt: 0@0)).
	
	slider := SimpleSliderMorph new
		color: Color veryVeryLightGray;
		extent: (graph width)@2;
		target: self;
		setMaxVal: (graph bounds width/(graph scale*graph data size));
		actionSelector: #scrollTime:;
		yourself.
	
	r addMorph: spacer.
	r addMorph: fwdButton.
	r addMorph: slider.
	r addMorph: backButton.
	
	m := Morph new color: r color; extent: 15@5;
		yourself.  "spacer"
	r addMorphBack: m.
	time := UpdatingStringMorph new
		target: self;
		getSelector: #startTime; 
		width: 40; step;
		yourself.
	time useStringFormat.
	r addMorphBack: time.

	self addMorphBack: r.

]

{ #category : #initialization }
PhratchSoundEditor >> addViewer [

	| r |

	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: viewer.
	r addMorphBack: (AlignmentMorph newSpacer: r color).

	self addMorphBack: r.
	

]

{ #category : #'graph ops' }
PhratchSoundEditor >> back [
	"Moves the cursor back in the music score."

	scrollDelta := -5.  
	self cursor: cursor + scrollDelta.
]

{ #category : #'graph ops' }
PhratchSoundEditor >> cancel [

	self delete.

]

{ #category : #accessing }
PhratchSoundEditor >> client: anObject [

	client := anObject.

]

{ #category : #'graph ops' }
PhratchSoundEditor >> copy [

	"copies the current selection if there is one."
	(selection at: 1) ifNotNil:
		[copy := graph data copyFrom: (graph selection at: 1) to: (graph selection at: 2).]
]

{ #category : #'graph ops' }
PhratchSoundEditor >> crop [
	
	| sel |

	"Crops the sound in the sound editor to be only the selected region"

	sel := ((selection at: 1) notNil and: [(selection at: 2) - (selection at: 1) > 3]).
	sel ifFalse: [^self].

	undoSel := graph selection copy.
	undoSound := SampledSound samples: graph data samplingRate: samplingRate.
	undoCursor := cursor.
	undoScale := graph scale/PhratchGraphMorph minScale.

	sel := graph data copyFrom: (selection at: 1) to: (selection at: 2).
	graph data: sel.
	viewer data: graph data.
	cursor := ((cursor - (selection at: 1)) truncated max: 1) min: graph data size truncated.

	"scales the botton viewer so that the data fits on the entire screen." 
	(selection second - selection first)/graph data size >= 0.05
		ifTrue: [PhratchGraphMorph minScale: (viewer extent x/ graph data size min: 1). "the mult factor in all scales, the minimum scale allowed...to get this just do self scale: 1, since this multiplied by input"
				viewer scale: 1.
				graph scale: 1.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: sel samplingRate: samplingRate.
	completeSnd setSamples: sel samplingRate: samplingRate.

	selection at: 1 put: 1.
	selection at: 2 put: graph data size.

]

{ #category : #accessing }
PhratchSoundEditor >> cursor [

	^cursor.
]

{ #category : #accessing }
PhratchSoundEditor >> cursor: aNumber [

	graph data ifNil: [^self].

	cursor ~= aNumber ifTrue:  [
	cursor := ((aNumber truncated max: 1) min: graph data size) truncated.
	"graph keepIndexInView: cursor."
	].
]

{ #category : #'graph ops' }
PhratchSoundEditor >> cut [ 

	| data1 data2 |
	(selection at: 1) ifNil: [^ self.].

	undoSound := SampledSound samples: graph data samplingRate: samplingRate.
	undoSel := graph selection copy.
	undoCursor := cursor.
	undoScale := graph scale/PhratchGraphMorph minScale.

	self copy.
	data1 := graph data copyFrom: 1 to: (selection at: 1).
	data2 := graph data copyFrom: (selection at: 2) to: graph data size.
	
	graph data: (data1, data2).
	viewer data: graph data.
		
	"scales the botton viewer so that the data fits on the entire screen." 
	((selection second - selection first)/graph data size asFloat) >= 0.05
		ifTrue: [PhratchGraphMorph minScale: (viewer extent x/ graph data size min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.
	cursor := (selection at: 1).
	
	selection at: 1 put: nil. 
	selection at: 2 put: nil.
]

{ #category : #accessing }
PhratchSoundEditor >> data: newData [

	graph data: newData.

]

{ #category : #accessing }
PhratchSoundEditor >> endPlaying [
 
	^endPlaying.
]

{ #category : #'graph ops' }
PhratchSoundEditor >> fixSliderRange [
 
	slider maxVal: (1 -(slider sliderThickness/slider extent x)).
	^slider
]

{ #category : #accessing }
PhratchSoundEditor >> graph [

	^ graph

]

{ #category : #'event handling' }
PhratchSoundEditor >> handlesMouseDown: evt [

	| p |
	p := evt cursorPoint.
	^ (Rectangle origin: backButton topLeft corner: fwdButton bottomRight) containsPoint: p.
]

{ #category : #'event handling' }
PhratchSoundEditor >> handlesMouseOver: evt [

	^true.
]

{ #category : #initialization }
PhratchSoundEditor >> initialize [

	super initialize.
	copy := nil.
	selection := {nil. nil}.
	scrollDelta := 0.
	deltaVal := 10.
	cursor := 200.
	playCursor := nil.
	samplingRate := SoundPlayer samplingRate.
	soundName := 'sound'.
	self extent: 5@5;
		orientation: #vertical;
		centering: #centered;
		cellPositioning: #topCenter;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		inset: 3;
		color: Color lightGray;
		borderWidth: 2.
	graph := PhratchGraphMorph new extent: 380@150.
	graph editor: self.
	graph selection: selection.
	graph addRuler.
	graph viewer: false.

	viewer := PhratchGraphMorph new extent: 380@30.
	viewer editor: self.
	viewer cursorColorAtZeroCrossings: Color red.
	viewer viewer: true.
	viewer selection: selection.

	self addControls.
	self addPlayButtons.
	self addMorphBack: (Morph new color: self color; extent: 10@5;
		yourself).

	self addGraph.
	self addMorphBack: (Morph newBounds: (0@0 extent: 0@3) color: Color transparent).
	self addSlider.

	self addViewer.
	viewer left: backButton right.

]

{ #category : #menu }
PhratchSoundEditor >> invokeMenu [
	"Invoke a menu of additonal functions."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addList:	#(
		('save to file'		saveToFile)
		('read from file'	readFromFile)).
	aMenu popUpInWorld.


]

{ #category : #'event handling' }
PhratchSoundEditor >> keyStroke: evt [

	| keyVal |
	keyVal := evt keyCharacter asciiValue.

	keyVal = 28 ifTrue: [ cursor := cursor + (( -10) / graph scale)].
	keyVal = 29 ifTrue: [ cursor := cursor + (10/graph scale)].
]

{ #category : #initialization }
PhratchSoundEditor >> makeSliderButton: buttonExtent [

	| button |
	button := BorderedMorph
		newBounds: (self innerBounds bottomRight - buttonExtent extent: buttonExtent)
		color: Color lightGray.

	button setBorderWidth: 1 borderColor: #raised.
	^ button

]

{ #category : #'event handling' }
PhratchSoundEditor >> mouseDown: evt [
	"do stuff"

	| p |
	p := evt cursorPoint.
	(slider containsPoint: p)
		ifTrue: [ 
			scrollDelta := slider descending
				ifTrue: [ deltaVal negated ]
				ifFalse: [ deltaVal ] ].
	(backButton containsPoint: p)
		ifTrue: [ 
			backButton borderInset.
			scrollDelta := deltaVal negated ].
	(fwdButton containsPoint: p)
		ifFalse: [ ^ self ].
	fwdButton borderInset.
	scrollDelta := deltaVal
]

{ #category : #'event handling' }
PhratchSoundEditor >> mouseEnter: evt [

	evt hand newKeyboardFocus: self.
]

{ #category : #'event handling' }
PhratchSoundEditor >> mouseUp: evt [

	"do stuff"
	scrollDelta := 0.
	fwdButton borderRaised.
	backButton borderRaised.

]

{ #category : #menu }
PhratchSoundEditor >> origSamplingRate [

	^origSamplingRate.

]

{ #category : #'graph ops' }
PhratchSoundEditor >> paste [
	| data1 data2 |
	"inserts the copied data into the dataset where the cursor is."
	
	copy ifNil: [^self ].
	
	"self selectionNil ifTrue: [undoSel := nil.] ifFalse: [undoSel := selection copy.]."
	undoSel := selection copy.
	undoSound := SampledSound samples: graph data samplingRate: samplingRate.
	undoCursor := cursor.
	undoScale := graph scale/PhratchGraphMorph minScale.


	((self selectionNil not) and: [(selection at: 2) - (selection at: 1) > 3])
		ifTrue: [data1 := graph data copyFrom: 1 to: (graph selection at: 1).
			     data2 := graph data copyFrom: (graph selection at: 2) to: graph data size.]
		ifFalse: [data1 := graph data copyFrom: 1 to: graph cursor truncated.
				 data2 := graph data copyFrom: graph cursor truncated + 1 to: graph data size.].
	
	graph data: (data1, copy, data2).
	viewer data: graph data.

	"scales the botton viewer so that the data fits on the entire screen." 
	(copy size)/graph data size >= 0.05
		ifTrue: [PhratchGraphMorph minScale: (viewer extent x/ graph data size min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				self fixSliderRange.
				viewer startIndex: 1.
				graph computeSlider.].

	

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.

	self selection: {data1 size. (data1 size) + (copy size).}.
	cursor := selection at: 2.
	graph startIndex: (slider getScaledValue)*(graph data size).

	viewer flushCachedForm.
		
]

{ #category : #menu }
PhratchSoundEditor >> pause [

	(snd notNil and: [snd isPlaying])
		ifTrue: [snd pause.].

]

{ #category : #initialization }
PhratchSoundEditor >> playAfterCursor [

	| sel currSel |
	graph data size < 2 ifTrue: [^ self].
	 

	sel := ((selection at: 1) notNil and: [(selection at: 2) - (selection at: 1) > 3]).
	sel ifTrue: [currSel := graph data copyFrom: (selection at: 1) asInteger to: (selection at: 2) asInteger. playCursor := selection at: 1.
			    endPlaying := selection at: 2.]
	    ifFalse: [currSel := graph data copyFrom: (cursor max: 1) asInteger to: graph data size.
				playCursor := cursor.
				endPlaying := graph data size].
	
		self changed.


	snd isNil
		ifTrue: [
				 snd := (SampledSound samples: currSel samplingRate: origSamplingRate).
				 snd play.]
		ifFalse: [
			currSel = snd samples
				ifTrue: [snd samplesRemaining = 0 ifTrue: [snd reset].
						 snd resumePlaying.]
				ifFalse: [ snd setSamples: currSel samplingRate: origSamplingRate.
						 snd play]].


]

{ #category : #menu }
PhratchSoundEditor >> playAll [

	"Resumes playing the selection if there is one, otherwise resumes playing the entire soundtrack."

	graph data size < 2 ifTrue: [^ self].
	playCursor := 1.
	endPlaying := graph data size.

	snd isNil
		ifTrue: [
				 snd := (SampledSound samples: graph data samplingRate: origSamplingRate).
				 snd play.]
		ifFalse: [
			snd reset.
			(graph data = snd samples)
				ifTrue: [snd samplesRemaining = 0 ifTrue: [snd reset].
						 snd resumePlaying.]
				ifFalse: [snd setSamples: graph data samplingRate: origSamplingRate.
						 snd play]]

]

{ #category : #accessing }
PhratchSoundEditor >> playCursor [ 
	
	^playCursor.
]

{ #category : #menu }
PhratchSoundEditor >> playFrom: start to: end [

	| sz i1 i2 snd2 |
	sz := graph data size.
	i1 := ((start + 1) min: sz) max: 1.
	i2 := ((end + 1) min: sz) max: i1.
	(i1 + 2) >= i2 ifTrue: [^ self].
	snd2 := SampledSound
		samples: (graph data copyFrom: i1 to: i2)
		samplingRate: samplingRate.
	snd2 play.

]

{ #category : #menu }
PhratchSoundEditor >> readFromFile [
	"Read my samples from a file selected by the user."

	| menu |
	
	menu := MenuMorph new defaultTarget: self.
	#(aif aiff au wav) do:[:aVarName |
		menu add: aVarName
			target: self 
			selector: #readFromFile:
			argument: (FileSystem workingDirectory / 'Sound' / aVarName).
	].
	menu localize; popUpInWorld.
]

{ #category : #menu }
PhratchSoundEditor >> readFromFile: fName [
	"Read my samples from the file with the given name."

	fName exists
		ifFalse: [ ^ self inform: 'File not found' withDetails: fName ].
	snd := SampledSound fromFileNamed: fName.
	completeSnd := snd copy.
	graph cursor: 200.
	samplingRate := snd originalSamplingRate.
	origSamplingRate := snd originalSamplingRate.
	graph data: snd samples.
	graph scale: 2.0.
	self setVolume: 0.5.
	volume setScaledValue: 0.5.
	deltaVal := graph data size > 5000
		ifTrue: [ 50 ]
		ifFalse: [ graph data size // 10 ]
]

{ #category : #accessing }
PhratchSoundEditor >> samplingRate [

	^ samplingRate


]

{ #category : #menu }
PhratchSoundEditor >> samplingRate: sampleRate [

"Sets the samplingRate to somewhere btw 0.1 and 2.5 the original samplingRate, given a number btw 0.2 and 2.5 (sampleRate)"

	snd ifNil: [^self.].

	origSamplingRate = 0 
		ifFalse: [snd setSamples: snd samples samplingRate: (sampleRate*origSamplingRate)]
		ifTrue: [ snd setSamples: snd samples samplingRate: (sampleRate*10000)].

	

]

{ #category : #'graph ops' }
PhratchSoundEditor >> save [

	snd := SampledSound samples: completeSnd samples samplingRate: samplingRate.
	client ifNotNil: [client saveSound: snd name: soundName].
	self delete.

]

{ #category : #menu }
PhratchSoundEditor >> saveToFile [
	"Export my samples to a WAV file."

	| fileName samples f |
	fileName := StringDialog ask: 'File name?'.
	fileName size = 0
		ifTrue: [ ^ self ].
	(fileName asLowercase endsWith: '.wav')
		ifFalse: [ fileName := fileName , '.wav' ].
	samples := (graph data isKindOf: SoundBuffer)
		ifTrue: [ graph data ]
		ifFalse: [ SoundBuffer fromArray: graph data ].
	f := (FileStream newFileNamed: fileName) binary.
	(SampledSound samples: samples samplingRate: samplingRate) storeWAVSamplesOn: f.
	f close
]

{ #category : #accessing }
PhratchSoundEditor >> scrollTime: relativeValue [
 
	graph startIndex: relativeValue*(graph data size).

	viewer flushCachedForm; changed.





]

{ #category : #accessing }
PhratchSoundEditor >> selection [

	^selection.
]

{ #category : #accessing }
PhratchSoundEditor >> selection: anArrayorNil [

	anArrayorNil ifNil: [selection := {nil. nil}.]
			 ifNotNil: [selection := anArrayorNil.].
	graph selection: selection.
	viewer selection: selection
]

{ #category : #accessing }
PhratchSoundEditor >> selection: aNumber scd: anotherNumber [

	selection := { aNumber min: anotherNumber. aNumber max: anotherNumber}.
	graph selection: selection.
	viewer selection: selection.
	graph flushCachedForm; changed.
	viewer flushCachedForm; changed.
]

{ #category : #accessing }
PhratchSoundEditor >> selectionNil [
	
	(selection at: 1) ifNil: [^ true].
	
	^false.
]

{ #category : #menu }
PhratchSoundEditor >> setVolume: aFloat [

	"aFloat is a value btw 0 and 1.0"
	
	snd ifNil: [^self].
	snd adjustVolumeTo: aFloat overMSecs: 50.
]

{ #category : #accessing }
PhratchSoundEditor >> slider [ 
	^slider.
]

{ #category : #accessing }
PhratchSoundEditor >> sound [

	^snd.
]

{ #category : #'graph ops' }
PhratchSoundEditor >> sound: aSampledSound [
	"completeSnd is a version of the sound that is unaffected by the play mechanism.  This method is called when a SoundMorph brings up a SoundEditor. soundMorphSound is a copy of the initial sampledSound, used for saving and cancelling edits purposes.  It serves as a reference to the original sound so that we can actually change the sound in the soundMorph"

	snd := aSampledSound copy.
	completeSnd := snd copy.
	graph cursor: 200.
	samplingRate := snd originalSamplingRate.
	origSamplingRate := snd originalSamplingRate.
	PhratchGraphMorph minScale: graph extent x / completeSnd samples size.
	graph data: completeSnd samples.	"SHOULD IT BE COPY?/"
	graph scale: 2.
	graph calculateDataArray.	"self fixSliderRange.
	graph computeSlider."
	viewer data: completeSnd samples.
	viewer scale: 1.
	viewer calculateDataArray.
	self setVolume: snd loudness.
	volume setScaledValue: snd loudness.
	deltaVal := graph data size > 5000
		ifTrue: [ 200 ]
		ifFalse: [ graph data size // 10 ].
	self updateSlider
]

{ #category : #accessing }
PhratchSoundEditor >> soundName: aString [
	"Note the sound name to use when saving."

	soundName := aString.

]

{ #category : #accessing }
PhratchSoundEditor >> startSelection [
		
	^ startSelection.
]

{ #category : #accessing }
PhratchSoundEditor >> startSelection: aNumber [


	startSelection := aNumber.
]

{ #category : #'graph ops' }
PhratchSoundEditor >> startTime [
	| ss |
	"secs := cursor / samplingRate.
	hrs := secs // 3600.
	mins := (secs \\ 3600) // 60.
	secs := secs \\ 60 asFloat.
	ms := ((secs \\ 1) * 100) asFloat truncated.
	secs := secs // 1."
	" hrs asString,':',mins asString, ':', secs asString, '.', ms asString."
	ss := origSamplingRate isNil
		ifTrue: [ 20000 ]
		ifFalse: [ origSamplingRate ].
	^ (cursor asFloat / ss roundTo: 0.01) asString
]

{ #category : #'graph ops' }
PhratchSoundEditor >> startTime: hrMinSecs [
	
	| secs hrs mins hms |
	hms := hrMinSecs findTokens: ' :.'.
	hrs := hms at: 1.
	mins := hms at: 2.
	secs := hms at: 3.
	self startIndex: ((hrs asNumber * 3600) + (mins asNumber * 60) + secs asNumber) * samplingRate.

]

{ #category : #stepping }
PhratchSoundEditor >> step [

	| played prev |
	(SoundPlayer isPlaying: snd) ifTrue: [
		played := ((snd millisecondsSinceStart) * snd samples size) / (1000.0 * snd duration).
		prev := (completeSnd samples size - snd samples size).
		playCursor := (played + prev truncated min: graph data size).
		self changed].

	time contents: self startTime.

	scrollDelta = 0 ifFalse: [
		graph startIndex: graph startIndex + (scrollDelta/graph scale).
		self updateSliderValue.].

	graph computeSlider.
	self fixSliderRange.

]

{ #category : #stepping }
PhratchSoundEditor >> stepTime [


	^ 150

]

{ #category : #menu }
PhratchSoundEditor >> stop [

	snd pause.
	playCursor := nil.
	
]

{ #category : #'graph ops' }
PhratchSoundEditor >> undo [


	| tmpSound tmpSel tmpCursor tmpScale |

	undoSound ifNil: [^self].

	tmpSound := SampledSound samples: graph data samplingRate: samplingRate.
	tmpSel := graph selection copy.
	tmpCursor := cursor.
	tmpScale := graph scale/PhratchGraphMorph minScale.

	graph data: undoSound samples copy.
	viewer data: graph data.
	
	"scales the botton viewer so that the data fits on the entire screen." 
	(tmpSound samples size - graph data size) abs > 3
		ifTrue: [PhratchGraphMorph minScale: ((viewer extent x/ graph data size) min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.
	self selection: undoSel copy.
	cursor := undoCursor.

	undoSound := tmpSound.
	undoSel := tmpSel.
	undoCursor := tmpCursor.
	undoScale := tmpScale.

]

{ #category : #other }
PhratchSoundEditor >> updateSlider [
 
	"this is the order that these methods have to be called in order to update slider!!!"
	graph computeSlider.  
	self fixSliderRange.
	self updateSliderValue.
]

{ #category : #accessing }
PhratchSoundEditor >> updateSliderValue [
 
	slider setScaledValue: ((graph startIndex/graph data size min: slider maxVal) max: 0).





]

{ #category : #accessing }
PhratchSoundEditor >> viewer [
 
	^viewer.
]

Class {
	#name : #BlocksBoardMorph15,
	#superclass : #BlocksBoardMorph,
	#category : #PhratchEducationalBureau
}

{ #category : #initialization }
BlocksBoardMorph15 >> addReadouts [
	| t1 t2 t3 t4 t5 |
	column := AlignmentMorph newColumn centering: #center;
			 hResizing: #shrinkWrap;
			 vResizing: #shrinkWrap;
			 color: (PhratchEducationalBureau color);
			 borderWidth: 2;
			 borderColor: (Color
					r: 148 / 255
					g: 145 / 255
					b: 145 / 255);
			 useRoundedCorners;
			 inset: 3.
	titleMorph := StringMorph contents: '' font: (StrikeFont fontName: 'VerdanaBold' size: 10).
	titleMorph color: Color yellow.
	column addMorph: titleMorph.
	self updateTitle.
	column addMorphBack: (Morph new color: column color;
		 extent: 5 @ 3).
	self removeAllMorphs.
	readouts := Array new: 15.
	t1 := AlignmentMorph newRow color: column color;
			 inset: 2.
	t1 addMorphBack: (Morph new color: column color;
		 extent: 1 @ 3).
	1 to: 15 do: 
		[:t6 | 
		t2 := AlignmentMorph newColumn color: column color;
				 inset: 2.
		t2 centering: #center.
		t5 := StringMorph contents: t6 printString capitalized font: (StrikeFont fontName: 'VerdanaBold' size: 10).
		t5 color: Color yellow.
		t2 addMorphBack: t5.
		t3 := Morph new extent: 20 @ 20;
				 color: (PhratchCategory blockColorFor: 'sensing').
		t4 := StringMorph contents: ' ' font: (StrikeFont fontName: 'VerdanaBold' size: 10).
		t4 color: Color white.
		t3 addMorph: t4.
		t2 addMorphBack: t3.
		t1 addMorphBack: t2.
		t6 = 15 ifFalse: [t1 addMorphBack: (AlignmentMorph new color: column color;
				 extent: 10 @ 1;
				 hResizing: #spaceFill)].
		readouts at: t6 put: t4.
		].
	t1 addMorphBack: (Morph new color: column color;
		 extent: 1 @ 3).
	column addMorphBack: t1.
	column position: self position - 2.
	self addMorph: column.
	column extent: column extent +20.
	self extent: column extent - 4
]

{ #category : #'serial port' }
BlocksBoardMorph15 >> closePort [
	port
		ifNotNil: 
			[port flushInputBuffer.
			port close].
	port := nil.
	sensorValues atAllPut: 0.
	1 to: 15 do: [:t1 | (readouts at: t1)
			contents: ' '].
	scanState := #off.
	self step
]

{ #category : #initialization }
BlocksBoardMorph15 >> initialize [
	super initialize.
	self initializeSkin.
]

{ #category : #initialization }
BlocksBoardMorph15 >> initializeSkin [
	self setMyName: 'Educ-Bureau'.
	sensorValues := Array new: 15 withAll: 0.
	curSlot := 0.
	slotValue := 0.
	scanState := #off.
	self addReadouts.
	lastString := ByteString new: 15.
	
	self gotoX: -216 y: 156.
]

{ #category : #'sensor ops' }
BlocksBoardMorph15 >> sensor: t1 [ 
	t1 < 1 ifTrue: [^ 0].
	t1 > 15 ifTrue: [^ 0].
	^ sensorValues at: t1
]

{ #category : #stepping }
BlocksBoardMorph15 >> step [
	| t1 |
	super step.
	(#checkData = scanState or: [#start = scanState])
		ifTrue: [self scanForPort].
	self portIsOpen
		ifTrue: [self processIncomingData]
		ifFalse: [port := nil].
	self updateTitle.
	1 to: 15 do: 
		[:t2 | 
		(readouts at: t2)
			contents: ' ',(self stringFor: (self sensor: t2)).
		lastString at: t2 put: (PhratchEducationalBureau characterAt: (self sensor: t2)).
		t1 := (readouts at: t2) owner.
		(t1 respondsTo: #fixLayout)
			ifTrue: [t1 fixLayout]]
]

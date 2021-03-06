"
This morph is used to collect and redisplay damage when Scratch is in presentation mode.

"
Class {
	#name : #OffscreenWorldMorph,
	#superclass : #Morph,
	#instVars : [
		'damageRecorder',
		'frame'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #accessing }
OffscreenWorldMorph >> frame [

	^ frame

]

{ #category : #accessing }
OffscreenWorldMorph >> frame: aPhratchFrameMorph [

	frame := aPhratchFrameMorph.

]

{ #category : #drawing }
OffscreenWorldMorph >> incrRedrawDouble: doubleFlag [
	"Draw the damage areas on the display. Draw at double size if so indicated."

	| damageList m f c p screenR |
	damageRecorder updateIsNeeded ifFalse: [^ self].
	damageList := damageRecorder invalidRectsFullBounds: bounds.
	damageRecorder reset.

	submorphs size = 0 ifTrue: [^ self].
	m := submorphs first.

	damageList do: [:r |
		f := Form extent: r extent depth: 32.
		c := (FormCanvas on: f) copyOffset: r origin negated.
		m fullDrawOn: c.
		doubleFlag
			ifTrue: [
				
				p := (m center - m extent) + (2 * (r origin - m topLeft)).
				screenR := p extent: (2 * f extent).
				(Display boundingBox containsRect: screenR) ifTrue: [
					[
						(f magnifyBy: 2.0) displayOn: Display at: ((Display width - (f width*2))/2) @ ((Display height - (f height*2))/2).
						"PhratchPlugin
							primDouble: f w: f width h: f height
							into: Display w: Display width h: Display height
							x: (Display width - (f width*2))/2 y: (Display height - (f height*2))/2."
					] ifError: [:e | 
						ScriptablePhratchMorph noviceMode ifFalse:[e signal] ].
					Display forceToScreen: screenR]]
			ifFalse: [
				f displayOn: Display at: r topLeft rule: Form over]].

]

{ #category : #initialization }
OffscreenWorldMorph >> initialize [

	super initialize.
	damageRecorder := DamageRecorder new.

]

{ #category : #'change reporting' }
OffscreenWorldMorph >> invalidRect: damageRect [

	damageRecorder recordInvalidRect: (damageRect intersect: bounds).

]

{ #category : #testing }
OffscreenWorldMorph >> isOffscreenWorldMorph [

	^ true
]

{ #category : #initialization }
OffscreenWorldMorph >> on: aMorph [

	aMorph position: 0@0.
	self bounds: aMorph bounds.
	self addMorph: aMorph.

]

{ #category : #'change reporting' }
OffscreenWorldMorph >> redrawAll [

	damageRecorder reset.
	submorphs do: [:m | m changed].

]

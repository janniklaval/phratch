"
I am a panel to allow creating script outside phratch.


ExternalScriptsMorph new 
	width: 400; 
	height: 500; 
	openInWindowLabeled: 'New phratch script'.
"
Class {
	#name : #ExternalScriptsMorph,
	#superclass : #PhratchScriptsMorph,
	#instVars : [
		'receiver'
	],
	#category : #PhratchExternalProject
}

{ #category : #'as yet unclassified' }
ExternalScriptsMorph class >> example1 [

"
self example1
"

"PhratchScriptsMorph new width: 400; height: 500; openInWindowLabeled: 'New phratch script'."
| page x y maxX |
ExternalScriptsMorph new width: 400; height: 500; openInWindowLabeled: 'New phratch script'.

"c := (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special:
		in: ScriptablePhratchMorph) first. 
offForm := PhratchFrameMorph skinAt: (c arguments at: 3).		
b := ResizableToggleButton new offForm: offForm onForm: offForm overForm: offForm.

prov := { c arguments at: 1 . c arguments at: 2 . c method selector . c arguments at: 6},  (c arguments at: 4).

block := ScriptablePhratchMorph new blockFromSpec: prov color: Color darkGray .
block openInWindow.
"
page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

x := 13.		
y:= 10.
(ScriptablePhratchMorph new blocksFor: 'operators') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #=) | (blockOrSym = #~)
			ifFalse: [
				y := ScriptablePhratchMorph new createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: (PhratchCategory blockColorFor: 'operators')]].
	
	
	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
page openInWindowLabeled: 'Available operator blocks'.
]

{ #category : #accessing }
ExternalScriptsMorph >> initialize [
	receiver := ScriptablePhratchMorph new.
	super initialize
]

{ #category : #accessing }
ExternalScriptsMorph >> isExternalScriptsMorph [

	^ true
]

{ #category : #accessing }
ExternalScriptsMorph >> receiver [
	^ receiver
]

{ #category : #accessing }
ExternalScriptsMorph >> receiver: anObject [
	receiver := anObject
]

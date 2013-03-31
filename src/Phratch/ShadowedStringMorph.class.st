"
This morph actually just holds two StringMorphs in it:

- 1 for the regular text in front
- 1 darker one for the text behind it

The color of the 'shadow' morph is automatically set by darkening the color of the main text.
"
Class {
	#name : #ShadowedStringMorph,
	#superclass : #Morph,
	#instVars : [
		'shadowMorph',
		'mainMorph'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
ShadowedStringMorph class >> contents: aString color: aColor font: aFont kern: aNumber [

	^ self new
		contents: aString
		color: aColor
		font: aFont
		kern: aNumber.
]

{ #category : #accessing }
ShadowedStringMorph >> contents [

	^ mainMorph contents

]

{ #category : #accessing }
ShadowedStringMorph >> contents: aString [

	mainMorph contents: aString.
	shadowMorph contents: aString.
]

{ #category : #accessing }
ShadowedStringMorph >> contents: aString color: aColor font: aFont kern: aNumber [

	mainMorph := PhratchStringMorph new
		contents: aString;
		color: aColor;
		font: aFont;
		kern: aNumber.
	shadowMorph := PhratchStringMorph new
		contents: aString;
		color: (Color black mixed: 0.2 with: self color);
		font: aFont;
		kern: aNumber.
	self
		addMorphBack: (mainMorph position: self position);
		addMorphBack: (shadowMorph position: (self position + (2@1))).
	self extent: (mainMorph extent + (2@1)).

]

{ #category : #initialization }
ShadowedStringMorph >> drawOn: aCanvas [

	^ self

]

{ #category : #initialization }
ShadowedStringMorph >> initialize [

	super initialize.
	self color: (Color r: 0.419 g: 0.603 b: 0.788).

]

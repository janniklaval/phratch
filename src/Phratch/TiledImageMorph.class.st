Class {
	#name : #TiledImageMorph,
	#superclass : #Morph,
	#instVars : [
		'tileForm'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
TiledImageMorph >> drawOn: aCanvas [
	"Draw myself by painting my tile form repeatedly to cover my extent."

	| myBox clipC |
	"myBox has integer position and extent and has a potentially inset bottom"
	myBox := bounds origin truncated corner: bounds corner truncated.
	clipC := aCanvas copyClipRect: myBox.

	(myBox top to: myBox bottom by: tileForm height) do: [:y |
		(myBox left to: myBox right by: tileForm width) do: [:x |
			clipC paintImage: tileForm at: x@y]].


]

{ #category : #'as yet unclassified' }
TiledImageMorph >> initialize [

	super initialize.
	tileForm := ImageMorph defaultForm.

]

{ #category : #'as yet unclassified' }
TiledImageMorph >> tileForm [

	^ tileForm

]

{ #category : #'as yet unclassified' }
TiledImageMorph >> tileForm: aForm [

	tileForm := aForm.
	self extent: tileForm extent.


]

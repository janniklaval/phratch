"
I'm the base class for Annoucements sent by EditableTextMorph objects.

See Announcements framework HelpSystem book for help on Announcements. 
"
Class {
	#name : #EditableTextMorphAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'textMorph'
	],
	#category : #'Phratch-Compatibility'
}

{ #category : #'as yet unclassified' }
EditableTextMorphAnnouncement class >> on: aEditableTextMorph [ 
	| ann |
	ann := self new.
	ann textMorph: aEditableTextMorph.
	^ ann
]

{ #category : #accessing }
EditableTextMorphAnnouncement >> textMorph [
	^ textMorph
]

{ #category : #accessing }
EditableTextMorphAnnouncement >> textMorph: anObject [
	textMorph := anObject
]

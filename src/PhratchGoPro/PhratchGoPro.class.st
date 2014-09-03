Class {
	#name : #PhratchGoPro,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'gopro'
	],
	#category : #PhratchGoPro
}

{ #category : #'as yet unclassified' }
PhratchGoPro class >> compileBlock: num for: anItem filedUnder: aProtocol on: aClass [
	aClass compile: (
		self methodTemplate
			format: {
					"{1}" anItem withFirstCharacterDownshifted onlyLetters.
					'<phratchItem: ''',anItem,''' kind: #- category: ''gopro'' defaultValues: #() subCategory: #''', (aProtocol "subStrings: '-'")"second" asSymbol, ''' special: #()>'.
					
					"{2}" '^ gopro command: ', num asString})
			classified: aProtocol
			notifying: nil
]

{ #category : #'as yet unclassified' }
PhratchGoPro class >> compileBlocks [

	
	'Compiling blocks for Gopro'
		displayProgressFrom: 0
		to: GoPro  Command size
		during: [ :bar |
			| count |
			count := 1.
			GoPro Command do: [:item |
				self compileBlock: count for: ((item at: 5), ', ', (item at: 4)) filedUnder: 'generated-',(item at: 5) on: self.
			bar value: (count := count + 1). ]]
]

{ #category : #'as yet unclassified' }
PhratchGoPro class >> initialize [
	
	self compileBlocks
]

{ #category : #'as yet unclassified' }
PhratchGoPro class >> methodTemplate [
^ '{1}
	{2} 
	{3}'
]

{ #category : #connection }
PhratchGoPro >> connectTo: ip port: aPort password: aPass [
	<phratchItem: 'connect to $String$ port $Number$ password $String$' kind: #- category: 'gopro' defaultValues: #('10.5.5.9' 8080 'goprohero') subCategory: #a special: #()>
	gopro ipAddr: ip; portAddr: aPort; password: aPass.
]

{ #category : #accessing }
PhratchGoPro >> gopro [
	
	^ gopro
]

{ #category : #accessing }
PhratchGoPro >> gopro: anObject [
	
	gopro := anObject
]

{ #category : #initialization }
PhratchGoPro >> initialize [
	super initialize.
	gopro := GoPro new.
]

{ #category : #accessing }
PhratchGoPro >> ip [
	<phratchItem: 'ip' kind: #ReporterBlockMorph category: 'gopro' defaultValues: #() subCategory: #a special: #()>
	^ gopro ipAddr
]

{ #category : #accessing }
PhratchGoPro >> password [
	<phratchItem: 'password' kind: #ReporterBlockMorph category: 'gopro' defaultValues: #() subCategory: #a special: #()>
	^ gopro password
]

{ #category : #accessing }
PhratchGoPro >> port [
	<phratchItem: 'port' kind: #ReporterBlockMorph category: 'gopro' defaultValues: #() subCategory: #a special: #()>
	^ gopro portAddr
]

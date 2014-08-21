"
to make it work, you need to generate methods and blocks.
Just execute these lines:

MinecraftConstants compileInstanceGetters.
PhratchMinecraftMorph compileBlocks
"
Class {
	#name : #PhratchMinecraftMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'minecraftObj'
	],
	#category : #MinecraftPhratch
}

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> compileBlockFor: anItem filedUnder: aProtocol on: aClass [
	aClass compile: (
		self methodTemplate
			format: {
					"{1}" anItem withFirstCharacterDownshifted.
					'<phratchItem: ''',anItem withFirstCharacterDownshifted,''' kind: #- category: ''minecraft'' defaultValues: #() subCategory: #''', (aProtocol "subStrings: '-'")"second" asSymbol, ''' special: #()>'.
					
					"{2}" '^ minecraftObj ', anItem withFirstCharacterDownshifted})
			classified: aProtocol
			notifying: nil
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> compileBlocks [
	"Add instance methods to Minecraft that will return our values."

	self compileBlocks: self categoryPrefix:  'generated-'.

]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> compileBlocks: aClass categoryPrefix: aString [

	'Compiling blocks on ', aClass asString
		displayProgressFrom: 0
		to: MinecraftConstants minecraftConstantsCategories size
		during: [ :bar |
			| count |
			count := 0.
			MinecraftConstants minecraftConstantsCategories keysAndValuesDo: [:categoryName :items |
				items
					do: [ :item | self compileBlockFor: item filedUnder: aString, categoryName on: aClass ]
					displayingProgress: 'Compiling ', categoryName ].
				bar value: (count := count + 1). ]
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> initialize [
	"MinecraftConstants compileInstanceGetters.
	PhratchMinecraftMorph compileBlocks
	"
	MinecraftConstants compileInstanceGetters.
	self compileBlocks
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> methodTemplate [
^ '{1}
	{2}
	{3}
	'
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> closeConnection [
	<phratchItem: 'disconnect' kind: #- category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	minecraftObj connection close.
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> connectTo: ip [
	<phratchItem: 'connect to $String$' kind: #- category: 'minecraft' defaultValues: #('localhost') subCategory: #a special: #()>
	minecraftObj connection: (MinecraftConnection host: ip port: 4711)
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> connectTo: ip port: aPort [
	<phratchItem: 'connect to $String$ port $Number$' kind: #- category: 'minecraft' defaultValues: #('localhost' 4711) subCategory: #a special: #()>
	minecraftObj connection: (MinecraftConnection host: ip port: aPort)
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> initialize [
	super initialize.
	minecraftObj := Minecraft new.
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> isConnected [
	<phratchItem: 'is connected ?' kind: #BooleanWatcherBlockMorph category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	^ [minecraftObj connection isConnected] on: Error do: [false].
]

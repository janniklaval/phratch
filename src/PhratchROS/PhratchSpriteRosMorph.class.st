Class {
	#name : #PhratchSpriteRosMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'rosMaster'
	],
	#category : #PhratchROS
}

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> getParameterNamed: aString [

	<phratchItem: 'get parameter named $String$' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	^rosMaster getParam: '' named: aString.
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> getTopicType: aString [

	<phratchItem: 'get type of topic $String$' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	^rosMaster getTopicType: aString.
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> initialize [

	super initialize.
	rosMaster := PhaROSMaster localhost.
	self setMyName: 'Ros'.
	self initializeSkin.
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> initializeSkin [
	| botSkin botImage |
	botSkin := Form fromFileNamed: (FileSystem workingDirectory / 'ScratchSkin' / 'defaultSpriteCostume.png').

	botImage := ImageMedia new form: botSkin.
	botImage mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: botImage.
	self lookLike: botImage mediaName.
	self updateMediaCategory.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> nodes [

	<phratchItem: 'nodes' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	| list |
	self listNamed: 'ROS nodes' ifNone:[
		list:= self quietCreateListNamed: 'ROS nodes'.
		((rosMaster getSystemState: '') nodes) do:[:e |
			self append: e toList: 'ROS nodes'
		].
		list
	].
	^self listNamed: 'ROS nodes'
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> parameterNames [

	<phratchItem: 'parameter names' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	| list |
	self listNamed: 'ROS parameters' ifNone:[
		list:= self quietCreateListNamed: 'ROS parameters'.
		(rosMaster getParamNames: '') do:[:e |
			self append: e toList: 'ROS parameters'
		].
		list
	].
	^self listNamed: 'ROS parameters'
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> publishedTopics [

	<phratchItem: 'published topics' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	| list |
	self listNamed: 'ROS published topics' ifNone:[
		list:= self quietCreateListNamed: 'ROS published topics'.
		(rosMaster getPublishedTopics: '') do:[:e |
			self append: e toList: 'ROS published topics'
		].
		list
	].
	^self listNamed: 'ROS published topics'
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> publisherTopics [

	<phratchItem: 'publisher topics' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	| list |
	self listNamed: 'ROS publisher topics' ifNone:[
		list:= self quietCreateListNamed: 'ROS publisher topics'.
		(rosMaster getPublisherTopics: '') do:[:e |
			self append: e toList: 'ROS publisher topics'
		].
		list
	].
	^self listNamed: 'ROS publisher topics'
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> subscriberTopics [

	<phratchItem: 'subscriber topics' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	| list |
	self listNamed: 'ROS subscriber topics' ifNone:[
		list:= self quietCreateListNamed: 'ROS subscriber topics'.
		(rosMaster getSubscriberTopics: '') do:[:e |
			self append: e toList: 'ROS subscriber topics'
		].
		list
	].
	^self listNamed: 'ROS subscriber topics'
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> systemState [

	<phratchItem: 'system state' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	^rosMaster getSystemState:''.
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> topicTypes [

	<phratchItem: 'topic types' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	| list |
	self listNamed: 'ROS topic types' ifNone:[
		list:= self quietCreateListNamed: 'ROS topic types'.
		(rosMaster getTopicTypes: '') do:[:e |
			self append: e toList: 'ROS topic types'
		].
		list
	].
	^self listNamed: 'ROS topic types'.
]

{ #category : #'as yet unclassified' }
PhratchSpriteRosMorph >> uri [

	<phratchItem: 'uri' kind: #ReporterBlockMorph category: 'ros' defaultValues: #() subCategory: #a special: #()>
	^rosMaster getUri:''.
]

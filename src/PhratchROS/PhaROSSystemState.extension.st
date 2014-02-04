Extension { #name : #PhaROSSystemState }

{ #category : #'*PhratchROS' }
PhaROSSystemState >> nodes [

	|allNodes|
	allNodes:= Set new.
	topicPublishersDict values do:[:e |
		allNodes addAll: e.
	].
	topicSubscribersDict values do:[:e |
		allNodes addAll: e.
	].
	^ allNodes
]

Extension { #name : #Morph }

{ #category : #'*PhratchSound' }
Morph >> centerInOwner [

	owner ifNil: [^ self].
	self left: owner left + ((owner width - self width) // 2).

]

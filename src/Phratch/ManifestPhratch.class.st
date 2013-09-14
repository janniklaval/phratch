Class {
	#name : #ManifestPhratch,
	#superclass : #Object,
	#category : #Phratch
}

{ #category : #'meta data' }
ManifestPhratch class >> rejectClasses [
^ #()
]

{ #category : #'meta data' }
ManifestPhratch class >> rejectRules [
^ #()
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleClassNotReferencedRuleV1FalsePositive [
^ #(#(#(#RGClassDefinition #(#SetSizeTo)) #'2013-09-14T08:46:56.951000002+02:00') #(#(#RGClassDefinition #(#GetAttributeOf)) #'2013-09-14T08:46:56.951000007+02:00') #(#(#RGClassDefinition #(#PhratchCategoryCustom)) #'2013-09-14T08:46:56.951000008+02:00') #(#(#RGClassDefinition #(#Say)) #'2013-09-14T08:46:56.951+02:00') #(#(#RGClassDefinition #(#PhratchCategorySensing)) #'2013-09-14T08:46:56.951000004+02:00') #(#(#RGClassDefinition #(#PlaySound)) #'2013-09-14T08:46:56.947000003+02:00') #(#(#RGClassDefinition #(#DoAsk)) #'2013-09-14T08:46:56.947000002+02:00') #(#(#RGClassDefinition #(#PhratchCategoryNone)) #'2013-09-14T08:46:56.951000003+02:00') #(#(#RGClassDefinition #(#ThinkDurationElapsedFrom)) #'2013-09-14T08:46:56.953000006+02:00') #(#(#RGClassDefinition #(#InsertAtOfList)) #'2013-09-14T08:46:56.94+02:00') #(#(#RGClassDefinition #(#LookLike)) #'2013-09-14T08:46:56.947000001+02:00') #(#(#RGClassDefinition #(#Think)) #'2013-09-14T08:46:56.947000004+02:00') #(#(#RGClassDefinition #(#ContentsOfList)) #'2013-09-14T08:46:56.953000004+02:00') #(#(#RGClassDefinition #(#PhratchCategoryMotion)) #'2013-09-14T08:46:56.949000003+02:00') #(#(#RGClassDefinition #(#PhratchCategoryPen)) #'2013-09-14T08:46:56.949000007+02:00') #(#(#RGClassDefinition #(#AppendLettersOfToList)) #'2013-09-14T08:46:56.951000005+02:00') #(#(#RGClassDefinition #(#Broadcast)) #'2013-09-14T08:46:56.953000005+02:00') #(#(#RGClassDefinition #(#PhratchCategorySound)) #'2013-09-14T08:46:56.944000007+02:00') #(#(#RGClassDefinition #(#PhratchCategoryOperators)) #'2013-09-14T08:46:56.951000006+02:00') #(#(#RGClassDefinition #(#DoBroadcastAndWait)) #'2013-09-14T08:46:56.949+02:00') #(#(#RGClassDefinition #(#LetterOf)) #'2013-09-14T08:46:56.944000006+02:00') #(#(#RGClassDefinition #(#PhratchCategoryList)) #'2013-09-14T08:46:56.949000006+02:00') #(#(#RGClassDefinition #(#LineCountOfList)) #'2013-09-14T08:46:56.942+02:00') #(#(#RGClassDefinition #(#PhratchCategoryControl)) #'2013-09-14T08:46:56.953000002+02:00') #(#(#RGClassDefinition #(#ConcatenateWith)) #'2013-09-14T08:46:56.942000001+02:00') #(#(#RGClassDefinition #(#PhratchCategoryLooks)) #'2013-09-14T08:46:56.953+02:00') #(#(#RGClassDefinition #(#SayDurationElapsedFrom)) #'2013-09-14T08:46:56.953000003+02:00') #(#(#RGClassDefinition #(#PhratchCategoryFiles)) #'2013-09-14T08:46:56.944+02:00') #(#(#RGClassDefinition #(#ShowBackground)) #'2013-09-14T08:46:56.947+02:00') #(#(#RGClassDefinition #(#DoPlaySoundAndWait)) #'2013-09-14T08:46:56.944000005+02:00') #(#(#RGClassDefinition #(#PhratchCategoryVariables)) #'2013-09-14T08:46:56.944000003+02:00') #(#(#RGClassDefinition #(#GetLineOfList)) #'2013-09-14T08:46:56.949000005+02:00') #(#(#RGClassDefinition #(#ListContains)) #'2013-09-14T08:46:56.951000001+02:00') #(#(#RGClassDefinition #(#PhratchCategoryColors)) #'2013-09-14T08:46:56.944000004+02:00') #(#(#RGClassDefinition #(#SetLineOfListTo)) #'2013-09-14T08:46:56.944000001+02:00') #(#(#RGClassDefinition #(#PhratchCategoryOther)) #'2013-09-14T08:46:56.949000002+02:00') #(#(#RGClassDefinition #(#DeleteLineOfList)) #'2013-09-14T08:46:56.944000002+02:00') #(#(#RGClassDefinition #(#AppendToList)) #'2013-09-14T08:46:56.942000002+02:00') #(#(#RGClassDefinition #(#GotoXy)) #'2013-09-14T08:46:56.949000004+02:00') #(#(#RGClassDefinition #(#GlideSecsToXYElapsedFrom)) #'2013-09-14T08:46:56.953000001+02:00') #(#(#RGClassDefinition #(#StringLength)) #'2013-09-14T08:46:56.949000001+02:00') )
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleImplementedNotSentRuleV1FalsePositive [
^ #(#(#(#RGMethodDefinition #(#PhratchFrameMorph #saveImageForEndUserSilently #false)) #'2013-09-14T08:46:56.297000003+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doWithCamOpen #false)) #'2013-09-14T08:46:56.297000001+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doIf #false)) #'2013-09-14T08:46:56.297000002+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doPauseThread #false)) #'2013-09-14T08:46:56.297000004+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doWaitUntil #false)) #'2013-09-14T08:46:56.297+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doWhile #false)) #'2013-09-14T08:46:56.297000005+02:00') )
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleJustSendsSuperRuleV1FalsePositive [
^ #(#(#(#RGMethodDefinition #(#PhratchSpriteMorph #height #false)) #'2013-09-14T08:46:56.419000001+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #comeToFront #false)) #'2013-09-14T08:46:56.419000002+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #width #false)) #'2013-09-14T08:46:56.419+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #isVisible #false)) #'2013-09-14T08:46:56.419000004+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #nextCostume #false)) #'2013-09-14T08:46:56.419000005+02:00') #(#(#RGMethodDefinition #(#ScriptablePhratchMorph #= #false)) #'2013-09-14T08:46:56.419000003+02:00') )
]

Extension { #name : #Object }

{ #category : #'*Phratch-Extensions' }
Object >> asArgString [
	^ self asString
]

{ #category : #'*Phratch-Extensions' }
Object >> asNumberNoError [
	"This message is intended to be sent to strings, booleans, and numbers. This method is a backstop in case some other type of object receives this message."

	^ 0

]

{ #category : #'*Phratch-Extensions' }
Object >> inform: informationString withDetails: detailsString [
	"Put up a DialogBox to give the user an informational message and wait until they click the 'ok' button before proceeding."

	DialogBoxMorph inform: informationString withDetails: detailsString.
]

{ #category : #'*Phratch-Extensions' }
Object >> isArgMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isAttributeArgMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBlockDialog [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBlockLabelFragmentMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBoolean [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBooleanArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCArgSlotMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCReporterSlotMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCSlotMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isChoiceArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isColorArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isColorBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCommandBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCommandScriptBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCustomCommandBlockMorph [
	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCustomReporterBlockMorph [
	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isDialogBoxMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isExpressionArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isHandMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isHatBlockMorph [

	^ false

]

{ #category : #'*Phratch-Extensions' }
Object >> isIfElseBlockMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isImageFrameMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isLambdaBlockMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isLibraryItemMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isListContentsBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isMediaItemMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isMenuMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isMultiArgCommandBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isMultiArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isOSlotMorph [
	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isOffscreenWorldMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchBlockPaletteMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchCommentMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchFilePicker [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchFilePickerEntry [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchFrameMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchList [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchListMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchNoteSelectorKeyMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchPrompterMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchScriptsMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchSpriteMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchStageMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchTalkBubbleMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isProcedureHatBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isReporterBlockDropTargetMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isReporterBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isReporterScriptBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isResizableToggleButton [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isScriptablePhratchMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isScrollFrameMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isSetterBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isSpecialArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isSpriteArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isStringFieldMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isStringMorph [
	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isToggleButton [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isVariableBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isVariableDeclarationBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isVariableFrame [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isWatcherMorph [

	^ false
]

Extension { #name : #PhratchScriptEditorMorph }

{ #category : #'*PhratchSound' }
PhratchScriptEditorMorph >> createTabPane [

	| tabOnForm tabOffForm tabID tabLabel |

	"create tab pane"
	tabPaneMorph := PhratchTabPaneMorph new.
	tabPaneMorph
		borderWidth: 0;
		color: Color transparent;
		targetPane: self.

	tabOnForm := (PhratchFrameMorph skinAt: #tabOn).
	tabOffForm := (PhratchFrameMorph skinAt: #tabOff).

	"add the tabs"
	#(Scripts Costumes Sounds) do: [:spec |
		tabID := spec asString.
		tabLabel := tabID localized.
		tabPaneMorph
			createTab: tabID
			withLabel: tabLabel
			onForm: tabOnForm
			offForm: tabOffForm].

	"set current tab and add to frame"
	tabPaneMorph currentTab: 'Scripts'.
	self addMorph: tabPaneMorph.

]

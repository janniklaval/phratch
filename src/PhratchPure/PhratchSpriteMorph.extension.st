Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchPure' }
PhratchSpriteMorph class >> blockSpecs [

	| blocks |
	blocks := #(
		'control'
			('clone me'						-	cloneMe)
			('delete me if I am a clone'						-	deleteMe)
			('I am a clone?'					b	isClone)
			=
			('when %m created'			C	-)

		'motion'
			('move %n steps'				-	forward:)
			('turn %n degrees'				-	turnRight: 15)	"icon shows turn direction"
			('turn %n degrees'				-	turnLeft: 15)	"icon shows turn direction"
			-
			('point in direction %d'			-	heading: 90)
			('point towards %m'				-	pointTowards:)
			-
			('go to x:%n y:%n'				-	gotoX:y: 0 0)
			('go to %m'						-	gotoSpriteOrMouse:)
			('glide %n secs to x:%n y:%n'	t	glideSecs:toX:y:elapsed:from: 1 50 50)
			-
			('change x by %n'				-	changeXposBy: 10)
			('set x to %n'					-	xpos: 0)
			('change y by %n'				-	changeYposBy: 10)
			('set y to %n'					-	ypos: 0)
			-
			('if on edge, bounce'			-	bounceOffEdge)
			-
			('x position'						r	xpos)
			('y position'						r	ypos)
			('direction'						r	heading)
			=
			('make draggable'				-	makeDrag)
			('make undraggable'			-	makeNoDrag)
			('draggable?'					b	isDraggable)
		'pen'
			('pen color'						r	penColor)
			('pen hue'						r	penHue)
			('pen shade'						r	penShade)
			('pen size'						r	penSize)
			=
			('clear'							-	clearPenTrails)
			-
			('pen down'						-	putPenDown)
			('pen up'						-	putPenUp)
			-
			('set pen color to %c'			-	penColor:)
			('change pen color by %n'		-	changePenHueBy:)
			('set pen color to %n'			-	setPenHueTo: 0)
			-
			('change pen shade by %n'		-	changePenShadeBy:)
			('set pen shade to %n'			-	setPenShadeTo: 50)
			-
			('change pen size by %n'		-	changePenSizeBy: 1)
			('set pen size to %n'				-	penSize: 1)
			-
			('stamp'							-	stampCostume)
	).

	blocks := blocks, #(
		'looks'
			('switch to costume %l'			-	lookLike:)
			('next costume'					-	nextCostume)
			('costume #'						r	costumeIndex)
			-
			('replace costume %n with %8'	-	replaceCostume:with: 1)
			('add %8 to costumes'	-	addCostumeTyped:)
			('delete costume %n'		-	deleteCostumeAt: 1)
			=
			('say %s for %n secs'			t	say:duration:elapsed:from: 'Hello!' 2)
			('say %s'						-	say: 'Hello!')
			('think %s for %n secs'			t	think:duration:elapsed:from: 'Hmm...' 2)
			('think %s'						-	think: 'Hmm...')
			-
			('change %g effect by %n'		-	changeGraphicEffect:by: 'color' 25)
			('set %g effect to %n'			-	setGraphicEffect:to: 'color' 0)
			('clear graphic effects'			-	filterReset)
			('%g effect'				r	graphicEffectNamed: 'color')
			-
			('change size by %n'			-	changeSizeBy:)
			('set size to %n%'				-	setSizeTo: 100)
			('size'							r	scale)
			-
			('change hStretch by %n'	-	changeStretchBy:)
			('set hStretch to %n %'		-	setStretchTo: 100)
			('hStretch'						r	hScale)
			('change vStretch by %n'	-	changeVStretchBy:)
			('set vStretch to %n %'		-	setVStretchTo: 100)
			('vStretch'						r	vScale)
			=
			('show'							-	show)
			('hide'							-	hide)
			('visible?'						b	isVisible)
			-
			('go to front'					-	comeToFront)
			('go back %n layers'			-	goBackByLayers: 1)
			=
			"('do with camera open'			c	doWithCamOpen)"
			('camera is open?'				b	cameraIsOpen)
			('close camera'				-	closeDefinitivelyCamera)
		'sensing'
			('sprite name'					r	objName)
			('set sprite name to %s'	-	setMyName:)
			=
			('touching %m?' 				b	touching:)
			('touching color %C?' 			b	touchingColor:)
			('color %C is touching %C?'		b	color:sees:)
			-
			('ask %s and wait'				s	doAsk 'What''s your name?')
			('ask %s in dialog'			-	showAskDialogWithText: 'What''s your name?')
			('answer'						r	answer)
			-
			('show dialog %s with text %s'	-	showInformDialog:withText: 'info' '')
			=
			('mouse x'						r	mouseX)
			('mouse y'						r	mouseY)
			('mouse down?'					b	mousePressed)
			('key %k pressed?'				b	keyPressed: 'space')
			('_key pressed'					r	keyPressed)
			-
			('distance to %m'				r	distanceTo:)
			-
			('reset timer'					-	timerReset)
			('timer'							r	timer)
			-
			('%a of %m'						r	getAttribute:of:)
			('get %a of %m'					r	attribute:of:)
			-
			('loudness'						r	soundLevel)
			('loud?'							b	isLoud)
			~
			('%H sensor value'				r	sensor: 'slider')
			('sensor %h?'					b	sensorPressed: 'button pressed')
			=
			('object %m'						r	getObject:)
			('attribute %a'						r	get:)
		'pure'
			('move %n cm'				-	forward:)
			('turn %n degrees'				-	turnRight: 15)	"icon shows turn direction"
			('turn %n degrees'				-	turnLeft: 15)	"icon shows turn direction"
			-
			('point in direction %d'			-	heading: 90)
			('point towards %m'				-	pointTowards:)
			-
			('go to x:%n y:%n'				-	gotoX:y: 0 0)
			('go to %m'						-	gotoSpriteOrMouse:)
			-
			('change x by %n'				-	changeXposBy: 10)
			('set x to %n'					-	xpos: 0)
			('change y by %n'				-	changeYposBy: 10)
			('set y to %n'					-	ypos: 0)
			-
			('x position'						r	xpos)
			('y position'						r	ypos)
			('direction'						r	heading)
		).

	^ blocks, super blockSpecs

]

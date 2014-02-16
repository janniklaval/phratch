"
This class supports peer-to-peer collaboration between Scratch instances or between Scratch and other applications that want to interact with Scratch.

Scratch 1.3 includes an experimental extension feature that supports interaction between Scratch and other programs.

Three kinds of interaction are supported:

  a. sharing broadcasts (in both directions)
  b. virtual sensors
  c. Scratch's global variables are made visible

Note that peers can read, but not change, each other's global variables.

Non-Scratch applications can use these mechanisms to control Scratch projects by sending broadcasts and virtual sensors available to Scratch. For example, a music sequencer might send Scratch broadcasts to synchronize animations to music. Or, Scratch can be used to control another application or (through some intermediary program) external hardware devices.

Topology

The network topology is a star, with one Scratch acting as the session host. Clients connect to this host. In addition to processing incoming messages from clients, the host forwards a message from one client to all other clients. The advantage of the star topology is that only the host must have a public IP address and be able to accept incoming TCP/IP connections; the clients may be bethind firewalls that do Network Address Translation (NAT) or disallow incoming connections. The disadvantages of the star toplogy are (a) messages must be forwarded by the host, increasing latency and (b) the host cannot leave the session. However, the star topology is eaiser for distributed users to set up and understand.

A common use of this mechanism is to provide additional sensors to Scratch or allow Scratch to control an external program. In that case, latency is typically very low.

Protocol

The experimental extension feature is enabled using the right-button menu on one of the two sensor blocks. When remote sensors are enabled, Scratch listens for connections on port 42001. 

Once a connection is established, messages are sent in both directions over the socket connection.

Each message consists of a four-byte size, most-significant byte first, followed by the message itself:

	<size: 4 bytes><msg: size bytes>

The four-byte size field is not counted as part of the message size. Thus, the empty message is four zero bytes.

The message up to the first whitespace character (any byte <= 32 is considered whitespace) is interpreted to as a case-insensitive command that is used to decide what to do with the rest of the message. Messages may eventually be used to transmit sprites or media, so large amounts of binary binary data in arbitrary formats may follow the initial command string.

The most common messages are human-readable strings made up of the following elements:

  - unquoted words with no embedded whitespace (cat, dog, mouse)
  - quoted strings (""three word string"", ""embedded """"quotation marks"""" are doubled"")
  - signed decimal numbers (1, -1, 3.14, -1.2, .1, -.2)
  - booleans (true or false)

Common Commands

The command set will get extended over time, so clients should just skip any commands that they do not understand. Here are the two most useful ones:

	broadcast <string>
	sensor-update [<var-name> <new-value>]

A sensor update command is followed by zero or more (variable name, value) pairs. Variable names are strings. Values are either numbers or strings.

Scratch outputs these commands when broadcasts or global variable changes occur. Scratch also responds to these commands. Broadcast commands sent to Scratch cause a broadcast to occur. Sensor-update commands update the values of virtual sensors available in the sensor block drop-down menu.

"
Class {
	#name : #PhratchCustomBlockParser,
	#superclass : #Object,
	#instVars : [
		'in'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'private-command parsing' }
PhratchCustomBlockParser >> parse: aString [

	| out token |
	in := ReadStream on: aString asString.
	out := OrderedCollection new.
	[in atEnd] whileFalse: [
		token := self readNext.
		token ifNotNil: [out addLast: token]].
	^ out asArray

]

{ #category : #'private-command parsing' }
PhratchCustomBlockParser >> readNext [
	"Read the next command line token from 'in' or nil if there are not more tokens. A token is a quoted string, a number, a boolean, or an unquoted string with no embedded whitespace. Strings that start with a digit or minus sign must be quoted to avoid being treated as an integer."

	| ch s |
	"skip white space"
	[in atEnd not and: [in peek asciiValue <= 32]]
		whileTrue: [in next].
	in atEnd ifTrue: [^ nil].

	ch := in peek.
	ch = $" ifTrue: [^ self readQuotedString].
	(({$- . $.} includes: ch) or:[ ch isDigit]) ifTrue: [^ self readNumber].

	"unquoted string or boolean"
	s := self readString.
	'true' = s ifTrue: [^ true].
	'false' = s ifTrue: [^ false].
	^ s

]

{ #category : #'private-command parsing' }
PhratchCustomBlockParser >> readNumber [

	| orig s sign |
	s := self readString.
	orig := s.
	sign := 1.
	s first = $- ifTrue: [s := s copyFrom: 2 to: s size. sign := -1].

	s size < 1 ifTrue: [^ orig]. "needed, -jens"

	s first = $. ifTrue: [s := '0', s].  "add leading zero"
	^ s asNumber * sign

]

{ #category : #'private-command parsing' }
PhratchCustomBlockParser >> readQuotedString [

	| result ch |
	result := WriteStream on: String new.
	in next.  "skip opening quote"
	[in atEnd] whileFalse: [
		ch := in next.
		ch = $" ifTrue: [
			in peek = $"
				ifTrue: [in skip: 1]
				ifFalse: [^ result contents]].
		result nextPut: ch].

	^ result contents

]

{ #category : #'private-command parsing' }
PhratchCustomBlockParser >> readString [

	| result ch |
	result := WriteStream on: String new.
	[in atEnd] whileFalse: [
		ch := in peek.
		ch asciiValue <= 32 ifTrue: [^ result contents].
		result nextPut: in next].

	^ result contents

]

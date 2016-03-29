Class {
	#name : #PhratchEducationalBureau,
	#superclass : #PhratchCategory,
	#classVars : [
		'CharacterTable'
	],
	#category : #PhratchEducationalBureau
}

{ #category : #'as yet unclassified' }
PhratchEducationalBureau class >> CharacterTable [

	^CharacterTable
]

{ #category : #'as yet unclassified' }
PhratchEducationalBureau class >> characterAt: aNumber [

	^ Unicode value: (self CharacterTable at: aNumber ifAbsent: [^'']).
]

{ #category : #'as yet unclassified' }
PhratchEducationalBureau class >> color [ 
    ^(Color r: 0.3 g: 0.3 b: 0.9)
]

{ #category : #'as yet unclassified' }
PhratchEducationalBureau class >> initialize [
"self initialize"
super initialize.
CharacterTable :=
{0 -> 16r20.
1 -> 16r61.
2 -> 16r62.
3 -> 16r63.
4 -> 16r64.
5 -> 16r65.
6 -> 16r66.
7 -> 16r67.
8 -> 16r68.
9 -> 16r69.
10 -> 16r6A.
11 -> 16r6B.
12 -> 16r6C.
13 -> 16r6D.
14 -> 16r6E.
15 -> 16r6F.
16 -> 16r70.
17 -> 16r71.
18 -> 16r72.
19 -> 16r73.
20 -> 16r74.
21 -> 16r75.
22 -> 16r76.
23 -> 16r77.
24 -> 16r78.
25 -> 16r79.
26 -> 16r7A.
27 -> 16r41.
28 -> 16r42.
29 -> 16r43.
30 -> 16r44.
31 -> 16r45.
32 -> 16r46.
33 -> 16r47.
34 -> 16r48.
35 -> 16r49.
36 -> 16r4A.
37 -> 16r4B.
38 -> 16r4C.
39 -> 16r4D.
40 -> 16r4E.
41 -> 16r4F.
42 -> 16r50.
43 -> 16r51.
44 -> 16r52.
45 -> 16r53.
46 -> 16r54.
47 -> 16r55.
48 -> 16r56.
49 -> 16r57.
50 -> 16r58.
51 -> 16r59.
52 -> 16r5A.
53 -> 16rE1.
54 -> 16rE0.
55 -> 16rE2.
56 -> 16rE3.
57 -> 16rC1.
58 -> 16rC0.
59 -> 16rC2.
60 -> 16rC3.
61 -> 16rE9.
62 -> 16rEA.
63 -> 16rC9.
64 -> 16rCA.
65 -> 16rED.
66 -> 16rCD.
67 -> 16rF3.
68 -> 16rF4.
69 -> 16rF5.
70 -> 16rD3.
71 -> 16rD4.
72 -> 16rD5.
73 -> 16rFA.
74 -> 16rDA.
75 -> 16rFC.
76 -> 16rDC.
77 -> 16r30.
78 -> 16r31.
79 -> 16r32.
80 -> 16r33.
81 -> 16r34.
82 -> 16r35.
83 -> 16r36.
84 -> 16r37.
85 -> 16r38.
86 -> 16r39.
87 -> 16r21.
88 -> 16r3F.
89 -> 16r2D.
90 -> 16r5F.
91 -> 16r2B.
92 -> 16r3D.
93 -> 16r22.
94 -> 16r2C.
95 -> 16r2E.
96 -> 16r3B.
97 -> 16r3A.
98 -> 16r40.
99 -> 16r23.
100 -> 16r24.
101 -> 16r25.
102 -> 16r26.
103 -> 16r2A.
104 -> 16r28.
105 -> 16r29.
106 -> 16r2F.
107 -> 16r5C.
108 -> 16r7C.
109 -> 16r7B.
110 -> 16r7D.
111 -> 16r5B.
112 -> 16r5D.
113 -> 16rAA.
114 -> 16rBA.
116 -> 16r3C.
117 -> 16r3E.
118 -> 16rF2.
119 -> 16rF3.
120 -> 16r2665.
121 -> 16r2663.
122 -> 16r2666.
123 -> 16r2660.
124 -> 16r26AB.
125 -> 16rC7.
126 -> 16rE7} asDictionary
]

{ #category : #'as yet unclassified' }
PhratchEducationalBureau class >> label [ 
    ^'educational bureau'
]

{ #category : #'as yet unclassified' }
PhratchEducationalBureau class >> order [ 
    ^5
]

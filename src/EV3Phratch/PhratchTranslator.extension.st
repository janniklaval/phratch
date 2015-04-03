Extension { #name : #PhratchTranslator }

{ #category : #'*EV3Phratch' }
PhratchTranslator class >> jetStormLanguageFr [

	"allPragmas := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: PhratchSpriteEv3Morph.

allPragmas select:[:aP | (aP arguments at: 3) = 'ev3-exp'] thenCollect:[:aP | aP arguments at: 1]."
	<phratchTranslation: 'fr'>
	^ { 'is connected ?' -> 'connecté ?'.
	'get firmware number' -> 'numéro de firmware'.
'disconnect' -> 'déconnecter'.
'list files from $String$ length $Number$' -> 'liste des fichier dans $String$ taille de liste $Number$'.
'connect to $String$' -> 'connecter à $String$'.
'start program $String$' -> 'démarrer le programme $String$'.
'sync motors left $ev3Motors$ right $ev3Motors$' -> 'Synchroniser les moteurs gauche $ev3Motors$ et droite $ev3Motors$'.
'clean all existing connections' -> 'supprimer toutes les connections'.
'stop current program' -> 'stop le programme en cours'.
'clear changes of $ev3Sensors$' -> 'réinitialiser les changements de $ev3Sensors$'.
'changes of $ev3Sensors$' -> 'changements de $ev3Sensors$'.
'type of $ev3Sensors$' -> 'type de $ev3Sensors$'.
'$ev3Sensors$ read string' -> 'lire et afficher $ev3Sensors$'.
'$ev3Sensors$ get figures' -> 'figures de $ev3Sensors$'.
'bumps of $ev3Sensors$' -> 'numbre d''appui de $ev3Sensors$'.
'$ev3Sensors$ read' -> 'lire $ev3Sensors$'.
'$ev3Sensors$ read Si' -> 'lire la valeur Si de $ev3Sensors$'.
'$ev3Sensors$ set mode $sensorMode$' -> '$ev3Sensors$ définir le mode $sensorMode$'.
'clear $ev3Sensors$' -> 'réinitialiser $ev3Sensors$'.
'mode type of $ev3Sensors$' -> 'mode de $ev3Sensors$'.
'symbol of $ev3Sensors$' -> 'symbole de $ev3Sensors$'.
'mode name of $ev3Sensors$' -> 'nom du mode de $ev3Sensors$'.
'$ev3Sensors$ ready Raw' -> 'donnée prête pour $ev3Sensors$'.
'$ev3Sensors$ ready Pct ' -> 'Pourcentage prêt pour $ev3Sensors$'.
'get min max of $ev3Sensors$' -> 'valeurs minimum et maximum de $ev3Sensors$'.
'name of $ev3Sensors$' -> 'nom de $ev3Sensors$'.
'get raw of $ev3Sensors$' -> 'valeur brute de $ev3Sensors$'.
'$ev3Sensors$ ready Si' -> 'valeur de $ev3Sensors$ '."SI unit is international system"
'$ev3Motors$ start' -> 'démarrer $ev3Motors$'.
'turn right forward speed: $Number$ percent: $Number$ degrees: $Number$' -> 'tourner à droite en avançant vitesse: $Number$ pourcentage: $Number$ degrés: $Number$'.
'$ev3Motors$ is reversed ?' -> '$ev3Motors$ est inversé ?'.
'turn left forward speed: $Number$ percent: $Number$ degrees: $Number$' -> 'tourner à gauche en avançant vitesse: $Number$ pourcentage: $Number$ degrés: $Number$'.
'$ev3Motors$ set power $Number$' -> '$ev3Motors$ puissance $Number$'.
'$ev3Motors$ set speed $Number$' -> '$ev3Motors$ vitesse $Number$'.
'move speed: $Number$ step: $Number$' -> 'avancer à la vitesse $Number$ nombre de pas $Number$'.
'$ev3Motors$ speed' -> 'vitesse de $ev3Motors$'.
'start at speed $Number$ turn ratio $Number$' -> 'démarrer à la vitesse $Number$ en tournant avec un ratio de $Number$'.
'turn right reverse speed: $Number$ percent: $Number$ degrees: $Number$' -> 'tourner à droite en reculant vitesse: $Number$ pourcentage: $Number$ degrés: $Number$'.
'handle spin right speed: $Number$ degrees: $Number$' -> 'tourner sur place à droite vitesse $Number$ degrés $Number$'.
'move $ev3Motors$ speed $Number$ degrees $Number$ brake $Boolean$' -> 'avancer $ev3Motors$ vitesse $Number$ degrés $Number$ frein $Boolean$'.
'move $ev3Motors$ speed $Number$ time $Number$ brake $Boolean$' -> 'avancer $ev3Motors$ vitesse $Number$ temps $Number$ frein $Boolean$'.
'start $ev3Motors$ at speed: $Number$' -> 'démarrer $ev3Motors$ à la vitesse de $Number$'.
'reverse $ev3Motors$' -> 'inverse $ev3Motors$'.
'move $ev3Motors$ power $Number$ time $Number$ brake $Boolean$' -> 'avancer $ev3Motors$ puissance $Number$ temps $Number$ frein $Boolean$'.
'$ev3Motors$ set polarity $Boolean$' -> '$ev3Motors$ polarité $Boolean$'.
'turn left reverse speed: $Number$ percent: $Number$ degrees: $Number$' -> 'tourner à gauche en reculant vitesse: $Number$ pourcentage: $Number$ degrés: $Number$'.
'handle spin left speed: $Number$ degrees: $Number$' -> 'tourner sur place à gauche vitesse $Number$ degrés $Number$'.
'move $ev3Motors$ power $Number$ step $Number$ brake: $Boolean$' -> 'avancer $ev3Motors$ puissance $Number$ nombre de pas $Number$ frein $Boolean$'.
'move speed $Number$ turn ratio $Number$ time $Number$ brake $Boolean$' -> 'avancer à la vitesse $Number$ tournant à $Number$ % temps $Number$ frein $Boolean$'.
'move $ev3Motors$ speed $Number$ steps $Number$ brake $Boolean$' -> 'avancer $ev3Motors$ vitesse $Number$ nombre de pas $Number$ frein $Boolean$'.
'$ev3Motors$ count' -> 'nombre de pas de $ev3Motors$'.
'start speed $Number$ turn ratio $Number$ degrees $Number$' -> 'démarrer à la vitesse de $Number$ tournant à $Number$ % degrés $Number$'.
'$ev3Motors$ is running ?' -> '$ev3Motors$ est en cours de fonctionnement'.
'$ev3Motors$ emergency stop' -> '$ev3Motors$ arrêt d''urgence'.
'move $ev3Motors$ speed $Number$ position $Number$ brake $Boolean$' -> 'avancer $ev3Motors$ vitesse $Number$ position $Number$ frein $Boolean$'.
'$ev3Motors$ clear count' -> 'réinitialiser le nombre de pas de $ev3Motors$'.
'$ev3Motors$ stop' -> 'arrêter $ev3Motors$'.
'draw line color $ev3ScreenColor$ x $Number$ y $Number$ to x $Number$ y $Number$' -> 'dessiner une ligne de couleur $ev3ScreenColor$ de x $Number$ y $Number$ à x $Number$ y $Number$'.

'draw fill window color $ev3ScreenColor$ from $Number$ size $Number$' -> 'remplir l''écran de la couleur $ev3ScreenColor$ à partir de $Number$ de taille $Number$'.
'draw vertical dotted line color $ev3ScreenColor$ at x $Number$ from y $Number$ to y $Number$ onPixels $Number$ offPixels $Number$' -> 'dessiner une ligne pointillée verticale de couleur $ev3ScreenColor$ à la position x $Number$ de y $Number$ à y $Number$ pixels noirs $Number$ pixels blancs $Number$'.
'play tone volume $Number$ frequency $Number$ duration $Number$' -> 'jouer un son volume $Number$ frequence $Number$ durée $Number$'.
'stop sound' -> 'arrêt du son'.
'select font type $ev3FontType$' -> 'type de police $ev3FontType$'.
'draw pixel color $ev3ScreenColor$ x $Number$ y $Number$' -> 'dessiner un pixel de couleur $ev3ScreenColor$ à x $Number$ y $Number$'.
'draw circle color $ev3ScreenColor$ x $Number$ y $Number$ radius $Number$ filled $Boolean$' -> 'dessiner un cercle de couleur $ev3ScreenColor$ à x $Number$ y $Number$ de rayon $Number$ plein $Boolean$'.
'draw inverse rectangle x $Number$ y $Number$ width $Number$ height $Number$' -> 'dessiner un rectangle de couleur inverse d''origine x $Number$ y $Number$ de largeur $Number$ de hauteur $Number$'.
'draw rectangle color $ev3ScreenColor$ x $Number$ y $Number$ width $Number$ height $Number$ filled $Boolean$' -> 'dessiner un rectangle de couleur $ev3ScreenColor$ d''origine x $Number$ y $Number$ de largeur $Number$ de hauteur $Number$ plein $Boolean$'.
'clear screen' -> 'vider l''écran'.
'enable top line' -> 'afficher la ligne supérieure'.
'draw text color $ev3ScreenColor$ x $Number$ y $Number$ text $String$' -> 'afficher le texte de couleur $ev3ScreenColor$ à x $Number$ y $Number$ texte $String$'.
'update screen' -> 'mettre à jour l''écran'.
'clear screen with top line $Boolean$' -> 'vider l''écran avec la ligne supérieure $Boolean$'.
'draw horizontal dotted line color $ev3ScreenColor$ at y $Number$ from x $Number$ to x $Number$ onPixels $Number$ offPixels $Number$' -> 'dessiner une ligne pointillée horizontale de couleur $ev3ScreenColor$ à la position x $Number$ de y $Number$ à y $Number$ pixels noirs $Number$ pixels blancs $Number$'.
'beep at volume $Number$ time $Number$' -> 'bip volume $Number$ durée $Number$'.
'set LED pattern to $ev3Leds$' -> 'allumer la DEL selon $ev3Leds$'.
'create directory $String$' -> 'créer un répertoire $String$'.
'play file $String$ volume $Number$' -> 'lire le son $String$ volume $Number$'.
'write in file $String$ contents $String$' -> 'ecrire dans le fichier $String$ le texte $String$'.
'draw image color $ev3ScreenColor$ x $Number$ y $Number$ path $String$' -> 'dessiner l''image de couleur $ev3ScreenColor$ x $Number$ y $Number$ chemin $String$'.
'list of opened file' -> 'liste des fichiers ouverts'.
'$ev3Buttons$ is pressed' -> '$ev3Buttons$ est appuyé ?'.
'read file $String$' -> 'lire le fichier $String$'.
'delete file $String$' -> 'supprimer le fichier $String$'.
'close file $String$' -> 'fermer le fichier $String$'
	}
]

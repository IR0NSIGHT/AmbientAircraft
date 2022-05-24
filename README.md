# AMBIENT_AA
A lightweight Arma 3 script, that will create immersive Anti-Aircraft fire, without endangering any aircraft <br>
__Developed and tested in multiplayer__.

The intention of this script is to create AA fire that feels very dangerous to the players, but is safe to fly through.<br>
The script was developed mainly around smaller helicopters but works well enough with most types of aircraft. It takes over control of AI-AA guns and has the AI fire large volleys in the general direction of any enemy aircraft within range. All aircraft are magically detected by the AI, the shots will be aimed at a dummy target offset to the aircraft. 

## Showcase video:
https://youtu.be/VccGZs8KudA

## How to use:
- Download the example mission. 
- Copypaste the IRN" folder and description.ext file into your own mission folder.
- place an AA gun with AI crew in Eden editor
- Editor: put ```[this] spawn IRN_fnc_aaAmbient``` into the AA guns init in Eden editor.
- Zeus: put ```[_this] spawn IRN_fnc_aaAmbient";``` into the AA guns command field in Zeus.
- AA Gun will run the script as long as its alive.

## Modes:
2 modes are available: 
- __ambient__ (0): All AA fire misses the aircraft, engange up to 2.5 km<br>```[this, 0] spawn IRN_fnc_aaAmbient;```
- __hybrid__ (1): Ambient fire up to 2.5km, direct+deadly fire for <900m<br>```[this, 1] spawn IRN_fnc_aaAmbient";```



## Tested:
- in Singleplayer
- in Multiplayer, 12+ Player mission
- with Huron Helicopter set to "slow speed"
- with Huron Helicopter landing right next to multiple AA guns (ZSU Tigris)
- with Littlebird set to "standard speed"

## Limitations:
- Hovering, very large or very slow aircraft might be very, very unlucky and get hit. 
- Only aircraft are targetted, any non-aircraft units are ignored (on purpose)
- AI will engage all enemy aircraft within a 2km radius. Engagement range might be lower for guns that can't operate that far (HMG on a tripod f.e.)

## TODO:
- Autodetect size of aircraft and adjust dummy-target offset accordingly
- every AA gun creates own dummy target
- allow a "turn off" button to return to defautl behaviour
- Allow detailed control over targetting behaviour

## Bugs:
- multiple aircraft at once can confuse the AA guns
- Praetorian CRAM manages to shoot down aircraft on accident sometimes

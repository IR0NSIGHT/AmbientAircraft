/*
	Author: IR0NSIGHT

	Description:
		Unit will use binoculars and watch the given direction, rotating left and right.
		
		Will appear as if the guy is searching for contacts in the direction. Unit will return to default behaviour on combat mode.
		Will continue searching once it is back to standard mode.

	Parameter(s):
		0:	object - Infantry Unit.
		1:	number - compass direction to watch, default: 0
		2:	number - range of compass direction to watch, default: 360.

	Returns:
		nothing

	Examples:
		[mySpotter, 90, 45] call IRN_fnc_aaSniper;
*/
params [
		["_unit", objNull,[objNull]],
		["_dir",0,[-1]],
		["_range",360,[-1]]
];
diag_log["spotter function called with:",_this];
if (isNull _unit) exitWith {
	["Unit is null."] call BIS_fnc_error;
};
_legalBehavs = ["AWARE","SAFE","CARELESS"];
_unit addWeapon "Binocular";
while {alive _unit} do {
	//timeout if in danger behaviour
	while {!(simulationEnabled _unit) || !((combatBehaviour _unit) in _legalBehavs)} do {
		sleep 1;
	};
	_newDir = _dir - _range + (random 2)*_range;
	//hint str ["dir",_dir,"range",_range,"new",_newDir];
	_vector = [ //direction compass -> 2d vector on grid
		sin(_newDir),
		cos(_newDir),
		0
	];
	_vector vectorMultiply 100;
	_vector = _vector vectorAdd getPosWorld _unit;
	if (currentWeapon _unit != "Binocular") then {
		_unit selectWeapon "Binocular";
	};
	_unit doWatch _vector;
	sleep (3 + random 3);
}

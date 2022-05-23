/**
*	AmbientAA function.
*	Call on AI controlled AA gun
*	params
*	_unit: AA gun
*	_mode:	0=ambient 1=hybrid (ambient on 1km+, deadly on <1km)
*
*/
params [
	["_unit", objNull, [objNull]],
	["_mode",0,[0]]
];
if (!isServer) exitWith {};
_legalModes = [0,1];
if !(_mode in _legalModes) exitWith {
	diag_log ["error ambientAA, unexpected mode ", _mode," should be ",_modes];
};
_isHybrid = (_mode == 1); //ambient for 1km+, deadly for <1km

//get (invisible dummy) target
_getTarget = {
	params ["_helo","_AA"];
	_varName = "irn_amb_aa_dummy";
	_t = _helo getVariable [_varName, objNull];
	if (isNull _t) then {
		_t = createVehicle ["CBA_B_InvisibleTargetAir",getPos _helo,  [], 0, "NONE"];
	//uncomment to have a helper object appear the the pseudotargets location
	//	_h = createVehicle ["Sign_Sphere200cm_F",getPos _helo,  [], 0, "NONE"];
	//	_h attachTo [_t,[0,0,0]];

		_helo setVariable [_varName,_t];
	};
	_last = _helo getVariable ["lastMoved",-1];
	if (_last + 2 < time) then {
		_radius = 100;
		_center = getPos _helo;
		//add velocity*forward
		_time =(_helo distance _AA)/980; //time the bullet needs to travel
		_lead = ((velocity  _helo) vectorMultiply (_time * (1+random 2)));
		_center = _center vectorAdd _lead;
		_offset = (vectorNormalized [-1 + random 1,-1 + random 1,-1 + random 1]);
		_offset = (_offset vectorMultiply _radius);
		_offset = _center vectorAdd _offset;
		_t setPos _offset;
		_helo setVariable ["lastMoved",time];
	};
	//return
	_t
};

//is this helo a legitimate target for unit?
_legalHelo = {
	params["_helo","_unit"];
	_out = alive _helo && ([side _helo, side _unit] call BIS_fnc_sideIsEnemy) && (getPosATL _helo) select 2 > 20;
	_out
};

_i = 0;
_veh = vehicle _unit;
_gunny = gunner _veh;
_gunny setSkill ["aimingAccuracy",1];

//run parallel loop that force fires whenever the gun is aimedAtTarget
[_gunny] spawn {
	params ["_gunny"];
	while {(alive _gunny)} do {
		sleep 0.2;
		_target = _gunny getVariable ["irn_amb_aa_target",objNull];
		_muzzle = ((vehicle _gunny) weaponsTurret [0]) select 0;
		if (!isNull _target) then {

			//fire burst while aimed
			vehicle _gunny setVehicleAmmo 1;
			_i = 0;
			_max = random 50 + 25;
			while {vehicle _gunny aimedAtTarget [_target] > 0.8 && _i < _max} do {
				_i = _i + 1;
				vehicle _gunny fireAtTarget [_target,_muzzle];
				sleep 0.01;
			};	
		} else {
			sleep 1;
		};
	};
};

_unit setVariable ["irn_amb_aa",true,true];
_range = 2500;
while {alive _unit} do {
	while {!simulationEnabled _unit} do {
		sleep 5;
	};
	sleep 1;
	(group _unit) setCombatMode "BLUE";

	_helos = ((getPos _unit) nearObjects ["Air",_range]) select {[_x,_unit] call _legalHelo};
	_helos = [_helos, [_unit], {_x distance _input0}, "ASCEND"] call BIS_fnc_sortBy;
	if (count _helos > 0) then {
		_helo = _helos select 0;//selectRandom _helos;


		//select firemode
		_fireMode = 0;
		if (_isHybrid && _helo distance _unit < (_range/3)) then {_fireMode = 1};

		_target = objNull;
		//choose target
		if (_fireMode == 1) then {
			//hybrid mode and helo is closer than 50% -> direct fire
			(group _unit) setCombatMode "RED";
			_target = _helo;
			_gunny doFire _target
		} else {
			//helo is farther than 50% OR not hybrid -> ambient fire
			_target = [_helo,_veh] call _getTarget; 		//get (pseudo) target
		};

		//set target as var, reveal and watch target.
		_gunny setVariable ["irn_amb_aa_target",_target];
		_gunny reveal [_target, 4];

		//_gunny doWatch getPos _target;
		_gunny doWatch getPos _target;
	} else {
		_gunny setVariable ["target",objNull];
		sleep 3;
	};
}
/**
*	AmbientAA function.
*	Call on AI controlled AA gun
*	params
*	_unit: AA gun
*	_mode:	0=ambient 1=hybrid (ambient on 1km+, deadly on <1km)
*
*/
params ["_unit","_mode"];
if (!isServer) exitWith {};
_legalModes = [0,1];
if (_mode in _legalModes) exitWith {
	diag_log ["error ambientAA, unexpected mode ", _mode," should be ",_modes];
};
_isHybrid = (_mode == 1); //ambient for 1km+, deadly for <1km

//get (invisible dummy) target
_getTarget = {
	params ["_helo","_AA"];
	_t = _helo getVariable ["dummy",objNull];
	if (isNull _t) then {
		_t = createVehicle ["CBA_B_InvisibleTargetAir",getPos _helo,  [], 0, "NONE"];

	//uncomment to have a helper object appear the the pseudotargets location
	//	_h = createVehicle ["Sign_Sphere200cm_F",getPos _helo,  [], 0, "NONE"];
	//	_h attachTo [_t,[0,0,0]];
		_helo setVariable ["dummy",_t];
	};
	_last = _helo getVariable ["lastMoved",-1];
	if (_last + 1 < time) then {
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
	alive _helo && ([side _helo, side _gunny] call BIS_fnc_sideIsEnemy) && (getPosATL _helo) select 2 > 20
}

_i = 0;
_veh = vehicle _unit;
_gunny = gunner _veh;
_gunny setSkill ["aimingAccuracy",1];

//run parallel loop that force fires whenever the gun is aimedAtTarget, uses getVar ["irn_amb_aa_target"] on gunny
[_gunny] spawn {
	params ["_gunny"];
	while {(alive _gunny)} do {
		sleep 0.2;
		_target = _gunny getVariable ["irn_amb_aa_target",objNull];
		if (!isNull _target) then {
			//fire burst while aimed
			vehicle _gunny setVehicleAmmo 1;
			_i = 0;
			_max = random 50;
			while {vehicle _gunny aimedAtTarget [_target] > 0.8} do {
				_i = _i + 1;
				vehicle _gunny fireAtTarget [_target];
				_run = (_i < _max);
				if (!_run) exitWith {
					sleep 5;
				};
				sleep 0.01;
			};	
		} else {
			sleep 3;
		};
	};
};

(group _unit) setCombatMode "BLUE";
_unit setVariable ["irn_amb_aa",true,true];
_range = 2000;
while {alive _unit} do {
	sleep 8;
	_helos = ((getPos _unit) nearObjects ["Air",_range]) select {[_x,_unit] call _legalHelo};
	if (count _helos > 0) then {
	
		//choose target or pseudo target
		_helo = selectRandom _helos;
		if (_isHybrid && _helo distance _unit < (_range/2)) then {
			//hybrid mode and helo is closer than 50% -> direct fire
			_target = _helo;
		} else {
			//helo is farther than 50% OR not hybrid -> ambient fire
			_target = [_helo,_veh] call _getTarget; 		//get (pseudo) target
		}
		
		//set target as var, reveal and watch target.
		_gunny setVariable ["irn_amb_aa_target",_target];
		_gunny reveal [_target, 4];
		_gunny doWatch getPos _target;
		
	} else {
		_gunny setVariable ["irn_amb_aa_target",objNull];
		sleep 3;
	};
}
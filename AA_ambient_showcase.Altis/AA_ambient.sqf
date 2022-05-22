params ["_unit"];
if (!isServer) exitWith {};

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

//get nearby targets
_i = 0;
_veh = vehicle _unit;
_gunny = gunner _veh;
_gunny setSkill ["aimingAccuracy",1];

//run parallel loop that force fires whenever the gun is aimedAtTarget
[_gunny] spawn {
	params ["_gunny"];
	while {(alive _gunny)} do {
		sleep 0.2;
		_target = _gunny getVariable ["target",objNull];
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
		};
	};
};

(group _unit) setCombatMode "BLUE";
while {alive _unit} do {
	sleep 1;
	_helos = ((getPos _unit) nearObjects ["Air",2000]) select {alive _x && (side _x getFriend side _gunny) < 0.6 && (getPosATL _x) select 2 > 20};
	if (count _helos > 0) then {
		//get (pseudo) target
		_helo = selectRandom _helos;
		_target = [_helo,_veh] call _getTarget;
		_gunny setVariable ["target",_target];

		//target the pseudo-target
		_gunny reveal [_target, 4];

		//_gunny doWatch getPos _target;
		_gunny doWatch getPos _target;
	} else {
		_gunny setVariable ["target",objNull];
		sleep 3;
	};
}
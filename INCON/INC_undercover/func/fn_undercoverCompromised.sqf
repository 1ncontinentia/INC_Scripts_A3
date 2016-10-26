/*
Changes the _percentage number of units of a given side to side enemy. Useful for simulating internal conflict.

Arguments

_undercoverUnit: The compromised unit
_regEnySide: Regular / conventional enemy side
_asymEnySide: Asymmetric enemy side (doesn't remember as long due to lack of information sharing between cells)


Conditions to be met first:

1. Unit has killed an enemy while spotted (killed eventhandler)

2. Unit has killed several enemies while not spotted but known about (killed eventhandler)

3. Unit has been spotted while armed and trespassing

4: Unit has been seen shooting (fired EH)


Order of events:

Unit is hostile for a cooldown period.

Once cooldown period is over, if there are still alerted units, unit becomes wanted.

Wanted level will only descrease when nobody knows about the unit anymore (alerted units = 0 and knowsabout = 0).


*/


params ["_undercoverUnit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

if (_undercoverUnit getVariable ["INC_compromisedLoopRunning",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

//Compromised loop
[_undercoverUnit,_regEnySide,_asymEnySide] spawn {

	params ["_undercoverUnit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

	_undercoverUnit setVariable ["INC_compromisedLoopRunning", true, true];

	// Publicize undercoverCompromised variable to true. This prevents other scripts from setting captive while unit is still compromised.
	_undercoverUnit setVariable ["INC_undercoverCompromised", true, true];

	// SetCaptive after suspicious act has been committed
	[_undercoverUnit, false] remoteExec ["setCaptive", _undercoverUnit];

	// Cooldown Timer to simulate how long it would take for word to get out
	_cooldownTimer = (30 + (random 240));
	sleep _cooldownTimer;


	//If there are still alerted units alive then wait until he's all sparkly and knowsabout _regEnySide has dropped off, otherwise just wait until he's sparkly
	if (_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) then {

		private ["_unitUniform","_unitGoggles","_unitHeadgear"];

		_unitUniform = uniform _undercoverUnit;
		_unitGoggles = goggles _undercoverUnit;
		_unitHeadgear = headgear _undercoverUnit;

		// Wait until nobody knows nuffing and the unit isn't being naughty
		waituntil {

			sleep 5;

			if (
				(uniform _undercoverUnit != _unitUniform) &&
				{(goggles _undercoverUnit != _unitGoggles) || {(headgear _undercoverUnit != _unitHeadgear)}}

			) then {

				if (

					(([_regEnySide,_undercoverUnit,150] call INCON_fnc_countAlerted) == 0) &&
					{(([_asymEnySide,_undercoverUnit,150] call INCON_fnc_countAlerted) == 0)}
					
				) then {

					_undercoverUnit setVariable ["INC_disguiseChanged",true];

				} else {

				_unitUniform = uniform _undercoverUnit;
				_unitGoggles = goggles _undercoverUnit;
				_unitHeadgear = headgear _undercoverUnit;

				};

			};


			sleep 3;

			if (_undercoverUnit getVariable ["INC_disguiseChanged",false]) exitWith {

				private ["_disguiseValue","_newDisguiseValue"];

				_disguiseValue = (_undercoverUnit getVariable ["INC_compromisedValue",1]);

				_newDisguiseValue = _disguiseValue + (random 1);

				_undercoverUnit setVariable ["INC_disguiseChanged",false,true];

				_undercoverUnit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

				// Publicize undercoverCompromised to false.
				_undercoverUnit setVariable ["INC_undercoverCompromised", false, true];

				// SetCaptive back to true.
				[_undercoverUnit, true] remoteExec ["setCaptive", _undercoverUnit];
			};

			sleep 2;

			(
				!(_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) &&
				{!(_undercoverUnit getVariable ["INC_armed",false])} &&
				{!(_undercoverUnit getVariable ["INC_trespassing",false])} &&
				{(1.8 > (_regEnySide knowsAbout _undercoverUnit))}
			);
		};

		// Publicize undercoverCompromised to false.
		_undercoverUnit setVariable ["INC_undercoverCompromised", false, true];

		// SetCaptive back to true.
		[_undercoverUnit, true] remoteExec ["setCaptive", _undercoverUnit];

	} else {

		// Wait until nobody knows nuffing and the unit isn't being naughty
		waituntil {

			sleep 5;

			(
				!(_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) &&
				{!(_undercoverUnit getVariable ["INC_armed",false])} &&
				{!(_undercoverUnit getVariable ["INC_trespassing",false])}
			);
		};

		// Publicize undercoverCompromised to false.
		_undercoverUnit setVariable ["INC_undercoverCompromised", false, true];


		// SetCaptive back to true.
		[_undercoverUnit, true] remoteExec ["setCaptive", _undercoverUnit];

	};

	//Allow the loop to run again
	_undercoverUnit setVariable ["INC_compromisedLoopRunning", false, true];

};

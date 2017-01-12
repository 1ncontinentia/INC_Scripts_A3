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

#include "..\UCR_setup.sqf"

if (_debug) then {hint "You've been compromised."};

if (_undercoverUnit getVariable ["INC_compromisedLoopRunning",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

//Compromised loop
[_undercoverUnit,_regEnySide,_asymEnySide,_debug] spawn {

	params ["_undercoverUnit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty],["_debug",false]];

	_undercoverUnit setVariable ["INC_compromisedLoopRunning", true, true];

	// Publicize undercoverCompromised variable to true. This prevents other scripts from setting captive while unit is still compromised.
	_undercoverUnit setVariable ["INC_undercoverCompromised", true, true];

	// SetCaptive after suspicious act has been committed
	[_undercoverUnit, false] remoteExec ["setCaptive", _undercoverUnit];

	// Cooldown Timer to simulate how long it would take for word to get out
	_cooldownTimer = (30 + (random 240));
	sleep _cooldownTimer;


	//If there are still alerted units alive...
	if (_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) then {

		private ["_unitUniform","_unitGoggles","_unitHeadgear","_compUniform","_compHeadGear"];

		if (_debug) then {hint "Your description has been transmitted to others."};

		_compUniform = (_undercoverUnit getVariable ["INC_compUniforms",[]]);
		_compUniform pushBackUnique (uniform _undercoverUnit);
		_undercoverUnit setVariable ["INC_compUniforms",_compUniform];

		_compHeadGear = (_undercoverUnit getVariable ["INC_compHeadGear",[]]);
		_compHeadGear pushBackUnique (goggles _undercoverUnit);
		_compHeadGear pushBackUnique (headgear _undercoverUnit);
		_undercoverUnit setVariable ["INC_compHeadGear",_compHeadGear];

		// Wait until nobody knows nuffing and the unit isn't being naughty (or has changed disguise)
		waituntil {

			_compUniform = (_undercoverUnit getVariable ["INC_compUniforms",[]]);
			_compHeadGear = (_undercoverUnit getVariable ["INC_compHeadGear",[]]);

			sleep 5;

			if (
				!(uniform _undercoverUnit in _compUniform) &&
				{!(goggles _undercoverUnit in _compHeadGear) || {!(headgear _undercoverUnit in _compHeadGear)}}

			) then {

				if (

					(([_regEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted) == 0) &&
					{(([_asymEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted) == 0)}

				) then {

					_undercoverUnit setVariable ["INC_disguiseChanged",true];

				} else {

					_compUniform pushBackUnique (uniform _undercoverUnit);
					_undercoverUnit setVariable ["INC_compUniforms",_compUniform];

					_compHeadGear pushBackUnique (goggles _undercoverUnit);
					_compHeadGear pushBackUnique (headgear _undercoverUnit);
					_undercoverUnit setVariable ["INC_compHeadGear",_compHeadGear];

				};

			};


			sleep 3;

			if (

				((_undercoverUnit getVariable ["INC_disguiseChanged",false]) && {(80 > (random 100))})

			) exitWith {

				private ["_disguiseValue","_newDisguiseValue"];

				if (_debug) then {hint "Disguise changed."};

				_disguiseValue = (_undercoverUnit getVariable ["INC_compromisedValue",1]);

				_newDisguiseValue = _disguiseValue + (random 1);

				_undercoverUnit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

				_undercoverUnit setVariable ["INC_disguiseChanged",false,true];

				true
			};

			sleep 1;

			(
				(!(_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) && {(1.8 > (_regEnySide knowsAbout _undercoverUnit))}) ||
				{!alive _undercoverUnit}
			);
		};

		// Publicize undercoverCompromised to false.
		_undercoverUnit setVariable ["INC_undercoverCompromised", false, true];

		if (_debug) then {hint "Disguise intact."};

		// Cooldown
		[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_undercoverUnit];

		private ["_disguiseValue","_newDisguiseValue"];

		_disguiseValue = (_undercoverUnit getVariable ["INC_compromisedValue",1]);

		_newDisguiseValue = _disguiseValue + (random 1.5);

		_undercoverUnit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

		_undercoverUnit setVariable ["INC_disguiseChanged",false,true];

	//Otherwise he is no longer compromised
	} else {

		// Publicize undercoverCompromised to false.
		_undercoverUnit setVariable ["INC_undercoverCompromised", false, true];

		if (_debug) then {hint "Disguise intact."};

		// Cooldown
		[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_undercoverUnit];

	};

	//Allow the loop to run again
	_undercoverUnit setVariable ["INC_compromisedLoopRunning", false, true];

};

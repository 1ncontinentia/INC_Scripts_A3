/*
Changes the _percentage number of units of a given side to side enemy. Useful for simulating internal conflict.

Arguments

_underCoverUnit: The compromised unit
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


params ["_underCoverUnit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

if (_underCoverUnit getVariable ["INC_compromisedLoopRunning",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

[_underCoverUnit,_regEnySide,_asymEnySide] spawn {

	params ["_underCoverUnit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

	_underCoverUnit setVariable ["INC_compromisedLoopRunning", true, true];

	// Publicize undercoverCompromised variable to true. This prevents other scripts from setting captive while unit is still compromised.
	_underCoverUnit setVariable ["INC_undercoverCompromised", true, true];

	// SetCaptive after suspicious act has been committed
	[_underCoverUnit, false] remoteExec ["setCaptive", _underCoverUnit];

	// Cooldown Timer to simulate how long it would take for word to get out
	_cooldownTimer = (30 + (random 180));
	sleep _cooldownTimer;


	//If there are still alerted units alive then wait until he's all sparkly and knowsabout _regEnySide has dropped off, otherwise just wait until he's sparkly
	if (_underCoverUnit getVariable ["INC_AnyKnowsSO",false]) then {

		// Wait until nobody knows nuffing and the unit isn't being naughty
		waituntil {
			sleep 11;
			(
				!(_underCoverUnit getVariable ["INC_AnyKnowsSO",false]) &&
				!(_underCoverUnit getVariable ["INC_armed",false]) &&
				!(_underCoverUnit getVariable ["INC_trespassing",false]) &&
				(1.8 > (_regEnySide knowsAbout _underCoverUnit))
			);
		};

		// Publicize undercoverCompromised to false.
		_underCoverUnit setVariable ["INC_undercoverCompromised", false, true];

		// SetCaptive back to true.
		[_underCoverUnit, true] remoteExec ["setCaptive", _underCoverUnit];

	} else {

		// Wait until nobody knows nuffing and the unit isn't being naughty
		waituntil {
			sleep 3;
			(
				!(_underCoverUnit getVariable ["INC_AnyKnowsSO",false]) &&
				!(_underCoverUnit getVariable ["INC_armed",false]) &&
				!(_underCoverUnit getVariable ["INC_trespassing",false])
			);
		};

		// Publicize undercoverCompromised to false.
		_underCoverUnit setVariable ["INC_undercoverCompromised", false, true];


		// SetCaptive back to true.
		[_underCoverUnit, true] remoteExec ["setCaptive", _underCoverUnit];

	};

	//Allow the loop to run again
	_underCoverUnit setVariable ["INC_compromisedLoopRunning", false, true];

};

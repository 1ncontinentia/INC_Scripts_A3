/*
Trespass Handler, checks whether any of the different types of trespass are being committed and sets trespass variable on.

Author: Incontinentia

Trespass types:
* Type0: player gets too close to unit of regular side
* Type1: player gets too close to unit of asymmetric side (further range due to knowing locals)
* Type2: player goes into prohibited area
* Type3: player gets too close to HVT
* Type4: player gets too close to super HVT


*/



params ["_undercoverUnit"];

#include "..\UCR_setup.sqf"

if (_undercoverUnit getVariable ["INC_trespassLoopRunning",false]) exitWith {};

_undercoverUnit setVariable ["INC_trespassType1",false,true];
_undercoverUnit setVariable ["INC_trespassType2",false,true];

[_undercoverUnit,_regEnySide,_asymEnySide] spawn {

	params ["_undercoverUnit","_regEnySide","_asymEnySide"];

	_undercoverUnit setVariable ["INC_trespassLoopRunning", true, true]; // Stops the script running twice on the same unit

	//[_undercoverUnit] remoteExecCall ["INCON_fnc_undercoverTrespassTriggers",0];

	[_undercoverUnit,_regEnySide,_asymEnySide] call INCON_fnc_undercoverTrespassRadiusLoop;

	[_undercoverUnit] call INCON_fnc_undercoverTrespassMarkerLoop;

	waitUntil {

		sleep 5;

		waitUntil {
			sleep 2;
			(
				(_undercoverUnit getVariable ["INC_trespassType1",false]) ||
				{_undercoverUnit getVariable ["INC_trespassType2",false]}
			); //Fires if any of the trespassing types are met.
		};

		_undercoverUnit setVariable ["INC_trespassing", true, true]; //Publicises trespassing variable on unit to true.

		waitUntil {
			sleep 2;
			!(
				(_undercoverUnit getVariable ["INC_trespassType1",false]) ||
				{_undercoverUnit getVariable ["INC_trespassType2",false]}
			); //Fires if all of the trespassing types are inactive.
		};

		_undercoverUnit setVariable ["INC_trespassing", false, true]; //Publicises trespassing variable on unit to false.

		(!(_undercoverUnit getVariable ["isUndercover",false]) || {!(alive _undercoverUnit)})
	};
};

_undercoverUnit setVariable ["INC_trespassLoopRunning", false, true];

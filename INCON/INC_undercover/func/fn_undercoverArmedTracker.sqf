/*
Armed tracker - detects whethere a player is wearing a BLUFOR military uniform or a military vest, or is armed.

Spawns a loop that checks if the unit is armed or if the unit is wearing a naughty uniform.


*/


params ["_underCoverUnit"];

#include "..\UCR_setup.sqf"

_safeVests append [""];

_safeUniforms append [""];

_safeVests append (["vests",_safeFactionVests] call INCON_fnc_getFactionGear);
_safeUniforms append (["uniforms",_safeFactionUniforms] call INCON_fnc_getFactionGear);


//Will only run locally on player's machine
//if (!local _underCoverUnit) exitWith {};

if (_underCoverUnit getVariable ["INC_armedLoopRunning",false]) exitWith {};

_underCoverUnit setVariable ["INC_armedLoopRunning", true, true]; // Stops the script running twice on the same unit

[_underCoverUnit,_safeUniforms,_safeVests] spawn {

	params ["_underCoverUnit","_safeUniforms","_safeVests"];

	sleep 5;

	[_underCoverUnit, true] remoteExec ["setCaptive", _underCoverUnit]; //Makes enemies not hostile to the unit
	_underCoverUnit setVariable ["isCaptive", true, true];

	waitUntil {

		_underCoverUnit setVariable ["INC_armed", false, true]; // Sets variable "INC_armed" as false.

		waitUntil {
			sleep 3;
			(!(uniform _underCoverUnit in _safeUniforms) || {!((vest _underCoverUnit in _safeVests) || {vest _underCoverUnit == ""})} || {!((currentWeapon _underCoverUnit == "") || {currentWeapon _underCoverUnit == "Throw"})} || {hmd _underCoverUnit != ""}); //Fires if unit gets out weapon or wears suspicious uniform.
		};

		_underCoverUnit setVariable ["INC_armed", true, true]; // Sets variable "INC_armed" as true.

		sleep 2;

		waitUntil {
			sleep 3;
			!(!(uniform _underCoverUnit in _safeUniforms) || {!((vest _underCoverUnit in _safeVests) || {vest _underCoverUnit == ""})} || {!((currentWeapon _underCoverUnit == "") || {currentWeapon _underCoverUnit == "Throw"})} || {hmd _underCoverUnit != ""}); //Fires if unit gets out weapon or wears suspicious uniform.
		};

		(!(_undercoverUnit getVariable ["isUndercover",false]) || {!(alive _undercoverUnit)})

	};

	_underCoverUnit setVariable ["INC_armedLoopRunning", false, true]; // Stops the script running twice on the same unit

};

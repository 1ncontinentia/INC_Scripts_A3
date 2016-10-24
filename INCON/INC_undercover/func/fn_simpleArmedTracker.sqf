/*
Armed tracker - replaces trigger with longer pause for performance and passes variable "armed" to undercoverHandler.

Spawns a loop that checks if the unit is armed or if the unit is wearing a naughty uniform.


*/



params ["_civ"];

#include "..\UCR_setup.sqf"

_safeVests append [""];

_safeUniforms append [""];

_safeVests append (["vests",_safeFactionVests] call INCON_fnc_getFactionGear);
_safeUniforms append (["uniforms",_safeFactionUniforms] call INCON_fnc_getFactionGear);


[_civ,_safeUniforms,_safeVests] spawn {

	params ["_civ","_safeUniforms","_safeVests"];

	if ((_civ getVariable ["INC_civArmedLoopRunning",false]) || {isDedicated} || {_civ == player}) exitWith {};

	_civ setVariable ["INC_civArmedLoopRunning", true, true]; // Stops the script running twice on the same unit

	[_civ, true] remoteExec ["setCaptive", _civ];

	waitUntil {

		sleep 5;

		waitUntil {
			sleep 5;
			(!(uniform _civ in _safeUniforms) || {!(vest _civ in _safeVests)} || {!((currentWeapon _civ == "") || {currentWeapon _civ == "Throw"})} || {hmd _civ != ""}); //Fires if unit gets out weapon or wears suspicious uniform.
		};

		[_civ, false] remoteExec ["setCaptive", _civ];

		waitUntil {
			sleep 5;
			!(!(uniform _civ in _safeUniforms) || {!(vest _civ in _safeVests)} || {!((currentWeapon _civ == "") || {currentWeapon _civ == "Throw"})} || {hmd _civ != ""}); //Fires if unit gets out weapon or wears suspicious uniform.
		};

		[_civ, true] remoteExec ["setCaptive", _civ];

		(!(_civ getVariable ["isUndercover",false]) || !(alive _civ))
	};

	_civ setVariable ["INC_civArmedLoopRunning", false, true]; // Stops the script running twice on the same unit
};

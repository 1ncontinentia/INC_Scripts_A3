/*
Armed tracker - detects whethere a player is wearing a BLUFOR military uniform or a military vest, or is armed.

Spawns a loop that checks if the unit is armed or if the unit is wearing a naughty uniform.


*/


params ["_underCoverUnit"];

#include "..\UCR_setup.sqf"

_safeVests append [""];

_safeUniforms append [""];

_safeBackpacks append [""];

_safeVests append (["vests",_safeFactionVests] call INCON_fnc_getFactionGear);
_safeUniforms append (["uniforms",_safeFactionUniforms] call INCON_fnc_getFactionGear);
_safeBackpacks append _civPackArray;

if (_underCoverUnit getVariable ["INC_armedLoopRunning",false]) exitWith {};

_underCoverUnit setVariable ["INC_armedLoopRunning", true, true]; // Stops the script running twice on the same unit

[_underCoverUnit,_safeUniforms,_safeVests,_safeBackpacks,_HMDallowed,_safeVehicleArray,_noOffRoad,_debug,_hints] spawn {

	params ["_underCoverUnit","_safeUniforms","_safeVests","_safeBackpacks","_HMDallowed","_safeVehicleArray","_noOffRoad","_debug","_hints"];

	sleep 5;

	[_underCoverUnit, true] remoteExec ["setCaptive", _underCoverUnit]; //Makes enemies not hostile to the unit

	waitUntil {

		_underCoverUnit setVariable ["INC_armed", false, true]; // Sets variable "INC_armed" as false.

		waitUntil {

			sleep 2;

			if (

				(isNull objectParent _undercoverUnit) &&
				{(!(uniform _underCoverUnit in _safeUniforms) || {!(vest _underCoverUnit in _safeVests)} || {!(backpack _underCoverUnit in _safeBackpacks)} || {!((currentWeapon _underCoverUnit == "") || {currentWeapon _underCoverUnit == "Throw"})} || {(hmd _underCoverUnit != "") && !(_HMDallowed)})}

			) exitWith {

				if ((_debug) || {_hints}) then {
					hint "You have a suspicious item on show."
				};

				true
			}; //Fires if unit gets out weapon or wears suspicious uniform.

			sleep 0.5;

			if (

				!(isNull objectParent _undercoverUnit) &&
				{(!((typeof vehicle _undercoverUnit) in _safeVehicleArray)) || {(_noOffRoad) && {((vehicle _undercoverUnit) isKindOf "Land")} && {((count (_undercoverUnit nearRoads 50)) == 0)}}} //Hostile vehicle or safe land-based vehicle offroad considered suspicious

			) exitWith {

				if ((_debug) || {_hints}) then {
					hint "You are in a suspicious vehicle."
				};

				true
			}; //Fires if unit gets out weapon or wears suspicious uniform while on foot.

			false
		};

		_underCoverUnit setVariable ["INC_armed", true, true]; // Sets variable "INC_armed" as true.

		sleep 2;

		waitUntil {
			sleep 2;
			if (
				(isNull objectParent _undercoverUnit) &&
				{!(!(uniform _underCoverUnit in _safeUniforms) || {!(vest _underCoverUnit in _safeVests)} || {!(backpack _underCoverUnit in _safeBackpacks)} || {!((currentWeapon _underCoverUnit == "") || {currentWeapon _underCoverUnit == "Throw"})} || {(hmd _underCoverUnit != "") && !(_HMDallowed)})}
			) exitWith {true}; //Fires if unit doesn't have suspicious items while on foot.

			sleep 0.5;

			if (
				!(isNull objectParent _undercoverUnit) &&
				{(((typeof vehicle _undercoverUnit) in _safeVehicleArray)) && {!(_noOffRoad) || {!((vehicle _undercoverUnit) isKindOf "Land") || {((count (_undercoverUnit nearRoads 50)) != 0)}}}}
			) exitWith {true}; //Fires if unit isn't in suspicious vehicle.

			false
		};

		(!(_undercoverUnit getVariable ["isUndercover",false]) || {!(alive _undercoverUnit)})

	};

	_underCoverUnit setVariable ["INC_armedLoopRunning", false, true]; // Stops the script running twice on the same unit

};

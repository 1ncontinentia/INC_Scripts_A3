/*
Armed tracker - detects whethere a player is wearing a BLUFOR military uniform or a military vest, or is armed.

Spawns a loop that checks if the unit is armed or if the unit is wearing a naughty uniform.


*/


params [["_unit",objNull],["_operation","armedLoop"]];

#include "..\UCR_setup.sqf"

_safeVests append [""];

_safeUniforms append [""];

_safeBackpacks append [""];

_safeVests append (["vests",_safeFactionVests] call INCON_fnc_getFactionGear);
_safeUniforms append (["uniforms",_safeFactionUniforms] call INCON_fnc_getFactionGear);
_safeBackpacks append _civPackArray;

switch (_operation) do {

    case "armedLoop": {

		[_unit,_safeUniforms,_safeVests,_safeBackpacks,_HMDallowed,_safeVehicleArray,_noOffRoad,_debug,_hints] spawn {

			params ["_unit","_safeUniforms","_safeVests","_safeBackpacks","_HMDallowed","_safeVehicleArray","_noOffRoad","_debug","_hints"];

			if ((_unit getVariable ["INC_armedLoopRunning",false]) || {(!local _unit)}) exitWith {};

			_unit setVariable ["INC_armedLoopRunning", true, true]; // Stops the script running twice on the same unit

			sleep 5;

			[_unit, true] remoteExec ["setCaptive", _unit]; //Makes enemies not hostile to the unit

			waitUntil {

				_unit setVariable ["INC_armed", false, true]; // Sets variable "INC_armed" as false.

				waitUntil {

					sleep 2;

					if (

						(isNull objectParent _unit) &&
						{(!(uniform _unit in _safeUniforms) || {!(vest _unit in _safeVests)} || {!(backpack _unit in _safeBackpacks)} || {!((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"})} || {(hmd _unit != "") && !(_HMDallowed)})}

					) exitWith {

						if ((_debug) || {_hints}) then {
							hint "You have a suspicious item on show."
						};

						true
					}; //Fires if unit gets out weapon or wears suspicious uniform.

					sleep 0.5;

					if (

						!(isNull objectParent _unit) &&
						{(!((typeof vehicle _unit) in _safeVehicleArray)) || {(_noOffRoad) && {((vehicle _unit) isKindOf "Land")} && {((count (_unit nearRoads 50)) == 0)}}} //Hostile vehicle or safe land-based vehicle offroad considered suspicious

					) exitWith {

						if ((_debug) || {_hints}) then {
							hint "You are in a suspicious vehicle."
						};

						true
					}; //Fires if unit is in naughty vehicle or is offroad

					false
				};

				_unit setVariable ["INC_armed", true]; // Sets variable "INC_armed" as true.

				sleep 2;

				waitUntil {
					sleep 2;
					if (
						(isNull objectParent _unit) &&
						{!(!(uniform _unit in _safeUniforms) || {!(vest _unit in _safeVests)} || {!(backpack _unit in _safeBackpacks)} || {!((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"})} || {(hmd _unit != "") && !(_HMDallowed)})}
					) exitWith {true}; //Fires if unit doesn't have suspicious items while on foot.

					sleep 0.5;

					if (
						!(isNull objectParent _unit) &&
						{(((typeof vehicle _unit) in _safeVehicleArray)) && {!(_noOffRoad) || {!((vehicle _unit) isKindOf "Land") || {((count (_unit nearRoads 50)) != 0)}}}}
					) exitWith {true}; //Fires if unit isn't in suspicious vehicle.

					false
				};

				(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)})

			};

			_unit setVariable ["INC_armedLoopRunning", false, true]; // Stops the script running twice on the same unit

		};

    };

	case "simpleArmedLoop": {

		private _trespassMarkers = (missionNamespace getVariable ["INC_trespassMarkers",[]]);

		[_unit,_safeUniforms,_safeVests,_safeBackpacks,_HMDallowed,_safeVehicleArray,_noOffRoad,_trespassMarkers] spawn {

			params ["_unit","_safeUniforms","_safeVests","_safeBackpacks","_HMDallowed","_safeVehicleArray","_noOffRoad","_trespassMarkers"];

			if ((_unit getVariable ["INC_simpleArmedLoopRunning",false]) || {(!local _unit)}) exitWith {};

			_unit setVariable ["INC_simpleArmedLoopRunning", true, true]; // Stops the script running twice on the same unit

			[_unit, true] remoteExec ["setCaptive", _unit];

			waitUntil {

				sleep 2;

				waitUntil {

					sleep 4;

					if (

						!(isNull objectParent _unit) &&
						{(!((typeof vehicle _unit) in _safeVehicleArray))  || {(_unit getVariable ["INC_trespassType2",false])} || {(_noOffRoad) && {((vehicle _unit) isKindOf "Land")} && {((count (_unit nearRoads 50)) == 0)}}} //Hostile vehicle or safe land-based vehicle offroad considered suspicious

					) exitWith {true}; //Fires if civ is doing naughty vehicular shizzle

					sleep 4;

					if (
						(isNull objectParent _unit) &&
						{!(uniform _unit in _safeUniforms) || {!(vest _unit in _safeVests)} || {!(backpack _unit in _safeBackpacks)} || {!((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"})} || {!(hmd _unit == "") && !(_HMDallowed)} || {(_unit getVariable ["INC_trespassType2",false])}}
					) exitWith {true}; //Fires if unit gets out weapon or wears suspicious uniform.

					false
				};

				[_unit, false] remoteExec ["setCaptive", _unit];

				waitUntil {

					sleep 4;

					if (

						!(isNull objectParent _unit) &&
						{!((!((typeof vehicle _unit) in _safeVehicleArray))  || {(_unit getVariable ["INC_trespassType2",false])} || {(_noOffRoad) && {((vehicle _unit) isKindOf "Land")} && {((count (_unit nearRoads 50)) == 0)}})} //Hostile vehicle or safe land-based vehicle offroad considered suspicious

					) exitWith {true}; //Fires if civ is doing naughty vehicular shizzle

					sleep 4;

					if (
						(isNull objectParent _unit) &&
						{!(!(uniform _unit in _safeUniforms) || {!(vest _unit in _safeVests)} || {!(backpack _unit in _safeBackpacks)} || {!((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"})} || {!(hmd _unit == "") && !(_HMDallowed)} || {(_unit getVariable ["INC_trespassType2",false])} || {(_unit getVariable ["INC_AnyKnowsSO",false])})}
					) exitWith {true}; //Fires if unit gets out weapon or wears suspicious uniform.

					false

				};

				[_unit, true] remoteExec ["setCaptive", _unit];

				(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {(isPlayer _unit)} || {(_unit getVariable ["INC_armedLoopRunning",false])})
			};

			_unit setVariable ["INC_simpleArmedLoopRunning", false, true]; // Stops the script running twice on the same unit
		};

		[_unit] spawn {

			params ["_unit"];

			_unit setVariable ["INC_simpleTrespassLoopRunning",true,true];

			private _trespassMarkers = (missionNamespace getVariable ["INC_trespassMarkers",[]]);

		    waitUntil {

		        sleep 10;

		        {
		            if (_unit inArea _x) exitWith {

		                private _activeMarker = _x;

		                _unit setVariable ["INC_trespassType2",true,true];

		                waitUntil {

		                    sleep 2;

		                    !(_unit inArea _activeMarker);
		                };

		                _unit setVariable ["INC_trespassType2",false,true];
		            };

		            false

		        } count _trespassMarkers;

				sleep 2;

		        (!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)})

		    };

		    _unit setVariable ["INC_simpleTrespassLoopRunning",false,true];
		};

	};

};

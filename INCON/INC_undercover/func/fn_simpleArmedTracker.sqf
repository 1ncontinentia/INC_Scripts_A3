/*
Armed tracker - replaces trigger with longer pause for performance and passes variable "armed" to undercoverHandler.

Spawns a loop that checks if the unit is armed or if the unit is wearing a naughty uniform.


*/



params ["_civ"];

if ((isDedicated) || {_civ getVariable ["INC_civTrespassLoopRunning",false]} || {(_civ getVariable ["INC_civArmedLoopRunning",false])} || {isPlayer _civ}) exitWith {};

#include "..\UCR_setup.sqf"

_safeVests append [""];

_safeUniforms append [""];

_safeBackpacks append [""];

_safeVests append (["vests",_safeFactionVests] call INCON_fnc_getFactionGear);
_safeUniforms append (["uniforms",_safeFactionUniforms] call INCON_fnc_getFactionGear);
_safeBackpacks append _civPackArray;

[_civ,_safeUniforms,_safeVests,_safeBackpacks,_HMDallowed,_safeVehicleArray,_noOffRoad] spawn {

	params ["_civ","_safeUniforms","_safeVests","_safeBackpacks","_HMDallowed","_safeVehicleArray","_noOffRoad"];

	_civ setVariable ["INC_civArmedLoopRunning", true, true]; // Stops the script running twice on the same unit

	[_civ, true] remoteExec ["setCaptive", _civ];

	waitUntil {

		if (_civ getVariable ["INC_armedLoopRunning",false]) exitWith {true};

		sleep 3;

		waitUntil {

			sleep 3;

			if (

				!(isNull objectParent _civ) &&
				{(!((typeof vehicle _civ) in _safeVehicleArray))  || {(_civ getVariable ["INC_trespassType2",false])} || {(_noOffRoad) && {((vehicle _civ) isKindOf "Land")} && {((count (_civ nearRoads 50)) == 0)}}} //Hostile vehicle or safe land-based vehicle offroad considered suspicious

			) exitWith {true}; //Fires if civ is doing naughty vehicular shizzle

			sleep 2;

			if (
				(isNull objectParent _civ) &&
				{!(uniform _civ in _safeUniforms) || {!(vest _civ in _safeVests)} || {!(backpack _civ in _safeBackpacks)} || {!((currentWeapon _civ == "") || {currentWeapon _civ == "Throw"})} || {!(hmd _civ == "") && !(_HMDallowed)} || {(_civ getVariable ["INC_trespassType2",false])}}
			) exitWith {true}; //Fires if unit gets out weapon or wears suspicious uniform.

			false
		};

		[_civ, false] remoteExec ["setCaptive", _civ];

		waitUntil {

			sleep 3;

			if (

				!(isNull objectParent _civ) &&
				{!((!((typeof vehicle _civ) in _safeVehicleArray))  || {(_civ getVariable ["INC_trespassType2",false])} || {(_noOffRoad) && {((vehicle _civ) isKindOf "Land")} && {((count (_civ nearRoads 50)) == 0)}})} //Hostile vehicle or safe land-based vehicle offroad considered suspicious

			) exitWith {true}; //Fires if civ is doing naughty vehicular shizzle

			sleep 2;

			if (
				(isNull objectParent _civ) &&
				{!(!(uniform _civ in _safeUniforms) || {!(vest _civ in _safeVests)} || {!(backpack _civ in _safeBackpacks)} || {!((currentWeapon _civ == "") || {currentWeapon _civ == "Throw"})} || {!(hmd _civ == "") && !(_HMDallowed)} || {(_civ getVariable ["INC_trespassType2",false])} || {(_civ getVariable ["INC_AnyKnowsSO",false])})}
			) exitWith {true}; //Fires if unit gets out weapon or wears suspicious uniform.

			false

		};

		[_civ, true] remoteExec ["setCaptive", _civ];

		(!(_civ getVariable ["isUndercover",false]) || {!(alive _civ)} || {(isPlayer _civ)})
	};

	_civ setVariable ["INC_civArmedLoopRunning", false, true]; // Stops the script running twice on the same unit
};

[_civ] spawn {

	params ["_civ"];

	_civ setVariable ["INC_civTrespassLoopRunning",true,true];

	private _trespassMarkers = (missionNamespace getVariable ["INC_trespassMarkers",[]]);

    waitUntil {

        sleep 10;

        {
            if (_civ inArea _x) exitWith {

                private _activeMarker = _x;

                _civ setVariable ["INC_trespassType2",true,true];

                waitUntil {

                    sleep 1;

                    !(_civ inArea _activeMarker);
                };

                _civ setVariable ["INC_trespassType2",false,true];
            };

            false

        } count _trespassMarkers;

		sleep 2;

        (!(_civ getVariable ["isUndercover",false]) || {!(alive _civ)})

    };

    _civ setVariable ["INC_civTrespassLoopRunning",false,true];
};

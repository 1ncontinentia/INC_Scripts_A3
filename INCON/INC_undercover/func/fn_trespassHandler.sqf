/*
Trespass Handler, checks whether any of the different types of trespass are being committed and sets trespass variable on.

Author: Incontinentia

Trespass types:
* Type1: player gets too close to enemy units
* Type2: player goes into prohibited area

*/



params [["_unit",objNull],["_trespassMarkers",[]]];

#include "..\UCR_setup.sqf"

if ((_unit getVariable ["INC_trespassLoopRunning",false]) || {!local _unit}) exitWith {};

_unit setVariable ["INC_trespassLoopRunning", true, true]; // Stops the script running twice on the same unit

_unit setVariable ["INC_trespassType1",false,true];
_unit setVariable ["INC_trespassType2",false,true];


//Find trespass markers
{

    _trespassMarkers pushBack _x;

} forEach (allMapMarkers select {
    ((_x find "INC_tre") >= 0)
});

{_x setMarkerAlpha 0} forEach _trespassMarkers;

missionNamespace setVariable ["INC_trespassMarkers",_trespassMarkers,true];


//Marker loop
[_unit,_trespassMarkers] spawn {

    params [["_unit",objNull],["_trespassMarkers",[]]];

    waitUntil {

        sleep 3;

        {
            if (_unit inArea _x) exitWith {

                private _activeMarker = _x;

                _unit setVariable ["INC_trespassType2",true,true];

                waitUntil {

                    sleep 1;

                    !(_unit inArea _activeMarker);
                };

                _unit setVariable ["INC_trespassType2",false,true];
            };

            false

        } count _trespassMarkers;

        (!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)})

    };

};


//Radius checks
[_unit,_regEnySide,_asymEnySide,_regDetectRadius,_asymDetectRadius] spawn {
	params [["_unit",player],["_regEnySide",east],["_asymEnySide",independent],["_radius1",15],["_radius2",25],["_radius3",60],["_radius4",200]];

	private ["_nearReg","_nearAsym","_nearHVT","_nearSuperHVT","_nearMines"];

	waitUntil {

		private _disguiseValue = ((_unit getVariable ["INC_compromisedValue",1]) * (_unit getVariable ["INC_suspiciousValue",1]));

		_nearReg = count ((_unit nearEntities (_radius1 * _disguiseValue)) select {((side _x == _regEnySide) && {(_x knowsAbout _unit) > 3})});

		sleep 0.5;

		_nearAsym = count ((_unit nearEntities _radius2) select {((side _x == _asymEnySide) && {(_x knowsAbout _unit) > 3})});

		sleep 0.5;

		_nearHVT = count ((_unit nearEntities _radius3) select {_x getVariable ["isHVT",false]});

		sleep 0.5;

		_nearSuperHVT = count ((_unit nearEntities (_radius4 * _disguiseValue)) select {_x getVariable ["isSuperHVT",false]});

		sleep 0.5;

		_nearMines = {_x isKindOf "timeBombCore"} count (nearestObjects [_unit,[],4]);

		if ((_nearReg + _nearAsym + _nearHVT + _nearSuperHVT + _nearMines) != 0) then {
			_unit setVariable ["INC_trespassType1",true];
		} else {
			_unit setVariable ["INC_trespassType1",false];
		};

		sleep 0.2;

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)})

	};

};



//Main loop
[_unit,_regEnySide,_asymEnySide] spawn {

	params ["_unit","_regEnySide","_asymEnySide"];

	waitUntil {

		sleep 5;

		waitUntil {
			sleep 2;
			(
				(_unit getVariable ["INC_trespassType1",false]) ||
				{_unit getVariable ["INC_trespassType2",false]}
			); //Fires if any of the trespassing types are met.
		};

		_unit setVariable ["INC_trespassing", true, true]; //Publicises trespassing variable on unit to true.

		waitUntil {
			sleep 2;
			!(
				(_unit getVariable ["INC_trespassType1",false]) ||
				{_unit getVariable ["INC_trespassType2",false]}
			); //Fires if all of the trespassing types are inactive.
		};

		_unit setVariable ["INC_trespassing", false, true]; //Publicises trespassing variable on unit to false.

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)})
	};
};

_unit setVariable ["INC_trespassLoopRunning", false, true];

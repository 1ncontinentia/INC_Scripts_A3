params [["_undercoverUnit",objNull],["_trespassMarkers",[]]];

if ((!local _undercoverUnit) || {_undercoverUnit getVariable ["INC_trespassMarkerLoopRunning",false]}) exitWith {};

_undercoverUnit setVariable ["INC_trespassMarkerLoopRunning",true,true];

{

    _trespassMarkers pushBack _x;

} forEach (allMapMarkers select {
    ((_x find "INC_tre") >= 0)
});

{_x setMarkerAlpha 0} forEach _trespassMarkers;



[_undercoverUnit,_trespassMarkers] spawn {

    params [["_undercoverUnit",objNull],["_trespassMarkers",[]]];

    waitUntil {

        sleep 2;

        {
            if (_undercoverUnit inArea _x) exitWith {

                private _activeMarker = _x;

                _undercoverUnit setVariable ["INC_trespassType2",true,true];

                waitUntil {

                    sleep 1;

                    !(_undercoverUnit inArea _activeMarker);
                };

                _undercoverUnit setVariable ["INC_trespassType2",false,true];
            };

            false

        } count _trespassMarkers;

        (!(_undercoverUnit getVariable ["isUndercover",false]) || {!(alive _undercoverUnit)})

    };

    _undercoverUnit setVariable ["INC_trespassMarkerLoopRunning",false,true];

};

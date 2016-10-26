private ["_nearReg","_nearAsym","_nearHVT","_nearSuperHVT"];

params [["_undercoverUnit",player],["_regEnySide",east],["_asymEnySide",independent],["_radius1",15],["_radius2",25],["_radius3",60],["_radius4",150]];

if ((!local _undercoverUnit) || {_undercoverUnit getVariable ["INC_trespassRadiusLoopRunning",false]}) exitWith {};

_undercoverUnit setVariable ["INC_trespassRadiusLoopRunning",true,true];

[_undercoverUnit,_regEnySide,_asymEnySide,_radius1,_radius2,_radius3,_radius4] spawn {
	params [["_undercoverUnit",player],["_regEnySide",east],["_asymEnySide",independent],["_radius1",15],["_radius2",25],["_radius3",60],["_radius4",200]];

	private ["_nearReg","_nearAsym","_nearHVT","_nearSuperHVT","_nearMines"];

	waitUntil {

		_nearReg = count ((_undercoverUnit nearEntities _radius1) select {((side _x == _regEnySide) && {(_x knowsAbout _undercoverUnit) > 1})});

		sleep 0.2;

		_nearAsym = count ((_undercoverUnit nearEntities _radius2) select {((side _x == _asymEnySide) && {(_x knowsAbout _undercoverUnit) > 1})});

		sleep 0.2;

		_nearHVT = count ((_undercoverUnit nearEntities _radius3) select {_x getVariable ["isHVT",false]});

		sleep 0.2;

		_nearSuperHVT = count ((_undercoverUnit nearEntities _radius4) select {_x getVariable ["isSuperHVT",false]});

		sleep 0.2;

		_nearMines = {_x isKindOf "timeBombCore"} count (nearestObjects [_undercoverUnit,[],3]);

		if ((_nearReg + _nearAsym + _nearHVT + _nearSuperHVT + _nearMines) != 0) then {
			_undercoverUnit setVariable ["INC_trespassType1",true,true];
		} else {
			_undercoverUnit setVariable ["INC_trespassType1",false,true];
		};

		sleep 0.1;

		(!(_undercoverUnit getVariable ["isUndercover",false]) || {!(alive _undercoverUnit)})

	};

	_undercoverUnit setVariable ["INC_trespassRadiusLoopRunning",false,true];

};

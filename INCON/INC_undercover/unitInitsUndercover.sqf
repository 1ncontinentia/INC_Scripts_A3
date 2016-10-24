params ["_unit"];

#include "UCR_setup.sqf"

if (side _unit == _regEnySide) then {
	[_unit,_regBarbaric,_undercoverUnitSide] call INCON_fnc_undercoverKilledHandler;
};

if (side _unit == _asymEnySide) then {
	[_unit,_asymBarbaric,_undercoverUnitSide] call INCON_fnc_undercoverKilledHandler;
};



if (_civRecruitEnabled) then {
	if (((side _unit) == CIVILIAN) && !(_unit getVariable ["isUndercover",false])) then {
		[_unit,_armedCivPercentage] remoteExecCall ["INCON_fnc_recruitCiv",0,true];
	};
};

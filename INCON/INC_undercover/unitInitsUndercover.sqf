params ["_unit"];

#include "UCR_setup.sqf"

switch (side _unit) do {
	case _regEnySide: {
		[_unit,_regBarbaric,_undercoverUnitSide] call INCON_fnc_undercoverKilledHandler;
	};
	case _asymEnySide: {
		[_unit,_asymBarbaric,_undercoverUnitSide] call INCON_fnc_undercoverKilledHandler;
	};
};

if (_civRecruitEnabled) then {
	if (((side _unit) == CIVILIAN) && {!(_unit getVariable ["isUndercover",false])}) then {
		[_unit,_armedCivPercentage,_civRifleArray,_civPistolArray,_civPackArray] remoteExecCall ["INCON_fnc_recruitCiv",0,true];
	};
};

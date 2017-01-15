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

_unit addEventHandler["Killed", {

	params["_unit"];

	[_unit, [
		"<t color='#33FF42'>Take Uniform</t>", {
			params ["_giver","_reciever"];
			private ["_gwh","_reciverUniform","_giverUniform","_droppedRecUni"];

			_gwh = createVehicle ["GroundWeaponHolder", getPosATL _reciever, [], 0, "CAN_COLLIDE"];
			_reciverUniform = uniform _reciever;
			_giverUniform = uniform _giver;
			_gwh addItemCargoGlobal [_reciverUniform, 1];
			_droppedRecUni = (((everyContainer _gwh) select 0) select 1);
			{_droppedRecUni addItemCargoGlobal [_x, 1];} forEach (uniformItems _reciever);
			{_droppedRecUni addItemCargoGlobal [_x, 1];} forEach (uniformItems _giver);
			removeUniform _reciever;
			removeUniform _giver;
			_reciever forceAddUniform _giverUniform;

			},[],6,true,true,"","((_this getVariable ['isUndercover',false]) && {uniform _target != ''})",4
	]] remoteExec ["addAction", 0,true];
}];

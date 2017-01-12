/*

This script sets a variable on the unit showing whether there are any Reg or Asym units who know about them.

*/

private ["_detectedGroup","_getAlertedReg","_getAlertedAsym","_alertedUnitsReg","_alertedRegCount","_alertedUnitsAsym","_alertedAsymCount","_RegKnowAboutUnit","_AsymKnowAboutUnit"];
params [["_unit",player]];

#include "..\UCR_setup.sqf"

if (_unit getVariable ["undercoverDetectionRunning",false]) exitWith {};

_unit setVariable ["undercoverDetectionRunning",true,true];

missionNamespace setVariable ["INC_ucr_firedEhReg",_regEnySide,true];

missionNamespace setVariable ["INC_ucr_firedEhAsym",_asymEnySide,true];

//Detection Loop
[_unit,_regEnySide,_asymEnySide] spawn {

	params ["_unit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

	waitUntil {

		sleep 5;

		private _alertedRegKnows = ([_unit, _regEnySide] call INCON_fnc_undercoverGetAlerted);

		private _alertedAsymKnows = ([_unit, _asymEnySide] call INCON_fnc_undercoverGetAlerted);

		private _anyAlerted = false;

		if (_alertedRegKnows || {_alertedAsymKnows}) then {_anyAlerted = true};

		//Publicise variables on undercover unit for undercover handler, killed handler & cooldown.
		_unit setVariable ["INC_RegKnowsSO", _alertedRegKnows, true];
		_unit setVariable ["INC_AsymKnowsSO", _alertedAsymKnows, true];
		_unit setVariable ["INC_AnyKnowsSO", _anyAlerted, true];

		(!(_unit getVariable ["isUndercover",false]) || !(alive _unit))
	};

	_unit setVariable ["undercoverDetectionRunning",false,true];
};

if (!isPlayer _unit) exitWith {}; 

//Fired EventHandler
_unit addEventHandler["Fired", {
	params["_unit"];

	//If he's compromised, do nothing
	if !(_unit getVariable ["INC_undercoverCompromised",false]) then {

		//If anybody is aware of the unit, then...
		if (_unit getVariable ["INC_AnyKnowsSO",false]) then {

			//Do nothing unless they know where the dude is
			_regAlerted = [INC_ucr_firedEhReg,_unit,50] call INCON_fnc_countAlerted;
			_asymAlerted = [INC_ucr_firedEhAsym,_unit,50] call INCON_fnc_countAlerted;

			//Once people know where he is, who he is, and that he has fired a weapon, make him compromised
			if ((_regAlerted != 0) || {_asymAlerted != 0}) exitWith {

				[_unit] call INCON_fnc_undercoverCompromised;
			};
		};
	};
}];

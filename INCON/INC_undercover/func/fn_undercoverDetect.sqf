/*

This script sets a variable on the unit showing whether there are any Reg or Asym units who know about them.

*/

private ["_detectedGroup","_getAlertedReg","_getAlertedAsym","_alertedUnitsReg","_alertedRegCount","_alertedUnitsAsym","_alertedAsymCount","_RegKnowAboutUnit","_AsymKnowAboutUnit"];
params [["_underCoverUnit",player],["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

if (_underCoverUnit getVariable ["undercoverDetectionRunning",false]) exitWith {};

[_underCoverUnit,_regEnySide,_asymEnySide] spawn {

	params ["_underCoverUnit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

	_underCoverUnit setVariable ["undercoverDetectionRunning",true,true];

	waitUntil {

		sleep 5;

		private _alertedRegKnows = ([_underCoverUnit, _regEnySide] call INCON_fnc_undercoverGetAlerted);

		private _alertedAsymKnows = ([_underCoverUnit, _asymEnySide] call INCON_fnc_undercoverGetAlerted);

		private _anyAlerted = false;

		if (_alertedRegKnows || {_alertedAsymKnows}) then {_anyAlerted = true};

		//Publicise variables on undercover unit for undercover handler, killed handler & cooldown.
		_underCoverUnit setVariable ["INC_RegKnowsSO", _alertedRegKnows, true];
		_underCoverUnit setVariable ["INC_AsymKnowsSO", _alertedAsymKnows, true];
		_underCoverUnit setVariable ["INC_AnyKnowsSO", _anyAlerted, true];

		(!(_underCoverUnit getVariable ["isUndercover",false]) || !(alive _underCoverUnit))
	};

	_underCoverUnit setVariable ["undercoverDetectionRunning",false,true];
};

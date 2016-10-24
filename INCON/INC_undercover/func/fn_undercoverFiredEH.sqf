/*
Undercover Unit Fired Eventhandler
*/


params [["_underCoverUnit",objNull],["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

INC_ucr_firedEhReg = _regEnySide;

INC_ucr_firedEhAsym = _asymEnySide;

publicVariable "INC_ucr_firedEhReg";

publicVariable "INC_ucr_firedEhAsym";

//Run the script locally
//if (!local _undercoverUnit) exitWith {};

//Fired EventHandler
_underCoverUnit addEventHandler["Fired", {
	params["_underCoverUnit"];

	//If he's compromised, do nothing
	if !(_underCoverUnit getVariable ["INC_undercoverCompromised",false]) then {

		//If anybody is aware of the unit, then...
		if (_underCoverUnit getVariable ["INC_AnyKnowsSO",false]) then {

			//Do nothing unless they know where the dude is
			_regAlerted = [INC_ucr_firedEhReg,_underCoverUnit,50] call INCON_fnc_countAlerted;
			_asymAlerted = [INC_ucr_firedEhAsym,_underCoverUnit,50] call INCON_fnc_countAlerted;

			//Once people know where he is, who he is, and that he has fired a weapon, make him compromised
			if ((_regAlerted != 0) || (_asymAlerted != 0)) exitWith {

				[_underCoverUnit] call INCON_fnc_undercoverCompromised;
			};
		};
	};
}];

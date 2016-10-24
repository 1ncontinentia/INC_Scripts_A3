/*

This script contains the eventhandlers for intel and undercover operations contained in the /intel folder.


Author: Incontinentia (copy and paste skills) with enormous help from SpyderBlack723 and Dixon13.


Must be defined in description.ext with

//----------------------INIT EVENTHANDLERS--------------------------
class Extended_Init_EventHandlers {
class CAManBase {
init = "_this call (compile preprocessFileLineNumbers 'unitInits.sqf')";
};
};

Requires fnc_spawnIntelObjects.



---------------------------------------------------------------------------- */




params [["_unit",objNull]];


//Exit if the code is already running on the unit or the unit has "noChanges" variable
if (_unit getVariable ["initLoopRunning",false]) exitWith {};
if (_unit getVariable ["noChanges",false]) exitWith {};

_unit setVariable ["initLoopRunning", true, true];

#include "INCON\INC_undercover\unitInitsUndercover.sqf"


if (side _unit in [EAST,WEST,INDEPENDANT]) then {
    [_unit] call INCON_fnc_spawnIntelObjects;
};
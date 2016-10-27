params ["_input","_mode"];

private ["_result"];

if !(isDedicated) exitWith {}; 

switch (_mode) do {

	case "saveData": {
		_input params ["_key","_value"];
		[_key, _value] call ALiVE_fnc_setData;
		_result = true;
	};

	case "loadData": {
		_input params ["_key"];
		_result = [_key] call ALiVE_fnc_getData;
	};

};

_result;

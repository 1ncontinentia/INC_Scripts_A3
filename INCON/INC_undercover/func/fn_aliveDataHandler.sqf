params ["_input","_mode"];

switch (_mode) do {

	case "saveData": {
		_input params ["_key","_value"];
		[_key, _value] call ALiVE_fnc_setData;
	};

	case "loadData": {



	};

};

_result;

/*

Author: Spyderblack723

*/

private ["_unit","_linkedItems"];

params ["_gearType","_factions"];

private _result = [];

private _units = [];
private _cfgVehicles = configFile >> "CfgVehicles";

for "_i" from 0 to (count _cfgVehicles - 1) do {
    _entry = _cfgVehicles select _i;

    if (isclass _entry) then {
        if (
            (getNumber(_entry >> "scope") >= 2) &&
            {configname _entry isKindOf "Man"}
        ) then {
            _units pushback _entry;
        };
    };
};

switch (_gearType) do {

    case "headgear": {
        {
            _unit = _x;
            _linkedItems = getArray (_unit >> "linkedItems");

            {
                _item = _x;
                _configPath = configFile >> "CfgWeapons" >> _item;
                    if (isClass _configPath) then {
                        _itemInfo = getNumber (_configPath >> "ItemInfo" >> "Type");

                        switch (str _itemInfo) do {
                            case "605": {
                                _result pushbackunique _item;
                            };
                        };
                    };
            } forEach _linkedItems;
        } forEach _units;
    };

    case "vests": {
        {
            _unit = _x;
            _linkedItems = getArray (_unit >> "linkedItems");
            {
                _item = _x;
                _configPath = configFile >> "CfgWeapons" >> _item;
                    if (isClass _configPath) then {
                        _itemInfo = getNumber (_configPath >> "ItemInfo" >> "Type");

                        switch (str _itemInfo) do {
                            case "701": {
                                _result pushbackunique _item;
                            };
                        };
                    };
            } forEach _linkedItems;
        } forEach _units;
    };

    case "uniforms": {
        {
            _uniform = getText (_x >> "uniformClass");
            _result pushbackunique _uniform;
        } forEach _units;
    };

};

_result

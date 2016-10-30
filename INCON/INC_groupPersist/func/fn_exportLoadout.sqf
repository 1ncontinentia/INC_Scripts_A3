/*
	Author: Karel Moricky
	Modified by: Incontinentia

	Description:
	Export unit's loadout

	Parameter(s):
		0: OBJECT - unit of which loadout will be export

	Returns:
	STRING - SQF code
*/

params [["_center",objNull]];

_br = tostring [13,10];
_export = "";

_fnc_addMultiple = {
	_items = _this select 0;
	_expression = _this select 1;
	_itemsUsed = [];
	{
		_item = _x;
		_itemLower = tolower _x;
		if !(_itemLower in _itemsUsed) then {
			_itemsUsed set [count _itemsUsed,_itemLower];
			_itemCount = {_item == _x} count _items;
			_expressionLocal = _expression;
			if (_itemCount > 1) then {
				_expressionLocal = format ["for ""_i"" from 1 to %1 do {%2};",_itemCount,_expression];
			};
			_export = _export + format [_expressionLocal,_var,_x] + _br;
		};
	} foreach _items;
};

_export = _export + "_unit = _this select 0;" + _br;
_var = "_unit";

_export = _export + format ["removeAllWeapons %1;",_var] + _br;
_export = _export + format ["removeAllItems %1;",_var] + _br;
_export = _export + format ["removeAllAssignedItems %1;",_var] + _br;
_export = _export + format ["removeUniform %1;",_var] + _br;
_export = _export + format ["removeVest %1;",_var] + _br;
_export = _export + format ["removeBackpack %1;",_var] + _br;
_export = _export + format ["removeHeadgear %1;",_var] + _br;
_export = _export + format ["removeGoggles %1;",_var] + _br;

if (uniform _center != "") then {
	_export = _export + format ["%1 forceAddUniform ""%2"";",_var,uniform _center] + _br;
	[uniformitems _center,"%1 addItemToUniform ""%2"";"] call _fnc_addMultiple;
};

if (vest _center != "") then {
	_export = _export + format ["%1 addVest ""%2"";",_var,vest _center] + _br;
	[vestitems _center,"%1 addItemToVest ""%2"";"] call _fnc_addMultiple;
};

if (!isnull unitbackpack _center) then {
	_export = _export + format ["%1 addBackpack ""%2"";",_var,typeof unitbackpack _center] + _br;
	[backpackitems _center,"%1 addItemToBackpack ""%2"";"] call _fnc_addMultiple;
};

if (headgear _center != "") then {_export = _export + format ["%1 addHeadgear ""%2"";",_var,headgear _center] + _br;};
if (goggles _center != "") then {_export = _export + format ["%1 addGoggles ""%2"";",_var,goggles _center] + _br;};


{
	_weapon = _x select 0;
	_weaponAccessories = _x select 1;
	_weaponCommand = _x select 2;
	if (_weapon != "") then {
		_export = _export + format ["%1 addWeapon ""%2"";",_var,_weapon] + _br;
		{
			if (_x != "") then {_export = _export + format ["%1 %3 ""%2"";",_var,_x,_weaponCommand] + _br;};
		} foreach _weaponAccessories;
	};
} foreach [
	[primaryweapon _center,_center weaponaccessories primaryweapon _center,"addPrimaryWeaponItem"],
	[secondaryweapon _center,_center weaponaccessories secondaryweapon _center,"addSecondaryWeaponItem"],
	[handgunweapon _center,_center weaponaccessories handgunweapon _center,"addHandgunItem"],
	[binocular _center,[],""]
];

[assigneditems _center - [binocular _center],"%1 linkItem ""%2"";"] call _fnc_addMultiple;

_export

/*

This script returns boolean on whether any living groups of a given side know about the unit.

*/

params [["_unit",player],["_detectingSide",sideEmpty]];

if (_detectingSide isEqualTo sideEmpty) exitWith {false};

_alertedGroups = allGroups select {
	if (side _x isEqualTo _detectingSide) then {
		if (alive leader _x) then {
			if ((leader _x targetKnowledge _unit) select 0) then {
				if (!captive leader _x) then {
					true
				};
			};
		};
	};
};

if ((count _alertedGroups) != 0) exitWith {true};

false

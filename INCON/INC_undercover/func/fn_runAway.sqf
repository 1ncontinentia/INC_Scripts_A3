params [["_unit",objNull]];

_unit doMove [((getPosASL _unit select 0) + (5 + (random 3) - (random 16))),((getPosASL _unit select 1) + (5 + (random 3))),(getPosASL _unit select 2)];

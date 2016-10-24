{[[_x], "INCON\INC_undercover\undercoverHandler.sqf"] remoteExec ["execVM",_x];} forEach (allUnits select {_x getVariable ["isSneaky",false]});

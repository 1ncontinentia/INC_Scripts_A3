params ["_civ","_undercoverUnit"];

private ["_civPos","_prevGroup","_civUnitorm","_civFace","_civSpeaker","_civHeadgear","_civRifle","_civBackpack","_civName","_civType"];

_civPos = getPosWorld _civ;
_prevGroup = group _civ;
_civFace = face _civ;
_civSpeaker = speaker _civ;
_civHeadgear = selectRandom ["H_Shemag_olive","H_ShemagOpen_tan","H_ShemagOpen_khk"];
_civName = name _civ;
_civType = typeOf _civ;
deleteVehicle _civ;

_skill = (0.7 + (random 0.25));

_unitType = typeOf _undercoverUnit;
_civLoadout = getUnitLoadout _civ;

_recruitedCiv = (group _undercoverUnit) createUnit [_unitType,[0,0,0],[],0,""];
_recruitedCiv setVariable ["noChanges",true,true];
_recruitedCiv setVariable ["isUndercover", true, true];

_recruitedCiv setPosWorld _civPos;
_recruitedCiv setUnitAbility _skill;

if ((count units _prevGroup) == 0) then {
	deleteGroup _prevGroup;
};

[_recruitedCiv,_civLoadout,_civHeadgear,_civFace,_civName,_civSpeaker,_undercoverUnit] spawn {
	params ["_recruitedCiv","_civLoadout","_civHeadgear","_civFace","_civName","_civSpeaker","_undercoverUnit"];

	sleep 0.1;

	_recruitedCiv setUnitLoadout _civLoadout;

	sleep 0.1;

	[_recruitedCiv, _civFace] remoteExec ["setFace", 0];
	[_recruitedCiv, _civName] remoteExec ["setName", 0];
	[_recruitedCiv, _civSpeaker] remoteExec ["setSpeaker", 0];

	sleep 0.3;

	_recruitedCiv remoteExec ["removeAllActions",0];
	removeHeadgear _recruitedCiv;

	sleep 0.1;

	_recruitedCiv addHeadgear _civHeadgear;

	sleep 1;

	[[_recruitedCiv,_undercoverUnit],"addConcealActions"] call INCON_fnc_civHandler;

	[_recruitedCiv] remoteExecCall ["INCON_fnc_simpleArmedTracker",_undercoverUnit];

	[_recruitedCiv] remoteExecCall ["INCON_fnc_undercoverDetect",_undercoverUnit];

};

_recruitedCiv setCombatMode "GREEN";

_recruitedCiv

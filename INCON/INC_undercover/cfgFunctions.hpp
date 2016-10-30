class undercoverRecruit
{
	file = "INCON\INC_undercover\func";
	class countAlerted {description = "Counts units of the defined side who have been alerted to a unit.";};
	class getFactionGear {description = "Gets a faction's gear.";};
	class getLoadout {description = "Copy a unit's loadout and store it in SQF.";};
	class recruitAttempt {description = "Attempt to recruit - requires ALiVE.";};
	class recruitCiv {description = "Allows civilians to be recruited. Also gives them either a rifle or pistol.";};
	class recruitSuccess {description = "Unit join's initiator's group and adds dismiss, conceal weapon and show weapon actions.";};
	class runAway {description = "Unit runs away from someone who is trying to steal their stuff.";};
	class simpleArmedTracker {description = "Sets captive depending on whether the unit is armed, wearing suspicious clothing or enemy units know about them.";};
	class spawnRebelCommander {description = "Spawns a commander for civilian units to join in an uprising.";};
	class undercoverArmedTracker {description = "Sets 'armed' variable to be picked up by undercover handler depending on whether the unit is armed, wearing suspicious clothing or enemy units know about them.";};
	class undercoverCompromised {description = "Sets the unit as compromised while it is know to enemy units and is doing something naughty.";};
	class undercoverCooldown {description = "Initiates a cooldown after the unit has done something naughty";};
	class undercoverDetect {description = "Updates variables on a unit which become true if the defined side knows about them.";};
	class undercoverFiredEH {description = "If the undercover unit is seen firing, it becomes compromised.";};
	class undercoverGetAlerted {description = "Returns the number of given side who know about the unit";};
	class undercoverKilledHandler {description = "Handles enemy deaths - enemies may become suspicious if they know about a nearby undercover unit. Also includes options for reprisals against civilians if the side is predefined as brutal in the setup.";};
	class undercoverTrespassHandler {description = "Handles unit trespassing in different situations, returning the 'trespassing' variable on the unit for the undercover handler.";};
	class undercoverTrespassMarkerLoop {description = "Handles unit trespassing in prohibited markers.";};
	class undercoverTrespassRadiusLoop {description = "Handles unit getting too close to enemy units.";};
};

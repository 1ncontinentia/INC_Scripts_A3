Requires:

ALiVE (for civilian recruitment)
CBA

FEATURES

Allows a player and his group to dress as civilians and go incognito, recruit civilians, and cause mayhem.
Integrates with ALiVE
Undercover simulation for stealth / sneaky beaky / guerilla missions without killing performance
Works on players and their AI group members
Recruit civilians and cause mayhem
Undercover units remain incognito unless they
(a) get too close to military units (of enemy side defined in INT_setup.sqf),
(b) wear a suspicious uniform or vest (configurable),
(c) openly carry any weapon (or binoculars so if you're dicking, do it in private),
(d) trespass into a forbidden area
(e) become compromised

Enemies ignore the AI group members of undercover units unless they

(a) wear a suspicious uniform or vest (configurable),
(b) openly carry any weapon (including binoculars),
(c) are seen doing naughty things (see below)

Stealth kills work -

If nobody sees you firing a shot, your cover will remain intact (works for both AI and players)
BUT, enemies do remember suspicious units - if you kill someone and other enemies of that side already know who you are and that you are nearby, there is a chance your cover will be blown regardless
However, your cover will return if you kill everyone who knows about you before they can spread the word
Different behaviour for regular and asymmetric forces

Define a side as asymmetric and they will not share your identity outside of the local area (maximum 1 regular side and 1 asymmetric side supported at present)
Define a side as regular and your cover will stay blown for much longer and for a much wider area once compromised
(Optional) Civilian Recruitment

Undercover units can recruit civilians to join their group
The more enemies you kill, the better your side's reputation will become (persists with ALiVE)
The better your side's reputation, the more likely civilians are to join you
Simple incognito script for recruited civilians - if they are openly armed or enemies have seen them acting suspiciously, they will be seen as hostile to enemies until all enemies that know about them have been killed
Armed civilians can hide their weapons to remain incognito using the group actions radio menu (6 - 1, the same menu as "open subordinate's inventory), and get them out when required using the same radio menu
You can dismiss civilians at any time using the radio menu
Ordinary ALiVE-spawned civilians may carry concealed weapons and pistols on their person or in backpacks (optional - only vanilla AKs and Rook handguns currently supported, I'll make this more flexible in future if there's apetite for it)
(Optional) If you kill an enemy and remain undetected, their side may lash out against civilians, which could in turn prompt reprisals from armed civilians (meaning, you could start a small scale rebellion)
Caveats:

The detection stuff will work without ALiVE. The recruitment of civilians will not work properly without ALiVE's civilian placement modules (you can disable recruitment in the setup options).
Works on dedicated server
SP compatible, untested in COOP but should work fine
Only one side can have undercover units at a time (so no east undercover and west undercover undercoverising each other at the same time)
USAGE

Change your settings in the UCR_setup.sqf file.

For each undercover unit, put this in their unit init in the editor (only group leaders need this):

this setVariable ["isSneaky",true,true];
For each out of bounds area, place a marker over the area with "INC_tre" somewhere in the marker name (e.g. "MyMarkerINC_tre" or "INC_tre_sillyMarkerName_15". The script will handle the rest.


In initPlayerLocal.sqf:

if (player getVariable ["isSneaky",false]) then {
    [player] execVM "INCON\INC_undercover\undercoverHandler.sqf";
};




In description.ext:

class Extended_InitPost_EventHandlers {
     class CAManBase {
		init = "_this call (compile preprocessFileLineNumbers 'INCON\INC_undercover\unitInitsUndercover.sqf')";
	};
};

class CfgFunctions
{
	#include "INCON\INC_undercover\cfgFunctions.hpp"
};

class CfgRemoteExec
{
   class Functions
   {
       mode = 2;
       jip = 1;
       #include "INCON\INC_undercover\functionsWhitelist.hpp"
   };
};

FUTURE PLANS

Sector hostility rewards for killing enemies on all sides, not just BLUFOR - done
Recruit civilians to non-BLUFOR sides - done
Trespassing areas - done (thanks to Spyderblack723)
Add ability to change civilians' weapons
Disguises - done

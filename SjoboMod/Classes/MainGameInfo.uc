//#############################################################################
// Kinda like a only one existing top actor, usefully for main game logic
//#############################################################################
class MainGameInfo extends EmptyGameInfo;

//#############################################################################
// Properties
//#############################################################################
var float NextDayWhenTimeElapsedPassed;

//#############################################################################
// Constants
//#############################################################################
const DayLengthInSeconds = 1440; // 24*60

//#############################################################################
// Events
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// PostTravel - Called after player has been spawned into world
///////////////////////////////////////////////////////////////////////////////
event PostTravel(P2Pawn PlayerPawn)
{
	// Call Super first
	Super.PostTravel(PlayerPawn);
	// TBD
	
	// If this is a new game, and bAllWeapons is true, give the Dude all the weapons in the game.
	if (!bLoadedSavedGame)
	{
		
	}
}

///////////////////////////////////////////////////////////////////////////////
// AddPawn - Called whenever an Pawn has been added to the level
///////////////////////////////////////////////////////////////////////////////
function AddPawn(Pawn AddMe)
{
	Super.AddPawn(AddMe);
	// TBD
}

///////////////////////////////////////////////////////////////////////////////
// Tick - Keeps track of time and calls NewDay when a new day starts
///////////////////////////////////////////////////////////////////////////////
event Tick(float Delta)
{
	local NPC pawn;
	local NPCCOntroller controller;

	Super.Tick(Delta);

	if(NextDayWhenTimeElapsedPassed <= TheGameState.TimeElapsed){
		NextDayWhenTimeElapsedPassed = TheGameState.TimeElapsed + DayLengthInSeconds;
		foreach DynamicActors(class'NPC', pawn){
			controller = NPCController(pawn.Controller);
			controller.NewDay();
		}
	}
}

//#############################################################################
// Default Properties
//#############################################################################
defaultproperties
{

	// Blank Day
	// This is a DayBase object with no errands defined and a minimal starting inventory.
	Begin Object Class=DayBase Name=SampleDay
		Description="Blank Day"
		LoadTex="p2misc_full.Load.loading-screen"
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(1)=(InvClassName="SjoboMod.LandlordClipboardWeapon")
	End Object
	
	// Game Definition
	// This is where you put together the days you've assembled to form a full week.
	Days(0)=DayBase'SampleDay'
	
	// Advanced users: define an alternate startup map, main menu, and game menu.
	// Can be used for "total conversion"-style games.
	// Don't mess with these unless you have a good working knowledge of the game's startup and menu system	

	// bShowStarrtupOnNewGame: if true, opens up the game's defined MainMenuURL when starting a new game, instead of StartFirstDayURL.
	// This should be a cinematic startup-style map, like POSTAL 2's Startup.fuk
	bShowStartupOnNewGame=true
	// MainMenuURL: URL of map to load when bShowStartupOnNewGame is true
	// This map is also loaded when quitting the game, so it should have a scripted action to show the main menu.
	MainMenuURL="UltimateSandboxStartup"
	// MainMenuName: class of menu to load after quitting the game. Should be Shell.MenuMain unless you know exactly what you're doing
	MainMenuName="Shell.MenuMain"
	// StartMenuName: class of menu to load when starting a new game with bShowStartupOnNewGame=true
	// Typically this will have two options: "Start" and "Quit"
	// If you don't have a specialized start menu, bShowStartupOnNewGame MUST be set to FALSE.
	StartMenuName="Shell.ExpansionMenuStart"
	// GameMenuName: class of menu to use for the Escape menu in-game. Should be Shell.MenuGame unless you know exactly what you're doing
	GameMenuName="Shell.MenuGame"
	
	// Game logo to be displayed in game menus
	MenuTitleTex="UltimateSandboxTex.UltimateSandboxMenuTitle"

	// Game Name displayed in the Workshop Browser.
	GameName="Sjöbo Mod"
	// Game Name displayed in the Save/Load Game Menu.
	GameNameShort="Sjöbo Mod"
	// Game Description displayed in the Workshop Browser.
	GameDescription="Small town in southern Sweden"

	PlayerControllerClassName="SjoboMod.PlayerLandlordController"
	DefaultPlayerClassName="GameTypes.AWPostalDude"

	HUDType="SjoboMod.MainHUD"
}

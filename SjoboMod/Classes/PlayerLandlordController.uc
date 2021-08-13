//#############################################################################
// PlayerLandlordController contains controller logic for the player
//#############################################################################
class PlayerLandlordController extends PlayerLandlordControllerBase;


//#############################################################################
// Properties
//#############################################################################

// Screens
var transient LandlordScreen MyLandlordScreen;	// Map screen


//#############################################################################
// Events
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// TravelPostAccept - Called after a level travel
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();
}

///////////////////////////////////////////////////////////////////////////////
// SetupScreens - Setups all player screens
///////////////////////////////////////////////////////////////////////////////
function SetupScreens()
{
	local int i;
	local LandlordScreen map;

	Super.SetupScreens();

	// Search for existing screens
	for (i = 0; i < Player.LocalInteractions.Length; i++)
	{
		map = LandlordScreen(Player.LocalInteractions[i]);
		if (map != None)
			MyLandlordScreen = map;
	}

	// Destroy the old screen -- vital to make sure that proper game types load their correct Map screens.
	if (MyLandlordScreen != None && MyLandlordScreen.Class != class'LandlordScreen')
	{
		Player.InteractionMaster.RemoveInteraction(MyLandlordScreen);
		MyLandlordScreen = None;
	}
	
	// If screens weren't found, create new ones
	if (MyLandlordScreen == None)
		MyLandlordScreen = LandlordScreen(Player.InteractionMaster.AddInteraction("LandlordScreen", Player));
}

///////////////////////////////////////////////////////////////////////////////
// DetachScreens - Clean up our screens.
///////////////////////////////////////////////////////////////////////////////
function DetachScreens()
{
	// Only do this for single player games
	if (P2GameInfoSingle(Level.Game) != None)
	{
		if (MyLandlordScreen != None)
		{
			Player.InteractionMaster.RemoveInteraction(MyLandlordScreen);
			MyLandlordScreen = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// DisplayStats - Display the stats screen (called externally)
///////////////////////////////////////////////////////////////////////////////
function DisplayStats(optional String URL)
{
	if (!MyLandlordScreen.IsRunning())
	{
		MyLandlordScreen.Show(URL);
		CurrentScreen = MyLandlordScreen;
		SetMyOldState();
		GotoState('WaitScreen');
	}
}
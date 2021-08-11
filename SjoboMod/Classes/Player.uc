class Player extends DudePlayer;

// Screens
var transient LandlordScreen MyLandlordScreen;	// Map screen

function SetupScreens()
{
	local int i;
	local LandlordScreen map;

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
// Clean up our screens.
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
// Display the stats screen (called externally)
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

///////////////////////////////////////////////////////////////////////////////
// called after a level travel
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();
	log("Player has been spawned, hell yeah");
}
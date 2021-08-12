class Player extends DudePlayer;

// Screens
var transient LandlordScreen MyLandlordScreen;	// Map screen

///////////////////////////////////////////////////////////////////////////////
// called after a level travel
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();
}

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

// MustGetOrCreateItem first checks if inventory contains item of provide class and if it does it returns that specific item
// elsewise it will create a new item add it to the inventory and return it
function Inventory MustGetOrCreateItem(class<Inventory> itemClass){
    local Inventory item;
    item = GetItem(itemClass);
    if(item != None)
        return item;
    return AddItem(itemClass);
}

// GetItem searches the inventory for a specific item of provided class and returns it
function Inventory GetItem(class<Inventory> itemClass){
    local inventory item;
    local int Count;
    for( item=MyPawn.Inventory; item!=None; item=item.Inventory )
	{
		if( item.Class == itemClass )
            return item;

        // Failsafe in case of circular links (since the Inventory is one ghuge linked list there is a possibility of looping)
		Count++;
		if (Count > 5000)
			break;
	}
    return None;
}

// AddItem creates item and adds it to the inventory and then returns the item
// returns None if item already exists in Inventory
function Inventory AddItem(class<Inventory> itemClass){
    local Inventory item;
    item = MyPawn.CreateInventoryByClass(itemClass);
    if(item == None){
        return None;
    }
    return item;
}
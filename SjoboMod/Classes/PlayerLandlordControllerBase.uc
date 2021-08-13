//#############################################################################
// PlayerLandlordControllerBase exists to keep PlayerController more clean
//#############################################################################
class PlayerLandlordControllerBase extends DudePlayer;

//#############################################################################
// Helper Methods
//#############################################################################

//#############################################################################
// Shared Helper Methods (Copy between all controller base classes)
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// MustGetOrCreateItem - first checks if inventory contains item of provide
// class and if it does it returns that specific item elsewise it will create 
// a new item add it to the inventory and return it
///////////////////////////////////////////////////////////////////////////////
function Inventory MustGetOrCreateItem(class<Inventory> itemClass){
    local Inventory item;
    item = GetItem(itemClass);
    if(item != None)
        return item;
    return AddItem(itemClass);
}

/////////////////////////////////////////////////////////////////////////////////////////
// GetItem - searches the inventory for a specific item of provided class and returns it
/////////////////////////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////////////////////////
// AddItem - creates item and adds it to the inventory and then returns the item 
// returns None if item already exists in Inventory
/////////////////////////////////////////////////////////////////////////////////////////
function Inventory AddItem(class<Inventory> itemClass){
    local Inventory item;
    item = MyPawn.CreateInventoryByClass(itemClass);
    if(item == None){
        return None;
    }
    return item;
}
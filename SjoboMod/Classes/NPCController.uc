class NPCController extends BystanderController;

var bool HasBeenSetup, HasBeenBotheredRegardingRenting;
var int Salary;
var NPC NPC;
var Player InterestPlayer;

// Gets called once when the NPC reaches his first Thinking state
function Setup()
{
    
    local MoneyInv Money;
    NPC = NPC(MyPawn);
    Salary = Rand(NPC.NPCSalaryMax - NPC.NPCSalaryMin);
    Money = MoneyInv(MustGetOrCreateItem(class'MoneyInv'));
    Money.Amount = Salary;
}

function AddSalaryToBankAccount(){
    MoneyInv(MustGetOrCreateItem(class'MoneyInv')).Amount += Salary;
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
        log("#### Failed to create inventory by class");
        return None;
    }
    return item;
}

// Called by Main whenever a new day starts
function NewDay()
{
    AddSalaryToBankAccount();
}

event PostBeginPlay() 
{
    
}

state Thinking {
    function BeginState()
	{
        if(!HasBeenSetup){
            HasBeenSetup = true;
            Setup();
        }
        Super.BeginState();
    }
}

state ReactToLandlordSpeaking
{
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
        InterestPlayer = Player(InterestPawn.Controller);
	}
Begin:
	// Stare at the result a minute
	Sleep(2.0 - MyPawn.Reactivity);

    if(NPC.NPCHomeTag == ""){ // I have no home
        log("#### I have no home");
        // Consider renting an apartment
        if(Salary < 20){
            PrintDialogue("Can't afford one");
            if(HasBeenBotheredRegardingRenting){
                NPC.SetMood(MOOD_Angry, 1.0);
                Sleep(Say(MyPawn.myDialog.lDefiant, true));
            }else{
                Sleep(Say(MyPawn.myDialog.lDontAcceptDeal, true));
            }
            HasBeenBotheredRegardingRenting = true;
            GotoStateSave('Thinking');
        }else{
            PrintDialogue("Yes please, show me my apartment");
            // No idea
            Sleep(Say(MyPawn.myDialog.lYes, true));
            Focus = None;
            GotoStateSave('FollowLandlordToPotentialHousing');
        }
    }else{ // I have a home

    }
}

state FollowLandlordToPotentialHousing
{
    function BeginState()
	{
		PrintThisState();
        log("TEST TEST TEST");
	}

Begin:
    log("State loop entered");
    if(InterestPawn == None){
        log("No more interest");
        GotoStateSave('Thinking');
    }else if(VSize(InterestPawn.Location - MyPawn.Location) < 600){
        MyPawn.StopAcc();
        log("Arrived and waiting");
        Sleep(1);
        GotoStateSave('FollowLandlordToPotentialHousing');
    }else{
        log("Will walk to target");
        EndGoal = InterestPawn;
        SetNextState('FollowLandlordToPotentialHousing');
        GotoStateSave('WalkToTarget');
    }
    log("State loop exited");
}

// function GrantMugeeCash()
// {
//     local Inventory thisinv;
//     local P2PowerupInv pinv;
//     local int GiveAmount;
//     local byte CreatedNow;

//     thisinv = InterestPawn.CreateInventoryByClass(class'Inventory.MoneyInv', CreatedNow);

//     GiveAmount = Rand(100) + 50;

//     pinv = P2PowerupInv(thisinv);


//     // Add in what we gave them
//     if(pinv != None)
//     {
//         pinv.AddAmount(GiveAmount);
//         // set it as your item
//         if(InterestPawn != None)
//             InterestPawn.SelectedItem = pinv;
//     }
// }
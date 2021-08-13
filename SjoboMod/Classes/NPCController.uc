//#############################################################################
// NPC Controller - Contains NPC controller logic
//#############################################################################
class NPCController extends NPCControllerBase;


//#############################################################################
// Properties
//#############################################################################
var bool HasBeenSetup, HasBeenBotheredRegardingRenting;
var int Salary;
var NPC NPC;
var PlayerLandlordController InterestPlayerController;

// LandlordClipboard
var float WaitTimeoutExpire;
var LandlordClipboardWeapon LandlordClipboard;
var bool HasGivenAttention;


//#############################################################################
// Constants
//#############################################################################
const WaitTimeout = 20;


//#############################################################################
// Events
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay() 
{
    Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Gets called once when the NPC reaches his first Thinking state
///////////////////////////////////////////////////////////////////////////////
function Setup()
{
    
    local MoneyInv Money;
    NPC = NPC(MyPawn);
    Salary = Rand(NPC.NPCSalaryMax - NPC.NPCSalaryMin);
    Money = MoneyInv(MustGetOrCreateItem(class'MoneyInv'));
    Money.Amount = Salary;
}

///////////////////////////////////////////////////////////////////////////////
// Called by Main whenever a new day starts
///////////////////////////////////////////////////////////////////////////////
function NewDay()
{
    AddSalaryToBankAccount();
}

///////////////////////////////////////////////////////////////////////////////
// Adds NPC's assigned salary to
///////////////////////////////////////////////////////////////////////////////
function AddSalaryToBankAccount(){
    MoneyInv(MustGetOrCreateItem(class'MoneyInv')).Amount += Salary;
}


//#############################################################################
// States
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// Thinking
///////////////////////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////////////////////////
// ReactToLandlordSpeaking - Invoked on Select Dude action
///////////////////////////////////////////////////////////////////////////////
state ReactToLandlordSpeaking
{

	function BeginState()
	{
        
		PrintThisState();
		MyPawn.StopAcc();

        InterestPlayerController = PlayerLandlordController(InterestPawn.Controller);
        WaitTimeoutExpire = Level.TimeSeconds + WaitTimeout;
        LandlordClipboard = LandlordClipboardWeapon(InterestPlayerController.GetItem(class'SjoboMod.LandlordClipboardWeapon'));

        Focus = InterestPawn;
        HasGivenAttention = false;
	}

    function EndState()
	{
		Super.EndState();
        if(LandlordClipboard.Target == MyPawn){
            LandlordClipboard.Target = None;
            LandlordClipboard.SetClipboardState(0);
        }
        InterestPlayerController = None;
        InterestPawn = None;
        LandlordClipboard = None;
	}

Begin:
    Sleep(2.0 - MyPawn.Reactivity);
    if(WaitTimeoutExpire < Level.TimeSeconds || LandlordClipboard.Target != MyPawn || VSize(InterestPawn.Location - MyPawn.Location) > 300){
        NPC.SetMood(MOOD_Angry, 1.0);
        Sleep(Say(MyPawn.myDialog.lDefiant, true));
        if(MyNextState == 'None')
            SetNextState('Thinking');
    }else if(!HasGivenAttention){
        HasGivenAttention = true;
        Sleep(Say(MyPawn.myDialog.lGreeting, true));
        LandlordClipboard.TargetGivesAttention();
    }
    if(MyNextState == 'None')
        SetNextState('ReactToLandlordSpeaking');
    GoToNextState();
    
    
	

    // if(NPC.NPCHomeTag == ""){ // I have no home
    //     log("#### I have no home");
    //     // Consider renting an apartment
    //     if(Salary < 20){
    //         PrintDialogue("Can't afford one");
    //         if(HasBeenBotheredRegardingRenting){
    //             NPC.SetMood(MOOD_Angry, 1.0);
    //             Sleep(Say(MyPawn.myDialog.lDefiant, true));
    //         }else{
    //             Sleep(Say(MyPawn.myDialog.lDontAcceptDeal, true));
    //         }
    //         HasBeenBotheredRegardingRenting = true;
    //         GotoStateSave('Thinking');
    //     }else{
    //         PrintDialogue("Yes please, show me my apartment");
    //         // No idea
    //         Sleep(Say(MyPawn.myDialog.lYes, true));
    //         Focus = None;
    //         GotoStateSave('FollowLandlordToPotentialHousing');
    //     }
    // }else{ // I have a home

    // }
}

///////////////////////////////////////////////////////////////////////////////
// FollowLandlordToPotentialHousing - Invoked on Offer Housing action
///////////////////////////////////////////////////////////////////////////////
state FollowLandlordToPotentialHousing
{
    function BeginState()
	{
        
		PrintThisState();
		MyPawn.StopAcc();

        InterestPlayerController = PlayerLandlordController(InterestPawn.Controller);
        WaitTimeoutExpire = Level.TimeSeconds + WaitTimeout;
        LandlordClipboard = LandlordClipboardWeapon(InterestPlayerController.GetItem(class'SjoboMod.LandlordClipboardWeapon'));

        Focus = InterestPawn;
        HasGivenAttention = false;
	}

Begin:
    if(InterestPawn == None){
        GotoStateSave('Thinking');
    }else if(VSize(InterestPawn.Location - MyPawn.Location) > 300){
        EndGoal = InterestPawn;
        SetNextState('FollowLandlordToPotentialHousing');
        GotoStateSave('WalkToTarget');
    }else{
        if(!HasGivenAttention){
            HasGivenAttention = true;
            Sleep(Say(MyPawn.myDialog.lYes, true));
        }else if(WaitTimeoutExpire < Level.TimeSeconds || LandlordClipboard.Target != MyPawn){
            NPC.SetMood(MOOD_Angry, 1.0);
            Sleep(Say(MyPawn.myDialog.lDefiant, true));
            if(MyNextState == 'None')
                SetNextState('Thinking');
        }
    }

    if(MyNextState == 'None'){
        Sleep(2.0 - MyPawn.Reactivity);
        SetNextState('FollowLandlordToPotentialHousing');
    }
    GoToNextState();
}
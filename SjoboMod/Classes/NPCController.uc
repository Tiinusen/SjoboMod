//#############################################################################
// NPC Controller - Contains NPC controller logic
//#############################################################################
class NPCController extends NPCControllerBase;


//#############################################################################
// Properties
//#############################################################################
var bool HasBeenSetup, HasBeenBotheredRegardingRenting;
var bool IsBusy; // If true then it will prevent SMInterestPoints from fireing
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

///////////////////////////////////////////////////////////////////////////////
// SetHome - HomeNode.Tag for were the NPC now lives
///////////////////////////////////////////////////////////////////////////////
function SetHome(name tag)
{
    NPC.NPCHomeTag = tag;
}

///////////////////////////////////////////////////////////////////////////////
// SetWork - HomeNode.Tag for were the NPC now works
///////////////////////////////////////////////////////////////////////////////
function SetWork(name tag)
{
    NPC.NPCWorkTag = tag;
}

///////////////////////////////////////////////////////////////////////////////
// GoToHome - Makes NPC go to living quarter
///////////////////////////////////////////////////////////////////////////////
function GoToHome()
{
    NPC.HomeTag = NPC.NPCHomeTag;
    FindHomeList(NPC.HomeTag);
    NPC.bCanEnterHomes = true;
}

///////////////////////////////////////////////////////////////////////////////
// GoToWork - Makes NPC go to work
///////////////////////////////////////////////////////////////////////////////
function GoToWork()
{
    NPC.HomeTag = NPC.NPCWorkTag;
    FindHomeList(NPC.HomeTag);
    NPC.bCanEnterHomes = true;
}

///////////////////////////////////////////////////////////////////////////////
// GoForWalk - Makes NPC go for a walk
///////////////////////////////////////////////////////////////////////////////
function GoForWalk()
{
    NPC.HomeTag = '';
    NPC.bCanEnterHomes = false;
}


//#############################################################################
// Landlord Clipboard related functions
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// BeginStateClipboard - Invoked by EndState of all Clipboard related states
///////////////////////////////////////////////////////////////////////////////
function BeginStateClipboard()
{
    NPC.StopAcc();

    InterestPlayerController = PlayerLandlordController(InterestPawn.Controller);
    WaitTimeoutExpire = Level.TimeSeconds + WaitTimeout;
    LandlordClipboard = LandlordClipboardWeapon(InterestPlayerController.GetItem(class'SjoboMod.LandlordClipboardWeapon'));

    Focus = InterestPawn;
    HasGivenAttention = false;
    IsBusy = true;
}

///////////////////////////////////////////////////////////////////////////////
// EndStateClipboard - Invoked by BeginState of all Clipboard related states
///////////////////////////////////////////////////////////////////////////////
function EndStateClipboard()
{
    if(LandlordClipboard == None || LandlordClipboard.Target != NPC){
        return;
    }
    LandlordClipboard.Target = None;
    LandlordClipboard.SetClipboardState(LCB_NONE_SELECTED);
    InterestPlayerController = None;
    InterestPawn = None;
    LandlordClipboard = None;
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
        IsBusy = false;
        EndStateClipboard(); // To make sure to clear the clipboard vars in case NPC gets stuck on something
        Super.BeginState();
    }
}

//#############################################################################
// States - Invoked by Landlord Clipboard
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// ReactToLandlordSpeaking - Invoked on Select Dude action
///////////////////////////////////////////////////////////////////////////////
state ReactToLandlordSpeaking
{

	function BeginState()
	{
		BeginStateClipboard();
	}

    function EndState()
	{
		Super.EndState();
        if(IsUpcomingState('Thinking'))
            EndStateClipboard();
	}

Begin:
    Sleep(2.0 - NPC.Reactivity);
    if(NPC.GetMood() == MOOD_Angry || WaitTimeoutExpire < Level.TimeSeconds || LandlordClipboard.Target != NPC || VSize(InterestPawn.Location - NPC.Location) > 300){
        HasBeenBotheredRegardingRenting = true;
        NPC.SetMood(MOOD_Angry, 1.0);
        NPC.PlayTellOffAnim();
        Sleep(Say(NPC.myDialog.lDefiant, true));
        if(MyNextState == 'None')
            SetNextState('Thinking');
    }else if(!HasGivenAttention){
        HasGivenAttention = true;
        Sleep(Say(NPC.myDialog.lGreeting, true));
        LandlordClipboard.TargetGivesAttention();
    }
    if(MyNextState == 'None')
        SetNextState('ReactToLandlordSpeaking');
    GoToNextState();
    
    
	

   
}

///////////////////////////////////////////////////////////////////////////////
// FollowLandlordToPotentialHousing - Invoked on Offer Housing action
///////////////////////////////////////////////////////////////////////////////
state FollowLandlordToPotentialHousing
{
    function BeginState()
	{
		BeginStateClipboard();
	}

Begin:
    if(Salary < 20){
        if(HasBeenBotheredRegardingRenting){
            NPC.SetMood(MOOD_Angry, 1.0);
            NPC.PlayTellOffAnim();
            Sleep(Say(NPC.myDialog.lDefiant, true));
        }else{
            Sleep(Say(NPC.myDialog.lDontAcceptDeal, true));
        }
        HasBeenBotheredRegardingRenting = true;
        GotoStateSave('Thinking');
    }
    if(InterestPawn == None){
        log("Lost interest");
        SetNextState('Thinking');
    }else if(VSize(InterestPawn.Location - NPC.Location) > 300){
        SetEndGoal(InterestPawn, 70);
        SetNextState('FollowLandlordToPotentialHousing');
        GotoStateSave('WalkToTarget');
    }else{
        if(!HasGivenAttention){
            HasGivenAttention = true;
            Sleep(Say(NPC.myDialog.lYes, true));
        }else if(WaitTimeoutExpire < Level.TimeSeconds || LandlordClipboard.Target != NPC){
            HasBeenBotheredRegardingRenting = true;
            NPC.SetMood(MOOD_Angry, 1.0);
            NPC.PlayTellOffAnim();
            Sleep(Say(NPC.myDialog.lDefiant, true));
            if(MyNextState == 'None')
                SetNextState('Thinking');
        }
    }

    if(MyNextState == 'None'){
        Sleep(2.0 - NPC.Reactivity);
        SetNextState('FollowLandlordToPotentialHousing');
    }
    GoToNextState(true);
}

///////////////////////////////////////////////////////////////////////////////
// DecideOnHousing - Invoked on Show Housing action
///////////////////////////////////////////////////////////////////////////////
state DecideOnHousing
{

    function BeginState()
	{
		BeginStateClipboard();
	}

Begin:
    Sleep(2.0 - NPC.Reactivity); // Required if state is gonna loop itself, or else game crashes
    if(false){ // TODO: craete a fair way of denial
        Sleep(Say(NPC.myDialog.lDontAcceptDeal, true));
        GotoStateSave('FollowLandlordToPotentialHousing');
    }
    Sleep(Say(NPC.myDialog.lAcceptDeal, true));

    NPC.AnimBlendParams(15, 1.0, 0,0);
	NPC.PlayAnim('s_give', 1.0, 0.2, 15);
    LandlordClipboard.CauseAltFire();

    // Next state will be set by LandlordClipboardWeapon, so this is not a misstake (see Use Case in LandlordClipboardWeapon.uc (at the bottom))
}
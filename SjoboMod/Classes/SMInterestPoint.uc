//#############################################################################
// SMInterestPoint - Makes InterestPoint not bother busy NPCs
//#############################################################################
class SMInterestPoint extends InterestPoint;


///////////////////////////////////////////////////////////////////////////////
// CheckIntersted - Checks if NPC is busy and then no elsewise use normal logic
///////////////////////////////////////////////////////////////////////////////
function bool CheckInterested(Actor other){
    local NPCController npcController;
    npcController = NPCController(Pawn(other).Controller);
    if(npcController != None && npcController.IsBusy){
        return false;
    }
    return Super.CheckInterested(other);
}
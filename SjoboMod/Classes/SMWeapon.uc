class SMWeapon extends P2Weapon
	abstract;

//
// Gets target in front of weapon
//
function Actor GetTarget(float accuracy, float yOffset, float zOffset)
{
    local Vector hitNormal, startTrace, endTrace, X, Y, Z;
	local Actor other;
    
    GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	startTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, startTrace, 2*AimError);
	endTrace = startTrace + (yOffset + accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (zOffset + accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	endTrace += (TraceDist * X);
    
    other = Trace(LastHitLocation,hitNormal,endTrace,startTrace,true);
    return other;
}
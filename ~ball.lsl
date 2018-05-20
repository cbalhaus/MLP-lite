//
// MLP lite v3.0 for OpenSim
// Based on the original MLP - MULTI-LOVE-POSE V1.2 - Copyright (c) 2006, by Miffy Fluffy (BSD License)
// This code has bounced around the Second Life and OpenSim for over a decade, with various people working on it.
// MLP lite for OpenSim is almost a complete rewrite by onefang rejected.

key      Boss;
integer  Number;
integer  isBall;


default
{
    state_entry()
    {
        integer perm = llGetObjectPermMask(MASK_OWNER);

        if (0 == (perm & (PERM_COPY | PERM_MOVE | PERM_MODIFY)))
        {
            llOwnerSay("DANGER, CAN'T COPY, MODIFY, OR MOVE THIS OBJECT!");
            llSay(DEBUG_CHANNEL, "DANGER, CAN'T COPY, MODIFY, OR MOVE THIS OBJECT!");
        }
    }

    on_rez(integer num)
    {
        string objectName = llGetObjectName();

        isBall = ("~ball" == objectName);
        if (isBall)     // This is only coz OpenSim 8.2 doesn't know PRIM_SIT_TARGET.
            llSitTarget(<0.0, 0.0, -0.1>, ZERO_ROTATION);
        Boss = osGetRezzingObject();
        if (NULL_KEY != Boss)
        {
            Number = num;
            osMessageObject(Boss, "ALIVE|" + num);
            llSetTimerEvent(600.0);
        }
    }

    changed(integer change)
    {
        if ((CHANGED_LINK == change) && isBall)
            osMessageObject(Boss, "AVATAR|" + Number + "|" + (string) llAvatarOnSitTarget());
    }

    dataserver(key query_id, string str)
    {
        if (query_id == Boss)
        {
            if ("LIVE" == str)
                llSetTimerEvent(600.0);
            else if ("DIE" == str)
                llDie();
        }
    }

    timer()
    {   // not heard "LIVE" from ~MLP for a while: suicide
        llDie();
    }
}


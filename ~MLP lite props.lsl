//
// MLP lite v3.0 for OpenSim
// Based on the original MLP - MULTI-LOVE-POSE V1.2 - Copyright (c) 2006, by Miffy Fluffy (BSD License)
// This code has bounced around the Second Life and OpenSim for over a decade, with various people working on it.
// MLP lite for OpenSim is almost a complete rewrite by onefang rejected.

vector  RefPos;
rotation RefRot;

string Pose     = "";

list    Props;                  // List of props.
integer PROP_NAME       = 0;    // Name of prop, which should match a POSE name.
integer PROP_OBJECT     = 1;    // | separated names of props in inventory.
integer PROP_POSROT     = 2;    // | separated position and rotation pairs.
integer PROP_STRIDE     = 3;

list Balls;                     // Ball / prop tracker.
integer BALL_NUM        = 0;    // The number of the ball, negative numbers for the props.
integer BALL_KEY        = 1;    // The UUID of the ball / prop.
integer BALL_AVATAR     = 2;    // The UUID of any avatar sitting on the ball.
integer BALL_STRIDE     = 3;

string  LIST_SEP        = "$!#";    // Used to seperate lists when sending them as strings.

// The various link messages.  The first lot are historical.
//integer OLD_TOUCH     = -1;       // msg = "PRIMTOUCH"
integer OLD_POSEB       = 0;        // msg = "POSEB"                 id = pose name
//                                    // Also CHECK1 and CHECK2 instead of pose name.
integer OLD_STOP        = 1;        // msg = "STOP"
//integer OLD_REF         = 8;        // msg = RefPos                  id = RefRot
integer OLD_SITS        = -11000;   // msg = ball number|anim name   id = avatar key
integer OLD_STANDS      = -11001;   // msg = ball number             id = avatar key
integer OLD_ANIM        = -11002;   // msg = ball number|anim name   id = avatar key
//integer SEQ_CMD         = -12001;   // msg = ~sequencer command
integer OLD_CMD        = -12002;   // msg = menu command for ~MLP   id = user key

integer MLP_CMD         = -13001;   // A command that ~MLP dealt with, so other scripts can hook it.
integer TOOL_DATA       = -13002;   // Get Menus, Poses, Props, or Sounds list.
integer MLP_DATA        = -13003;   // Set Menus, Poses, Props, or Sounds list.
integer MLP_POSE        = -13004;   // doPose(pose, type);
integer MLP_UNKNOWN     = -13005;   // ~MLP doesn't know this command, might be for other scripts.

// Types for doPose(),
integer POSES_POSE      = -14001;   // Change pose, even if it's changing to the same pose.
integer POSES_SWAP      = -14002;   // Swap poses.
integer POSES_DUMP      = -14003;   // Dump or save poses.
integer POSES_Z         = -14004;   // Change height.


integer listFindString(list lst, string name, integer stride)
{
    integer f = llListFindList(lst, [name]);
    integer ix = f / stride;

    // Round to nearest stride.
    ix = ix * stride;

    // Sanity check, make sure we found a name, not something else, else do it the slow way.
    if ((-1 != f) && (ix != f))
    {
        integer l = llGetListLength(lst);
        integer i;

        f = -1;
        for (i = 0; i < l; i += stride)
        {
            if (llList2String(lst, i) == name)
            {
                f = i;
                i = l;
            }
        }
    }
    return f;
}

// Only used in one place, but leave it here for now.
string prStr(string str)
{
    integer ix = llSubStringIndex(str, ">");
    vector  p = ((vector) llGetSubString(str, 0, ix) - RefPos) / RefRot;
    vector  r = llRot2Euler((rotation) llGetSubString(str, ix + 1, -1) / RefRot) * RAD_TO_DEG;

    // OpenSim likes to swap these around, which triggers the ball movement saving.
    // Coz OpenSim doesn't support move events, so we gotta do things the hard way.
    if (-179.9 >= r.x)    r.x = 180.0;
    if (-179.9 >= r.y)    r.y = 180.0;
    if (-179.9 >= r.z)    r.z = 180.0;

    return "<" + round(p.x, 3) + "," + round(p.y, 3) + "," + round(p.z, 3) + 
        "><" + round(r.x, 1) + "," + round(r.y, 1) + "," + round(r.z, 1) + ">";
}

string round(float number, integer places)
{
    float shifted;
    integer rounded;
    string s;

    shifted = number * llPow(10.0, (float) places);
    rounded = llRound(shifted);
    s = (string) ((float) rounded / llPow(10.0, (float)places));
    rounded = llSubStringIndex(s, ".");
    if (-1 != rounded)
        s = llGetSubString(s, 0, llSubStringIndex(s, ".") + places);
    else
    {
        s += ".00000000";
        s = llGetSubString(s,0,llSubStringIndex(s, ".") + places);
    }
    return s;
}

integer findBall(integer num)
{
    integer f = llListFindList(Balls, [num]);
    integer ix = f / BALL_STRIDE;

    // Round to nearest stride.
    ix = ix * BALL_STRIDE;

    if ((-1 != f) && (ix == f))   // Sanity check, make sure we found a chan, not something else.
        return f;
    else
        return -1;
}

saveBall(integer num, key id, key avatar)
{
    integer f = findBall(num);

    if (-1 == f)
        Balls += [num, id, avatar];
    else
        Balls = llListReplaceList(Balls, [num, id, avatar], f, f + BALL_STRIDE - 1);
}

rezThing(string thing, string posRot, integer num)
{
    integer  i = llSubStringIndex(posRot, ">");

    llRezObject(thing,
    ((vector) llGetSubString(posRot, 0, i)) * RefRot + RefPos,
    ZERO_VECTOR,
    llEuler2Rot((vector) llGetSubString(posRot, i + 1, -1) * DEG_TO_RAD) * RefRot,
    num);
}

readProps(list propCards)
{
    integer i;
    integer l = llGetListLength(propCards);

    propCards = llListSort(propCards, 1, TRUE);
    for (i = 0; i < l; i++)
    {
        string card = llList2String(propCards, i);
        list crd = llParseStringKeepNulls(osGetNotecard(card), ["\n"], []);
        integer m = llGetListLength(crd);
        integer j;

        llOwnerSay("Reading '" + card + "'.");
        for (j = 0; j < m; j++)
        {
            string data = llList2String(crd, j);

            if (llGetSubString(data, 0, 0) != "/")
            {              // skip comments
                data = llStringTrim(data, STRING_TRIM);
                if ("" != data)
                {
                    // .PROPS is different from .POSITIONS, which is just inconsistant.
                    // There's an extra | at the beginning of the lines, for no apparent reason.
                    // The position and rotation has a "/" between them, and normally / is a comment.
                    // But we gotta stay compatible.  sigh
                    list props = llParseStringKeepNulls(data, ["|"], []);
                    string name  = llStringTrim(llList2String(props, 1), STRING_TRIM);
                    string prop = llStringTrim(llList2String(props, 2), STRING_TRIM);
                    list posrots = llParseString2List(llStringTrim(llList2String(props, 3), STRING_TRIM), ["/"], []);

                    saveProp(name, prop, llDumpList2String(posrots, ""));
                }
            }
        }
    }
}

integer findProp(string name)
{
    return listFindString(Props, name, PROP_STRIDE);
}

saveProp(string name, string prop, string posRot)
{
    integer f = findProp(name);

    if (-1 != f)
    {
        string t;

        t = llList2String(Props, f + PROP_OBJECT);
        if ("" != t)
            prop += "|" + prop;
        t = llList2String(Props, f + PROP_POSROT);
        if ("" != t)
            posRot += "|" + posRot;
        Props = llListReplaceList(Props, [name, prop, posRot], f, f + PROP_STRIDE - 1);
    }
    else
        Props += [name, prop, posRot];
}

// ball is either the ball number, or a POSES_* flag.
// ball on the other hand, is a negative integer for props.
doPose(string newPose, integer ball)
{
    integer f = findProp(Pose);
    integer p = findBall(ball);
    integer l = llGetListLength(Balls);
    integer i = 0;
    vector   newRefPos = llGetPos();
    rotation newRefRot = llGetRot();

    newRefPos.z += ((integer) llGetObjectDesc()) / 100.0;

    if (-1 != p)
    {
        i = p;
        l = p + BALL_STRIDE;
    }
    for (; i < l; i += BALL_STRIDE)
    {
        integer b0 = llList2Integer(Balls, i + BALL_NUM);
        integer isBall = (0 <= b0);

        if (isBall)
            ;
        else //if ((POSES_SWAP != ball)
        {
            if (-1 != f)
            {
                integer m = f + PROP_POSROT;
                string prOld = llList2String(Props, m);
                // Find out where the prop is now, and rotation.
                integer q = -1 - b0;
                string  bpr = prStr(llDumpList2String(
                    llGetObjectDetails(llList2Key(Balls, i + BALL_KEY), [OBJECT_POS, OBJECT_ROT]), ""));
                string result = llDumpList2String(llListReplaceList(llParseString2List(prOld, ["|"], []), [bpr], q, q), "|");
                // Actually store the props new position / rotation if it moved.
                if (result != prOld)
                {
                    llOwnerSay("  MOVEd prop " + q + ".\n\t old [" + prOld + "]\n\t new [" + result + "]");
                    Props = llListReplaceList(Props, [result], m, m);
                }
            }

            if ((POSES_DUMP != ball) && (POSES_SWAP != ball))
            {
                // Remove the prop.
                osMessageObject(llList2Key(Balls, i + BALL_KEY), "DIE");
                Balls = llListReplaceList(Balls, [], i, i + BALL_STRIDE - 1);
                i -= BALL_STRIDE;
                l -= BALL_STRIDE;
            }
        }
    }
    RefPos = newRefPos;
    RefRot = newRefRot;

    // Props are per pose, so deal with them here to.
    // Assumption - props don't MOVE when we change poses, they die, and get recreated when needed.
    // Note that the original MLP also assumed that props don't MOVE, though they send MOVE.
    if (POSES_POSE == ball)
    {
        p = findProp(newPose);
        if (-1 != p)
        {
            list o = llParseStringKeepNulls(llList2String(Props, p + PROP_OBJECT), ["|"], []);
            list q = llParseStringKeepNulls(llList2String(Props, p + PROP_POSROT), ["|"], []);

            l = llGetListLength(o);
            for (i = 0; i < l; i++)
                rezThing(llList2String(o, i), llList2String(q, i), -1 - i);
        }
    }
    Pose = newPose;
}


default
{
    link_message(integer from, integer num, string str, key id)
    {
        if (((0 == num) && ("POSEB" == str)) || ((1 == num) && ("STOP" == str)))
            ; // Old messages we can ignore.
        else if ((MLP_UNKNOWN == num) && ("LOADPROPS" == str))
        {
            float   then = llGetTime();
            float   now = 0.0;
            list    propCards  = []; // List of names of config cards.
            string  item;
            integer i = llGetInventoryNumber(INVENTORY_NOTECARD);
            integer PropCount;

            while (i-- > 0)
            {
                item = llGetInventoryName(INVENTORY_NOTECARD, i);
                if (llSubStringIndex(item, ".PROPS") == 0)
                    propCards += (list) item;
            }
            Props = [];
            readProps(propCards);
            PropCount = llGetListLength(Props) / PROP_STRIDE;
            if (0 < PropCount)
            {
                now = llGetTime();
                llOwnerSay("Loaded " + PropCount + " props in " + (string) (now - then) + " seconds.");
            }
        }
        else if (MLP_POSE == num)
        {
            if (NULL_KEY == id)
                id = Pose;
            doPose((string) id, (integer) str);
        }
        else if (TOOL_DATA == num)
        {
            if ("" == str)
            {
                if ("Props" == id)
                    llMessageLinked(from, num, LIST_SEP + llDumpList2String(Props, LIST_SEP), id);
            }
            else
            {
                if ("Props" == id)
                    Props = llParseStringKeepNulls(llGetSubString(str, llStringLength(LIST_SEP), -1), [LIST_SEP], []);
            }
        }
        else if ((OLD_CMD == num) || (MLP_CMD == num) || (MLP_UNKNOWN == num)
            || (OLD_SITS == num) || (OLD_STANDS == num) || (OLD_ANIM == num))
            ;
        else
            llOwnerSay(llGetScriptName() + " Unknown link message " + num + ", " + str);
    }

    dataserver(key queryId, string str)
    {
        list data = llParseString2List(str, ["|"], []);

        if ("ALIVE" == llList2String(data, 0))
            saveBall(llList2Integer(data, 1), queryId, NULL_KEY);
    }
}

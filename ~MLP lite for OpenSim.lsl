//
// MLP lite v3.0 for OpenSim
// Based on the original MLP - MULTI-LOVE-POSE V1.2 - Copyright (c) 2006, by Miffy Fluffy (BSD License)
// This code has bounced around the Second Life and OpenSim for over a decade, with various people working on it.
// MLP lite for OpenSim is almost a complete rewrite by onefang rejected.

string  Version = "MLP lite v3.0 alpha";

list COLOUR_NAMES =
[
    "HIDE", "PINK", "BLUE", "PINK2",
    "BLUE2", "GREEN", "MAGENTA", "RED",
    "ORANGE", "WHITE", "BLACK", "YELLOW",
    "CYAN", "RED2", "TEAL", "GREEN2"
];

list COLOURS = 
[
    <0.0,0.0,0.0>,          // 0 = HIDE
    <0.835,0.345,0.482>,    // 1 = PINK
    <0.353,0.518,0.827>,    // 2 = BLUE
    <0.635,0.145,0.282>,    // 3 = PINK2 - Dark pink
    <0.153,0.318,0.627>,    // 4 = BLUE2 - Dark blue
    <0.128,0.500,0.128>,    // 5 = GREEN
    <1.000,0.000,1.000>,    // 6 = MAGENTA
    <1.000,0.000,0.000>,    // 7 = RED
    <1.000,0.500,0.000>,    // 8 = ORANGE
    <1.000,1.000,1.000>,    // 9 = WHITE
    <0.0,0.0,0.0>,          // 10 = BLACK
    <1.0,1.0,0.0>,          // 11 = YELLOW
    <0.0,0.8,0.8>,          // 12 = CYAN
    <0.5,0.0,0.0>,          // 13 = RED2
    <0.0,0.5,0.5>,          // 14 = TEAL
    <0.0,0.25,0.25>         // 15 = GREEN2
];

list EXPRESSIONS =
[
    "",
    "express_open_mouth",
    "express_surprise_emote",
    "express_tongue_out",
    "express_smile",
    "express_toothsmile",
    "express_wink_emote",
    "express_cry_emote",
    "express_kiss",
    "express_laugh_emote",
    "express_disdain",
    "express_repulsed_emote",
    "express_anger_emote",
    "express_bored_emote",
    "express_sad_emote",
    "express_embarrassed_emote",
    "express_frown",
    "express_shrug_emote",
    "express_afraid_emote",
    "express_worry_emote",
    "SLEEP"
];

key     Owner;
integer Channel;
integer Chat                = TRUE;
integer Redo                = TRUE;
integer ReloadOnRez         = TRUE;


integer LoadMenu        = TRUE;
list ToMenus = [];
list SeenMenus = [];
key User0;
integer People = 0;
integer MenuUsers   = 0;
string CurrentMenu      = "";
integer ThisSwap;
string Filter       = "123456789";
string LastFilter   = "123456789";
// NOTE - This one uses \n to separate sub lists, coz | is used in some of the commands.
list Menus;                     // List of menus.
integer MENU_NAME       = 0;    // Name of menu.
integer MENU_AUTH       = 1;    // Authorised users of menu - 0 = owner, 1 = group, 2 = all
integer MENU_COLOURS    = 2;    // \n spearated list of ball colours.
integer MENU_ENTRIES    = 3;    // \n separated list of entries.
integer MENU_CMDS       = 4;    // \n separated list of commands, matching the entries.
integer MENU_SWAPS      = 5;    // \n separated list of colour sets.
integer MENU_STRIDE     = 6;

integer LoadPos         = TRUE;
vector  RefPos;
rotation RefRot;
string Pose     = "";
list    Poses;                  // List of poses.
integer POSE_NAME       = 0;    // Name of pose.
integer POSE_ANIM       = 1;    // | separated animations.
integer POSE_EMOTE      = 2;    // | separated emotions and timers list.
integer POSE_POSROT     = 3;    // | separated posiiton and rotation pairs.
integer POSE_STRIDE     = 4; 

integer Lag             = 45;   // Assume we start with no lag.
float   Tick            = 0.2;  // Shortest tick for expressions.
list Exps;            // List of current expressions playing on avatars.
integer EXP_AVATAR      = 0;    // Avatar to do expression on.
integer EXP_EXP         = 1;    // Name of expression.
integer EXP_TIME        = 2;    // Time for expression loop.
integer EXP_NEXT        = 3;    // Time for next trigger.
integer EXP_STRIDE      = 4;

integer LoadProp        = TRUE;

list Musers;                    // List of menu users.
integer MUSER_AVATAR    = 0;    // Key of user.
integer MUSER_CURRENT   = 1;    // Current menu of user.
integer MUSER_STACK     = 2;    // | separated menu stack list.
integer MUSER_STRIDE    = 3;

integer MaxBalls        = 1;    // One as a bare minimum, for a single person.  No point if there are zero balls.
integer BallCount;
integer Adjusting;
list Balls;                     // Ball / prop tracker.
integer BALL_NUM        = 0;    // The number of the ball, negative numbers for the props.
integer BALL_KEY        = 1;    // The UUID of the ball / prop.
integer BALL_AVATAR     = 2;    // The UUID of any avatar sitting on the ball.
integer BALL_STRIDE     = 3;

list Sounds;
integer SOUND_NAME      = 0;
integer SOUND_INV       = 1;
integer SOUND_STRIDE    = 2;

// TODO - Should stride this to.
list LMButtons;
list LMParms;

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

integer listFindWord(list lst, string s)
{
    integer l = llGetListLength(lst);
    integer i;

    for (i = 0; i < l; i++)
    {
        list w = llParseStringKeepNulls(llList2String(lst, i), [" "], []);

        if (-1 != llListFindList(w, s))
            return TRUE;
    }
    return FALSE;
}

say(string str)
{
    if (Chat)
    {
        if (MenuUsers) llWhisper(0, str);
        else llOwnerSay(str);
    }
}

// Only used in one place, but leave it here for now.
string prStr(string str)
{
    integer ix = llSubStringIndex(str, ">");
    vector  p = ((vector) llGetSubString(str, 0, ix) - RefPos) / RefRot;
    vector  r = llRot2Euler((rotation) llGetSubString(str, ix + 1, -1) / RefRot) * RAD_TO_DEG;

    // OpenSim likes to swap these around, which triggers the ball movement saving.
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

setRunning(integer st)
{
    integer i = llGetInventoryNumber(INVENTORY_SCRIPT);

    while (i-- > 0)
    {
        string s = llGetInventoryName(INVENTORY_SCRIPT, i);

        if ((llSubStringIndex(s, "~MLP lite ") == 0) && (llGetScriptName() != s))
        {
            llSetScriptState(s, st);
            if (st)
                llResetOtherScript(s);
        }
    }
    if (st)
        llSetTimerEvent(120.0);
    CurrentMenu = "";
    doPose("", POSES_POSE, TRUE);
}

stop()
{
    llMessageLinked(LINK_SET, OLD_STOP, "STOP", NULL_KEY);
    Adjusting = FALSE;
    CurrentMenu = "";
    doPose("", POSES_POSE, TRUE);
    Balls = [];
    Exps= [];
}

readMenu(list cards)
{
    integer i;
    integer l = llGetListLength(cards);

    cards = llListSort(cards, 1, TRUE);
    for (i = 0; i < l; i++)
    {
        string menu = "";
        string card = llList2String(cards, i);
        list crd = llParseStringKeepNulls(osGetNotecard(card), ["\n"], []);
        integer m = llGetListLength(crd);
        integer j;
        integer k;

        llOwnerSay("Reading '" + card + "'.");
        for (j = 0; j < m; j++)
        {
            string data = llList2String(crd, j);
            string filter = "";
            integer ix = llSubStringIndex(data, "/");  // remove comments

            if (ix != -1)
            {
                if (ix == 0) data = "";
                else         data = llGetSubString(data, 0, ix - 1);
            }
            data = llStringTrim(data, STRING_TRIM);
            if (data != "")
            {
                string cmd = data;
                string mdata = data;

                ix = llSubStringIndex(data, " ");
                if (ix != -1)
                {
                    cmd = llStringTrim(llGetSubString(data, 0, ix - 1), STRING_TRIM);
                    data = llStringTrim(llGetSubString(data, ix + 1, -1), STRING_TRIM);
                    mdata = data;
                }
                else
                    mdata = "";

                string mcmd = cmd;
                list ldata = llParseStringKeepNulls(data, ["|"], []);

                ix = llGetListLength(ldata);
                for (k = 0; k < ix; k++)
                    ldata = llListReplaceList(ldata, [llStringTrim(llList2String(ldata, k), STRING_TRIM)], k, k);
                data = llDumpList2String(ldata, "|");

                string arg1 = llList2String(ldata, 0);

                if (cmd == "MENU")
                {
                    integer auth;
                    string colours = "";

                    menu = arg1;
                    if (llList2String(ldata, 1) == "GROUP") auth = 1;
                    else if (llList2String(ldata, 1) != "OWNER") auth = 2;
                    for (k = 0; k < 9; ++k)    // Maximum of 9 balls supported.
                    {
                        string bc = llList2String(ldata, k + 2);

                        if ("" != bc)
                        {
                            colours += "\n" + bc;
                            if ((k + 1) > MaxBalls)
                                MaxBalls = k + 1;
                        }
                    }
                    saveMenu(menu, auth, colours, "", "", "");
                    ToMenus += [menu];
                }
                else if (cmd == "NORELOAD")
                    ReloadOnRez = (arg1 != "0");
                else
                {    // The rest are entries within a menu.
                    if (cmd == "POSE") 
                    {
                        string thisPose = llStringTrim(llList2String(ldata, 0), STRING_TRIM);
                        string anims = "";
                        string exps = "";

                        ix = llGetListLength(ldata);
                        for (k = 1; k < ix; k++)
                        {
                            string anim = llList2String(ldata, k);
                            string  exp;
                            float   expTime;

                            if (anim == "") anim = "sit_ground";

                            if (llGetSubString(anim, -1, -1) == "*")
                            {
                                exp = llList2String(EXPRESSIONS, 1);
                                expTime = 0.5;
                                anim = llGetSubString(anim, 0, -2);
                            }
                            else
                            {
                                integer a = llSubStringIndex(anim, "::");

                                if (a == -1)
                                {
                                    exp = "";
                                    expTime = 0.5;
                                }
                                else
                                {
                                    list parms = llParseString2List(anim, ["::"], []);
                                    integer p = (integer) llList2String(parms, 1);

                                    anim = llList2String(parms, 0);
                                    exp = llList2String(EXPRESSIONS, p);
                                    expTime  = (float) llList2String(parms, 2);

                                    if (expTime <= 0.0)
                                        expTime = 0.5;
                                }
                            }
                            anims  += "|" + anim;
                            exps   += "|" + exp + "::" + (string) expTime;
                        }
                        anims   = llGetSubString(anims, 1, -1);
                        exps    = llGetSubString(exps,  1, -1);
                        savePose(thisPose, anims, exps, "");
                        mcmd = "POSE";
                        mdata = thisPose;
                    }
                    else if (cmd == "CHAT")
                    {
                        if (llList2String(ldata, 1) != "OFF")
                            Chat = 1;
                    }
                    else if (cmd == "MENUUSERS")
                    {
                        if (llList2String(ldata, 1) == "GROUP")
                            MenuUsers = 1;
                        else if (llList2String(ldata, 1) != "OWNER")
                            MenuUsers = 2;
                    }
                    else if (cmd == "LINKMSG")
                    {
                        LMButtons += arg1;
                        LMParms += llList2String(ldata, 1);
                    }
                    else if (cmd == "SOUND")
                        Sounds += [arg1, llList2String(ldata, 1)];
                    else if (cmd == "SWAP")
                    {
                        list sl = llListReplaceList(ldata, [], 0, 0);

                        if ("" == arg1)
                            arg1 = "SWAP";
                        if ("SWAP" == data)
                            sl = ["21"];
                        ix = llGetListLength(sl);
                        if (ix == 0)
                        {
                            sl = ["21"];
                            ix = 1;
                        }

                        for (k = 0; k < ix; k++)
                        {
                            string s = llList2String(sl, k);
                            integer ls = llStringLength(s);

                            s += llGetSubString("213456789", ls, -1);
                            sl = llListReplaceList(sl, [s], k, k);
                        }
                        if (ix)
                            filter = llDumpList2String(sl, "\n");
                    }
                    else if (cmd == "TOMENU")
                    {
                        if ("-" != arg1)
                            SeenMenus += [arg1];
                    }
                    ix = findMenu(menu);
                    if ((-1 != ix) && ("-" != arg1))
                    {
                        saveMenu(menu, 
                            llList2Integer(Menus, ix + MENU_AUTH),
                            "",
                            llList2String(Menus, ix + MENU_ENTRIES) + "\n" + arg1,
                            llList2String(Menus, ix + MENU_CMDS)    + "\n" + mcmd + " " + mdata,
                            filter);
                    }
                }
            }
        }
    }
}

integer findMenu(string name)
{
    return listFindString(Menus, name, MENU_STRIDE);
}

saveMenu(string name, integer auth, string colours, string entries, string commands, string swaps)
{
    integer f = findMenu(name);

    if ("\n" == llGetSubString(colours, 0, 0))
        colours = llGetSubString(colours, 1, -1);
    if ("\n" == llGetSubString(entries, 0, 0))
        entries = llGetSubString(entries, 1, -1);
    if ("\n" == llGetSubString(commands, 0, 0))
        commands = llGetSubString(commands, 1, -1);
    if ("\n" == llGetSubString(swaps, 0, 0))
        swaps = llGetSubString(swaps, 1, -1);
    if (-1 == f)
        Menus += [name, auth, colours, entries, commands, swaps];
    else
    {
        if ("" == colours)
            colours = llList2String(Menus, f + MENU_COLOURS);
        if ("" == entries)
            entries = llList2String(Menus, f + MENU_ENTRIES);
        if ("" == commands)
            commands = llList2String(Menus, f + MENU_CMDS);
        if ("" == swaps)
            swaps = llList2String(Menus, f + MENU_SWAPS);
        Menus = llListReplaceList(Menus, [name, auth, colours, entries, commands, swaps], f, f + MENU_STRIDE - 1);
    }
}

vector getBallColour(integer b)
{
    integer f = findMenu(CurrentMenu);

    if (-1 != f)
        return llList2Vector(COLOURS, llListFindList(COLOUR_NAMES, 
            llList2String(llParseStringKeepNulls(llList2String(Menus, f + MENU_COLOURS), ["\n"], []), b)));
    return <1.0, 1.0, 1.0>;
}

unauth(key id, string button, string who)
{
    llDialog(id, "\n" + button + " menu allowed only for " + who, ["OK"], -1);
}

touched(key avatar)
{
    if (avatar == Owner || (MenuUsers == 1 && llSameGroup(avatar)) || MenuUsers == 2)
    {
        saveMuser(avatar, llList2String(Menus, 0 + MENU_NAME), "");
        doMenu(avatar);
    }
}

doMenu(key id)
{
    integer f = listFindString(Musers, id, MUSER_STRIDE);

    if (-1 != f)
    {
        string menu = llList2String(Musers, f + MUSER_CURRENT);
        integer m = findMenu(menu);

        if (-1 != m)
        {
            integer i = llList2Integer(Menus, m + MENU_AUTH);

            if (i > MenuUsers)
                i = MenuUsers;
            if (id == Owner || (i == 1 && llSameGroup(id)) || i == 2)
            {
                list entries = llParseStringKeepNulls(llList2String(Menus, m + MENU_ENTRIES), ["\n"], []);
                list    cmds = llParseStringKeepNulls(llList2String(Menus, m + MENU_CMDS),    ["\n"], []);
                string title = menu;

                if ((0 == m) || listFindWord(cmds, "POSE"))
                {
                    if ("" != Pose)
                    {
                        if (menu == CurrentMenu)
                            title += "\nCurrent pose is " + Pose;
                        else
                            title += "\nCurrent pose is " + Pose + " in menu " + CurrentMenu;
                    }
                    if ("123456789" != Filter)
                        title += "\nPositions are swapped.";
                }
                if (listFindWord(cmds, "ADJUST"))
                {
                    title += "\nAdjusting is o";
                    if (Adjusting)  title += "n.";  else title += "ff.";
                }
                if (listFindWord(cmds, "CHAT"))
                {
                    title += "\nChat is o";
                    if (Chat)  title += "n.";  else title += "ff.";
                }
                if (listFindWord(cmds, "MENUUSERS"))
                {
                    title += "\nMenu users are ";
                    if (0 == MenuUsers)
                        title += "OWNER.";
                    if (1 == MenuUsers)
                        title += "GROUP.";
                    if (2 == MenuUsers)
                        title += "ALL.";
                }
                llDialog(id, Version + "\n\n" + title,
                      llList2List(entries, -3, -1)
                    + llList2List(entries, -6, -4)
                    + llList2List(entries, -9, -7)
                    + llList2List(entries, -12, -10),
                    Channel);
            }
            else
            {
                if (i == 1) unauth(id, menu, "group");
                else        unauth(id, menu, "owner");
            }
        }
        else
            llSay(0, "'" + menu + "' menu not found!");
    }
}

readPos(list cards)
{
    integer i;
    integer l = llGetListLength(cards);

    cards = llListSort(cards, 1, TRUE);
    for (i = 0; i < l; i++)
    {
        string card = llList2String(cards, i);
        list crd = llParseStringKeepNulls(osGetNotecard(card), ["\n"], []);
        integer m = llGetListLength(crd);
        integer j;

        llOwnerSay("Reading '" + card + "'.");
        for (j = 0; j < m; j++)
        {
            string data = llList2String(crd, j);

            if (llGetSubString(data, 0, 0) != "/")
            {    // skip comments
                data = llStringTrim(data, STRING_TRIM);
                integer ix = llSubStringIndex(data, "{");
                integer jx = llSubStringIndex(data, "} <");

                if (ix != -1 && jx != -1)
                {
                    string name  = llStringTrim(llGetSubString(data, ix + 1, jx - 1), STRING_TRIM);
                    string ldata = llGetSubString(data, jx + 2, -1);
                    list posrots = llParseString2List(ldata, ["<"], []);
                    string pr = "";

                    jx = llGetListLength(posrots);
                    for (ix = 0; ix < jx; ix += 2)
                        pr += "|<" + llStringTrim(llList2String(posrots, ix), STRING_TRIM) + "<"
                                   + llStringTrim(llList2String(posrots, ix + 1), STRING_TRIM);
                    savePose(name, "", "", llGetSubString(pr, 1, -1));
                }
            }
        }
    }
}

integer findPose(string name)
{
    return listFindString(Poses, name, POSE_STRIDE);
}

savePose(string name, string anim, string exp, string posRot)
{
    integer f = findPose(name);

    if (-1 != f)
    {
        if ("" == anim)
        {
            anim = llList2String(Poses, f + POSE_ANIM);
            exp = llList2String(Poses, f + POSE_EMOTE);
        }
        else if ("" == posRot)
            posRot = llList2String(Poses, f + POSE_POSROT);
        Poses = llListReplaceList(Poses, [name, anim, exp, posRot], f, f + POSE_STRIDE - 1);
    }
    else
        Poses += [name, anim, exp, posRot];
}

stopAnims(key avatar)
{
    if (NULL_KEY != avatar)
    {
        list anims = llGetAnimationList(avatar);
        integer l = llGetListLength(anims);
        integer i;

        for (i = 0; i < l; i++)
        {
            string anim = llList2String(anims, i);

            if (anim != "")
                osAvatarStopAnimation(avatar, anim);
        }
    }
}

checkTicks()
{
    if (llGetListLength(Exps))
    {
        float dil = llGetRegionTimeDilation();  // Between 0 and 1.
        float fps = llGetRegionFPS();           // Frames per second, up to 50.
        integer newLag = (integer) (dil * fps);

        if (llAbs(Lag - newLag) > 9)
        {
            if (45 <= newLag)       // none
                Tick = 0.2;
            else if (35 <= newLag)  // little
                Tick = 0.3;
            else if (25 <= newLag)  // medium
                Tick = 0.5;
            else if (15 <= newLag)  // lots
                Tick = 0.7;
            else                    // way too much
                Tick = 1.0;
            Lag = newLag;
        }
        llSetTimerEvent(Tick);
    }
    else    // There's no expressions running, so just use the "anyone there" timer.
        llSetTimerEvent(120.0);
}

string filterIt(string an)
{
    list anl = llParseStringKeepNulls(an, ["|"], []);
    integer l = llGetListLength(anl);
    integer lf = llStringLength(Filter);
    integer i;
    string anr = "";

    for (i = 0; i < l; i++)
    {
        if (0 != i)
            anr += "|";
        anr += llList2String(anl, ((integer) llGetSubString(Filter, i, i)) - 1);
    }

    return anr;
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

// ball is either the ball number, or a POSES_* flag.
doPose(string newPose, integer ball, integer pass)
{
    list anl;
    list eml;
    list prl;
    integer p = findPose(newPose);
    integer l = llGetListLength(Balls);
    integer i;
    vector   newRefPos = llGetPos();
    rotation newRefRot = llGetRot();

    // A little bit inefficient, but keeps things a little simpler.
    // Most of the time we pass this through a link message, so other scripts can know about it.
    // The one time we don't is when we get that link message.
    if (pass)
    {
        llMessageLinked(LINK_SET, MLP_POSE, (string) ball, newPose);
        if ("" != newPose)  // Deal with it anyway if it's the stop pose, otherwise that wont happen.
            return;
    }
    llMessageLinked(LINK_SET, OLD_POSEB, "POSEB", newPose);
    // The prStr() call below needs to use the old RefPos.
    newRefPos.z += ((integer) llGetObjectDesc()) / 100.0;
    if (-1 != p)
    {
        if ((POSES_POSE == ball) || (POSES_SWAP == ball) || (0 <= ball))
        {
            if ("123456789" == Filter)
                say("The pose is now '" + newPose + "'.");
            else
                say("The pose is now '" + newPose + "' swapped.");
        }
        // Filter the data to current SWAP.
        anl = llParseStringKeepNulls(filterIt(llList2String(Poses, p + POSE_ANIM)), ["|"], []);
        eml = llParseStringKeepNulls(filterIt(llList2String(Poses, p + POSE_EMOTE)), ["|"], []);
        prl = llParseStringKeepNulls(filterIt(llList2String(Poses, p + POSE_POSROT)), ["|"], []);
    }

    Exps = [];
    i = 0;
    if (0 <= ball)    // A single ball, for when someone sits on it.
    {
        i = findBall(ball);
        l = i + BALL_STRIDE;
    }
    for (; i < l; i += BALL_STRIDE)
    {
        integer b0 = llList2Integer(Balls, i + BALL_NUM);
        integer isBall = (0 <= b0);
        key     k  = llList2Key(Balls, i + BALL_KEY);
        key     a = llList2Key(Balls, i + BALL_AVATAR);
        // Find out where the ball / prop is now, and rotation.
        string  bpr = prStr(llDumpList2String(llGetObjectDetails(k, [OBJECT_POS, OBJECT_ROT]), ""));

        if (isBall)    // Props are handled in their own script.
        {
            integer b1 = ((integer) llGetSubString(LastFilter, b0, b0)) - 1;
            integer b2 = ((integer) llGetSubString(    Filter, b0, b0)) - 1;

            if ((POSES_POSE == ball) || (POSES_SWAP == ball) || (0 <= ball))
                stopAnims(a);
            if (-1 != p)
            {
                string prn = llList2String(llParseStringKeepNulls(llList2String(Poses, p + POSE_POSROT), ["|"], []), b2);
                integer ix = llSubStringIndex(prn, ">");

                if (0 > ball)
                {
                    // Deal with ball movements.
                    integer g = llListFindList(Poses, Pose);
                    integer m = g + POSE_POSROT;
                    string prOld = llList2String(Poses, m);
                    list nprl = llParseString2List(prOld, ["|"], []);
                    string result = llDumpList2String(llListReplaceList(nprl, [bpr], b1, b1), "|");

                    // Actually store the balls new position / rotation if it moved.
                    if (result != prOld)
                    {
                        llOwnerSay("  MOVEd ball " + b1 + ".\n\t old [" + prOld + "]\n\t new [" + result + "]");
                        Poses = llListReplaceList(Poses, [result], m, m);
                    }
                }

                // Deal with animations and expressions.
                if ((POSES_POSE == ball) || (POSES_SWAP == ball) || (0 <= ball))
                {
                    list e = llParseStringKeepNulls(llList2String(eml, b0), ["::"], []);

                    if (NULL_KEY != a)
                    {
                        string ani = llList2String(anl, b0);

                        llMessageLinked(LINK_SET, OLD_ANIM, "" + i + "|" + newPose, a);
                        osAvatarPlayAnimation(a, ani);
                        if (llGetListLength(e))
                        {
                            string exp = llList2String(e, 0);

                            if ("" != exp)
                                Exps += [a, exp, llList2Float(e, 1), 0.0];
                        }
                    }
                }
                // Move the ball.
                if (POSES_DUMP != ball)
                {
                    if (ix != -1)
                    {
                        vector   pos = ((vector) llGetSubString(prn, 0, ix)) * newRefRot + newRefPos;
                        rotation rot = llEuler2Rot((vector) llGetSubString(prn, ix + 1, -1) * DEG_TO_RAD) * newRefRot;

                        osSetPrimitiveParams(k, [PRIM_POSITION, pos, PRIM_ROTATION, rot]);
                    }
                }
            }
        }
    }
    // The rezThing() call below needs the new position.
    RefPos = newRefPos;
    RefRot = newRefRot;
    checkTicks();

    // Delete / create balls as needed.
    if ((POSES_POSE == ball) || (0 <= ball))
    {
        i = 0;
        p = findMenu(CurrentMenu);
        if (-1 != p)
            i = llGetListLength(llParseStringKeepNulls(llList2String(Menus, p + MENU_COLOURS), ["\n"], []));
        if (BallCount != i)
        {
            while (BallCount > i)
            {
                --BallCount;
                stopAnims(llList2Key(Balls, BallCount + BALL_AVATAR));
                setBall(BallCount, "DIE");
                p = findBall(BallCount);
                if (-1 != p)
                    Balls = llListReplaceList(Balls, [], p, p + BALL_STRIDE - 1);
            }

            while (BallCount < i)
            {
                rezThing("~ball", llList2String(prl, BallCount), BallCount);
                BallCount++;
            }
        }
    }
    Pose = newPose;
    LastFilter = Filter;
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

integer findBallByID(key id)
{
    integer f = llListFindList(Balls, [id]);
    integer ix = f / BALL_STRIDE;

    // Round to nearest stride.
    ix = ix * BALL_STRIDE;

    if ((-1 != f) && ((ix + BALL_KEY) == f))   // Sanity check, make sure we found a UUID, not something else.
        return f - BALL_KEY;
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

key getBall(integer num)
{
    integer f = findBall(num);

    if (-1 != f)
        return llList2Key(Balls, f + BALL_KEY);
    else
        return NULL_KEY;
}

setBall(integer num, string cmd)
{
    key k = getBall(num);

    if (NULL_KEY != k)
        osMessageObject(k, cmd);
    else
        llOwnerSay("Missed ball command - " + cmd);
}

setBalls(string cmd)
{
    integer i;

    for (i = 0; i < BallCount; ++i)
        setBall(i, cmd);
}

saveMuser(key avatar, string current, string stack)
{
    integer f = listFindString(Musers, avatar, MUSER_STRIDE);

    if (-1 == f)
        Musers += [avatar, current, stack];
    else
        Musers = llListReplaceList(Musers, [avatar, current, stack], f, f + MUSER_STRIDE - 1);
}

// return TRUE if caller should doMenu()
integer handleCmd(key id, string button, integer isMenu)
{
    string cmd = button;
    string data = cmd;
    string menu = CurrentMenu;
    list lst;
    integer m;
    integer f;
    integer i;

    if (isMenu)
    {
        f = listFindString(Musers, id, MUSER_STRIDE);
        if (-1 != f)
        {
            menu = llList2String(Musers, f + MUSER_CURRENT);
            m = findMenu(menu);  // This was already checked before it was stuffed into Musers.
            lst = llParseStringKeepNulls(llList2String(Menus, m + MENU_CMDS), ["\n"], []);
            i = llListFindList(llParseStringKeepNulls(llList2String(Menus, m + MENU_ENTRIES), ["\n"], []), [button]);
            data = llList2String(lst, i);
            cmd = data;

            i = llList2Integer(Menus, m + MENU_AUTH);
            if (i > MenuUsers)
                i = MenuUsers;
            if (!(id == Owner || (i == 1 && llSameGroup(id)) || i == 2))
                return FALSE;
        }
    }

    i = llSubStringIndex(data, " ");
    if (-1 != i)
    {
        cmd = llGetSubString(data, 0, i - 1);
        data = llStringTrim(llGetSubString(data, i + 1, -1), STRING_TRIM);
    }
    else
        data = "";

    if ("POSE" == cmd)
    {
        if (isMenu)  CurrentMenu = menu;
        doPose(data, POSES_POSE, TRUE);
    }
    else if ("TOMENU" == cmd)
    {
        if ("" == data)
        {
            i = m;
            m = TRUE;
        }
        else
        {
            i = findMenu(data);
            m = FALSE;
        }
        if (-1 != i)
        {
            if (isMenu)
                saveMuser(id, data, menu + "|" + llList2String(Musers, f + MUSER_STACK));
            else
            {
                if (m)
                {
                    if (Redo) doMenu(id);
                }
                else
                    CurrentMenu = data;
            }
        }
    }
    else if (("BACK" == cmd) && isMenu)
    {
        lst = llParseStringKeepNulls(llList2String(Musers, f + MUSER_STACK), ["|"], []);
        saveMuser(id, llList2String(lst, 0), llDumpList2String(llDeleteSubList(lst, 0, 0), "|"));
    }
    else if ("SWAP" == cmd)
    {
        data = llList2String(Menus, m + MENU_SWAPS);
        if ((menu == CurrentMenu) || (llList2String(Menus, findMenu(CurrentMenu) + MENU_SWAPS) == data))
        {
            // The first one is always the normal order, so users don't set that in .MENUITEM cards.
            list swaps = ["123456789"] + llParseStringKeepNulls(data, ["\n"], []);

            ++ThisSwap;
            if (llGetListLength(swaps) <= ThisSwap)
                ThisSwap = 0;
            LastFilter = Filter;
            Filter = llList2String(swaps, ThisSwap);
            doPose(Pose, POSES_SWAP, TRUE);
        }
        else
            llSay(0, "The current pose is from another menu with a different SWAP command, cant swap.");
    }
    else if ("ADJUST" == cmd)
    {
        Adjusting = ! Adjusting;
        f = llGetListLength(Balls);

        for (i = 0; i < f; i += BALL_STRIDE)
        {
            integer b = llList2Integer(Balls, i + BALL_NUM);
            integer isBall = (0 <= b);
            key     k = llList2Key(Balls, i + BALL_KEY);
            key     a = llList2Key(Balls, i + BALL_AVATAR);
            vector  c = getBallColour(b);

            if (Adjusting)
            {
                if (NULL_KEY == a)
                    osSetPrimitiveParams(k, [PRIM_COLOR, ALL_SIDES, c, 1.0,
                        PRIM_SIZE, <0.2, 0.2, 0.2>, PRIM_TEXT, "Adjust", <1.0, 1.0, 1.0>, 1.0]);
                else
                    osSetPrimitiveParams(k, [PRIM_COLOR, ALL_SIDES, c, 0.15,
                        PRIM_SIZE, <0.1, 0.1, 5.0>, PRIM_TEXT, "Adjust", <1.0, 1.0, 1.0>, 1.0]);
            }
            else
            {
                if (NULL_KEY == a)
                    osSetPrimitiveParams(k, [PRIM_COLOR, ALL_SIDES, c, 1.0,
                        PRIM_SIZE, <0.2, 0.2, 0.2>, PRIM_TEXT, "Love", <1.0, 1.0, 1.0>, 1.0]);
                else
                    osSetPrimitiveParams(k, [PRIM_COLOR, ALL_SIDES, c, 0.0,
                        PRIM_SIZE, <0.01, 0.01, 0.01>, PRIM_TEXT, "", <1.0, 1.0, 1.0>, 1.0]);
            }
        }
    }
    else if ("CHAT" == cmd)
    {
        Chat = !Chat;
        if (Chat) llSay(0, button + " ON"); else llSay(0, button + " OFF");
    }
    else if ("MENUUSERS" == cmd)
    {
        MenuUsers++;
        if (3 <= MenuUsers)  MenuUsers = 0;
        say(button + llList2String(["OWNER", "GROUP", "ALL"], MenuUsers) + " can use the menus.");
    }
    else if ("LINKMSG" == cmd)
    {   // Send LM to a non-MLP script.
        i = llListFindList(LMButtons, [button]);
        if (i != -1)
        {
            lst = llCSV2List(llList2String(LMParms, i));
            llMessageLinked(
                llList2Integer(lst, 1), // destination link number
                llList2Integer(lst, 2), // 'num' arg
                llList2String(lst, 3),  // 'str' arg
                id);                    // key arg
            if (llList2Integer(lst,0))  // inhibit remenu?
                return FALSE;           // yes, bug out
        }
    }
    else if ("SOUND" == cmd)
    {
        i = llListFindList(Sounds, [button]);
        if (-1 != i)
            llPlaySound(llList2String(Sounds, i + SOUND_INV), 1.0);
    }
    else if ("TOOLS" == cmd)
    {
        if (llGetInventoryType("~MLP lite tools") == INVENTORY_SCRIPT)
        {
            llMessageLinked(LINK_SET, MLP_UNKNOWN, cmd, Owner);
            return FALSE;
        }
        else
            llOwnerSay("Please install the '~MLP lite tools' script for this to work.");
    }
    else if ("REDECORATE" == cmd || "RELOAD" == cmd || "RESET" == cmd || "RESTART" == cmd || "STOP" == cmd)
    {
        say(button);
        stop();
        LoadMenu = ("RESET"      == cmd);
        LoadPos  = ("RELOAD"     == cmd);
        LoadProp = ("REDECORATE" == cmd);
        if ("RESTART" == cmd)
            llResetScript();
        else if ("STOP" == cmd)
            return FALSE;
        else
            state load;
    }
    else
    {
        if (isMenu)
            llOwnerSay("Unknown menu command '" + cmd + "' from -\n\t" + button);
        else
            llOwnerSay("Unknown command '" + cmd + "' from -\n\t" + button);
        llMessageLinked(LINK_SET, MLP_UNKNOWN, cmd + " " + data, id);
        return FALSE;
    }
    llMessageLinked(LINK_SET, MLP_CMD, cmd + " " + data, id);
    return TRUE;
}


default
{
    state_entry()
    {
        Owner = llGetOwner();
        Channel = (integer) ("0x" + llGetSubString((string) llGetKey(), -4, -1));
        setRunning(FALSE);
        LoadMenu  = TRUE;
        LoadPos = TRUE;
        LoadProp = TRUE;
        llSay(0, "OFF (touch to switch on).");
    }

    on_rez(integer arg)
    {
        if (ReloadOnRez)
            llResetScript();
    }

    touch_start(integer i)
    {
        User0 = llDetectedKey(0);
        state load;
    }

    // Waits for another script to send a link message.
    // This is needed coz child prims only send touch events to root prims.
    // So if this script is in a child prim, it can only be touched by touching that prim.
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == "PRIMTOUCH" && id == Owner)
            state load;
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER && Owner != llGetOwner())
            llResetScript();
    }
}

state load
{
    state_entry()
    {
        float   then = llGetTime();
        float   now = 0.0;
        float   total = 0.0;
        list    menuCards = [];
        list    posCards  = [];
        string  item;
        string  e;
        string  c;
        integer i = llGetInventoryNumber(INVENTORY_NOTECARD);
        integer l;
        integer PosCount;
        integer PropCount;

        llSay(0, "STARTING, please wait...");
        llListen(Channel, "", NULL_KEY, "");
        setRunning(TRUE);
        if (LoadProp)
            llMessageLinked(LINK_SET, MLP_UNKNOWN, "LOADPROPS", NULL_KEY);
        while (i-- > 0)
        {
            item = llGetInventoryName(INVENTORY_NOTECARD, i);
            if (llSubStringIndex(item, ".MENUITEMS") == 0)
                menuCards += (list) item;
            if (llSubStringIndex(item, ".POSITIONS") == 0)
                posCards += (list) item;
        }

        if (LoadMenu && LoadPos)    // They both fiddle with Poses, but only need to clear it when loading both.
            Poses = [];
        if (LoadMenu)
        {
            Menus = [];
            Sounds = [];
            LMButtons = [];
            LMParms = [];
            MaxBalls = 1;
            MenuUsers = 0;
            Chat = TRUE;
            Redo = TRUE;
            ReloadOnRez = FALSE;
            Pose = "";
            readMenu(menuCards);
            // Place any otherwise unplaced menus in the main menu.
            l = llGetListLength(ToMenus);
            // Skipping the first one, which should be the main menu.
            for (i = 1; i < l; i++)
            {
                item = llList2String(ToMenus, i);
                if (-1 == llListFindList(SeenMenus, item))
                {
                    e += "\n" + item;
                    c += "\nTOMENU " + item;
                }
            }
            ToMenus = [];
            SeenMenus = [];
            e += "\n" + llList2String(Menus, MENU_ENTRIES);
            c += "\n" + llList2String(Menus, MENU_CMDS);
            Menus = llListReplaceList(Menus, 
                [llGetSubString(e, 1, -1), llGetSubString(c, 1, -1)], MENU_ENTRIES, MENU_CMDS);
            now = llGetTime();
            total += now - then;
            llOwnerSay("Loaded " + (string) (llGetListLength(Menus) / MENU_STRIDE) + " menus in "
                + (string) (now - then) + " seconds.");
            then = now;
            touched(User0);
        }

        if (LoadPos)
        {
            readPos(posCards);
            PosCount = llGetListLength(Poses) / POSE_STRIDE;
            now = llGetTime();
            total += now - then;
            llOwnerSay("Loaded " + (string) (llGetListLength(Poses) / POSE_STRIDE) + " positions in "
                + (string) (now - then) + " seconds.");
            then = now;
        }
        LoadMenu = TRUE;
        LoadPos = TRUE;
        LoadProp = TRUE;
        llSay(0, Version + ": READY in " + (string) total + " seconds.");
        // Give any listen event time to fire before we switch state.
        llSetTimerEvent(0.1);
    }

    changed(integer change)
    {
        if ((change & CHANGED_OWNER) && Owner != llGetOwner())
            llResetScript();
    }

    listen(integer channel, string name, key id, string button)
    {
        if (handleCmd(id, button, TRUE) && Redo) doMenu(id);
    }

    on_rez(integer arg)
    {
        if (ReloadOnRez)
            llResetScript();
    }

    timer()
    {
        state on;
    }
}

state re_on
{
    state_entry()
    {
        state on;
    }
}

state on
{
    state_entry()
    {
        llListen(Channel, "", NULL_KEY, "");
    }

    on_rez(integer arg)
    {
        if (ReloadOnRez)
            llResetScript();
        BallCount = 0;
        setRunning(TRUE);
    }

    changed(integer change)
    {
        if ((change & CHANGED_OWNER) && Owner != llGetOwner())
            llResetScript();
    }

    // Handle messages from balls and props.
    dataserver(key queryId, string str)
    {
        list data = llParseString2List(str, ["|"], []);
        string cmd = llList2String(data, 0);
        if ("ALIVE" == cmd)
        {
            integer ball = llList2Integer(data, 1);
            integer isBall = (0 <= ball);

            saveBall(ball, queryId, NULL_KEY);
            if (isBall)
            {
                vector c = getBallColour(ball);

                osSetPrimitiveParams(queryId, [PRIM_COLOR, ALL_SIDES, c, 1.0,
                    PRIM_NAME, "~ball" + ball, PRIM_TEXT, "Love", <1.0, 1.0, 1.0>, 1.0
// OpenSim doesn't support this, so the ~ball script does it.
//                    PRIM_SIT_TARGET, TRUE, <0.0, 0.0, -0.1>, ZERO_ROTATION
                    ]);
            }
            llMessageLinked(LINK_SET, MLP_CMD, str, queryId);
        }
        else if ("AVATAR" == cmd)
        {
            integer b = findBallByID(queryId);
            integer ball = llList2Integer(Balls, b + BALL_NUM);
            key     a = llList2Key(data, 2);

            if (-1 != b)
            {
                key id = llList2Key(Balls, b + BALL_AVATAR);
                vector c = getBallColour(ball);
                if (NULL_KEY == a)
                {
                    llMessageLinked(LINK_SET, OLD_STANDS, (string) ball, id);
                    osSetPrimitiveParams(queryId, [PRIM_COLOR, ALL_SIDES, c, 1.0,
                        PRIM_SIZE, <0.2, 0.2, 0.2>, PRIM_TEXT, "Love", <1.0, 1.0, 1.0>, 1.0]);
                    stopAnims(id);
                }
                else
                {
                    llMessageLinked(LINK_SET, OLD_SITS, (string) ball + "|" + Pose, id);
                    osSetPrimitiveParams(queryId, [PRIM_COLOR, ALL_SIDES, c, 0.0,
                        PRIM_SIZE, <0.01, 0.01, 0.01>, PRIM_TEXT, "", <1.0, 1.0, 1.0>, 1.0]);
                }
                Balls = llListReplaceList(Balls, [a], b + BALL_AVATAR, b + BALL_AVATAR);
                if (NULL_KEY != a)
                    doPose(Pose, ball, TRUE);
            }
            llMessageLinked(LINK_SET, MLP_CMD, str, queryId);
        }
    }

    touch_start(integer num)
    {
        integer i;

        for (i = 0; i < num; i++)
            touched(llDetectedKey(i));
    }

    listen(integer channel, string name, key id, string button)
    {
        if (handleCmd(id, button, TRUE) && Redo) doMenu(id);
    }

    link_message(integer from, integer num, string str, key id)
    {
        if ("PRIMTOUCH" == str)
            touched(id);
        else if (OLD_CMD == num)
            handleCmd(id, str, FALSE);
        else if (TOOL_DATA == num)
        {
            if ("" == str)
            {
                list data = [];
                integer i = FALSE;

                if ("Menus" == id)
                {
                    data = Menus;
                    i = TRUE;
                }
                else if ("Poses" == id)
                {
                    data = Poses;
                    i = TRUE;
                }
                else if ("Sounds" == id)
                {
                    data = Sounds;
                    i = TRUE;
                }
                if (i)
                    llMessageLinked(from, num, LIST_SEP + llDumpList2String(data, LIST_SEP), id);
            }
        }
        else if (MLP_POSE == num)
        {
            if (NULL_KEY == id)
                id = Pose;
            doPose((string) id, (integer) str, FALSE);
        }
        else if (MLP_DATA == num)
        {
            list data = llParseStringKeepNulls(llGetSubString(str, llStringLength(LIST_SEP), -1), [LIST_SEP], []);

            if ("Menus" == id)
                Menus = data;
            else if ("Poses" == id)
                Poses = data;
            else if ("Sounds" == id)
                Sounds = data;
// TODO - Do we need to update anything else to match the new data now?
        }
        else if (((0 == num) && ("POSEB" == str)) || ((1 == num) && ("STOP" == str)))
            ; // Old messages we can ignore.
        else if ((MLP_CMD == num) || (MLP_UNKNOWN == num)
            || (OLD_SITS == num) || (OLD_STANDS == num) || (OLD_ANIM == num))
            ;  // Ignore these, they are for others.
        else
            llOwnerSay("Unknown link message " + num + ", " + str);
    }

    no_sensor()
    {
        if (People)
        {
            People = 0;
            return;
        }
        People = 0;
        llShout(0, "No one here, shutting down.");
        llResetScript();
    }

    sensor(integer num)
    {
        list t = [];

        // Subtle point here, leaves People = num, which we want for later.
        for (People = 0; People < num; People++)
        {
            integer f = listFindString(Musers, llDetectedKey(People), MUSER_STRIDE);

            if (-1 != f)
                t += llList2List(Musers, f, f + MUSER_STRIDE - 1);
        }
        Musers = t;
    }

    timer()
    {
        float now = llGetTime();
        integer l = llGetListLength(Exps);
        integer i;

        for (i = 0; i < l; i += EXP_STRIDE)
        {
            if (llList2Float(Exps, i + EXP_NEXT) <= now)
            {
                key avatar = llList2Key(Exps, i + EXP_AVATAR);
                string exp = llList2String(Exps, i + EXP_EXP);

                if (exp == "SLEEP")
                {
                    osAvatarStopAnimation(avatar, "express_disdain");
                    osAvatarPlayAnimation(avatar, "express_disdain");
                    osAvatarStopAnimation(avatar, "express_smile");
                    osAvatarPlayAnimation(avatar, "express_smile");
                }
                else if (exp != "")
                {
                    osAvatarStopAnimation(avatar, exp);
                    osAvatarPlayAnimation(avatar, exp);
                }
                Exps = llListReplaceList(Exps, [now + llList2Float(Exps, i + EXP_TIME)], i + EXP_NEXT, i + EXP_NEXT);
            }
        }

        if (now >= 120.0)
        {
            // Yes, I know, this might screw with the expressions timing, think we can live with that though.
            // LSL timing isn't very precise anyway, and makes things less robotic every couple of minutes.
            llResetTime();
            setBalls("LIVE");
            llSensor("", NULL_KEY, AGENT, 6.0, PI);
            for (i = 0; i < l; i += EXP_STRIDE)
                Exps = llListReplaceList(Exps, [llList2Float(Exps, i + EXP_TIME)], i + EXP_NEXT, i + EXP_NEXT);
        }
        checkTicks();
    }
}


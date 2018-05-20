//
// MLP lite v3.0 for OpenSim
// Based on the original MLP - MULTI-LOVE-POSE V1.2 - Copyright (c) 2006, by Miffy Fluffy (BSD License)
// This code has bounced around the Second Life and OpenSim for over a decade, with various people working on it.
// MLP lite for OpenSim is almost a complete rewrite by onefang rejected.

string  Version = "MLP lite tools v3.0 alpha";

key     Owner;
integer Channel;

list Need   = [];
string Todo = "";

// NOTE - This one uses \n to separate sub lists, coz | is used in some of the commands.
list Menus;                     // List of menus.
integer MENU_NAME       = 0;    // Name of menu.
integer MENU_AUTH       = 1;    // Authorised users of menu - 0 = owner, 1 = group, 2 = all
integer MENU_COLOURS    = 2;    // \n spearated list of ball colours.
integer MENU_ENTRIES    = 3;    // \n separated list of entries.
integer MENU_CMDS       = 4;    // \n separated list of commands, matching the entries.
integer MENU_SWAPS      = 5;    // \n separated list of colour sets.
integer MENU_STRIDE     = 6;

string Pose     = "";
list    Poses;                  // List of poses.
integer POSE_NAME       = 0;    // Name of pose.
integer POSE_ANIM       = 1;    // | separated animations.
integer POSE_EMOTE      = 2;    // | separated emotions and timers list.
integer POSE_POSROT     = 3;    // | separated posiiton and rotation pairs.
integer POSE_STRIDE     = 4; 

list    Props;                  // List of props.
integer PROP_NAME       = 0;    // Name of prop, which should match a POSE name.
integer PROP_OBJECT     = 1;    // | separated names of props in inventory.
integer PROP_POSROT     = 2;    // | separated position and rotation pairs.
integer PROP_STRIDE     = 3;

list Sounds;
integer SOUND_NAME      = 0;
integer SOUND_INV       = 1;
integer SOUND_STRIDE    = 2;

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

integer PERMS_CT = PERM_COPY | PERM_TRANSFER;


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

integer findMenu(string name)
{
    return listFindString(Menus, name, MENU_STRIDE);
}

list reportPose()
{
    list result = [];
    integer l = llGetListLength(Poses);
    integer i;

    for (i = 0; i < l; i += POSE_STRIDE)
    {
        list prs = llParseString2List(llList2String(Poses, i + POSE_POSROT), ["|"], []);
        string r = "{" + llList2String(Poses, i) + "} ";
        integer m = llGetListLength(prs);
        integer j;

        for (j = 0; j < m; j++)
            r += llList2String(prs, j);
        result += [r];
    }

    return result;
}

list reportProp()
{
    list result = [];
    integer l = llGetListLength(Props);
    integer i;

    for (i = 0; i < l; i += PROP_STRIDE)
    {
        list obs = llParseString2List(llList2String(Props, i + PROP_OBJECT), ["|"], []);
        list prs = llParseString2List(llList2String(Props, i + PROP_POSROT), ["|"], []);
        string r = "|" + llList2String(Props, i) + "|";
        integer m = llGetListLength(prs);
        integer j;

        // See ~MLP lite props for a comment about why this is different from reportPose().
        for (j = 0; j < m; j++)
            r += llList2String(obs, j) + "|" + osReplaceString(llList2String(prs, j), "><", ">/<", -1, 0);
        result += [r];
    }

    return result;
}

list checkPerms(string name, integer type)
{
    list ans = [];
    integer i = llGetInventoryNumber(type);
    integer p;

    while (i-- > 0)
    {
        string a = llGetInventoryName(type, i);

        ans += [a];
        p = llGetInventoryPermMask(a, MASK_OWNER);
        if (PERMS_CT != (p & PERMS_CT))
            llSay(0, name + " '" + a + "' does not have copy or transfer permissions for the owner.");
        p = llGetInventoryPermMask(a, MASK_NEXT);
        if (PERMS_CT != (p & PERMS_CT))
            llSay(0, name + " '" + a + "' does not have copy or transfer permissions for the next owner.");
    }
    return ans;
}

checkConfig()
{
    list ans;
    integer l = llGetListLength(Poses);
    integer m;
    integer i;
    integer j;
    integer f;

    llSay(0, "Checking most things...");
    ans = checkPerms("Animation", INVENTORY_ANIMATION);
    for (i = 0; i < l; i += POSE_STRIDE)
    {
        string name = llList2String(Poses, i + POSE_NAME);

        if ("" == llList2String(Poses, i + POSE_POSROT))
            llSay(0, "No .POSITIONS* entry for '" + name + "'.");
        else if ("" == llList2String(Poses, i + POSE_ANIM))
        {
            if (("default" != name) && ("stand" != name))
                llSay(0, "No .MENUITEMS* entry for '" + name + "'.");
        }
        else
        {
            list anims = llParseString2List(llList2String(Poses, i + POSE_ANIM), ["|"], []);

            m = llGetListLength(anims);
            for (j = 0; j < m; j++)
            {
                string aname = llList2String(anims, j);

                if (aname != "")
                {
                    if ((aname != "stand") && (aname != "sit_ground"))
                    {
                        if (llGetSubString(aname, -1, -1) == "*")
                            aname = llGetSubString(aname, 0, -2);
                        else
                        {
                            f = llSubStringIndex(aname, "::");
                            if (-1 != f)
                                aname = llGetSubString(aname, 0, f - 1);
                        }

                        if (llGetInventoryType(aname) != INVENTORY_ANIMATION)
                            llSay(0, "Animation '" + aname + "' is not in inventory (ok for build-in animations, otherwise check).");
                        f = llListFindList(ans, aname);
                        if (-1 != f)
                            ans = llDeleteSubList(ans, f, f);
                    }
                }
            }
        }
    }
    if (0 < llGetListLength(ans))
        llSay(0, "These animations are not in any config cards - " + llList2CSV(llListSort(ans, 1, TRUE)));

    ans = checkPerms("Object", INVENTORY_OBJECT);
    l = llGetListLength(Props);
    f = llListFindList(ans, "~ball");
    if (-1 != f)
        ans = llDeleteSubList(ans, f, f);
    for (i = 0; i < l; i += PROP_STRIDE)
    {
        list objs = llParseStringKeepNulls(llList2String(Props, i + PROP_OBJECT), ["|"], []);

        m = llGetListLength(objs);
        for (j = 0; j < m; j++)
        {
            string s = llList2String(objs, j);

            f = llListFindList(ans, s);
            if (-1 != f)
                ans = llDeleteSubList(ans, f, f);
            else
                llSay(0, "Object '" + s + "' is not in inventory.");
        }
    }
    if (0 < llGetListLength(ans))
        llSay(0, "These objects are not in any config cards - " + llList2CSV(llListSort(ans, 1, TRUE)));

    ans = checkPerms("Sound", INVENTORY_SOUND);
    l = llGetListLength(Sounds);
    if (l)
    {
        for (i = 0; i < l; i += SOUND_STRIDE)
        {
            string s = llList2String(Sounds, i + SOUND_INV);

// TODO - No idea why checkPerms() is handing me ["", ""].
            if (llStringLength(s))
            {
                f = llListFindList(ans, s);
                if (-1 != f)
                    ans = llDeleteSubList(ans, f, f);
                else
                    llSay(0, "Sound '" + s + "' is not in inventory.");
            }
        }
    }
    if (0 < llGetListLength(ans))
        llSay(0, "These sounds are not in any config cards - " + llList2CSV(llListSort(ans, 1, TRUE)));

    l = llGetListLength(Poses);
    for (i = 0; i < l; i += MENU_STRIDE)
    {
        string name = llList2String(Menus, i + MENU_NAME);

        ans = llParseStringKeepNulls(llList2String(Menus, i + MENU_CMDS), ["\n"], []);
        if (12 < llGetListLength(ans))
            llSay(0, "To many menu items in '" + name + "' menu.");
        m = llGetListLength(ans);
        for (j = 0; j < m; j++)
        {
            string cmd = llList2String(ans, j);

            if ("TOMENU " == llGetSubString(cmd, 0, 6))
            {
                cmd = llGetSubString(cmd, 7, -1);
                if (-1 == findMenu(cmd))
                    llSay(0, "Menu '" + cmd + "' not found.");
            }
        }
    }

    list scripts = llParseStringKeepNulls("memory menu menucfg pos pose poser prop props run timeout", [""],[]);
    list found = [];

    ans = checkPerms("Script", INVENTORY_SCRIPT);
    l = llGetListLength(scripts);
    for (i = 0; i < l; i++)
    {
        f = llListFindList(ans, ["~" + llList2String(scripts, i)]);
        if (-1 != f)
        {
            found += ["~" + llList2String(scripts, i)];
            ans = llDeleteSubList(ans, f, f);
        }
    }
    for (i = 1; i < 9; i++)
    {
        f = llListFindList(ans, ["~poser " + i]);
        if (-1 != f)
        {
            found += ["~poser " + i];
            ans = llDeleteSubList(ans, f, f);
        }
    }
    f = llListFindList(ans, ["~ball"]);
    if (-1 != f)
    {
        found += ["~ball"];
        ans = llDeleteSubList(ans, f, f);
        llSay(0, "There is a '~ball' script, it should be in the '~ball' object, and in any prop objects.");
        llSay(0, "There is a '~ball' script, it should NOT be in this '" + llGetObjectName() + "' object.");
    }
    f = llListFindList(ans, ["~sequencer"]);
    if (-1 != f)
    {
        ans = llDeleteSubList(ans, f, f);
        llSay(0, "There is a '~sequencer' script, which you wont need unless you where using the old MLP sequences.");
        llSay(0, "If any old '.SEQUENCER' cards are in use, try them, see if it still works.");
    }
    if (0 < llGetListLength(found))
        llSay(0, "These scripts are likely left overs from an older MLP, you can probably remove them - " + llList2CSV(llListSort(found, 1, TRUE)));


    f = llListFindList(ans, ["~MLP lite for OpenSim"]);
    if (-1 != f)
        ans = llDeleteSubList(ans, f, f);
    else
        llSay(0, llGetScriptName() + " says it wants '~MLP lite for OpenSim'.");
    f = llListFindList(ans, ["~MLP lite tools"]);
    if (-1 != f)
        ans = llDeleteSubList(ans, f, f);
    else
        llSay(0, llGetScriptName() + " !=  ~MLP lite tools!");

    list cards = checkPerms("Notecard", INVENTORY_NOTECARD);
    l = llGetListLength(cards);
    f = -1;
    for (i = 0; i < l; i++)
    {
        string crd = llList2String(cards, i);

        if (llSubStringIndex(crd, ".SEQUENCES") == 0)
            llSay(0, "Old MLP sequences might be in notecard - '" + crd + "'.");
        if (llSubStringIndex(crd, ".PROPS") == 0)
            f = i;
    }
    if (-1 == f)
    {
        f = llListFindList(ans, ["~MLP lite props"]);
        if (-1 != f)
            llSay(0, "'~MLP lite props' script is not needed if there are no .PROPS* cards.");
    }
    else
    {
        f = llListFindList(ans, ["~MLP lite props"]);
        if (-1 == f)
            llSay(0, "'~MLP lite props' script is needed if there are .PROPS* cards.");
    }


    llSay(0, "Checks completed.");
}

doMenu(key id)
{
    llDialog(id, Version, [
        "All poses", " ", "Quit tools",
        "Height>>", "Pose match>>", "Adjust pos>>",
        "RELOAD", "RESET", "REDECORATE",
        "CHECK", "DUMP", "SAVE"
        ], Channel);
}

doHeight(key id)
{
    llDialog(id, Version, [
        " ", " ", "Back",
        "Z-1", "Z-5", "Z-25",
        "Z+1", "Z+5", "Z+25"
        ], Channel);
}

getData(string name)
{
    Need += [name];
    llMessageLinked(LINK_SET, TOOL_DATA, "", name);
}

default
{
    state_entry()
    {
        Owner = llGetOwner();
        Channel = (integer) ("0x" + llGetSubString((string) llGetKey(), -4, -1) + 1);
        llListen(Channel, "", Owner, "");
    }

    link_message(integer from, integer num, string str, key id)
    {
        if (((0 == num) && ("POSEB" == str)) || ((1 == num) && ("STOP" == str)))
            ;
        else if ((MLP_UNKNOWN == num) && ("TOOLS" == str))
            doMenu(id);
        else if ((MLP_POSE == num) || (OLD_CMD == num) || (MLP_CMD == num) || (MLP_UNKNOWN == num)
            || (OLD_SITS == num) || (OLD_STANDS == num) || (OLD_ANIM == num))
            ;
        else if ((TOOL_DATA == num) && ("" == str))
            ;
        else if ((TOOL_DATA == num) && ("" != str))
        {
            list data = llParseStringKeepNulls(llGetSubString(str, llStringLength(LIST_SEP), -1), [LIST_SEP], []);
            integer f = llListFindList(Need, id);

            if ("Menus" == id)
                Menus = data;
            else if ("Poses" == id)
                Poses = data;
            else if ("Props" == id)
                Props = data;
            else if ("Sounds" == id)
                Sounds = data;
            if (-1 != f)
            {
                integer i;

                Need = llDeleteSubList(Need, f, f);
                if (0 == llGetListLength(Need))
                {
                    if ("CHECK" == Todo)
                    {
                        checkConfig();
                        Todo = "";
                    }
                    else if ("DUMP" == Todo)
                    {
                        string objectName = llGetObjectName();
                        list report = reportPose();
                        integer l = llGetListLength(report);

                        llSetObjectName(".");
                        llOwnerSay(".POSITIONS---------------------------------------------------------------");
                        for (i = 0; i < l; i++)
                            llOwnerSay(llList2String(report, i));
                        llOwnerSay(".PROPS-------------------------------------------------------------------");
                        report = reportProp();
                        l = llGetListLength(report);
                        for (i = 0; i < l; i++)
                            llOwnerSay(llList2String(report, i));
                        llOwnerSay("-------------------------------------------------------------------------");
                        llSetObjectName(objectName);
                        Todo = "";
                    }
                    else if ("SAVE" == Todo)
                    {
                        i = llGetInventoryNumber(INVENTORY_NOTECARD);
                        list cards = [];

                        llSay(0, "Backing up old cards.");
                        while (i-- > 0)
                        {
                            string item = llGetInventoryName(INVENTORY_NOTECARD, i);

                            if ((llSubStringIndex(item, ".POSITIONS") == 0) || (llSubStringIndex(item, ".PROPS") == 0))
                                cards += [llGetInventoryName(INVENTORY_NOTECARD, i)];
                        }
                        i = llGetListLength(cards);
                        while (i-- > 0)
                        {
                            string item = llList2String(cards, i);

                             osMakeNotecard(".backup" + item, llParseStringKeepNulls(osGetNotecard(item), ["\n"], []));
                             llRemoveInventory(item);
                        }

                        osMakeNotecard(".POSITIONS", reportPose());
                        llSay(0, "Current ball positions saved to the .POSITIONS notecard.");
                        if (llGetListLength(Props))
                        {
                            osMakeNotecard(".PROPS", reportProp());
                            llSay(0, "Current props positions saved to the .PROPS notecard.");
                        }
                        Todo = "";
                    }
                    else if ("All poses" == Todo)
                    {

                        f = llGetListLength(Menus);
                        for (i = 0; i < f; i += MENU_STRIDE)
                        {
                            string name = llList2String(Menus, i + MENU_NAME);
                            list   cmds = llParseStringKeepNulls(llList2String(Menus, i + MENU_CMDS), ["\n"], []);
                            integer l = llGetListLength(cmds);
                            integer j;

                            llOwnerSay("Running through all the poses in menu '" + name + "'.");
                            for (j = 0; j < l; j++)
                            {
                                string p = llList2String(cmds, j);

                                if ("POSE " == llGetSubString(p, 0, 4))
                                {
                                    string pose = llGetSubString(p, 5, -1);

                                    llMessageLinked(LINK_SET, OLD_CMD, "TOMENU " + name, Owner);
                                    llMessageLinked(LINK_SET, MLP_POSE, (string) POSES_POSE, pose);
                                    llSleep(5.0);
                                }
                            }
                        }
                        llMessageLinked(LINK_SET, OLD_CMD, "STOP", Owner);
                        llOwnerSay("Finished all poses.");
                        Todo = "";
                    }
                }
            }
        }
        else
            llOwnerSay(llGetScriptName() + " Unknown link message " + num + ", " + str);
    }

    listen(integer channel, string name, key id, string button)
    {
        if ("CHECK" == button)
        {
            Todo = button;
            getData("Menus");
            getData("Poses");
            if (llGetInventoryType("~MLP lite props") == INVENTORY_SCRIPT)
                getData("Props");
            getData("Sounds");
        }
        else if ("DUMP" == button)
        {
            // Save any edits to the current pose first.
            llMessageLinked(LINK_SET, MLP_POSE, (string) POSES_DUMP, NULL_KEY);
            getData("Poses");
            if (llGetInventoryType("~MLP lite props") == INVENTORY_SCRIPT)
                getData("Props");
            Todo = button;
        }
        else if ("SAVE" == button)
        {
            // Save any edits to the current pose first.
            llMessageLinked(LINK_SET, MLP_POSE, (string) POSES_DUMP, NULL_KEY);
            getData("Poses");
            if (llGetInventoryType("~MLP lite props") == INVENTORY_SCRIPT)
                getData("Props");
            Todo = button;
        }
        else if ("All poses" == button)
        {
            getData("Menus");
            Todo = button;
        }
        else if ("RESET" == button || "RELOAD" == button || "REDECORATE" == button)
            llMessageLinked(LINK_SET, OLD_CMD, button, Owner);
        else if ("Height>>" == button)
        {
            doHeight(id);
            return;
        }
        else if ("Z" == llGetSubString(button, 0, 0))
        {
            integer i = (integer) llGetSubString(button, 1, 10);
            integer Zoffset = (integer) llGetObjectDesc() + i;

            llSetObjectDesc((string) Zoffset);
            llMessageLinked(LINK_SET, MLP_POSE, (string) POSES_Z, NULL_KEY);
            llOwnerSay("Height Adjustment: change by " + (string) i + "cm, new offset: " + (string) Zoffset + "cm.");
            doHeight(id);
            return;
        }
        else if ("Back" == button)
            ;
        else if ("Quit tools" == button)
        {
            llMessageLinked(LINK_SET, OLD_CMD, "TOMENU", Owner);
            return;
        }
        doMenu(id);
    }
}

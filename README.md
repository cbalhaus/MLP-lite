# MLP-lite
A lighter version of the MLP scripts, built for OpenSim.

MLP lite v3.0 for OpenSim is almost a complete rewrite by onefang
rejected, of the venerable MLP scripts.  It uses OpenSim specific
functions, so wont work in Second Life.  It might not work on some
OpenSim grids or sims, due to the use of OpenSim specific "high threat
level" functions.  Test it first before putting it in anything important.

---

CONTENTS:
- INTRODUCTION
- FEATURES
- OPERATION
  - TO ADJUST POSITIONS
  - TO MAKE A BACKUP
  - TO ADJUST HEIGHT OFFSET (Z)
  - TO ADD POSES
  - TO CREATE ANIMATION SETS (menus)
  - SWAPPING POSES
  - ACCESS TO THE MAIN MENU
  - PORTABLE USE
- FAQ for END USERS
- UPGRADE GUIDE
- DIFFERENCES FOR THE MLP lite v3.0 for OpenSim VARIATION
- OPENSIM THREAT LEVELS


## INTRODUCTION:

The main justification for this rewrite is that I have about a dozen
OpenSim sims, some with dozens of copies of MLP running.  So this
variation uses some OpenSim specific LSL functions, tries to use less 
resources, be quicker, and automatically shuts down when no one is
around.  Some functions where removed, hence the "lite" in the name, most
of these seem to not be used, or useful, or just don't get used in my
sims.  Note that I've not extensively tested any of this stuff yet.  It's
not a huge improvement, but when you have dozens of the things, every
little bit helps.  And then I added more features.  lol

Based on the original MLP - MULTI-LOVE-POSE V1.2 - Copyright (c) 2006, by
Miffy Fluffy (BSD License).  This code has bounced around Second Life and
OpenSim for over a decade, with various people working on it.  I can't
compile a complete list, as I have no idea of the complete history of the
versions I have received.  The names I do know coz they where in the
source code (in no particular order) - Miffy Fluffy, Learjeff Innis, Jez
Ember, Liz Silverstein, Zonax Delorean, Purrcat Miranda, and Kokoro
Fasching.  Apologies to anyone who's code is in this variation and I
haven't mentioned you.  It's likely that some or all of the code written
by these people is no longer in this variation.  Thanks to you all.

This variation is still BSD licensed.  The text of the BSD license wasn't
included in any of the versions I have, but it's a simple and standard
license, you should easily find copies all over the Internet, or a 
simple search.  The versions I have seen don't specify which variation of
the BSD license, so I wont either.  GitHub insists on a license file, so
I went with 3 clause BSD.

Note that some of the OpenSim functions used are what OpenSim classes as
"high threat level".  More about that below.  This means that these
scripts wont work without some tweaking of your grid / sims 
configuration.  This has only been tested in my hacked up version of
OpenSim 0.8.2, which removes a lot of the insane threat levels and script
delays, so anything I say about speed improvements might not apply.  I
did at least remove script delays in both LL and OS functions.  If
nothing works for you, this is likely why, and you should go back to the
old scripts.  Test it first before upgrading anything that's not full
perm.

Some parts of this document is mostly copied from the .readme file I got
with the latest MLP versions I had laying around.


## FEATURES:

- Put all your poseball animations into one object (110 pairs or even more
should be no problem).
- Create submenus for each category of poses, for instance: "Solo,
Boy-Girl, Girl-Girl, Dance, 3some, 4some"
- Shows up to nine poseballs depending on the submenu you select
- Positions can be adjusted and saved into memory or notecard.
- Portable, can be worn and used everywhere
- Option to adjust height offset (Z) of all poses at once (for different
persons/locations).
- 15 poseball colours:
    PINK, BLUE, PINK2, BLUE2, GREEN, MAGENTA, RED, ORANGE, WHITE, BLACK,
    YELLOW, CYAN, RED2, TEAL, GREEN2


## OPERATION:

- Click the MLP object to switch it on.
- When everything has loaded the main menu will appear.
- Select a submenu containing poses, and select a pose.  Pose balls will
appear.
- Sit on your pose ball (Right-click - LOVE).
- To remove the balls, select 'EXTRAS>>' then 'STOP', or just walk away,
it will shut down automatically when no one is around.

### TO ADJUST POSITIONS:

You can adjust the poses to fit your own avatar and those you share MLP
with.
- Select a pose you want to adjust and sit on the balls.
- Select 'EXTRAS>> ' then 'ADJUST'.  This changes the balls into
translucent beams.
- Right-click a beam, select Edit and adjust the position (Shift-click to
select more than one).
- Position the balls anywhere within the sim.
- 'EXTRAS>>', 'OPTIONS>>', then 'Save Pos' stores the positions into a
new notecard.

### TO MAKE A BACKUP:

Saved positions are stored in memory but are not permanent.  They are
lost on script error (See "Script run-time error / Stack-Heap Collision"
below).  They are also lost on shutdown/startup, or "Pos Reset".  To
back the positions up more permanently you have to copy them into a
new .POSITIONS notecard:
- Select 'EXTRAS>>', 'OPTIONS>>', then 'Save Pos' .
All original .POSITIONS* cards are copied to .backup.POSITIONS* cards.
Prop positions are saved to .PROPS, so the same applies.

Note: After changing any *.POSITIONS* files, use the 'Pos Reset' command
to verify your changes, if desired.  This also helps to avoid losing
changes due to Stack-Heap collisions.

### TO ADJUST HEIGHT OFFSET (Z):

Select 'EXTRAS>>', 'OPTIONS>>', then'Height>>' and click the 'Z'-buttons,
this will adjust the height for all poses.  Note: the offset height is
stored in the objects Description, so any descriptions will be replaced.

### TO ADD POSES:

Copy all animations into the MLP object (if you want to use existing pose
balls, open them to rip their animations).  Note: you can use any object
as MLP, just copy the MLP contents in the object of your choice. Open the
.MENUITEMS and add the animations:

POSE name | animation1 | animation2 ... 

The changes will become active after MLP is (re)started.  Use the 'Menu
Reset' command after changing 
*.MENUITEMS* files.

To give an expression to an animation, add one of the following suffixes
to the anim name in the POSE line.  (Just add it to the POSE config line,
don't change the anim name.)

   Suffix / expression
    *        open mouth
    ::1      open mouth
    ::2      surprise
    ::3      tongue out
    ::4      smile
    ::5      toothsmile
    ::6      wink
    ::7      cry
    ::8      kiss
    ::9      laugh
    ::10    disdain
    ::11    repulsed
    ::12    anger
    ::13    bored
    ::14    sad
    ::15    embarrassed
    ::16    frown
    ::17    shrug
    ::18    afraid
    ::19    worry
    ::20    sleeping (combination of disdain and smile, closest I could find)

To make the expression happen periodically rather than constantly, add
another extension and the period (in seconds).  This is mostly needed for
those expressions that only last a short time.  For example, to use MyAnim 
with open mouth every 5.5 seconds:

    POSE Mypose | MyAnim::1::5.5

TO ADD SOUNDS (buttons to play sounds), in a menu (just like a POSE
button), add a line like this:

    SOUND She moans | female-moan

where "She moans" will be the button label, and "female-moan" is the
sound to play, which must be in object inventory.  For sounds in menus
with poses (rather than in a menu specifically for sounds) I recommend
you begin the pose name with "☊" (which looks a bit like headphones, the
best I could find for the purpose).  This serves as a clue to the user
that the button plays a sound.

### TO CREATE ANIMATION SETS (menus):

Create .MENUITEMS.xxx and .POSITIONS.xxx files (where xxx is whatever you
want) and put the corresponding menu configs and poses in them.  This
way you can deliver a bed with folders of add-on menus so the customer
can choose what types of anims they want to add to the menu.  Note that
you get at most 12 top menu choices.  The scripts read the .POSITIONS
files in alphabetical order (and 
.POSITIONS must be first).

This also allows you to sell furniture with "enhancement packs", which
are simply collections of .MENUITEMS.xxx, .POSITIONS.xxx, and the
associated animations for the customer to drop into the furniture. 
Customers can easily select furniture appearance and pose bundles
independently!

### SWAPPING POSES:

Each menu can have a swap command:

    SWAP | 21

Would be the default.  Note that this means before you hit the SWAP 
button, the balls will be in the same order as listed in the MENU and
POSE commands, after they would be reversed.  SWAP always assumes
the unswapped condition is the order things are listed.  So 21 in the 
above command means swap the first two balls.

The default for more than two balls is to just fill out both strings with
the remaining integers:

    SWAP | 213456789

This might be used to swap the last two balls only:

    SWAP | 132

Any number of swap patterns can be used:

    SWAP | 132 | 321 | 312

You can also use a different name for the button:

    SWAP switch men | 213

Also, the original one should be supported, that uses the default:

    SWAP

### ACCESS TO THE MAIN MENU:

The owner is the only one who can shutdown, in all cases.  Anyone
can start it.
- if 'MenuUser' is set to OWNER: the owner is the only one who can access
the menus
- if 'MenuUser' is set to ALL: anyone can access the MAIN MENU
- if 'MenuUser' is set to GROUP: members of the same Group as the MLP
object can access the 
MAIN MENU (the MLP Group can set by right-clicking MLP and selecting
Edit, More >> General tab - Group: Set) Note: even if "MenuUser" is set
to ALL or GROUP, individual SUBMENUS can still be blocked (you can 
define access for each submenu in .MENUITEMS, see examples in
.MENUITEMS).

### PORTABLE USE:

Attach the object to the HUD, you can use it's default shape and colour
for clickable bar on one of the edges of your screen (to move HUD
position: Right-click - Edit), you can edit
colour/transparency/size/position.  Adjust the height offset (Z). Note:
the balls will appear relative to the initial MLP position (to reset 
where the balls appear, press STOP to remove the balls, and reselect a
submenu to rez them again).


## FAQ for END USERS:

- Will my animations be lost if I lose a poseball?

No.  The animations are not placed the balls, they remain in the main MLP
object.  Don't worry about the poseballs, they are copies of the one in
the MLP object.  A balls will commit suicide if left behind somewhere
(the MLP object needs to be within the same sim).

- Sometimes notecards or scripts won't open for editing, why?

If the MLP object contains many things, access to it's contents can be
slow, just keep waiting until it's all loaded.  Can take over a minute
sometimes.

- "Script run-time error / Stack-Heap Collision"?

Right-click/Edit the object, and use SL menu: "Tools -> Reset Scripts in
Selection" to reset. Any saved positions that were not backed up in
.POSITIONS files are lost, so if your furniture has lots of poses (over
50) and you save positions, be sure to back up regularly.  Use OPTIONS ->
Pos Reset after changing .POSITIONS* files.

FAQ for those who edit *.MENUITEMS files:

- "Script run-time error / Stack-Heap Collision"?

After a restart, this is a clue that there are too many items in
*.MENUITEMS* or *.POSITIONS* files.  Trim the menu.

- My new menu appears on the main page, rather than as a submenu where I
configured it.  Why?

Most likely, you named it differently in the MENU line versus the TOMENU
line.  When MPL sees a MENU line, it looks for the same name in a TOMENU
line.


## UPGRADE GUIDE:

For the sake of these instructions, let's say you want to upgrade the
scripts in an object called "My Old Bed", this is what you would do.  
These instructions assume that everything has copy permission.

First rez My Old Bed in world somewhere.  If it is already in world, take
a copy, in case things don't work out and you want to revert to the old
scripts.  You could also move the scripts and things you are about to
replace to a new folder, so you can put things back the way they where
before.  Or just ignore any backups and cross your fingers.

Remove the old MLP scripts, they will be named ~memory, ~menu, ~menucfg,
~pos, ~pose, ~poser, ~poser 1, ~poser 2, ~poser 3, ~poser 4, ~poser 5,
~run,  and you might also have optional scripts ~props, ~sequencer, and
~timer.  Also remove the ~ball object.  There may be another script, I
have never seen  one, that deals with PRIMTOUCH, my guess is it might be
called ~primtouch.  Leave it alone, this new script should be compatible
with it.  Since I have never seen that script, nor needed it, I dunno
for sure.

Drag the "~MLP lite for OpenSim" script into My Old Bed, and the new
~ball object.  You should see "My Old Bed: OFF (touch to switch on)" in
chat.

My Old Bed might have some props in it, they will be objects other than
~ball.  In typical examples I have seen there is a pillow, so lets use
that as an example.  Drag pillow out of My Old Bed and into your
inventory, into the same folder you are backing up everything else. 
Remove pillow from My Old Bed.  Drag pillow onto the ground, edit it, and
remove the ~prop script.  Replace that script with the new ~ball script. 
Take pillow, then drag it into My Old Bed.  Add the "~MLP lite props"
script to My Old Bed.

You may want to update your .MENUITEMS, or just leave them as is.  Look
at the examples for how it is now recommended to have them setup.  If you 
do this take care of the OPTIONS menu, which is now called OPTIONS>> in
this new .MENUITEMS.

If you still want to edit the poses / props, or do any of the other
tweaking, then you might want to add the "~MLP lite tools" script to My
Old Bed.  Leave it out, or remove it, once My Old Bed is fully set up.


## DIFFERENCES FOR THE MLP lite v3.0 for OpenSim VARIATION:

As mentioned above, this variation drops a few rarely used features, and
tries to make things a bit better for OpenSim users.  Note that some of
the dropped features may be added back again in later versions, I dunno
yet.

- Up to nine avatars can be animated at once.

- Menus no longer lock out other users when someone else is using it.

- The SWAP command has been changed to something like the XPOSE SWAP
command.  It's documented above.  The original MLP SWAP command works as
it used to.

- Changing menus no longer reverts any SWAP commands.  Though if the swap 
command is different between menus, it wont let you swap again in the
different menu.

- Anyone can start up an MLP lite object, and they automatically shutdown
if no one is around for a couple of minutes.  This makes it easy to setup
public areas with publicly usable objects that don't soak up resources 
when people forget to turn them off after using them.  The startup also
prints the startup time.

- After turning on an MLP object by touching it while it is turned off,
the MAIN MENU is shown automatically to the person that started it.  I
assume that the person that turned it on is just waiting for it to finish
starting up so they can actually use it.  Actually the menu shows after
loading menus, but before loading positions, but you can start to use it
straight away.

- The CHECK command no longer reloads things.  It also checks for
permissions and animations that are not used, as well as a few other
things.  It's in the ~MLP lite tools script.

- Less scripts.  There are only two scripts now, "~MLP lite for OpenSim"
is the main script, and ~ball in the ~ball and prop objects.  OpenSim
doesn't seem to have any memory limits per script (usually the main 
reason to split scripts like that), and it simplifies the code a lot if
there is just one main script.  The ~ball script is much simpler.  Props
use the ~ball script instead of ~prop.  There are two optional scripts,
"~MLP lite props" is used in the main MLP object if you have any props,
and "~MLP lite tools" is used by creators and editors if needed.

- It may use a bit more CPU time when expressions are being used.  You
may not notice.  A lag tester was added to help with this, expressions
may slow down when it gets laggy.

- Since we use some OpenSim functions that are considered high threat,
you might need to tweak your OpenSim settings.  See below for details.

- The default .MENUITEMS note card now includes an EXTRAS menu, for all
those functions that usually go at the bottom of each menu, so you can
fit more poses on each menu.  I suggest that "TOMENU EXTRAS>>" be added
to the end of menus, along with "BACK" and maybe "SWAP"

- Various creator and editing functions have been moved to the TOOLS>>
menu, and the "~MLP lite tools" script.  You can leave this out if
the MLP object is fully set up.

- You no longer need to have the first two lines of .MENUITEMS as the
"stand" and "default" POSE commands.  It wont hurt to include them.

- MENUORDER is no longer supported, menu buttons appear in the same order
they are on the .MENUITEMS* cards, coz that's the only sane way of doing
it.

- The MAIN MENU, first menu in .MENUITEMS, no longer needs a bunch of
"TOMENU -" commands.

- While the DUMP command still prints the positions in chat, SAVE now
saves that to a fresh .POSITIONS notecard, so you no longer have
to cut and paste to your old .POSITIONS cards.  The old cards are
backed up, and the same applies to .PROPS cards that store props.

- MLP lite remembers all editing of the pose balls, not just those done
while in ADJUST mode, ADJUST now just makes the pose balls easier to
edit.  This makes editing of lots of poses a lot quicker, and means you 
can make quick fixes on the fly, and save them at the end if you want to.

- The BALLUSERS, OFF, REDO, INVISIBLE, STAND, SHOW, HIDE, and AGAIN
commands no longer exist.  They are rarely used, or just not needed.

- The code that slices up long menus into shorter ones with "BACK" and
"MORE", to fit in the Second Life 12 button menu limit has all been
removed.  I was gonna rewrite that, but for various reasons decided to
just drop it completely.  People can chop up their own submenus if they
need this, and that's exactly what I have seen other furniture makers do. 
As a bonus, there are no hard coded English menu or button names left in
the code, so you can easily use MLP lite for other languages.  On  the
other hand, all the messages are in English.  CHECK will let you know if
your menus are too long.

- Old ~prop scripts are not supported, use the new ~ball script instead,
which means a bit of surgery needed on old props.

- Sequences are not currently supported.

- The REORIENT command, and various link messages, are not currently
supported.  Some or all of these may come back.  Some of the existing
link messages changed as well.  Combining the scripts meant that a lot
of these link messages are no longer needed, but some external scripts
may depend on them.

- ZHAO support is gone.  None of the ZHAO based AOs I have seen in
OpenSim support that.  Note that the ~MLPT-AutoZhao script says "This
one supports AutoZhao, which is a ZHAO variant that turns of 
automatically when you sit."  Which seems pointless, it's already doing
the correct thing.  My own AO / swimmer does the correct thing to.

- No Xcite support.  Xcite doesn't exist in OpenSim.

- The STOP command now just stops all animations and puts away the balls,
instead of switching to the "stand" animation.

- Strided lists are used internally, in theory should use a little less
memory than having separate lists for everything.

- osMessageObject() is used instead of llSay() to communicate with the
pose balls.  This will stop any cross talk issues, and save some script
running time.  As a bonus, balls can be anywhere in the sim.

- The OpenSim notecard reading functions are used instead of the clunky
Second Life dataserver() functions.  Faster and cleaner code.

- While the PRIMTOUCH command is still supported, it's script isn't here. 
I never did have a copy of that script, and haven't needed to use it
anyway.

- There may be a thing or two I forgot to mention here.


## OPENSIM THREAT LEVELS:

OpenSim developers introduced a concept of "threat levels" for their new
os* LSL functions.  In my not so humble opinion, they where very
paranoid in assigning threat levels.  For this reason, these scripts may
or may not work in any given grid or sim.  In my version of OpenSim I
have removed or reduced the more insane threat levels, so YMMV.

Refer to the OpenSim documentation for how to deal with this, or ask the
person that runs your OpenSim grid / sim.

- osAvatarPlayAnimation() and osAvatarStopAnimation()
Threat level: VeryHigh, disabled by default.

These two functions can animate any avatar with any animation in the
objects inventory, without asking permission.  So I guess this threat
level is warranted.  Also means one script can manage animations for more
than one avatar, a limitation of the LL variety.

Used to get rid of one of the annoying aspects of how MLP works, which
often confuses newbies.  Also allowed me to reduce the code complexity
and get rid of all those ~poser X scripts.

- osGetRezzingObject()
Threat level: none, enabled by default.

Wow, no threat level, the only one.  lol

Used to reduce the complexity of the communication between the MLP object
and the balls.

- osGetNumberOfNotecardLines(), osGetNotecard(), and osGetNotecardLine()
Threat level: VeryHigh, only enabled for estate owners and managers by
default.

A faster and less complex way of being able to do what you could always
do, gets a VeryHigh threat level?  WTF are the OpenSim developers
smoking?

Used to speed things up and reduce code complexity, exactly what they
where designed for.

- osMakeNotecard()
Threat level: High, only enabled for estate owners and managers by
default.

Slightly less WTF than the other notecard functions, but still.  Allows
to script what the object owner can do manually, why is that a high
threat?

Saves having to cut and paste to notecards after editing ball and prop
positions.

-osMessageObject()
Threat level: Low, only enabled for estate owners and managers by
default.

More WTF, allows to send messages between objects better.  Nothing you
couldn't do before.

Used to reduce the complexity and increase the reliability of messages
between the MLP object and balls / props.

-osReplaceString()
Threat level: VeryLow , enabled by default.

Why isn't this threat level none?

Used to reduce script complexity.

-osSetPrimitiveParams()
Threat level: High, disabled by default.

Once again, allows scripting of something that can be done manually, and
only works on objects the script owner actually owns.  With that later
restriction, total WTF.

Used to reduce complexity and speed things up.


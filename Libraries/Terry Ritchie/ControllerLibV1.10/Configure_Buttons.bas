'$INCLUDE:'CONTROLLER.BI'
'
'------------------------------
' Controller Library Demo
' "Reconfiguring Buttons"
'
' Terry Ritchie
' April 26th, 2023 - Initial version
' May   17th, 2023 - added ability to save and load button configurations in configuration screen
'                  - demo detects when controllers are unplugged/plugged back in
'                  - demo detects when new controllers are plugged in
'------------------------------
'
' Default Demo Keys:
'
'   W      - UP    (Mario JUMP)
'   S      - DOWN  (Mario CROUCH)
'   A      - Mario LEFT
'   D      - Mario RIGHT
'   C      - Mario CROUCH
'   SPACE  - Mario JUMP
'   RCTRL  - Mario FIRE
'   RSHIFT - Mario RUN
'   F1     - Configure Controllers
'
' Hitting mystery box on bottom
' releases coins.
'
'------------------------------

OPTION _EXPLICIT '                all variables must be explicitly defined

CONST STAND = 1 '                 action sprites - Standing
CONST CROUCH = 2 '                crouching
CONST RUNSTART = 3 '              get ready to run
CONST WALK = 4 '                  walking/running (6 animation images)
CONST JUMP = 5 '                  jumping
CONST FIRE = 6 '                  bullet sprites (4 animation images)
CONST COIN = 7 '                  coin sprite

TYPE TYPE_RECTANGLE '             RECTANGLE PROPERTIES
    x1 AS INTEGER '               upper left x
    y1 AS INTEGER '               upper left y
    x2 AS INTEGER '               lower right x
    y2 AS INTEGER '               lower right y
END TYPE

TYPE TYPE_BUTTON '                DEFINED BUTTON PROPERTIES
    UP AS INTEGER '               UP button(s)
    DOWN AS INTEGER '             DOWN button(s)
    RIGHT AS INTEGER '            RIGHT button(s)
    LEFT AS INTEGER '             LEFT buttons(s)
    FIRE AS INTEGER '             FIRE button(s)
    RUN AS INTEGER '              RUN button(s)
    JUMP AS INTEGER '             JUMP button(s)
    CROUCH AS INTEGER '           CROUCH button(s)
    F1 AS INTEGER '               F1 button (key - enter config mode)
    F2 AS INTEGER '               F2 button (key - reset button defaults)
    F3 AS INTEGER '               F3 button (key - save buttons)
    F4 AS INTEGER '               F4 button (key - load saved buttons)
    F5 AS INTEGER '               F5 button (key - exit config)
END TYPE

TYPE TYPE_MARIO '                 MARIO PROPERTIES
    x AS SINGLE '                 x location (center bottom)
    y AS SINGLE '                 y location (center bottom)
    Frame AS INTEGER '            animation frame
    Action AS INTEGER '           STAND, CROUCH, RUNSTART, WALK, JUMP
    Rect AS TYPE_RECTANGLE '      sprite image location
    FPS AS INTEGER '              mario animation update speed
    Direction AS INTEGER '        direction mario is traveling
    Speed AS INTEGER '            speed of mario (walking or running)
    Facing AS INTEGER '           direction mario is facing
    Jumping AS INTEGER '          mario currently jumping (t/f)
    Running AS INTEGER '          mario currently running (t/f)
    Walking AS INTEGER '          mario currently walking (t/f)
    RunTimer AS INTEGER '         period to show ready to run image
    Yvel AS SINGLE '              y velocity of mario jump
    Vector AS SINGLE '            y vector of mario jump
    Floor AS INTEGER '            lowest point on screen mario can go
END TYPE

TYPE TYPE_BULLET '                BULLET PROPERTIES
    InUse AS INTEGER '            this bullet currently active (t/f)
    x AS SINGLE '                 x coordinate of bullet
    y AS SINGLE '                 y coordinate of bullet
    Direction AS INTEGER '        direction bullet is traveling
    Cell AS INTEGER '             current bullet animation cell
END TYPE

TYPE TYPE_COIN '                  COIN PROPERTIES
    InUse AS INTEGER '            this coin currently active (t/f)
    y AS SINGLE '                 y coordinate of coin
    vector AS SINGLE '            y vector of coin
END TYPE

'+------------------------------+
'| Program variable definitions |
'+------------------------------+

REDIM Bullets(1) AS TYPE_BULLET ' bullet array
REDIM Coins(1) AS TYPE_COIN '     coin array
DIM Button AS TYPE_BUTTON '       player buttons
DIM WorkScreen AS LONG '          graphics drawn here
DIM BackGround AS LONG '          static background image
DIM Sprite(7, 6) AS LONG '        mario sprite image pool
DIM Mario AS TYPE_MARIO '         mario properties
DIM Box AS TYPE_RECTANGLE '       mystery box coordinates
DIM MysteryBox AS LONG '          mystery box image
DIM FPSFrame AS INTEGER '         current frame (1 to 30)
DIM BulletTimer AS INTEGER '      time to wait between bullets
DIM Controller AS INTEGER '       controller(s) status
DIM Action AS INTEGER '           controller action taken
DIM FrameCount AS INTEGER '       game frame counter
DIM SNDBump AS LONG '             bump sound
DIM SNDCoin AS LONG '             coin sound
DIM SNDConf AS LONG '             configuration screen sound
DIM SNDFire AS LONG '             bullet firing sound
DIM SNDJump AS LONG '             jump sound
DIM SNDSong AS LONG '             theme song

'______________________________________________________________________________________________________________________

'+---------------+
'| Program setup |
'+---------------+

__INITIALIZE_CONTROLLERS '                                   initialize controller library
__MAKE_BUTTON Button.UP '                                    define user assigned buttons
__MAKE_BUTTON Button.DOWN '                                  +------------------------------------------------------+
__MAKE_BUTTON Button.RIGHT '                                 | 05/16/23                                             |
__MAKE_BUTTON Button.LEFT '                                  | Buttons must now be defined before they can be used. |
__MAKE_BUTTON Button.FIRE '                                  | This change was necessary to allow saved button      |
__MAKE_BUTTON Button.RUN '                                   | assignments to be loaded at program start.           |
__MAKE_BUTTON Button.JUMP '                                  +------------------------------------------------------+
__MAKE_BUTTON Button.CROUCH
__MAKE_BUTTON Button.F1
__MAKE_BUTTON Button.F2
__MAKE_BUTTON Button.F3
__MAKE_BUTTON Button.F4
__MAKE_BUTTON Button.F5
SET_DEFAULT_BUTTONS '                                        set default button inputs
__LOAD_BUTTONS '                                             load any preconfigured buttons saved
LOAD_ASSETS '                                                load demo graphics and sounds
INITIALIZE_VARIABLES '                                       initialize demo variables
SCREEN _NEWIMAGE(640, 480, 32) '                             create view screen
_SNDLOOP SNDSong '                                           play theme song

'+--------------------------+
'| Main program loop begins |
'+--------------------------+

DO '                                                         begin demo loop
    _LIMIT 30 '                                              30 frames per second
    IF __BUTTON_DOWN(Button.F1) THEN CONFIGURE_BUTTONS '     configure buttons if F1 pressed
    FrameCount = FrameCount + 1 '                            increment frame counter
    IF FrameCount = 31 THEN '                                has one second passed?

        '+----------------------------------------------+
        '| Check for controller changes once per second |
        '| No need to bog the game down constantly      |
        '+----------------------------------------------+

        FrameCount = 1 '                                     yes, reset frame counter
        Controller = __NEW_CONTROLLER(Action) '              get controller status
        IF Controller THEN '                                 has controller status changed?
            _SNDPLAY SNDConf '                               yes, play confirmation sound
            SELECT CASE Action '                             what changed?
                CASE __NEWCONTROLLER '                       a new controller was plugged in
                    __LOAD_BUTTONS '                         load controller's buttons if they exist
                CASE __UNPLUGGED '                           a controller was unplugged
                    __REMOVE_CONTROLLER Controller '         remove the controller's buttons
                CASE __PLUGGEDIN '                           a controller was plugged back in
                    __LOAD_BUTTONS '                         load the controller's buttons
            END SELECT
        END IF
    END IF
    UPDATE_MARIO '                                           update mario position
    DRAW_SCREEN '                                            draw demo screen
    MOVE_MARIO '                                             check for player inputs
LOOP UNTIL _KEYDOWN(27) '                                    leave demo when ESC pressed

'+-------------------------------+
'| Free assets from RAM and exit |
'+-------------------------------+

CLEANUP '                                                    remove all assets from memory
SYSTEM '                                                     return to OS

'______________________________________________________________________________________________________________________


' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB CONFIGURE_BUTTONS () '                                                                                                   CONFIGURE_BUTTONS |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Allows player to reconfigure keyboard keys, joystick/game pad buttons, and joystick/game pad axes as buttons.                                |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Button AS TYPE_BUTTON ' need access to buttons
    SHARED SNDSong AS LONG '       need access to theme song
    SHARED SNDConf AS LONG '       need access to configure sound
    DIM Menu(8) AS STRING '        horizontal line of menu text
    DIM MenuLine AS INTEGER '      current highlighted menu line
    DIM CreateMenu AS INTEGER '    -1 (TRUE) when menu needs recreated
    DIM m AS INTEGER '             menu counter
    DIM s AS INTEGER '             slot counter
    DIM KeyHit AS INTEGER '        player keyboard input using _KEYHIT
    DIM Hit AS INTEGER '           player keyboard input using INKEY$
    DIM F2Down AS INTEGER '        F2 key latch
    DIM F3Down AS INTEGER '        F3 key latch
    DIM F4Down AS INTEGER '        F4 key latch
    DIM Controller AS INTEGER '    controller(s) status
    DIM Action AS INTEGER '        controller action taken

    _KEYCLEAR '                                                                     clear all keyboard buffers
    __SET_AXIS_THRESHOLD .9 '                                                       set axis threshold to register as a button press
    __BUTTON_REASSIGN_ALLOWED '                                                     allow reassigning of buttons
    _SNDSTOP SNDSong '                                                              stop theme song
    _SNDPLAY SNDConf '                                                              play configure sound
    MenuLine = 1 '                                                                  highlight starts on line 1
    CreateMenu = -1 '                                                               menu needs creating
    DO '                                                                            begin main loop
        _LIMIT 30 '                                                                 don't hog the CPU
        CLS , _RGB32(92, 148, 252) '                                                clear screen with light blue
        Controller = __NEW_CONTROLLER(Action) '                                     check for controller status chagnes
        IF Controller THEN '                                                        was there a change in a controller status?

            '+----------------------------------------------------------+
            '| A new controller was plugged in, a previously unplugged  |
            '| controller has been plugged back in, or a controller has |
            '| been unplugged.                                          |
            '+----------------------------------------------------------+

            _SNDPLAY SNDConf '                                                      yes, play confirmation sound
            SELECT CASE Action '                                                    what changed?
                CASE __NEWCONTROLLER '                                              a new controller was plugged in
                    __LOAD_BUTTONS '                                                load controllers buttons if they exist
                CASE __UNPLUGGED '                                                  a conroller was unplugged
                    __REMOVE_CONTROLLER Controller '                                remove the controller's button assignments
                    CreateMenu = -1 '                                               the menu needs recreated
                CASE __PLUGGEDIN '                                                  a controller was plugged back in
                    __LOAD_BUTTONS '                                                load the controller's button assignments
                    CreateMenu = -1 '                                               the menu needs recreated
            END SELECT
        END IF
        IF NOT __BUTTON_DOWN(Button.F2) THEN F2Down = 0 '                           remember when F2 button released
        IF __BUTTON_DOWN(Button.F2) AND (NOT F2Down) THEN '                         was F2 key pressed?

            '+--------------------------------------------------------------------+
            '| F2: Player has selected to set buttons back to their default state |
            '+--------------------------------------------------------------------+

            SET_DEFAULT_BUTTONS '                                                   yes, set all buttons to default values
            CreateMenu = -1 '                                                       menu needs recreated
            _SNDPLAY SNDConf '                                                      play configure sound
            F2Down = -1 '                                                           remember that F2 button is down
        END IF
        IF NOT __BUTTON_DOWN(Button.F3) THEN F3Down = 0 '                           remember when F3 button released
        IF __BUTTON_DOWN(Button.F3) AND (NOT F3Down) THEN '                         was F3 key pressed?

            '+------------------------------------------------------------+
            '| F3: Player has selected to load button configuration files |
            '+------------------------------------------------------------+

            __LOAD_BUTTONS '                                                        yes, load saved button configurations
            CreateMenu = -1 '                                                       menu needs recreated
            _SNDPLAY SNDConf '                                                      play configure sound
            F3Down = -1 '                                                           remember that F3 button is down
        END IF
        IF NOT __BUTTON_DOWN(Button.F4) THEN F4Down = 0 '                           remember when F4 button released
        IF __BUTTON_DOWN(Button.F4) AND (NOT F4Down) THEN '                         was F4 key pressed?

            '+------------------------------------------------------------------+
            '| F4: Player has selected to save the current button configuration |
            '+------------------------------------------------------------------+

            __SAVE_BUTTONS '                                                        yes, save button configurations
            _SNDPLAY SNDConf '                                                      play configure sound
            F4Down = -1 '                                                           remember that F4 button is down
        END IF
        IF CreateMenu THEN '                                                        does menu need (re)created?

            '+-------------------------------+
            '| The menu lines need refreshed |
            '+-------------------------------+

            CreateMenu = 0 '                                                        yes, reset creation flag
            Menu(1) = "  UP      " '                                                create beginning of each menu item
            Menu(2) = "  DOWN    "
            Menu(3) = "  LEFT    "
            Menu(4) = "  RIGHT   "
            Menu(5) = "  JUMP    "
            Menu(6) = "  FIRE    "
            Menu(7) = "  RUN     "
            Menu(8) = "  CROUCH  "
            FOR s = 1 TO 4 '                                                        cycle through 4 slots
                Menu(1) = Menu(1) + " " + __BUTTON_NAME$(Button.UP, s) + " " '      add assigned button names to each menu line
                Menu(2) = Menu(2) + " " + __BUTTON_NAME$(Button.DOWN, s) + " "
                Menu(3) = Menu(3) + " " + __BUTTON_NAME$(Button.LEFT, s) + " "
                Menu(4) = Menu(4) + " " + __BUTTON_NAME$(Button.RIGHT, s) + " "
                Menu(5) = Menu(5) + " " + __BUTTON_NAME$(Button.JUMP, s) + " "
                Menu(6) = Menu(6) + " " + __BUTTON_NAME$(Button.FIRE, s) + " "
                Menu(7) = Menu(7) + " " + __BUTTON_NAME$(Button.RUN, s) + " "
                Menu(8) = Menu(8) + " " + __BUTTON_NAME$(Button.CROUCH, s) + " "
            NEXT s
        END IF

        '+---------------+
        '| Draw the menu |
        '+---------------+

        COLOR _RGB32(255, 255, 0), _RGB32(0, 0, 255) '                              yellow text on blue background
        _PRINTMODE _FILLBACKGROUND '                                                show the background color
        LOCATE 2, 25 '                                                              position cursor
        PRINT "                             " '                                     print header
        LOCATE 3, 25
        PRINT " CONFIGURE CONTROLLER INPUTS "
        LOCATE 4, 25
        PRINT "                             "
        LINE (192, 16)-(423, 63), _RGB32(255, 255, 0), B '                          draw a box around header
        COLOR _RGB32(0, 0, 0) '                                                     black text
        _PRINTMODE _KEEPBACKGROUND '                                                transparent text background
        LOCATE 6, 6 '                                                               draw input instructions
        PRINT "UP/DOWN: Select Row  F2 : Load Defaults  F3: Load Saved Buttons     "
        LOCATE 7, 6
        PRINT "ENTER  : Add Button  DEL: Remove Button  F4: Save Buttons  F5: Exit "
        LOCATE 9, 1
        PRINT
        PRINT "   ACTION      METHOD 1         METHOD 2         METHOD 3         METHOD 4     "
        PRINT
        FOR m = 1 TO 8 '                                                            cycle through 8 menu lines
            PRINT " ";
            IF m = MenuLine THEN '                                                  is this menu line highlighted?
                COLOR _RGB32(255, 255, 0), _RGB32(0, 0, 255) '                      yes, yellow text on blue background
                _PRINTMODE _FILLBACKGROUND '                                        show the background color
            END IF
            PRINT Menu(m) '                                                         print the menu line
            COLOR _RGB32(0, 0, 0) '                                                 black text
            _PRINTMODE _KEEPBACKGROUND '                                            transparent text background
            PRINT
        NEXT m
        FOR m = 135 TO 391 STEP 32 '                                                draw grid lines around menu items
            LINE (8, m)-(632, m + 32), _RGB32(0, 0, 0), B
        NEXT m
        LINE (83, 135)-(83, 423), _RGB32(0, 0, 0)
        LINE (219, 135)-(219, 423), _RGB32(0, 0, 0)
        LINE (355, 135)-(355, 423), _RGB32(0, 0, 0)
        LINE (491, 135)-(491, 423), _RGB32(0, 0, 0)
        KeyHit = _KEYHIT '                                                          get any key pressed by player
        IF KeyHit = 18432 THEN '                                                    was the UP ARROW key pressed?

            '+---------------------------------+
            '| Player pressed the UP ARROW key |
            '+---------------------------------+

            MenuLine = MenuLine - 1 '                                               yes, move highlight up one line
            IF MenuLine = 0 THEN MenuLine = 1 '                                     keep highlight at top if necessary
        ELSEIF KeyHit = 20480 THEN '                                                no, was the DOWN ARROW key pressed?

            '+-----------------------------------+
            '| Player pressed the DOWN ARROW key |
            '+-----------------------------------+

            MenuLine = MenuLine + 1 '                                               yes, move highlight down one line
            IF MenuLine = 9 THEN MenuLine = 8 '                                     keep highlight at bottom if necessary
        ELSEIF KeyHit = 21248 THEN '                                                no, was the DELETE key pressed?

            '+----------------------------+
            '| Player pressed the DEL key |
            '+----------------------------+

            COLOR _RGB32(255, 255, 0), _RGB32(255, 0, 0) '                          yes, yellow text on red background
            _PRINTMODE _FILLBACKGROUND '                                            show the background color
            LOCATE 29, 15 '                                                         position cursor
            PRINT " PRESS 1, 2, 3, or 4 TO REMOVE METHOD FROM ACTION "; '           display instructions
            _DISPLAY '                                                              update screen to show instructions
            DO '                                                                    begin key press loop
                _LIMIT 30 '                                                         don't hog the CPU
                Hit = VAL(INKEY$) '                                                 get value of any key pressed
            LOOP UNTIL Hit '                                                        leave when value not equal to zero
            IF Hit >= 1 AND Hit <= 4 THEN '                                         is value between 1 and 4?
                CreateMenu = -1 '                                                   yes, the menu will need recreated
                SELECT CASE MenuLine '                                              which menu line is highlighted?
                    CASE 1 '                                                        line 1
                        __REMOVE_BUTTON Button.UP, Hit '                            remove button from chosen slot
                    CASE 2 '                                                        line 2
                        __REMOVE_BUTTON Button.DOWN, Hit '                          remove button from chosen slot
                    CASE 3 '                                                        line 3
                        __REMOVE_BUTTON Button.LEFT, Hit '                          etc..
                    CASE 4
                        __REMOVE_BUTTON Button.RIGHT, Hit
                    CASE 5
                        __REMOVE_BUTTON Button.JUMP, Hit
                    CASE 6
                        __REMOVE_BUTTON Button.FIRE, Hit
                    CASE 7
                        __REMOVE_BUTTON Button.RUN, Hit
                    CASE 8
                        __REMOVE_BUTTON Button.CROUCH, Hit
                END SELECT
                _SNDPLAY SNDConf '                                                  play configure sound
            END IF
            _KEYCLEAR '                                                             clear all keyboard buffers
        ELSEIF KeyHit = 13 THEN '                                                   no, was the ENTER key pressed?

            '+------------------------------+
            '| Player pressed the ENTER key |
            '+------------------------------+

            COLOR _RGB32(255, 255, 0), _RGB32(255, 0, 0) '                          yes, yellow text on red background
            _PRINTMODE _FILLBACKGROUND '                                            show background color
            LOCATE 29, 12 '                                                         position cursor
            PRINT " SELECT KEYBOARD KEY, JOYSTICK AXIS, OR JOYSTICK BUTTON "; '     display instructions
            _DISPLAY '                                                              update display to show instructions
            CreateMenu = -1 '                                                       the menu will need recreated
            SELECT CASE MenuLine '                                                  which menu line is highlighted?
                CASE 1 '                                                            line 1
                    __AUTOASSIGN_BUTTON Button.UP '                                 assign button/axis to UP button
                CASE 2 '                                                            line 2
                    __AUTOASSIGN_BUTTON Button.DOWN '                               assign button/axis to DOWN button
                CASE 3 '                                                            line 3
                    __AUTOASSIGN_BUTTON Button.LEFT '                               etc..
                CASE 4
                    __AUTOASSIGN_BUTTON Button.RIGHT
                CASE 5
                    __AUTOASSIGN_BUTTON Button.JUMP
                CASE 6
                    __AUTOASSIGN_BUTTON Button.FIRE
                CASE 7
                    __AUTOASSIGN_BUTTON Button.RUN
                CASE 8
                    __AUTOASSIGN_BUTTON Button.CROUCH
            END SELECT
            _SNDPLAY SNDConf '                                                      play configure sound
        END IF
        _DISPLAY '                                                                  update screen with changes
    LOOP UNTIL __BUTTON_DOWN(Button.F5) '                                           leave when F5 key pressed
    _SNDLOOP SNDSong '                                                              start theme song again

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB CLEANUP () '                                                                                                                       CLEANUP |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Removes all sounds and graphics from RAM. (Always clean up after yourself before exiting program)                                            |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Sprite() AS LONG '   need access to sprite images
    SHARED WorkScreen AS LONG ' need access to work screen
    SHARED BackGround AS LONG ' need access to background image
    SHARED MysteryBox AS LONG ' need access to mystery box image
    SHARED SNDBump AS LONG '    need access to all sounds
    SHARED SNDCoin AS LONG
    SHARED SNDConf AS LONG
    SHARED SNDFire AS LONG
    SHARED SNDJump AS LONG
    SHARED SNDSong AS LONG
    DIM i AS INTEGER '          generic counter
    DIM j AS INTEGER '          generic counter

    SCREEN 0, 0, 0, 0 '                                    go to pure text screen
    CLS '                                                  clear screen
    _SNDCLOSE SNDBump '                                    remove sounds from RAM
    _SNDCLOSE SNDCoin
    _SNDCLOSE SNDFire
    _SNDCLOSE SNDJump
    _SNDCLOSE SNDSong
    _SNDCLOSE SNDConf
    _FREEIMAGE WorkScreen '                                remove images from RAM
    _FREEIMAGE BackGround
    _FREEIMAGE MysteryBox
    FOR i = 1 TO 7
        FOR j = 1 TO 6
            IF Sprite(i, j) THEN _FREEIMAGE Sprite(i, j) ' remove sprite images from RAM
        NEXT j
    NEXT i

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB SPAWN_COIN () '                                                                                                                 SPAWN_COIN |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Spawns a coin.                                                                                                                               |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Coins() AS TYPE_COIN '  need access to coin array
    SHARED Box AS TYPE_RECTANGLE ' need access to mystery box coordinates
    SHARED SNDCoin AS LONG '       need access to coin sound
    DIM c AS INTEGER '             coin counter

    c = 0 '                                              reset coin counter
    DO '                                                 loop through coin array
        c = c + 1 '                                      increment coin counter
    LOOP UNTIL Coins(c).InUse = 0 OR c = UBOUND(Coins) ' leave when array scannded
    IF Coins(c).InUse THEN '                             if index in use then all indexes used
        c = c + 1 '                                      increment coin counter
        REDIM _PRESERVE Coins(c) AS TYPE_COIN '          increase size of coin array
    END IF
    _SNDPLAY SNDCoin '                                   play coin sound
    Coins(c).InUse = -1 '                                mark this index in use
    Coins(c).y = Box.y1 + 7 '                            calculate y coordinate of coin
    Coins(c).vector = -5 '                               set initial vertical vector

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB UPDATE_COINS () '                                                                                                             UPDATE_COINS |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Updates the position of active coins and draws them to the screen.                                                                           |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Sprite() AS LONG '      need access to sprite images
    SHARED Coins() AS TYPE_COIN '  need access to coin array
    SHARED Box AS TYPE_RECTANGLE ' need access to mystery box coordinates
    DIM c AS INTEGER '             coin counter

    c = 0 '                                                    reset coin counter
    DO '                                                       loop through coin array
        c = c + 1 '                                            increment coin counter
        IF Coins(c).InUse THEN '                               is this coin in use?
            Coins(c).y = Coins(c).y + Coins(c).vector '        yes, update coin y coordinate
            Coins(c).vector = Coins(c).vector * .91 '          decrease vertical vector amount slightly
            _PUTIMAGE (Box.x1, Coins(c).y), Sprite(COIN, 1) '  draw coin to screen
            IF Coins(c).y < 1 THEN Coins(c).InUse = 0 '        deactivate coin when it reaches top of screen
        END IF
    LOOP UNTIL c = UBOUND(Coins) '                             leave when array scanned

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB DRAW_SCREEN () '                                                                                                               DRAW_SCREEN |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Brings all the components together to create one frame of the demo.                                                                          |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Sprite() AS LONG '    need access to sprite images
    SHARED Mario AS TYPE_MARIO ' need access to mario properties
    SHARED WorkScreen AS LONG '  need access to the work screen
    SHARED BackGround AS LONG '  need access to the background image
    SHARED MysteryBox AS LONG '  need access to the mystery box image

    '+--------------------+
    '| Update view screen |
    '+--------------------+

    _DEST WorkScreen '                                                                                               draw on work screen
    _PUTIMAGE , BackGround, WorkScreen '                                                                             erase work screen with background
    _PRINTMODE _KEEPBACKGROUND '                                                                                     transparent text background
    LOCATE 1, 6 '                                                                                                    position cursor
    COLOR _RGB32(0, 0, 0) '                                                                                          black text
    PRINT "PRESS F1 TO CONFIGURE BUTTONS" '                                                                          print instructions
    IF Mario.Facing = -1 THEN '                                                                                      is mario facing left?
        _PUTIMAGE (Mario.Rect.x2, Mario.Rect.y1)-(Mario.Rect.x1, Mario.Rect.y2), Sprite(Mario.Action, Mario.Frame) ' yes, flip sprite horizontally
    ELSE '                                                                                                           no, mario is facing right
        _PUTIMAGE (Mario.Rect.x1, Mario.Rect.y1), Sprite(Mario.Action, Mario.Frame) '                                draw sprite as drawn
    END IF
    UPDATE_BULLETS '                                                                                                 draw active bullets
    UPDATE_COINS '                                                                                                   draw active coins
    _PUTIMAGE (144, 48), MysteryBox '                                                                                draw mystery box
    _DEST 0 '                                                                                                        draw on view screen
    _PUTIMAGE , WorkScreen '                                                                                         stretch work screen (zoom 2X)
    _DISPLAY '                                                                                                       update view screen with changes

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB UPDATE_MARIO () '                                                                                                             UPDATE_MARIO |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Updates mario's position on screen and checks for collision between mario and mystery box.                                                   |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Mario AS TYPE_MARIO '   need access to mario properties
    SHARED Box AS TYPE_RECTANGLE ' need access to mystery box coordinates
    SHARED FPSFrame AS INTEGER '   need access to master frame counter
    SHARED SNDBump AS LONG '       need access to bump sound

    FPSFrame = FPSFrame + 1 '                                                  increment master frame counter
    IF FPSFrame = 31 THEN FPSFrame = 1 '                                       reset master frame counter when needed
    Mario.x = Mario.x + Mario.Direction * Mario.Speed '                        update mario x position
    IF Mario.x >= 336 THEN Mario.x = Mario.x - 336 '                           move mario to left side of screen
    IF Mario.x <= -16 THEN Mario.x = Mario.x + 336 '                           move mario to right side of screen

    '+---------------------------------+
    '| Calculate mario sprite location |
    '+---------------------------------+

    Mario.Rect.x1 = Mario.x - 15 '                                             calculate mario rectangular coordinates
    Mario.Rect.y1 = Mario.y - 63
    Mario.Rect.x2 = Mario.Rect.x1 + 31
    Mario.Rect.y2 = Mario.Rect.y1 + 63
    IF COLLISION(Mario.Rect, Box) THEN '                                       has mario collided with mystery box?
        _SNDPLAY SNDBump '                                                     play bump sound

        '+-------------------------------------+
        '| Mario has collided with mystery box |
        '+-------------------------------------+

        IF Mario.x < Box.x1 - 8 THEN '                                         yes, is mario at left side of box?

            '+----------------------------+
            '| Mario hit left side of box |
            '+----------------------------+

            Mario.Direction = 0 '                                              yes, stop mario movement
            Mario.x = Box.x1 - 17 '                                            position mario at left side of box
        ELSEIF Mario.x > Box.x2 + 8 THEN '                                     no, is mario at right side of box?

            '+-----------------------------+
            '| Mario hit right side of box |
            '+-----------------------------+

            Mario.Direction = 0 '                                              yes, stop mario movement
            Mario.x = Box.x2 + 16 '                                            position mario at right side of box
        ELSE '                                                                 no, must have hit box from underneath

            '+-------------------------------+
            '| Mario hit box from underneath |
            '+-------------------------------+

            SPAWN_COIN '                                                       create a coin
            Mario.y = Box.y2 + 64 '                                            position mario just underneath box
            Mario.Yvel = 0 '                                                   stop upward movement

        END IF

        '+-----------------------------------+
        '| Recalculate mario sprite location |
        '+-----------------------------------+

        Mario.Rect.x1 = Mario.x - 15 '                                         recalculate mario rectangular coordinates
        Mario.Rect.y1 = Mario.y - 63
        Mario.Rect.x2 = Mario.Rect.x1 + 31
        Mario.Rect.y2 = Mario.Rect.y1 + 63
    END IF

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB MOVE_MARIO () '                                                                                                                 MOVE_MARIO |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Moves mario according to player input.                                                                                                       |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Mario AS TYPE_MARIO '   need access to mario properties
    SHARED Button AS TYPE_BUTTON ' need access to buttons
    SHARED FPSFrame AS INTEGER '   need access to master frame counter
    SHARED SNDJump AS LONG '       need access to jump sound

    '+-------------------------------+
    '| Check for button/axis presses |
    '+-------------------------------+

    IF __BUTTON_DOWN(Button.FIRE) THEN FIRE_BULLET '                           fire a bullet
    IF NOT Mario.Jumping THEN '                                                is mario currently jumping?

        '+---------------------------------------------------+
        '| Must not be jumping to walk, run, jump, or crouch |
        '+---------------------------------------------------+

        IF __BUTTON_DOWN(Button.LEFT) THEN '                                   no, is player pressing a left button?

            '+--------------------+
            '| Walk and face left |
            '+--------------------+

            Mario.Walking = -1 '                                               yes, remember that mario is walking
            Mario.Direction = -1 '                                             mario is walking to the left
            Mario.Facing = -1 '                                                mario is facing left
            Mario.Action = WALK '                                              use walking sprites
            IF FPSFrame MOD Mario.FPS = 0 THEN Mario.Frame = Mario.Frame + 1 ' increment to next walking animation frame
            IF Mario.Frame = 7 THEN Mario.Frame = 1 '                          reset animation frame counter when necessary
        ELSEIF __BUTTON_DOWN(Button.RIGHT) THEN '                              no, is player pressing a right button?

            '+---------------------+
            '| Walk and face right |
            '+---------------------+

            Mario.Walking = -1 '                                               yes, remember that mario is walking
            Mario.Direction = 1 '                                              mario is walking to the right
            Mario.Facing = 1 '                                                 mario is facing right
            Mario.Action = WALK '                                              use walking sprites
            IF FPSFrame MOD Mario.FPS = 0 THEN Mario.Frame = Mario.Frame + 1 ' increment to next walking animation frame
            IF Mario.Frame = 7 THEN Mario.Frame = 1 '                          reset animation frame counter when necessary
        ELSE '                                                                 no, mario is standing still

            '+--------------+
            '| Stop walking |
            '+--------------+

            Mario.Action = STAND '                                             use standing sprite
            Mario.Frame = 1 '                                                  reset animation frame counter (sprite only has 1 frame)
            Mario.Direction = 0 '                                              mario is standing still
            Mario.Walking = 0 '                                                remember that mario is not walking
        END IF
        IF Mario.Walking THEN '                                                is mario currently walking?

            '+--------------------------------+
            '| Must be walking before running |
            '+--------------------------------+

            IF __BUTTON_DOWN(Button.RUN) THEN '                                yes, is player pressing a run button?

                '+---------------+
                '| Start running |
                '+---------------+

                IF NOT Mario.Running THEN '                                    yes, is mario already running?
                    Mario.Action = RUNSTART '                                  no, use getting ready to run sprite
                    Mario.Frame = 1 '                                          reset animation frame counter (sprite only has 1 frame)
                    Mario.RunTimer = Mario.RunTimer + 1 '                      increment getting ready to run timer
                    IF Mario.RunTimer = 5 THEN Mario.Running = -1 '            start mario running after 5 frames have passed
                    Mario.Direction = 0 '                                      mario stands still during these 5 frames
                ELSE '                                                         yes, mario is already running
                    Mario.Speed = 4 '                                          set mario speed
                    Mario.FPS = 2 '                                            set animation frames per second (15 FPS)
                END IF
            ELSE '                                                             no, a run button is not being pressed

                '+--------------+
                '| Stop running |
                '+--------------+

                Mario.Speed = 2 '                                              set mario speed
                Mario.FPS = 5 '                                                set animation frames per second (6 FPS)
                Mario.Running = 0 '                                            mario is no longer running
                Mario.RunTimer = 0 '                                           reset getting ready to run timer
            END IF
        END IF
        IF __BUTTON_DOWN(Button.CROUCH) OR __BUTTON_DOWN(Button.DOWN) THEN '   is player pressing a button to crouch?
            Mario.Action = CROUCH '                                            yes, use crouching sprite
            Mario.Frame = 1 '                                                  reset animation frame counter (sprite only has 1 frame)
            Mario.Direction = 0 '                                              mario is standing still
        ELSEIF __BUTTON_DOWN(Button.JUMP) OR __BUTTON_DOWN(Button.UP) THEN '   no, is player pressing a button to jump?
            _SNDPLAY SNDJump '                                                 play jump sound
            Mario.Jumping = -1 '                                               yes, mario is now jumping
            Mario.Yvel = -5 '                                                  set vertical velocity
            Mario.Vector = -1 '                                                set vertical vector direction
            Mario.Action = JUMP '                                              use jumping sprite
            Mario.Frame = 1 '                                                  reset animation frame counter (sprite only has 1 frame)
        END IF
    ELSE '                                                                     yes, mario is currently jumping

        '+---------------------------+
        '| Perform jump arc sequence |
        '+---------------------------+

        Mario.Vector = Mario.Vector + .2 '                                     increment vertical vector direction (will change direction at 0)
        Mario.Yvel = Mario.Yvel + Mario.Vector '                               add vector quantity to vertical velocity
        Mario.y = Mario.y + Mario.Yvel '                                       add vertical velocity to mario y coordinate
        IF Mario.y >= Mario.Floor THEN '                                       has mario hit floor on way down?

            '+--------------+
            '| Stop jumping |
            '+--------------+

            Mario.Jumping = 0 '                                                yes, mario is no longer jumping
            Mario.y = Mario.Floor '                                            place mario onto floor
        END IF
    END IF

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB UPDATE_BULLETS () '                                                                                                         UPDATE_BULLETS |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Updates location of active bullets and draws them to the screen.                                                                             |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Mario AS TYPE_MARIO '       need access to mario properties
    SHARED Sprite() AS LONG '          need access to sprite images
    SHARED Bullets() AS TYPE_BULLET '  need access to bullet array
    SHARED BulletTimer AS INTEGER '    need access to bullet timer
    DIM b AS INTEGER '                 bullet counter

    IF BulletTimer THEN BulletTimer = BulletTimer - 1 '                                           decrement bullet timer if needed
    b = 0 '                                                                                       reset bullet counter
    DO '                                                                                          loop through bullet array
        b = b + 1 '                                                                               increment bullet counter
        IF Bullets(b).InUse THEN '                                                                is this bullet active?
            Bullets(b).x = Bullets(b).x + Bullets(b).Direction * 6 '                              yes, update bullet x coordinate
            IF Bullets(b).y < Mario.Floor - 9 THEN '                                              has bullet reached the floor?
                Bullets(b).y = Bullets(b).y + 3 '                                                 no, add to the bullet's y coordinate
            ELSE '                                                                                yes, bullet at floor
                Bullets(b).y = Bullets(b).y - 4 '                                                 bounce bullet back up
            END IF
            IF Bullets(b).x > 336 OR Bullets(b).x < -16 THEN '                                    has bullet left screen?
                Bullets(b).InUse = 0 '                                                            yes, this bullet no longer active
            ELSE '                                                                                no, bullet still on screen
                _PUTIMAGE (Bullets(b).x - 16, Bullets(b).y - 16), Sprite(FIRE, Bullets(b).Cell) ' draw bullet
                Bullets(b).Cell = Bullets(b).Cell + 1 '                                           increment animation cell
                IF Bullets(b).Cell = 5 THEN Bullets(b).Cell = 1 '                                 reset animation cell when needed
            END IF
        END IF
    LOOP UNTIL b = UBOUND(Bullets) '                                                              leave when array scanned

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB FIRE_BULLET () '                                                                                                               FIRE_BULLET |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Fires a bullet.                                                                                                                              |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Mario AS TYPE_MARIO '      need access to mario properties
    SHARED Bullets() AS TYPE_BULLET ' need access to bullet array
    SHARED BulletTimer AS INTEGER '   need access to bullet timer
    SHARED SNDFire AS LONG '          need access to bullet sound
    DIM b AS INTEGER '                bullet counter

    IF BulletTimer THEN EXIT SUB '                           leave if not time to fire bullet
    BulletTimer = 10 '                                       must wait 10 frames between bullets (3 rounds per second)
    b = 0 '                                                  reset bullet counter
    DO '                                                     loop through bullet array
        b = b + 1 '                                          increment bullet counter
    LOOP UNTIL Bullets(b).InUse = 0 OR b = UBOUND(Bullets) ' leave when array scanned
    IF Bullets(b).InUse THEN '                               if this index in use then all indexes used
        b = b + 1 '                                          increment bullet counter
        REDIM _PRESERVE Bullets(b) AS TYPE_BULLET '          increase size of array
    END IF
    Bullets(b).InUse = -1 '                                  mark this index in use
    _SNDPLAY SNDFire '                                       play bullet sound
    IF Mario.Facing = 1 THEN '                               mario facing right?
        Bullets(b).x = Mario.Rect.x2 '                       yes, bullet comes from right side of mario
    ELSE '                                                   no, mario facing left
        Bullets(b).x = Mario.Rect.x1 '                       bullet comes from left side of mario
    END IF
    Bullets(b).y = Mario.Rect.y1 + 31 '                      bullet comes from vertical center of mario
    Bullets(b).Direction = Mario.Facing '                    remember bullet direction
    Bullets(b).Cell = 1 '                                    animation frame 1

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
FUNCTION COLLISION (R1 AS TYPE_RECTANGLE, R2 AS TYPE_RECTANGLE) '                                                                    COLLISION |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Detects and reports a collision between two rectangular areas provided, -1 (TRUE) if in collision, 0 (FALSE) otherwise.                      |
    '|                                                                                                                                              |
    '| R1 - rectangle 1                                                                                                                             |
    '| R2 - rectangle 2                                                                                                                             |
    '\______________________________________________________________________________________________________________________________________________/

    COLLISION = 0 '                      assume no collision
    IF R1.x2 >= R2.x1 THEN '             does R1 overlap R2?
        IF R1.x1 <= R2.x2 THEN
            IF R1.y2 >= R2.y1 THEN
                IF R1.y1 <= R2.y2 THEN
                    COLLISION = -1 '     yes, report rectangles in state of collision
                END IF
            END IF
        END IF
    END IF

END FUNCTION
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB SET_DEFAULT_BUTTONS () '                                                                                               SET_DEFAULT_BUTTONS |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Sets the default buttons. Will use keyboard and/or joystick 1(optional) if they are detected.                                                |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Button AS TYPE_BUTTON ' need access to button array
    STATIC Configured AS INTEGER ' -1 when buttons previously created and configured

    '+-----------------------------------+
    '| Clear previous button assignments |
    '+-----------------------------------+

    IF Configured THEN '                                             have buttons been created and configured
        __REMOVE_BUTTON Button.UP, 0 '                               yes, clear all previous button assignments
        __REMOVE_BUTTON Button.DOWN, 0
        __REMOVE_BUTTON Button.LEFT, 0
        __REMOVE_BUTTON Button.RIGHT, 0
        __REMOVE_BUTTON Button.FIRE, 0
        __REMOVE_BUTTON Button.RUN, 0
        __REMOVE_BUTTON Button.JUMP, 0
        __REMOVE_BUTTON Button.CROUCH, 0
    END IF

    '+-------------------------------------------------------+
    '| Configure keyboard keys as buttons if keyboard exists |
    '+-------------------------------------------------------+

    IF __KEYBOARD_EXISTS THEN '                                      does keyboard exist?
        __ASSIGN_BUTTON Button.UP, __KEYBOARDCID, CLKEY_W '          UP       = W KEY               [SLOT1]
        __ASSIGN_BUTTON Button.DOWN, __KEYBOARDCID, CLKEY_S '        DOWN     = S KEY               [SLOT1]
        __ASSIGN_BUTTON Button.LEFT, __KEYBOARDCID, CLKEY_A '        LEFT     = A KEY               [SLOT1]
        __ASSIGN_BUTTON Button.RIGHT, __KEYBOARDCID, CLKEY_D '       RIGHT    = D KEY               [SLOT1]
        __ASSIGN_BUTTON Button.FIRE, __KEYBOARDCID, CLKEY_RCTRL '    FIRE     = RIGHT CONTROL KEY   [SLOT1]
        __ASSIGN_BUTTON Button.RUN, __KEYBOARDCID, CLKEY_RSHIFT '    RUN      = RIGHT SHIFT KEY     [SLOT1]
        __ASSIGN_BUTTON Button.JUMP, __KEYBOARDCID, CLKEY_SPACEBAR ' JUMP     = SPACE BAR KEY       [SLOT1]
        __ASSIGN_BUTTON Button.CROUCH, __KEYBOARDCID, CLKEY_C '      CROUCH   = C KEY               [SLOT1]

        '+----------------------+
        '| Optional assignments |
        '+----------------------+

        '__ASSIGN_BUTTON Button.UP, __KEYBOARDCID, CLKEY_UP '         UP       = UP ARROW KEY        [SLOT2]
        '__ASSIGN_BUTTON Button.DOWN, __KEYBOARDCID, CLKEY_DOWN '     DOWN     = DOWN ARROW KEY      [SLOT2]
        '__ASSIGN_BUTTON Button.LEFT, __KEYBOARDCID, CLKEY_LEFT '     LEFT     = LEFT ARROW KEY      [SLOT2]
        '__ASSIGN_BUTTON Button.RIGHT, __KEYBOARDCID, CLKEY_RIGHT '   RIGHT    = RIGHT ARROW KEY     [SLOT2]
        '__ASSIGN_BUTTON Button.FIRE, __KEYBOARDCID, CLKEY_LCTRL '    FIRE     = LEFT CONTROL KEY    [SLOT2]
    END IF

    '+---------------------------------------------------------------+
    '| Configure joystick 1 axes and buttons if it exists (optional) |
    '+---------------------------------------------------------------+

    'IF __JOYPAD_EXISTS(1) THEN '                                                                   does joystick 1 exist?
    '    __ASSIGN_AXIS Button.UP, __JOYPAD1CID, -2 '                                                UP       = JOYSTICK 1 AXIS 2   [SLOT3 or 1]
    '    __ASSIGN_AXIS Button.DOWN, __JOYPAD1CID, 2 '                                               DOWN     = JOYSTICK 1 AXIS 2   [SLOT3 or 1]
    '    __ASSIGN_AXIS Button.LEFT, __JOYPAD1CID, -1 '                                              LEFT     = JOYSTICK 1 AXIS 1   [SLOT3 or 1]
    '    __ASSIGN_AXIS Button.RIGHT, __JOYPAD1CID, 1 '                                              RIGHT    = JOYSTICK 1 AXIS 1   [SLOT3 or 1]
    '    __ASSIGN_BUTTON Button.FIRE, __JOYPAD1CID, 1 '                                             FIRE     = JOYSTICK 1 BUTTON 1 [SLOT3 or 1]
    '    IF __BUTTON_TOTAL(__JOYPAD1CID) > 1 THEN __ASSIGN_BUTTON Button.JUMP, __JOYPAD1CID, 2 '    JUMP     = JOYSTICK 1 BUTTON 2 [SLOT2 or 1]
    '    IF __BUTTON_TOTAL(__JOYPAD1CID) > 2 THEN __ASSIGN_BUTTON Button.RUN, __JOYPAD1CID, 3 '     RUN      = JOYSTICK 1 BUTTON 4 [SLOT2 or 1]
    '    IF __BUTTON_TOTAL(__JOYPAD1CID) >= 3 THEN __ASSIGN_BUTTON Button.CROUCH, __JOYPAD1CID, 4 ' CROUCH   = JOYSTICK 1 BUTTON 5 [SLOT2 or 1]
    'END IF
    Configured = -1 '                                                buttons have been created and configured

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB LOAD_ASSETS () '                                                                                                               LOAD_ASSETS |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Load the demo's graphics and sounds                                                                                                          |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Sprite() AS LONG '   need access to sprite images
    SHARED WorkScreen AS LONG ' need access to work screen
    SHARED BackGround AS LONG ' need access to background image
    SHARED MysteryBox AS LONG ' need access to mystery box image
    SHARED SNDBump AS LONG '    need access to sounds
    SHARED SNDCoin AS LONG
    SHARED SNDConf AS LONG
    SHARED SNDFire AS LONG
    SHARED SNDJump AS LONG
    SHARED SNDSong AS LONG
    DIM Sheet AS LONG '         demo sprite sheet
    DIM Ground AS LONG '        ground square image
    DIM i AS INTEGER '          generic counter

    SNDBump = _SNDOPEN("CB_Bump.ogg") '                                                      load sounds
    SNDCoin = _SNDOPEN("CB_Coin.ogg")
    SNDFire = _SNDOPEN("CB_Fire.ogg")
    SNDJump = _SNDOPEN("CB_Jump.ogg")
    SNDSong = _SNDOPEN("CB_Song.ogg")
    SNDConf = _SNDOPEN("CB_Conf.ogg")
    Sheet = _LOADIMAGE("CBDemo.PNG", 32) '                                                   sprite sheet image
    WorkScreen = _NEWIMAGE(320, 240, 32) '                                                   work screen image
    BackGround = _NEWIMAGE(320, 240, 32) '                                                   background image
    Sprite(STAND, 1) = _NEWIMAGE(32, 64, 32) '                                               standing image
    Sprite(CROUCH, 1) = _NEWIMAGE(32, 64, 32) '                                              crouching image
    Sprite(RUNSTART, 1) = _NEWIMAGE(32, 64, 32) '                                            ready to run image
    Sprite(JUMP, 1) = _NEWIMAGE(32, 64, 32) '                                                jumping image
    MysteryBox = _NEWIMAGE(32, 32, 32) '                                                     mystery box image
    Sprite(COIN, 1) = _NEWIMAGE(32, 32, 32) '                                                coin image
    Ground = _NEWIMAGE(32, 32, 32) '                                                         ground image
    _PUTIMAGE , Sheet, MysteryBox, (128, 64)-(159, 95) '                                     get mystery box image from sprite sheet
    _PUTIMAGE , Sheet, Sprite(COIN, 1), (160, 64)-(191, 95) '                                get coin image from sprite sheet
    _PUTIMAGE , Sheet, Ground, (192, 64)-(223, 95) '                                         get ground image from sprite sheet
    _PUTIMAGE , Sheet, Sprite(STAND, 1), (0, 0)-(31, 64) '                                   get standing image from sprite sheet
    _PUTIMAGE , Sheet, Sprite(CROUCH, 1), (32, 0)-(63, 63) '                                 get crouching image from sprite sheet
    _PUTIMAGE , Sheet, Sprite(RUNSTART, 1), (64, 0)-(95, 63) '                               get ready to run image from sprite sheet
    _PUTIMAGE , Sheet, Sprite(JUMP, 1), (288, 0)-(319, 63) '                                 get jumping image from sprite sheet
    FOR i = 1 TO 6 '                                                                         cycle through 6 animation cells
        Sprite(WALK, i) = _NEWIMAGE(32, 64, 32) '                                            walking animation image cell
        _PUTIMAGE , Sheet, Sprite(WALK, i), (64 + i * 32, 0)-(95 + i * 32, 63) '             get walking animation cell from sprite sheet
        IF i < 5 THEN '                                                                      cycle through 4 animation cells
            Sprite(FIRE, i) = _NEWIMAGE(32, 32, 32) '                                        bullet animation image cell
            _PUTIMAGE , Sheet, Sprite(FIRE, i), ((i - 1) * 32, 64)-((i - 1) * 32 + 31, 95) ' get bullet animation cell from sprite sheet
        END IF
    NEXT i
    _DEST BackGround '                                                                       draw on background image
    CLS , _RGB32(0, 255, 0) '                                                                clear background image in green
    FOR i = 0 TO 288 STEP 32 '                                                               cycle through the floor area
        _PUTIMAGE (i, 176), Ground '                                                         draw the floor ground blocks
        _PUTIMAGE (i, 208), Ground
    NEXT i
    _FREEIMAGE Ground '                                                                      ground image no longer needed
    _FREEIMAGE Sheet '                                                                       sprite sheet no longer needed
    _DEST 0 '                                                                                return to main screen

END SUB
' _____________________________________________________________________________________________________________________________________________
'/                                                                                                                                             \
SUB INITIALIZE_VARIABLES () '                                                                                             INITIALIZE_VARIABLES |
    ' _________________________________________________________________________________________________________________________________________|____
    '/                                                                                                                                              \
    '| Initialize all demo variables                                                                                                                |
    '\______________________________________________________________________________________________________________________________________________/

    SHARED Button AS TYPE_BUTTON ' need access to buttons
    SHARED Mario AS TYPE_MARIO '   need access to mario properties
    SHARED Box AS TYPE_RECTANGLE ' need access to box coordinates

    Mario.FPS = 5 '                                      mario animation speed
    Mario.Direction = 1 '                                mario travel direction (right)
    Mario.Facing = 1 '                                   mario facing direction (right)
    Mario.Floor = 176 '                                  floor that mario can't go beyond
    Mario.x = 159 '                                      x coordinate of mario (bottom center of sprite)
    Mario.y = Mario.Floor '                              y coordinate of mario (bottom center of sprite)
    Mario.Action = STAND '                               mario is currently standing
    Mario.Frame = 1 '                                    first animation frame
    Mario.Rect.x1 = Mario.x - 15 '                       calculate mario sprite rectangular coordinates
    Mario.Rect.y1 = Mario.y - 63
    Mario.Rect.x2 = Mario.Rect.x1 + 31
    Mario.Rect.y2 = Mario.Rect.y1 + 63
    Box.x1 = 144 '                                       mystery box rectangular coordinates
    Box.y1 = 48
    Box.x2 = Box.x1 + 31
    Box.y2 = Box.y1 + 31
    __ASSIGN_BUTTON Button.F1, __KEYBOARDCID, CLKEY_F1 ' F1 key
    __ASSIGN_BUTTON Button.F2, __KEYBOARDCID, CLKEY_F2 ' F2 key
    __ASSIGN_BUTTON Button.F3, __KEYBOARDCID, CLKEY_F3 ' F3 key
    __ASSIGN_BUTTON Button.F4, __KEYBOARDCID, CLKEY_F4 ' F4 key
    __ASSIGN_BUTTON Button.F5, __KEYBOARDCID, CLKEY_F5 ' F5 key
END SUB

'$INCLUDE:'CONTROLLER.BM'
'----------------------------
' Controller Library V1.10
' Terry Ritchie
' May 17th, 2023
' Written using QB64PE v3.7.0
'----------------------------
' CONTROLLER.BI
'----------------------------
'
' TODO: Add WHEEL routines
'       Create PDF instructions
'
'----------------------------
' 04/10/23 V1.0  - Initial Release
' 04/26/23 V1.01 - Corrected slot reassigning issues
' 05/17/23 V1.10 - Added __MAKE_BUTTON, __CONNECTED, __SAVE_BUTTONS, __LOAD_BUTTONS, __NEW_CONTROLLER, __REMOVE_CONTROLLER
'                - The library now has the ability to save and load controller user defined button configurations
'                - You can now detect when a controller has been plugged in or unplugged
'                - A controller's user defined button assignments can be removed when the controller has been unplugged
'----------------------------



' +---------------------------------------+
' |                                       |
' |     HOW QB64 HANDLES CONTROLLERS      |
' |                                       |
' +---------------------------------------+
'
' QB64's controller commands work by identifying the connected controllers at program start up using _DEVICES. This list of identified controllers can
' only be added to during program execution. If a controller is unplugged the controller's id number is not removed from the list. Instead, the
' controller will be listed as [DISCONNECTED] through _DEVICE$. When the controller is plugged back in the [DISCONNECTED] will be removed from the
' controller's identifying string returned by _DEVICE$.
'
' This library will support up to six controllers (see the list below in "INITIALIZING THE LIBRARY") connected at one time. The behavior above will only
' become an issue if your user, for whatever reason, has plugged in, and then unplugged, so many controllers that the device list contains all
' [DISCONNECTED] controllers and a new controller plugged in occupies id #7. That controller will not be detected, only the previous controllers the
' user plugged in. This scenario is highly unlikely but, users being users, it may happen. You can test for this condition by checking if _DEVICES is
' ever greater than 6.



' +---------------------------------------+
' |                                       |
' |       INITIALIZING THE LIBRARY        |
' |                                       |
' +---------------------------------------+
'
' The first subroutine that MUST be called is __INITIALIZE_CONTROLLERS. This subroutine initializes all the associated controller variables and
' identifies all connected controllers. Up to 6 total controllers can be detected and used:
'
' - 1 keyboard,  1 mouse,  and 4 joysticks/game pads
' - 1 leyboard,  no mouse, and 5 joysticks/game pads
' - no keyboard, 1 mouse,  and 5 joysticks/game pads
' - no keyboard, no mouse, and 6 joysticks/game pads
'
' Once the connected controllers have been identified the following shared integers will be set with controller ID numbers:
'
' __KEYBOARDCID      Always a value of 1 when a keyboard is detected
' __MOUSECID         Always a value of 2 if a keyboard is also present, 1 if no keyboard detected
' __JOYPAD1CID       The first joystick/game pad detected. Always a value of 3 if a keyboard and mouse present, 1 or 2 otherwise
' __JOYPAD2CID       The second joystick/game pad detected. Always a value of 4 if a keyboard and mouse present, 2 or 3 otherwise
' __JOYPAD3CID       The third joystick/game pad detected. Always a value of 5 if a keyboard and mouse present, 3 or 4 otherwise
' __JOYPAD4CID       The fourth joystick/game pad detected. Always a value of 6 if a keyboard and mouse present, 4 or 5 otherwise
' __JOYPAD5CID       The fifth joystick/game pad detected. ALWAYS A VALUE OF 5. Will only be detected if a keyboard or mouse is NOT present
' __JOYPAD6CID       The sixth joystick/game pad detected. ALWAYS A VALUE OF 6. Will only be detected if a keyboard and mouse are NOT present
'
' NOTE: If a certain controller is not found, for instance a mouse, then the corresponding variable will contain 0 (__MOUSECID = 0)
'
' These variables are now to be used to indentify the controller you wish to interact with. If a variable contains a value other than 0 the controller
' exists and will continue to exist until program termination.



' +---------------------------------------+
' |                                       |
' |        REDETECING CONTROLLERS         |
' |                                       |
' +---------------------------------------+
'
' If at any time you wish to rescan for currently connected controllers you can use this subroutine:
'
' __IDENTIFY_CONTROLLERS
'
' However, you'll more than likely never need to use this subroutine. The library is designed to automatically use __IDENTIFY_CONTROLLERS when a
' change in controller status occurs, such as a new controller plugged in, an existing controller unplugged, or an existing controller plugged back in.
' __INITIALIZE_CONTROLLERS automatically calls this subroutine as well.



' +---------------------------------------+
' |                                       |
' |       GET EXISTING CONTROLLERS        |
' |                                       |
' +---------------------------------------+
'
' The following functions can be used to determine the number and type of controllers found:
'
' __KEYBOARD_EXISTS         - determine if a keyboard controller was found, -1 (TRUE) or 0 (FALSE)
' __MOUSE_EXISTS            - determine if a mouse controller was found, -1 (TRUE) or 0 (FALSE)
' __JOYPAD_EXISTS(Number)   - determine if a joystick/game pad was found
'                             Number = the desired joystick/game pad to query (1 to 6)
'                             If the numbered game pad was found __JOYPAD_EXISTS returns the TOTAL NUMBER of joysticks/game pads found.
'
' Example:
'
' IF __KEYBOARD_EXISTS THEN PRINT "Found!" '                          was keyboard controller found?
' IF __MOUSE_EXISTS THEN PRINT "Found!" '                             was mouse controller found?
' NumberOfJoypads = __JOYPAD_EXISTS(__JOYPAD1CID) '                   query to determine if at least one joystick/game pad found
' IF NumberOfJoypads THEN '                                           at least 1 joystick found?
'     PRINT "Joystick 1 found!" '                                     yes, display result
'     PRINT "Total number of joysticks/game pads:"; NumberOfJoypads
' END IF



' +---------------------------------------+
' |                                       |
' |       GET CONTROLLER PROPERTIES       |
' |                                       |
' +---------------------------------------+
'
' The following functions can be used to query each controller for information:
'
' __CONTROLLER_NAME$(cid) - the descriptive name of the controller
' __BUTTON_TOTAL(cid)     - the number of buttons a controller has
' __AXIS_TOTAL(cid)       - the number of axes a controller has
'
' Example:
'
' IF __JOYPAD1CID THEN                                               ' or "IF __JOYPAD_EXISTS(1) THEN" would work as well
'     PRINT "Joystick 1 name  : "; __CONTROLLER_NAME$(__JOYPAD1CID)
'     PRINT "Buttons available:"; __BUTTON_TOTAL(__JOYPAD1CID)
'     PRINT "Axes available   :"; __AXIS_TOTAL(__JOYPAD1CID)
' END IF



' +---------------------------------------+
' |                                       |
' |       QUERY CONTROLLER DIRECTLY       |
' |                                       |
' +---------------------------------------+
'
' The following function can be used to determine if a controller is plugged in or unplugged:
'
' __CONNECTED(cid)
'
' The function will return a value of -1 (TRUE) if the controller is plugged in and 0 (FALSE) if the controller in unplugged.
'
' Example:
'
' IF __JOYPAD2CID THEN '                                      was joystick 2 detected at program startup?
'     IF __CONNECTED(__JOYPAD2CID) THEN '                     yes, is joystick 2 currently connected?
'         PRINT "Joystick 2 found and currently connected." ' yes, inform user
'     ELSE '                                                  no, joystick 2 has been unplugged
'         PRINT "Joystick 2 is currently unplugged." '        inform user
'     END IF
' END IF
'
' The following functions can be used to query buttons and axes directly from a controller:
'
' __CONTROLLER_BUTTON(cid, Button)
' __CONTROLLER_AXIS(cid, Axis)
'
' Example:
'
' IF __CONTROLLER_BUTTON(__JOYPAD1CID, 1) THEN '        is joystick button one down?
'     PRINT "Joystick button #1 pressed!" '             yes, report findings
' END IF
' IF __CONROLLER_BUTTON(__KEYBOARDCID, CLKEY_UP) THEN ' is keyboard UP ARROW key down?
'     PRINT "Keyboard UP ARROW key pressed!" '          yes, report findings
' END IF
' VerticalAxis = __CONTROLLER_AXIS(__JOYPAD1CID, 1) '   get current vertical axis of joystick/game pad 1



' +---------------------------------------+
' |                                       |
' |     RETRIEVING CONTROLLER EVENTS      |
' |                                       |
' +---------------------------------------+
'
' The __NEW_CONTROLLER function is used to identify when a new controller has been plugged in, and existing controller has been unplugged, or an
' existing controller has been plugged back in:
'
' Controller = __NEW_CONTROLLER(Event)
'
' Event will contain the controller event that was detected (if any):
'
'    0 - no events occurred
'    1 - an existing controller was unplugged       (the constant __UNPLUGGED     can be used to check for this event)
'    2 - an existing controller was plugged back in (the constant __PLUGGEDIN     can be used to check for this event)
'    3 - a new controller has been plugged in       (the constant __NEWCONTROLLER can be used to check for this event)
'
' The function will return the following values:
'
'      - a value of 0 (FALSE) if nothing has changed
'      - the value will contain the new controller id when a new controller is plugged in               (Event = 3     )
'      - the value will contain the controller id of a controller that was unplugged or plugged back in (Event = 1 or 2)
'
' Example:
'
' Controller = __NEW_CONTROLLER(Event) '                                                    check for a controller event
' IF Controller THEN '                                                                      has a controller event ocurred?
'     SELECT CASE Event '                                                                   yes, what happened?
'         CASE __NEW_CONTROLLER '                                                           a new controller was plugged in
'             PRINT "A new controller with the id of"; Controller; "has been plugged in."
'         CASE __PLUGGEDIN '                                                                an existing controller was plugged back in
'             PRINT "Controller id"; Controller; "has been plugged back in."
'         CASE __UNPLUGGED '                                                                an existing controller was unplugged
'             PRINT "Controller id"; Controller; "has been unplugged."
'     END SELECT
' END IF
'
' During game play there is no need to constantly check for controller events. Inside the main game loop during game play a check once per second
' will be more than enough. See the example program named "Configure_buttons.BAS" for a demonstration of this in action.



' +---------------------------------------+
' |                                       |
' |     CREATING USER DEFINED BUTTONS     |
' |                                       |
' +---------------------------------------+
'
' A user defined button can have up to 4 buttons or axes from various controllers associated with it. First, create an integer handle for each user
' defined button:
'
' DIM UP_Button AS INTEGER '    user defined button handles with up to four associated controller buttons and/or axes
' DIM DOWN_Button AS INTEGER
' DIM LEFT_Button AS INTEGER
' DIM RIGHT_Button AS INTEGER
'
' Next, the variables must be identified as user defined buttons using the __MAKE_BUTTON subroutine:
'
' __MAKE_BUTTON UP_Button '     __MAKE_BUTTON statement added with version 1.10
' __MAKE_BUTTON DOWN_Button '   __MAKE_BUTTON must be used with versions 1.10 and above
' __MAKE_BUTTOn LEFT_Button
' __MAKE_BUTTON RIGHT_Button
'
' The following subroutines allow for assigning a controller button and/or axes directly to a user defined button:
'
' __ASSIGN_BUTTON(Handle, cid, Button)
' __ASSIGN_AXIS(Handle, cid, Axis)
'
' Example:
'
' __ASSIGN_BUTTON UP_Button, __KEYBOARDCID, CLKEY_UP '       keyboard UP ARROW key assigned to UP_Button                     [SLOT1]
' __ASSIGN_BUTTON UP_Button, __KEYBOARDCID, CLKEY_W '        Keyboard W key also assigned to UP_Button                       [SLOT2]
' __ASSIGN_AXIS UP_Button, __JOYPAD1CID, -2 '                joystick vertical axis UP (-) also assigned to UP_Button        [SLOT3]
' __ASSIGN_BUTTON DOWN_Button, __KEYBOARDCID, CLKEY_DOWN '   keyboard DOWN ARROW key assigned to DOWN_Button                 [SLOT1]
' __ASSIGN_BUTTON DOWN_Button, __KEYBOARDCID, CLKEY_S '      keyboard S key also assigned to DOWN_Button                     [SLOT2]
' __ASSIGN_AXIS DOWN_Button, __JOYPAD1CID, 2 '               joystick vertical axis DOWN (+) also assigned to DOWN_Button    [SLOT3]
' __ASSIGN_BUTTON LEFT_Button, __KEYBOARDCID, CLKEY_LEFT '   keyboard LEFT ARROW key assigned to LEFT_Button                 [SLOT1]
' __ASSIGN_BUTTON LEFT_Button, __KEYBOARDCID, CLKEY_A '      keyboard A key also assigned to LEFT_Button                     [SLOT2]
' __ASSIGN_AXIS LEFT_Button, __JOYPAD1CID, -1 '              joystick horizontal axis LEFT (-) also assigned to LEFT_Button  [SLOT3]
' __ASSIGN_BUTTON RIGHT_Button, __KEYBOARDCID, CLKEY_RIGHT ' keyboard RIGHT ARROW key assigned to RIGHT_Button               [SLOT1]
' __ASSIGN_BUTTON RIGHT_Button, __KEYBOARDCID, CLKEY_D '     keyboard D key also assigned to RIGHT_Button                    [SLOT2]
' __ASSIGN_AXIS RIGHT_Button, __JOYPAD1CID, 1 '              joystick horizontal axis RIGHT (+) also asigned to RIGHT_Button [SLOT3]
'
' The above example now gives the player the option of using the keyboard ARROW keys, WASD keys, or the joystick to move in all four directions.
' Each of the above user defined buttons still have one slot remaining [SLOT4] and it could be populated with another joystick axis or perhaps
' the keyboard NUMBER PAD arrow keys if you wish.
'
' Joystick and game pad axis directions are defined with positive and negative values. A negative axis value either means UP or LEFT and a positive
' axis value either means DOWN or RIGHT depending on the axis being assigned. Axis deflections are detected when the axis is 50% or greater in
' deflection in a given direction. Top hats and D-Pads typically return a vale of -1 (-100%) or 1 (100%) while analog joystick inputs will change
' from -1 to 1 with a range of values in between. Analog joystick axes will register as a button press when they are deflected -.5 (-50%) to
' .5 (+50%) in either direction. (This .5 value can be changed using __SET_AXIS_THRESHOLD to suit your needs)




' +---------------------------------------+
' |                                       |
' |  SETTING AXIS THRESHOLD SENSITIVITY   |
' |                                       |
' +---------------------------------------+
'
' When using an axis as a button a certain axis deflection must be reached before the axis is considered "pressed". By default a joystick or game pad
' axis must be deflected at least 50% to reach this threshold. The following function can be used to change the threshold sensitivity amount:
'
' __SET_AXIS_THRESHOLD(Value)
'
' Example:
'
' __SET_AXIS_THRESHOLD .25 ' set axis button sensitivity to 25% deflection.
'
' Value can be any number from .01 (1%) to .99 (99%).



' +---------------------------------------+
' |                                       |
' | DETECTING A USER DEFINED BUTTON PRESS |
' |                                       |
' +---------------------------------------+
'
' The following function can be used to test if a user defined button is being pressed:
'
' __BUTTON_DOWN(Handle)
'
' Example:
'
' IF __BUTTON_DOWN(UP_Button) THEN
'     PRINT "Either the keyboard UP ARROW or W key was pressed or joystick 1 was pushed or pressed UP."
' END IF



' +---------------------------------------+
' |                                       |
' |  AUTO-ASSIGNING USER DEFINED BUTTONS  |
' |                                       |
' +---------------------------------------+
'
' Because of the wide variety of joytick and game pad controllers a user may connect it may be best to have the user define the keys, buttons, and
' axes they wish to use. The following subroutine can be used to have the user auto-assign user defined button assignments:
'
' __AUTOASSIGN_BUTTON(Handle)
'
' Example:
'
' __AUTOASSIGN_BUTTON UP_Button ' [SLOT1] wait for a button press or axis deflection
' __AUTOASSIGN_BUTTON UP_Button ' [SLOT2] wait for a button press or axis deflection
'
' __AUTOASSIGN_BUTTON will wait for a controller button press or axis deflection and then store that information into an available slot. Again,
' this can be done up to four times to fill the four available slots.
'
' NOTE: The mouse controller axes are ignored while __AUTOASSIGN_BUTTON waits for a controller button or axis. If you wish to assign mouse movements as
'       axes to a user defined button you'll need to do it manually with __ASSIGN_AXIS.



' +---------------------------------------+
' |                                       |
' |     REMOVING BUTTON ASSIGNMENTS       |
' |                                       |
' +---------------------------------------+
'
' The following subroutine can be used to clear button/axis assignments (slots) from a user defined button:
'
' __REMOVE_BUTTON(Handle, Slot)
'
' Example:
'
' __REMOVE_BUTTON UP_Button, 3   ' remove the assigned button/axis from slot 3
' __REMOVE_BUTTON DOWN_Button, 0 ' remove the assigned buttons/axes from all slots
'
' Slot can range from 1 to 4, or 0 if you wish to remove all user assigned buttons/axes.



' +---------------------------------------+
' |                                       |
' |    REMOVING A CONTROLLER'S BUTTONS    |
' |                                       |
' +---------------------------------------+
'
' The subroutine __REMOVE_CONTROLLER will remove all user assigned buttons associated with a controller. This is most useful when a controller has
' been detected as unplugged by __NEW_CONTROLLER and the associated assigned buttons need to be removed as well.
'
' __REMOVE_CONTROLLER cid
'
' Example:
'
' Controller = __NEW_CONTROLLER(Event) '                                                    check for a controller event
' IF Controller THEN '                                                                      has a controller event ocurred?
'     SELECT CASE Event '                                                                   yes, what happened?
'         CASE __NEW_CONTROLLER '                                                           a new controller was plugged in
'             PRINT "A new controller with the id of"; Controller; "has been plugged in."
'         CASE __PLUGGEDIN '                                                                an existing controller was plugged back in
'             PRINT "Controller id"; Controller; "has been plugged back in."
'             __LOAD_BUTTONS '                                                              load user defined buttons associated with controller (if they exist)
'         CASE __UNPLUGGED '                                                                an existing controller was unplugged
'             PRINT "Controller id"; Controller; "has been unplugged."
'             __REMOVE_CONTROLLER Controller '                                              remove controller's associated user defined buttons
'     END SELECT
' END IF



' +---------------------------------------+
' |                                       |
' | ENABLING/DISABLING BUTTON REASSIGNMENT|
' |                                       |
' +---------------------------------------+
'
' If an attempt is made to assign an axis or button that was previously assigned to a user defined button, the original assignment will be erased and
' replaced by the new assignment by default. This behavior can be changed using the following subroutines:
'
' __BUTTON_REASSIGN_ALLOWED
' __BUTTON_REASSIGN_NOT_ALLOWED
'
' Example:
'
' __BUTTON_REASSIGN_ALLOWED     ' allow previously assigned buttons/axes to be moved into a different user assigned button *DEFAULT*
' __BUTTON_REASSIGN_NOT_ALLOWED ' ignore requests to reassign buttons



' +---------------------------------------+
' |                                       |
' |       GETTING A BUTTON'S NAME         |
' |                                       |
' +---------------------------------------+
'
' When a user defined button is created a descriptive name is also generated and stored. You can use the following function to get a user defined button's
' name:
'
' __BUTTON_NAME$(Handle, Slot)
'
' Example:
'
' ButtonName$ = __BUTTON_NAME$(UP_Button, 1)
'
' Slot values range from 1 to 4.



' +---------------------------------------+
' |                                       |
' |  LOADING/SAVING USER DEFINED BUTTONS  |
' |                                       |
' +---------------------------------------+
'
' It's now possible to save and load user defined buttons associated to controller inputs. Use the __SAVE_BUTTONS subroutine to save the current
' set of user defined buttons and __LOAD_BUTTONS to load any user defined buttons that may be associated with a controller.
'
' __SAVE_BUTTONS ' save all currently configured user define buttons to configuration files
' __LOAD_BUTTONS ' load buttons that are associated with the currently connected controllers
'
' When __SAVED_BUTTONS is used a configration file for each attached controller is created. The name of the controller and the controller's id number
' ised used to create the file. For instance, if a system currently has a keyboard, mouse, Joystick, and game pad. The name of the joystick is
' "Saitek ST290 Pro" and the name of the game pad is "USB Game Pad". The joystick is using id#3 and the game pad is using id#4. The four configration
' files that will be created are:
'
'   - "Keyboard.ID1"
'   - "Mouse.ID2"
'   - "Saitek ST290 Pro.ID3"
'   - "USB Game Pad.ID4"
'
' All user assigned buttons will be saved in their assigned controller configuration file. It's possible to have multiple configration files for any
' given controller based on the id number it is using. For example, let's say the next time the program is started only the USB Game Pad is connected.
' It will be identified as using id number 3. Later on the user plugs in the Saitek ST290 Pro which will now be have an id of 4. When __SAVE_BUTTONS
' is used the four configration files will be as follows:
'
'   - "Keyboard.ID1"
'   - "Mouse.ID2"
'   - "USB Game Pad.ID3"
'   - "Saitek ST290 Pro.ID4"
'
' Therefore, depending on which id number a controller currently has will depend on which configuration file is used to load saved user defined
' buttons. This allows controllers to be set up with player 1-6 configurations with each player having a different preferred configuration.
'
' Also, controllers that have no user assigned buttons will still create a configuration file of zero bytes in size. This is normal.
'
' __LOAD_BUTTONS will look for configuration files associated with all currently connected controllers based on their id numbers. If a configration
' exists the user defined buttons wil be loaded.



' +---------------------------------------+
' |                                       |
' |   REMAPPING JOYSTICK/GAME PAD AXES    |
' |                                       |
' +---------------------------------------+
'
' As stated before, joystick and game pad axis are always returned as values between -1 and 1. The following function can be used to remap this range
' to a different value range:
'
' __MAP_AXIS(AxisValue, Lower, Upper)
'
' Example:
'
' J1Xaxis = __MAP_AXIS(__CONTROLLER_AXIS(__JOYPAD1CID, 1), -128, 128) ' remap joystick 1 horizontal axis values from -128 to 128 (0 being center)
' J1Yaxis = __MAP_AXIS(__CONTROLLER_AXIS(__JOYPAD1CID, 2), -128, 128) ' remap joystick 1 vertical axis values from -128 to 128   (0 being center)
' J2Xaxis = __MAP_AXIS(__CONTROLLER_AXIS(__JOYPAD2CID, 1), 0, 255) '    remap joystick 2 horizontal axis values from 0 to 255    (127 being center)
' J2Yaxis = __MAP_AXIS(__CONTROLLER_AXIS(__JOYPAD2CID, 2), 0, 255) '    remap joystick 2 vertical axis values from 0 to 255      (127 being center)
'
' The Lower and Upper range values can be any values you wish as long as the Lower value is less than the Upper value.



'
' +---------------------------------------+
' |                                       |
' |      LIBRARY CODE BEGINS HERE         |
' |                                       |
' +---------------------------------------+

'OPTION _EXPLICIT

' __________________________________________________________________________________________________________________________________________________
'/                                                                                                                   KEYBOARD KEY _BUTTON CONSTANTS \
CONST CLKEY_ESC = 2 '                                                                                                                               |
CONST CLKEY_F1 = 60 '              FUNCTION KEY ROW _BUTTON CONSTANTS                                                                               |
CONST CLKEY_F2 = 61 '               _____     _____ _____ _____ _____    _____ _____ _____ _____    _____ _____ _____ _____                         |
CONST CLKEY_F3 = 62 '              ||ESC||   ||F1 |||F2 |||F3 |||F4 ||  ||F5 |||F6 |||F7 |||F8 ||  ||F9 |||N/A|||F11|||F12||                        |
CONST CLKEY_F4 = 63 '              ||___||   ||___|||___|||___|||___||  ||___|||___|||___|||___||  ||___|||___|||___|||___||                        |
CONST CLKEY_F5 = 64 '              |/___\|   |/___\|/___\|/___\|/___\|  |/___\|/___\|/___\|/___\|  |/___\|/___\|/___\|/___\|                        |
CONST CLKEY_F6 = 65 '                                                                                                                               |
CONST CLKEY_F7 = 66 '              NOTE: F10 does not register as a _BUTTON. I know, strange but true.                                              |
CONST CLKEY_F8 = 67 '                    These _BUTTON contants were provided by gx.bi in dbox's Game Engine: https://github.com/boxgaming/gx       |
CONST CLKEY_F9 = 68 '                                                                                                                               |
CONST CLKEY_F11 = 88 '                                                                                                                              |
CONST CLKEY_F12 = 89 '                                                                                                                              |
CONST CLKEY_BACKQUOTE = 42 '       -----------------------------------------------------------------------------------------                        |
CONST CLKEY_1 = 3 '                FIRST KEY ROW _BUTTON CONSTANTS                                                                                  |
CONST CLKEY_2 = 4 '                                                                                                                                 |
CONST CLKEY_3 = 5 '                 _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _________                         |
CONST CLKEY_4 = 6 '                ||`~ |||1! |||2@ |||3# |||4$ |||5% |||6^ |||7& |||8* |||9( |||0) |||-_ |||=+ |||BACKSP ||                        |
CONST CLKEY_5 = 7 '                ||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||_______||                        |
CONST CLKEY_6 = 8 '                |/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/_______\|                        |
CONST CLKEY_7 = 9 '                                                                                                                                 |
CONST CLKEY_8 = 10 '                                                                                                                                |
CONST CLKEY_9 = 11 '                                                                                                                                |
CONST CLKEY_0 = 12 '                                                                                                                                |
CONST CLKEY_MINUS = 13 '                                                                                                                            |
CONST CLKEY_EQUALS = 14 '                                                                                                                           |
CONST CLKEY_BACKSPACE = 15 '                                                                                                                        |
CONST CLKEY_TAB = 16 '             -----------------------------------------------------------------------------------------                        |
CONST CLKEY_Q = 17 '               SECOND KEY ROW _BUTTON CONSTANTS                                                                                 |
CONST CLKEY_W = 18 '                                                                                                                                |
CONST CLKEY_E = 19 '                _______ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _______                         |
CONST CLKEY_R = 20 '               ||TAB  |||Q  |||W  |||E  |||R  |||T  |||Y  |||U  |||I  |||O  |||P  |||[{ |||]} |||\|   ||                        |
CONST CLKEY_T = 21 '               ||_____|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||_____||                        |
CONST CLKEY_Y = 22 '               |/_____\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/_____\|                        |
CONST CLKEY_U = 23 '                                                                                                                                |
CONST CLKEY_I = 24 '                                                                                                                                |
CONST CLKEY_O = 25 '                                                                                                                                |
CONST CLKEY_P = 26 '                                                                                                                                |
CONST CLKEY_LBRACKET = 27 '                                                                                                                         |
CONST CLKEY_RBRACKET = 28 '                                                                                                                         |
CONST CLKEY_BACKSLASH = 44 '                                                                                                                        |
CONST CLKEY_CAPSLOCK = 59 '        -----------------------------------------------------------------------------------------                        |
CONST CLKEY_A = 31 '               THIRD KEY ROW _BUTTON CONSTANTS                                                                                  |
CONST CLKEY_S = 32 '                                                                                                                                |
CONST CLKEY_D = 33 '                ________ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ ____________                         |
CONST CLKEY_F = 34 '               ||CAPS  |||A  |||S  |||D  |||F  |||G  |||H  |||J  |||K  |||L  |||;: |||'" |||ENTER     ||                        |
CONST CLKEY_G = 35 '               ||______|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||__________||                        |
CONST CLKEY_H = 36 '               |/______\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/__________\|                        |
CONST CLKEY_J = 37 '                                                                                                                                |
CONST CLKEY_K = 38 '                                                                                                                                |
CONST CLKEY_L = 39 '                                                                                                                                |
CONST CLKEY_SEMICOLON = 40 '                                                                                                                        |
CONST CLKEY_QUOTE = 41 '                                                                                                                            |
CONST CLKEY_ENTER = 29 '                                                                                                                            |
CONST CLKEY_LSHIFT = 43 '          -----------------------------------------------------------------------------------------                        |
CONST CLKEY_Z = 45 '               FOURTH KEY ROW _BUTTON CONSTANTS                                                                                 |
CONST CLKEY_X = 46 '                                                                                                                                |
CONST CLKEY_C = 47 '                _____________ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____________                         |
CONST CLKEY_V = 48 '               ||LEFT SHIFT |||Z  |||X  |||C  |||V  |||B  |||N  |||M  |||,< |||.> |||/? |||RIGHT SHIFT||                        |
CONST CLKEY_B = 49 '               ||___________|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___|||___________||                        |
CONST CLKEY_N = 50 '               |/___________\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___\|/___________\|                        |
CONST CLKEY_M = 51 '                                                                                                                                |
CONST CLKEY_COMMA = 52 '                                                                                                                            |
CONST CLKEY_PERIOD = 53 '                                                                                                                           |
CONST CLKEY_SLASH = 54 '                                                                                                                            |
CONST CLKEY_RSHIFT = 55 '                                                                                                                           |
CONST CLKEY_LCTRL = 30 '           -----------------------------------------------------------------------------------------                        |
CONST CLKEY_LWIN = 348 '           FIFTH KEY ROW _BUTTON CONSTANTS                                                                                  |
CONST CLKEY_SPACEBAR = 58 '                                                                                                                         |
CONST CLKEY_RWIN = 349 '            ______ ______ ______ _____________________________________________ ______ ______ ______                         |
CONST CLKEY_RCTRL = 286 '          ||LCTL|||LWIN|||MENU|||SPACEBAR                                   |||N/A |||RWIN|||RCTL||                        |
CONST CLKEY_MENU = 350 '           ||____|||____|||____|||___________________________________________|||____|||____|||____||                        |
'                                  |/____\|/____\|/____\|/___________________________________________\|/____\|/____\|/____\|                        |
'                                                                                                                                                   |
CONST CLKEY_NUMLOCK = 326 '        -----------------------------------------------------------------------------------------                        |
CONST CLKEY_NUMPAD_DIVIDE = 310 '  NUMBER PAD _BUTTON CONSTANTS                                                                                     |
CONST CLKEY_NUMPAD_MULTIPLY = 56 '                                                                                                                  |
CONST CLKEY_NUMPAD_MINUS = 75 '     _____ _____ _____ _____                                                                                         |
CONST CLKEY_NUMPAD_7 = 72 '        ||NUM|||/  |||*  |||-  ||                                                                                        |
CONST CLKEY_NUMPAD_8 = 73 '        ||___|||___|||___|||___||                                                                                        |
CONST CLKEY_NUMPAD_9 = 74 '        |/___\|/___\|/___\|/___\|                                                                                        |
CONST CLKEY_NUMPAD_PLUS = 79 '      _____ _____ _____ _____                                                                                         |
CONST CLKEY_NUMPAD_4 = 76 '        ||7  |||8 |||9  |||+  ||                                                                                        |
CONST CLKEY_NUMPAD_5 = 77 '        ||___|||___|||___|||   ||                                                                                        |
CONST CLKEY_NUMPAD_6 = 78 '        |/___\|/___\|/___\||   ||                                                                                        |
CONST CLKEY_NUMPAD_1 = 80 '         _____ _____ _____||   ||                                                                                        |
CONST CLKEY_NUMPAD_2 = 81 '        ||4 |||5  |||6 |||   ||                                                                                        |
CONST CLKEY_NUMPAD_3 = 82 '        ||___|||___|||___|||___||                                                                                        |
CONST CLKEY_NUMPAD_ENTER = 285 '   |/___\|/___\|/___\|/___\|                                                                                        |
CONST CLKEY_NUMPAD_0 = 83 '         _____ _____ _____ _____                                                                                         |
CONST CLKEY_NUMPAD_PERIOD = 84 '   ||1  |||2 |||3  |||E  ||                                                                                        |
'                                  ||___|||___|||___|||N  ||                                                                                        |
'                                  |/___\|/___\|/___\||T  ||                                                                                        |
'                                   ___________ _____||E  ||                                                                                        |
'                                  ||0        |||.  |||R  ||                                                                                        |
'                                  ||_________|||___|||___||                                                                                        |
'                                  |/_________\|/___\|/___\|                                                                                        |
'                                                                                                                                                   |
CONST CLKEY_UP = 329 '             -----------------------------------------------------------------------------------------                        |
CONST CLKEY_LEFT = 332 '           ARROW KEY _BUTTON CONSTANTS                                                                                      |
CONST CLKEY_DOWN = 337 '                                                                                                                            |
CONST CLKEY_RIGHT = 334 '                 _____                                                                                                     |
'                                        ||  ||                                                                                                    |
'                                        ||___||                                                                                                    |
'                                        |/___\|                                                                                                    |
'                                   _____ _____ _____                                                                                               |
'                                  ||  |||  |||  ||                                                                                              |
'                                  ||___|||___|||___||                                                                                              |
'                                  |/___\|/___\|/___\|                                                                                              |
'                                                                                                                                                   |
CONST CLKEY_SCRLK = 71 '           -----------------------------------------------------------------------------------------                        |
CONST CLKEY_PAUSE = 70 '           POSITION KEY _BUTTON CONSTANTS                                                                                   |
CONST CLKEY_INSERT = 339 '                                                                                                                          |
CONST CLKEY_HOME = 328 '            _____ _____ _____                                                                                               |
CONST CLKEY_PAGEUP = 330 '         ||N/A|||SCR|||PAU||                                                                                              |
CONST CLKEY_DELETE = 340 '         ||___|||___|||___||               NOTE: Pause not working on my system?                                          |
CONST CLKEY_END = 336 '            |/___\|/___\|/___\|                                                                                              |
CONST CLKEY_PAGEDOWN = 338 '        _____ _____ _____|                                                                                              |
'                                  ||INS|||HOM|||PUP||                                                                                              |
'                                  ||___|||___|||___||                                                                                              |
'                                  |/___\|/___\|/___\|                                                                                              |
'                                   _____ _____ _____                                                                                               |
'                                  ||DEL|||END|||PDN||                                                                                              |
'                                  ||___|||___|||___||                                                                                              |
'                                  |/___\|/___\|/___\|                                                                                              |
'                                                                                                                                                   |
'\__________________________________________________________________________________________________________________________________________________/
'/                                                                                                                       __NEW_CONTROLLER CONSTANTS \
CONST __UNPLUGGED = 1 '                    existing controller unplugged        - use with __NEW_CONTROLLER                                         |
CONST __PLUGGEDIN = 2 '                    existing controller plugged back in  - use with __NEW_CONTROLLER                                         |
CONST __NEWCONTROLLER = 3 '                a new controller has been plugged in - use with __NEW_CONTROLLER                                         |
'\__________________________________________________________________________________________________________________________________________________/
'/                                                                                                                                       TYPE__SLOT \
TYPE TYPE__SLOT '                          USER DEFINED BUTTON SLOT PROPERTIES                                                                      |
    Cname AS STRING * 25 '                 controller name                                                                                          |
    cid AS INTEGER '                       controller id number (_DEVICES)                                                                          |
    Button AS INTEGER '                    button number (0 if using axis)                                                                          |
    Axis AS INTEGER '                      axis number (0 if using button) (- value for UP/LEFT or + value for DOWN/RIGHT)                          |
    Name AS STRING * 15 '                  button/axis name                                                                                         |
END TYPE '                                                                                                                                          |
'\__________________________________________________________________________________________________________________________________________________/
'/                                                                                                                                     TYPE__BUTTON \
TYPE TYPE__BUTTON '                        USER DEFINED BUTTON PROPERTIES                                                                           |
    Slot0 AS TYPE__SLOT '                  blank slot to clear others                                                                               |
    Slot1 AS TYPE__SLOT '                  user defined button slot 1                                                                               |
    Slot2 AS TYPE__SLOT '                  user defined button slot 2                                                                               |
    Slot3 AS TYPE__SLOT '                  user defined button slot 3                                                                               |
    Slot4 AS TYPE__SLOT '                  user defined button slot 4                                                                               |
END TYPE '                                                                                                                                          |
'\__________________________________________________________________________________________________________________________________________________/
'/                                                                                                                                 TYPE__CONTROLLER \
TYPE TYPE__CONTROLLER '                    DETECTED CONTROLLER PROPERTIES                                                                           |
    Found AS INTEGER '                     controller found (t/f)                                                                                   |
    Connected AS INTEGER '                 controller connected (t/f)                                                                               |
    Name AS STRING * 25 '                  description of controller                                                                                |
    Buttons AS INTEGER '                   number of buttons controller has ( _LASTBUTTON(Controller) )                                             |
    Axis AS INTEGER '                      number of axis controller has    ( _LASTAXIS(Controller)   )                                             |
    Wheels AS INTEGER '                    number of wheels controller has  ( _LASTWHEEL(Controller)  ) ** NOT IMPLEMENTED YET *                    |
END TYPE '                                                                                                                                          |
'\__________________________________________________________________________________________________________________________________________________/
'/                                                                                                                                   TYPE__SETTINGS \
TYPE TYPE__SETTINGS '                      LIBRARY SETTINGS                                                                                         |
    Reassign AS INTEGER '                  reassign (-1) or ignore (0) already used user defined buttons                                            |
    Threshold AS SINGLE '                  axis sensitivity when used as a user defined button (.01 to .99)                                         |
    FoundDevices AS INTEGER '              number of controllers found when program first started                                                   |
END TYPE '                                                                                                                                          |
'\__________________________________________________________________________________________________________________________________________________/
'/                                                                                                                             VARIABLE ASSIGNMENTS \
REDIM CL_BUTTON(1) AS TYPE__BUTTON '       user assigned button array                                                                               |
DIM CL_CONTROLLER(6) AS TYPE__CONTROLLER ' controller array (index number equals _DEVICES id number)                                                |
DIM CL_KEYNAME(350) AS STRING '            keyboard _BUTTON key names                                                                               |
DIM CL_SETTINGS AS TYPE__SETTINGS '        library settings                                                                                         |
DIM SHARED __CURRENT_ROUTINE AS STRING '   __ERROR use                                                                                              |
DIM SHARED __PREVIOUS_ROUTINE AS STRING '  __ERROR use                                                                                              |
DIM SHARED __KEYBOARDCID AS INTEGER '      these will contain the device ids (_DEVICES)                                                             |
DIM SHARED __MOUSECID AS INTEGER '                                                                                                                  |
DIM SHARED __JOYPAD1CID AS INTEGER '                                                                                                                |
DIM SHARED __JOYPAD2CID AS INTEGER '                                                                                                                |
DIM SHARED __JOYPAD3CID AS INTEGER '                                                                                                                |
DIM SHARED __JOYPAD4CID AS INTEGER '                                                                                                                |
DIM SHARED __JOYPAD5CID AS INTEGER '                                                                                                                |
DIM SHARED __JOYPAD6CID AS INTEGER '                                                                                                                |
'\__________________________________________________________________________________________________________________________________________________/

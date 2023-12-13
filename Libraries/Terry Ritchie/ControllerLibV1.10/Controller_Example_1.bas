'$INCLUDE:'CONTROLLER.BI'
'----------------------------------------------------------------------------------------------------
' Controller Library Example 1
' Creating user defined buttons that include keyboard keys and joystick axes
'
' Use the keyboard ARROW keys, keyboard WASD keys, or Joystick 1 to move the circle around the screen
'
' Terry Ritchie
' April 11th, 2023 - initial release
' May 17th, 2023   - updated to use Controller Library v1.10
'----------------------------------------------------------------------------------------------------

DIM UP_Button AS INTEGER '    user defined button handles with up to four associated controller buttons and/or axes
DIM DOWN_Button AS INTEGER
DIM LEFT_Button AS INTEGER
DIM RIGHT_Button AS INTEGER
DIM x AS INTEGER '            circle x location
DIM y AS INTEGER '            circle y location

__INITIALIZE_CONTROLLERS '                                 initialize controller library
__MAKE_BUTTON UP_Button
__MAKE_BUTTON DOWN_Button
__MAKE_BUTTON LEFT_Button
__MAKE_BUTTON RIGHT_Button

'+----------------------------------------------------------------------------------+
'| Assign keyboard ARROW keys, WASD keys, and joystick 1 to the four button handles |
'+----------------------------------------------------------------------------------+

__ASSIGN_BUTTON UP_Button, __KEYBOARDCID, CLKEY_UP '       keyboard UP ARROW key assigned to UP_Button                     [SLOT1]
__ASSIGN_BUTTON UP_Button, __KEYBOARDCID, CLKEY_W '        Keyboard W key also assigned to UP_Button                       [SLOT2]
__ASSIGN_AXIS UP_Button, __JOYPAD1CID, -2 '                joystick vertical axis UP (-) also assigned to UP_Button        [SLOT3]
__ASSIGN_BUTTON DOWN_Button, __KEYBOARDCID, CLKEY_DOWN '   keyboard DOWN ARROW key assigned to DOWN_Button                 [SLOT1]
__ASSIGN_BUTTON DOWN_Button, __KEYBOARDCID, CLKEY_S '      keyboard S key also assigned to DOWN_Button                     [SLOT2]
__ASSIGN_AXIS DOWN_Button, __JOYPAD1CID, 2 '               joystick vertical axis DOWN (+) also assigned to DOWN_Button    [SLOT3]
__ASSIGN_BUTTON LEFT_Button, __KEYBOARDCID, CLKEY_LEFT '   keyboard LEFT ARROW key assigned to LEFT_Button                 [SLOT1]
__ASSIGN_BUTTON LEFT_Button, __KEYBOARDCID, CLKEY_A '      keyboard A key also assigned to LEFT_Button                     [SLOT2]
__ASSIGN_AXIS LEFT_Button, __JOYPAD1CID, -1 '              joystick horizontal axis LEFT (-) also assigned to LEFT_Button  [SLOT3]
__ASSIGN_BUTTON RIGHT_Button, __KEYBOARDCID, CLKEY_RIGHT ' keyboard RIGHT ARROW key assigned to RIGHT_Button               [SLOT1]
__ASSIGN_BUTTON RIGHT_Button, __KEYBOARDCID, CLKEY_D '     keyboard D key also assigned to RIGHT_Button                    [SLOT2]
__ASSIGN_AXIS RIGHT_Button, __JOYPAD1CID, 1 '              joystick horizontal axis RIGHT (+) also asigned to RIGHT_Button [SLOT3]
SCREEN _NEWIMAGE(640, 480, 32)
x = 319
y = 239
DO
    _LIMIT 30
    CLS
    LOCATE 2, 1
    PRINT " Controller Library Demo 1"
    PRINT " Use ARROW keys, WASD keys, or Joystick 1"
    PRINT " ESC to exit"
    IF __BUTTON_DOWN(UP_Button) THEN y = y - 5 '           press UP ARROW    key, W key, or move joystick UP
    IF __BUTTON_DOWN(DOWN_Button) THEN y = y + 5 '         press DOWN ARROW  key, S key, or move joystick DOWN
    IF __BUTTON_DOWN(LEFT_Button) THEN x = x - 5 '         press LEFT ARROW  key, A key, or move joystick LEFT
    IF __BUTTON_DOWN(RIGHT_Button) THEN x = x + 5 '        press RIGHT ARROW key, D key, or move joystick RIGHT
    CIRCLE (x, y), 30
    _DISPLAY
LOOP UNTIL _KEYDOWN(27) '                                  exit when ESC pressed
SYSTEM

'$INCLUDE:'CONTROLLER.BM'


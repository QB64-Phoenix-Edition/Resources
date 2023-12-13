'$INCLUDE:'CONTROLLER.BI'
'----------------------------------------------------------------------------------------------------
' Controller Library Example 2
' Remapping joystick axes
'
' Use Joystick 1 to move the circle around the screen
'
' Terry Ritchie
' April 11th, 2023 - original release
' May 17th, 2023   - updated to use Controller Library v1.10
'----------------------------------------------------------------------------------------------------

__INITIALIZE_CONTROLLERS '                                       initialize controller library
SCREEN _NEWIMAGE(640, 480, 32)
DO
    _LIMIT 30
    CLS
    LOCATE 2, 1
    PRINT " Controller Library Demo 2"
    PRINT " Use Joystick 1"
    PRINT " ESC to exit"
    x = __MAP_AXIS(__CONTROLLER_AXIS(__JOYPAD1CID, 1), 0, 639) ' joystick 1 axis now 0 to 639
    y = __MAP_AXIS(__CONTROLLER_AXIS(__JOYPAD1CID, 2), 0, 479) ' joystick 2 axis now 0 to 479
    CIRCLE (x, y), 30
    _DISPLAY
LOOP UNTIL _KEYDOWN(27) '                                        exit when ESC pressed
SYSTEM

'$INCLUDE:'CONTROLLER.BM'


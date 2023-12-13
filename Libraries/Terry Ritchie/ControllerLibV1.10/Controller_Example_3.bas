'$INCLUDE:'CONTROLLER.BI'
'----------------------------------------------------------------------------------------------------
' Controller Library Example 3
' Polling controllers for information
'
' Reports information on all controllers found.
'
' Terry Ritchie
' April 11th, 2023 - original release
' May 17th, 2023   - updated to use Controller Library v1.10
'----------------------------------------------------------------------------------------------------

__INITIALIZE_CONTROLLERS ' initialize controller library
DIM Joysticks AS INTEGER
DIM Format AS STRING
DIM j AS INTEGER
DIM jid AS INTEGER

Joysticks = __JOYPAD_EXISTS(1)
Format = " |       #        | \                             \ |   ###   |  ##  |"
CLS
PRINT
PRINT "  ___________________________________________________________________"
PRINT " /           CONTROLLERS FOUND CONNECTED TO YOUR COMPUTER            \"
PRINT " |----------------+---------------------------------+---------+------|"
PRINT " |  CONTROLLER ID |         CONTROLLER NAME         | BUTTONS | AXES |"
PRINT " |----------------+---------------------------------+---------+------|"
IF __KEYBOARD_EXISTS THEN PRINT USING Format; __KEYBOARDCID; __CONTROLLER_NAME$(__KEYBOARDCID); __BUTTON_TOTAL(__KEYBOARDCID); 0
PRINT " |----------------+---------------------------------+---------+------|"
IF __MOUSE_EXISTS THEN PRINT USING Format; __MOUSECID; __CONTROLLER_NAME$(__MOUSECID); __BUTTON_TOTAL(__MOUSECID); __AXIS_TOTAL(__MOUSECID)
FOR j = 1 TO Joysticks
    SELECT CASE j
        CASE 1: jid = __JOYPAD1CID
        CASE 2: jid = __JOYPAD2CID
        CASE 3: jid = __JOYPAD3CID
        CASE 4: jid = __JOYPAD4CID
        CASE 5: jid = __JOYPAD5CID
        CASE 6: jid = __JOYPAD6CID
    END SELECT
    PRINT " |----------------+---------------------------------+---------+------|"
    PRINT USING Format; jid; __CONTROLLER_NAME$(jid); __BUTTON_TOTAL(jid); __AXIS_TOTAL(jid)
NEXT j
PRINT " \________________|_________________________________|_________|______/"
PRINT
PRINT " Press ESC to exit"
SLEEP
SYSTEM

'$INCLUDE:'CONTROLLER.BM'


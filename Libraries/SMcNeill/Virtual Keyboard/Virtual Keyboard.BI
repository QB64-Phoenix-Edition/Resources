$IF VKBI = UNDEFINED THEN
    TYPE Keyboard_Internal_Type
        In_Use AS LONG
        Is_Hidden AS LONG
        Handle AS LONG
        Hardware_Handle AS LONG
        Xoffset AS LONG
        Yoffset AS LONG
        Xsize AS LONG
        Ysize AS LONG
        Style1 AS INTEGER
        style2 AS INTEGER
    END TYPE
    TYPE Keyboard_Value_Type
        Value AS LONG
        State AS LONG
        Caption AS STRING
    END TYPE
    DIM SHARED Virtual_KB(0 TO 10) AS Keyboard_Internal_Type
    DIM SHARED Keyboard_Values(0 TO 10, 0 TO 10, 0 TO 255) AS Keyboard_Value_Type '11 keyboards of up to 11 rows of 256 keys
    TYPE Button_Report
        Time AS _FLOAT
        Value AS LONG
        Caption AS STRING
        Held AS LONG
    END TYPE
    TYPE Buttons_Internal_Type
        In_Use AS INTEGER
        Red AS INTEGER
        Green AS INTEGER
        Blue AS INTEGER
        RedMax AS INTEGER
        GreenMax AS INTEGER
        BlueMax AS INTEGER
        Font AS INTEGER
        Shade AS INTEGER
        Font_Color AS _UNSIGNED LONG
        Font_Background AS _UNSIGNED LONG
    END TYPE
    REDIM SHARED Button_Style(10) AS Buttons_Internal_Type
    DIM SHARED Buttons(10) AS Button_Report
    DIM SHARED Repeat_Speed AS _FLOAT
    Repeat_Speed = 0.1 'by default
    $LET VKBI = TRUE
$END IF

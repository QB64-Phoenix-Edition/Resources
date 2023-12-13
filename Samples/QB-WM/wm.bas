'$INCLUDE: './global.bh'
'$CHECKING:OFF

'ON ERROR GOTO er
Dim temp As winType
Dim win_Log As Integer
Dim win_Img As Integer, win_Img_Image As Long
Dim win_Cat As Integer, win_Cat_Text As String
Dim win_Launcher
Dim win_Other As Integer

win_Img_Image = LoadImage("images/image.jpg", 32)
'SetAlpha 250, , win_Img_Image

temp = __template_Win
temp.IH = NewImage(temp.W, temp.H, 32)
temp.T = ""
win_Launcher = newWin(temp)


logP "INFO> main routine: Ready"
Dim win As Integer
Do
    Do While MouseInput: updateMouse: Loop

    For win = LBound(w) To UBound(w)
        If w(win).IH = 0 Then Continue
        Select Case win


            Case win_Log 'Log window
                If w(win).NeedsRefresh Then resizeWin win_Log: logP ""


            Case win_Img
                If w(win).NeedsRefresh Then
                    resizeWin win_Img
                    PutImage , win_Img_Image, w(win).IH
                End If



            Case win_Cat 'Text editor window
                $Checking:Off
                If w(win_Cat).Z = 0 Then

                    If __inKey <> "" Then w(win_Cat).NeedsRefresh = -1
                    Do Until __inKey = ""
                        Select Case __inKey '__inKey is updated when upd is called.
                            Case Chr$(8): win_Cat_Text = Left$(win_Cat_Text, Len(win_Cat_Text) - 1) 'backspace
                            Case Chr$(13): win_Cat_Text = win_Cat_Text + " " + Chr$(13) + " "
                            Case Else: win_Cat_Text = win_Cat_Text + __inKey 'Append keypress to window
                        End Select
                        __inKey = InKey$
                    Loop


                    If w(win).NeedsRefresh Then
                        resizeWin win
                        printWithWrap win_Cat_Text, win_Cat
                    End If
                End If
                $Checking:On




            Case win_Launcher
                w(win).W = 100
                w(win).H = 76
                If (w(win).NeedsRefresh <> 0) Or (w(win_Launcher).Z = 0) Then
                    resizeWin win
                    Dest w(win).IH
                    Line (0, 0)-Step(100, 16), &H404040C8, BF
                    Line (0, 20)-Step(100, 16), &H404040C8, BF
                    Line (0, 40)-Step(100, 16), &H404040C8, BF
                    Line (0, 60)-Step(100, 16), &H404040C8, BF
                    If win_Log Then PrintString (2, 2), "Close log" Else PrintString (2, 2), "Open log"
                    If win_Cat Then PrintString (2, 22), "Close text editor" Else PrintString (2, 22), "Open text editor"
                    If win_Img Then PrintString (2, 42), "Close image" Else PrintString (2, 42), "Open image"
                    If win_Other Then PrintString (2, 62), "Close debug" Else PrintString (2, 62), "Open debug"
                End If

                If w(win_Launcher).Z = 0 Then
                    If ((w(win).MX < 100) And (w(win).MX > 0)) Then
                        w(win).NeedsRefresh = True
                        Select Case w(win).MY
                            Case 0 To 16
                                If MouseButton(1) Then
                                    If win_Log Then
                                        freeWin win_Log
                                        win_Log = 0
                                    Else
                                        temp = __template_Win
                                        temp.X = 50
                                        temp.IH = NewImage(320, 240, 32)
                                        temp.T = "Log"
                                        temp.FH = __font_Mono
                                        win_Log = newWin(temp)
                                    End If
                                Else
                                    Line (0, 0)-(100, 16), &H66666666, BF
                                End If

                            Case 20 To 36
                                If MouseButton(1) Then
                                    If win_Cat Then
                                        freeWin win_Cat
                                        win_Cat = 0
                                    Else
                                        temp = __template_Win
                                        temp.X = 200
                                        temp.IH = NewImage(320, 240, 32)
                                        temp.T = "Text editor"
                                        temp.FH = __font_Sans
                                        win_Cat = newWin(temp)
                                    End If
                                Else
                                    Line (0, 20)-(100, 36), &H66666666, BF
                                End If

                            Case 40 To 56
                                If MouseButton(1) Then
                                    If win_Img Then
                                        freeWin win_Img
                                        win_Img = 0
                                    Else
                                        temp = __template_Win
                                        temp.IH = NewImage(temp.W, temp.H, 32)
                                        temp.T = "Image"
                                        win_Img = newWin(temp)
                                    End If
                                Else
                                    Line (0, 40)-(100, 56), &H66666666, BF
                                End If

                            Case 60 To 76
                                If MouseButton(1) Then
                                    If win_Other Then
                                        freeWin win_Other
                                        win_Other = 0
                                    Else
                                        temp = __template_Win
                                        temp.IH = NewImage(temp.W, temp.H, 32)
                                        temp.FH = __font_Mono
                                        win_Other = newWin(temp)
                                    End If
                                Else
                                    Line (0, 60)-(100, 76), &H66666666, BF
                                End If
                        End Select
                    End If
                End If


            Case win_Other 'Other window
                If w(win).NeedsRefresh Then resizeWin win_Other
                'Window contents
                Dest w(win).IH
                Cls , 0
                Print Using "X: ####  Y: ####  Z: +####"; w(win).X, w(win).Y, w(win).Z
                Print Using "W: ####  H: ####"; w(win).W, w(win).H
                Print Using "MX: ####  MY: ####  MS: +#  MAS: ####"; w(win).MX, w(win).MY, w(win).MS, w(win).MAS
                Print Using "IH: ########  FH: ########  win: ###"; w(win).IH, w(win).FH, win

                'Window title
                w(win).T = "Window " + LTrim$(Str$(win)) + " (" + LTrim$(Str$(w(win).X)) + "," + LTrim$(Str$(w(win).Y)) + ")-(" + LTrim$(Str$(w(win).W + w(win).X)) + "," + LTrim$(Str$(w(win).H + w(win).Y)) + ")"

        End Select
    Next
    upd
    Display
    Limit 60
Loop






$Checking:Off
Sub splitIntoWords (words() As String, text As String)
    Dim sp As Unsigned Long, oldSp As Unsigned Long
    Dim nextWord As Unsigned Long
    ReDim words(1000) As String
    Do
        oldSp = sp + 1
        sp = InStr(oldSp, text, " ")
        If sp = 0 Then Exit Do

        If nextWord > UBound(words) Then Exit Do
        words(nextWord) = Mid$(text, oldSp, sp - oldSp) + " "
        nextWord = nextWord + 1
    Loop
    words(nextWord) = Mid$(text, oldSp)
    ReDim Preserve words(nextWord + 1) As String
End Sub

Sub printWithWrap (text As String, win As Integer)
    Shared w() As winType

    If w(win).MAS > 0 Then w(win).MAS = 0
    Rem $DYNAMIC
    Dim words(1) As String
    Call splitIntoWords(words(), text)

    Dest w(win).IH
    Cls , 0

    Dim wordCount As Unsigned Long
    Dim current_X As Unsigned Long, current_Y As Unsigned Long
    current_X = 0
    current_Y = w(win).MAS

    For wordCount = 0 To UBound(words) ' for word wrapping
        Dim wordSize As Unsigned Integer

        If words(wordCount) = "" Then Continue 'prevent Illegal function calls

        If Asc(words(wordCount)) = 13 Then 'if its a newline character
            current_Y = current_Y + FontHeight(w(win).FH)
            current_X = 0
            Continue
        End If

        wordSize = PrintWidth(words(wordCount), w(win).IH)

        If wordSize + current_X > w(win).W Then
            current_Y = current_Y + FontHeight(w(win).FH)

            If current_Y > w(win).H Then Exit For

            current_X = 0
        End If

        PrintString (current_X, current_Y), words(wordCount), w(win).IH
        current_X = current_X + wordSize
    Next
    Line (current_X, current_Y)-Step(0, FontHeight(w(win).FH))
End Sub

$Checking:On


$Checking:Off
$If LIGHT = TRUE Then
        Sub putWin (w As winType)
        Shared __param_TBHeight As Unsigned byte

        If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!
        _DontBlend

        If w.Z = 0 Then
        Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF000000, BF
        Else Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF999999, BF
        End If

        PrintString ((w.W - PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

        PutImage (w.X + 1, w.Y + __param_TBHeight), w.IH, , (0, 0)-Step(w.W, w.H) ' Put the contents of the window down
        End Sub
$Else
    Sub putWin (w As winType)
        Shared __param_TBHeight As Unsigned Byte

        'For speed
        Rem RGBA32(0, 0, 0, 10)  = &H0A000000
        Rem RGBA32(0, 0, 0, 200) = &HC8000000
        Rem RGBA32(0, 0, 0, 64)  = &H40000000

        'LINE (w.X - 2, w.Y - 2)-STEP(w.W + 6, w.H + __param_TBHeight + 6), &H2A000000, BF 'Shadow

        If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

        If w.Z = 0 Then
            Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HC8000000, BF 'Window backing
        End If

        PrintString ((w.W - PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

        PutImage (w.X + 1, w.Y + __param_TBHeight), w.IH, , (0, 0)-Step(w.W, w.H) ' No stretch one
        'PutImage (w.X + 1, w.Y + __param_TBHeight)-Step(w.W, w.H), w.IH ' Put the contents of the window down

        Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF000000, B ' Outline

        If w.Z Then Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &H40000000, BF 'Dark overlay if not focused
    End Sub

    Sub putOverlay (w As winType)
        Shared __param_TBHeight As Unsigned Byte
        Line (w.X, w.Y)-Step(w.W, w.H), &HFF000000, B
        PutImage (w.X + 1, w.Y + 1), w.IH
    End Sub
$End If
$Checking:On


$Checking:Off
Sub upd
    Shared w() As winType
    Shared winZOrder() As Byte
    Shared __image_Background As Long
    Shared __image_Screen As Long
    Shared __image_ScreenBuffer As Long
    Shared __image_Cursor As Long
    Shared __param_ScreenFont As Long
    'Shared __inKey$

    __inKey$ = InKey$

    $If HW = TRUE Then
            IF RESIZE THEN
            DIM tempImage AS LONG

            tempImage = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32)
            SCREEN tempImage

            FREEIMAGE __image_Screen
            __image_Screen = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32)

            FREEIMAGE __image_ScreenBuffer
            __image_ScreenBuffer = COPYIMAGE(tempImage, 33)

            FONT __param_ScreenFont, __image_ScreenBuffer
            printmode keepbackground,__image_screenbuffer
            SCREEN __image_Screen

            FREEIMAGE tempImage
            END IF

            DEST __image_ScreenBuffer
    $Else
        If (Resize) Then 'If the program window is resizing
            Screen 0
            FreeImage __image_Screen
            __image_Screen = NewImage(ResizeWidth, ResizeHeight, 32)
            Screen __image_Screen
            Font __param_ScreenFont, __image_Screen
            PrintMode KeepBackground , __image_Screen
        End If

        Dest Display
    $End If

    PutImage , __image_Background 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    PrintString (0, 0), "FPS:" + Str$(fps) 'the fps function is fps the amount of times it's called in a second.

    fixFocusArray

    Dim i As Integer
    For i = UBound(winZOrder) To LBound(winZOrder) Step -1
        If winZOrder(i) <> 0 Then
            If w(winZOrder(i)).T = "" Then putOverlay w(winZOrder(i)) Else putWin w(winZOrder(i))
        End If
    Next

    PutImage (MouseX, MouseY), __image_Cursor

    $If HW = TRUE Then
            PUTIMAGE , __image_ScreenBuffer, __image_Screen
    $End If
End Sub
$Checking:On





'$Checking:Off
Function newWin% (template As winType)
    Shared w() As winType

    Font template.FH, template.IH
    template.X = MouseX
    template.Y = MouseY
    Dim i As Integer
    For i = LBound(w) To UBound(w)

        If (w(i).IH = 0) Then
            logP "INFO> newWin: Empty slot " + Str$(i) + " now holds window with image handle of " + Str$(w(i).IH)
            GoTo e
        End If

    Next
    ReDim Preserve w(LBound(w) To UBound(w) + 1) As winType
    i = UBound(w)
    logP "INFO> newWin: Extending w() to " + Str$(i) + " for window with image handle of " + Str$(w(i).IH)

    e:
    If template.T <> "" Then template.T = template.T + " (" + LTrim$(Str$(i)) + ")"
    w(i) = template
    If w(i).Z = 0 Then grabFocus i
    newWin% = i
End Function
'$Checking:On




'$Checking:Off
Sub logP (s As String)
    Shared w() As winType
    Shared win_Log As Integer

    Static l As String

    Dim i As Long
    i = Dest

    If s <> "" Then l = l + s + " " + Chr$(13) + " "

    If win_Log Then
        If w(win_Log).IH Then
            printWithWrap l, win_Log
            Dest i 'Restore the DEST IMAGE
        End If
    End If
End Sub
'$Checking:On




Function fps%
    Static t As Double
    Dim t2 As Double

    t2 = Timer(0.0001)
    fps = 1 / (t2 - t)
    t = t2
End Function





Sub freeWin (hdl As Integer)
    Shared w() As winType

    If w(hdl).IH = 0 Then logP "ERROR> freeWin: Window " + LTrim$(Str$(hdl)) + " doesn't exist": Exit Sub
    FreeImage w(hdl).IH
    w(hdl).IH = 0
End Sub




$Checking:Off
Sub updateMouse
    Shared w() As winType
    Shared winZOrder() As Byte
    Shared __param_TBHeight As Unsigned Byte


    Static optMenu As Integer, optWin As Integer
    Static mLockX As Single, mLockY As Single 'Or as I like to call it, mmmlocks and mmmlockie
    Static mouseLatch As Bit

    Dim win As Integer, i As Integer
    For win = LBound(winZOrder) To UBound(winZOrder)
        i = winZOrder(win)

        If i = 0 Then Continue

        If w(i).T = "" Then
            w(i).MX = MouseX - (w(i).X + 1)
            w(i).MY = MouseY - (w(i).Y + 1)
        Else
            w(i).MX = MouseX - (w(i).X + 1)
            w(i).MY = MouseY - (w(i).Y + __param_TBHeight + 1)
        End If

        If mouseIsOver(i) Then

            If MouseButton(1) And (__inKey$ = " ") Then 'Open options (Middle click)
                If optMenu = 0 Then
                    __template_WinOptions.IH = CopyImage(__template_WinOptions.IH, 32) 'So that when we inevitably freeWin the option menu, we dont erase the template's image
                    __template_WinOptions.X = w(i).X
                    __template_WinOptions.Y = w(i).Y

                    optMenu = newWin(__template_WinOptions)
                    grabFocus optMenu

                    optWin = i
                    mouseLatch = True
                End If

            ElseIf (MouseButton(1) Or MouseButton(2)) And (mouseLatch = False) Then
                grabFocus i
                mouseLatch = True

            ElseIf (__focusedWindow = i) And (Not MouseButton(1)) And (Not MouseButton(2)) Then mouseLatch = False
            End If

            Rem ElseIf (mouseIsOver(i) = false) And (MouseButton(1)) Then __focusedWindow = 0
            Rem ElseIf (mouseIsOver(i)) And (MouseButton(1)) Then grabFocus i
        End If


    Next

    If (optMenu <> 0) And (__inKey$ <> " ") Then
        If MouseButton(1) Then
            If mouseIsOver(optMenu) Then
                freeWin optWin
                freeWin optMenu
                optMenu = 0
            Else
                freeWin optMenu
                optMenu = 0
            End If
        End If
    End If

    If __focusedWindow Then
        w(__focusedWindow).MS = MouseWheel
        If w(__focusedWindow).MS <> 0 Then w(__focusedWindow).NeedsRefresh = True: w(__focusedWindow).MAS = w(__focusedWindow).MAS + w(__focusedWindow).MS

        If MouseButton(1) Then 'Move (Left click)
            w(__focusedWindow).X = w(__focusedWindow).X + (MouseX - mLockX)
            w(__focusedWindow).Y = w(__focusedWindow).Y + (MouseY - mLockY)

        ElseIf MouseButton(2) Then 'Resize (Right click)
            w(__focusedWindow).W = w(__focusedWindow).W + (MouseX - mLockX)
            w(__focusedWindow).H = w(__focusedWindow).H + (MouseY - mLockY)
            $If LIGHT = FALSE Then
                w(__focusedWindow).NeedsRefresh = True
            $End If

            $If LIGHT = TRUE Then
                    ElseIf (w(__focusedWindow).W <> _Width(w(__focusedWindow).IH)) Or (w(__focusedWindow).H <> _Height(w(__focusedWindow).IH)) Then
                    w(__focusedWindow).NeedsRefresh = True
            $End If
            'Else
            'w(__focusedWindow).NeedsRefresh = False

    End If: End If

    mLockX = MouseX
    mLockY = MouseY
End Sub
$Checking:On





Sub fixFocusArray
    Shared winZOrder() As Byte
    Shared w() As winType

    Erase winZOrder

    Dim i As Integer
    'For i = LBound(w) To UBound(w)
    '    If w(i).T = "" Then winZOrder(UBound(winZOrder)) = i
    'Next

    For i = UBound(w) To LBound(w) Step -1 'Prioritize newer windows by going backwards
        If w(i).IH = 0 Then Continue
        If i = __focusedWindow Then
            w(i).Z = 0
            winZOrder(0) = i
            Continue
        End If

        Do Until winZOrder(w(i).Z) = 0
            w(i).Z = w(i).Z + 1
        Loop
        winZOrder(w(i).Z) = i
    Next
End Sub



Sub resizeWin (win As Integer)
    Shared w() As winType
    FreeImage w(win).IH
    w(win).IH = NewImage(w(win).W, w(win).H, 32)
    setPM w(win).PM, w(win).IH
    Font w(win).FH, w(win).IH
    w(win).NeedsRefresh = False
End Sub



Sub setPM (PM As Unsigned Byte, IH As Long)
    Select Case PM
        Case __PM_KeepBackground: PrintMode KeepBackground , IH
        Case __PM_OnlyBackground: PrintMode OnlyBackground , IH
        Case __PM_FillBackground: PrintMode FillBackground , IH
        Case Else: logP "ERROR> setPM: Invalid mode '" + Str$(PM) + "'"
    End Select
End Sub




Function mouseIsOver` (win As Integer)
    Shared w() As winType
    mouseIsOver` = ((MouseX >= w(win).X) And (MouseX <= (w(win).X + w(win).W)) And (MouseY >= w(win).Y) And (MouseY <= (w(win).Y + w(win).H)))
End Function






Sub grabFocus (win As Integer)
    Shared w() As winType
    Dim i As Integer
    For i = LBound(w) To UBound(w)
        If i = win Then w(i).Z = 0 Else w(i).Z = w(i).Z + 1
    Next
    __focusedWindow = win
End Sub




Sub sendWin (w As winType, c As Long)
    Dim i As _Unsigned _Byte
    i = 0
    Put #c, , i
    Put #c, , w.X
    Put #c, , w.Y
    Put #c, , w.Z
    Put #c, , w.W
    Put #c, , w.H
    Put #c, , w.NeedsRefresh
    _Source w.IH

    Dim x As Integer, y As Integer, clr As Long

    x = _Width(w.IH)
    Put #c, , x

    y = _Height(w.IH)
    Put #c, , y

    For x = 0 To _Width(w.IH)
        For y = 0 To _Height(w.IH)
            clr = Point(x, y)
            Put #c, , clr
    Next y, x
End Sub



Sub getWin (c As Long)
    Shared temp As winType
    Dim i As _Unsigned _Byte
    Do
        i = 1
        If LOF(c) Then Get #c, , i
    Loop Until i = 0
    Do: Loop Until LOF(c)
    Get #c, , temp.X
    Do: Loop Until LOF(c)
    Get #c, , temp.Y
    Do: Loop Until LOF(c)
    Get #c, , temp.Z
    Do: Loop Until LOF(c)
    Get #c, , temp.W
    Do: Loop Until LOF(c)
    Get #c, , temp.H
    Do: Loop Until LOF(c)
    Get #c, , temp.NeedsRefresh

    Dim x As Integer, y As Integer
    Do: Loop Until LOF(c)
    Get #c, , x

    Do: Loop Until LOF(c)
    Get #c, , y

    If temp.IH = 0 Or temp.IH = -1 Then _FreeImage temp.IH
    temp.IH = _NewImage(x, y, 32)
    _Dest temp.IH

    Dim clr As Long
    For x = 0 To _Width(temp.IH)
        For y = 0 To _Height(temp.IH)
            Do: Loop Until LOF(c)
            Get #c, , clr
            PSet (x, y), clr
    Next y, x
End Sub


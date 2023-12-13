'CHESSGFX.BAS
DefInt A-Z
Dim Box(1 To 26000)
Screen 12

GoSub SetPALETTE
GoSub DrawPIX
GoSub DrawBOARD

Def Seg = VarSeg(Box(1))
BSave "chesspcs.bsv", VarPtr(Box(1)), 39000
Def Seg

'position black pieces
Put (31, 31), Box(7501), PSet
Put (81, 31), Box(15751), PSet
Put (131, 31), Box(6001), PSet
Put (181, 31), Box(14251), PSet
Put (231, 31), Box(4501), PSet
Put (281, 31), Box(15001), PSet
Put (331, 31), Box(6751), PSet
Put (381, 31), Box(16501), PSet
For x = 31 To 331 Step 100
    Put (x, 81), Box(17251), PSet
    Put (x + 50, 81), Box(8251), PSet
Next x

'position white pieces
Put (31, 381), Box(12001), PSet
Put (81, 381), Box(2251), PSet
Put (131, 381), Box(10501), PSet
Put (181, 381), Box(751), PSet
Put (231, 381), Box(9001), PSet
Put (281, 381), Box(1501), PSet
Put (331, 381), Box(11251), PSet
Put (381, 381), Box(3001), PSet
For x = 31 To 331 Step 100
    Put (x, 331), Box(3751), PSet
    Put (x + 50, 331), Box(12751), PSet
Next x
GoSub SaveSCREEN

Cls
Line (100, 100)-(539, 349), 3, B
Color 14
Locate 13, 26
Print "The chess graphics files have"
Locate 14, 28
Print "been successfully created."
Locate 16, 28
Print "You may now run CHESSUBS"

a$ = Input$(1)
End

SetPALETTE:
Restore PaletteDATA
Out &H3C8, 0
For n = 1 To 48
    Read Colr
    Out &H3C9, Colr
Next n
Return

DrawPIX:
Restore PictureDATA
MaxWIDTH = 465
MaxDEPTH = 46
x = 0: y = 0
Do
    Read Count, Colr
    For Reps = 1 To Count
        PSet (x, y), Colr
        x = x + 1
        If x > MaxWIDTH Then
            x = 0
            y = y + 1
        End If
    Next Reps
Loop Until y > MaxDEPTH
Return

SaveSCREEN:
FileNUM = 0
Def Seg = VarSeg(Box(1))
For y = 0 To 320 Step 160
    Get (0, y)-(639, y + 159), Box()
    FileNUM = FileNUM + 1
    FileNAME$ = "ChessBD" + LTrim$(Str$(FileNUM)) + ".BSV"
    BSave FileNAME$, VarPtr(Box(1)), 52000
Next y
Def Seg
Return

DrawBOARD:
Line (0, 47)-(46, 93), 7, BF
For x = 0 To 46
    For y = 0 To 46
        Select Case Point(x, y)
            Case 3: PSet (x, y + 47), 5
            Case 1: PSet (x, y + 47), 6
        End Select
    Next y
Next x

Get (0, 0)-(46, 46), Box(1000)
Put (0, 0), Box(1000)
Get (0, 47)-(46, 93), Box(2000)
Put (0, 47), Box(2000)

xx = 100: y = 100
Line (100, 100)-(300, 450), 0, BF
For x = 55 To 450 Step 35
    Get (x, 0)-(x + 30, 47), Box()
    Put (xx, y), Box()
    Put (xx - 50, y), Box(2000)
    For xxx = xx To xx + 35
        For yy = y To y + 48
            If Point(xxx, yy) <> 0 Then
                PSet (xxx - 42, yy), Point(xxx, yy)
                PSet (xxx, yy), 0
            End If
        Next yy
    Next xxx
    y = y + 50
    If y = 400 Then xx = xx + 100: y = 100
Next x
For x = 55 To 450 Step 35
    Get (x, 0)-(x + 30, 47), Box()
    Put (x, 0), Box()
    Put (xx, y), Box()
    Put (xx - 50, y), Box(1000)
    For xxx = xx To xx + 35
        For yy = y To y + 48
            If Point(xxx, yy) <> 0 Then
                PSet (xxx - 42, yy), Point(xxx, yy)
                PSet (xxx, yy), 0
            End If
        Next yy
    Next xxx
    y = y + 50
    If y = 400 Then xx = xx + 100: y = 100
Next x
Put (0, 0), Box(1000)
Put (0, 47), Box(2000)

Index = 1
For x = 50 To 350 Step 100
    For y = 100 To 350 Step 50
        Get (x, y)-(x + 46, y + 46), Box(Index)
        Put (x, y), Box(Index)
        Index = Index + 750
    Next y
Next x

Get (0, 0)-(46, 46), Box(18001)
Put (0, 0), Box(18001)
Get (0, 47)-(46, 93), Box(18751)
Put (0, 47), Box(18751)

Line (16, 16)-(444, 444), 1, BF
Line (15, 15)-(445, 445), 8, B
Line (15, 15)-(445, 15), 3
Line (15, 15)-(15, 445), 3
Line (25, 25)-(435, 435), 2, BF
For Reps = 1 To 1600
    x = Fix(Rnd * 11) + 14
    y = Fix(Rnd * 430) + 14
    If Fix(Rnd * 2) = 0 Then Colr = 3 Else Colr = 8
    If Point(x, y) = 1 Then
        PSet (x, y), Colr
        PSet (x + 420, y), Colr
    End If
    x = Fix(Rnd * 430) + 14
    y = Fix(Rnd * 11) + 14
    If Fix(Rnd * 2) = 0 Then Colr = 3 Else Colr = 8
    If Point(y, x) = 1 Then
        PSet (x, y), Colr
        PSet (x, y + 420), Colr
    End If
Next Reps
Line (25, 25)-(435, 435), 7, BF
Line (29, 29)-(430, 430), 13, B
Line (28, 28)-(431, 431), 14, B
Line (29, 430)-(430, 430), 8
Line (431, 29)-(431, 430), 8
Line (25, 25)-(435, 435), 8, B
Line (435, 26)-(435, 435), 3
Line (25, 435)-(435, 435), 3
For x = 30 To 380 Step 50
    n = n + 1
    For y = 30 To 380 Step 50
        n = n + 1
        If n Mod 2 Then Put (x + 1, y + 1), Box(18751), PSet Else Put (x + 1, y + 1), Box(18001), PSet
        Line (x, y)-(x + 49, y + 49), 14, B
        Line (x, y)-(x + 48, y + 48), 13, B
    Next y
Next x
Line (5, 5)-(634, 474), 1, B
Line (8, 8)-(631, 471), 1, B
Return

PaletteDATA:
Data 12,0,10,12,14,12,15,17,15,16,20,16
Data 63,0,0,63,60,50,58,55,45,53,50,40
Data 0,0,0,42,42,48,50,50,55,40,40,63
Data 15,15,34,58,37,15,60,52,37,63,63,63

PictureDATA:
Data 4,3,2,2,11,3,6,2,1,3,4,2,4,3,8,1,1,2,1,3,3,1,2,2,20,0
Data 7,8,392,0,18,3,4,2,1,1,1,2,3,1,1,2,4,3,5,1,3,2,5,1
Data 2,2,20,0,2,8,3,15,2,8,204,0,1,15,3,8,184,0,8,3,1,2
Data 9,3,4,2,1,1,1,2,2,1,2,2,1,3,1,2,2,3,1,2,8,1,1,3,3,1
Data 2,2,18,0,4,8,3,15,4,8,202,0,1,11,3,8,184,0,2,2,6,3
Data 1,2,5,3,8,2,2,1,10,2,5,1,1,2,1,3,1,2,3,1,2,2,18,0,2,8
Data 7,15,2,8,200,0,1,15,7,8,182,0,3,2,5,3,1,2,5,3,7,2,1,3
Data 2,1,4,2,5,1,2,2,1,1,1,2,2,1,5,2,1,1,1,2,1,1,18,0,2,8
Data 7,15,2,8,200,0,1,11,7,8,182,0,3,2,5,3,1,2,6,3,3,2,3,3
Data 2,2,1,1,1,2,3,3,5,1,2,2,1,1,1,2,2,1,3,2,1,3,2,2,2,1
Data 18,0,4,8,3,15,4,8,28,0,3,8,171,0,1,11,3,8,184,0,1,1
Data 2,2,13,3,1,2,1,1,2,2,3,3,1,2,1,1,1,2,2,3,3,1,1,2,1,1
Data 2,2,1,1,3,2,2,3,1,1,2,3,3,2,20,0,2,8,3,15,2,8,28,0
Data 2,8,2,15,1,10,2,8,169,0,1,11,3,8,32,0,1,15,2,8,149,0
Data 3,1,1,2,1,1,2,2,7,3,2,2,8,3,1,2,3,3,1,2,1,3,1,2,1,3
Data 1,2,1,1,2,2,1,1,5,2,3,1,2,2,14,0,7,8,3,15,2,10,7,8
Data 17,0,6,8,2,15,3,10,6,8,163,0,1,11,5,8,30,0,1,11,4,8
Data 148,0,1,2,5,1,1,2,14,3,1,2,10,3,2,2,1,1,1,2,1,1,3,2
Data 1,1,1,2,1,1,4,2,13,0,2,8,17,15,2,8,15,0,1,8,17,15,1,8
Data 157,0,2,11,2,15,3,11,7,8,2,12,1,8,18,0,2,15,3,8,2,11
Data 3,8,2,12,2,8,2,12,1,8,142,0,3,2,3,1,1,2,8,3,1,2,1,3
Data 1,2,1,3,2,2,2,3,1,2,8,3,2,2,1,1,1,2,1,1,4,2,6,1,12,0
Data 2,8,2,9,3,10,1,9,1,10,11,9,1,10,2,8,13,0,1,8,3,15,1,10
Data 1,9,1,10,2,15,1,10,1,9,1,10,2,15,1,10,1,9,1,10,3,15
Data 1,8,23,0,3,8,129,0,19,8,16,0,1,12,3,8,1,11,4,8,1,12
Data 4,8,1,12,3,8,1,12,24,0,1,11,2,12,114,0,3,2,2,1,2,2
Data 2,3,2,2,3,3,6,2,3,3,1,1,2,2,4,3,6,2,1,1,3,2,1,3,5,1
Data 1,2,13,0,2,8,1,9,3,10,1,9,1,10,10,9,1,10,2,8,14,0,2,8
Data 1,9,1,10,3,15,1,10,1,9,3,15,2,9,3,15,1,9,1,10,2,8,21,0
Data 2,8,3,9,2,8,127,0,19,8,16,0,19,8,24,0,3,8,114,0,7,1
Data 1,2,8,3,1,2,6,3,1,2,1,1,2,2,5,3,1,2,2,1,9,2,3,1,14,0
Data 2,8,1,9,3,10,1,9,1,10,8,9,1,10,2,8,16,0,2,8,1,9,3,10
Data 1,9,1,10,8,9,1,10,2,8,21,0,2,8,5,9,2,8,56,0,4,8,2,0
Data 7,8,2,0,4,8,52,0,17,8,18,0,17,8,24,0,1,12,4,8,113,0
Data 4,1,3,2,1,1,1,2,1,1,4,3,3,2,6,3,1,2,1,3,1,2,6,3,10,2
Data 4,3,1,2,14,0,2,8,1,9,3,10,1,9,1,10,8,9,1,10,2,8,16,0
Data 2,8,1,9,3,10,1,9,1,10,8,9,1,10,2,8,20,0,1,8,3,9,4,15
Data 1,9,2,8,21,0,3,8,31,0,1,8,1,15,1,10,1,8,2,0,1,8,4,15
Data 1,9,1,8,2,0,1,8,1,9,1,10,1,8,52,0,16,8,19,0,16,8,24,0
Data 1,12,1,8,1,15,1,11,1,12,2,8,58,0,1,8,1,15,1,11,3,0
Data 5,12,3,0,3,12,37,0,4,1,1,2,1,3,1,2,4,1,2,2,1,3,2,2
Data 1,3,7,2,8,3,2,1,3,2,1,1,4,2,4,3,1,2,15,0,2,8,1,9,3,10
Data 1,9,1,10,6,9,1,10,2,8,18,0,2,8,1,9,3,10,1,9,1,10,6,9
Data 1,10,2,8,21,0,3,8,6,15,2,8,21,0,1,8,2,15,5,8,26,0,1,8
Data 1,15,1,10,1,8,2,0,1,8,4,15,1,9,1,8,2,0,1,8,1,9,1,10
Data 1,8,53,0,15,8,20,0,15,8,23,0,3,8,1,11,3,12,2,8,24,0
Data 2,8,31,0,1,8,1,15,1,11,3,0,5,8,3,0,2,12,1,8,37,0,3,2
Data 2,1,2,2,2,1,1,2,1,1,6,2,4,1,4,2,7,3,3,1,1,2,2,1,3,2
Data 5,3,1,2,15,0,2,8,1,9,3,10,1,9,1,10,6,9,1,10,2,8,18,0
Data 2,8,1,9,3,10,1,9,1,10,6,9,1,10,2,8,21,0,1,8,1,9,2,8
Data 5,15,1,10,2,8,19,0,1,8,1,10,1,9,1,15,1,10,3,15,4,8
Data 23,0,1,8,1,15,1,10,1,8,2,0,1,8,4,15,1,9,1,8,2,0,1,8
Data 1,9,1,10,1,8,54,0,13,8,22,0,13,8,25,0,3,8,2,12,3,8
Data 23,0,1,8,1,15,5,8,27,0,1,8,1,15,1,11,3,0,5,8,3,0,2,12
Data 1,8,37,0,2,2,1,3,1,1,4,2,1,1,4,2,8,1,3,2,2,3,1,2,5,3
Data 2,1,2,2,1,1,4,2,5,3,1,2,16,0,2,8,1,9,3,10,1,9,1,10
Data 4,9,1,10,2,8,20,0,2,8,1,9,3,10,1,9,1,10,4,9,1,10,2,8
Data 21,0,1,8,3,9,2,8,4,15,1,10,2,8,19,0,1,8,1,15,1,9,2,10
Data 6,15,3,8,21,0,1,8,1,15,1,10,4,8,4,15,1,9,4,8,1,9,1,10
Data 1,8,54,0,13,8,22,0,13,8,23,0,2,8,1,12,1,0,7,8,22,0
Data 1,8,1,11,2,12,6,8,24,0,1,8,1,15,4,11,5,8,5,12,1,8,37,0
Data 3,2,3,3,1,2,1,3,13,1,3,2,1,3,1,2,2,1,4,3,4,2,1,1,3,2
Data 2,3,2,2,2,3,1,2,15,0,2,8,13,15,2,8,18,0,2,8,13,15,2,8
Data 20,0,1,8,3,15,1,9,2,8,2,15,3,10,1,8,18,0,1,8,1,10,3,15
Data 3,10,1,9,5,15,1,10,1,8,20,0,1,8,1,15,1,10,8,15,4,10
Data 2,9,1,10,1,8,53,0,15,8,20,0,15,8,22,0,3,8,1,12,1,0
Data 6,8,21,0,1,8,1,11,4,8,1,12,1,11,1,12,4,8,22,0,1,8,1,15
Data 2,11,2,12,7,8,3,12,1,8,37,0,8,3,1,2,4,3,1,2,1,3,1,2
Data 2,3,8,2,3,1,3,2,4,3,2,2,1,1,3,2,2,1,1,2,2,3,14,0,2,8
Data 15,9,2,8,16,0,2,8,15,9,2,8,19,0,1,8,4,15,1,9,2,8,1,15
Data 2,10,1,9,1,8,18,0,1,8,3,15,1,10,4,15,2,10,1,9,4,15
Data 1,8,19,0,1,8,1,15,1,10,8,15,4,10,2,9,1,10,1,8,52,0
Data 2,8,2,15,3,11,5,12,2,8,1,12,2,8,18,0,2,8,2,15,3,11
Data 5,12,2,8,1,12,2,8,21,0,2,8,1,15,2,12,1,0,5,8,21,0,1,8
Data 1,12,8,8,1,12,4,8,20,0,1,8,1,15,2,11,2,12,7,8,3,12
Data 1,8,37,0,8,3,1,2,9,3,3,2,3,3,2,2,3,1,3,2,6,3,7,1,1,2
Data 1,3,13,0,2,8,17,15,2,8,14,0,2,8,17,15,2,8,18,0,1,8
Data 1,15,1,10,3,15,1,9,1,8,3,10,1,9,1,8,17,0,1,8,1,10,3,15
Data 2,10,5,15,2,10,1,9,3,15,1,8,18,0,1,8,1,15,1,10,8,15
Data 4,10,2,9,1,10,1,8,51,0,19,8,16,0,19,8,20,0,2,8,2,12
Data 1,8,1,12,1,0,4,8,20,0,1,8,1,12,2,8,1,12,8,8,1,12,3,8
Data 19,0,1,8,1,15,2,11,2,12,7,8,3,12,1,8,37,0,8,3,1,2,16,3
Data 2,2,2,1,3,2,6,3,3,2,5,1,1,2,12,0,2,8,19,15,2,8,12,0
Data 2,8,19,15,2,8,18,0,1,8,4,15,1,10,1,9,2,10,1,9,1,8,18,0
Data 1,8,3,15,2,10,8,15,1,10,1,9,2,15,2,8,17,0,1,8,1,15
Data 1,10,8,15,4,10,2,9,1,10,1,8,24,0,3,8,23,0,2,8,3,15
Data 3,11,5,12,5,8,1,12,2,8,14,0,2,8,3,15,3,11,5,12,4,8
Data 1,12,3,8,19,0,6,8,1,12,4,8,20,0,3,8,2,12,12,8,19,0
Data 1,8,1,15,2,11,2,12,7,8,3,12,1,8,37,0,2,2,6,3,1,2,16,3
Data 3,2,3,1,1,2,8,3,1,2,6,1,13,0,2,8,17,15,2,8,14,0,2,8
Data 17,15,2,8,19,0,1,8,7,10,2,9,1,8,17,0,1,8,1,10,1,15
Data 2,8,1,10,10,15,2,10,2,15,2,8,16,0,1,8,1,15,1,10,8,15
Data 4,10,2,9,1,10,1,8,23,0,1,8,3,15,1,8,23,0,19,8,16,0
Data 19,8,21,0,9,8,20,0,2,8,1,11,2,12,11,8,1,12,2,8,18,0
Data 1,8,1,15,2,11,2,12,7,8,3,12,1,8,25,0,2,12,1,8,9,0,5,1
Data 1,2,20,3,3,2,2,1,1,2,9,3,3,1,2,2,1,1,14,0,6,8,7,9,6,8
Data 16,0,6,8,7,9,6,8,21,0,1,8,2,9,2,10,3,9,1,8,18,0,1,8
Data 3,15,1,8,1,10,11,15,1,10,1,9,2,15,1,8,16,0,2,8,15,9
Data 2,8,22,0,1,8,5,15,1,8,27,0,9,8,26,0,9,8,26,0,9,8,20,0
Data 2,8,2,11,16,8,17,0,1,8,1,15,2,11,2,12,7,8,3,12,1,8
Data 24,0,1,12,4,8,8,0,1,2,4,1,1,2,20,3,6,2,10,3,1,2,1,1
Data 1,2,2,1,18,0,2,8,7,9,2,8,24,0,2,8,7,9,2,8,26,0,1,8
Data 6,9,1,8,17,0,1,8,1,10,1,15,1,10,14,15,1,10,1,9,2,15
Data 2,8,17,0,2,8,11,9,2,8,23,0,1,8,6,15,1,10,1,8,26,0,9,8
Data 26,0,9,8,27,0,7,8,20,0,2,8,1,11,6,8,1,12,8,8,1,12,2,8
Data 18,0,15,8,24,0,1,12,2,15,1,11,3,8,7,0,1,2,3,1,2,2,19,3
Data 7,2,10,3,2,2,1,3,2,2,18,0,2,8,7,9,2,8,24,0,2,8,7,9
Data 2,8,27,0,1,8,4,9,1,8,18,0,1,8,1,15,1,10,8,15,2,10,5,15
Data 2,10,2,15,2,8,19,0,2,8,7,9,2,8,25,0,1,8,6,15,1,10,1,8
Data 26,0,9,8,26,0,9,8,28,0,5,8,21,0,1,8,1,11,7,8,1,12,8,8
Data 1,12,2,8,20,0,11,8,25,0,1,12,1,8,2,15,1,11,1,12,3,8
Data 6,0,2,2,2,1,1,2,20,3,7,2,14,3,1,2,18,0,2,8,5,10,2,9
Data 2,8,24,0,2,8,5,10,2,9,2,8,22,0,5,8,4,15,2,10,5,8,12,0
Data 1,8,2,10,8,15,3,10,5,15,2,10,1,9,2,15,1,8,20,0,1,8
Data 7,9,1,8,26,0,1,8,6,15,1,10,1,8,26,0,9,8,26,0,9,8,26,0
Data 9,8,18,0,1,8,1,11,8,8,1,12,12,8,20,0,9,8,26,0,1,12
Data 1,8,2,11,2,12,2,8,1,12,6,0,1,3,3,2,22,3,6,2,15,3,17,0
Data 2,8,2,15,5,10,2,9,2,8,22,0,2,8,2,15,5,10,2,9,2,8,20,0
Data 2,8,11,15,2,10,1,15,2,8,11,0,1,8,4,15,1,9,5,15,1,8
Data 1,9,1,10,5,15,2,10,1,9,2,15,1,8,17,0,3,8,10,15,2,8
Data 23,0,1,8,1,10,2,15,4,10,1,8,25,0,11,8,24,0,11,8,22,0
Data 3,8,2,15,2,11,3,12,5,8,15,0,4,8,1,12,15,8,1,12,2,8
Data 17,0,15,8,23,0,1,12,1,8,3,12,3,8,1,12,6,0,26,3,6,2
Data 15,3,17,0,2,8,3,15,4,10,2,9,2,8,22,0,2,8,3,15,4,10
Data 2,9,2,8,19,0,2,8,16,9,2,8,9,0,1,8,1,10,5,15,1,9,3,15
Data 1,8,2,9,6,15,1,10,2,9,2,15,1,8,16,0,1,8,15,10,1,8,23,0
Data 1,8,5,10,1,8,26,0,11,8,24,0,11,8,21,0,17,8,13,0,6,8
Data 1,12,4,8,1,12,9,8,1,12,2,8,16,0,17,8,23,0,1,12,5,8
Data 1,12,7,0,24,3,1,1,6,3,1,2,2,3,4,2,1,1,1,2,7,3,17,0
Data 2,8,4,15,3,10,2,9,2,8,22,0,2,8,4,15,3,10,2,9,2,8,19,0
Data 1,8,13,15,4,10,1,15,1,8,9,0,1,8,1,15,1,8,1,9,2,15,1,10
Data 1,15,1,9,2,8,2,9,1,10,6,15,1,10,2,9,2,15,1,8,15,0,1,8
Data 17,15,1,8,23,0,1,8,3,10,1,8,27,0,11,8,24,0,11,8,20,0
Data 3,8,2,15,2,11,3,12,6,8,3,12,12,0,1,8,1,11,1,12,2,8
Data 1,12,1,8,2,12,1,8,1,12,10,8,1,12,2,8,15,0,1,8,2,15
Data 3,11,4,12,6,8,2,12,1,8,22,0,1,12,4,8,2,12,7,0,31,3
Data 1,2,2,3,4,2,1,1,2,2,6,3,17,0,2,8,4,15,4,10,1,9,2,8
Data 22,0,2,8,4,15,4,10,1,9,2,8,19,0,2,8,8,15,8,10,2,8,9,0
Data 1,8,1,15,2,9,2,8,2,10,2,8,2,9,1,10,6,15,1,10,3,9,2,15
Data 1,8,16,0,6,8,5,9,6,8,24,0,1,8,3,9,1,8,27,0,11,8,24,0
Data 11,8,21,0,17,8,13,0,1,8,2,12,2,8,2,12,1,0,1,8,1,12
Data 14,8,16,0,17,8,25,0,1,12,2,8,9,0,34,3,7,2,6,3,16,0
Data 2,8,5,15,4,10,2,9,2,8,20,0,2,8,5,15,4,10,2,9,2,8,19,0
Data 6,8,6,9,6,8,11,0,1,8,1,9,1,15,1,8,1,15,1,10,2,8,1,9
Data 2,10,6,15,2,10,2,9,2,15,2,8,21,0,1,8,5,9,1,8,26,0,1,8
Data 9,9,1,8,23,0,13,8,22,0,13,8,25,0,7,8,18,0,1,8,1,12
Data 3,8,1,12,1,0,1,8,1,12,14,8,22,0,7,8,26,0,11,8,5,0,31,3
Data 1,2,3,3,7,2,5,3,16,0,2,8,5,15,4,10,2,9,2,8,20,0,2,8
Data 5,15,4,10,2,9,2,8,23,0,2,8,6,9,2,8,16,0,2,8,1,15,1,10
Data 2,8,1,9,2,10,6,15,5,10,2,15,1,8,22,0,1,8,5,9,1,8,25,0
Data 1,8,11,15,1,8,22,0,13,8,22,0,13,8,25,0,7,8,20,0,2,8
Data 1,12,1,0,1,8,1,12,12,8,1,12,2,8,22,0,7,8,25,0,1,8,2,15
Data 3,11,4,12,3,8,4,0,25,3,6,2,8,3,3,2,5,3,16,0,2,8,6,15
Data 3,10,2,9,2,8,20,0,2,8,6,15,3,10,2,9,2,8,23,0,2,8,6,9
Data 2,8,18,0,4,8,1,10,6,15,7,10,1,15,2,8,22,0,1,8,2,15
Data 3,10,1,8,26,0,4,8,3,9,4,8,23,0,13,8,22,0,13,8,25,0
Data 7,8,23,0,1,8,1,11,12,8,1,12,2,8,23,0,7,8,26,0,11,8
Data 5,0,2,3,1,2,23,3,2,2,2,3,2,2,15,3,16,0,2,8,11,9,2,8
Data 20,0,2,8,11,9,2,8,23,0,1,8,2,15,4,10,2,9,1,8,19,0,2,8
Data 17,15,1,8,22,0,1,8,4,15,1,10,1,8,29,0,1,8,3,9,1,8,26,0
Data 13,8,22,0,13,8,24,0,9,8,21,0,1,8,1,11,1,12,16,8,21,0
Data 9,8,29,0,3,8,9,0,26,3,1,2,5,3,1,2,14,3,15,0,2,8,6,15
Data 6,10,1,9,2,8,18,0,2,8,6,15,6,10,1,9,2,8,22,0,1,8,3,15
Data 4,10,1,9,1,8,18,0,1,8,20,15,1,8,20,0,1,8,1,9,4,15,2,10
Data 1,8,28,0,1,8,3,15,1,8,25,0,2,8,1,15,3,11,3,12,6,8,20,0
Data 2,8,1,15,3,11,3,12,6,8,23,0,9,8,21,0,1,8,1,12,1,11
Data 4,12,11,8,1,12,1,8,20,0,9,8,28,0,5,8,8,0,6,3,3,2,23,3
Data 1,2,14,3,14,0,2,8,9,15,4,10,1,9,1,10,2,8,16,0,2,8,9,15
Data 4,10,1,9,1,10,2,8,20,0,1,8,5,15,3,10,2,9,1,8,18,0,2,8
Data 16,9,2,8,20,0,1,8,2,9,5,15,1,10,1,9,1,8,26,0,1,8,3,15
Data 2,10,1,8,23,0,2,8,3,15,1,11,1,12,8,8,1,12,1,8,18,0
Data 2,8,3,15,1,11,1,12,9,8,1,12,21,0,11,8,21,0,15,8,2,12
Data 1,8,20,0,11,8,27,0,5,8,8,0,2,2,1,3,3,2,3,1,2,2,10,3
Data 4,2,7,3,1,2,12,3,2,2,13,0,2,8,10,15,4,10,2,9,1,10,2,8
Data 14,0,2,8,10,15,4,10,2,9,1,10,2,8,18,0,2,8,6,15,2,10
Data 2,9,2,8,16,0,2,8,18,15,2,8,19,0,1,8,1,9,6,15,1,10,1,9
Data 1,8,25,0,1,8,5,15,2,10,1,8,21,0,2,8,3,15,2,11,1,12
Data 9,8,1,12,1,8,16,0,2,8,3,15,2,11,1,12,9,8,1,12,1,8,20,0
Data 11,8,20,0,2,8,2,15,4,11,5,12,6,8,20,0,11,8,26,0,7,8
Data 7,0,3,2,1,3,2,2,3,1,2,2,13,3,1,2,2,1,1,2,4,3,2,2,13,3
Data 13,0,2,8,9,15,5,10,3,9,2,8,14,0,2,8,9,15,5,10,3,9,2,8
Data 18,0,2,8,10,9,2,8,17,0,2,8,16,9,2,8,20,0,1,8,9,9,1,8
Data 24,0,2,8,7,9,2,8,20,0,1,8,1,12,1,11,1,15,2,11,1,12
Data 11,8,1,12,16,0,1,8,1,12,1,11,1,15,2,11,1,12,11,8,1,12
Data 20,0,11,8,21,0,17,8,21,0,11,8,25,0,9,8,6,0,2,2,3,3
Data 2,2,3,1,1,2,14,3,3,2,2,3,1,2,1,3,1,2,14,3,12,0,2,8
Data 9,15,6,10,3,9,1,10,2,8,12,0,2,8,9,15,6,10,3,9,1,10
Data 2,8,16,0,2,8,6,15,3,10,3,9,2,8,18,0,2,8,9,10,3,9,2,8
Data 21,0,1,8,6,15,3,10,2,9,1,8,22,0,1,8,6,15,3,10,2,9,1,8
Data 19,0,1,8,2,12,2,11,1,12,12,8,1,12,16,0,1,8,2,12,2,11
Data 1,12,12,8,1,12,19,0,2,8,1,15,2,11,3,12,5,8,22,0,2,8
Data 1,15,2,11,3,12,5,8,22,0,2,8,1,15,3,11,3,12,4,8,23,0
Data 2,8,1,15,2,11,3,12,3,8,5,0,6,3,3,2,14,3,5,2,3,3,1,2
Data 15,3,12,0,2,8,8,15,6,10,4,9,1,10,2,8,12,0,2,8,8,15
Data 6,10,4,9,1,10,2,8,15,0,2,8,8,15,3,10,3,9,2,8,17,0,1,8
Data 6,15,5,10,3,9,1,8,20,0,1,8,8,15,3,10,2,9,1,8,20,0,1,8
Data 8,15,3,10,2,9,1,8,18,0,18,8,1,12,16,0,18,8,1,12,18,0
Data 2,8,1,15,1,11,1,12,8,8,1,12,1,8,20,0,2,8,2,15,1,11
Data 1,12,7,8,1,12,1,8,20,0,2,8,1,15,2,11,1,12,7,8,1,12
Data 1,8,21,0,2,8,1,15,1,11,1,12,6,8,1,12,1,8,4,0,7,3,1,2
Data 14,3,1,2,2,1,2,2,19,3,1,2,12,0,2,8,6,15,7,10,5,9,1,10
Data 2,8,12,0,2,8,6,15,7,10,5,9,1,10,2,8,14,0,2,8,9,15,3,10
Data 4,9,2,8,15,0,1,8,9,15,3,10,4,9,1,8,18,0,1,8,9,15,3,10
Data 3,9,1,8,18,0,1,8,9,15,3,10,3,9,1,8,16,0,20,8,1,12,14,0
Data 20,8,1,12,17,0,1,8,3,15,2,12,8,8,1,12,1,8,18,0,2,8
Data 2,15,2,11,1,12,8,8,1,12,1,8,18,0,2,8,3,15,1,11,2,12
Data 7,8,1,12,1,8,19,0,2,8,3,15,2,12,6,8,1,12,1,8,3,0,6,3
Data 1,2,1,1,5,2,9,3,1,2,2,1,1,2,10,3,3,2,1,3,7,2,12,0,2,8
Data 4,15,8,10,6,9,1,10,2,8,12,0,2,8,4,15,8,10,6,9,1,10
Data 2,8,14,0,2,8,8,15,4,10,4,9,2,8,15,0,1,8,8,15,4,10,4,9
Data 1,8,18,0,1,8,8,15,4,10,3,9,1,8,18,0,1,8,8,15,4,10,3,9
Data 1,8,16,0,20,8,1,12,14,0,21,8,16,0,2,8,1,11,1,15,2,11
Data 1,12,9,8,1,12,18,0,2,8,3,11,2,12,9,8,1,12,18,0,2,8
Data 1,11,1,15,2,11,2,12,8,8,1,12,19,0,2,8,1,11,1,15,1,11
Data 2,12,7,8,1,12,3,0,2,3,2,2,8,1,4,2,5,3,1,2,4,1,1,2,9,3
Data 2,2,6,3,3,2,11,0,2,8,2,15,10,10,8,9,1,10,2,8,10,0,2,8
Data 2,15,10,10,8,9,1,10,2,8,13,0,2,8,6,15,4,10,6,9,2,8
Data 14,0,1,8,7,15,4,10,7,9,1,8,17,0,1,8,6,15,4,10,5,9,1,8
Data 17,0,1,8,7,15,4,10,6,9,1,8,14,0,22,8,1,12,12,0,22,8
Data 1,12,15,0,2,8,4,12,10,8,1,12,18,0,2,8,4,12,10,8,1,12
Data 18,0,2,8,4,12,10,8,1,12,19,0,2,8,4,12,8,8,1,12,3,0
Data 1,2,14,1,5,2,5,1,1,2,5,3,1,2,13,3,2,2,10,0,2,8,22,9
Data 1,10,2,8,8,0,2,8,22,9,1,10,2,8,11,0,2,8,3,15,5,10,10,9
Data 2,8,12,0,2,8,3,15,5,10,10,9,2,8,15,0,1,8,3,15,5,10
Data 9,9,1,8,16,0,1,8,3,15,5,10,9,9,1,8,13,0,1,8,4,15,4,11
Data 8,12,7,8,1,12,10,0,1,8,4,15,4,11,8,12,5,8,3,12,13,0
Data 18,8,1,12,16,0,18,8,1,12,16,0,18,8,1,12,17,0,16,8,1,12
Data 2,0,17,1,2,2,6,1,1,2,4,3,2,2,15,3,10,0,1,8,25,15,1,8
Data 8,0,1,8,25,15,1,8,10,0,3,8,18,9,3,8,10,0,2,8,20,9,1,8
Data 13,0,3,8,17,9,3,8,13,0,2,8,17,9,1,8,13,0,24,8,1,12
Data 10,0,24,8,1,12,13,0,18,8,1,12,16,0,18,8,1,12,16,0,18,8
Data 1,12,17,0,16,8,1,12,2,0,1,1,1,2,23,1,1,2,21,3,10,0
Data 1,8,7,15,1,10,1,15,5,10,9,9,2,10,1,8,8,0,1,8,7,15,1,10
Data 1,15,5,10,9,9,2,10,1,8,10,0,1,8,22,15,1,8,10,0,1,8
Data 22,15,1,8,12,0,1,8,21,15,1,8,13,0,1,8,19,15,1,8,12,0
Data 24,8,1,12,10,0,24,8,1,12,11,0,1,8,3,15,3,11,5,12,10,8
Data 1,12,12,0,1,8,3,15,3,11,5,12,10,8,1,12,12,0,2,8,3,15
Data 3,11,5,12,9,8,1,12,13,0,1,8,3,15,3,11,5,12,8,8,1,12
Data 1,2,1,3,1,2,22,1,1,2,21,3,10,0,1,8,7,15,1,10,1,15,5,10
Data 9,9,2,10,1,8,8,0,1,8,7,15,1,10,1,15,5,10,9,9,2,10,1,8
Data 10,0,1,8,8,15,6,10,7,9,1,10,1,8,10,0,1,8,8,15,6,10
Data 7,9,1,10,1,8,12,0,1,8,8,15,6,10,7,9,1,8,13,0,1,8,7,15
Data 6,10,6,9,1,8,12,0,24,8,1,12,10,0,24,8,1,12,11,0,22,8
Data 1,12,12,0,22,8,1,12,12,0,22,8,1,12,13,0,20,8,1,12,1,1
Data 2,2,1,1,2,2,19,1,1,2,2,3,1,2,1,3,2,2,15,3,10,0,1,8
Data 7,15,1,10,1,15,5,10,9,9,2,10,1,8,8,0,1,8,7,15,1,10
Data 1,15,5,10,9,9,2,10,1,8,10,0,1,8,8,15,6,10,7,9,1,10
Data 1,8,10,0,1,8,8,15,6,10,7,9,1,10,1,8,12,0,1,8,8,15,6,10
Data 7,9,1,8,13,0,1,8,7,15,6,10,6,9,1,8,12,0,24,8,1,12,10,0
Data 24,8,1,12,11,0,22,8,1,12,12,0,22,8,1,12,12,0,22,8,1,12
Data 13,0,20,8,1,12

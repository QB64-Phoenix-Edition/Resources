'+----------------------------------------------------------------------------+
'|                   QB64 Asteroids! by Terry Ritchie                         |
'|                       terry.ritchie@gmail.com                              |
'|                                                                            |
'|                         Programmed in QB64                                 |
'|                            www.qb64.net                                    |
'|                           July 29th 2011                                   |
'|                                                                            |
'| This program was created as a test bed for Ritchie's Sprite Library. It    |
'| has been released as freeware. Please pass a copy along to anyone who      |
'| might like it. If you use any of the code inside, or modify the game,      |
'| please give credit where credit is due. Thank you and have fun!            |
'|                                                                            |
'| A special thanks to Rob (Galleon) the creator of QB64, for allowing old-   |
'| school programmers to continue their craft.                                |
'+----------------------------------------------------------------------------+

'$INCLUDE:'spritetop.bi'

CONST FALSE = 0, TRUE = NOT FALSE ' boolean constants
CONST PI = 3.1415926 '              I like with ice cream

TYPE SPARK '                holds explosion spark information
    count AS INTEGER '      used to time how long spark will last
    x AS SINGLE '           x location on screen of spark
    y AS SINGLE '           y location on screen of spark
    xdir AS SINGLE '        the horizontal vector of the spark
    ydir AS SINGLE '        the vertical vector of the spark
    speed AS SINGLE '       the speed the spark is traveling
    fade AS INTEGER '       the current amount the spark is fading
END TYPE

TYPE TOPTEN '               holds top ten high score information
    initials AS STRING * 3 'the player's initials
    score AS DOUBLE '       the player's high score
END TYPE

REDIM sparks(0) AS SPARK '  GFX: array to hold collision and explosion pixels
REDIM rocks%(0) '           GFX: the asteroids flying around on the screen
DIM rock%(3, 3) '           GFX: the nine asteroid sprites to choose from (rock%(size, rock)  size = 1 to 3, rock = 1 to 3)
DIM lfont%(35) '            GFX: the large number and letter fonts
DIM sfont%(9) '             GFX: the small number fonts
DIM round%(5) '             GFX: the player's five bullet rounds
DIM sround%(3) '            GFX: the saucer's three bullet rounds
DIM rocksheet128% '         GFX: the sprite sheet containing the large asteroid images
DIM rocksheet64% '          GFX: the sprite sheet containing the medium asteroid images
DIM rocksheet32% '          GFX: the sprite sheet containing the small asteroid images
DIM lfontsheet% '           GFX: the sprite sheet containing the large number and letter fonts
DIM sfontsheet% '           GFX: the sprite sheet containing the small number fonts
DIM shipsheet% '            GFX: the sprite sheet containing the player ship images
DIM roundsheet% '           GFX: the sprite sheet containing the bullet rounds
DIM bsaucersheet% '         GFX: the sprite sheet containing the big saucer image
DIM lsaucersheet% '         GFX: the sprite sheet containing the little saucer image
DIM ship% '                 GFX: the player's ship
DIM extraship% '            GFX: inmages of the player ships remaining
DIM bsaucer% '              GFX: the big flying saucer
DIM lsaucer% '              GFX: the little flying saucer
DIM saucer% '               GFX: the flying saucer currently on screen
DIM icon& '                 GFX: the game window icon
DIM explode&(3) '           SND: the three explosion sounds in game
DIM beat&(1) '              SND: the jaws beats in the background
DIM thrust& '               SND: ship thrusting forward sound
DIM pfire& '                SND: player ship firing sound
DIM extralife& '            SND: extra ship awarded sound
DIM bigsaucer& '            SND: the big saucer flying sound
DIM littlesaucer& '         SND: the little saucer flying sound (run! hide!)
DIM hiscore(10) AS TOPTEN ' the top ten high scores
DIM level% '                the current game level
DIM score& '                the surrent game score
DIM hiscore& '              the overall high score
DIM shipsremaining% '       player ships remaining in game
DIM rocksleft% '            the number of small rocks remaining in the level
DIM newlevelwait% '         time to pause between levels
DIM beattimer! '            time to pause between background beat sounds
DIM intro% '                true when game in intro screen mode
DIM saucerflying% '         true when a saucer is on screen
DIM playerdead% '           true when player has died
DIM deathfinished% '        true when last death sequence finished
DIM enter% '                true when player presses ENTER to start game
DIM coin% '                 true when player inserts coin
DIM gameover% '             true when a game has ended

SCREEN _NEWIMAGE(1024, 768, 32) '                                              set up 1024x768 screen with 32bit color
CLS '                                                                          clear the screen to remove alpha blending
_SCREENMOVE _MIDDLE '                                                          move the game screen to center of player screen
icon& = _LOADIMAGE("aicon.bmp", 32) '                                          load the game window icon
_ICON icon& '                                                                  set the icon image
_FREEIMAGE icon& '                                                             icon image no longer needed
_TITLE "QB64 Asteroids!" '                                                     give the window a title
RANDOMIZE TIMER '                                                              seed the random number generator
LoadSounds '                                                                   load the game sounds
LoadGraphics '                                                                 load the game graphics
LoadHiScores '                                                                 load the high scores
DO '                                                                           start the main loop
    IntroScreen '                                                              show the intro screen
    level% = 1 '                                                               start the game at level 1
    score& = 0 '                                                               reset the player score
    shipsremaining% = 3 '                                                      set the amount of ships player has
    beattimer! = 32 '                                                          set the beat sound timer
    newlevelwait% = 96 '                                                       set the amount of wait time between levels
    playerdead% = FALSE '                                                      tell the program the player is alive and well
    NewLevel '                                                                 create a new level
    DO '                                                                       start game loop
        DO '                                                                   start of level loop
            _LIMIT 32 '                                                        limit game play to 32 frames per second
            CLS '                                                              clear the game screen
            deathfinished% = FALSE '                                           make sure death sequence is seen at end
            UpdateSparks '                                                     move any sparks that may be on screen
            UpdateRocks '                                                      update the asteroid positions on screen
            UpdatePlayer '                                                     check and update the player's movements
            IF playerdead% THEN UpdatePlayerDeath '                            update player death routines
            UpdateUfo '                                                        update ufo movement on screen
            UpdateBullets '                                                    move any bullets that may be on screen
            UpdateCollisions '                                                 handle any collisions that may have occured
            UpdateScore '                                                      update the player's score, high score and ships
            _DISPLAY '                                                         display the results of previous subs on screen
        LOOP UNTIL (rocksleft% = 0) OR (shipsremaining% = 0) '                 end the level loop
        IF newlevelwait% > 0 THEN newlevelwait% = newlevelwait% - 1 '          countdown until next level can be shown
        IF newlevelwait% = 0 THEN '                                            has the countdown completed?
            level% = level% + 1 '                                              yes, increment the game level
            IF level% > 9 THEN level% = 9 '                                    generate no more than 12 large rocks
            NewLevel '                                                         create a new level
            newlevelwait% = 96 '                                               reset the countdown timer
            beattimer! = 32 '                                                  reset the beat sound timer
        END IF
    LOOP UNTIL (shipsremaining% = 0) AND deathfinished% '                      end the game loop
    gameover% = TRUE '                                                         inform the intro screen that a game has ended
LOOP '                                                                         end the main loop
END

'##################################################################################################################################

SUB UpdateHiScores ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Gets the initials of the player that achieved a high score and saves them and the score to the high score file.                |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED hiscore() AS TOPTEN, score&

DIM toolong% '                                                                 2 minute countdown timer that leaves when reached
DIM letter%(3) '                                                               the three player initials
DIM currentletter% '                                                           the current initial being selected
DIM keytimer% '                                                                timer used to keep letters from going by too fast
DIM finished% '                                                                true when player finished entering initials

toolong% = 3840 '                                                              leaves loop when 2 minutes elapsed (3840 frames)
letter%(1) = 65 '                                                              set first letter in initials to "A"
letter%(2) = 32 '                                                              set second letter in initials to " "
letter%(3) = 32 '                                                              set third letter in initials to " "
currentletter% = 1 '                                                           current intital being changed
finished% = FALSE '                                                            not finished yet
DO '                                                                           start the initial selection loop here
    _LIMIT 32 '                                                                limit updates to 32fps
    CLS '                                                                      clear the screen
    toolong% = toolong% - 1 '                                                  decrement the 2 minute countdown timer
    IF toolong% = 0 THEN EXIT DO '                                             if 2 minutes have elapased then exit loop
    UpdateScore '                                                              show the score and high score on screen
    DrawText 10, 250, "YOUR SCORE IS ONE OF THE 10 BEST" '                     inform the player that they are an asteroids god
    DrawText 10, 300, "PLEASE ENTER YOUR INITIALS" '                           and instruct them on how to enter their initials
    DrawText 10, 350, "PUSH ROTATE TO SELECT LETTER"
    DrawText 10, 400, "PUSH HYPERSPACE WHEN LETTER CORRECT"
    DrawText 442, 500, CHR$(letter%(1)) + " " + CHR$(letter%(2)) + " " + CHR$(letter%(3)) 'draw the initials on the screen
    LINE (454, 520)-(482, 520), _RGB(128, 128, 128) '                          first letter underline
    LINE (511, 520)-(539, 520), _RGB(128, 128, 128) '                          second letter underline
    LINE (568, 520)-(596, 520), _RGB(128, 128, 128) '                          third letter underline
    IF _KEYDOWN(19712) AND keytimer% = 0 THEN '                                is the player pressing the right arrow key?
        letter%(currentletter%) = letter%(currentletter%) + 1 '                yes, increment the ASCII value of the letter
        IF letter%(currentletter%) = 91 THEN letter%(currentletter%) = 65 '    has the ASCII value gone beyond Z? set to A if so
        keytimer% = 8 '                                                        next keypress won't be seen for 8 frames
    END IF
    IF _KEYDOWN(19200) AND keytimer% = 0 THEN '                                is the player pressing the left arrow key?
        letter%(currentletter%) = letter%(currentletter%) - 1 '                yes, decrement the ASCII value of the letter
        IF letter%(currentletter%) = 64 THEN letter%(currentletter%) = 90 '    has the ASCII value gone below A? set to Z if so
        keytimer% = 8 '                                                        next keypress won't be seen for 8 frames
    END IF
    IF _KEYDOWN(20480) AND keytimer% = 0 THEN '                                is the player pressing the down arrow key?
        currentletter% = currentletter% + 1 '                                  yes, move to the next letter
        IF currentletter% = 4 THEN '                                           is the next letter too far?
            finished% = TRUE '                                                 yes, set the finished flag
        ELSE '                                                                 no, still within the 3 initials
            letter%(currentletter%) = 65 '                                     set this letter to "A"
        END IF
        keytimer% = 8 '                                                        next keypress won't be seen for 8 frames
    END IF
    IF keytimer% > 0 THEN keytimer% = keytimer% - 1 '                          decrement the keypress timer if needed
    _DISPLAY '                                                                 display the results of the previous commands on screen
LOOP UNTIL finished% '                                                         continue looping until player finished
IF toolong% = 0 THEN '                                                         did 2 minutes elapse?
    IF letter%(2) = 32 THEN letter%(2) = 65 '                                  yes, set the second letter to "A" if it's a space
    IF letter%(3) = 32 THEN letter%(3) = 65 '                                  set the third letter to "A" if it's a space
END IF
hiscore(10).score = score& '                                                   set the last high score array container to score
hiscore(10).initials = CHR$(letter%(1)) + CHR$(letter%(2)) + CHR$(letter%(3)) 'set the last high score array container to initials
SortHiScores '                                                                 sort the new high score into proper order
SaveHiScores '                                                                 save the new high score to the high score file

END SUB

'##################################################################################################################################

SUB SortHiScores ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Bubble sorts the high scores into descending order.                                                                            |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED hiscore() AS TOPTEN

DIM count1% '                                                                  generic counter
DIM count2% '                                                                  generic counter

FOR count1% = 1 TO 10 '                                                        cycle through the high score array 10 times
    FOR count2% = 1 TO 10 '                                                    cycle through the high score array 10 more times
        IF hiscore(count1%).score > hiscore(count2%).score THEN '              is the lower score greater than the score above?
            SWAP hiscore(count1%), hiscore(count2%) '                          yes, swap the array values with each other
        END IF
    NEXT count2%
NEXT count1%

END SUB

'##################################################################################################################################

SUB SaveHiScores ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Saves the 10 high scores to the high score file.                                                                               |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED hiscore() AS TOPTEN

DIM filenum% '                                                                 the next available file handle
DIM count% '                                                                   generic counter

filenum% = FREEFILE '                                                          get the next available file handle
OPEN "asteroids.hi" FOR OUTPUT AS #filenum% '                                  open the high score file for output
FOR count% = 1 TO 10 '                                                         cycle through all 10 high score array containers
    PRINT #filenum%, hiscore(count%).initials '                                print the player's initials to the file
    PRINT #filenum%, hiscore(count%).score '                                   print the player's high score to the file
NEXT count%
CLOSE #filenum% '                                                              close the high score file

END SUB

'##################################################################################################################################

SUB LoadHiScores ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Load the high scores from the high score file or creates the file if it does not exist.                                        |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED hiscore() AS TOPTEN, hiscore&

DIM filenum% '                                                                 the next available file handle
DIM count% '                                                                   generic counter

filenum% = FREEFILE '                                                          get the next available file handle
OPEN "asteroids.hi" FOR APPEND AS #filenum% '                                  open the high score file for appending
IF LOF(filenum%) THEN '                                                        is the length of the file greater than 0?
    CLOSE #filenum% '                                                          yes, the file exists, close the file
    filenum% = FREEFILE '                                                      get the next available file handle
    OPEN "asteroids.hi" FOR INPUT AS #filenum% '                               open the high score file for input
    FOR count% = 1 TO 10 '                                                     cycle through all 10 high score array containers
        INPUT #filenum%, hiscore(count%).initials '                            get the player's initials
        INPUT #filenum%, hiscore(count%).score '                               get the player's high score
    NEXT count%
    CLOSE #filenum% '                                                          close the high score file
    hiscore& = hiscore(1).score '                                              set the game's highest high score
ELSE '                                                                         the high score file does not exist
    CLOSE #filenum% '                                                          close the open appended file
    KILL "asteroids.hi" '                                                      kill temporary file that was created for appending
    hiscore(1).initials = "TWR" '                                              create a list of 10 high scores and player initials
    hiscore(1).score = 100
    hiscore(2).initials = "GAL" '                                              Galleon!
    hiscore(2).score = 90
    hiscore(3).initials = "UNS" '                                              Unseen Machine!
    hiscore(3).score = 80
    hiscore(4).initials = "CLY" '                                              Clippy!
    hiscore(4).score = 70
    hiscore(5).initials = "DWH" '                                              DarthWho!
    hiscore(5).score = 60
    hiscore(6).initials = "CYP" '                                              Cyperium!
    hiscore(6).score = 50
    hiscore(7).initials = "PET" '                                              Pete!
    hiscore(7).score = 40
    hiscore(8).initials = "ZMB" '                                              Zom-B!
    hiscore(8).score = 30
    hiscore(9).initials = "MRW" '                                              MrWhy!
    hiscore(9).score = 20
    hiscore(10).initials = "DAV" '                                             Dave!
    hiscore(10).score = 10
    SaveHiScores '                                                             save the high scores to the high score file
END IF

END SUB

'##################################################################################################################################

SUB UpdateCollisions ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Handles all collisions between objects currently located on screen.                                                            |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED round%(), sround%(), ship%, saucer%, saucerflying%, score&, explode&()
SHARED ssound&, intro%, shipsremaining%, playerdead%, rocksleft%

DIM count% '                                                                   generic counter
DIM bcount% '                                                                  generic counter
DIM hit% '                                                                     contains sprite number of objects that collide

FOR count% = 1 TO 5 '                                                          cycle through all 5 player bullets
    IF SPRITESCORE(round%(count%)) > 0 THEN '                                  is this bullet active?
        IF SPRITECOLLIDE(round%(count%), ALLSPRITES) THEN '                    yes, has the bullet collided with something?
            hit% = SPRITECOLLIDEWITH(round%(count%)) '                         yes, get the sprite that it collided with
            FOR bcount% = 1 TO 5 '                                             cycle through all 5 possible player bullets
                IF hit% = round%(bcount%) THEN hit% = 0 '                      if bullet hit bullet then ignore
                IF bcount% < 4 THEN '                                          is the bullet counter less than 4?
                    IF hit% = sround%(bcount%) THEN hit% = 0 '                 yes, if bullet hit saucer bullet then ignore
                END IF
            NEXT bcount%
            IF hit% = ship% THEN hit% = 0 '                                    if the bullet hit ship then ignore
            IF hit% <> 0 THEN '                                                ignore hits with a value of 0
                IF NOT intro% THEN score& = score& + SPRITESCORE(hit%) '       add the sprite's score to the player's score
                IF NOT intro% THEN _SNDPLAY explode&(INT(RND(1) * 3) + 1) '    play a random explosion sound
                SELECT CASE SPRITESCORE(hit%) '                                what was it that the bullet hit?
                    CASE 20 '                                                  it was a large rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '     generate two medium size rocks where large rock is
                    CASE 50 '                                                  it was a medium sized rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '     generate two small rocks where medium rock is
                    CASE 100 '                                                 it was a small rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        rocksleft% = rocksleft% - 1 '                          keep track of how many small rocks left in level
                    CASE 200 '                                                 it was a large flying saucer (I want to believe)
                        SPRITEMOTION hit%, DONTMOVE '                          turn automotion off for the saucer
                        saucerflying% = FALSE '                                tell the program a saucer is no longer flying
                        IF _SNDPLAYING(ssound&) THEN _SNDSTOP ssound& '        if the saucer sound is playing turn it off
                    CASE 1000 '                                                it was a small flying saucer
                        SPRITEMOTION hit%, DONTMOVE '                          turn automotion off for the saucer
                        saucerflying% = FALSE '                                tell the program a saucer is no longer flying
                        IF _SNDPLAYING(ssound&) THEN _SNDSTOP ssound& '        if the saucer sound is playing turn it off
                END SELECT
                SPRITEPUT -500, -500, hit% '                                   move the object that was hit off screen
                MakeSparks SPRITEX(round%(count%)), SPRITEY(round%(count%)) '  make explosion sparks where bullet hit object
                SPRITESCORESET round%(count%), 1 '                             set to 1 so the next countdown turns bullet off
            END IF
        END IF
        SPRITESCORESET round%(count%), SPRITESCORE(round%(count%)) - 1 '       decrement the bullet countdown timer
        IF SPRITESCORE(round%(count%)) = 0 THEN '                              has the bullet traveled its full course?
            SPRITEMOTION round%(count%), DONTMOVE '                            yes, turn automotion off for bullet
            SPRITEPUT -500, -500, round%(count%) '                             move the bullet off screen for later use
        END IF
    END IF
NEXT count%
FOR count% = 1 TO 3 '                                                          cycle through all 3 saucer bullets
    IF SPRITESCORE(sround%(count%)) > 0 THEN '                                 is this saucer bullet active?
        IF SPRITECOLLIDE(sround%(count%), ALLSPRITES) THEN '                   yes, has the saucer bullet collided with something?
            hit% = SPRITECOLLIDEWITH(sround%(count%)) '                        yes, get the sprite that it collided with
            FOR bcount% = 1 TO 5 '                                             cycle through all 5 possible player bullets
                IF hit% = round%(bcount%) THEN hit% = 0 '                      if saucer bullet hit bullet then treat as though it hit nothing
                IF bcount% < 4 THEN '                                          is the bullet counter less than 4?
                    IF hit% = sround%(bcount%) THEN hit% = 0 '                 if saucer bullet hit saucer bullet then ignore
                END IF
            NEXT bcount%
            IF hit% = saucer% THEN hit% = 0 '                                  ignore saucer bullets hitting self
            IF hit% <> 0 THEN '                                                did the saucer bullet hit something?
                IF NOT intro% THEN _SNDPLAY explode&(INT(RND(1) * 3) + 1) '    yes, play a random explosion sound
                SELECT CASE SPRITESCORE(hit%) '                                what was it that the saucer bullet hit?
                    CASE 20 '                                                  it was a large rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '     generate two medium size rocks where large rock is
                    CASE 50 '                                                  it was a medium sized rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '     generate two small rocks where medium rock is
                    CASE 100 '                                                 it was a small rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        rocksleft% = rocksleft% - 1 '                          keep track of how many small rocks left in level
                    CASE 5 '                                                   it hit the player's ship
                        IF NOT playerdead% THEN '                              is the player already dead? (keep from multiple saucer hits)
                            shipsremaining% = shipsremaining% - 1 '            no, decrement the amount of ships player has left
                            playerdead% = TRUE '                               tell the program the player is dead
                        END IF
                END SELECT
                IF SPRITESCORE(hit%) <> 5 THEN SPRITEPUT -500, -500, hit% '    move all hit objects except for player's ship off screen
                MakeSparks SPRITEX(sround%(count%)), SPRITEY(sround%(count%)) 'make explosion sparks where saucer bullet hit object
                SPRITESCORESET sround%(count%), 1 '                            set to 1 so the next countdown turns saucer bullet off
            END IF
        END IF
        SPRITESCORESET sround%(count%), SPRITESCORE(sround%(count%)) - 1 '     decrement the saucer bullet countdown timer
        IF SPRITESCORE(sround%(count%)) = 0 THEN '                             has the saucer bullet run its course?
            SPRITEMOTION sround%(count%), DONTMOVE '                           yes, turn automotion off for saucer bullet
            SPRITEPUT -500, -500, sround%(count%) '                            move the saucer bullet off screen for later use
        END IF
    END IF
NEXT count%
IF saucerflying% THEN '                                                        is a saucer currently on screen?
    IF SPRITECOLLIDE(saucer%, ALLSPRITES) THEN '                               has the saucer collided with something?
        hit% = SPRITECOLLIDEWITH(saucer%) '                                    yes, get the sprite that the saucer collided with
        FOR count% = 1 TO 3 '                                                  cycle through all three saucer bullets
            IF SPRITESCORE(sround%(count%)) > 0 THEN '                         is this saucer bullet on screen?
                IF hit% = sround%(count%) THEN hit% = 0 '                      yes, ignore saucer bullet hits with saucer
            END IF
        NEXT count%
        IF hit% <> 0 THEN '                                                    did the saucer collide with something?
            IF NOT intro% THEN score& = score& + SPRITESCORE(saucer%) '        yes, add the saucer's score to the player's score
            IF NOT intro% THEN _SNDPLAY explode&(INT(RND(1) * 3) + 1) '        play a random explosion sound
            SELECT CASE SPRITESCORE(hit%) '                                    what did the saucer hit?
                CASE 20 '                                                      it was a large rock
                    SPRITEMOTION hit%, DONTMOVE '                              turn the rock's automotion off
                    SPRITESCORESET hit%, 0 '                                   set the rock's score value to 0
                    GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '         generate two medium size rocks where large rock is
                CASE 50 '                                                      it was a medium sized rock
                    SPRITEMOTION hit%, DONTMOVE '                              turn the rock's automotion off
                    SPRITESCORESET hit%, 0 '                                   set the rock's score value to 0
                    GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '         generate two small rocks where medium rock is
                CASE 100 '                                                     it was a small rock
                    SPRITEMOTION hit%, DONTMOVE '                              turn the rock's automotion off
                    SPRITESCORESET hit%, 0 '                                   set the rock's score value to 0
                    rocksleft% = rocksleft% - 1 '                              keep track of how many small rocks left in level
                CASE 5 '                                                       it was the player's ship
                    IF NOT playerdead% THEN '                                  is the player already dead? (keep saucer from hitting player explosion sequence)
                        shipsremaining% = shipsremaining% - 1 '                no, decrement the amount of ships player has left
                        playerdead% = TRUE '                                   tell the program the player is dead
                    END IF
            END SELECT
            IF SPRITESCORE(hit%) <> 5 THEN SPRITEPUT -500, -500, hit% '        move all hit objects except for player's ship off screen
            SPRITEMOTION saucer%, DONTMOVE '                                   turn the saucer's automotion off
            saucerflying% = FALSE '                                            tell the program a saucer in no longer on screen
            IF _SNDPLAYING(ssound&) THEN _SNDSTOP ssound& '                    turn off the saucer sound
            MakeSparks SPRITEX(saucer%), SPRITEY(saucer%) '                    make explosion sparks where saucer hit object
            SPRITEPUT -500, -500, saucer% '                                    move the saucer off screen for later use
        END IF
    END IF
END IF
IF NOT intro% THEN
    IF NOT playerdead% THEN '                                                  is the player still alive and kicking?
        IF SPRITECOLLIDE(ship%, ALLSPRITES) THEN '                             yes, has the ship collided with anything?
            hit% = SPRITECOLLIDEWITH(ship%) '                                  yes, get the sprite that the ship collided with
            FOR bcount% = 1 TO 5 '                                             cycle through all 5 possible player bullets
                IF hit% = round%(bcount%) THEN hit% = 0 '                      ignore collisions between player bullet and ship
            NEXT bcount%
            IF hit% <> 0 THEN '                                                did the ship collide with something?
                score& = score& + SPRITESCORE(hit%) '                          yes, add the object's score to the player's score
                IF NOT intro% THEN _SNDPLAY explode&(INT(RND(1) * 3) + 1) '    play a random explosion sound
                SELECT CASE SPRITESCORE(hit%) '                                what did the ship hit?
                    CASE 20 '                                                  it was a large rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '     generate two medium size rocks where large rock is
                    CASE 50 '                                                  it was a medium sized rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '     generate two small rocks where medium rock is
                    CASE 100 '                                                 it was a small rock
                        SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                        rocksleft% = rocksleft% - 1 '                          keep track of how many small rocks left in level
                END SELECT
                SPRITEPUT -500, -500, hit% '                                   move object that was hit off screen
                MakeSparks SPRITEX(ship%), SPRITEY(ship%) '                    make explosion sparks where ship hit object
                playerdead% = TRUE '                                           tell the program the player is dead
                shipsremaining% = shipsremaining% - 1 '                        decrement the amount of ships player has left
            END IF
        END IF
    END IF
END IF

END SUB

'##################################################################################################################################

SUB UpdatePlayerDeath ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| handles the intermediate time between a player death and respawn.                                                              |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED shipsremaining%, rocks%(), playerdead%, ship%, ssound&, deathfinished%

STATIC deathcount% '                                                           countdown timer used to control when player can respawn
STATIC setcount% '                                                             counter used to control when to tighten spawn box
STATIC distance% '                                                             the minimum distance a rock must be from spawn box
STATIC animcount% '                                                            animation counter used to control ship explosion animation

DIM count% '                                                                   generic counter
DIM setplayer% '                                                               true when it's ok to respawn player

IF distance% = 0 THEN distance% = 150 '                                        set minimum distance from rocks to respawn
IF deathcount% = 0 THEN deathcount% = 64 '                                     wait at least 2 seconds to respawn
animcount% = animcount% + 1 '                                                  exploding ship animation counter
IF (animcount% \ 5 = animcount% / 5) AND (animcount% < 30) THEN '              have 5 framses passed?
    SPRITESET ship%, (animcount% \ 5) * 2 + 1 '                                yes, set the next explosion animation cell
END IF
IF animcount% < 30 THEN '                                                      still within explosion animation frames?
    SPRITEPUT SPRITEX(ship%), SPRITEY(ship%), ship% '                          yes, show the next animation cell
ELSE
    SPRITESET ship%, 1 '                                                       no, set ship back to normal sprite
    SPRITEPUT -500, -500, ship% '                                              put it off screen until later
    deathfinished% = TRUE
END IF
IF _SNDPLAYING(ssound&) THEN EXIT SUB '                                        wait until the saucer has left the screen
deathcount% = deathcount% - 1 '                                                decrement the 2 second wait counter
IF deathcount% = 0 THEN '                                                      have 2 seconds elapsed?
    deathcount% = 1 '                                                          yes, set to 1 in case we need to come back here
    setplayer% = TRUE '                                                        assume player's ship will be set this time around
    FOR count% = 1 TO UBOUND(rocks%) '                                         cycle through all the rocks
        IF SPRITESCORE(rocks%(count%)) > 0 THEN '                              is this rock on screen and far enough away?
            IF (ABS(SPRITEX(rocks%(count%)) - 512) < distance%) AND (ABS(SPRITEY(rocks%(count%)) - 384) < distance%) THEN setplayer% = FALSE
        END IF
    NEXT count%
    IF setplayer% = TRUE THEN '                                                are all rocks far enough away?
        playerdead% = FALSE '                                                  yes, the player is alive again
        SPRITEPUT 512, 384, ship% '                                            respawn ship
        deathcount% = 0 '                                                      reset the spawn delay timer
        distance% = 0 '                                                        reset the distance to 0 so it's set at max again
        animcount% = 0 '                                                       reset the explosion animation counter
    ELSE
        setcount% = setcount% + 1 '                                            rocks are too close! increment 1/2 second counter
        IF setcount% = 16 THEN '                                               have we tried at this distance for at least 1/2 sec?
            distance% = distance% - 1 '                                        yes, tighten the minimum distance required
            IF distance% < 70 THEN distance% = 70 '                            but not too close
            setcount% = 0 '                                                    reset the 1/2 second counter
        END IF
    END IF
END IF

END SUB

'##################################################################################################################################

SUB UpdateUfo ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Updates the position of any flying saucer that is currently on screen.                                                         |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED lsaucer%, bsaucer%, level%, bigsaucer&, littlesaucer&, intro%
SHARED saucerflying%, sround%(), ship%, saucer%, ssound&, pfire&, playerdead%
SHARED score&, explode&(), rocksleft%, shipsremaining%

STATIC saucerwait% '                                                           the amount of time to wait between saucer encounters
STATIC nextshot% '                                                             the amount of time to wait between saucer shots
STATIC changedir% '                                                            countdown timer used to control when saucer can change direction

DIM side% '                                                                    the side of the screen the saucer will appear at
DIM height% '                                                                  how high on the screen the saucer will appear
DIM angle! '                                                                   the angle at which the bullet will leave the saucer
DIM sdirection% '                                                              the saucer's current direction

IF shipsremaining% = 0 THEN '                                                  does the player have any ships left?
    IF _SNDPLAYING(ssound&) THEN _SNDSTOP ssound& '                            no, if a saucer is flying stop its flying sound
END IF
IF (saucerwait% = 0) AND (NOT saucerflying%) THEN '                            has enough time elapsed and no saucer currently onscreen?
    IF (INT(RND(1) * 250) = 125) AND (NOT playerdead%) THEN '                  yes, should a saucer appear if the player isn't dead?
        saucerflying% = TRUE '                                                 yes, let the program know a saucer is flying
        saucerwait% = 320 '                                                    time to wait after this saucer done (320 = 10 secs)
        saucer% = INT(RND(1) * level%) '                                       calculate how often each type of saucer should appear
        IF saucer% <= level% \ 3 THEN '                                        should a large saucer be produced?
            saucer% = bsaucer% '                                               yes, set to equal a big saucer
            ssound& = bigsaucer& '                                             set the sound to big saucer sound
            nextshot% = 32 '                                                   set time between shots to 1 sec (32fps)
            changedir% = 120 '                                                 amount of frames to travel before changing direction again
            SPRITESPEEDSET saucer%, 3 '                                        set the speed of the large saucer
        ELSE '                                                                 no, a small saucer should be produced
            saucer% = lsaucer% '                                               set to equal a small saucer
            ssound& = littlesaucer& '                                          set the sound to small saucer sound
            nextshot% = 24 '                                                   set time between shots to 3/4 sec (24fps)
            changedir% = 90 '                                                  amount of frames to travel before changing direction again
            SPRITESPEEDSET saucer%, 4 '                                        set the speed of the small saucer
        END IF
        side% = INT(RND(1) * 2) '                                              calculate a random side to appear from
        height% = INT(RND(1) * 6) '                                            calculate a random height to appear at
        SELECT CASE side% '                                                    which side should saucer appear from?
            CASE 0 '                                                           the left side
                SPRITEPUT -32, (height% * 128) + 26, saucer% '                 place saucer just off left of screen
                SPRITEDIRECTIONSET saucer%, 90 '                               set the saucer to travel at 90 degrees (right)
            CASE 1 '                                                           the right side
                SPRITEPUT 1056, (height% * 128) + 26, saucer% '                place saucer just off right of screen
                SPRITEDIRECTIONSET saucer%, 270 '                              set the saucer to travel at 270 degrees (left)
        END SELECT
        SPRITEMOTION saucer%, MOVE '                                           turn automotion on for the saucer
        IF NOT intro% THEN _SNDLOOP ssound& '                                  play the saucer sound if not in intro mode
    END IF
END IF
IF saucerflying% THEN '                                                        is the saucer currently flying?
    SPRITEPUT MOVE, MOVE, saucer% '                                            yes, automove the saucer
    changedir% = changedir% - 1 '                                              decrement the direction change counter
    IF changedir% = 0 THEN '                                                   is it time to see if a direction change is coming?
        IF saucer% = bsaucer% THEN '                                           yes, is this a big saucer?
            changedir% = 120 '                                                 yes, reset the direction change counter
        ELSE '                                                                 no, this is a little saucer
            changedir% = 90 '                                                  reset the direction change counter
        END IF
        IF INT(RND(1) * 2) = 1 THEN '                                          will the saucer randomly change direction now?
            sdirection% = SPRITEDIRECTION(saucer%) '                           yes, get the saucer's direction
            IF sdirection% = 270 THEN '                                        is the saucer heading left?
                IF INT(RND(1) * 2) = 0 THEN '                                  yes, should it randomly be changed by 45 degrees?
                    SPRITEDIRECTIONSET saucer%, 315 '                          yes, add 45 degrees to the saucer direction
                ELSE
                    SPRITEDIRECTIONSET saucer%, 225 '                          yes, subtract 45 degrees from the saucer direction
                END IF
            ELSEIF (sdirection% = 315) OR (sdirection% = 225) THEN '           is the saucer already heading left at a +/- 45 degrees?
                SPRITEDIRECTIONSET saucer%, 270 '                              yes, set the suacer direction back to 270
            ELSEIF sdirection% = 90 THEN '                                     is the saucer heading right?
                IF INT(RND(1) * 2) = 0 THEN '                                  yes, should it randmoly be changed by 45 degrees?
                    SPRITEDIRECTIONSET saucer%, 45 '                           yes, subtract 45 degrees from the saucer direction
                ELSE
                    SPRITEDIRECTIONSET saucer%, 135 '                          yes, add 45 degrees to the saucer direction
                END IF
            ELSEIF (sdirection% = 45) OR (sdirection% = 135) THEN '            is the saucer already heading right at a +/- 45 degrees?
                SPRITEDIRECTIONSET saucer%, 90 '                               yes, set the saucer direction back to 90 degrees
            END IF
        END IF
    END IF
    IF SPRITEY(saucer%) < 0 THEN '                                             has the saucer left the top of the screen?
        SPRITEMOTION saucer%, DONTMOVE '                                       yes, stop the saucer's automotion
        SPRITEPUT SPRITEX(saucer%), 767, saucer% '                             place the saucer at the bottom of screen
        SPRITEMOTION saucer%, MOVE '                                           turn the saucer's automotion back on
    END IF
    IF SPRITEY(saucer%) > 767 THEN '                                           has the saucer left the bottom of the screen?
        SPRITEMOTION saucer%, DONTMOVE '                                       yes, turn the saucer's automotion off
        SPRITEPUT SPRITEX(saucer%), 0, saucer% '                               place the saucer at the top of the screen
        SPRITEMOTION saucer%, MOVE '                                           turn the saucer's automotion back on
    END IF
    IF SPRITEX(saucer%) <= -32 OR SPRITEX(saucer%) >= 1056 THEN '              has the saucer left the right or left side of screen?
        saucerflying% = FALSE '                                                yes, tell the program that a saucer is no longer flying
        SPRITEMOTION saucer%, DONTMOVE '                                       turn automotion off for saucer
        SPRITEPUT -300, -300, saucer% '                                        place the saucer off screen for later use
        IF _SNDPLAYING(ssound&) THEN _SNDSTOP ssound& '                        if the saucer sound is playing stop it
    END IF
    IF NOT playerdead% THEN '                                                  is the player still alive?
        IF nextshot% = 0 THEN '                                                yes, is it time to shoot another bullet yet?
            FOR count% = 1 TO 3 '                                              yes, cycle through all 3 possible bullets
                IF SPRITESCORE(sround%(count%)) = 0 THEN '                     is  this bullet available for use?
                    IF NOT intro% THEN _SNDPLAY pfire& '                       yes, play the ship firing bullet sound if not in intro mode
                    SPRITESCORESET sround%(count%), 64 '                       set the countdown timer of the bullet to 2 seconds (64 frames)
                    SPRITEPUT SPRITEX(saucer%), SPRITEY(saucer%), sround%(count%) 'put the bullet onto the screen
                    SPRITESPEEDSET sround%(count%), 10 '                       set the speed of the bullet

                    IF NOT intro% THEN
                        IF saucer% = bsaucer% THEN '                           is the saucer flying a big saucer?
                            IF INT(RND(1) * (27 \ level%)) = 1 THEN '          yes, how accurate will the big saucer be on this shot?
                                angle! = SPRITEANGLE(saucer%, ship%) '         very accurate, aim right for player ship
                            ELSE '                                             not accurate at all
                                angle! = INT(RND(1) * 360) '                   fire bullet in a random direction
                            END IF
                            nextshot% = 32 '                                   wait 32 frames until next bullet
                        ELSE '                                                 no, this is a small saucer flying
                            angle! = SPRITEANGLE(saucer%, ship%) '             assume that the small saucer will be dead on accurate
                            IF INT(RND(1) * level% * 3) = 1 THEN '             should a little error be introduced in the shot?
                                angle! = angle! + RND(1) * 10 - RND(1) * 10 '  yes, introduce a +/- 10 degree error
                                IF angle! < 0 THEN angle! = angle! + 360 '     make sure angle stays in between 0 and 359.99.. degrees
                                IF angle! >= 360 THEN angle! = angle! - 360 '  make sure angle stays in between 0 and 359.99.. degrees
                            END IF
                            nextshot% = 24 '                                   wait 24 frames until next bullet
                        END IF
                    ELSE
                        angle! = INT(RND(1) * 360) '                           in intro mode just make shots have random angles
                        nextshot% = 32 '                                       both saucers will wait 32 frames before next bullet
                    END IF

                    SPRITEDIRECTIONSET sround%(count%), angle! '               set the angle of the bullet
                    SPRITEMOTION sround%(count%), MOVE '                       turn on automotion for the bullet
                    EXIT FOR '                                                 no need to cycle through the rest of the bullets
                END IF
            NEXT count%
        END IF
    END IF
    IF nextshot% > 0 THEN nextshot% = nextshot% - 1 '                          decrement the shot timer
END IF
IF (saucerwait% > 0) AND (NOT saucerflying%) THEN saucerwait% = saucerwait% - 1 'decrement the saucer wait timer

END SUB

'##################################################################################################################################

SUB IntroScreen ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Displays the intro screen goodies while waiting for the player to enter a coin and start game.                                 |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED intro%, shipsremaining%, level%, score&, beattimer!, playerdead%
SHARED rocksleft%, enter%, coin%, saucerflying%, saucer%, sround%()

STATIC firsttime% '                                                            keeps track of first time this sub is called

DIM count% '                                                                   generic counter

intro% = TRUE '                                                                let the program know its in intro mode
DO: LOOP UNTIL INKEY$ = "" '                                                   clear the keyboard buffer
playerdead% = FALSE '                                                          make the player alive to allow ufos to shoot
IF NOT firsttime% THEN '                                                       is this the first time this sub called?
    firsttime% = TRUE '                                                        yes, set flag so this part of code not entered again
    level% = 1 '                                                               set the game level to 1
    score& = 0 '                                                               set the player score to 0
    shipsremaining% = 3 '                                                      set the remaining ships to 3
    NewLevel '                                                                 set up a new asteroid field
END IF
DO '                                                                           start the intro loop here
    _LIMIT 32 '                                                                limit the intro to 32fps
    CLS '                                                                      clear the screen
    IF rocksleft% = 0 THEN NewLevel '                                          if ufos clear asteroids set up new asteroid field
    UpdateSparks '                                                             update any explosions currently on screen
    UpdateUfo '                                                                update the position of ufos
    UpdateRocks '                                                              update the positions of asteroids
    UpdateBullets '                                                            update any ufo bullets that are on screen
    UpdateCollisions '                                                         update any collisions that are happening
    UpdateScore '                                                              show the high score
    UpdateText '                                                               update the info text on screen
    _DISPLAY '                                                                 display the results of previous subs on screen
LOOP UNTIL enter% '                                                            keep looping until the player presses ENTER
IF saucerflying% THEN '                                                        is there a ufo currently on screen?
    SPRITEMOTION saucer%, DONTMOVE '                                           yes, stop it from moving
    SPRITEPUT -500, -500, saucer% '                                            put it off screen for later use
    saucerflying% = FALSE '                                                    tell the program no more ufos are on screen
END IF
FOR count% = 1 TO 3 '                                                          cycle through all 3 possible ufo bullets
    IF SPRITESCORE(sround%(count%)) > 0 THEN '                                 is this bullet on screen?
        SPRITEMOTION sround%(count%), DONTMOVE '                               yes, stop it from moving
        SPRITESCORESET sround%(count%), 0 '                                    set its value to 0 signifying it's dead
        SPRITEPUT -500, -500, sround%(count%) '                                put it off screen for later use
    END IF
NEXT count%
intro% = FALSE '                                                               let the program know its no longer in intro mode
enter% = FALSE '                                                               reset the enter key flag for next time
coin% = FALSE '                                                                reset the coin indicator for next time
CLS '                                                                          clear the screen
UpdateScore '                                                                  show the score and player ships
DrawText 367, 100, "PLAYER ONE" '                                              let player one know it's time
_DISPLAY '                                                                     display the results on screen of previous commands
_DELAY 2 '                                                                     pause for 2 seconds

END SUB

'##################################################################################################################################

SUB UpdateText ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Displays any relevant text on the screen while in intro mode.                                                                  |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED enter%, coin%, hiscore() AS TOPTEN, gameover%, score&, explode&()

STATIC flip% '                                                                 counter used to turn high scores on and off
STATIC flash% '                                                                used to flash "press enter"
STATIC overcount% '                                                            counter used to show "game over" for 3 seconds
STATIC esc% '                                                                  player escape key timer

DIM keypress$ '                                                                holds any key value the player may press
DIM count% '                                                                   generic counter

keypress$ = INKEY$ '                                                           get any key that the player may press
IF keypress$ = "1" THEN coin% = TRUE '                                         if the player pressed 1 then signify a coin drop
IF keypress$ = CHR$(13) AND coin% THEN '                                       did the player press ENTER after a coin dropped?
    enter% = TRUE '                                                            yes, let the program know the player pressed ENTER
    flip% = 0 '                                                                reset the high score flip counter
    flash% = 0 '                                                               reset the "press enter" flash counter
    EXIT SUB '                                                                 exit the subroutine to play the game
END IF
IF keypress$ = CHR$(27) THEN '                                                 did the player press the escape key?
    esc% = 1 '                                                                 yes, increment the escape counter
    flip% = 0 '                                                                reset high score flip
    coin% = FALSE '                                                            take the coin back
END IF
IF esc% > 0 AND esc% < 160 THEN '                                              has the escape counter been activated?
    esc% = esc% + 1 '                                                          yes, increment the escape counter
    _SNDPLAY explode&(INT(RND(1) * 3) + 1) '                                   play a random explosion sound for each frame
    MakeSparks INT(RND(1) * 1024), INT(RND(1) * 768) '                         make sparks at a random spot on screen
    DrawText 260, 350, "PROGRAMMED IN QB64" '                                  display credits for 5 seconds
    DrawText 260, 400, " BY TERRY RITCHIE" '                                   ""
    DrawText 260, 450, "   WWW QB64 NET" '                                     ""
    PSET (455, 465), _RGB(192, 192, 192) '                                     put the first dot in www.qb64.net
    PSET (595, 465), _RGB(192, 192, 192) '                                     put the second dot in www.qb64.net
END IF
IF esc% > 159 THEN '                                                           have 5 seconds gone by?
    esc% = esc% + 1 '                                                          yes, increment escape counter
    IF esc% = 224 THEN SYSTEM '                                                exit the game after 7 seconds
END IF
IF gameover% THEN '                                                            is the previous game over?
    DrawText 381, 400, "GAME OVER" '                                           yes, print "game over" on screen
    overcount% = overcount% + 1 '                                              increment the game over counter
    IF overcount% = 96 THEN '                                                  have 96 frames elapsed? (3 seconds)
        overcount% = 0 '                                                       yes, reset the counter for next game
        gameover% = FALSE '                                                    reset the game over flag for next game
        IF score& > hiscore(10).score THEN UpdateHiScores '                    player has achieved a high score, get info
    END IF
END IF
DrawText 325, 680, "1 COIN 1 PLAY" '                                           print instructions on the screen
DrawText 72, 740, "1 TO INSERT COIN OR ESC TO QUIT" '                          print more instructions on screen
IF flip% < 320 OR coin% THEN '                                                 should screen show no high scores or coin information?
    IF coin% THEN '                                                            yes, has a coin been dropped?
        DrawText 25, 250, "RIGHT AND LEFT ARROW KEYS TO TURN" '                yes, print game play instructions on screen
        DrawText 25, 300, "  UP ARROW KEY TO THRUST FORWARD" '                 ""
        DrawText 25, 350, "DOWN ARROW KEY TO ENTER HYPERSPACE" '               ""
        DrawText 25, 400, "     SPACEBAR TO FIRE BULLETS" '                    ""
        DrawText 25, 500, "   ALT ENTER TO GO FULL SCREEN" '                   ""
        IF flash% < 32 THEN '                                                  is it time to show "press enter"? (every other second)
            DrawText 367, 100, "PUSH ENTER" '                                  yes, print the message on screen
        END IF
        flash% = flash% + 1 '                                                  increment the "press enter" flash counter
        IF flash% = 64 THEN flash% = 0 '                                       if 64 frames have elapsed reset flash counter (2 seconds)
    END IF
ELSE '                                                                         the screen should show high scores now
    DrawText 367, 100, "HIGH SCORES" '                                         print the message to the screen
    FOR count% = 1 TO 10 '                                                     cycle through all high scores and print them to screen
        DrawText 325, 100 + (count% * 50), RIGHT$(" " + LTRIM$(STR$(count%)), 2) + "  " + RIGHT$("    " + LTRIM$(STR$(hiscore(count%).score)), 5) + " " + hiscore(count%).initials
        PSET (404, 113 + count% * 50), _RGB(128, 128, 128) '                   put the periods after the line numbers
    NEXT count%
END IF
flip% = flip% + 1 '                                                            increment the high score screen flip counter
IF flip% = 640 THEN flip% = 0 '                                                if 640 frames have passed reset counter (20 seconds)

END SUB

'##################################################################################################################################

SUB DrawText (x%, y%, text$)

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Draws the asteroids font text on the screen at the given location.                                                             |
'| x%, y% = the position on screen to draw the text.                                                                              |
'| text$  = the text message to display on the screen                                                                             |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED lfont%()

DIM count% '                                                                   generic counter
DIM nextx% '                                                                   the next text character location
DIM subtract% '                                                                calculate where on the sprite sheet to get character

nextx% = x% '                                                                  set variable to starting x location of text
FOR count% = 1 TO LEN(text$) '                                                 cycle through the text one character at a time
    IF MID$(text$, count%, 1) = " " THEN '                                     is this character a space?
        nextx% = nextx% + 28 '                                                 yes, move the x position to the right
    ELSE '                                                                     this character is not a space
        nextx% = nextx% + 28 '                                                 move to the next character position
        IF ASC(MID$(text$, count%, 1)) < 65 THEN subtract% = 48 ELSE subtract% = 55 'calculate where on sprite sheet character resides
        SPRITESTAMP nextx%, y%, lfont%(ASC(MID$(text$, count%, 1)) - subtract%) 'stamp the character onto the screen
    END IF
NEXT count%

END SUB

'##################################################################################################################################

SUB UpdateBullets ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Updates the positions of the player's and saucer's bullets on screen                                                           |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED round%(), ship%, score&, explode&(), rocksleft%, sround%(), intro%
SHARED saucer%, saucerflying%, ssound&, playerdead%, shipsremaining%

DIM count% '                                                                   generic counter
DIM bcount% '                                                                  generic counter used to detect bullet/bullet collision

FOR count% = 1 TO 5 '                                                          cycle through all 5 possible bullets on screen
    IF SPRITESCORE(round%(count%)) > 0 THEN '                                  if the bullet score is greater than 0 it's on screen
        SPRITEPUT MOVE, MOVE, round%(count%) '                                 automove the bullet to its next position
        IF SPRITEX(round%(count%)) < 0 THEN '                                  has the bullet left the left side of the screen?
            SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
            SPRITEPUT 1023, SPRITEY(round%(count%)), round%(count%) '          move bullet to right side of screen
            SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
        END IF
        IF SPRITEX(round%(count%)) > 1023 THEN '                               has the bullet left the right side of the screen?
            SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
            SPRITEPUT 0, SPRITEY(round%(count%)), round%(count%) '             move bullet to left side of screen
            SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
        END IF
        IF SPRITEY(round%(count%)) > 767 THEN '                                has the bullet left the bottom of the screen?
            SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
            SPRITEPUT SPRITEX(round%(count%)), 0, round%(count%) '             move bullet to top of screen
            SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
        END IF
        IF SPRITEY(round%(count%)) < 0 THEN '                                  has the bullet left the top of the screen?
            SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
            SPRITEPUT SPRITEX(round%(count%)), 767, round%(count%) '           move bullet to bottom of screen
            SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
        END IF
    END IF
    IF count% < 4 THEN '                                                       is count less than 4
        IF SPRITESCORE(sround%(count%)) > 0 THEN '                             yes, if the saucer bullet on screen?
            SPRITEPUT MOVE, MOVE, sround%(count%) '                            yes, automove the saucer bullet to its next position
            IF SPRITEX(sround%(count%)) < 0 THEN '                             has the saucer bullet left the left side of the screen?
                SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                SPRITEPUT 1023, SPRITEY(sround%(count%)), sround%(count%) '    move saucer bullet to right side of screen
                SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
            END IF
            IF SPRITEX(sround%(count%)) > 1023 THEN '                          has the saucer bullet left the right side of the screen?
                SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                SPRITEPUT 0, SPRITEY(sround%(count%)), sround%(count%) '       move saucer bullet to left side of screen
                SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
            END IF
            IF SPRITEY(sround%(count%)) > 767 THEN '                           has the saucer bullet left the bottom of the screen?
                SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                SPRITEPUT SPRITEX(sround%(count%)), 0, sround%(count%) '       move saucer bullet to the top of screen
                SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
            END IF
            IF SPRITEY(sround%(count%)) < 0 THEN '                             has the saucer bullet left the top of the screen?
                SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                SPRITEPUT SPRITEX(sround%(count%)), 767, sround%(count%) '     move suacer bullet to the bottom of screen
                SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
            END IF
        END IF
    END IF
NEXT count%

END SUB

'##################################################################################################################################

SUB UpdateScore ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Displays player's score, the high score and remaining ships on screen.                                                         |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED score&, hiscore&, lfont%(), sfont%(), shipsremaining%, intro%
SHARED extraship%, extralife&

DIM s$ '                                                                       the player's score in string format
DIM hs$ '                                                                      the high score in string format
DIM count% '                                                                   generic counter
DIM padding$ '                                                                 the type of padding needed before score and hiscore

STATIC shipawarded% '                                                          true when a player has been awarded ship
STATIC nextship& '                                                             score value to award next extra ship

IF nextship& = 0 THEN nextship& = 10000 '                                      set extra life value for first time
IF score& > hiscore& THEN hiscore& = score& '                                  if the score is greater than high score set high score
IF score& = 0 THEN padding$ = "   0" ELSE padding$ = "    " '                  original game shows two zeros if no high score file
s$ = RIGHT$(padding$ + LTRIM$(STR$(score&)), 5) '                              format the score string padding it with spaces
IF hiscore& = 0 THEN padding$ = "   0" ELSE padding$ = "    " '                original game shows to zeros if no high score file
hs$ = RIGHT$(padding$ + LTRIM$(STR$(hiscore&)), 5) '                           format the high score string padding it with spaces
FOR count% = 1 TO 5 '                                                          cycle through all 5 digits of score and high score
    IF MID$(s$, count%, 1) <> CHR$(32) THEN '                                  is this place in score string a space?
        SPRITESTAMP 25 + count% * 25, 25, lfont%(ASC(MID$(s$, count%, 1)) - 48) 'no, stamp an image of the number onto the screen
    END IF
    IF MID$(hs$, count%, 1) <> CHR$(32) THEN '                                 is this place in high score string a space?
        SPRITESTAMP 471 + count% * 11, 15, sfont%(ASC(MID$(hs$, count%, 1)) - 48) 'no, stamp an image of the number onto the screen
    END IF
NEXT count%
IF score& >= nextship& THEN '                                                  has the score for an extra ship been achieved?
    _SNDPLAY extralife& '                                                      yes, play the extra life sound
    shipsremaining% = shipsremaining% + 1 '                                    add a ship tot he player's remaining ships
    nextship& = nextship& + 10000 '                                            set the next extra ship value
END IF
IF NOT intro% THEN '                                                           is game in intro mode?
    FOR count% = 1 TO shipsremaining% '                                        no, cycle through the number of remaining player ships
        SPRITESTAMP 30 + count% * 30, 65, extraship% '                         stamp an image of the ship onto the screen
    NEXT count%
END IF

END SUB

'##################################################################################################################################

SUB UpdateSparks ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Moves the individual explosion sparks that are currently on screen.                                                            |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED sparks() AS SPARK

DIM count% '                                                                   generic counter
DIM fade1% '                                                                   fade level of vertical and horizontal from center
DIM fade2% '                                                                   fade level of 45 degree from center

FOR count% = 1 TO UBOUND(sparks) '                                                                                      cycle through the entire array
    IF sparks(count%).count > 0 THEN '                                                                                  is the countdown timer still active?
        fade1% = sparks(count%).fade / 2 '                                                                              yes, compute first fade level
        fade2% = sparks(count%).fade / 4 '                                                                              compute second fade level
        PSET (sparks(count%).x, sparks(count%).y), _RGB(sparks(count%).fade, sparks(count%).fade, sparks(count%).fade) 'set center pixel with full intensity
        PSET (sparks(count%).x + 1, sparks(count%).y), _RGB(fade1%, fade1%, fade1%) '                                   set right horizontal pixel 1/2 intensity
        PSET (sparks(count%).x - 1, sparks(count%).y), _RGB(fade1%, fade1%, fade1%) '                                   set left horizontal pixel 1/2 intensity
        PSET (sparks(count%).x, sparks(count%).y + 1), _RGB(fade1%, fade1%, fade1%) '                                   set lower vertical pixel 1/2 intensity
        PSET (sparks(count%).x, sparks(count%).y - 1), _RGB(fade1%, fade1%, fade1%) '                                   set upper vertical pixel 1/2 intensity
        PSET (sparks(count%).x + 1, sparks(count%).y + 1), _RGB(fade2%, fade2%, fade2%) '                               set lower right pixel 1/4 intensity
        PSET (sparks(count%).x - 1, sparks(count%).y - 1), _RGB(fade2%, fade2%, fade2%) '                               set upper left pixel 1/4 intensity
        PSET (sparks(count%).x - 1, sparks(count%).y + 1), _RGB(fade2%, fade2%, fade2%) '                               set lower left pixel 1/4 intensity
        PSET (sparks(count%).x + 1, sparks(count%).y - 1), _RGB(fade2%, fade2%, fade2%) '                               set upper right pixel 1/4 intensity
        sparks(count%).fade = sparks(count%).fade - 8 '                                                                 decrease intensity amount
        sparks(count%).x = sparks(count%).x + sparks(count%).xdir * sparks(count%).speed '                              compute new x location based on direction and speed
        sparks(count%).y = sparks(count%).y + sparks(count%).ydir * sparks(count%).speed '                              compute new y location based on direction and speed
        sparks(count%).speed = sparks(count%).speed / 1.1 '                                                             derease the speed of the spark
        sparks(count%).count = sparks(count%).count - 1 '                                                               decrement the countdown timer
    END IF
NEXT count%

END SUB

'##################################################################################################################################

SUB MakeSparks (x%, y%)

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Creates the explosion sparks when objects collide with one another in game.                                                    |
'| x%, y% = the location to originate the sparks from.                                                                            |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED sparks() AS SPARK

DIM cleanup% '                                                                 if true then array is redimmed to 0
DIM count% '                                                                   generic counter
DIM topspark% '                                                                the upper boundary of the spark array

cleanup% = TRUE '                                                              assume redimming of the array will occur
FOR count% = 1 TO UBOUND(sparks) '                                             cycle through the contents of the entire array
    IF sparks(count%).count <> 0 THEN '                                        is the countdown timer for this spark at 0?
        cleanup% = FALSE '                                                     no, redimming of the array will not occur
        EXIT FOR '                                                             no reason to check the rest of the array
    END IF
NEXT count%
IF cleanup% THEN REDIM sparks(0) AS SPARK '                                    if cleanup is still true then redim the array
topspark% = UBOUND(sparks) '                                                   get the upper boundary of the array
REDIM _PRESERVE sparks(topspark% + 11) AS SPARK '                              add 10 more spark elements to the array
FOR count% = 1 TO 10 '                                                         cycle through 10 new spark elements
    sparks(topspark% + count%).count = 32 '                                    set the countdown timer to equal 1 second (32fps)
    sparks(topspark% + count%).x = x% '                                        set the start x point for the spark
    sparks(topspark% + count%).y = y% '                                        set the start y point for the spark
    sparks(topspark% + count%).fade = 255 '                                    set the initial intensity of the spark
    sparks(topspark% + count%).speed = INT(RND(1) * 6) + 6 '                   give the spark a random speed to travel at
    sparks(topspark% + count%).xdir = RND(1) - RND(1) '                        give the spark a random x vector to travel at
    sparks(topspark% + count%).ydir = RND(1) - RND(1) '                        give the spark a random y vector to travel at
NEXT count%

END SUB

'##################################################################################################################################

SUB UpdatePlayer

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Updates the player's ship position on screen.                                                                                  |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED ship%, thrust&, round%(), pfire&, playerdead%

SHARED sprite() AS SPRITE '                                                    allows the sprite library to be accesses directly

STATIC vx! '                                                                   x vector velocity of player ship
STATIC vy! '                                                                   y vector velocity of player ship
STATIC pulse% '                                                                controls the pulse rate of ship's rocket engine
STATIC nextshot% '                                                             controls the rate of fire
STATIC hyperwait% '                                                            control how often a player can hyperspace

DIM newrotation! '                                                             the new rotational heading ship will be heading in
DIM acceleration! '                                                            the acceleration rate of ship
DIM ax! '                                                                      current x acceleration velocity to add to ship
DIM ay! '                                                                      current y acceleration velocity to add to ship
DIM speed!

IF playerdead% THEN '                                                          is the player dead?
    vx! = 0 '                                                                  yes, set horizontal velocity to 0
    vy! = 0 '                                                                  set vertical velocity to 0
    IF _SNDPLAYING(thrust&) THEN _SNDSTOP (thrust&) '                          if the ship thrusting sound is playing turn it off
    EXIT SUB '                                                                 player is dead, nothing more to do
END IF
IF _KEYDOWN(32) THEN '                                                         is the player pressing the space bar?
    IF nextshot% = 0 THEN '                                                    yes, is it time to shoot another bullet yet?
        FOR count% = 1 TO 5 '                                                  yes, cycle through all 5 possible bullets
            IF SPRITESCORE(round%(count%)) = 0 THEN '                          is this bullet available for use?
                _SNDPLAY pfire& '                                              yes, play the ship firing bullet sound
                SPRITESCORESET round%(count%), 48 '                            set the countdown timer of the bullet to 1.5 seconds (48 frames)
                SPRITEPUT SPRITEX(ship%), SPRITEY(ship%), round%(count%) '     put the bullet onto the screen
                SPRITESPEEDSET round%(count%), 10 '                            set the speed of the bullet
                SPRITEDIRECTIONSET round%(count%), SPRITEROTATION(ship%) '     match the direction of the bullet to the ship's rotation
                sprite(round%(count%)).xdir = sprite(round%(count%)).xdir + vx! 'had to access the sprite library directly to add the velocity of
                sprite(round%(count%)).ydir = sprite(round%(count%)).ydir + vy! 'the ship to the velocity of the bullets. need to make commands to handle this.
                SPRITEMOTION round%(count%), MOVE '                            turn on automotion for the bullet
                nextshot% = 4 '                                                must wait at least 4 frames before another bullet can be fired
                EXIT FOR '                                                     no need to cycle through the rest of the bullets
            END IF
        NEXT count%
    END IF
END IF
IF nextshot% > 0 THEN nextshot% = nextshot% - 1
IF _KEYDOWN(19712) THEN '                                                      is the player pressing the right arrow key?
    newrotation! = SPRITEROTATION(ship%) + 11.25 '                             yes, add clockwise rotation to the ship
    IF newrotation! >= 360 THEN newrotation! = newrotation! - 360 '            keep rotation angle between 0 and 359.99.. degrees
    SPRITEROTATE ship%, newrotation! '                                         apply new rotational angle to ship
END IF
IF _KEYDOWN(19200) THEN '                                                      is the player pressing the left arrow key?
    newrotation! = SPRITEROTATION(ship%) - 11.25 '                             yes, add counter-clockwise rotation to the ship
    IF newrotation! < 0 THEN newrotation! = newrotation! + 360 '               keep rotation andgle between 0 and 359.99.. degrees
    SPRITEROTATE ship%, newrotation! '                                         apply new rotational angle to ship
END IF
IF _KEYDOWN(20480) THEN '                                                      is the player pressing the down arrow key?
    IF hyperwait% = 0 THEN '                                                   yes, has 10 seconds elapsed since the last hyperspace?
        SPRITEPUT INT(RND(1) * _WIDTH(_DEST)), INT(RND(1) * _HEIGHT(_DEST)), ship% 'yes, hyperspace ship to random spot on screen
        vy! = 0 '                                                              set vertical velocity to 0
        vx! = 0 '                                                              set horizontal velocity to 0
        hyperwait% = 320 '                                                     wait 320 frames until the next hyperspace (10 secs)
    END IF
END IF
IF hyperwait% > 0 THEN hyperwait% = hyperwait% - 1 '                           decrement the hyperspace wait timer
IF _KEYDOWN(18432) THEN ' Up arrow '                                           is the player pressing the up arrow key?
    IF NOT _SNDPLAYING(thrust&) THEN _SNDLOOP thrust& '                        play the thruster sound if not already playing
    acceleration! = .2 '                                                       this much acceleration will be applied to ship
    pulse% = pulse% + 1 '                                                      increase the thruster pulse counter
    IF pulse% = 2 THEN '                                                       does the pulse counter = 2?
        SPRITESET ship%, 2 '                                                   yes, change the sprite to the ship with rocket flame
    ELSEIF pulse% = 4 THEN '                                                   no, does the pulse counter = 4?
        SPRITESET ship%, 1 '                                                   yes, change the sprite to the ship without flame
        pulse% = 0 '                                                           reset the pulse counter
    END IF
ELSE
    _SNDSTOP thrust& '                                                         no, the player is not pressing the up arrow key
    acceleration! = 0 '                                                        no acceleration will be added to ship
    SPRITESET ship%, 1 '                                                       set the sprite to the ship without flame
    pulse% = 1 '                                                               set pulse count to 1 so flame shows on key press
END IF
IF acceleration! <> 0 THEN '                                                   is ship currently accelerating?
    ax! = acceleration! * SIN(SPRITEROTATION(ship%) * PI / 180) '              yes, compute velocity to add to x vector
    ay! = acceleration! * -COS(SPRITEROTATION(ship%) * PI / 180) '             compute velocity to add to y vector
    vx! = vx! + ax! '                                                          add x velocity to velocity already present
    vy! = vy! + ay! '                                                          add y velocity to velocity already present
    speed! = SQR(vx! * vx! + vy! * vy!) '                                      get the current speed of the ship (Yikes! this takes lots of horsepower! is there a better way?)
    IF speed! > 10 THEN '                                                      has it exceeded the maximum speed allowed?
        vx! = vx! * 10 / speed! '                                              yes, limit the x velocity vector to max speed
        vy! = vy! * 10 / speed! '                                              limit the y velocity vector to max speed
    END IF
ELSE
    vx! = vx! * .99 '                                                          add a little "space friction"
    vy! = vy! * .99 '                                                          we'll call it dark matter for those saying WTF?
END IF
SPRITEPUT SPRITEAX(ship%) + vx!, SPRITEAY(ship%) + vy!, ship% '                add velocity to actual x,y for small increments
IF SPRITEX(ship%) < 0 THEN '                                                   has ship crossed left boundary?
    SPRITEPUT _WIDTH(_DEST), SPRITEY(ship%), ship% '                           yes, move ship to the right of the screen
END IF
IF SPRITEX(ship%) > _WIDTH(_DEST) THEN '                                       has ship crossed right boundary?
    SPRITEPUT 0, SPRITEY(ship%), ship% '                                       yes, move ship to left of screen
END IF
IF SPRITEY(ship%) < 0 THEN '                                                   has ship crossed upper boundary?
    SPRITEPUT SPRITEX(ship%), _HEIGHT(_DEST), ship% '                          yes, move ship to bottom of screen
END IF
IF SPRITEY(ship%) > _HEIGHT(_DEST) THEN '                                      has ship crossed lower boundary?
    SPRITEPUT SPRITEX(ship%), 0, ship% '                                       yes, move ship to top of screen
END IF

END SUB

'##################################################################################################################################

SUB NewLevel ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Generates a new game screen based on the current game level.                                                                   |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED level%, ship%, rocksleft%, intro%

IF SPRITEAX(ship%) <= 0 AND SPRITEAY(ship%) <= 0 THEN '                        is the ship off screen?
    IF NOT intro% THEN '                                                       yes, is game in intro mode?
        SPRITEPUT 512, 384, ship% '                                            no, place ship for first time
    ELSE '                                                                     yes, game is in intro mode
        SPRITEPUT -300, -300, ship% '                                          hide ship during intro screen
    END IF
END IF
GenerateRocks 0, 0, level% + 3, 1 '                                            generate large rocks at beginning of level
rocksleft% = (level% + 3) * 4 '                                                total small rocks that will be generated in level

END SUB

'##################################################################################################################################

SUB UpdateRocks ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Updates the position of the asteroids on screen.                                                                               |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED rocks%(), beat&(), beattimer!, intro%

STATIC beatcount% '                                                            controls when to play jaws beat sound
STATIC beat% '                                                                 controls which jaws beat sound to play

FOR rockcount% = 1 TO UBOUND(rocks%) '                                         cycle through all the rocks that have been generated
    IF SPRITESCORE(rocks%(rockcount%)) <> 0 THEN '                             is this rock active and on screen?
        SPRITEPUT MOVE, MOVE, rocks%(rockcount%) '                             yes, automove the rock to its new location
        IF SPRITEX(rocks%(rockcount%)) < 0 THEN '                              has rock left the left side of screen?
            SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
            SPRITEPUT 1023, SPRITEY(rocks%(rockcount%)), rocks%(rockcount%) '  move the rock to the right side of screen
            SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
        END IF
        IF SPRITEX(rocks%(rockcount%)) > 1023 THEN '                           has rock left the right side of screen?
            SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
            SPRITEPUT 0, SPRITEY(rocks%(rockcount%)), rocks%(rockcount%) '     move the rock to the left side of screen
            SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
        END IF
        IF SPRITEY(rocks%(rockcount%)) < 0 THEN '                              has the rock left the upper portion of screen?
            SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
            SPRITEPUT SPRITEX(rocks%(rockcount%)), 767, rocks%(rockcount%) '   move the rock to the lower portion of screen
            SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
        END IF
        IF SPRITEY(rocks%(rockcount%)) > 767 THEN '                            has the rock left the lower portion of screen?
            SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
            SPRITEPUT SPRITEX(rocks%(rockcount%)), 0, rocks%(rockcount%) '     move the rock to the upper portion of screen
            SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
        END IF
    END IF
NEXT rockcount%
IF NOT intro% THEN '                                                           is this sub being called by the intro screen?
    IF beatcount% = 0 THEN '                                                   no, time to change beat sound?
        beatcount% = beattimer! '                                              yes, set beat count to equal beat timer
        beat% = 1 - beat% '                                                    flip/flop the current beat sound
        _SNDPLAY beat&(beat%) '                                                play the current beat sound
        beattimer! = beattimer! - .2 '                                         decrease the beat timer a little at a time
        IF beattimer! < 8 THEN beattimer! = 8 '                                never go less than 8 frames per beat
    ELSE
        beatcount% = beatcount% - 1 '                                          not time yet, decrement beat count
    END IF
END IF

END SUB

'##################################################################################################################################

SUB GenerateRocks (x%, y%, rocknum%, size%)

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Generates rocks at a given position on screen with a predetermined size.                                                       |
'| x%, y%   = the location on screen to generate the new rocks                                                                    |
'| rocknum% = the number of new rocks to generate                                                                                 |
'| size%    = the size of the new rocks (1 = 100%, 2 = 50%, 3 = 25%)                                                              |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED rocks%(), rock%(), ship%, level%

STATIC nextrock% '                                                             holds the next rock type to be chosen

DIM rockstart% '                                                               the top of the rock array
DIM rockcount% '                                                               generic counter
DIM rockspeed! '                                                               the calculated speed a new rock will travel at

IF (UBOUND(rocks%) > 0) AND (size% = 1) THEN '                                 is level 2 or greater starting?
    FOR rockcount% = UBOUND(rocks%) TO 1 STEP -1 '                             yes, cycle through entire rock array
        SPRITEFREE rocks%(rockcount%) '                                        free the sprite from memory
    NEXT rockcount%
    REDIM rocks%(0) '                                                          clear array for new level
END IF
rockstart% = UBOUND(rocks%) '                                                  the last element in the rock array
REDIM _PRESERVE rocks%(UBOUND(rocks%) + rocknum%) '                            add the desired number of new rocks to the array
FOR rockcount% = 1 TO rocknum% '                                               cycle through all the new rocks that need created
    nextrock% = nextrock% + 1 '                                                cycle through all three available types of rocks
    IF nextrock% = 4 THEN nextrock% = 1 '                                      rest rock type cycle timer if gone too high
    rocks%(rockstart% + rockcount%) = SPRITECOPY(rock%(size%, nextrock%)) '    copy the chosen rock sprite
    IF size% = 1 THEN ' random spots on new level '                            are the new rocks being created large?
        DO '                                                                   yes, this is the start of a new level
            x% = INT(RND(1) * 824) + 100 '                                     choose a random x location for rock
            y% = INT(RND(1) * 568) + 100 '                                     choose a random y location for rock
        LOOP UNTIL (ABS(SPRITEX(ship%) - x%) > 200) OR (ABS(SPRITEY(ship%) - y%) > 200) 'make sure it's not too close to ship
    END IF
    SPRITEPUT x%, y%, rocks%(rockstart% + rockcount%) '                        place the rock on the screen
    IF size% = 1 THEN rockspeed! = RND(1) * (level% / 3) + 1 '                 calculate the speed of big rocks based on level
    IF size% = 2 THEN rockspeed! = RND(1) * (level% / 2) + 1 '                 calculate the speed of medium rocks based on level
    IF size% = 3 THEN rockspeed! = RND(1) * level% + 1 '                       calculate the speed of small rocks based on level
    SPRITESPEEDSET rocks%(rockstart% + rockcount%), rockspeed! '               set the speed of the rock
    SPRITEDIRECTIONSET rocks%(rockstart% + rockcount%), INT(RND(1) * 360) '    create a random direction for the rock to move in
    'SPRITESPINSET rocks%(rockstart% + rockcount%), RND(1) * 2 - RND(1) * 2 '  put some spin on the rock
    SPRITEMOTION rocks%(rockstart% + rockcount%), MOVE '                       enable automotion for the rock sprite
    IF INT(RND(1) * 2) = 1 THEN SPRITEFLIP rocks%(rockstart% + rockcount%), INT(RND(1) * 3) + 1 'randomly flip rocks around
NEXT rockcount%

END SUB

'##################################################################################################################################

SUB LoadGraphics ()

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Loads the game's graphics into memory.                                                                                         |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED rocksheet128%, rocksheet64%, rocksheet32%, rock%(), lfont%(), sfont%()
SHARED lfontsheet%, sfontsheet%, roundsheet%, round%(), shipsheet%, ship%
SHARED extraship%, bsaucersheet%, lsaucersheet%
SHARED bsaucer%, lsaucer%, sround%()

DIM rock1%
DIM rock2%
DIM rock3%
DIM count%

rocksheet128% = SPRITESHEETLOAD("hrocks128.png", 128, 128, _RGB(0, 0, 0))
rocksheet64% = SPRITESHEETLOAD("hrocks64.png", 64, 64, _RGB(0, 0, 0))
rocksheet32% = SPRITESHEETLOAD("hrocks32.png", 32, 32, _RGB(0, 0, 0))
rock%(1, 1) = SPRITENEW(rocksheet128%, 1, DONTSAVE)
SPRITECOLLIDETYPE rock%(1, 1), PIXELDETECT
SPRITESCORESET rock%(1, 1), 20
rock%(1, 2) = SPRITENEW(rocksheet128%, 2, DONTSAVE)
SPRITECOLLIDETYPE rock%(1, 2), PIXELDETECT
SPRITESCORESET rock%(1, 2), 20
rock%(1, 3) = SPRITENEW(rocksheet128%, 3, DONTSAVE)
SPRITECOLLIDETYPE rock%(1, 3), PIXELDETECT
SPRITESCORESET rock%(1, 3), 20
rock%(2, 1) = SPRITENEW(rocksheet64%, 1, DONTSAVE)
SPRITECOLLIDETYPE rock%(2, 1), PIXELDETECT
SPRITESCORESET rock%(2, 1), 50
rock%(2, 2) = SPRITENEW(rocksheet64%, 2, DONTSAVE)
SPRITECOLLIDETYPE rock%(2, 2), PIXELDETECT
SPRITESCORESET rock%(2, 2), 50
rock%(2, 3) = SPRITENEW(rocksheet64%, 3, DONTSAVE)
SPRITECOLLIDETYPE rock%(2, 3), PIXELDETECT
SPRITESCORESET rock%(2, 3), 50
rock%(3, 1) = SPRITENEW(rocksheet32%, 1, DONTSAVE)
SPRITECOLLIDETYPE rock%(3, 1), PIXELDETECT
SPRITESCORESET rock%(3, 1), 100
rock%(3, 2) = SPRITENEW(rocksheet32%, 2, DONTSAVE)
SPRITECOLLIDETYPE rock%(3, 2), PIXELDETECT
SPRITESCORESET rock%(3, 2), 100
rock%(3, 3) = SPRITENEW(rocksheet32%, 3, DONTSAVE)
SPRITECOLLIDETYPE rock%(3, 3), PIXELDETECT
SPRITESCORESET rock%(3, 3), 100
lfontsheet% = SPRITESHEETLOAD("lfont19x29.png", 19, 29, _RGB(0, 0, 0))
sfontsheet% = SPRITESHEETLOAD("ssfont9x15.png", 9, 15, _RGB(0, 0, 0))
FOR count% = 0 TO 35
    lfont%(count%) = SPRITENEW(lfontsheet%, count% + 1, DONTSAVE)
NEXT count%
FOR count% = 0 TO 9
    sfont%(count%) = SPRITENEW(sfontsheet%, count% + 1, DONTSAVE)
NEXT count%
roundsheet% = SPRITESHEETLOAD("rounds11.png", 11, 11, NOTRANSPARENCY)
FOR count% = 1 TO 5
    round%(count%) = SPRITENEW(roundsheet%, 1, DONTSAVE)
    SPRITECOLLIDETYPE round%(count%), PIXELDETECT
    SPRITEANIMATESET round%(count%), 1, 3
    SPRITEANIMATION round%(count%), ANIMATE, FORWARDLOOP
NEXT count%
FOR count% = 1 TO 3
    sround%(count%) = SPRITENEW(roundsheet%, 1, DONTSAVE)
    SPRITECOLLIDETYPE sround%(count%), PIXELDETECT
    SPRITEANIMATESET sround%(count%), 1, 3
    SPRITEANIMATION sround%(count%), ANIMATE, FORWARDLOOP
NEXT count%
shipsheet% = SPRITESHEETLOAD("ships41.png", 41, 41, _RGB(0, 0, 0))
ship% = SPRITENEW(shipsheet%, 1, DONTSAVE)
SPRITESCORESET ship%, 5
SPRITECOLLIDETYPE ship%, PIXELDETECT
extraship% = SPRITENEW(shipsheet%, 8, DONTSAVE)
bsaucersheet% = SPRITESHEETLOAD("lsaucer51x33.png", 51, 33, _RGB(0, 0, 0))
bsaucer% = SPRITENEW(bsaucersheet%, 1, DONTSAVE)
SPRITECOLLIDETYPE bsaucer%, PIXELDETECT
SPRITESCORESET bsaucer%, 200
lsaucersheet% = SPRITESHEETLOAD("ssaucer25x16.png", 25, 16, _RGB(0, 0, 0))
lsaucer% = SPRITENEW(lsaucersheet%, 1, DONTSAVE)
SPRITECOLLIDETYPE lsaucer%, PIXELDETECT
SPRITESCORESET lsaucer%, 1000

END SUB

'##################################################################################################################################

SUB LoadSounds

'+--------------------------------------------------------------------------------------------------------------------------------+
'| Loads the game's sounds into memory.                                                                                           |
'+--------------------------------------------------------------------------------------------------------------------------------+

SHARED thrust&, beat&(), pfire&, explode&(), extralife&, bigsaucer&
SHARED littlesaucer&

bigsaucer& = _SNDOPEN("lsaucer.ogg", "VOL, SYNC")
littlesaucer& = _SNDOPEN("ssaucer.ogg", "VOL, SYNC")
extralife& = _SNDOPEN("extraship.ogg", "VOL, SYNC")
explode&(1) = _SNDOPEN("aexplode1.ogg", "VOL, SYNC")
explode&(2) = _SNDOPEN("aexplode2.ogg", "VOL, SYNC")
explode&(3) = _SNDOPEN("aexplode3.ogg", "VOL, SYNC")
pfire& = _SNDOPEN("fire.ogg", "VOL, SYNC")
thrust& = _SNDOPEN("thrust.ogg", "VOL, SYNC")
beat&(0) = _SNDOPEN("thumplo.ogg", "VOL, SYNC")
beat&(1) = _SNDOPEN("thumphi.ogg", "VOL,SYNC")
_SNDVOL beat&(0), .25
_SNDVOL beat&(1), .25

END SUB

'##################################################################################################################################

'$INCLUDE:'sprite.bi'

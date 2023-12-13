'$INCLUDE:'spritetop.bi'

'+----------------------------------------------------------------------------+
'|                           QB64 Space Invaders!                             |
'|                                                                            |
'|                              Programmed by:                                |
'|                                                                            |
'|                              Terry Ritchie                                 |
'|                                                                            |
'|                         terry.ritchie@gmail.com                            |
'|                                                                            |
'| This game was written to be used as a test bed for my QB64 Sprite Library. |
'| QB64 Space Invaders! has been released as freeware to be used as a         |
'| QB64 Sprite Libary example. If you use any of the code from this game for  |
'| your own project(s) please give credit where credit is due (and email me a |
'| copy of the cool games you create!).                                       |
'|                                                                            |
'| A special thanks goes to Rob (Galleon), the creator of the QB64 language.  |
'|                                                                            |
'| You can download the QB64 language at: http://www.qb64.net                 |
'|                                                                            |
'| And a big thank you to the QB64 forum community for all their help during  |
'| the creation of the Sprite Library and this program. Thank guys!           |
'+----------------------------------------------------------------------------+

CONST FALSE = 0, TRUE = NOT FALSE

TYPE letters '           font container
    h AS INTEGER '       sprite H font image
    i AS INTEGER '       sprite I font image
    s AS INTEGER '       sprite S font image
    c AS INTEGER '       sprite C font image
    o AS INTEGER '       sprite O font image
    r AS INTEGER '       sprite R font image
    e AS INTEGER '       sprite E font image
    d AS INTEGER '       sprite D font image
    t AS INTEGER '       sprite T font image
    dash AS INTEGER '    sprite - font image
    lthan AS INTEGER '   sprite < font image
    gthan AS INTEGER '   sprite > font image
    one AS INTEGER '     sprite 1 font image
END TYPE

DIM letter AS letters '  GFX: container holding the font sprites
DIM invader%(5, 11) '    GFX: the space invaders (5 rows by 11 columns)
DIM remaining%(3) '      GFX: sprites of ships remaining
DIM scoredigit%(4) '     GFX: player score four digits
DIM hiscoredigit%(4) '   GFX: player hi-score four digits
DIM imissile%(10) '      GFX: 10 invader missiles
DIM remainingdigit% '    GFX: ships remaining digit
DIM background& '        GFX: the background image
DIM mainsheet% '         GFX: the sprite sheet that holds the enemies
DIM fontsheet% '         GFX: the sprite sheet that holds the font
DIM missilesheet% '      GFX: the sprite sheet that holds the missiles
DIM pmissile% '          GFX: the player's missile sprite
DIM player% '            GFX: the player's ship
DIM ufo% '               GFX: the ufo
DIM base1% '             GFX: top left quarter of base
DIM base2% '             GFX: bottom left quarter of base
DIM icon& '              GFX: windows icon image
DIM baseshields& '       GFX: copy of base shields
DIM beat&(4) '           SND: walking beat sounds
DIM playerhit& '         SND: player getting hit explosion sound
DIM invaderhit& '        SND: invader getting hit explosion sound
DIM fire& '              SND: player laser cannon firing sound
DIM ufomoving& '         SND: ufo moving scross the screen sound
DIM ufohit& '            SND: ufo getting hit funky sound
DIM level% '             current game level
DIM showufoscore% '      showscore after ufo hit?
DIM fps% '               frames per second game runs at (default = 128)
DIM score% '             player's score
DIM hiscore% '           game high score
DIM shipsremaining% '    number of ships player has remaining
DIM shieldsremain% '     does any part of the base shields remain
DIM invadersremaining% ' the number of invaders left in game

SCREEN _NEWIMAGE(800, 700, 32) '                                               800 by 700 screen in 32bit color
CLS '                                                                          get rid of alpha transparency
_SCREENMOVE _MIDDLE '                                                          move the image to the center of player's screen
icon& = _LOADIMAGE("siicon.bmp", 32) '                                         load the window icon image
_ICON icon& '                                                                  set the icon to the loaded image
_FREEIMAGE icon& '                                                             no longer need the icon image
_TITLE "QB64 Space Invaders!" '                                                set window title
RANDOMIZE TIMER '                                                              seed random number generator
fps% = 128 '                                                                   set to 128 frames per second (default)
level% = 0 '                                                                   reset the level counter
shipsremaining% = 3 '                                                          player starts with 3 ships
shieldsremain% = TRUE '                                                        set the shield flag
LoadGraphics '                                                                 load the game graphics
LoadSounds '                                                                   load the game sounds
DrawScreen '                                                                   draw the initial game screen
DO '                                                                           start the game loop here
    level% = level% + 1 '                                                      increment game level
    IF level% = 8 THEN level% = 7
    invadersremaining% = 55
    NewLevel '                                                                 draw the next level screen
    DO '                                                                       start the individual level loop here
        _LIMIT fps% '                                                          limit game to this many frames per second
        _PUTIMAGE (0, 36), background&
        IF shieldsremain% THEN _PUTIMAGE (80, 500), baseshields&
        UpdateInvaders '                                                       update the position of the invaders
        UpdateUfo '                                                            update the ufo status
        UpdatePlayerMissile '                                                  update the player missile status
        UpdatePlayer '                                                         update the player status
        UpdateInvaderMissiles '                                                update the invader missiles
        UpdateScore '                                                          update the score
        _DISPLAY '                                                             show all changes made to the screen
    LOOP UNTIL (invadersremaining% = 0) OR (shipsremaining% = 0) '             time to end level?
LOOP UNTIL shipsremaining% = 0 '                                               time to end the game?
SYSTEM '                                                                       yes, back the the OS

'##################################################################################################################################

SUB PlayerLostShip (ships%)

SHARED player%, imissile%(), ufomoving&, playerhit&, shipsremaining%

DIM count% '                                                                   generic counter
DIM remember% '                                                                remember if ufo moving sound was playing

FOR count% = 1 TO 10 '                                                         cycle through all 10 possible invader missiles
    SPRITESCORESET imissile%(count%), 0 '                                      turn any lingering ones off
    SPRITEPUT -40, 0, imissile%(count%) '                                      place them off the screen and out of the way for now
NEXT count%
SPRITESET player%, 10 '                                                        set the player's ship to the explosion image
SPRITEANIMATESET player%, 10, 11 '                                             set the explosion animation sequence
SPRITEANIMATION player%, ANIMATE, FORWARDLOOP '                                turn animation on for the player ship
IF _SNDPLAYING(ufomoving&) THEN '                                              is the ufo sound playing? (ufo in flight)
    remember% = TRUE '                                                         yes, remember that it was
    _SNDSTOP ufomoving& '                                                      stop the ufo moving sound
END IF
_SNDPLAY playerhit& '                                                          play the player ship explosion sound
FOR count% = 1 TO 60 '                                                         show the animation for 60 frames
    _LIMIT 20 '                                                                at 20 frames per second for total of 3 seconds
    SPRITEPUT SPRITEX(player%), SPRITEY(player%), player% '                    put player ship on screen for autoanimation
    _DISPLAY '                                                                 show the screen changes
NEXT count%
SPRITESET player%, 9 '                                                         set the player's ship back the standard image
SPRITEANIMATION player%, NOANIMATE, FORWARDLOOP '                              turn off animation for player's ship
shipsremaining% = shipsremaining% - ships% '                                   take player's ship(s) away
UpdatePlayerShips '                                                            show the result of taking away a ship on screen
IF remember% THEN _SNDLOOP (ufomoving&) '                                      if the ufo sound was playing turn it back on

END SUB

'##################################################################################################################################

SUB UpdateInvaderMissiles ()

SHARED imissile%(), player%, invader%(), level%, invadersremaining%, shieldsremain%

STATIC mcount%(11) '                                                           don't allow missiles to get too close in each column

DIM count% '                                                                   generic counter
DIM shieldhit% '                                                               true if missiles hit base shield
DIM count2% '                                                                  generic counter
DIM row% '                                                                     cycle through invader rows
DIM column% '                                                                  cycle through invader columns

FOR count% = 1 TO 10 '                                                         cycle through all 10 possible invader missiles
    IF SPRITESCORE(imissile%(count%)) = 1 THEN '                               is this missile flying, if so update its position
        SPRITEPUT SPRITEX(imissile%(count%)), SPRITEY(imissile%(count%)) + (level% \ 4) + 1, imissile%(count%) ' 1-3 slow, 4-7 fast
        IF SPRITECOLLIDE(imissile%(count%), player%) THEN '                    has this missile collided with the player?
            PlayerLostShip 1 '                                                  player has been hit and loses a ship
        END IF
        IF SPRITEY(imissile%(count%)) > 486 THEN '                             are we in base shield territory?
            IF shieldsremain% THEN '                                           yes, are there any base shields to worry about?
                shieldhit% = FALSE '                                           yes, assume this missile did not hit base shield
                FOR count2% = -1 TO 1 '                                        scan ahead of missile looking for the shield
                    IF POINT(SPRITEX(imissile%(count%)) + count2%, SPRITEY(imissile%(count%)) + 15) = _RGB(0, 255, 0) THEN
                        shieldhit% = TRUE '                                    shield was hit, remember this
                    END IF
                NEXT count2%
                IF shieldhit% THEN '                                           was the shield hit?
                    SPRITESCORESET imissile%(count%), 0 '                      yes, hide the invader missile
                    DamageShields SPRITEX(imissile%(count%)) - 8, SPRITEY(imissile%(count%)) + 32 'damage the shields in location where missile hit
                    SPRITEPUT -40, 0, imissile%(count%) '                      move missile off screen out of the way for now
                END IF
            END IF
        END IF
        IF SPRITEY(imissile%(count%)) > 620 THEN '                             did the missile hit the bottom of the screen?
            SPRITESCORESET imissile%(count%), 0 '                              yes, remove it from view
            SPRITEPUT -40, 0, imissile%(count%) '                              move missile off screen out of the way for now
        END IF
    ELSE
        IF INT(RND(1) * (invadersremaining% * (24 - level% * 2))) + 1 = 10 THEN 'should an invader randomly drop a missile now?
            column% = INT(RND(1) * 11) + 1 '                                   yes, pick a random column
            IF mcount%(column%) = 0 THEN '                                     is there another missile in this column that just left?
                FOR row% = 5 TO 1 STEP -1 '                                    no, start checking each row for an invader at bottom
                    IF SPRITESCORE(invader%(row%, column%)) <> 0 THEN '        is this invader still active?
                        IF level% > 3 THEN mcount%(column%) = 16 ELSE mcount%(column%) = 32 'yes, adjust missile closeness based on level
                        SPRITEPUT SPRITEX(invader%(row%, column%)), SPRITEY(invader%(row%, column%)), imissile%(count%) 'put missile on screen
                        SPRITESCORESET imissile%(count%), 1 '                  set that it's active and flying
                        EXIT FOR
                    END IF
                NEXT row%
            END IF
        END IF
    END IF
    IF mcount%(count%) > 0 THEN mcount%(count%) = mcount%(count%) - 1 '        decrement the column missile closeness counter
NEXT count%

END SUB

'##################################################################################################################################

SUB DamageShields (x%, y%)

SHARED baseshields&, background&

DIM dx% '                                                                      x damage location
DIM dy% '                                                                      y damage location

FOR dx% = 0 TO 4 '                                                             create a damage cell 20 pixels wide
    FOR dy% = 0 TO 8 '                                                         by 36 pixels high
        IF INT(RND(1) * 2) - 1 THEN '                                          randomly do damage to this 4x4 pixel square?
            _PUTIMAGE (x% - 80 + (dx% * 4), (y% - 536) + (dy% * 4))-(x% - 80 + (dx% * 4) + 3, (y% - 536) + (dy% * 4) + 3), background&, baseshields&, (x% + (dx% * 4), (y% - 72) + (dy% * 4))-(x% + (dx% * 4) + 3, (y% - 72) + (dy% * 4) + 3)
        END IF
    NEXT dy%
NEXT dx%

END SUB

'##################################################################################################################################

SUB UpdatePlayerShips ()

SHARED remainingdigit%, shipsremaining%, remaining%()

DIM count% '                                                                   generic counter

SPRITESET remainingdigit%, shipsremaining% + 1 '                               set the ship number digit to sprite digit
SPRITEPUT 16, 667, remainingdigit% '                                           place remaining ships number at bottom of screen
FOR count% = 1 TO 3 '                                                          cycle through all ship image placeholders
    IF shipsremaining% - 1 >= count% THEN '                                    should this ship be shown at bottom of screen?
        SPRITESHOW remaining%(count%) '                                        yes, show the ship
        SPRITEPUT count% * 64, 667, remaining%(count%) '                       place the ship on the screen
    ELSE
        SPRITEHIDE remaining%(count%) '                                        no, hide the ship
    END IF
NEXT count%

END SUB

'##################################################################################################################################

SUB UpdateScore ()

SHARED score%, hiscore%, scoredigit%(), hiscoredigit%(), ufohit&, shipsremaining%

STATIC shipawarded% '                                                          true if an extra ship has been awarded

DIM s$ '                                                                       string holding the player's score padded with zeros
DIM hs$ '                                                                      string holding the high score padded with zeros
DIM count% '                                                                   generic counter

s$ = RIGHT$("000" + LTRIM$(STR$(score%)), 4) '                                 pad the beginning of the score with zeros
IF score% > hiscore% THEN hiscore% = score% '                                  should the high score be updated?
FOR count% = 1 TO 4 '                                                          cycle through all four score and high score digits
    SPRITESET scoredigit%(count%), VAL(MID$(s$, count%, 1)) + 1 '              set the corresponding digit to the score digit
    SPRITEPUT 254 + count% * 24, 17, scoredigit%(count%) '                     place the digit on the screen
    IF hiscore% = score% THEN '                                                does the high score need to be updated as well?
        SPRITESET hiscoredigit%(count%), VAL(MID$(s$, count%, 1)) + 1 '        yes, set the corresponding digit to high score digit
        SPRITEPUT 638 + count% * 24, 17, hiscoredigit%(count%) '               place the high score digit on the screen
    END IF
NEXT count%
IF (score% >= 1500) AND (NOT shipawarded%) THEN '                              should the player be awarded with an extra ship?
    _SNDPLAY ufohit& '                                                         yes, play the extra ship sound
    shipawarded% = TRUE '                                                      set the flag indicating an extra ship was given
    shipsremaining% = shipsremaining% + 1 '                                    add to the pool of player ships remaining
    UpdatePlayerShips '                                                        update the player remaining ships on screen
END IF

END SUB

'##################################################################################################################################

SUB UpdatePlayerMissile ()

SHARED pmissile%, invaderhit&, showufoscore%, ufomoving&, ufohit&, ufo%, score%
SHARED player%, shieldsremain%, imissile%()

STATIC hit% '                                                                  remebers which invader was last hit
STATIC hittimer% '                                                             counts down time left to show invader explosion

DIM deadguy% '                                                                 the invader, missile or ufo that was hit
DIM shieldhit% '                                                               true if player missile hits base shield
DIM count% '                                                                   generic counter
DIM im% '                                                                      true if an invader missile was hit

IF hit% > 0 THEN '                                                             was an invader recently hit?
    hittimer% = hittimer% - 1 '                                                yes, decrement the explosion show counter
    IF hittimer% = 0 THEN '                                                    done showing the explosion?
        SPRITESCORESET hit%, 0 '                                               yes, set the invader not to be seen
        SPRITEPUT -40, 0, hit% '                                               put it off the screen out of the way
        hit% = 0 '                                                             reset recently hit invader for next one
    END IF
END IF
IF SPRITESCORE(pmissile%) = 1 THEN '                                           is the player's missile currently traveling?
    IF SPRITEY(pmissile%) = 50 THEN '                                          yes, has the missile reached the top of the screen?
        SPRITESCORESET pmissile%, 0 '                                          yes, hide the player's missile
    ELSE '                                                                     no, missile has not reached top of screen
        SPRITEPUT SPRITEX(pmissile%), SPRITEY(pmissile%) - 2, pmissile% '      move the misile and place it on the screen
        IF SPRITECOLLIDE(pmissile%, ALLSPRITES) THEN '                         has the player's missile collided with anything?
            deadguy% = SPRITECOLLIDEWITH(pmissile%) '                          yes, find out what it collided with
            IF deadguy% <> player% THEN '                                      make sure missile doesn't collide with player ship
                FOR count% = 1 TO 10 '                                         cycle through all 10 possible invader missiles
                    IF deadguy% = imissile%(count%) THEN '                     did the missile hit an invader missile?
                        im% = TRUE '                                           yes, remember this
                    END IF
                NEXT count%
                IF NOT im% THEN '                                              was an invader missile hit?
                    IF SPRITEY(deadguy%) = 52 THEN '                           no, was the object hit a ufo?
                        _SNDSTOP ufomoving& '                                  yes, stop the ufo moving sound
                        _SNDPLAY ufohit& '                                     play the ufo hit explosion sound
                        showufoscore% = TRUE '                                 set a flag to show the ufo's score for a brief time
                        SELECT CASE ABS(SPRITEX(ufo%) - SPRITEX(pmissile%)) \ 10 'how accurate was player's missile?
                            CASE 0 '                                           very close to center or dead center
                                SPRITESET ufo%, 16 '                           set the ufo image to 300
                                score% = score% + 300 '                        add 300 to the player's score
                            CASE 1 '                                           close to center
                                SPRITESET ufo%, 15 '                           set the ufo image to 200
                                score% = score% + 200 '                        add 200 to player's score
                            CASE IS > 1 '                                      on the outer edge
                                SPRITESET ufo%, 14 '                           set the ufo image to 100
                                score% = score% + 100 '                        add 100 to the player's score
                        END SELECT
                        SPRITEPUT SPRITEX(ufo%), SPRITEY(ufo%), ufo% '         display the point value image on the screen
                        SPRITESCORESET pmissile%, 0 '                          turn off the player's missile
                    ELSE '                                                     an invader was hit
                        _SNDPLAY invaderhit& '                                 play the invader hit explosion sound
                        SPRITESCORESET pmissile%, 0 '                          hide the player's missile
                        SPRITEANIMATION deadguy%, NOANIMATE, FORWARDLOOP '     turn off animation for the invader that was hit
                        SPRITESET deadguy%, 7 '                                set the invader to the explosion sprite
                        hit% = deadguy% '                                      remember that this invader was hit
                        hittimer% = 4 '                                        show explosion for four frames
                        score% = score% + SPRITESCORE(deadguy%) '              add the invader's score value to the player's score
                    END IF
                ELSE '                                                         an invader missile was hit
                    SPRITESCORESET pmissile%, 0 '                              invader's missile wins, turn off player's missile
                END IF
            END IF
        END IF
    END IF
    IF shieldsremain% THEN '                                                   are there any base shields left?
        IF SPRITEY(pmissile%) > 516 THEN '                                     yes, is missle in area of base shields?
            shieldhit% = FALSE '                                               assume shields have not been hit
            FOR count% = -1 TO 1 '                                             look ahead for shield pixels
                IF POINT(SPRITEX(pmissile%) + count%, SPRITEY(pmissile%) - 15) = _RGB(0, 255, 0) THEN shieldhit% = TRUE
            NEXT count%
            IF shieldhit% THEN '                                               did the player's missile hit the shields?
                SPRITESCORESET pmissile%, 0 '                                  yes, hide the player's missile
                DamageShields SPRITEX(pmissile%) - 8, SPRITEY(pmissile%) + 8 ' damage the shields in location where missile hit
            END IF
        END IF
    END IF
END IF

END SUB

'##################################################################################################################################

SUB UpdatePlayer ()

SHARED player%, pmissile%, fire&

STATIC speed% '                                                                used to control speed of player's ship

IF speed% = 0 THEN '                                                           is it ok to move player?
    speed% = 4 '                                                               yes, reset speed controller
    IF _KEYDOWN(19712) THEN '                                                  is player pressing the right arrow key?
        IF SPRITEX(player%) + 4 <= 740 THEN '                                  yes, is player at the right edge of the screen?
            SPRITEPUT SPRITEX(player%) + 4, SPRITEY(player%), player% '        no, move the player's ship to the right
        END IF
    END IF
    IF _KEYDOWN(19200) THEN '                                                  is player pressing the left arrow key?
        IF SPRITEX(player%) - 4 >= 56 THEN '                                   yes, is player at the left edge of the screen?
            SPRITEPUT SPRITEX(player%) - 4, SPRITEY(player%), player% '        no, move the player's ship to the left
        END IF
    END IF
ELSE
    speed% = speed% - 1 '                                                      no, decrement speed controller
END IF
IF _KEYDOWN(32) THEN '                                                         is the player pressing the space bar?
    IF SPRITESCORE(pmissile%) = 0 THEN '                                       yes, is the player's missile already traveling?
        _SNDPLAY fire& '                                                       no, play the laser firing sound
        SPRITEPUT SPRITEX(player%) - 1, SPRITEY(player%), pmissile% '          put the player's missile on the screen
        SPRITESCORESET pmissile%, 1 '                                          turn the missile on
    END IF
END IF
SPRITEPUT SPRITEX(player%), SPRITEY(player%), player% '                        put the player's ship on the screen

END SUB

'##################################################################################################################################

SUB UpdateInvaders ()

SHARED invader%(), beat&(), baseshields&, background&, fps%, pmissile%
SHARED shieldsremain%, invadersremaining%, imissile%(), shipsremaining%

STATIC beatsound% '                                                            keeps track of which beat sound to play next
STATIC direction% '                                                            keeps track of invader direction
STATIC walktimer% '                                                            keeps track of when it is ok for invaders to move
STATIC walktime! '                                                             holds amount of time to wait between invader moves

DIM highy% '                                                                   contains the y value of the lowest invader
DIM row% '                                                                     used to keep track of invader rows
DIM column% '                                                                  used to keep trak of invader columns
DIM addx% '                                                                    value invaders will move horizontally
DIM addy% '                                                                    value invaders will move vertically
DIM im%(10) '                                                                  generic counter
DIM count%

IF direction% = 0 THEN direction% = -4 '                                       set direction for first time
walktimer% = walktimer% + 1 '                                                  increment the walk timer
IF walktimer% >= walktime! THEN '                                              is it time for the invaders to move?
    invadersremaining% = 0 '                                                   reset the invader counter
    walktimer% = 0 '                                                           yes, reset the walk timer
    beatsound% = beatsound% + 1 '                                              go to the next marching beat sound
    IF beatsound% = 5 THEN beatsound% = 1 '                                    cycle back to first marching beat sound
    _SNDPLAY beat&(beatsound%) '                                               play the marching beat sound
    addx% = direction% '                                                       the amount of horizontal invader movement
    addy% = 0 '                                                                the amount of vertical invader movement
    FOR row% = 5 TO 1 STEP -1 '                                                cycle through each row of invaders
        FOR column% = 1 TO 11 '                                                cycle through each column of invaders in each row
            IF SPRITESCORE(invader%(row%, column%)) <> 0 THEN '                   is the invader still on the screen?
                invadersremaining% = invadersremaining% + 1 '                  count the number of invaders remaining for later use
                IF SPRITEY(invader%(row%, column%)) > highy% THEN '            yes, is it the lowest one seen so far?
                    highy% = SPRITEY(invader%(row%, column%)) '                yes, save its y location for later use
                END IF
                IF SPRITEX(invader%(row%, column%)) + direction% = 24 OR SPRITEX(invader%(row%, column%)) + direction% = 776 THEN ' will invader leave the screen?
                    addx% = 0 '                                                yes, stop invaders horizontal movement
                    addy% = 32 '                                               invaders must move down instead
                END IF
            END IF
        NEXT column%
    NEXT row%
    IF addy% = 32 THEN '                                                       are invaders going to drop down?
        direction% = -direction% '                                             tyes, after invaders move down they go in new direction
        IF highy% + addy% = 516 THEN '                                         will invader cover the top half of base shields?
            _PUTIMAGE (0, 0), background&, baseshields&, (80, 464)-(719, 495) 'yes, top half of base shields will get erased
        ELSEIF highy% + addy% = 548 THEN '                                     will invader cover all of the base shields?
            _PUTIMAGE (0, 0), background&, baseshields&, (80, 464)-(719, 528) 'yes, all of base shields will get erased
            shieldsremain% = FALSE '                                           shields completely gone
        END IF
    END IF
    walktime! = (invadersremaining% * (fps% / 55)) - (fps% / 55) '             calculate amount of time until next invader walk
    FOR row% = 1 TO 5 '                                                        cycle through each row of invaders
        FOR column% = 1 TO 11 '                                                cycle through each column of invaders in each row
            IF SPRITESCORE(invader%(row%, column%)) <> 0 THEN '                if the sprite is showing put it on the screen
                SPRITENEXT invader%(row%, column%) '                           go to the next animation cell
                SPRITEPUT SPRITEX(invader%(row%, column%)) + addx%, SPRITEY(invader%(row%, column%)) + addy%, invader%(row%, column%)
            END IF
        NEXT column%
    NEXT row%
ELSE
    FOR row% = 1 TO 5 '                                                        cycle through each row of invaders
        FOR column% = 1 TO 11 '                                                cycle through each column of invaders in each row
            IF SPRITESCORE(invader%(row%, column%)) <> 0 THEN '                if the sprite is showing put it on the screen
                SPRITEPUT SPRITEX(invader%(row%, column%)), SPRITEY(invader%(row%, column%)), invader%(row%, column%)
            END IF '                                                           used for non-animation frames
        NEXT column%
    NEXT row%
END IF
IF invadersremaining% = 0 THEN '                                               is the screen clear of invaders?
    walktimer% = 0 '                                                           yes, reset walk timer
    beatsound% = 0 '                                                           start the marching beat sound back from the beginning
    direction% = 0 '                                                           rest the invader direction
END IF
IF highy% = 612 THEN PlayerLostShip shipsremaining% '                          the invasion has begun! Lock up your wives and daughters!


END SUB

'##################################################################################################################################

SUB UpdateUfo ()

SHARED ufo%, ufomoving&, ufohit&, showufoscore%, fps%, pmissile%

STATIC scoretimer% '                                                           count down timer indicating how long score shows
STATIC speed% '                                                                speed controller for the ufo
STATIC ufotimer% '                                                             make sure that ufo shows up only once every 30 sec
STATIC ufoflying% '                                                            true if ufo flying across screen

IF ufotimer% = 0 THEN '                                                        has it been at leat 30 seconds or first time?
    IF (NOT showufoscore%) AND (NOT ufoflying%) THEN '                         yes, ufo not on screen and not showing score?
        IF INT(RND(1) * 1250) = 750 THEN '                                     should a ufo be created now?
            SPRITEPUT 832, 52, ufo% '                                          yes, place ufo just off the screen to the right
            _SNDLOOP ufomoving& '                                              start playing the ufo moving sound
            ufoflying% = TRUE '                                                the ufo is now flying across the screen
            scoretimer% = fps% '                                               set score timer to 1 sec in case the ufo gets hit
        END IF
    ELSEIF showufoscore% THEN '                                                is the ufo score currently being displayed?
        IF _SNDPLAYING(ufomoving&) THEN '                                      yes, is the ufo moving sound still playing?
            _SNDSTOP ufomoving& '                                              yes, stop the ufo moving sound
            _SNDPLAY ufohit& '                                                 play the ufo being hit sound
        END IF
        scoretimer% = scoretimer% - 1 '                                        decrement the show score timer
        IF scoretimer% = 0 THEN '                                              has the show score timer reached 0?
            showufoscore% = FALSE '                                            don't show the ufo's score any longer
            SPRITESET ufo%, 13 '                                               set the sprite back to the ufo image
            SPRITEPUT -40, 0, ufo% '                                           put ufo off screen out of the way
            ufotimer% = 30 * fps% '                                            wait at least 30 seconds until next ufo encounter
            ufoflying% = FALSE
        ELSE
            SPRITEPUT SPRITEX(ufo%), SPRITEY(ufo%), ufo% '                     display the ufo screen
        END IF
    ELSE '                                                                     ufo is currently on the screen moving
        speed% = 1 - speed% '                                                  flip/flop used to slow ufo to half player's speed
        IF speed% = 0 THEN '                                                   time to move?
            SPRITEPUT SPRITEX(ufo%) - 1, SPRITEY(ufo%), ufo% '                 yes, update ufo position on screen
            IF SPRITEX(ufo%) = -32 THEN '                                      has the ufo flown off the left side of screen?
                _SNDSTOP ufomoving& '                                          yes, stop the ufo moving sound
                ufoflying% = FALSE '                                           ufo is no longer flying across the screen
                ufotimer% = 30 * fps% '                                        wait at least 30 seconds until next ufo encounter
            END IF
        ELSE
            SPRITEPUT SPRITEX(ufo%), SPRITEY(ufo%), ufo% '                     show ufo on non animation frames
        END IF
    END IF
ELSE
    IF ufotimer% > 0 THEN ufotimer% = ufotimer% - 1 '                          decrement the count down timer
END IF

END SUB

'##################################################################################################################################

SUB NewLevel ()

SHARED background&, ufomoving&, baseshields&, level%, invader%(), beat&()
SHARED player%, ufo%, shieldsremain%, pmissile%, imissile%(), fps%

STATIC firsttime% '                                                            no 2 second delay at the start of the first level

DIM row% '                                                                     the current row of invaders being drawn
DIM column% '                                                                  the current invader being drawn in column
DIM x% '                                                                       the x location of each invader
DIM y% '                                                                       the y location of each invader

_PUTIMAGE (0, 36), background& '                                               place background image on screen
_PUTIMAGE (80, 500), baseshields& '                                            place base shields image on screen
FOR count% = 1 TO 10 '                                                         cycle through all 10 possible invader missiles
    SPRITESCORESET imissile%(count%), 0 '                                      turn any lingering ones off
    SPRITEPUT -40, 0, imissile%(count%) '                                      place them off the screen and out of the way for now
NEXT count%
IF ((level% - 1) * 32) + 356 = 516 THEN '                                      will invaders be generated over top of base shields?
    _PUTIMAGE (0, 0), background&, baseshields&, (80, 464)-(719, 495) '        yes, top half of base shields will get erased
ELSEIF ((level% - 1) * 32) + 356 = 548 THEN '                                  will invaders be genrated over all of base shields?
    _PUTIMAGE (0, 0), background&, baseshields&, (80, 464)-(719, 528) '        yes, all of base shields will get erased
    shieldsremain% = FALSE '                                                   shields completely gone
END IF
SPRITEPUT SPRITEX(player%), SPRITEY(player%), player% '                        put the player's ship on the screen
count% = fps% * 2 '                                                            calculate 2 seconds worth of frames
IF NOT firsttime% THEN '                                                       is this the first level being played?
    firsttime% = TRUE '                                                        yes, set flag
ELSE '                                                                         no, flag is already set, first level already played
    DO '                                                                       create a two second pause between levels
        _LIMIT fps% '                                                          limit loop to this many frames per second
        UpdateUfo '                                                            allow ufo to keep moving if on screen
        UpdatePlayer '                                                         allow player to keep moving ship
        UpdatePlayerMissile '                                                  allow player to fire a missile while waiting!
        count% = count% - 1 '                                                  decrement count down timer
        _DISPLAY '                                                             show each frame change to the screen
    LOOP UNTIL count% = 0 '                                                    begin playing next level after 2 seconds
END IF
FOR row% = 1 TO 5 '                                                            cycle through all 5 rows of invaders
    y% = ((level% - 1) * 32) + 100 + ((row% - 1) * 64) '                       calculate the y location of this row
    FOR column% = 1 TO 11 '                                                    cycle through all 11 columns of invaders
        _LIMIT fps%
        UpdateUfo '                                                            keep ufo moving between levels
        UpdatePlayer '                                                         allow player to move between levels
        x% = 80 + (column% - 1) * 64 '                                         calculate the x value of this invader
        SELECT CASE row% '                                                     which row is currently being generated?
            CASE 1 '                                                           top row
                SPRITESET invader%(row%, column%), 1 '                         set the invader image to top row image
                SPRITEANIMATESET invader%(row%, column%), 1, 2 '               set the animation cells associated with this invader
                SPRITESCORESET invader%(row%, column%), 30 '                   set the score value of this invader
            CASE 2 TO 3 '                                                      2nd & 3rd rows
                SPRITESET invader%(row%, column%), 3 '                         set the invader image to 2nd & 3rd row image
                SPRITEANIMATESET invader%(row%, column%), 3, 4 '               set the animation cells associated with this invader
                SPRITESCORESET invader%(row%, column%), 20 '                   set the score value of this invader
            CASE 4 TO 5 '                                                      4th & 5th rows
                SPRITESET invader%(row%, column%), 5 '                         set the invader image to 4th & 5th row image
                SPRITEANIMATESET invader%(row%, column%), 5, 6 '               set the animation cells associated with this invader
                SPRITESCORESET invader%(row%, column%), 10 '                   set the score value of this invader
        END SELECT
        _SNDPLAY beat&(4) '                                                    play a pulsating beat sound as invaders being drawn
        SPRITEPUT x%, y%, invader%(row%, column%) '                            draw the current invader to the screen
        _DISPLAY '                                                             show each invader being drawn
    NEXT column%
NEXT row%

END SUB

'##################################################################################################################################

SUB DrawScreen ()

SHARED remaining%(), scoredigit%(), hiscoredigit%(), background&
SHARED fontsheet%, remainingdigit%, player%, base1%, base2%, baseshields&
SHARED letter AS letters

DIM count% '                                                                   generic counter used in subroutine

_PUTIMAGE (0, 36), background& '                                               place background image on screen
LINE (0, 636)-(799, 639), _RGB(0, 254, 0), BF '                                draw green line toward bottom of screen
SPRITESTAMP 62, 17, letter.s '                                                 place letter S in word SCORE<1>
SPRITESTAMP 86, 17, letter.c '                                                 place letter C in word SCORE<1>
SPRITESTAMP 110, 17, letter.o '                                                place letter O in word SCORE<1>
SPRITESTAMP 134, 17, letter.r '         Top row letters centered on 17         place letter R in word SCORE<1>
SPRITESTAMP 158, 17, letter.e '                                                place letter E in word SCORE<1>
SPRITESTAMP 182, 17, letter.lthan '                                            place letter < in word SCORE<1>
SPRITESTAMP 206, 17, letter.one '                                              place letter 1 in word SCORE<1>
SPRITESTAMP 230, 17, letter.gthan '                                            place letter > in word SCORE<1>
SPRITESTAMP 446, 17, letter.h '                                                place letter H in word HI-SCORE
SPRITESTAMP 470, 17, letter.i '                                                place letter I in word HI-SCORE
SPRITESTAMP 494, 17, letter.dash '                                             place letter - in word HI-SCORE
SPRITESTAMP 518, 17, letter.s '                                                place letter S in word HI-SCORE
SPRITESTAMP 542, 17, letter.c '                                                place letter C in word HI-SCORE
SPRITESTAMP 566, 17, letter.o '                                                place letter O in word HI-SCORE
SPRITESTAMP 590, 17, letter.r '                                                place letter R in word HI-SCORE
SPRITESTAMP 614, 17, letter.e '                                                place letter E in word HI-SCORE
SPRITESTAMP 593, 667, letter.c '                                               place letter C in word CREDIT<1>
SPRITESTAMP 617, 667, letter.r '                                               place letter R in word CREDIT<1>
SPRITESTAMP 641, 667, letter.e '       bottom row letters centered on 667      place letter E in word CREDIT<1>
SPRITESTAMP 665, 667, letter.d '                                               place letter D in word CREDIT<1>
SPRITESTAMP 689, 667, letter.i '                                               place letter I in word CREDIT<1>
SPRITESTAMP 713, 667, letter.t '                                               place letter T in word CREDIT<1>
SPRITESTAMP 737, 667, letter.lthan '                                           place letter < in word CREDIT<1>
SPRITESTAMP 761, 667, letter.one '                                             place number 1 in word CREDIT<1>
SPRITESTAMP 785, 667, letter.gthan '                                           place letter > in word CREDIT<1>
SPRITEPUT 399, 620, player% '                                                  place player base ship on the screen
FOR count% = 1 TO 3
    SPRITEPUT count% * 64, 667, remaining%(count%) '                           place the remaining ships at bottom of the screen
NEXT count%
SPRITEHIDE remaining%(3) '                                                     hide the 3rd ship (extra ship) for now
SPRITEPUT 16, 667, remainingdigit% '                                           place remaining ships number at bottom of screen
FOR count% = 1 TO 4
    SPRITEPUT 254 + count% * 24, 17, scoredigit%(count%) '                     place the score digits at the top of screen
    SPRITEPUT 638 + count% * 24, 17, hiscoredigit%(count%) '                   place the high score digits at the top of screen
NEXT count%
SPRITESTAMP 100, 516, base1% '                                                 first base shield top left quarter
SPRITESTAMP 100, 548, base2% '                                                 first base shield bottom left quarter
SPRITESTAMP 280, 516, base1% '                                                 second base shield top left quarter
SPRITESTAMP 280, 548, base2% '                                                 second base shield bottom left quarter
SPRITESTAMP 456, 516, base1% '                                                 third base shield top left quarter
SPRITESTAMP 456, 548, base2% '                                                 third base shield bottom left quarter
SPRITESTAMP 636, 516, base1% '                                                 fourth base shield top left quarter
SPRITESTAMP 636, 548, base2% '                                                 fourth base shield bottom left quarter
SPRITEFLIP base1%, HORIZONTAL '                                                flip top half horizontally
SPRITEFLIP base2%, HORIZONTAL '                                                flip bottom half horizontally
SPRITESTAMP 164, 516, base1% '                                                 first base shield top right quarter
SPRITESTAMP 164, 548, base2% '                                                 first base shield bottom right quarter
SPRITESTAMP 344, 516, base1% '                                                 second base shield top right quarter
SPRITESTAMP 344, 548, base2% '                                                 second base shield bottom right quarter
SPRITESTAMP 520, 516, base1% '                                                 third base shield top right quarter
SPRITESTAMP 520, 548, base2% '                                                 third base shield bottom right quarter
SPRITESTAMP 700, 516, base1% '                                                 fourth base shield to right quarter
SPRITESTAMP 700, 548, base2% '                                                 fourth base shield bottom right quarter
_PUTIMAGE (0, 0), _DEST, baseshields&, (80, 500)-(719, 563) '                  place copy of shields in shield image holder

END SUB

'##################################################################################################################################

SUB LoadGraphics ()

SHARED letter AS letters, scoredigit%(), hiscoredigit%(), imissile%()
SHARED invader%(), remaining%(), background&, mainsheet%
SHARED missilesheet%, pmissile%, ufo%, player%, base1%, base2%, fontsheet%
SHARED remainingdigit%, baseshields&

DIM counter% '                                                                 generic counter used in subroutine
DIM invader1%, invader2%, invader3% '                                          temporary invader sprites used for copying
DIM row%, column% '                                                            used when creating the 55 invader sprites
DIM imissile1%, imissile2%, imissile3% '                                       temporary invader missile sprites used for copying

'*
'*                                                                             DEFINE STATIC IMAGES
'*
background& = _LOADIMAGE("invadersbackground.png", 32) '                       background image of planet and stars
baseshields& = _NEWIMAGE(640, 64, 32) '                                        image to hold copy of base shields
'*
'*                                                                             DEFINE ENEMY AND PLAYER SPRITES
'*
mainsheet% = SPRITESHEETLOAD("invaders64x32.png", 64, 32, _RGB(1, 1, 1)) '     main sprite sheet containing player and invaders
invader1% = SPRITENEW(mainsheet%, 1, DONTSAVE) '                               top row invader sprite
SPRITECOLLIDETYPE invader1%, PIXELDETECT '                                     this sprite uses pixel accurate collision detection
invader2% = SPRITENEW(mainsheet%, 3, DONTSAVE) '                               2nd & 3rd row invader sprite
SPRITECOLLIDETYPE invader2%, PIXELDETECT '                                     this sprite uses pixel accurate collision detection
invader3% = SPRITENEW(mainsheet%, 5, DONTSAVE) '                               4th & 5th row invader sprite
SPRITECOLLIDETYPE invader3%, PIXELDETECT '                                     this sprite uses pixel accurate collision detection
player% = SPRITENEW(mainsheet%, 9, SAVE) '                                     player base ship sprite
SPRITECOLLIDETYPE player%, PIXELDETECT '                                       this sprite uses pixel accurate collision detection
ufo% = SPRITENEW(mainsheet%, 13, SAVE) '                                       ufo sprite
SPRITECOLLIDETYPE ufo%, PIXELDETECT '                                          this sprite uses pixel accurate collision detection
SPRITESCORESET ufo%, 100 '                                                     this sprite is worth a minimum 100 points when hit
base1% = SPRITENEW(mainsheet%, 8, DONTSAVE) '                                  top left quarter of base shield
base2% = SPRITENEW(mainsheet%, 12, DONTSAVE) '                                 bottom left quarter of base shield
FOR count% = 0 TO 3 '                                                          create 3 player ships to show at bottom of screen
    remaining%(count%) = SPRITENEW(mainsheet%, 9, SAVE) ' allow hide/show '    remaining player base ships on bottom of screen
NEXT count%
FOR row% = 1 TO 5 '                                                            create a sprite array of 55 invader sprites
    FOR column% = 1 TO 11 '                                                    with each invader sprite in its correct row
        SELECT CASE row% '                                                     which row is being created?
            CASE 1 '                                                           top row
                invader%(row%, column%) = SPRITECOPY(invader1%) '              sprites 1 through 11
            CASE 2 TO 3 '                                                      2nd & 3rd rows
                invader%(row%, column%) = SPRITECOPY(invader2%) '              sprites 12 through 33
            CASE 4 TO 5 '                                                      4th & 5th rows
                invader%(row%, column%) = SPRITECOPY(invader3%) '              sprites 34 through 55
        END SELECT
    NEXT column%
NEXT row%
'*
'*                                                                             DEFINE FONT SPRITES
'*
fontsheet% = SPRITESHEETLOAD("invadersfont.png", 20, 28, _RGB(1, 1, 1)) '      sprite sheet containing fonts needed in game
letter.h = SPRITENEW(fontsheet%, 12, DONTSAVE) '                               font letter H
letter.i = SPRITENEW(fontsheet%, 13, DONTSAVE) '                               font letter I
letter.s = SPRITENEW(fontsheet%, 15, DONTSAVE) '                               font letter S
letter.c = SPRITENEW(fontsheet%, 16, DONTSAVE) '                               font letter C
letter.o = SPRITENEW(fontsheet%, 17, DONTSAVE) '                               font letter O
letter.r = SPRITENEW(fontsheet%, 18, DONTSAVE) '                               font letter R
letter.e = SPRITENEW(fontsheet%, 19, DONTSAVE) '                               font letter E
letter.d = SPRITENEW(fontsheet%, 20, DONTSAVE) '                               font letter D
letter.t = SPRITENEW(fontsheet%, 21, DONTSAVE) '                               font letter T
letter.dash = SPRITENEW(fontsheet%, 14, DONTSAVE) '                            font letter -
letter.lthan = SPRITENEW(fontsheet%, 11, DONTSAVE) '                           font letter <
letter.gthan = SPRITENEW(fontsheet%, 22, DONTSAVE) '                           font letter >
letter.one = SPRITENEW(fontsheet%, 2, DONTSAVE) '                              font letter 1
FOR count% = 1 TO 4 '                                                          create 4 digits for score and high score
    scoredigit%(count%) = SPRITENEW(fontsheet%, 1, SAVE) '                     score digits at the top of screen
    hiscoredigit%(count%) = SPRITENEW(fontsheet%, 1, SAVE) '                   high score digits at the top of screen
NEXT count%
remainingdigit% = SPRITENEW(fontsheet%, 4, SAVE) '                             digit showing ships remaining at bottom of screen
'*
'*                                                                             DEFINE MISSILE SPRITES
'*
missilesheet% = SPRITESHEETLOAD("invadersmissiles.png", 12, 28, _RGB(1, 1, 1)) 'sprite sheet containing various missiles
pmissile% = SPRITENEW(missilesheet%, 1, SAVE) '                            the player missile sprite (normal missile)
SPRITECOLLIDETYPE pmissile%, PIXELDETECT '                                     this missile uses pixel accurate collision detection
imissile1% = SPRITENEW(missilesheet%, 1, DONTSAVE) '                           invader missile 1 sprite (normal missile)
SPRITECOLLIDETYPE imissile1%, PIXELDETECT '                                    this missile uses pixel accurate collision detection
imissile2% = SPRITENEW(missilesheet%, 2, DONTSAVE) '                           invader missile 2 sprite (throbbing missile)
SPRITEANIMATESET imissile2%, 2, 5 '                                            this sprite uses these sheet cells for animation
SPRITEANIMATION imissile2%, ANIMATE, FORWARDLOOP '                             activate auto animation for this sprite
SPRITECOLLIDETYPE imissile2%, PIXELDETECT '                                    this missile uses pixel accurate collision detection
imissile3% = SPRITENEW(missilesheet%, 6, DONTSAVE) '                           invader missile 3 sprite (screwball missile)
SPRITEANIMATESET imissile3%, 6, 9 '                                            this sprite uses these sheet cells for animation
SPRITEANIMATION imissile3%, ANIMATE, FORWARDLOOP '                             activate auto animation for this sprite
SPRITECOLLIDETYPE imissile3%, PIXELDETECT '                                    this missile uses pixel accurate collision detection
FOR count% = 1 TO 10 '                                                         create sprite array of 10 invader missiles
    SELECT CASE count% '                                                       which missiles should be created?
        CASE 1 TO 4 '                                                          normal missiles
            imissile%(count%) = SPRITECOPY(imissile1%) '                       create 4 normal missiles
        CASE 5 TO 7 '                                                          throbbing missiles
            imissile%(count%) = SPRITECOPY(imissile2%) '                       create 3 throbbing missiles
        CASE 8 TO 10 '                                                         screwball missiles
            imissile%(count%) = SPRITECOPY(imissile3%) '                       create 3 screwball missiles
    END SELECT
NEXT count%

END SUB

'##################################################################################################################################

SUB LoadSounds ()

SHARED beat&(), playerhit&, invaderhit&, fire&, ufomoving&, ufohit&

beat&(1) = _SNDOPEN("beat1.ogg", "VOL, SYNC") '                                first beat of four beat marching sound
beat&(2) = _SNDOPEN("beat2.ogg", "VOL, SYNC") '                                second beat of four beat marching sound
beat&(3) = _SNDOPEN("beat3.ogg", "VOL, SYNC") '                                third beat of four beat marching sound
beat&(4) = _SNDOPEN("beat4.ogg", "VOL, SYNC") '                                fourth beat of four beat marching sound
playerhit& = _SNDOPEN("explosion.ogg", "VOL, SYNC") '                          player base ship getting hit explosion sound
invaderhit& = _SNDOPEN("kill.ogg", "VOL, SYNC") '                              invader getting hit explosion sound
fire& = _SNDOPEN("laser.ogg", "VOL, SYNC") '                                   player base ship laser cannon firing sound
ufomoving& = _SNDOPEN("ufo.ogg", "VOL, SYNC") '                                ufo moving across the screen sound
ufohit& = _SNDOPEN("ufokill.ogg", "VOL, SYNC") '                               ufo getting hit funky explosion sound

END SUB

'##################################################################################################################################

'$INCLUDE:'sprite.bi'


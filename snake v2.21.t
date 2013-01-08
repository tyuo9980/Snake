%By Peter Li
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v2.21 - 3/22/11
% fixed error when exiting game
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v2.2 - 3/10/11
% added text mode
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v2.11 - 3/9/11
% fixed wall spawning on snake/food
% fixed wall collide glitch
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v2.1 - 3/9/11
% added walls
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v2.01 - 3/8/11
% scoreboard fix
% added return to menu on difficulty screen
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v2.0 - 3/8/11
% added timed mode
% various bug fixes
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.22 - 3/7/11
% various key input fixes
% fixed save file bug
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.21 - 3/6/11
% fixed flickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.2 - 3/6/11
% added scoreboard
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.11 - 3/6/11
% fixed unexpected collision when paused
% fixed crash to menu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.1 - 3/5/11
% added sound effects
% added 1337 difficulty
% added custom difficulty
% added intro
% added menu
% added return to menu
% added pause function
% added instructions
% fixed boundaries
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.01 - 3/5/11
% fixed no death when hitting snake
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% v1.0 - 3/4/11
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

var x, y : int                                          %screensize
var x2, y2 : int
var wall : int
var wallx, wally : int
var wallrx, wallry : int                                %wall coords
var walldir : int
var frx, fry : int                                      %food coords
var sx, sy : int                                        %snake head coords
var wallsx : array 3 .. 156 of int
var wallsy : array 3 .. 114 of int
var fsx : array 3 .. 156 of int                         %food spawn point x coord
var fsy : array 3 .. 114 of int                         %food spawn point y coord
var sdirx, sdiry : int                                  %snake direction coords
var score : real                                        %score
var colr : array 1 .. 5 of int                          %stores food color
var col : int                                           %food color
var counter : int                                       %number of food eaten
var walltoggle : int                                    %toggle walls on/off
var texttoggle : int                                    %toggle textmode on/off
var GO : boolean                                        %checks if gameover is t/f
var retry : boolean                                     %checks if retry is t/f
var back2menu : boolean                                 %returns to menu
var wallenable : boolean                                %checks if walls are enabled
var key : string (1)                                    %wasd keys to move
var prevkey : string                                    %previous key pressed
var delay1 : int                                        %speed of snake
var input : string                                      %for error proofing
var segment : int                                       %number of segments
var chars : array char of boolean                       %check if keypressed or not
var prevx, prevy : array 1 .. 1000 of int               %previous snake segment coords
var difficultyl : string                                %level of difficulty
var timer : int                                         %timer
var timelast : int                                      %compares timenow
var timenow : int                                       %compares timelast

var name : string                                       %scoreboard
var fnum : int
var num : int
var prevtext : array 1 .. 100 of string

back2menu := false                                      %disabled by default
wallenable := false

fnum := 1
num := 0

x := 1                                                  %800x600 resolution
y := 1
x2 := 800
y2 := 600
colr (1) := 42                                          %orange
colr (2) := 46                                          %lightgreen
colr (3) := 52                                          %aqua
colr (4) := 65                                          %lightpink
colr (5) := 77                                          %brightblue
prevkey := ""                                           %filler
prevtext (1) := ""                                      %filler
walltoggle := 0                                         %disabled by default
texttoggle := 0

View.Set ("graphics:800;600, nobuttonbar, nocursor, offscreenonly")

process musicadd1
    Music.PlayFile ("add1.wav")
end musicadd1

process musiclose
    Music.PlayFile ("lose.wav")
end musiclose

process musicintro
    Music.PlayFile ("intro.wav")
end musicintro

procedure setmap
    Draw.Box (x, y, x2, y2, black)
    Draw.FillBox (x, y, x2, y2, black)
    colourback (black)
    colour (white)
end setmap

procedure intro
    fork musicintro
    setmap

    for a : 16 .. 31
	locatexy (230, 300)
	color (a)
	put "This pro snake game is by..."
	View.Update
	delay (50)
    end for

    for decreasing b : 31 .. 16
	locatexy (230, 300)
	color (b)
	put "This pro snake game is by..."
	View.Update
	delay (50)
    end for

    for c : 16 .. 31
	locatexy (435, 300)
	color (c)
	put "Peter Li"
	View.Update
	delay (100)
    end for

    delay (1250)

end intro

procedure createwall
    for walls : 1 .. wall
	randint (walldir, 1, 2)                         %random wall direction

	for wx : 3 .. 156
	    wallsx (wx) := wx * 5
	end for
	for wy : 3 .. 114
	    wallsy (wy) := wy * 5
	end for

	randint (wallx, 3, 156)
	randint (wally, 3, 114)

    end for
end createwall

procedure foodspawn
    randint (frx, 3, 156)                               %randomize spawn coords
    randint (fry, 3, 114)
    randint (col, 1, 5)                                 %randomize food color

    for foodx : 3 .. 156
	fsx (foodx) := foodx * 5
    end for

    for foody : 3 .. 114
	fsy (foody) := foody * 5
    end for

end foodspawn

procedure overlap
    for overlap : 0 .. 20
	if fsx (frx) = wallsx (wallx) + overlap * 5 and fsy (fry) = wallsy (wally) then
	    foodspawn
	end if
	if fsx (frx) = wallsx (wallx) and fsy (fry) = wallsy (wally) + overlap * 5 then
	    foodspawn
	end if
    end for
end overlap

procedure scored
    counter += 1
    score += 1337 + counter * 1.337
end scored

procedure collide
    if sx < x then                                      %outside boundaries
	locatexy (340, 400)
	put "Your score: ", round (score)
	locatexy (375, 300)
	put "GAME OVER"
	fork musiclose
	View.Update
	delay (1000)
	GO := true
    elsif sy < y then
	locatexy (340, 400)
	put "Your score: ", round (score)
	locatexy (375, 300)
	put "GAME OVER"
	fork musiclose
	View.Update
	delay (1000)
	GO := true
    elsif sx + 5 > x2 then
	locatexy (340, 400)
	put "Your score: ", round (score)
	locatexy (375, 300)
	put "GAME OVER"
	fork musiclose
	View.Update
	delay (1000)
	GO := true
    elsif sy + 5 > y2 then
	locatexy (340, 400)
	put "Your score: ", round (score)
	locatexy (375, 300)
	put "GAME OVER"
	fork musiclose
	View.Update
	delay (1000)
	GO := true
    end if

    for c : 1 .. segment                                %hits segments
	if sx = prevx (c) and sy = prevy (c) then
	    locatexy (340, 400)
	    put "Your score: ", round (score)
	    locatexy (375, 300)
	    put "GAME OVER"
	    fork musiclose
	    View.Update
	    delay (1000)
	    GO := true
	end if
    end for

    if sx = fsx (frx) and sy = fsx (fry) then           %eats food
	segment += 1
	if wallenable = true then
	    wall += 1
	    createwall
	end if
	foodspawn
	scored
	fork musicadd1
    end if
end collide

procedure collidewall

    if walldir = 1 then
	for wallcheck : 0 .. 19
	    if sx = wallsx (wallx) + wallcheck * 5 and sy = wallsy (wally) then
		locatexy (340, 400)
		put "Your score: ", round (score)
		locatexy (375, 300)
		put "GAME OVER"
		fork musiclose
		View.Update
		delay (1000)
		GO := true
	    end if
	end for

    elsif walldir = 2 then
	for wallcheck : 0 .. 19
	    if sx = wallsx (wallx) and sy = wallsy (wally) + wallcheck * 5 then
		locatexy (340, 400)
		put "Your score: ", round (score)
		locatexy (375, 300)
		put "GAME OVER"
		fork musiclose
		View.Update
		delay (1000)
		GO := true
	    end if
	end for
    end if

end collidewall

procedure difficulty                                    %Higher delay = slower
    loop                                                %Lower delay = faster
	cls
	put "Enter difficulty level"
	put "[1] Easy"
	put "[2] Normal"
	put "[3] Hard"
	put "[4] 1337"
	put "[5] Custom"
	put ""
	put "[0] Back"
	View.Update
	getch (key)
	if key = "1" then
	    delay1 := 70
	    difficultyl := "Easy"
	    exit
	elsif key = "2" then
	    delay1 := 40
	    difficultyl := "Normal"
	    exit
	elsif key = "3" then
	    delay1 := 25
	    difficultyl := "Hard"
	    exit
	elsif key = "4" then
	    delay1 := 15
	    difficultyl := "1337"
	    exit
	elsif key = "5" then
	    View.Set ("graphics:800;600, nobuttonbar, nocursor, nooffscreenonly")
	    put "Enter delay - 15 = 1337, 25 = Hard, 40 = Normal, 70 = Easy"
	    get input
	    if strintok (input) then
		delay1 := strint (input)
		difficultyl := input
	    else
		put "Invalid input"
	    end if
	    View.Set ("graphics:800;600, nobuttonbar, nocursor, offscreenonly")
	    exit
	elsif key = "0" then
	    back2menu := true
	    exit
	end if
    end loop
end difficulty

procedure drawwall
    if walldir = 1 then                                 %horizontal
	if texttoggle = 1 then
	    Draw.Text ("#", wallsx (wallx), wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 10, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 20, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 30, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 40, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 50, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 60, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 70, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 80, wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx) + 90, wallsy (wally), defFontID, white)
	else
	    Draw.Box (wallsx (wallx), wallsy (wally), wallsx (wallx) + 100, wallsy (wally) + 5, white)
	    Draw.FillBox (wallsx (wallx), wallsy (wally), wallsx (wallx) + 100, wallsy (wally) + 5, white)
	end if
    elsif walldir = 2 then                              %vertical
	if texttoggle = 1 then
	    Draw.Text ("#", wallsx (wallx), wallsy (wally), defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 10, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 20, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 30, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 40, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 50, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 60, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 70, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 80, defFontID, white)
	    Draw.Text ("#", wallsx (wallx), wallsy (wally) + 90, defFontID, white)
	else
	    Draw.Box (wallsx (wallx), wallsy (wally), wallsx (wallx) + 5, wallsy (wally) + 100, white)
	    Draw.FillBox (wallsx (wallx), wallsy (wally), wallsx (wallx) + 5, wallsy (wally) + 100, white)
	end if
    end if
end drawwall

procedure drawsnake

    for decreasing ds : segment .. 2                    %saves previous segment coords
	prevx (ds) := prevx (ds - 1)
	prevy (ds) := prevy (ds - 1)
    end for

    prevx (1) := sx
    prevy (1) := sy

    sx += sdirx                                         %calculates new coords of head
    sy += sdiry

    if texttoggle = 1 then
	Draw.Text ("+", sx, sy, defFontID, brightgreen)
    else
	Draw.Box (sx, sy, sx + 5, sy + 5, brightgreen)  %draws head
	Draw.FillBox (sx + 1, sy + 1, sx + 4, sy + 4, brightgreen)
    end if

    for seg : 1 .. segment                              %draws segments
	if texttoggle = 1 then
	    Draw.Text ("+", prevx (seg), prevy (seg), defFontID, 42)
	else
	    Draw.Box (prevx (seg), prevy (seg), prevx (seg) + 5, prevy (seg) + 5, brightgreen)
	    Draw.FillBox (prevx (seg) + 1, prevy (seg) + 1, prevx (seg) + 4, prevy (seg) + 4, 42)
	end if
    end for

end drawsnake

procedure drawfood
    if texttoggle = 1 then
	Draw.Text ("*", fsx (frx), fsy (fry), defFontID, colr (col))
    else
	Draw.Box (fsx (frx), fsy (fry), fsx (frx) + 5, fsy (fry) + 5, colr (col))
	Draw.FillBox (fsx (frx), fsy (fry), fsx (frx) + 5, fsy (fry) + 5, colr (col))
    end if
end drawfood

procedure reset                                         %variable reset

    cls
    setmap

    if wallenable = true then
	wall := 1
	createwall
	overlap
    end if

    foodspawn
    GO := false
    retry := false
    back2menu := false
    sx := 400
    sy := 300
    sdiry := 0
    sdirx := 0
    score := 0
    segment := 0
    counter := 0
    timer := 60

end reset

procedure instructions
    locatexy (330, 300)
    put "Use W,A,S,D to move"
    View.Update
    delay (1500)
end instructions

procedure leaderboard
    loop
	cls
	put "[0] Return"
	put ""
	View.Update

	open : fnum, "score.txt", read
	for x : 1 .. 100
	    exit when eof (fnum)
	    read : fnum, prevtext (x)
	end for
	close : fnum
	put prevtext (x)

	View.Update

	getch (key)
	if key = "0" then
	    exit
	end if

    end loop
end leaderboard

procedure leaderboardtimer
    loop
	cls
	put "[0] Return"
	put ""
	View.Update

	open : fnum, "scoretimer.txt", read
	for x : 1 .. 100
	    exit when eof (fnum)
	    read : fnum, prevtext (x)
	end for
	close : fnum
	put prevtext (x)

	View.Update

	getch (key)
	if key = "0" then
	    exit
	end if

    end loop
end leaderboardtimer

procedure savefile
    View.Set ("graphics:800;600, nobuttonbar, nocursor, nooffscreenonly")
    locatexy (375, 500)
    put "Enter name"
    locatexy (375, 475)
    get name : *
    open : fnum, "score.txt", put, mod, seek
    seek : fnum, *
    put : fnum, difficultyl, "      ", name : 18, "  ", round (score), "   ", walltoggle
    close : fnum
    View.Set ("graphics:800;600, nobuttonbar, nocursor, offscreenonly")
end savefile

procedure savefiletimer
    View.Set ("graphics:800;600, nobuttonbar, nocursor, nooffscreenonly")
    locatexy (375, 500)
    put "Enter name"
    locatexy (375, 475)
    get name : *
    open : fnum, "scoretimer.txt", put, mod, seek
    seek : fnum, *
    put : fnum, difficultyl, "      ", name : 18, "  ", counter, "   ", walltoggle
    close : fnum
    View.Set ("graphics:800;600, nobuttonbar, nocursor, offscreenonly")
end savefiletimer

procedure timed

    loop
	if back2menu = true then
	    exit
	end if

	reset
	difficulty

	if back2menu = true then
	    exit
	end if

	instructions

	if wallenable = true then
	    createwall
	end if

	timelast := Time.Elapsed

	loop

	    cls
	    collide

	    if wallenable = true then
		collidewall
	    end if

	    if timer = 0 then
		locatexy (340, 400)
		put "Your score: ", round (score)
		locatexy (375, 300)
		put "GAME OVER"
		fork musiclose
		View.Update
		delay (1000)
		GO := true
	    end if

	    if GO = true then
		savefiletimer
		loop
		    cls
		    setmap
		    Input.KeyDown (chars)
		    put "Do you want to retry? (Y/N)"
		    if chars ('y') or chars ('Y') then
			retry := true
			exit
		    elsif chars ('n') or chars ('N') then
			quit
		    end if
		    locatexy (340, 400)
		    put "Your score: ", round (score)
		    locatexy (375, 300)
		    put "GAME OVER"

		    View.Update

		end loop
	    end if

	    if retry = true then
		exit
	    end if

	    drawsnake
	    drawfood

	    if wallenable = true then
		drawwall
	    end if

	    timenow := Time.Elapsed

	    if timenow - timelast >= 1000 then
		timer -= 1
		timelast := timenow
	    end if

	    locatexy (20, 585)                          %scoreboard
	    put "Press 0 to return to menu"
	    locatexy (350, 585)
	    put "Time: ", timer
	    locatexy (500, 585)
	    put "Count: ", counter
	    locatexy (650, 585)
	    put "Score: ", round (score)

	    if hasch = true then                        %gets key input
		getch (key)
		if key = "w" then
		    sdiry := 5
		    sdirx := 0
		    if prevkey = "s" then               %disallow movement in opposite direction
			sdiry := -5
			sdirx := 0
			key := "s"
		    end if
		elsif key = "a" then
		    sdiry := 0
		    sdirx := -5
		    if prevkey = "d" then
			sdiry := 0
			sdirx := 5
			key := "d"
		    end if
		elsif key = "s" then
		    sdiry := -5
		    sdirx := 0
		    if prevkey = "w" then
			sdiry := 5
			sdirx := 0
			key := "w"
		    end if
		elsif key = "d" then
		    sdiry := 0
		    sdirx := 5
		    if prevkey = "a" then
			sdiry := 0
			sdirx := -5
			key := "a"
		    end if
		elsif key = "0" then
		    loop
			cls
			put "Are you sure you want to quit? (Y/N)"
			Input.KeyDown (chars)
			if chars ('y') or chars ('Y') then
			    back2menu := true
			    exit
			elsif chars ('n') or chars ('N') then
			    exit
			end if

			View.Update

		    end loop

		    if back2menu = true then
			exit
		    end if

		end if
		prevkey := key
	    end if

	    View.Update
	    delay (delay1)

	end loop
    end loop
end timed


procedure survival

    loop

	if wallenable = true then
	    createwall
	end if

	if back2menu = true then
	    exit
	end if

	reset
	difficulty

	if back2menu = true then
	    exit
	end if

	instructions

	loop

	    cls
	    collide

	    if wallenable = true then
		collidewall
	    end if

	    if GO = true then
		savefile
		loop
		    cls
		    setmap
		    Input.KeyDown (chars)
		    put "Do you want to retry? (Y/N)"
		    if chars ('y') or chars ('Y') then
			retry := true
			exit
		    elsif chars ('n') or chars ('N') then
			quit
		    end if
		    locatexy (340, 400)
		    put "Your score: ", round (score)
		    locatexy (375, 300)
		    put "GAME OVER"

		    View.Update

		end loop
	    end if

	    if retry = true then
		exit
	    end if

	    drawsnake
	    drawfood

	    if wallenable = true then
		drawwall
	    end if

	    locatexy (20, 585)                          %scoreboard
	    put "Press 0 to return to menu"
	    locatexy (500, 585)
	    put "Count: ", counter
	    locatexy (650, 585)
	    put "Score: ", round (score)

	    if hasch = true then                        %gets key input
		getch (key)
		if key = "w" then
		    sdiry := 5
		    sdirx := 0
		    if prevkey = "s" then               %disallow movement in opposite direction
			sdiry := -5
			sdirx := 0
			key := "s"
		    end if
		elsif key = "a" then
		    sdiry := 0
		    sdirx := -5
		    if prevkey = "d" then
			sdiry := 0
			sdirx := 5
			key := "d"
		    end if
		elsif key = "s" then
		    sdiry := -5
		    sdirx := 0
		    if prevkey = "w" then
			sdiry := 5
			sdirx := 0
			key := "w"
		    end if
		elsif key = "d" then
		    sdiry := 0
		    sdirx := 5
		    if prevkey = "a" then
			sdiry := 0
			sdirx := -5
			key := "a"
		    end if
		elsif key = "0" then
		    loop
			cls
			put "Are you sure you want to quit? (Y/N)"
			Input.KeyDown (chars)
			if chars ('y') or chars ('Y') then
			    back2menu := true
			    exit
			elsif chars ('n') or chars ('N') then
			    exit
			end if

			View.Update

		    end loop

		    if back2menu = true then
			exit
		    end if

		end if
		prevkey := key
	    end if
	    View.Update
	    delay (delay1)
	end loop
    end loop
end survival

procedure menu
    loop
	reset
	cls
	put "[1] Survival"
	put "[2] Countdown"
	put "[3] Survival Scoreboard"
	put "[4] Countdown Scoreboard"
	put "[5] Toggle Walls Status: ", walltoggle
	put "[6] Toggle Text Mode Status: ", texttoggle
	put ""
	put "[0] Exit"

	View.Update

	getch (key)
	if key = "1" then
	    survival
	elsif key = "2" then
	    timed
	elsif key = "3" then
	    cls
	    setmap
	    leaderboard
	elsif key = "4" then
	    cls
	    setmap
	    leaderboardtimer
	elsif key = "5" then
	    if walltoggle = 0 then
		walltoggle := 1
		wallenable := true
	    elsif walltoggle = 1 then
		walltoggle := 0
		wallenable := false
	    end if
	elsif key = "6" then
	    if texttoggle = 0 then
		texttoggle := 1
	    elsif texttoggle = 1 then
		texttoggle := 0
	    end if
	elsif key = "0" then
	    loop
		cls
		put "Are you sure you want to quit? (Y/N)"
		Input.KeyDown (chars)
		if chars ('y') or chars ('Y') then
		    quit
		elsif chars ('n') or chars ('N') then
		    exit
		end if

		View.Update

	    end loop
	end if
    end loop
end menu

setmap
intro
menu

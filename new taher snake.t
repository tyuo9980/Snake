setscreen ("graphics:640;480,nocursor,nobuttonbar,offscreenonly")

var chars : array char of boolean %store string for which direction snake must travel in (holds one value)
var x, y : array 1 .. 11930 of int %lower left coordinates of snake head
var xdir, ydir : int %
var retry : boolean %checks if retry has been asked (true or false)
var fx : int %lower left coordinates of food
var fy : int %upper right coordinates of food
var points : real %points earned from eating food
var multiplier : real %how much points multiply by
var mpoints : real %total points
var mchoice : string (1) %menu options (holds one value)
var timenow, timelast : int
var bodies : int

color (white)
colorback (black)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%procedure for rules

proc rules

    locatexy (160, 240)
    put "Use W, A, S, and D to move, collect the food"
    locatexy (157, 220)
    put "Don't touch the walls and don't touch yourself"
    locatexy (0, 0)
    put "Press M to go back to menu"

    View.Update

    getch (mchoice)

    loop
	if mchoice = "m" or mchoice = "M" then
	    exit
	else
	    getch (mchoice)
	end if
    end loop

    cls

end rules

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%procedure for game over

proc gameover

    %When game is over, show user his or her score

    locatexy (200, 240)
    put "Game is over, wasn't that fun :)"

    locatexy (270, 300)
    put "Your score is"
    locatexy (310, 280)
    put mpoints

    View.Update

    Time.Delay (5000)

    cls

end gameover

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%procedure for food spawning

proc spawnfood

    %randomly choose x and y coordinates for lower left of food box (multiplied by 5 to make sure everything is within 5 pixels

    randint (fx, 1, 125)
    randint (fy, 1, 93)

    fx *= 5
    fy *= 5

    %end food procedure

end spawnfood

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%procedure of snake movements and game

proc move
    %CONTROLS

    Input.KeyDown (chars)

    if chars ('w') or chars ('W') then             %if w is pressed, go up, but if snake was previously going down, keep going down
	if ydir ~= -5 then
	    xdir := 0
	    ydir := 5
	end if
    elsif chars ('s') or chars ('S') then             %if s is pressed, go down, but if snake was previously going up, keep going up
	if ydir ~= 5 then
	    xdir := 0
	    ydir := -5
	end if
    elsif chars ('a') or chars ('A') then             %if a is pressed, go left, but if snake was previously going right, keep going right
	if xdir ~= 5 then
	    xdir := -5
	    ydir := 0
	end if
    elsif chars ('d') or chars ('D') then             %if d is pressed, go right, but if snake was previously going left, keep going left
	if xdir ~= -5 then
	    xdir := 5
	    ydir := 0
	end if
    end if

end move     %end of snake movement procedure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc varinit
    %initialize values
    x (1) := 315
    y (1) := 235
    xdir := 0
    ydir := 0
    retry := false
    multiplier := 0.5
    points := 5
    mpoints := 0
    mchoice := "O"
    bodies := 1
end varinit

proc drawsnake
    for decreasing a : bodies .. 2 % draws body
	x (a) := x (a - 1)
	y (a) := y (a - 1)
    
	
	Draw.FillBox (x (a), y (a), x (a) + 5, y (a) + 5, 43)
    end for
    
    x (1) += xdir
    y (1) += ydir
    
    Draw.FillBox (x (1), y (1), x (1) + 5, y (1) + 5, 43)
end drawsnake

proc drawfood
    Draw.FillBox (fx, fy, fx + 5, fy + 5, 50)
end drawfood

proc collision
    if x (1) = fx and y (1) = fy then
	bodies += 1
	spawnfood
    end if

    if x (1) < 0 then       %more efficient than or-ing
	gameover
    elsif x (1) > 635 then
	gameover
    elsif y (1) < 0 then
	gameover
    elsif y (1) > 475 then
	gameover
    end if
end collision

proc startgame
    timelast := Time.Elapsed
    spawnfood
    loop
	timenow := Time.Elapsed
	if timenow - timelast > 50 then
	    timelast := timenow
	    cls
	    Draw.FillBox (1, 1, 640, 480, black)
	    move
	    collision
	    drawfood
	    drawsnake
	    View.Update
	end if
    end loop
end startgame


loop

    Draw.FillBox (1, 1, 640, 480, black)
    put "[1] Play Game"
    put "[2] Instructions"
    put "[3] Quit"

    View.Update

    getch (mchoice)

    if mchoice = "1" then
	cls
	varinit
	startgame
    elsif mchoice = "2" then
	cls
	rules
    elsif mchoice = "3" then
	cls
	locatexy (318, 240)
	put "BYE!"
	View.Update
	exit
    end if
end loop

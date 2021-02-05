%------------MAIN BATTLESHIPS FUNCTION------------%
function battleship_final
%------------INITIAL ICON/AUDIO LOAD------------%

%PATH TO THIS GAME
[fullpath] = fileparts(mfilename('fullpath'));

%SHIP ICONS
ship1 = imread(strcat(fullpath,'\icons\1.png'));
ship2 = imread(strcat(fullpath,'\icons\2.png'));
ship3 = imread(strcat(fullpath,'\icons\3.jpg'));
ship4 = imread(strcat(fullpath,'\icons\4.png'));

%HIT OR MISS ICONS
hit = imread(strcat(fullpath,'\icons\explosion.png'));
miss = imread(strcat(fullpath,'\icons\splash.jpg'));

%AUDIO FILES
[e,es] =audioread(strcat(fullpath,'\sounds\explosion.wav'));
[s,ss] =audioread(strcat(fullpath,'\sounds\splash.wav'));

%------------SHIP SETUP------------%

%TYPES OF SHIP IN THE GAME
DESTROYER=1;
AIRCRAFT=2;
BATTLESHIP=3;
PATROL=4;

%SET SIZE OF EACH SHIP TYPE
shipsizes(BATTLESHIP)=4;
shipsizes(AIRCRAFT)=5;
shipsizes(DESTROYER)=3;
shipsizes(PATROL)=2;

%GRID NAMES FOR AI/PLAYER LOGIC
shipname(BATTLESHIP)='B';
shipname(AIRCRAFT)='A';
shipname(DESTROYER)='D';
shipname(PATROL)='P';

%LIST OF PIECES THE PLAYER CAN PLACE
shiptype = [DESTROYER BATTLESHIP AIRCRAFT PATROL PATROL] ;

%VISUAL PLAYER GRID SET UP
VISUAL_PLAYERGRID=figure;
set(VISUAL_PLAYERGRID,'name','Player Screen','numbertitle','off');
plot(0,0,8,8);
grid on ;
hold on ;
movegui(VISUAL_PLAYERGRID, 'center');
set(VISUAL_PLAYERGRID,'MenuBar','none');

n = 1;

%PLAYERGRID = 8x8 MATRIX OF '-'
clear PLAYERGRID;
PLAYERGRID(1:8,1:8)='-';

%------------SHIP PLACING------------%
while n <= length(shiptype)
    
    %CHOOSE WHICH SHIP IS BEING PLACED
    type = shiptype(n);
    
    if type == BATTLESHIP
        shipimage = ship1;
    end
    
    if type == DESTROYER
        shipimage = ship2;
    end
    
    if type == AIRCRAFT
        shipimage = ship3;
    end
    
    if type == PATROL
        shipimage = ship4;
    end
    
    %GET THE XY COORDINATES OF MOUSE CLICK & BUTTON USED
    [clickx,clicky,button] = ginput(1);
    
    
    if button == 1 %LEFT MOUSE BUTTON - NO ROTATION NEEDED
        X1=floor(clickx)+0.1;%+0.1 TO MOVE OFF AXIS LINE
        Y1=floor(clicky)+0.1;
        
        X2=X1 + shipsizes(type)-0.2;%ADD LENGTH OF CERTAIN SHIP
        Y2=Y1 + 1-0.2;%ADD 1 FOR ALL AS WIDTH OF SHIP IS CONSTANT
        
    else % RIGHT MOUSE BUTTON - ROTATE SHIP 90 DEGREES
        shipimage = imrotate(shipimage, 90);
        
        X1=floor(clickx)+0.1;
        Y1=floor(clicky)-0.1+1.0;%ADD 1 SO IT GOES IN CORRECT GRID CLICKED
        
        X2=X1 + 1 - 0.2;
        Y2=Y1 - shipsizes(type)+0.2;
    end
    
    %CHECK BOUNDARIES FOR INVALID GRAPH POINTS
    if X2 > 8 || Y2 > 8 || X2 < 0 || Y2 < 0 || X1 > 8 || Y1 > 8 || X1<0 || Y1<0
        uiwait(msgbox('This is an invalid location','Error','modal'));
    else
        
        %------------SHIP PLACING INTO PLAYERGRID------------%
        
        if button == 1 %LEFT MOUSE BUTTON
            ship_doesnt_exist=1;
            
            %SEARCH WHERE WE WILL PUT THE SHIP TO MAKE SURE ITS CLEAR
            for i=1:shipsizes(type)
                atgridXY = PLAYERGRID(9-floor(Y1+1),floor(X1+i)); %-9 TO INVERT Y AXIS
                if atgridXY~='-' %NOT A BLANK SPACE, THERE IS A SHIP
                    ship_doesnt_exist=0;
                end
            end
            
            %IF THERE ISNT ANYTHING IN THOSE SPACES PLACE SHIP
            if ship_doesnt_exist == 1
                for i=1:shipsizes(type)
                    PLAYERGRID(9-floor(Y1+1),floor(X1+i)) = shipname(type);%PLACES CORRESPONDING LETTERS ON GRID
                end
                
                %PLACE SHIP ON GRAPH
                image([X1 X2],[Y1 Y2],shipimage);
                % INCREMENT N BECAUSE SHIP WAS PLACED
                n = n + 1 ;
            else
                % THERE WAS SOMETHING IN THE SPACES, WARN OUR PLAYER
                uiwait(msgbox('A ship already exists in this location','Error','modal'));
            end
            
        else %OTHER MOUSE BUTTON
            %SEARCH WHERE WE WILL PUT THE SHIP TO MAKE SURE ITS CLEAR
            ship_doesnt_exist=1;
            
            for i=1:shipsizes(type)
                atgridXY = PLAYERGRID(9-floor(Y1-i+2),floor(X1+1));
                if atgridXY~='-' % NOT A BLANK SPACE, THERE IS A SHIP
                    ship_doesnt_exist=0;
                end
            end
            
            if ship_doesnt_exist == 1
                for i=1:shipsizes(type)
                    PLAYERGRID(9-floor(Y1-i+2),floor(X1+1)) = shipname(type);
                end
                
                %PLACE SHIP ON GRAPH
                image([X1 X2],[Y1 Y2],shipimage);
                %INCREMENT N BECAUSE SHIP WAS PLACED
                n = n + 1 ;
                
            else
                %THERE WAS SOMETHING IN THE SPACES, WARN OUR PLAYER
                uiwait(msgbox('A ship already exists in this location','Error','modal'));
            end
        end
    end
end % WHILE - PLACING PLAYER SHIPS

%------------AI GRID = 8x8 MATRIX OF '-'------------%
clear AIGRID ;
AIGRID(1:8,1:8)='-';
n = 1;
%------------PLACING AI SHIPS------------%
while n <= length(shiptype)
    
    type = shiptype(n);
    
    %GENERATE RANDOM XY FOR SHIP POSITION
    X1 = floor(rand(1)*8);
    Y1 = floor(rand(1)*8);
    
    %GENERATE RANDOM 0 OR 1 FOR VERTICAL OR HORIZONTAL PLACING
    translation = floor(rand(1)*2);
    
    if translation == 0 %PLACE VERTICALLY
        
        X2=X1 + shipsizes(type)-0.2;
        Y2=Y1 + 1-0.2;
        
    else %PLACE HORIZONTALLY
        X2=X1 + 1 - 0.2;
        Y2=Y1 - shipsizes(type)+0.2;
    end
    
    %CHECK BOUNDARIES
    if X2 > 8 || Y2 > 8 || X2 < 0 || Y2 < 0
        
    else
        if translation == 0;
            %VERTICAL POSITIONING
            ship_doesnt_exist=1;
            
            %SEARCH WHERE WE WILL PUT THE SHIP TO MAKE SURE ITS CLEAR
            for i=1:shipsizes(type)
                atgridXY = AIGRID(9-floor(Y1+1),floor(X1+i)); %-9 TO INVERT Y AXIS
                if atgridXY~='-' %NOT A BLANK SPACE, THERE IS A SHIP
                    ship_doesnt_exist=0;
                end
            end
            
            %IF THERE ISNT ANYTHING IN THOSE SPACES PLACE SHIP
            if ship_doesnt_exist == 1
                for i=1:shipsizes(type)
                    AIGRID(9-floor((Y1)+1),floor(X1+i)) = shipname(type);
                end
                % INCREMENT N BECAUSE SHIP WAS PLACED
                n = n + 1 ;
            end
            
        else
            
            %HORIZONTAL POSITIONING
            ship_doesnt_exist=1;
            
            for i=1:shipsizes(type)
                atgridXY = AIGRID(9-floor(Y1-i+2),floor(X1+1));%-9 TO INVERT Y AXIS
                if atgridXY~='-' %NOT A BLANK SPACE, THERE IS A SHIP
                    ship_doesnt_exist=0;
                end
            end
            
            if ship_doesnt_exist == 1
                for i=1:shipsizes(type)
                    AIGRID(9-floor(Y1-i+2),floor(X1+1)) = shipname(type);
                end
                %INCREMENT N BECAUSE SHIP WAS PLACED
                n = n + 1 ;
            end
        end
    end
    
end %WHILE - PLACING AI SHIPS

%VISUAL AI GRID
VISUAL_AIGRID=figure;
set(VISUAL_AIGRID,'name','AI Screen','numbertitle','off');
plot(0,0,8,8);
grid on;
hold on ;
position = get(VISUAL_PLAYERGRID,'Position');
movegui([position(1)+550,position(2)]);
set(VISUAL_AIGRID,'MenuBar','none');

%------------LOOP FOR TAKING SHOTS ------------%
winner = 0;
while winner==0
    
    %CHOOSE VISUAL AI GRID
    figure(VISUAL_AIGRID);
    
    %------------ PLAYER TAKES SHOT ------------%
    %SHOT LOCATION
    clickx=-1; %CHECK SHOT LOCATION IS INSIDE GRID
    clicky=-1;
    while clickx < 0 || clickx > 8 || clicky > 8 || clicky < 0
        [clickx,clicky] = ginput(1);
    end
    
    shotx = floor(clickx);
    shoty = floor(clicky);
    
    %DRAW IMAGE ON FIGURE
    if AIGRID(9-(shoty+1),shotx+1) == '-'
        image([shotx+0.1 shotx+1-0.2], [shoty + 0.1 shoty + 1 - 0.2], miss);
        sound(s,ss);%SOUND EFFECT
    else
        AIGRID(9-(shoty+1),shotx+1) = 'X';
        image([shotx+0.1 shotx+1-0.2], [shoty + 0.1 shoty + 1 - 0.2], hit);
        sound(e,es);%SOUND EFFECT
    end
    
    %------------ CHECK TO SEE IF PLAYER KILLED EVERYTHING ------------%
    winner = CheckForWin(AIGRID);
    if winner ~= 0
        break ;
    end
    %PAUSE BEFORE AI SHOT TO PREVENT SOUND CROSSOVER
    pause(1) ;
    
    %------------ AI TAKES SHOT ------------%
    while 1
        %PICK RANDOM SHOT POSITION
        shotx= floor(rand(1)*8);
        shoty= floor(rand(1)*8);
        
        %MAKE SURE IT HASN'T ALREADY HIT THIS POSITION
        if PLAYERGRID(9-(shoty+1),shotx+1) ~= 'X' && PLAYERGRID(9-(shoty+1),shotx+1) ~= 'O'
            break ;
        end
    end
    
    %CHOOSE VISUAL PLAYER GRID
    figure(VISUAL_PLAYERGRID);
    
    %IF AI GIVE O TO PREVENT HITTING SAME SPOT TWICE
    if PLAYERGRID(9-(shoty+1),shotx+1) == '-'
        PLAYERGRID(9-(shoty+1),shotx+1) = 'O';
        image([shotx+0.1 shotx+1-0.2], [shoty + 0.1 shoty + 1 - 0.2], miss);
        sound(s,ss);%SOUND EFFECT
    else
        PLAYERGRID(9-(shoty+1),shotx+1) = 'X';
        image([shotx+0.1 shotx+1-0.2], [shoty + 0.1 shoty + 1 - 0.2], hit);
        sound(e,es);%SOUND EFFECT
    end
    
    %------------ CHECK TO SEE IF AI KILLED EVERYTHING ------------%
    winner = CheckForWin( PLAYERGRID ) ;
    if winner ~= 0
        winner = 2 ;
        break ;
    end
end %WHILE - TAKING SHOTS

%------------CONGRATULATIONS SCREEN ------------%
if winner == 1 ;
    uiwait(msgbox('Congratulations! You have won','WINNER','modal'))
else
    uiwait(msgbox('Badluck, you lost to the AI','LOSER','modal'))
end
close all
end
%------------CHECK FOR WIN FUNCTION ------------%
function winner = CheckForWin(INTERNAL_GRID)

for x=1:8
    for y=1:8
        if INTERNAL_GRID(x,y) ~= '-' && INTERNAL_GRID(x,y) ~='X' %CHECK IF SHIP EXISTS ON GRID
            break  %EXIT FOR LOOP
        end
    end %END OF Y CHECK
    
    if INTERNAL_GRID(x,y) ~= '-' && INTERNAL_GRID(x,y) ~='X'
        break %EXIT FOR X LOOP
    end
end

if INTERNAL_GRID(x,y) == '-' || INTERNAL_GRID(x,y)== 'X'
    winner = 1;
else
    winner = 0 ;
end
end
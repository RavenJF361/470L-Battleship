`timescale 1ns / 1ps

// Notes for self 
/*
2D Arrays for virtual boards 
Player One - DONE
Player Two - N/A

-Started game logic on receiving user input
- NEED TO IMPLEMENT LOGIC TO PLACE USER SHIP.
- OR YOU CAN JUST RANDOMLY PLACE THEM.

Displaying LEDS through multiplexing

NOTE to self
: make another board containing the coordinates of the user's ship, so you use it to check
if you hit a ship or not. 

*/

module battleship(
input wire clk,

///////////////////////////
// Player One Board I/O
///////////////////////////
input wire ARDUINO_A0,   // Button used to store user's input into the virtual board
input wire ARDUINO_A1,   // Dipswitch "number 1"
input wire ARDUINO_A2,   // Dipswitch "number 2"
input wire ARDUINO_A3,   // Dipswitch "number 3"
output reg ARDUINO_IO0,  // Voltage for Green LED
output reg ARDUINO_IO1,  // Voltage for Green LED
output reg ARDUINO_IO2,  // Voltage for Green LED
//
output reg ARDUINO_IO6,  // Voltage for BLUE LED
output reg ARDUINO_IO7,  // Voltage for BLUE LED
output reg ARDUINO_IO8,  // Voltage for BLUE LED
//
output reg ARDUINO_IO9,  // Voltage for RED LED
output reg ARDUINO_IO10, // Voltage for RED LED
output reg ARDUINO_IO11, // Voltage for RED LED.

output reg ARDUINO_A4, // Help user determine whether its row
output reg ARDUINO_A5, // Help user determine whether its column

///////////////////////////
// Player Two Board I/O
///////////////////////////
// PMOD 1
output reg PMOD1_D0_P, // pin 1 RED
output reg PMOD1_D0_N, // pin 2 RED
output reg PMOD1_D1_P, // pin 3 RED

output reg PMOD1_D1_N, // pin 7 GREEN
output reg PMOD1_D2_P, // pin 8 GREEN 
output reg PMOD1_D2_N, // pin 9 GREEN

//PMOD 2
output reg PMOD2_D0_P, // pin 1 BLUE
output reg PMOD2_D0_N, // pin 2 BLUE
output reg PMOD2_D1_P, // pin 3 BLUE




output reg PMOD2_D2_P, // GND for Player 2 pin 7
output reg PMOD2_D2_N, // GND for Player 2 pin 8
output reg PMOD2_D3_P, // GND for Player 2 pin 9
 
output reg ARDUINO_IO3,  // GND for Player 1
output reg ARDUINO_IO4,  // GND for Player 1
output reg ARDUINO_IO5   // GND for Player 1
);

// POTENTIALLY UNUSED, REMOVE
// Flag to initiate board.
reg makeBoards = 1;
reg make2DArray = 1;
    
// Initiating variables


// Player One Board
reg [7:0] playerOneBoard [0:2][0:2];    // playerOneBoard --> 2D array rows=3,cols=3 each 8-bit wide
reg [1:0] a = 0; // A loop variable used to help initialize the board
reg [1:0] b = 0; // A loop variable used to help initialize the board.

reg [7:0] playerOneSHIPSBoard [0:2][0:2]; // Board containing the coordinates of their ship. 
reg [1:0] c = 0; // A loop variable used to help initialize the board
reg [1:0] d = 0; // A loop variable used to help initialize the board.
reg [2:0] numShipsP1 = 0;
reg [2:0] hitsP1 = 0;

// Player Two Board
reg [7:0] playerTwoBoard [0:2][0:2]; // 2D array rows = cols = 3, each 8 bit wide.
reg [1:0] e = 0; // A loop variable used to help initialize the board
reg [1:0] f = 0; // A loop variable used to help initialize the board

reg [7:0] playerTwoSHIPSBoard [0:2][0:2]; // Board containing the coordinates of their ship. 
reg [1:0] g = 0; // A loop variable used to help initialize the board
reg [1:0] h = 0; // A loop variable used to help initialize the board.
reg [2:0] numShipsP2 = 0;
reg [2:0] hitsP2 = 0;

reg [2:0] playerTurn = 1;

///////////////////////////////////////////////////
// LED DISPLAY VARIABLES
///////////////////////////////////////////////////

// Used for displaying LED's
// Turns Green by default, to indicate to user that they can hit that spot.
// Turns Blue if the user hits a ship.
// Turns Red if the player misses
reg [3:0] nineStates = 1; 
reg [3:0] nineStates2 = 1;



///////////////////////////////////////////////////
// Game Logic Variables
///////////////////////////////////////////////////

// As implied by name, determines the state of the game. 
// Asks user to input for row and column, and advances the state
reg [5:0] gameLogicState = 0;
reg [2:0] inputRow = 0; // Contains the user's input for row
reg [2:0] inputCol = 0; // Contains the user's input for column



// Clock variables (MULTIPLEXING)
reg [26:0] customCounter = 0; // Setting the counter to 0
reg customClk = 0; 

// one second clock
reg [26:0] oneSecondCounter = 0; // Setting the counter to 0
reg oneSecondClk = 0; 

//reg [1:0] turnOnBoards = 0; // not used anymore. Used for testing to turn on both boards.
reg [1:0] turnOnFirstBoard = 0;
reg [1:0] turnOnSecondBoard = 0;

///////////////////////////////
// Making a cusotm clock
///////////////////////////////

// Note
// 25000000 --> 1 second clk
// 12500000 --> 0.5 second clk
// 625000 ---> 0.25 seconds 
// 312500 ---> 0.125 seconds
// 156250 ---> 0.0625 seconds
// 78125 --->  0.03125 seconds
// 39062 ---> 0.015625 seconds
// 19531 ---> 0.0078125 seconds
// 9765 ----> 0.00390625 seconds
// 4882    -----> 0.00195312 seconds
// 2441 -----> 0.00097656 seconds

// USed for displaying the board at a rate which it stays on to the naked eye.
// OLD = 625000  
always@(posedge clk)
begin
if (customCounter == 10000) // change this to change the clk
    begin
        customClk <= ~customClk; // Toggle the clock
        customCounter <= 0; // RESET THE cOUNTER
    end
        
else
    begin
        customCounter = customCounter + 1; // Increment counter
    end
    

end

// Used for handling inputs from the user.
// Uses a slow clock to prevent any debouncing from the button
always@(posedge clk)
begin

if (oneSecondCounter == 25000000) // Dividing clock into 2 to create 1Hz clk. "Cycles 2 times a second. first one turns on, second one turns off.
    begin
        oneSecondClk <= ~oneSecondClk; // Toggle the clock
        oneSecondCounter <= 0; // RESET THE cOUNTER
    end
        
else
    begin
        oneSecondCounter = oneSecondCounter + 1; // Increment counter
    end
    



end








// Using the "Repeat statement" to simulate a "For" loop
/*
    1 2 3 
    4 5 6 
    7 8 9
    
    Number denotes the position. 
    For example: 
        position 1 has coordinates 0,0  
        position 5 has coordinates 1,1
        position 9 has coordinates 2,2
    
*/ 

// NOTE
//  a = row
//  b = col

// 1 = default color is green, for an available spot to hit.
// 2 = blue, to show that you have hit a ship.
// 3 = red, to show that you missed. 
// 4 == TURN OFF THE LED/SHIP. IT MEANS YOU SUNK THE SHIP.


///////////////////////////
     // Game Logic//
///////////////////////////
always @ (posedge oneSecondClk)
begin

case (gameLogicState) 

0: // INITIALIZE THE BOARD
begin

    

   // Creating Player One's Board
    repeat (4) begin
        repeat (4) begin
            playerOneBoard[a][b] = 1;
            b = b + 1;
        end
        a = a + 1;
    end
    
    // Creating Player One's SHIPS board, containing the coordiantes of their ships
    repeat (4) begin
        repeat (4) begin
            playerOneSHIPSBoard[c][d] = 1;
            d = d + 1;
        end
        c = c + 1;
    end
    
        // Creating Player Two's board, 
    repeat (4) begin
        repeat (4) begin
            playerTwoBoard[e][f] = 1;
            f = f + 1;
        end
        e = e + 1;
    end
    
        // Creating Player Two's SHIPS board, containing the coordiantes of their ships
    repeat (4) begin
        repeat (4) begin
            playerTwoSHIPSBoard[g][h] = 1;
            h = h + 1;
        end
        g = g + 1;
    end
    

    

    


    // TESTING, MANUALY PLACING SHIPS for Player One
    /*
    playerOneSHIPSBoard[0][0] = 2; // 1x1 ship
    playerOneSHIPSBoard[2][2] = 2; // 1x1 ship
    playerOneSHIPSBoard[1][1] = 2; // part 1 of 2x1 ship
    playerOneSHIPSBoard[1][2] = 2; // part 2 of 2x1 ship
    */
    
    /*
    // Testing, MANUALLY PLACING SHIPS for Player TWO
    playerTwoSHIPSBoard[0][0] = 2; // 1x1 ship
    playerTwoSHIPSBoard[1][0] = 2; // 1x1 ship
    playerTwoSHIPSBoard[2][0] = 2; // part 1 of 2x1 ship
    playerTwoSHIPSBoard[2][1] = 2; // part 2 of 2x1 ship
    */
    
   
    gameLogicState = gameLogicState + 1;
    //gameLogicState = 7; // fortesting
end

// Code for letting the player chose their ship coordinates.
// Due to time constraints, does not detect any overlaps within the ships

1: // Placing the Player One's first AND second 1x1 ship. Saving the ROW
begin
    ARDUINO_A4 = 1;
    ARDUINO_A5 = 0;
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0) // If user inputs the number one, save it into the ROW variable
        begin
            inputRow = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 
  

end

2: //Placing Player One's first AND second 1x1 ship. Saving the COLUMN
begin
    ARDUINO_A4 = 0;
    ARDUINO_A5 = 1;
// If this button is pressed, save the Column into the virtual board and commence logic. 
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0 ) // If user inputs the number one, save it into the COLUMN variable
        begin
            inputCol = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 

end


3: // Save the coordinates of the first ship into the board.
begin
    playerOneSHIPSBoard[inputRow][inputCol] = 2;
    numShipsP1 = numShipsP1 + 1;
    // The user has created two 1x1 ships, create the 2x1 ship and let the user pick its coordinates.
    if (numShipsP1 == 2) 
    begin
        gameLogicState = 4; // Do it again for the second 1x1 ship.
    end
    else
    begin
        gameLogicState = 1; // Go back and create the second 1x1 ship.
    end
end

4: // Create the 2x1 HORIZONTAL ship and let the user pick its coordinates. Choosing row
begin
    ARDUINO_A4 = 1;
    ARDUINO_A5 = 0;
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0) // If user inputs the number one, save it into the ROW variable
        begin
            inputRow = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 
  

end

5: // Create the 2x1 HORIZONTAL ship and let the user pick its coordinates. Choosing column
begin
    ARDUINO_A4 = 0;
    ARDUINO_A5 = 1;
// If this button is pressed, save the Column into the virtual board and commence logic. 
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0 ) // If user inputs the number one, save it into the COLUMN variable
        begin
            inputCol = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 

end
6: // Take the user input and place the 2x1 horizontal ship in such a way to prevent it from "exiting" the board
begin
    if(inputCol == 2)
    begin
        playerOneSHIPSBoard[inputRow][inputCol-1] = 2;
        playerOneSHIPSBoard[inputRow][inputCol] = 2;
    end
    
    else if (inputCol == 1 || inputCol == 0)
    begin
        playerOneSHIPSBoard[inputRow][inputCol] = 2;
        playerOneSHIPSBoard[inputRow][inputCol+1] = 2;
    end
    
    else
    begin
        // ERROR, DONT PLACE SHIP. 
    end
   // turnOnBoards = 1; // used for testing the first board to turn on the board(s)
    gameLogicState = 7;

end

7: // Placing the Player TWO's first AND second 1x1 ship. Saving the ROW
begin
    ARDUINO_A4 = 1;
    ARDUINO_A5 = 0;
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0) // If user inputs the number one, save it into the ROW variable
        begin
            inputRow = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 
  

end

8: //Placing Player TWO's first AND second 1x1 ship. Saving the COLUMN
begin
    ARDUINO_A4 = 0;
    ARDUINO_A5 = 1;
// If this button is pressed, save the Column into the virtual board and commence logic. 
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0 ) // If user inputs the number one, save it into the COLUMN variable
        begin
            inputCol = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 

end


9: // Save the coordinates of the first ship into the board. (Second player)
begin
    playerTwoSHIPSBoard[inputRow][inputCol] = 2;
    numShipsP2 = numShipsP2 + 1;
    // The user has created two 1x1 ships, create the 2x1 ship and let the user pick its coordinates.
    if (numShipsP2 == 2) 
    begin
        gameLogicState = 10; // Do it again for the second 1x1 ship.
    end
    else
    begin
        gameLogicState = 7; // Go back and create the second 1x1 ship.
    end
end

10: // Create the 2x1 HORIZONTAL ship and let the user pick its coordinates. Choosing row (Second player)
begin
    ARDUINO_A4 = 1;
    ARDUINO_A5 = 0;
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0) // If user inputs the number one, save it into the ROW variable
        begin
            inputRow = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 
  

end

11: // Create the 2x1 HORIZONTAL ship and let the user pick its coordinates. Choosing column (second player)
begin
    ARDUINO_A4 = 0;
    ARDUINO_A5 = 1;
// If this button is pressed, save the Column into the virtual board and commence logic. 
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0 ) // If user inputs the number one, save it into the COLUMN variable
        begin
            inputCol = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 

end

12: // Take the user input and place the 2x1 horizontal ship in such a way to prevent it from "exiting" the board (second player)
begin
    if(inputCol == 2)
    begin
        playerTwoSHIPSBoard[inputRow][inputCol-1] = 2;
        playerTwoSHIPSBoard[inputRow][inputCol] = 2;
    end
    
    else if (inputCol == 1 || inputCol == 0)
    begin
        playerTwoSHIPSBoard[inputRow][inputCol] = 2;
        playerTwoSHIPSBoard[inputRow][inputCol+1] = 2;
    end
    
    else
    begin
        // ERROR, DONT PLACE SHIP. 
    end
    turnOnFirstBoard = 1;
    turnOnSecondBoard = 1;
    gameLogicState = 13;

end

//ATTACK PHASE
///////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
///////////////////////////////////////////////////////
13: //Player's One's Turn, Ask for input for the ROW
begin
    ARDUINO_A4 <= 1;
    ARDUINO_A5 <= 0;
    // If this button is pressed, save the ROW into the virtual board and commence logic. 
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0) // If user inputs the number one, save it into the ROW variable
        begin
            inputRow = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the ROW variable
        begin
            inputRow = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 
   
end

    
14: //Player One's Turn, Ask for input for the Column
begin
    ARDUINO_A4 <= 0;
    ARDUINO_A5 <= 1;
// If this button is pressed, save the Column into the virtual board and commence logic. 
    if (ARDUINO_A0 == 0) 
    begin
        if(ARDUINO_A1 == 0 ) // If user inputs the number one, save it into the COLUMN variable
        begin
            inputCol = 0;
        end
        
        else if(ARDUINO_A2 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 1;
        end
        
        else if(ARDUINO_A3 == 0) // If user inputs the number two, save it into the COLUMN variable
        begin
            inputCol = 2;
        end
        
        gameLogicState = gameLogicState + 1; // Advance the game logic. 
   end 

end

15: // Take Player One's desired input, and save it unto the virtual board.
// Take Player One's desired input, and compute whether or not they hit a ship. 
begin

    // Player Two attack phase
    if (playerTurn == 1)
    begin
    
        // They hit a ship, turn that spot into blue. 
        if (playerOneSHIPSBoard[inputRow][inputCol] == 2 )
        begin
            playerOneBoard[inputRow][inputCol] = 2; 
            playerTurn = 2;
            hitsP2 = hitsP2 + 1;
        end
        
        // They didnt hit anything, mark that spot red.
        else 
        begin
            playerOneBoard[inputRow][inputCol] = 3;
            playerTurn = 2;
        end
        
    end // end of if statement
    
    
    // player One attack phase.
    else
    begin
     if (playerTwoSHIPSBoard[inputRow][inputCol] == 2 )
       begin
           playerTwoBoard[inputRow][inputCol] = 2;
           playerTurn = 1;
           hitsP1 = hitsP1 + 1;
       end
       
       // They didnt hit anything, mark that spot red.
       else 
       begin
           playerTwoBoard[inputRow][inputCol] = 3;
           playerTurn = 1;
       end
    end
    
    // One player's ships have all been destroyed, turn off that board and wait for user input to restart.
    if(hitsP2 == 4)
    begin
        turnOnFirstBoard = 0;
        gameLogicState = 21;
    end
    
    // One player's ships have all been destroyed, turn off that board and wait for user input to restart.
    else if ( hitsP1 == 4)
    begin
        turnOnSecondBoard = 0;
        gameLogicState = 21;
    end
    
    // There are still ships active, go back to attack phase.
    else
    begin
        gameLogicState = 13; // Go back to select a coordinate to attack.
    end
end


// End phase, wait for user input to restart game. Goes back to restart the boards and pick ships again.
16: 
begin
   ARDUINO_A4 <= 0;
   ARDUINO_A5 <= 0;
   if (ARDUINO_A1 == 0 && ARDUINO_A3 == 0 && ARDUINO_A2 == 0)
   begin
       // Restarting the loop variables to re-create the board. 
       a = 0;
       b = 0;
       c = 0;
       d = 0;
       e = 0;
       f = 0;
       g = 0;
       
       // Restarting hits
       hitsP1 = 0;
       hitsP2 = 0;
       
       //Reset player turn
       playerTurn = 1;
       
       // Hide the boards so they can place their ships
       turnOnFirstBoard = 0;
       turnOnSecondBoard = 0;

       

       
       // Restart the game.
       gameLogicState = 0;
   end
end



default:
begin
    // do nothing, there is an error. 
end



endcase

end // end of game logic


/////////////////
// Logic to demonstrate multiplexing of the LED's
/////////////////
always @ (posedge customClk)
begin

// Note to self
/*
Column1
Column2
Column3

RRR
ooo
www
321
*/
if (turnOnFirstBoard == 1)
begin


case (nineStates)
1:   // Turn on LED position 1, 1
begin
    if (playerOneBoard[0][0] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 1; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
                 
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)
        
        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
    end
    
    // turn it red
    else if ( playerOneBoard[0][0] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 1; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
    
    
    end
    
    // turn it blue
    else if ( playerOneBoard[0][0] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 1; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
     
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

2: //Turn on LED position 1,2
begin
    if (playerOneBoard[0][1] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 0; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 1; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
    end
    
    
    else if ( playerOneBoard[0][1] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 0; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 1; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
     
    end
    
    else if ( playerOneBoard[0][1] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 1; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

3: // Turn on LED position 1,3
begin
    if (playerOneBoard[0][2] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 0; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 1; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        
        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
    end
    
    else if ( playerOneBoard[0][2] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 0; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 1; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
     
    end
    
    else if ( playerOneBoard[0][2] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 1; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 0; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

4: // Turn on LED position 2,1
begin
    if (playerOneBoard[1][0] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 1; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        
        ARDUINO_IO3 = 1; // set the second row to gnd
        ARDUINO_IO4 = 0; // 
        ARDUINO_IO5 = 1;
    end
    
    else if ( playerOneBoard[1][0] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 1; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; 
        ARDUINO_IO4 = 0; 
        ARDUINO_IO5 = 1;
     
    end
    
    else if ( playerOneBoard[1][0] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 1; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)   
                     
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 0; // set the second row to gnd
        ARDUINO_IO5 = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

5: // Turn on LED position 2,2
begin
    if (playerOneBoard[1][1] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 0; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 1; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
              
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 0; // set the second row to gnd
        ARDUINO_IO5 = 1;
    end
    
    else if ( playerOneBoard[1][1] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 0; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 1; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 0; // 
        ARDUINO_IO5 = 1;
     
    end
    
    else if ( playerOneBoard[1][1] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 1; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 0; // set the second row to gnd
        ARDUINO_IO5 = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

6: // Turn on LED position 2,3
begin
    if (playerOneBoard[1][2] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 0; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 1; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 0; // set the second row to gnd
        ARDUINO_IO5 = 1;
    end
    
    else if ( playerOneBoard[1][2] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 0; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 1; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 0; // 
        ARDUINO_IO5 = 1;
     
    end
    
    else if ( playerOneBoard[1][2] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 1; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 0; // set the second row to gnd
        ARDUINO_IO5 = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

7: // Turn on LED position 3,1
begin
    if (playerOneBoard[2][0] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 1; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0; // set the third row to ground 
    end
    
    else if ( playerOneBoard[2][0] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 1; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0;
     
    end
    
    else if ( playerOneBoard[2][0] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 1; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                                
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0; // set the third row to ground 
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                                
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

8: // Turn on LED position 3,2
begin
    if (playerOneBoard[2][1] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 0; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 1; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0; // set the third row to ground 
    end
    
    else if ( playerOneBoard[2][1] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 0; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 1; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0;
     
    end
    
    else if ( playerOneBoard[2][1] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 1; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0; // set the third row to ground 
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

9: // Turn on LED position 3,3
begin
    if (playerOneBoard[2][2] == 1) // If default color, display default color
    begin
        ARDUINO_IO0 = 0; // turn ON col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 1; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn off col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


        
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0; // set the third row to ground 
    end
    
    else if ( playerOneBoard[2][2] == 2)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
    
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
        ARDUINO_IO6 = 0; // Turn ON col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 1; // turn off column 3 (BLUE)

        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0;
     
    end
    
    else if ( playerOneBoard[2][2] == 3)
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
        
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 1; // turn off column 3  (RED)
        
                        
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
        ARDUINO_IO3 = 1; // 
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 0; // set the third row to ground 
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        ARDUINO_IO0 = 0; // turn off col one     (GREEN)
        ARDUINO_IO1 = 0; // turn off column 2   (GREEN)
        ARDUINO_IO2 = 0; // turn off column 3   (GREEN)
           
        ARDUINO_IO9 = 0; // turn ON col one     (RED)
        ARDUINO_IO10 = 0; // turn off column 2  (RED)
        ARDUINO_IO11 = 0; // turn off column 3  (RED)
        
                                
        ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
        ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
        ARDUINO_IO8 = 0; // turn off column 3 (BLUE)
        

       
        ARDUINO_IO3 = 1; // set the first row to gnd
        ARDUINO_IO4 = 1; // 
        ARDUINO_IO5 = 1;
       
       
       end
end

default: // Turn OFFF ALL LEDS 
begin
    // Set all Columns to OFF and all ROWS to logic '1' to turn OFF all of the LED's.
    ARDUINO_IO0 = 0;   //green
    ARDUINO_IO1 = 0;   // green
    ARDUINO_IO2 = 0;    // green
    ARDUINO_IO3 = 1;   // gnd
    ARDUINO_IO4 = 1;  // gnd
    ARDUINO_IO5 = 1;   //gnd
    
    ARDUINO_IO9 = 0; // turn ON col one     (RED)
    ARDUINO_IO10 = 0; // turn off column 2  (RED)
    ARDUINO_IO11 = 0; // turn off column 3  (RED)
    
                        
    ARDUINO_IO6 = 0; // Turn OFF col one (BLUE)
    ARDUINO_IO7 = 0; // turn off column 2 (BLUE)
    ARDUINO_IO8 = 0; // turn off column 3 (BLUE)


    
end




endcase

end // end of turnOnBoards if statement

nineStates <= nineStates + 1;

if (nineStates >= 10 )
begin
    nineStates <= 1;
end

    
end // end of displaying logic for first board



//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////


always @ (posedge customClk)
begin

// Note to self
/*
Column1
Column2
Column3

RRR
ooo
www
321
*/
if (turnOnSecondBoard == 1)
begin


case (nineStates2)
1:   // Turn on LED position 1, 1
begin
    if (playerTwoBoard[0][0] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 1; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                 
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
        
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
    end
    
    // turn it red
    else if ( playerTwoBoard[0][0] == 3)
    begin
    
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
    
        
        
        PMOD1_D0_P = 1; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
    
      
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
    
    
    end
    
    // turn it blue
    else if ( playerTwoBoard[0][0] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
    
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 1; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
             
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
     
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
           
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
     
        PMOD2_D2_P = 1; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       
       end
end

2: //Turn on LED position 1,2
begin
    if (playerTwoBoard[0][1] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 1; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
       
    
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
        
    end
    
    
    else if ( playerTwoBoard[0][1] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)    
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 1; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

     
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
     
    end
    
    else if ( playerTwoBoard[0][1] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
       
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 1; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
         
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
           
        PMOD2_D2_P = 1; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       
       end
end

3: // Turn on LED position 1,3
begin
    if (playerTwoBoard[0][2] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 1; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED) 
         
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
      
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
    end
    
    else if ( playerTwoBoard[0][2] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
    
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 1; // turn off column 3 (BLUE)
       
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
     
    end
    
    else if ( playerTwoBoard[0][2] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 1; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
           
        PMOD2_D2_P = 0; // set the first row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)   
                
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

       PMOD2_D2_P = 1; // set the first row to gnd
       PMOD2_D2_N = 1; // 
       PMOD2_D3_P = 1;
       
       
       end
end

4: // Turn on LED position 2,1
begin
    if (playerTwoBoard[1][0] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 1; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
        
        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
    end
    
    else if ( playerTwoBoard[1][0] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
    
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 1; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
     
    end
    
    else if ( playerTwoBoard[1][0] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 1; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              


    
        PMOD2_D2_P = 1; // set the seclnd row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       
       
       end
end

5: // Turn on LED position 2,2
begin
    if (playerTwoBoard[1][1] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 1; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
    end
    
    else if ( playerTwoBoard[1][1] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 1; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the secnd row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
     
    end
    
    else if ( playerTwoBoard[1][1] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 1; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
    
        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; //
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       
       
       end
end

6: // Turn on LED position 2,3
begin
    if (playerTwoBoard[1][2] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 1; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        
        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
    end
    
    else if ( playerTwoBoard[1][2] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 1; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
     
    end
    
    else if ( playerTwoBoard[1][2] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 1; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
    
        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 0; // 
        PMOD2_D3_P = 1;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
              
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
            
        PMOD2_D2_P = 1; // set the second row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       
       
       end
end

7: // Turn on LED position 3,1
begin
    if (playerTwoBoard[2][0] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 1; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0; 
        
    end
    
    else if ( playerTwoBoard[2][0] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 1; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
    end
    
    else if ( playerTwoBoard[2][0] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 1; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                                
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
             
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                                
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
                     
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       end
end

8: // Turn on LED position 3,2
begin
    if (playerTwoBoard[2][1] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 1; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
        
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
    end
    
    else if ( playerTwoBoard[2][1] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 1; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
     
    end
    
    else if ( playerTwoBoard[2][1] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 1; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

    
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

       
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 1;
       
       
       end
end

9: // Turn on LED position 3,3
begin
    if (playerTwoBoard[2][2] == 1) // If default color, display default color
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 1; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
        
    end
    
    else if ( playerTwoBoard[2][2] == 2)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 1; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
     
    end
    
    else if ( playerTwoBoard[2][2] == 3)
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 1; // turn off column 3  (RED)
                        
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              

        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
    
    
    end
    
    else // ERROR, turn the led off for debugging
    begin
        PMOD1_D1_N = 0; // turn ON col one     (GREEN)
        PMOD1_D2_P = 0; // turn off column 2   (GREEN)
        PMOD1_D2_N = 0; // turn off column 3   (GREEN)
        
        PMOD1_D0_P = 0; // turn off col one     (RED)
        PMOD1_D0_N = 0; // turn off column 2  (RED)
        PMOD1_D1_P = 0; // turn off column 3  (RED)
                                
        PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
        PMOD2_D0_N = 0; // turn off column 2 (BLUE)
        PMOD2_D1_P = 0; // turn off column 3 (BLUE)
              
       
        PMOD2_D2_P = 1; // set the third row to gnd
        PMOD2_D2_N = 1; // 
        PMOD2_D3_P = 0;
       
       
       end
end

default: // Turn OFFF ALL LEDS 
begin
    // Set all Columns to OFF and all ROWS to logic '1' to turn OFF all of the LED's.
    PMOD1_D1_N = 0; // turn off col one     (GREEN)
    PMOD1_D2_P = 0; // turn off column 2   (GREEN)
    PMOD1_D2_N = 0; // turn off column 3   (GREEN)
    
    PMOD2_D2_P = 1; // gnd
    PMOD2_D2_N = 1; // gnd
    PMOD2_D3_P = 1; // gnd
    
    PMOD1_D0_P = 0; // turn off col one     (RED)
    PMOD1_D0_N = 0; // turn off column 2  (RED)
    PMOD1_D1_P = 0; // turn off column 3  (RED)
    
                        
    PMOD2_D0_P = 0; // Turn OFF col one (BLUE)
    PMOD2_D0_N = 0; // turn off column 2 (BLUE)
    PMOD2_D1_P = 0; // turn off column 3 (BLUE)
          


    
end




endcase

end

nineStates2 <= nineStates2 + 1;

if (nineStates2 >= 10 )
begin
    nineStates2 <= 1;
end

    
end // end of displaying logic

    



endmodule 







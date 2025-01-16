//module top (CLOCK_50, KEY, SW, LEDR, HEX0, HEX1,HEX2,HEX3);
//	input CLOCK_50;
//	input [3:0]KEY;
//	input [9:0] SW;
//	output [9:0] LEDR;
//	output [6:0] HEX0;
//	output [6:0] HEX1;
//	output [6:0] HEX2;
//	output [6:0] HEX3;
//	
//	wire [63:0]lastBoard;
//	assign lastBoard = 64'h 0001000100010001;
//	wire [63:0]newBoard;
//	//merge(CLOCK_50, KEY[0], KEY[1], SW[7:0], lastBoard, newBoard, LEDR[0]);
//	Hexadecimal_To_Seven_Segment (newBoard[15:12], HEX0);
//	Hexadecimal_To_Seven_Segment (newBoard[11:8], HEX1);
//	Hexadecimal_To_Seven_Segment (newBoard[7:4], HEX2);
//	Hexadecimal_To_Seven_Segment (newBoard[3:0], HEX3);
//endmodule




module merge (clk, enable, reset, key_pressed_signal, gameOver, lastBoard,  tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3, finish);
	 input enable, clk, reset;
    input [63:0]lastBoard;
	 input [3:0]key_pressed_signal; //3 --- W; 2 --- A; 1 --- S; 0 --- D
    output reg [3:0] tile_0_0;
	 output reg [3:0] tile_0_1;
	 output reg [3:0] tile_0_2;
	 output reg [3:0] tile_0_3;
	 output reg [3:0] tile_1_0;
    output reg [3:0] tile_1_1;
	 output reg [3:0] tile_1_2;
	 output reg [3:0] tile_1_3;
	 output reg [3:0] tile_2_0;
	 output reg [3:0] tile_2_1;
	 output reg [3:0] tile_2_2;
	 output reg [3:0] tile_2_3;
	 output reg [3:0] tile_3_0;
	 output reg [3:0] tile_3_1;
	 output reg [3:0] tile_3_2;
	 output reg [3:0] tile_3_3;
	 output reg gameOver;
    output reg finish;//board ready for generate new square
	 
	 reg [3:0] tile_values [0:15];
	 
	 //for states in FSM
    parameter upFstCol = 5'b 00001, upSecCol = 5'b 00010, upThdCol = 5'b 00011, upFthCol = 5'b 00100, 
					downFstCol = 5'b 00101, downSecCol = 5'b 00110, downThdCol = 5'b 00111, downFthCol = 5'b 01000, 
					leftFstCol = 5'b 01001, leftSecCol = 5'b 01010, leftThdCol = 5'b 01011, leftFthCol = 5'b 01100, 
					rightFstCol = 5'b 01101, rightSecCol = 5'b 01110, rightThdCol = 5'b 01111, rightFthCol = 5'b 10000,
					idle = 5'b 00000;
					
	 //for comparing keyIn
    //parameter uparrow = 8'h 1D, downarrow = 8'h 1B, rightarrow = 8'h 23, leftarrow = 8'h 1C, releaseKey = 8'h F0;
	 
	 //take a row/col from lastboard: from b3 to b0 is the direction of moving
	 reg [3:0] lb0, lb1, lb2, lb3;
	 
	 //updated row/col
	 wire [3:0] newb0, newb1, newb2, newb3;
	 reg [63:0]newBoard;
		
	 //store the updated cols/rows, once all four is updated (finishInternal = 1), pass to newboard
	 reg [63:0] updatingB;
	 reg [1:0] finishInternal;
	

    reg [4:0] y, Y;   //y is current, Y is future states
	 reg [4:0] x, X;	 //x is current, X is future states

    always @ (posedge clk or posedge key_pressed_signal[3] or posedge key_pressed_signal[2] or posedge key_pressed_signal[1] or posedge key_pressed_signal[0] )
    //always @ (posedge clk or negedge reset)
	 begin
        case(y)
        idle:
        begin
            if (key_pressed_signal[3])begin
					Y <= upFstCol;
					//finish <= 0;
				end
            else if (key_pressed_signal[1])begin
					Y <= downFstCol;
					//finish <= 0; 
				end
            else if (key_pressed_signal[2]) begin
					Y <= leftFstCol;
					//finish <= 0;
				end
            else if (key_pressed_signal[0]) begin
					Y <= rightFstCol;
					//finish <= 0;
				end
            else Y <= y;
		  lb0 = 4'b0000; lb1 = 4'b0000; lb2 = 4'b0000; lb3 = 4'b0000;
        end
        upFstCol:
        begin
				lb0 <= lastBoard [63:60];
				lb1 <= lastBoard [47:44];
				lb2 <= lastBoard [31:28];
				lb3 <= lastBoard [15:12];
				Y <= upSecCol;
        end
		  upSecCol:
        begin
				lb0 <= lastBoard [59:56];
				lb1 <= lastBoard [43:40];
				lb2 <= lastBoard [27:24];
				lb3 <= lastBoard [11:8];
				Y <= upThdCol;
        end
		  upThdCol:
        begin
				lb0 <= lastBoard [55:52];
				lb1 <= lastBoard [39:36];
				lb2 <= lastBoard [23:20];
				lb3 <= lastBoard [7:4];
				Y <= upFthCol;
        end
		  upFthCol:
        begin
				lb0 <= lastBoard [51:48];
				lb1 <= lastBoard [35:32];
				lb2 <= lastBoard [19:16];
				lb3 <= lastBoard [3:0];
				Y <= idle;
        end
        
		  downFstCol:
        begin
				lb3 <= lastBoard [63:60];
				lb2 <= lastBoard [47:44];
				lb1 <= lastBoard [31:28];
				lb0 <= lastBoard [15:12];
				Y <= downSecCol;
        end
		  downSecCol:
        begin
				lb3 <= lastBoard [59:56];
				lb2 <= lastBoard [43:40];
				lb1 <= lastBoard [27:24];
				lb0 <= lastBoard [11:8];
				Y <= downThdCol;
        end
		  downThdCol:
        begin
				lb3 <= lastBoard [55:52];
				lb2 <= lastBoard [39:36];
				lb1 <= lastBoard [23:20];
				lb0 <= lastBoard [7:4];
				Y <= downFthCol;
        end
		  downFthCol:
        begin
				lb3 <= lastBoard [51:48];
				lb2 <= lastBoard [35:32];
				lb1 <= lastBoard [19:16];
				lb0 <= lastBoard [3:0];
				Y <= idle;
        end
		  
		  leftFstCol:
        begin
				lb0 <= lastBoard [63:60];
				lb1 <= lastBoard [59:56];
				lb2 <= lastBoard [55:52];
				lb3 <= lastBoard [51:48];
				Y <= leftSecCol;
        end
		  leftSecCol:
        begin
				lb0 <= lastBoard [47:44];
				lb1 <= lastBoard [43:40];
				lb2 <= lastBoard [39:36];
				lb3 <= lastBoard [35:32];
				Y <= leftThdCol;
        end
		  leftThdCol:
        begin
				lb0 <= lastBoard [31:28];
				lb1 <= lastBoard [27:24];
				lb2 <= lastBoard [23:20];
				lb3 <= lastBoard [19:16];
				Y <= leftFthCol;
        end
		  leftFthCol:
        begin
				lb0 <= lastBoard [15:12];
				lb1 <= lastBoard [11:8];
				lb2 <= lastBoard [7:4];
				lb3 <= lastBoard [3:0];
				Y <= idle;
        end
		  
		  rightFstCol:
        begin
				lb3 <= lastBoard [63:60];
				lb2 <= lastBoard [59:56];
				lb1 <= lastBoard [55:52];
				lb0 <= lastBoard [51:48];
				Y <= rightSecCol;
        end
		  rightSecCol:
        begin
				lb3 <= lastBoard [47:44];
				lb2 <= lastBoard [43:40];
				lb1 <= lastBoard [39:36];
				lb0 <= lastBoard [35:32];
				Y <= rightThdCol;
        end
		  rightThdCol:
        begin
				lb3 <= lastBoard [31:28];
				lb2 <= lastBoard [27:24];
				lb1 <= lastBoard [23:20];
				lb0 <= lastBoard [19:16];
				
				Y <= rightFthCol;
        end
		  rightFthCol:
        begin
				lb3 <= lastBoard [15:12];
				lb2 <= lastBoard [11:8];
				lb1 <= lastBoard [7:4];
				lb0 <= lastBoard [3:0];
				
				Y <= idle;
        end
		  default:
		  begin
			lb0 = 4'b0000; lb1 = 4'b0000; lb2 = 4'b0000; lb3 = 4'b0000;
				Y <= idle;
		  end
        endcase
    end
	 always @ (posedge clk or negedge reset) begin
    if (!reset) begin
        y <= idle;
        //finish <= 0;
    end else if (enable) begin
        if (y == idle && (key_pressed_signal[3] == 1 || key_pressed_signal[2] == 1 || key_pressed_signal[1] == 1 || key_pressed_signal[0] == 1)) begin
            // Start FSM only on valid key press
            y <= Y;
				resetMove = 0;
        end else if (finishInternal) begin
            // Transition to idle only after updatingB is fully processed
            y <= idle;
        end else begin
            y <= Y;
        end
    end
end

	 wire moveDone;
	 reg resetMove;
	 
	 move m1 (clk, reset, lb0, lb1, lb2, lb3, newb0, newb1, newb2, newb3, moveDone);
	 
	 //update updatingB row/col by row/col
    always @ (posedge clk or posedge moveDone)begin
        case(x)
		  
        idle:
        begin
		  finishInternal <= 0;
            if (y == upFstCol) begin
					X <= upFstCol;
					finishInternal <= 0;
            end else if (y == upSecCol) begin 
					X <= upSecCol;
					finishInternal <= 0;
            end else if (y == upThdCol) begin 
					X <= upThdCol;
					finishInternal <= 0;
            end else if (y == upFthCol) begin 
					X <= upFthCol;
					finishInternal <= 0;
            end else if (y == downFstCol) begin 
					X <= downFstCol;
					finishInternal <= 0;
            end else if (y == downSecCol) begin 
					X <= downSecCol;
					finishInternal <= 0;
            end else if (y == downThdCol) begin 
					X <= downThdCol;
					finishInternal <= 0;
            end else if (y == downFthCol) begin 
					X <= downFthCol;
					finishInternal <= 0;
            end else if (y == leftFstCol) begin 
					X <= leftFstCol;
					finishInternal <= 0;
            end else if (y == leftSecCol) begin 
					X <= leftSecCol;
					finishInternal <= 0;
					resetMove <= 0;
            end else if (y == leftThdCol) begin 
					X <= leftThdCol;
					finishInternal <= 0;
            end else if (y == leftFthCol) begin 
					X <= leftFthCol;
					finishInternal <= 0;
					resetMove <= 0;
            end else if (y == rightFstCol) begin 
					X <= rightFstCol;
					finishInternal <= 0;
            end else if (y == rightSecCol) begin 
					X <= rightSecCol;
					finishInternal <= 0;
            end else if (y == rightThdCol) begin 
					X <= rightThdCol;
					finishInternal <= 0;
            end else if (y == rightFthCol) begin 
					X <= rightFthCol;
					finishInternal <= 0;
            end else if (!reset) begin
					updatingB <= 64'b 0;
					finishInternal <= 0;
					resetMove <= 0;
					X <= x;
				end
				updatingB <= 16'h 0000000000000000;
        end
		  
        upFstCol:
        begin
				updatingB [63:60] <= newb0;
				updatingB [47:44] <= newb1;
				updatingB [31:28] <= newb2;
				updatingB [15:12] <= newb3;
				resetMove = 1;
				X <= upSecCol;
        end
		  upSecCol:
        begin
				updatingB [59:56] <= newb0;
				updatingB [43:40] <= newb1;
				updatingB [27:24] <= newb2;
				updatingB [11:8] <= newb3;
				resetMove = 1;
				X <= upThdCol;
        end
		  upThdCol:
        begin
				updatingB [55:52] <= newb0;
				updatingB [39:36] <= newb1;
				updatingB [23:20] <= newb2;
				updatingB [7:4] <= newb3;
				resetMove = 1;
				X <= upFthCol;
        end
		  upFthCol:
        begin
				updatingB [51:48] <= newb0;
				updatingB [35:32] <= newb1;
				updatingB [19:16] <= newb2;
				updatingB [3:0] <= newb3;
				resetMove = 1;
				finishInternal <= finishInternal + 1'b 1;
				X <= idle;
        end
        
		  downFstCol:
        begin
				updatingB [63:60] <= newb3;
				updatingB [47:44] <= newb2;
				updatingB [31:28] <= newb1;
				updatingB [15:12] <= newb0;
				resetMove = 1;
				X <= downSecCol;
        end
		  downSecCol:
        begin
				updatingB [59:56] <= newb3;
				updatingB [43:40] <= newb2;
				updatingB [27:24] <= newb1;
				updatingB [11:8] <= newb0;
				resetMove = 1;
				X <= downThdCol;
        end
		  downThdCol:
        begin
				updatingB [55:52] <= newb3;
				updatingB [39:36] <= newb2;
				updatingB [23:20] <= newb1;
				updatingB [7:4] <= newb0;
				resetMove = 1;
				X <= downFthCol;
        end
		  downFthCol:
        begin
				updatingB [51:48] <= newb3;
				updatingB [35:32] <= newb2;
				updatingB [19:16] <= newb1;
				updatingB [3:0] <= newb0;
				resetMove = 1;
				finishInternal <= finishInternal + 1'b 1;
				X <= idle;
        end
		  
		  leftFstCol:
        begin
				updatingB [63:60] <= newb0;
				updatingB [59:56] <= newb1;
				updatingB [55:52] <= newb2;
				updatingB [51:48] <= newb3;
				resetMove = 1;
				X <= leftSecCol;
        end
		  leftSecCol:
        begin
				updatingB [47:44] <= newb0;
				updatingB [43:40] <= newb1;
				updatingB [39:36] <= newb2;
				updatingB [35:32] <= newb3;
				resetMove = 1;
				X <= leftThdCol;
        end
		  leftThdCol:
        begin
				updatingB [31:28] <= newb0;
				updatingB [27:24] <= newb1;
				updatingB [23:20] <= newb2;
				updatingB [19:16] <= newb3;
				resetMove = 1;
				X <= leftFthCol;
        end
		  leftFthCol:
        begin
				updatingB [15:12] <= newb0;
				updatingB [11:8] <= newb1;
				updatingB [7:4] <= newb2;
				updatingB [3:0] <= newb3;
				resetMove = 1;
				finishInternal <= finishInternal + 1'b 1;
				X <= idle;
        end
		  
		  rightFstCol:
        begin
				updatingB [63:60] <= newb3;
				updatingB [59:56] <= newb2;
				updatingB [55:52] <= newb1;
				updatingB [51:48] <= newb0;
				resetMove = 1;
				X <= rightSecCol;
        end
		  rightSecCol:
        begin
				updatingB [47:44] <= newb3;
				updatingB [43:40] <= newb2;
				updatingB [39:36] <= newb1;
				updatingB [35:32] <= newb0;
				resetMove = 1;
				X <= rightThdCol;
        end
		  rightThdCol:
        begin
				updatingB [31:28] <= newb3;
				updatingB [27:24] <= newb2;
				updatingB [23:20] <= newb1;
				updatingB [19:16] <= newb0;
				resetMove = 1;
				X <= rightFthCol;
        end
		  rightFthCol:
        begin
				updatingB [15:12] <= newb3;
				updatingB [11:8] <= newb2;
				updatingB [7:4] <= newb1;
				updatingB [3:0] <= newb0;
				resetMove = 1;
				finishInternal <= finishInternal + 1'b 1;
				X <= idle;
        end
		  default:
		  begin
				updatingB <= 16'h 0000000000000000;
				X <= idle;
		  end
        endcase
 end 

	always @(posedge clk or negedge reset) begin
        if (!reset) begin
            x <= idle;
//            finishInternal <= 0;
//            updatingB <= 64'b0;
        end else if (enable) begin
            x <= X;
        end
    end
	//always @(posedge clk or negedge reset or posedge finishInternal or negedge key_pressed_signal[3] or negedge key_pressed_signal[2] or negedge key_pressed_signal[1] or negedge key_pressed_signal[0]) begin
	//always @ (posedge clk, negedge reset) begin
	always @ (clk, reset, finishInternal, y, key_pressed_signal[3:0]) begin
	 if (!reset) begin
        newBoard <= 64'b0;
        finish <= 0;
    end else if (enable && finishInternal == 2'b 01) begin
        // Update newBoard only if finishInternal is asserted
        newBoard <= updatingB;
        finish <= 1;
    end else if (y == idle || key_pressed_signal[3] == 0 || key_pressed_signal[2] == 0 || key_pressed_signal[1] == 0 || key_pressed_signal[0] == 0) begin
        // Do not update newBoard when idle
        finish <= 0;
    end else begin
        finish <= 0;
    end
end

integer i = 0;
integer zeroCount = 0;
integer j = 0;
reg [3:0] sixteenCount = 4'b0000;
reg [3:0] tenCount = 4'b0000;
reg assigned;


always@(posedge clk)
begin
  //random number generation
  sixteenCount <= sixteenCount + 1'b1;
  if(tenCount == 4'd9)
		tenCount <= 4'b0000;
  else
		tenCount <= tenCount + 1'b1;
		
end


always@(posedge finish or negedge reset)
begin
  if(reset == 0)
  begin
	  tile_values[0] <= 4'b0000;
	  tile_values[1] <= 4'b0000;
	  tile_values[2] <= 4'b0000;
	  tile_values[3] <= 4'b0000;
	  tile_values[4] <= 4'b0000;
	  tile_values[5] <= 4'b0001;
	  tile_values[6] <= 4'b0000;
	  tile_values[7] <= 4'b0000;
	  tile_values[8] <= 4'b0000;
	  tile_values[9] <= 4'b0000;
	  tile_values[10] <= 4'b0001;
	  tile_values[11] <= 4'b0000;
	  tile_values[12] <= 4'b0000;
	  tile_values[13] <= 4'b0000;
	  tile_values[14] <= 4'b0000;
	  tile_values[15] <= 4'b0000;
	  gameOver <= 0;
  end
  else
  begin
	  tile_values[0] <= newBoard[63:60];
	  tile_values[1] <= newBoard[59:56];
	  tile_values[2] <= newBoard[55:52];
	  tile_values[3] <= newBoard[51:48]; 
	  tile_values[4] <= newBoard[47:44];
	  tile_values[5] <= newBoard[43:40]; 
	  tile_values[6] <= newBoard[39:36];
	  tile_values[7] <= newBoard[35:32];
	  tile_values[8] <= newBoard[31:28];
	  tile_values[9] <= newBoard[27:24];
	  tile_values[10] <= newBoard[23:20];
	  tile_values[11] <= newBoard[19:16];
	  tile_values[12] <= newBoard[15:12];
	  tile_values[13] <= newBoard[11:8]; 
	  tile_values[14] <= newBoard[7:4]; 
	  tile_values[15] <= newBoard[3:0]; 
	  zeroCount = 0;
	  for(i = 0; i < 16; i = i + 1)
	  begin
			if(tile_values[i] == 4'b0000)
			begin
				 zeroCount = zeroCount + 1;
			end
	  end
	  if(zeroCount == 0)
			//no possible generations therefore game is over
			gameOver <= 1;
	  else //at least one empty block
	  begin
			gameOver <= 0;
			assigned = 0;
			j = 0;
			for(i = 0; i < 16; i = i + 1)
			begin
				 if(tile_values[i] == 4'b0000 && assigned == 1'b0)
				 begin
					  if(j == (sixteenCount%zeroCount))
					  begin
							if(tenCount == 4'd9) begin
								tile_values[i] <= 4'b0010;
								assigned = 1'b1;
							end
							else begin
								tile_values[i] <= 4'b0001;
								assigned = 1'b1;
							end
					  end
					  j = j + 1;
				 end
			end
	  end
 end
end

always @(*)
begin
  tile_0_0 = tile_values[0];
  tile_0_1 = tile_values[1];
  tile_0_2 = tile_values[2];
  tile_0_3 = tile_values[3];
  tile_1_0 = tile_values[4];
  tile_1_1 = tile_values[5];
  tile_1_2 = tile_values[6];
  tile_1_3 = tile_values[7];
  tile_2_0 = tile_values[8];
  tile_2_1 = tile_values[9];
  tile_2_2 = tile_values[10];
  tile_2_3 = tile_values[11];
  tile_3_0 = tile_values[12];
  tile_3_1 = tile_values[13];
  tile_3_2 = tile_values[14];
  tile_3_3 = tile_values[15];
end

endmodule

//up: check a column of the board from top to bottom b0, b1, b2, b3 movement from b3 to b0
//down: check a column of the board from bottom to top b3, b2, b1, b0 movement from b3 to b0
//left: check a row of the board from left to right b0, b1, b2, b3 movement from b3 to b0
//right: check a row of the board from right to left b3, b2, b1, b0 movement from b3 to b0
module move (clk, reset, b0, b1, b2, b3, newb0, newb1, newb2, newb3, moveDone);
	input clk, reset;
	input [3:0]b0, b1, b2, b3;
	output reg [3:0]newb0, newb1, newb2, newb3;
	output reg moveDone;
	
 //Empty Tile: 4'b0000
 //2 Tile: 4'b0001
 //4 Tile: 4'b0010
 //8 Tile: 4'b0011
 //16 Tile: 4'b0100
 //32 Tile: 4'b0101
 //64 Tile: 4'b0110
 //128 Tile: 4'b0111
 //256 Tile: 4'b1000
 //512 Tile: 4'b1001
 //1024 Tile: 4'b1010
 //2048 Tile: 4'b1011
 //Defeat Tile: 4'b1100
	
	parameter zero = 4'b 0000, one = 4'b0001, two = 4'b0010, 
				three = 4'b0011, four = 4'b0100, five = 4'b0101, six = 4'b0110, 
				seven = 4'b0111, eight = 4'b1000, nine = 4'b1001, ten = 4'b1010, 
				eleven = 4'b1011;
	
	always@(posedge clk or negedge reset)
	begin
		if(reset == 0) begin
			newb0 <= zero;
			newb1 <= zero;
			newb2 <= zero;
			newb3 <= zero;
			moveDone <= 0;
		//no number
		end else begin 
		
			moveDone <= 0;
		
		
		if((b0 == zero) && (b1 == zero) && (b2 == zero) && (b3 == zero))begin
			newb0 <= zero;
			newb1 <= zero;
			newb2 <= zero;
			newb3 <= zero;
			moveDone <= 1;
		//one number
		end else if((b0 != zero) && (b1 == zero) && (b2 == zero) && (b3 == zero))begin
			newb0 <= b0;
			newb1 <= zero;
			newb2 <= zero;
			newb3 <= zero;
			moveDone <= 1;
		end else if((b0 == zero) && (b1 != zero) && (b2 == zero) && (b3 == zero))begin
			newb0 <= b1;
			newb1 <= zero;
			newb2 <= zero;
			newb3 <= zero;
			moveDone <= 1;
		end else if((b0 == zero) && (b1 == zero) && (b2 != zero) && (b3 == zero))begin
			newb0 <= b2;
			newb1 <= zero;
			newb2 <= zero;
			newb3 <= zero;
			moveDone <= 1;
		end else if((b0 == zero) && (b1 == zero) && (b2 == zero) && (b3 != zero))begin
			newb0 <= b3;
			newb1 <= zero;
			newb2 <= zero;
			newb3 <= zero;
			moveDone <= 1;
		//two numbers
		end else if((b0 != zero) && (b1 != zero) && (b2 == zero) && (b3 == zero))begin
				if(b0 == b1)begin
					newb0 <= b0 + 1;
					newb1 <= zero;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b1;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end
		end else if((b0 != zero) && (b1 == zero) && (b2 != zero) && (b3 == zero))begin
				if(b0 == b2)begin
					newb0 <= b0 + 1;
					newb1 <= zero;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b2;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end
				
		end else if((b0 != zero) && (b1 == zero) && (b2 == zero) && (b3 != zero))begin
				if(b0 == b3)begin
					newb0 <= b0 + 1;
					newb1 <= zero;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b3;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end
				
		end else if((b0 == zero) && (b1 != zero) && (b2 != zero) && (b3 == zero))begin
				if(b1 == b2)begin
					newb0 <= b1 + 1;
					newb1 <= zero;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b1;
					newb1 <= b2;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end
				
		end else if((b0 == zero) && (b1 != zero) && (b2 == zero) && (b3 != zero))begin
				if(b1 == b3)begin
					newb0 <= b1 + 1;
					newb1 <= zero;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b1;
					newb1 <= b3;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end
				
		end else if((b0 == zero) && (b1 == zero) && (b2 != zero) && (b3 != zero))begin
				if(b2 == b3)begin
					newb0 <= b2 + 1;
					newb1 <= zero;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b2;
					newb1 <= b3;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end
		//three numbers
		end else if((b0 != zero) && (b1 != zero) && (b2 != zero) && (b3 == zero))begin
				if(b0 == b1)begin
					newb0 <= b0 + 1;
					newb1 <= b2;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else if(b1 == b2)begin
					newb0 <= b0;
					newb1 <= b1 + 1;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b1;
					newb2 <= b2;
					newb3 <= zero;
					moveDone <= 1;
				end
		 
		end else if((b0 != zero) && (b1 != zero) && (b2 == zero) && (b3 != zero))begin
				if(b0 == b1)begin
					newb0 <= b0 + 1;
					newb1 <= b3;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else if(b1 == b3)begin
					newb0 <= b0;
					newb1 <= b1 + 1;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b1;
					newb2 <= b3;
					newb3 <= zero;
					moveDone <= 1;
				end
		end else if((b0 != zero) && (b1 == zero) && (b2 != zero) && (b3 != zero))begin
				if(b0 == b2)begin
					newb0 <= b0 + 1;
					newb1 <= b3;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else if(b2 == b3)begin
					newb0 <= b0;
					newb1 <= b2 + 1;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b2;
					newb2 <= b3;
					newb3 <= zero;
					moveDone <= 1;
				end
		end else if((b0 == zero) && (b1 != zero) && (b2 != zero) && (b3 != zero))begin
				if(b1 == b2)begin
					newb0 <= b1 + 1;
					newb1 <= b3;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else if(b2 == b3)begin
					newb0 <= b1;
					newb1 <= b2 + 1;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b1;
					newb1 <= b2;
					newb2 <= b3;
					newb3 <= zero;
					moveDone <= 1;
				end
		//four numbers
		end else if((b0 != zero) && (b1 != zero) && (b2 != zero) && (b3 != zero))begin
				
				//first two are the same, last two are the same
				if(b0 == b1 && b2 == b3)begin
					newb0 <= b0 + 1;
					newb1 <= b2 + 1;
					newb2 <= zero;
					newb3 <= zero;
					moveDone <= 1;
				//only two numbers are the same
				end else if(b0 == b1)begin
					newb0 <= b0 + 1;
					newb1 <= b2;
					newb2 <= b3;
					newb3 <= zero;
					moveDone <= 1;
				end else if(b1 == b2)begin
					newb0 <= b0;
					newb1 <= b1 + 1;
					newb2 <= b3;
					newb3 <= zero;
					moveDone <= 1;
				end else if(b2 == b3)begin
					newb0 <= b0;
					newb1 <= b1;
					newb2 <= b2 + 1;
					newb3 <= zero;
					moveDone <= 1;
				end else begin
					newb0 <= b0;
					newb1 <= b1;
					newb2 <= b2;
					newb3 <= b3;
					moveDone <= 1;
				end	
		end
		end
	end
endmodule

module vga2048(CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_G, VGA_R, VGA_B, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	 input CLOCK_50;       // 50 MHz clock input
    input [3:0] KEY;       // Reset signal
    output [7:0] VGA_R;    // VGA Red output
    output [7:0] VGA_G;    // VGA Green output
    output [7:0] VGA_B;    // VGA Blue output
    output VGA_HS;         // VGA horizontal sync
    output VGA_VS;          // VGA vertical sync
	 output VGA_BLANK_N;
	 output VGA_SYNC_N;
    output VGA_CLK;   
	 output [9:0] LEDR;
	 reg [8:0] VGA_X;
	 wire [2:0] VGA_COLOR;
	 reg [7:0] VGA_Y;
	 inout PS2_CLK;
	 inout PS2_DAT;
	 output [6:0] HEX0;
	 output [6:0] HEX1;
	 output [6:0] HEX2;
	 output [6:0] HEX3;
	 output [6:0] HEX4;
	 output [6:0] HEX5;
          


    // Game Board - Stores the current `tile_value` of each 4x4 grid cell 
	 wire [3:0] tile_0_0;
	 wire [3:0] tile_0_1;
	 wire [3:0] tile_0_2;
	 wire [3:0] tile_0_3;
	 wire [3:0] tile_1_0;
	 wire [3:0] tile_1_1;
	 wire [3:0] tile_1_2;
	 wire [3:0] tile_1_3;
	 wire [3:0] tile_2_0;
	 wire [3:0] tile_2_1;
	 wire [3:0] tile_2_2;
	 wire [3:0] tile_2_3;
	 wire [3:0] tile_3_0;
	 wire [3:0] tile_3_1;
	 wire [3:0] tile_3_2;
	 wire [3:0] tile_3_3;
	 
	 //keyboard input
	 wire [3:0]key_pressed_signal;
	 wire [7:0] keyIn;
	 
	 localparam SCREEN_WIDTH = 240;
    localparam SCREEN_HEIGHT = 200;
	 
	 reg halfcount;
	 always @(posedge CLOCK_50 or negedge KEY[0])
	 begin
		if (KEY[0] == 0)
			halfcount <= 0;
		else
			halfcount <= halfcount + 1;
	 end
	 
	 // Increment x and y coordinates on each pixel clock
    always @(posedge halfcount or negedge KEY[0]) begin
        if (KEY[0] == 0) begin
            VGA_X <= 80;
            VGA_Y <= 40;
        end else begin
            if (VGA_X < SCREEN_WIDTH - 1) begin
                VGA_X <= VGA_X + 1;
            end else begin
                VGA_X <= 80;
                if (VGA_Y < SCREEN_HEIGHT - 1) begin
                    VGA_Y <= VGA_Y + 1;
                end else begin
                    VGA_Y <= 40;  // Reset to the top left for a new frame
                end
            end
        end
    end
	 
	 
	 PS2_read read (CLOCK_50, KEY[0], PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, keyIn, key_pressed_signal);
	 
	 vga_adapter VGA (
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(VGA_COLOR),
			.x(VGA_X),
			.y(VGA_Y),
			.plot(1),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK_N(VGA_BLANK_N),
			.VGA_SYNC_N(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	game_board board (LEDR[2:0], CLOCK_50, KEY[0], 1, key_pressed_signal, tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3);
	
	
	tile_selector selector(VGA_X, VGA_Y, tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3, VGA_COLOR, VGA_CLK);


endmodule

module game_board (LEDR, clk, reset, enable, key_pressed_signal, tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3);
	
	 output [2:0] LEDR;
	 input clk;
    input reset;
	 input enable;
	 input [3:0] key_pressed_signal;
    output [3:0] tile_0_0;
	 output [3:0] tile_0_1;
	 output [3:0] tile_0_2;
	 output [3:0] tile_0_3;
	 output [3:0] tile_1_0;
	 output [3:0] tile_1_1;
	 output [3:0] tile_1_2;
	 output [3:0] tile_1_3;
	 output [3:0] tile_2_0;
	 output [3:0] tile_2_1;
	 output [3:0] tile_2_2;
	 output [3:0] tile_2_3;
	 output [3:0] tile_3_0;
	 output [3:0] tile_3_1;
	 output [3:0] tile_3_2;
	 output [3:0] tile_3_3;
	 
	 
	 wire gameOver;
	 wire finish;
	 assign LEDR[0] = gameOver;
	 assign LEDR[1] = 0;
	 assign LEDR[2] = 0;
	 
	 wire [63:0]lastBoard;
	 assign lastBoard = {tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3};
	 merge merg(clk, enable, reset, key_pressed_signal, gameOver, lastBoard, tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3, finish);
	 //random  rand(reset, clk, gameOver, enable, tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3);

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

	 /*reg [25:0] slowcount;
	 always @(posedge clk or negedge reset)
	 begin
		if (reset == 0)
			slowcount <= 0;
		else
			slowcount <= slowcount + 1;
	 end
	 wire sec = slowcount[25];
	
	 reg [2:0] state;
	 always @(posedge sec or negedge reset)
	 begin
		if (reset == 0)
			state <= 0;
		else
			state <= state + 1;
	 end
	 
	 assign LEDR[1] = 0;
	 assign LEDR[2] = 0;
	 
	 always @(*) 
	 begin
		case (state)
			3'd0: begin
			  tile_0_0 = 4'b0000;
			  tile_0_1 = 4'b0000;
			  tile_0_2 = 4'b0000;
			  tile_0_3 = 4'b0000;

			  tile_1_0 = 4'b0000;
			  tile_1_1 = 4'b0000;
			  tile_1_2 = 4'b0000;
			  tile_1_3 = 4'b0000; 

		
			  tile_2_0 = 4'b0000;
			  tile_2_1 = 4'b0000;
			  tile_2_2 = 4'b0000;
			  tile_2_3 = 4'b0000;

			  tile_3_0 = 4'b0000;
			  tile_3_1 = 4'b0000;
			  tile_3_2 = 4'b0000;
			  tile_3_3 = 4'b0000;
			end
			3'd1: begin
			  tile_0_0 = 4'b0101;
			  tile_0_1 = 4'b0000;
			  tile_0_2 = 4'b0101;
			  tile_0_3 = 4'b0101;

			  tile_1_0 = 4'b0110;
			  tile_1_1 = 4'b0111;
			  tile_1_2 = 4'b0111;
			  tile_1_3 = 4'b0110; 

		
			  tile_2_0 = 4'b0111;
			  tile_2_1 = 4'b1010;
			  tile_2_2 = 4'b1001;
			  tile_2_3 = 4'b0111;

			  tile_3_0 = 4'b1001;
			  tile_3_1 = 4'b1011;
			  tile_3_2 = 4'b0110;
			  tile_3_3 = 4'b1010;
			end
			3'd2: begin
			  tile_0_0 = 4'b0101;
			  tile_0_1 = 4'b0000;
			  tile_0_2 = 4'b0101;
			  tile_0_3 = 4'b0110;

			  tile_1_0 = 4'b0000;
			  tile_1_1 = 4'b0110;
			  tile_1_2 = 4'b1000;
			  tile_1_3 = 4'b0110; 

		
			  tile_2_0 = 4'b0111;
			  tile_2_1 = 4'b1010;
			  tile_2_2 = 4'b1001;
			  tile_2_3 = 4'b0111;

			  tile_3_0 = 4'b1001;
			  tile_3_1 = 4'b1011;
			  tile_3_2 = 4'b0110;
			  tile_3_3 = 4'b1010;
			end
			3'd3: begin
			  tile_0_0 = 4'b0101;
			  tile_0_1 = 4'b0110;
			  tile_0_2 = 4'b0101;
			  tile_0_3 = 4'b0111;

			  tile_1_0 = 4'b0111;
			  tile_1_1 = 4'b1010;
			  tile_1_2 = 4'b1000;
			  tile_1_3 = 4'b0111; 

		
			  tile_2_0 = 4'b1001;
			  tile_2_1 = 4'b1011;
			  tile_2_2 = 4'b1001;
			  tile_2_3 = 4'b1010;

			  tile_3_0 = 4'b0101;
			  tile_3_1 = 4'b0000;
			  tile_3_2 = 4'b0110;
			  tile_3_3 = 4'b0000;
			end
			3'd4: begin
			  tile_0_0 = 4'b0101;
			  tile_0_1 = 4'b0000;
			  tile_0_2 = 4'b0101;
			  tile_0_3 = 4'b0110;

			  tile_1_0 = 4'b0111;
			  tile_1_1 = 4'b0110;
			  tile_1_2 = 4'b1000;
			  tile_1_3 = 4'b0000; 

		
			  tile_2_0 = 4'b1001;
			  tile_2_1 = 4'b1010;
			  tile_2_2 = 4'b1001;
			  tile_2_3 = 4'b1000;

			  tile_3_0 = 4'b0101;
			  tile_3_1 = 4'b1011;
			  tile_3_2 = 4'b0110;
			  tile_3_3 = 4'b1010;
			end
			3'd5: begin
			  tile_0_0 = 4'b0000;
			  tile_0_1 = 4'b0101;
			  tile_0_2 = 4'b0110;
			  tile_0_3 = 4'b0110;

			  tile_1_0 = 4'b0000;
			  tile_1_1 = 4'b0111;
			  tile_1_2 = 4'b0110;
			  tile_1_3 = 4'b1000; 

		
			  tile_2_0 = 4'b1001;
			  tile_2_1 = 4'b1010;
			  tile_2_2 = 4'b1001;
			  tile_2_3 = 4'b1000;

			  tile_3_0 = 4'b0101;
			  tile_3_1 = 4'b1011;
			  tile_3_2 = 4'b0110;
			  tile_3_3 = 4'b1010;
			end
			3'd6: begin
			  tile_0_0 = 4'b0000;
			  tile_0_1 = 4'b0101;
			  tile_0_2 = 4'b0101;
			  tile_0_3 = 4'b0000;

			  tile_1_0 = 4'b0000;
			  tile_1_1 = 4'b0111;
			  tile_1_2 = 4'b0111;
			  tile_1_3 = 4'b0110; 

		
			  tile_2_0 = 4'b1001;
			  tile_2_1 = 4'b1010;
			  tile_2_2 = 4'b1001;
			  tile_2_3 = 4'b1001;

			  tile_3_0 = 4'b0101;
			  tile_3_1 = 4'b1011;
			  tile_3_2 = 4'b0110;
			  tile_3_3 = 4'b1010;
			end
			3'd7: begin
			  tile_0_0 = 4'b0000;
			  tile_0_1 = 4'b0001;
			  tile_0_2 = 4'b0010;
			  tile_0_3 = 4'b0011;

			  tile_1_0 = 4'b0100;
			  tile_1_1 = 4'b0101;
			  tile_1_2 = 4'b0110;
			  tile_1_3 = 4'b0111; 

		
			  tile_2_0 = 4'b1000;
			  tile_2_1 = 4'b1001;
			  tile_2_2 = 4'b1010;
			  tile_2_3 = 4'b1011;

			  tile_3_0 = 4'b1100;
			  tile_3_1 = 4'b0000;
			  tile_3_2 = 4'b0000;
			  tile_3_3 = 4'b0000;
			end
			default: begin
			  tile_0_0 = 4'b0000;
			  tile_0_1 = 4'b0000;
			  tile_0_2 = 4'b0000;
			  tile_0_3 = 4'b0000;

			  tile_1_0 = 4'b0000;
			  tile_1_1 = 4'b0000;
			  tile_1_2 = 4'b0000;
			  tile_1_3 = 4'b0000; 

		
			  tile_2_0 = 4'b0000;
			  tile_2_1 = 4'b0000;
			  tile_2_2 = 4'b0000;
			  tile_2_3 = 4'b0000;

			  tile_3_0 = 4'b0000;
			  tile_3_1 = 4'b0000;
			  tile_3_2 = 4'b0000;
			  tile_3_3 = 4'b0000;
			end
		endcase
	end
	*/

    // Additional game logic to update tile_values goes here
endmodule

module tile_selector(x, y, tile_0_0, tile_0_1, tile_0_2, tile_0_3, tile_1_0, tile_1_1, tile_1_2, tile_1_3, tile_2_0, tile_2_1, tile_2_2, tile_2_3, tile_3_0, tile_3_1, tile_3_2, tile_3_3, color_index, VGA_CLK);

	 input [8:0] x;                // X coordinate from VGA controller
    input [7:0] y;                // Y coordinate from VGA controller
    input [3:0] tile_0_0;
	 input [3:0] tile_0_1;
	 input [3:0] tile_0_2;
	 input [3:0] tile_0_3;
	 input [3:0] tile_1_0;
	 input [3:0] tile_1_1;
	 input [3:0] tile_1_2;
	 input [3:0] tile_1_3;
	 input [3:0] tile_2_0;
	 input [3:0] tile_2_1;
	 input [3:0] tile_2_2;
	 input [3:0] tile_2_3;
	 input [3:0] tile_3_0;
	 input [3:0] tile_3_1;
	 input [3:0] tile_3_2;
	 input [3:0] tile_3_3; // 4x4 array of tile values from game board
    output [2:0] color_index;      // Output color index for VGA
	 reg [2:0] color_indexB;
    input VGA_CLK;               // 25 MHz clock
	 
	 wire [3:0] tile_values [0:15];
	 
	 assign tile_values[0] = tile_0_0;
	 assign tile_values[1] = tile_0_1;
	 assign tile_values[2] = tile_0_2;
	 assign tile_values[3] = tile_0_3;
	 assign tile_values[4] = tile_1_0;
	 assign tile_values[5] = tile_1_1;
	 assign tile_values[6] = tile_1_2;
	 assign tile_values[7] = tile_1_3;
	 assign tile_values[8] = tile_2_0;
	 assign tile_values[9] = tile_2_1;
	 assign tile_values[10] = tile_2_2;
	 assign tile_values[11] = tile_2_3;
	 assign tile_values[12] = tile_3_0;
	 assign tile_values[13] = tile_3_1;
	 assign tile_values[14] = tile_3_2;
	 assign tile_values[15] = tile_3_3;


    // Calculate the row and column of the tile that corresponds to the current pixel (x, y)
    wire [1:0] tile_row = (y - 40) / 40;
    wire [1:0] tile_col = (x - 80) / 40;
	 reg [3:0] tile_value;
	 
	 always @(*) begin
		integer index;
	   index	= tile_row * 4 + tile_col;
		tile_value = tile_values[index];
	 end


    // Calculate the local address within the tile
    wire [5:0] local_x = x - (80 + tile_col * 40);
    wire [5:0] local_y = y - (40 + tile_row * 40);
    wire [10:0] tile_address = local_y * 40 + local_x;

    // Memory outputs for each tile type
    wire [2:0] color_data_2;
    wire [2:0] color_data_4;
    wire [2:0] color_data_8;
    wire [2:0] color_data_16;
    wire [2:0] color_data_32;
    wire [2:0] color_data_64;
    wire [2:0] color_data_128;
    wire [2:0] color_data_256;
    wire [2:0] color_data_512;
    wire [2:0] color_data_1024;
    wire [2:0] color_data_2048;
    wire [2:0] color_data_empty;
    wire [2:0] color_data_defeat;

    // Instantiate memory blocks for each tile type
    block2 tile_2_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_2);
    block4 tile_4_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_4);
    block8 tile_8_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_8);
    block16 tile_16_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_16);
    block32 tile_32_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_32);
    block64 tile_64_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_64);
    block128 tile_128_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_128);
    block256 tile_256_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_256);
    block512 tile_512_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_512);
    block1024 tile_1024_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_1024);
    block2048 tile_2048_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_2048);
    blockempty tile_empty_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_empty);
    blockdefeat tile_defeat_memory (tile_address, VGA_CLK, 3'b0, 1'b0, color_data_defeat);

    // Select the correct color data based on tile_value
    always @(*) begin
        case (tile_value)
            4'b0001: color_indexB = color_data_2;    // Tile "2"
            4'b0010: color_indexB = color_data_4;    // Tile "4"
            4'b0011: color_indexB = color_data_8;    // Tile "8"
            4'b0100: color_indexB = color_data_16;    // Tile "16"
            4'b0101: color_indexB = color_data_32;    // Tile "32"
            4'b0110: color_indexB = color_data_64;    // Tile "64"
            4'b0111: color_indexB = color_data_128;    // Tile "128"
            4'b1000: color_indexB = color_data_256;    // Tile "256"
            4'b1001: color_indexB = color_data_512;    // Tile "512"
            4'b1010: color_indexB = color_data_1024;    // Tile "1024"
            4'b1011: color_indexB = color_data_2048;    // Tile "2048"
            4'b0000: color_indexB = color_data_empty;    // Tile "empty"
            4'b1100: color_indexB = color_data_defeat;    // Tile "defeat"
            default: color_indexB = color_data_empty;          // Default color (e.g., black or background)
        endcase
    end
	 
	 colorconvert cc(color_indexB, color_index);
	 
endmodule

module colorconvert(rgba, rgbb);
	input [2:0] rgba;
	output reg [2:0] rgbb;
	
	always@(*) 
	begin
		case(rgba)
			3'b000: rgbb = 3'b000;
			3'b001: rgbb = 3'b100;
			3'b010: rgbb = 3'b010;
			3'b011: rgbb = 3'b110;
			3'b100: rgbb = 3'b001;
			3'b101: rgbb = 3'b101;
			3'b110: rgbb = 3'b011;
			3'b111: rgbb = 3'b111;
			default: rgbb = 3'b000;
		endcase
	end
	
	
endmodule

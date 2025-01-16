
module PS2_read (
	// Inputs
	CLOCK_50,
	resetn,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	keyIn,
	key_press_signal
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input				resetn;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output 		[7:0] keyIn;
output 		[3:0] key_press_signal;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (resetn == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
//	else if (last_data_received == 8'h F0 && ps2_key_pressed == 1'b1)
//		keyIn <= ps2_key_data;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign HEX2 = 7'h7F;
assign HEX3 = 7'h7F;
assign HEX4 = 7'h7F;
assign HEX5 = 7'h7F;


assign keyIn = last_ps2_data;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~resetn),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(keyIn[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(keyIn[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);


    // 键盘扫描码处理
    reg [1:0] recv_state;
    reg [7:0] last_ps2_data;
	 
	 reg [7:0] ps2_key_data_sync1, ps2_key_data_sync2;
	reg ps2_key_pressed_sync1, ps2_key_pressed_sync2;
		 reg w_key_down;
		 reg a_key_down;
       reg s_key_down;
 		 reg d_key_down;

	always @(posedge CLOCK_50 or negedge resetn) begin
		 if (!resetn) begin
			  ps2_key_data_sync1 <= 8'h00;
			  ps2_key_data_sync2 <= 8'h00;
			  ps2_key_pressed_sync1 <= 1'b0;
			  ps2_key_pressed_sync2 <= 1'b0;
		 end else begin
			  ps2_key_data_sync1 <= ps2_key_data; // 第一级同步
			  ps2_key_data_sync2 <= ps2_key_data_sync1; // 第二级同步
			  ps2_key_pressed_sync1 <= ps2_key_pressed; // 同步按键按下信号
			  ps2_key_pressed_sync2 <= ps2_key_pressed_sync1; // 第二级同步
		 end
	end
	 

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            w_key_down <= 1'b0;
            a_key_down <= 1'b0;
            s_key_down <= 1'b0;
            d_key_down <= 1'b0;
            recv_state <= 2'b00;
            last_ps2_data <= 8'h00;
        end else begin
            if (ps2_key_pressed_sync2) begin
                case (recv_state)
                    2'b00: begin
                        if (ps2_key_data_sync2 == 8'hF0) begin
                            recv_state <= 2'b01; // 收到F0，表示按键释放
                        end else begin
                            // 按键按下
                            last_ps2_data <= ps2_key_data_sync2;
                            case (ps2_key_data_sync2)
                                8'h1D: w_key_down <= 1'b1; // W键按下
                                8'h1C: a_key_down <= 1'b1; // A键按下
                                8'h1B: s_key_down <= 1'b1; // S键按下
                                8'h23: d_key_down <= 1'b1; // D键按下
                                default: ;
                            endcase
									 
                        end
                    end
                    2'b01: begin
                        // 接收按键释放的扫描码
                        case (ps2_key_data_sync2)
                            8'h1D: w_key_down <= 1'b0; // W键释放
                            8'h1C: a_key_down <= 1'b0; // A键释放
                            8'h1B: s_key_down <= 1'b0; // S键释放
                            8'h23: d_key_down <= 1'b0; // D键释放
                            default: ;
                        endcase
                        recv_state <= 2'b00; // 回到初始状态
                    end
                    default: recv_state <= 2'b00;
                endcase
            end
        end
    end


	 reg [19:0] debounce_counter_w, debounce_counter_a, debounce_counter_s, debounce_counter_d;
	 reg w_key_stable, a_key_stable, s_key_stable, d_key_stable;

	always @(posedge CLOCK_50 or negedge resetn) begin
		 if (!resetn) begin
			  debounce_counter_w <= 20'd0;
			  debounce_counter_a <= 20'd0;
			  debounce_counter_s <= 20'd0;
			  debounce_counter_d <= 20'd0;
			  w_key_stable <= 1'b0;
			  a_key_stable <= 1'b0;
			  s_key_stable <= 1'b0;
			  d_key_stable <= 1'b0;
		 end else begin
			  // W键消抖处理
			  if (w_key_down == w_key_stable) begin
					debounce_counter_w <= 20'd0; // 状态没有变化，计数器清零
			  end else begin
					debounce_counter_w <= debounce_counter_w + 20'd1;
					if (debounce_counter_w == 20'hFFFFF) begin // 达到消抖时间
						 w_key_stable <= w_key_down;
						 debounce_counter_w <= 20'd0; // 清零计数器
					end
			  end

			  // A键消抖处理
			  if (a_key_down == a_key_stable) begin
					debounce_counter_a <= 20'd0;
			  end else begin
					debounce_counter_a <= debounce_counter_a + 20'd1;
					if (debounce_counter_a == 20'hFFFFF) begin
						 a_key_stable <= a_key_down;
						 debounce_counter_a <= 20'd0;
					end
			  end

			  // S键消抖处理
			  if (s_key_down == s_key_stable) begin
					debounce_counter_s <= 20'd0;
			  end else begin
					debounce_counter_s <= debounce_counter_s + 20'd1;
					if (debounce_counter_s == 20'hFFFFF) begin
						 s_key_stable <= s_key_down;
						 debounce_counter_s <= 20'd0;
					end
			  end

			  // D键消抖处理
			  if (d_key_down == d_key_stable) begin
					debounce_counter_d <= 20'd0;
			  end else begin
					debounce_counter_d <= debounce_counter_d + 20'd1;
					if (debounce_counter_d == 20'hFFFFF) begin
						 d_key_stable <= d_key_down;
						 debounce_counter_d <= 20'd0;
					end
			  end
		 end
	end
	
	// 记录上一次的按键状态
reg [3:0] key_state_prev;
always @(posedge CLOCK_50 or negedge resetn) begin
    if (!resetn) begin
        key_state_prev <= 4'b1111;
    end else begin
        key_state_prev <= {w_key_stable, a_key_stable, s_key_stable, d_key_stable};
    end
end

// 检测按键按下（下降沿）
//wire [3:0] key_press_signal;
assign key_press_signal = key_state_prev & (~{w_key_stable, a_key_stable, s_key_stable, d_key_stable}); // 当按键从高变低时，key_press对应位为1


   
endmodule

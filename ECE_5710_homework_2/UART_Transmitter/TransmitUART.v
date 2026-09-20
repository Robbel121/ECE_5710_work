`timescale 1ns / 1ps

module TransmitUART(
    input clk,
    input rst,
    input [7:0] data_bus,
    input byte_ready,
    input Load_XMT_datareg,
    input T_byte,
    output wire serial_out
    );
    
    localparam IDLE = 3'b000,
               LOAD = 3'b001,
               WAIT = 3'b010,
               START = 3'b011,
               SEND = 3'b100,
               SHIFT = 3'b101,
               CLEAR = 3'b110; 
               
     reg [2:0] state, next_state;           
     reg [3:0] status_reg;
     reg [9:0] shift_reg;
     reg [7:0] data_reg;
     
     initial begin
        state = IDLE;
        status_reg = 4'b0;
     end
     
     always@(posedge clk or posedge rst)begin
        if(rst)begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
     end
     
     always@(*) begin
        next_state = state;
        
        case(state)
            IDLE: begin
                if(byte_ready)begin
                    next_state = LOAD;
                end else begin
                    next_state = IDLE;
                end
            end
            
            LOAD: begin
                next_state = WAIT;
            end
            
            WAIT: begin
                if (T_byte)
                    next_state = START;
                else next_state = WAIT;
            end
            
            START: begin
                next_state = SEND;
            end
            
            SEND: begin
                if(status_reg == 9)
                    next_state = CLEAR;
                else    
                    next_state = SHIFT;
            end
            
            SHIFT: begin
                next_state = SEND;
            end
            
            CLEAR: begin
                next_state = IDLE;
            end
            
        endcase
     
     end   
     
     always @(posedge clk or posedge rst)begin        
        if(rst) begin
            shift_reg <= 10'd0;
        end else if (state == LOAD)begin
            shift_reg <= {1'b1, data_reg, 1'b0}; // Stop bit(1) at MSB and start bit(0) at LSB
        end else if(state == SHIFT)begin
            shift_reg <= {1'b0, shift_reg[9:1]}; // Shift value 0 out onto serial out
        end
     end
     
     always@(posedge clk or posedge rst)begin
        if(rst)begin
            status_reg <= 4'd0;
        end else if(state == CLEAR) begin
            status_reg <= 4'd0;
        end else if(state == SHIFT) begin
            status_reg <= status_reg + 1'd1; // Increment status reg for state controls
        end
     end
     
     always@(posedge clk or posedge rst)begin
        if(rst)begin
            data_reg <= 8'b0;
        end else if(Load_XMT_datareg) begin
            data_reg <= data_bus; // Sample data bus when load XMT enabled
        end
     end
     
     assign serial_out = shift_reg[0];
     
endmodule

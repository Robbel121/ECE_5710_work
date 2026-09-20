`timescale 1ns/1ps

module PatternDetectionFSM(
    input clk,
    input rst,
    input I,
    output reg Z,
    output reg E
);
    
    parameter S = 3'b000;
    parameter S1 = 3'b001;
    parameter S11 = 3'b010;
    parameter S110 = 3'b011;
    parameter S0 = 3'b100;
    parameter S00 = 3'b101;
    parameter S001 = 3'b110;
    
    reg [2:0] state, next_state;

    initial begin
        Z <= 1'b0;
        E <= 1'b0;
    end

    always@(posedge clk or posedge rst)begin
        if(rst == 1) state <= S;
        else state <= next_state;
    end


    always@(*)begin
        next_state = state;
        
        case(state)
            S : begin
                if (I == 1'b1)
                    next_state = S1;
                else 
                    next_state = S0;  
                if(rst == 1'b1) next_state = S;
                
                Z = 1'b0;
                E = 1'b0; 
            end
            S1 : begin
                if (I == 1'b1)
                    next_state = S11;
                else 
                    next_state = S0;   
               
                if(rst == 1'b1) next_state = S;
                
                Z = 1'b0;
                E = 1'b0; 
            end
            S11 : begin
                if (I == 1'b1)
                    next_state = S11;
                else 
                    next_state = S110;  
                if(rst == 1'b1) next_state = S;
                
                Z = 1'b0;
                E = 1'b0; 
            end
            S110 : begin
                if (I == 1'b1)
                    next_state = S1;
                else 
                    next_state = S00;
                if(rst == 1'b1) next_state = S;
                Z = 1'b1;
                E = 1'b0;
            end
            S0 : begin
                if (I == 1'b1)
                    next_state = S1;
                else 
                    next_state = S00;  
                if(rst == 1'b1) next_state = S;
                
                Z = 1'b0;
                E = 1'b0; 
            end
            S00 : begin
                if (I == 1'b1)
                    next_state = S001;
                else 
                    next_state = S00;
                    
                if(rst == 1'b1) next_state = S;  
                
                Z = 1'b0;
                E = 1'b0; 
            end
            S001 : begin
                if (I == 1'b1)
                    next_state = S001;
                else 
                    next_state = S001;
                    
                if(rst == 1'b1) next_state = S; 
                Z = 1'b0;
                E = 1'b1; 
            end
        endcase
    end


endmodule
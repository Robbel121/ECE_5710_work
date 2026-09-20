`timescale 1ns / 1ps

module tb_TransmitUART;
    reg clk;
    reg rst;
    reg [7:0] data_bus;
    reg byte_ready;
    reg Load_XMT_datareg;
    reg T_byte;
    
    wire serial_out;
    
    TransmitUART uut(.clk(clk), .rst(rst), .data_bus(data_bus), .byte_ready(byte_ready), .Load_XMT_datareg(Load_XMT_datareg), .T_byte(T_byte), .serial_out(serial_out));
    
    always #10 clk = ~clk; // 50 MHz clock on my FPGA
    
    task test_transmit( // Will go through standard transmission process
        input [7:0] data
        );
        
        integer i;
        reg [9:0] exp_shift_reg;
        reg [3:0] exp_stat_reg;
        
        begin
            i = 0;
            exp_shift_reg = {1'b1, data, 1'b0};
            exp_stat_reg = 4'd0;
            data_bus = data;
            #1;
            
            byte_ready = 1'b1; //Idle to load
            Load_XMT_datareg = 1'b1; 
            @(posedge clk);
            #1;         // Add this block of code to wait for state change
            byte_ready = 1'b0;
            Load_XMT_datareg = 1'b0; 
            @(posedge clk);
            #1;
            
            $display("Data reg is %h | Expected data reg: %h", uut.data_reg, data); // Load to wait
            $display("Shift reg is %b | Expected shift reg: %b", uut.shift_reg, exp_shift_reg);
            
            T_byte = 1'b1;
            @(posedge clk); // wait to start
            #1;
            T_byte = 1'b0;
            
            while(i < 10) begin // send to stop
                @(posedge clk);
                #1;
                if(uut.SEND == uut.state)begin         
                    if(exp_shift_reg[0] !== uut.serial_out)begin
                        $display("Incorrect output for bit %0d. Expected : %b | Actual: %b", i, exp_shift_reg[0] , uut.serial_out);
                    end else begin
                        $display("All good");
                    end
                    
                    if(exp_stat_reg !== uut.status_reg)begin
                        $display("Incorrect status reg     Expected status reg: %b | Actual status reg: %b",exp_stat_reg , uut.status_reg);
                    end 
                    
                    exp_stat_reg = exp_stat_reg + 1;
                    exp_shift_reg = exp_shift_reg >> 1;
                    i = i +1;
                end
                
            end
            @(posedge clk); // Stop to clear
            #1;
            @(posedge clk); // Clear to idle
            #1;
            
            
            if(4'd0 !== uut.status_reg) begin
                $display("Clear is not working. Status reg is not 0.");
            end
        end
    endtask    
    
    initial begin
        clk = 1'b0;
        rst = 1'b0;
        data_bus = 8'd0;
        byte_ready = 1'b0;
        Load_XMT_datareg = 1'b0;
        T_byte = 1'b0;
        #1;
        
        // Going to test 2 patterns(with inputs): 11110000(0xF0) and 10101010(0xAA) with reset 
        test_transmit(8'hF0);
        
        #10; // Wait half a clock period
        
        test_transmit(8'hAA);
        
        #10;
        
        rst = 1'b1;
        #1; // stabilize rst
        if((uut.status_reg !== 4'd0) || (uut.data_reg !== 8'b0) || (uut.shift_reg !== 10'b0))begin
            $display("Reset does not set registers to 0");
        end else begin
            $display("Reset works");
        end
            
        #10;
        $finish;
    end
    
endmodule

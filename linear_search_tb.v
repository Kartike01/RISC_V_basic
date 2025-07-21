module linear_search ;
    reg clk1 ,clk2 ;
    integer k,n;

    pipe_MIPS32 mips (clk1,clk2) ;

    initial 
        begin 
            clk1 = 0; clk2 =0 ;
            repeat (20) 
                begin
                    #5 clk1 = 1 ;  #5 clk1 = 0 ;
                    #5 clk2 =1  ; #5 clk2 =0 ;
                end
        end
    
    initial 
        begin
            for(k=0 ; k<31; k=k+1)
                mips.Reg[k] = k ;
                
        mips.Mem[0] = 32'h28010003; // ADDI R1,R0,3
        mips.Mem[1] = 32'h28020004; // ADDI R2,R0,4
        mips.Mem[2] = 32'h28030005; // ADDI R3,R0,5
        mips.Mem[3] = 32'h28040006; // ADDI R4,R0,6 
        mips.Mem[4] = 32'h28050007; // ADDI R5,R0,7
        mips.Mem[5] = 32'h280a0005; // No. of elements in register R10
        mips.Mem[6] = 32'h280b0005; // element to be searched for in R11 (here 6)
        mips.Mem[7] = 32'h280c0001; // 1 stored in R12
        mips.Mem[8] = 32'h042c6800; // R13 = R1-R11
        mips.Mem[9] = 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[10]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[11]= 32'h39a00030; // IF R13=0 ,GO TO INSTRUCTION 50
        mips.Mem[12]= 32'h298c0001; // R12=R12+1
        mips.Mem[13]= 32'h044c6800; // R13=R2-R11
        mips.Mem[14]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[15]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[16]= 32'h39a00021; // IF R13=0 ,GO TO INSTRUCTION 50
        mips.Mem[17]= 32'h298c0001; // R12=R12+1
        mips.Mem[18]= 32'h046c6800; // R13=R3-R11
        mips.Mem[19]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[20]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[21]= 32'h39a0001c; // IF R13=0 ,GO TO INSTRUCTION 50
        mips.Mem[22]= 32'h298c0001; // R12=R12+1
        mips.Mem[23]= 32'h048c6800; // R13=R4-R11
        mips.Mem[24]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[25]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[26]= 32'h39a00017; // IF R13=0 ,GO TO INSTRUCTION 50
        mips.Mem[27]= 32'h298c0001; // R12=R12+1
        mips.Mem[28]= 32'h04ac6800; // R13=R5-R11
        mips.Mem[29]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[30]= 32'h0680a000; // DUMMY R20=R20+R0
        mips.Mem[31]= 32'h29802000; // IF R13=0 ,GO TO INSTRUCTION 50
        mips.Mem[32]= 32'hfc000000; // HALT
        mips.Mem[51]= 32'hfc000000; // HALT

        mips.HALTED =0;
        mips.PC=0;
        mips.TAKEN_BRANCH=0;
        #2000
        for(k=0;k<20;k=k+1)
            $display ("R%2d - %2d ", k, mips.Reg[k]);
        end
endmodule
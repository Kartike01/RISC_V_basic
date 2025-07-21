module RISCV(input clk1,clk2);
  reg[31:0] PC,IF_ID_IR,IF_ID_NPC; //INSTRUCTION FETCH 
  reg[31:0] ID_EX_IR,ID_EX_NPC,ID_EX_A,ID_EX_B,ID_EX_Imm;//ID
  reg[31:0] EX_Mem_ALUOut,EX_Mem_IR,EX_Mem_B;//IE
  reg EX_Mem_cond;//IE
  reg[31:0] Mem_WB_IR, Mem_WB_ALUOut, Mem_WB_LMD;//Mem
  
  
  parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'b000010, OR = 6'b000011,SLT = 6'b000100, MUL = 6'b000101, DIV = 6'b000110, EQ = 6'b000111, HLT = 6'b111111, LW = 6'b001000,SW = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, SLTI = 6'b001100,BNEZ = 6'b001101, BEZ = 6'b001110, JMP = 6'b001111;
  // OPCODES encoding 
  
  reg[2:0] ID_EX_type,EX_Mem_type,Mem_WB_type;
  
  // INSTRUCTION TYPE
  parameter RR_ALU = 3'd0;    // Register-Register ALU operation
  parameter RM_ALU = 3'd1;    // Register-Memory ALU operation
  parameter Load   = 3'd2;    // Load from memory
  parameter Store  = 3'd3;    // Store to memory
  parameter Branch = 3'd4;    // Branch instruction
  parameter Halt   = 3'd5;    // Halt the processor
  
  reg Halted,Taken_branch;
  
  reg[31:0] Reg[0:31];
  reg[31:0] Mem [0:1023];
  
  // INSTRUCTION FETCH
  always @(posedge clk1) begin 
    if(Halted == 0) begin 
      if(((EX_Mem_IR[31:26]==BEZ)&&(EX_Mem_cond==1))||((EX_Mem_IR[31:26]==BNEZ)&&(EX_Mem_cond==0)))begin // here cond will be 1 when the reg value(A) is 0
        IF_ID_IR <=  Mem[EX_Mem_ALUOut];
        IF_ID_NPC <= #2 EX_Mem_ALUOut +1;
        PC <= #2 EX_Mem_ALUOut+1;
        Taken_branch <= 1'b1;
      end
      else begin 
        IF_ID_IR <= #2 Mem[PC];
        PC <= #2 PC +1;
        IF_ID_NPC <= #2 PC +1;
		  Taken_branch <= 1'b0;
      end 
    end 
  end
  
  // INSTRUCTION DECODE 
  always @(posedge clk2) begin 
    if(Halted == 0) begin 
      if(IF_ID_IR[25:21] == 5'd0) ID_EX_A <= 0;
      else ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];
      
      if (IF_ID_IR[20:16] == 5'd0) ID_EX_B <= 0;
      else ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];
      
      ID_EX_IR <= #2 IF_ID_IR  ;
      ID_EX_NPC <= #2 IF_ID_NPC  ;
      ID_EX_Imm <= {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};
      
      case(IF_ID_IR[31:26])
        ADD,SUB,AND,OR,MUL,SLT,DIV,EQ : ID_EX_type = RR_ALU;
        ADDI,SUBI,SLTI : ID_EX_type = #2 RM_ALU;
        LW : ID_EX_type = #2 Load  ;
        SW : ID_EX_type = #2 Store ;
        BEZ,BNEZ,JMP : ID_EX_type = #2 Branch;
        HLT : ID_EX_type = #2 Halt;
        default: ID_EX_type <= #2 Halt;
      endcase 
    end 
  end 
  
  // INSTRUCTION EXECUTE 
  
  always @(posedge clk1) begin 
    if(Halted == 0) begin 
      EX_Mem_IR <= ID_EX_IR;
     // Taken_branch <= #2 1'b0;
      EX_Mem_type <= ID_EX_type;
      
      case (ID_EX_type) 
        RR_ALU : 
          case(ID_EX_IR[31:26])
            ADD : EX_Mem_ALUOut <= #2 (ID_EX_A)+(ID_EX_B ) ;
            SUB : EX_Mem_ALUOut <= #2 (ID_EX_A)-(ID_EX_B ) ;                                          
            AND : EX_Mem_ALUOut <= #2 (ID_EX_A)&(ID_EX_B ) ;
            OR  : EX_Mem_ALUOut <= #2 (ID_EX_A)|(ID_EX_B ) ;
            MUL : EX_Mem_ALUOut <= #2 (ID_EX_A)*(ID_EX_B ) ;
            SLT : EX_Mem_ALUOut <= #2 (ID_EX_A)<(ID_EX_B ) ;
            DIV : EX_Mem_ALUOut <= #2 (ID_EX_A)/(ID_EX_B ) ;
            EQ  : EX_Mem_ALUOut <= #2 (ID_EX_A)==(ID_EX_B) ;
          endcase
        RM_ALU : begin
          case(ID_EX_IR[31:26])
            ADDI : EX_Mem_ALUOut <= #2 ID_EX_A + ID_EX_Imm ;
            SUBI  : EX_Mem_ALUOut <= #2 ID_EX_A - ID_EX_Imm ;
            SLTI  : EX_Mem_ALUOut <= #2 ID_EX_A < ID_EX_Imm ;
          endcase 
          EX_Mem_B <= #2 ID_EX_B;
        end        
        Load,Store : begin 
          EX_Mem_B <= #2 ID_EX_B;
          EX_Mem_ALUOut <= #2 ID_EX_A + ID_EX_Imm ;
        end 
        Branch : begin 
          EX_Mem_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
          EX_Mem_cond <= #2 (ID_EX_A == 0);
        end 
      endcase
    end 
  end 
  
  // Memory Access
  
  always @(posedge clk2) begin
    if(Halted == 0) begin
      Mem_WB_IR <= #2 EX_Mem_IR;
      Mem_WB_type <= #2 EX_Mem_type;
      case (EX_Mem_type)
        RR_ALU,RM_ALU : Mem_WB_ALUOut <= EX_Mem_ALUOut;
        Load : Mem_WB_LMD <= #2 Mem[EX_Mem_ALUOut];  // LMD here stands for load memory data 
        Store : begin if(Taken_branch == 0) Mem[EX_Mem_ALUOut] <= #2 EX_Mem_B; end 
      endcase 
    end 
  end
  
  // Write Back
  
  always @(posedge clk1) begin 
    if(Taken_branch == 0) begin 
      case(Mem_WB_type)
        RR_ALU : Reg[Mem_WB_IR[15:11]] <= Mem_WB_ALUOut ;
        RM_ALU : Reg[Mem_WB_IR[20:16]] <= Mem_WB_ALUOut ;
        Load : Reg[Mem_WB_IR[20:16]] <= Mem_WB_LMD;
        Halt : Halted <= 1'b1;
        endcase
    end 
  end 
endmodule




/*
//TESTBENCH WITH FACTORIAL IMPLENTATION 
// computing factorial of a number using testbench 

module tb_RISCV;
  reg clk1,clk2;
  integer k;
  
  initial
    begin
      clk1=0;clk2=0;
      repeat(30)
        begin
          #5 clk1=1;  #5 clk1=0;
          #5 clk2=1;  #5 clk2=0;
        end
    end
  
  RISCV mips(clk1,clk2);
  initial begin 
    mips.Halted=0;
    mips.Taken_branch =0;
    mips.PC = 0;
  end 
  
  initial 
    begin 
      for(k=0;k<=31;k++) mips.Reg[k] = k;
      mips.Mem[0] = 32'h280a00c8; // ADDI R10,RO,200
	  mips.Mem[1] = 32'h28020001; // ADDI R2,RO,1
	  mips.Mem[2] = 32'h0e94a000; // OR R20,R20,R20 -- dummy ir
	  mips.Mem[3] = 32'h21430000; // LW R3,0 (R10)
	  mips.Mem[4] = 32'h0e94a000; // OR R20,R20,R20 —-- dummy ir
	  mips.Mem[5] = 32'h14431000; // Loop: MUL R2,R2,R3
	  mips.Mem[6] = 32'h2c630001; // SUBI R3,R3,1
	  mips.Mem[7] = 32'h0e94a000; // OR R20,R20,R20 —-- dummy ir
	  mips.Mem[8] = 32'h3460fffc; // BNEQZ R3,Loop (i.e. -4 offset)
	  mips.Mem[9]=32'h2542fffe;
	  mips.Mem[10]=32'hfc000000;
      mips.Mem[200]=4;
    end 
        
  
  initial begin 
    #5000
    $display("Mem[200] = %2d, Mem[198] = %8d",mips.Mem[200],mips.Mem[198]);
  end
endmodule
    
    
    
 */
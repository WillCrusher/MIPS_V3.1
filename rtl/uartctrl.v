`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module name    uartctrl.v
// ˵����          ������ڽ��յ����ݣ����ͽ��յ������ݵ����ڣ����û�н��յ����ݣ�Ĭ�ϲ��ϵķ���
//                �洢���ַ���
//////////////////////////////////////////////////////////////////////////////////
module uartctrl(
      input                   clk,
		input                   rdsig,                //���ڽ���������Ч�ź�
		input      [7:0]        rxdata,               //���ڽ�������
	   output                  wrsig,                //���ڷ���ָʾ�ź�
		output     [7:0]        dataout,               //���ڷ�������
		input rst_n

);

reg [17:0] uart_wait;
reg [15:0] uart_cnt;
reg rx_data_valid;
reg [7:0] store [19:0];                        //�洢�����ַ�
reg [2:0] uart_stat;                           //uart״̬��
reg [8:0] k;                                   //����ָʾ���͵ĵڼ�������
reg [7:0] dataout_reg;
reg data_sel;
reg wrsig_reg;

  
assign dataout = data_sel ? rxdata : rxdata ; //dataout_reg           //��������ѡ��data_sel�ߣ�ѡ��洢���ַ�����data_sel���ͣ�ѡ����յ�����
//assign wrsig = data_sel ?  rdsig : rdsig;  //wrsig_reg                 //��������ѡ��data_sel�ߣ����ʹ洢���ַ�����data_sel���ͣ����ͽ��յ�����
assign wrsig = data_sel;


//�洢����Ҫ���͵��ַ���
initial
begin     //���巢�͵��ַ�
	 store[0]<=72;                           //�洢�ַ�H
	 store[1]<=101;                          //�洢�ַ�e
	 store[2]<=108;                          //�洢�ַ�l
	 store[3]<=108;                          //�洢�ַ�l
	 store[4]<=111;                          //�洢�ַ�o                         
	 store[5]<=32;                           //�洢�ַ��ո�
	 store[6]<=78;                           //�洢�ַ�N
	 store[7]<=69;                           //�洢�ַ�E
	 store[8]<=88;                           //�洢�ַ�X
	 store[9]<=89;                           //�洢�ַ�Y
	 store[10]<=83;                          //�洢�ַ�S
	 store[11]<=32;                          //�洢�ַ��ո�
	 store[12]<=52;                          //�洢�ַ�4
	 store[13]<=32;                          //�洢�ַ��ո�
	 store[14]<=68;                          //�洢�ַ�D
	 store[15]<=68;                          //�洢�ַ�D
	 store[16]<=82;                          //�洢�ַ�R
	 store[17]<=32;                          //�洢�ַ��ո�
	 store[18]<=10;                          //���з�
	 store[19]<=13;                          //�س���
  end 
  
//���ڷ��Ϳ��ƣ�ÿ��һ��ʱ�����һ�������ַ���������  
always @(negedge clk)
if(~rst_n) begin uart_wait <= 0; rx_data_valid <= 1; end
else begin
  if(rdsig == 1'b1) begin   //��������н��յ����ݣ�ֹͣ�����ַ���                        
		uart_wait <= 0;
		rx_data_valid <=1'b0;
  end
  else begin
    if (uart_wait ==18'h3ffff) begin                //�ȴ�һ��ʱ��(ÿ��һ��ʱ�䷢���ַ�����,������������Ըı䷢���ַ���֮���ʱ������
		uart_wait <= 0;
		rx_data_valid <=1'b1;	                      //�ȴ�ʱ�����������һ�������ַ�����Ч�ź�����
    end		
	 else begin
		uart_wait <= uart_wait+1'b1;
		rx_data_valid <=1'b0;
	 end
  end
end 
 
//////////////////////////////////////// 
//���ڷ����ַ������Ƴ������η��ʹ洢���ַ���//
////////////////////////////////////////	
always @(posedge clk)
if (~rst_n) begin uart_cnt <= 0; uart_stat <= 3'b0; data_sel <= 0; k<=0;wrsig_reg <=0; dataout_reg <= 0; end
else begin
  if(rdsig == 1'b1) begin   
		uart_cnt <= 0;
		uart_stat <= 3'b000; 
		data_sel<=1'b0;
		k<=0;
  end
  else begin
  	 case(uart_stat)
	 3'b000: begin               
       if (rx_data_valid == 1'b1) begin  //�����ַ�����Ч�ź�Ϊ�ߣ���ʼ�����ַ���
		    uart_stat <= 3'b001; 
			 data_sel<=1'b1; 
		 end
	 end	
	 3'b001: begin                      //����19���ַ�   
         if (k == 18 ) begin           //���͵�19���ַ�      		 
				 if(uart_cnt ==0) begin
					dataout_reg <= store[18]; 
					uart_cnt <= uart_cnt + 1'b1;
					wrsig_reg <= 1'b1;      //�����ַ�ʹ������             			
				 end	
				 else if(uart_cnt ==254) begin    //�ȴ�һ���ַ�������ɣ�����һ���ַ���ʱ��Ϊ168��ʱ�ӣ���������ȴ���ʱ����Ҫ����168
					uart_cnt <= 0;
					wrsig_reg <= 1'b0; 				
					uart_stat <= 3'b010; 
					k <= 0;
				 end
				 else	begin			
					 uart_cnt <= uart_cnt + 1'b1;
					 wrsig_reg <= 1'b0;  
				 end
		  end
	     else begin                      //����ǰ18���ַ�   
				 if(uart_cnt ==0) begin      
					dataout_reg <= store[k]; 
					uart_cnt <= uart_cnt + 1'b1;
					wrsig_reg <= 1'b1;           //����ʹ��           			
				 end	
				 else if(uart_cnt ==254) begin    //�ȴ�һ�����ݷ�����ɣ�����һ���ַ���ʱ��Ϊ168��ʱ�ӣ���������ȴ���ʱ����Ҫ����168
					uart_cnt <= 0;
					wrsig_reg <= 1'b0; 
					k <= k + 1'b1;	               //k��1��������һ���ַ�        			
				 end
				 else	begin			
					 uart_cnt <= uart_cnt + 1'b1;
					 wrsig_reg <= 1'b0;  
				 end
		 end	 
	 end
	 3'b010: begin       //����finish	 
		 	uart_stat <= 3'b000;
			data_sel<=1'b0;	
	 end
	 default:uart_stat <= 3'b000;
    endcase 
  end
end

 
endmodule

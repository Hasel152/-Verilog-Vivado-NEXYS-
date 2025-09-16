`timescale 1ns / 1ps
//==============================================================
// Module: debounce (��������)
// Description: ͨ�ð�������ģ�顣
//              ����һ���ж����ġ��͵�ƽ��Ч�İ����źţ�
//              ���һ���ɾ��ġ���������Ч�������¼���
//==============================================================
module debounce(
    input        clk,          // ���룺ϵͳ��ʱ�� (100MHz)
    input        rst_n,        // ���룺ȫ�ָ�λ
    input        btn_in,       // ���룺ԭʼ�ġ��������İ����ź�
    output       btn_pulse     // ���������������ĵ���������
);
    // ��������ʱ�䣬ͨ��10-20ms���ɡ�����ѡ��10ms��
    // 10ms @ 100MHz clk = 1,000,000 ��ʱ������
    parameter DEBOUNCE_CNT_MAX = 20'd1_000_000;

    // �ڲ��Ĵ���
    reg [1:0]  state;          // һ��������ڲ�״̬��
    reg [19:0] counter;        // ������ʱ������
    reg        btn_in_sync;    // ͬ����İ��������ź�

    // FSM ״̬����
    parameter IDLE    = 2'b00; // ״̬0���ȴ���������
    parameter DEBOUNCE = 2'b01; // ״̬1��������ʱ����
    parameter WAIT_RELEASE = 2'b10; // ״̬2��ȷ�ϰ��£��ȴ������ͷ�

    //---------------------------------------------------------
    // 1. ����ͬ���� (Input Synchronizer)
    //---------------------------------------------------------
    // Ϊ�˷�ֹ�����첽�����btn_in�źŵ�������̬��
    // ��������һ������������"ͬ��"�����ǵ�clkʱ����
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            btn_in_sync <= 1'b1; // Ĭ�ϰ�����û���µ�(�ߵ�ƽ)
        else
            btn_in_sync <= btn_in;
    end

    //---------------------------------------------------------
    // 2. ���������߼� (��һ������״̬��ʵ��)
    //---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
            counter <= 0;
        end else begin
            case(state)
                IDLE: begin // ��"�ȴ�"״̬
                    if(btn_in_sync == 1'b0) begin // �����⵽����������...
                        state <= DEBOUNCE;       // ...�ͽ���"������ʱ"״̬...
                        counter <= 0;            // ...��������������
                    end
                end
                
                DEBOUNCE: begin // ��"��ʱ"״̬
                    if(counter == DEBOUNCE_CNT_MAX) begin // ���10ms��ʱ����...
                        if(btn_in_sync == 1'b0) begin // ...�����ٴ�ȷ�ϰ�������Ȼ���ǰ��µ�...
                            state <= WAIT_RELEASE;   // ...��ô��ȷ��Ϊһ����Ч���£�����"�ȴ��ͷ�"״̬��
                        end else begin
                            state <= IDLE; // ������Ϊ�Ǹ��ţ�����"�ȴ�"״̬��
                        end
                    end else begin
                        counter <= counter + 1; // ��ʱû����������������
                    end
                end

                WAIT_RELEASE: begin // ��"�ȴ��ͷ�"״̬
                    if(btn_in_sync == 1'b1) begin // �����⵽�������ɿ���...
                        state <= IDLE;           // ...�ͷ��������"�ȴ�"״̬��׼����һ�ΰ�����
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
    
    //---------------------------------------------------------
    // 3. ����߼�
    //---------------------------------------------------------
    // ���ҽ�����״̬����"��ʱ"״̬���ո���ת����"�ȴ��ͷ�"״̬����һ˲�䣬
    // ���ǲŲ���һ�������ڵ����塣
    assign btn_pulse = (state == DEBOUNCE) && (counter == DEBOUNCE_CNT_MAX) && (btn_in_sync == 1'b0);

endmodule
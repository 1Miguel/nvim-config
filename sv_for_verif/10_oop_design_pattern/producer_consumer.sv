// **************************************************************************************
// @file producer_consumer.sv
// @brief a reference design pattern of procuer and consumer.
//
// @usage you can execute this with verilator, example command is:
//
//    "verilator --binary --exe --timing producer_consumer.sv"
//
// then it will create an obj_dir, execute
//
//    "./obj_dir/Vproducer_consumer"
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
//
// **************************************************************************************

// below are example of producer consumer pattern. 

localparam int N = 10;

// this enable handshake synchronization which allow the consumer to tell the
// producer if the item pushed has been consumed before the producer push
// another item to the mailbox
//
// as an exerise check the $display print if this is enabled or disabled.
localparam bit SYNC_ENABLE = 1;

class Producer;
  // producer to consumer mailbox
  mailbox #(int) mbx;
  // this is a synchronization primitive, this allows the producer to
  // synchronize with the consumer, think of this as a handshake mechanism,
  // consumer tells the producer (via event) if it has consumed a popped
  // item before the produce push another item.
  event ack;

  function new(mailbox #(int) mbx, event ack);
    this.mbx = mbx;
    this.ack = ack;
  endfunction

  task run();
    for (int i=1; i<N; i++) begin
      $display("producer: putting <%0d>", i);
      this.mbx.put(i);
      if (SYNC_ENABLE == 1)
        @this.ack;
    end
  endtask
endclass

class Consumer;
  // mailbox that consumer waits for the producer to push to
  mailbox #(int) mbx;
  // consumer raises this event if it has popped the item from the mailbox
  event ack;

  function new(mailbox #(int) mbx, event ack);
    this.mbx = mbx;
    this.ack = ack;
  endfunction

  task run();
    int i;
    repeat(N) begin
      this.mbx.get(i);
      $display("consumer: pop <%0d>", i);
      // let the consumer know we received the item
      #10
      if (SYNC_ENABLE == 1)
        ->this.ack;
    end
  endtask

endclass

module top();
  
  mailbox #(int) mbx_p2c;
  event evt_c2p;
  Producer p;
  Consumer c;

  initial begin
    mbx_p2c = new();
    p = new(mbx_p2c, evt_c2p);
    c = new(mbx_p2c, evt_c2p);
    
    $display("start at %0d loop", N);
    fork
      p.run();
      c.run();
    join
  end

endmodule

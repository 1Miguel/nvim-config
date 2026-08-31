// **************************************************************************************
// @file factory.sv
// @brief simple exercise that demonstrate factory pattern
// systemverilog
//
// @usage you can execute this with verilator, example command is:
//
//    "verilator --binary --exe --timing scope.sv"
//
// then it will create an obj_dir, execute
//
//    "./obj_dir/Vtop"
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
//
// **************************************************************************************

// ... just a few notes .. as someone who works with oop language for a long
// time, i always tell myself to only use inherittance when there is
// a requirement to override or implement a behaviour. its always a better
// decision to use composition when structuring code.


// Base class Transaction model
class Transaction;

  rand bit[31:0] src;
  rand bit[31:0] dest;
  rand bit[31:0] data[8];
  bit[31:0] crc;

  // what is virtual? tagging a function as virtual allows the child class to
  // override the method if it needs to. it allows child class to modify the
  // behaviour of the base class.
  virtual function string name();
    return "Transaction";
  endfunction: name

  virtual function void calc_crc();
    crc = src ^ dest ^ data.xor();
  endfunction: calc_crc

  virtual function void display();
    $display("Tr<%s> {src=%h, dest=%h, crc=%h}",
      this.name(), this.src, this.dest, this.crc);
  endfunction: display

endclass: Transaction

class GoodTransaction extends Transaction;

  virtual function string name();
    return "GoodTransaction";
  endfunction: name

endclass: GoodTransaction

// suppose our testbench requires that we inject an error to a good
// transaction. we can extend the transaction class to modify its behaviour to
// generate a bad transaction
class BadTransaction extends Transaction;

  rand bit bad_crc;

  virtual function string name();
    return "BadTransaction";
  endfunction: name

  virtual function void calc_crc();
    super.calc_crc();
    if (bad_crc)
      crc = ~crc;
  endfunction

  virtual function void display();
    $display("Injecting a bad crc");
    // super is similar to python's super. in computer science we call base
    // class as the superclass. super allows the child class to refer to the
    // base class and call its method and refer to its attributes.
    super.display();
  endfunction

endclass: BadTransaction

// We can create a class factory, with this other parts of the program does
// not need to know other `Transaction` type. we can build and change the
// types of transaction at runtime.
class TransactionFactory;

  static function Transaction create(string name);
    case (name)

      "bad": begin
        BadTransaction bad_tr = new();
        return bad_tr;
      end

      "good": begin
        GoodTransaction good_tr = new();
        return good_tr;
      end

      default: $fatal(1, "Unknown type: %s", name);
    endcase
    return null;
  endfunction

endclass: TransactionFactory

module top();

  Transaction tr_1;
  Transaction tr_2;

  initial begin: init
    tr_1 = TransactionFactory::create("good");
    tr_2 = TransactionFactory::create("bad");

    tr_1.display();
    tr_2.display();
  end: init

endmodule: top

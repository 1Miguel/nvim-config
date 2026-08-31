# UVM Factory Mechanism

If you are learning UVM like me, you will notice a common recurring pattern: you define a class and whenever you want to instantiate that class, you use `uvm_factory::create_instance_*`. But how does it work? We need to understand the mechanism behind it first. The best way to understand it is to create a factory ourselves!

## The **Static** keyword

To understand factory, we first need to understand how the static keyword works and how a class variable and method behaves when it is marked as static. Let's observe the code below:

```
class MyClass;

  static int static_count;
  int my_count;

endclass: MyClass

module top();

  MyClass my_class;

  initial begin: init
    my_class.static_count++;
    $display("my_class.static_count = %0d", my_class.static_count);
    my_class.my_count++;
    $display("my_class.static_count = %d", my_class.my_count);
  end: init

endmodule: top
```

If you execute this code you'll find two things, the *my_class.static_count* being printed and the *myclass.my_count* causing a Null pointer dereferenced error. This is because a static class variable persist within the class scope, and is shared among instances.

... but why does my_class.my_count++ raises an error? Its because my_class is only a *handle*, a *pointer* to a MyClass object, but it doesn't point to anything yet. *my_count* does not exist in memory yet.

We can even test this with static functions, try the code below and see the result

```
class MyClass;
  
  function string my_name();
    return "my_name";
  endfunction

  static function string my_name();
    return "static my_name";
  endfunction

endclass: MyClass

module top();

  MyClass my_class;

  initial begin: init
    $display("my_class.static_count = %0d", my_class.my_name);
    $display("my_class.static_count = %d", my_class.my_static_name);
  end: init

endmodule: top
```

# The **Singleton** Pattern

*static* is a very powerful keyword, languages like C++ and python uses static variables to control class instantiation. Let's one of the most famous design pattern that best demonstrate this, the **singleton** pattern.

``` SystemVerilog
class Singleton;

  static int count;
  static Singleton inst;

  int id;

  local function new();
    id = ++count;
  endfunction

  static function Singleton get_instance();
    if (inst == null)
      $display("Create new singleton");
      inst = new();
    return inst;
  endfunction: get_instance

module top();

  Singleton s;
  Singleton x;
  Singleton y;

  initial begin: init
    s = Singleton::get_instance();
    x = Singleton::get_instance();
    y = Singleton::get_instance();

    $display("s=%p", s);
    $display("x=%p", x);
    $display("y=%p", y);
  end: init

endmodule: top
endclass: Singleton
```

If you run this you will see this logs:
```
Create new singleton
s='{id:'h1}
x='{id:'h1}
y='{id:'h1}
```

Notice that even though we instantiated multiple object, the instance creation in *Singleton::get_instance()* routine is only executed once? This is because we control the instantiation via the *static Singleton inst* pointer. If an instance is already created, we will not create another but instead, just return the pointer to it.

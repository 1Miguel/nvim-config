// the goal is, whenever we define a type, we want to be able to register that
// type into a list, which we will call a "registry of types", a lookup table
// of types that would later on allow us to object creation by name.
//
// to do this, each time we define a type (a class), an registry object must


// @brief this will be the common base object to all the classes we will define.
virtual class object;

  string name;

  function new(string name="object");
    this.name = name;
  endfunction

endclass : object

 // @brief A proxy object controls the object creation for every registered
 // type, therefore a proxy object is binded to a defined type.
 //
 // The factory class would contain a list of proxy objects. So when factory
 // needst to  create an object, it would look into its list of proxy objects
 // and create the desired object via proxy.
 //
 // Note that this is a virtual class, this provides an interface and registry
 // protocol to the factory class.
virtual class registry_proxy_base
  extends object;

  function new(string name);
    super.new(name);
  endfunction;

  // @brief creates a new object of typed `T` and assign it with name.
  //
  // @param name name to assign to a new object.
  pure virtual function object create(string name);

  // @brief returns the type name of the type binded to this registry proxy.
  //
  // @return type name binded to the registry item.
  pure virtual function string get_type_name();

endclass : registry_proxy_base

class factory;

  static registry_proxy_base proxy_list_by_type_name[string];

  static function void register_proxy(registry_proxy_base proxy);
    $display("registering proxy <%s> object: %s", proxy.name, proxy.get_type_name());
    proxy_list_by_type_name[proxy.get_type_name()] = proxy;
  endfunction : register_proxy

  static function object create_object_by_type_name(string type_name, string name);
    registry_proxy_base proxy = proxy_list_by_type_name[type_name];
    $display("create new object from proxy <%s>", proxy.name);
    return proxy.create(name);;
  endfunction

endclass : factory

// @brief This implements registry proxy.
class registry_proxy #(type T, string TYPE_NAME)
  extends registry_proxy_base;

  // registry proxy type, we typedef for convenience
  typedef registry_proxy #(
    .T(T), .TYPE_NAME(TYPE_NAME)
  ) registry_proxy_t;
  // singleton, there should only be one proxy object for every type defined
  static registry_proxy_t inst;
  // registry type name
  static string type_name = TYPE_NAME;

  local function new(string name);
    super.new(name);
  endfunction

  function string get_type_name();
    return this.type_name;
  endfunction

  function object create(string name);
    T new_instance;
    new_instance = new(name);
    return new_instance;
  endfunction

  static function registry_proxy_t get();
    if (inst == null) begin
      $display("Registry proxy creation of type: %s", TYPE_NAME);
      inst = new({"registry_proxy__",  TYPE_NAME});
      // when we create a new instance, we will register this to the factory,
      // this would allow the factory to identify the type or name when
      // creating an object
      factory::register_proxy(inst);
    end
    return inst;
  endfunction : get

endclass

// @brief stringifier utility macro.
//
// @usage suppose we have a class we define with name my_type. we can use
// `stringify` to return the class name as string name. example below
//
//  class my_type;
//    ...
//  endclass : my_type
//
//  string type_name = `stringify(my_type)
//  $display(type_name);
//
//  This will output "my_type".
`define stringify(s) `"s`"

// @brief component utils macro that provides proxy object registration. this
// must be called after a class declaration, which will register a type to the
// factory registry. later on, user can create object by type_name or by type
// itself.
//
// @usage example usage below
//
//    class MyClass extends object;
//      component_utils(MyClass);
//    endclass;
`define component_utils(_T) \
  typedef registry_proxy #(.T(_T), `stringify(_T)) \
    _T``_registry_proxy_t; \
  static _T``_registry_proxy_t registry = \
    _T``_registry_proxy_t::get();

// define an custom item that implements `object` type.
class item extends object;
  `component_utils(item)

  function new(string name);
    super.new(name);
  endfunction

endclass

module tb;

object my_item;

initial begin;
  // we can create an object without incuding the actual type. this is
  // powerful as now, class item is totally decoupled. we can define `class
  // item` in a different file, and on the top level, we can instantiate
  // `class item` without having an access to its actual type.
  //
  // the downside of this is it removes error detection at compilation stage.
  // this is the disadvantage of polymorphism, as type is determined at
  // runtime.
  my_item = factory::create_object_by_type_name("item", "my_item");
  $display("created my_item named: ", my_item.name);
end
  
endmodule : tb

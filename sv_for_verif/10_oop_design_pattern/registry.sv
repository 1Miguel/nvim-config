
class registry_proxy #(type T, `"S`");

  string name;
  string type_name;

  function new(string name);
    this.name = name;
  endfunction

  static function get();
    $display("Registry creation: %s", this.name);
  endfunction

endclass

class item;
  typedef registry_proxy #(.T(item), item) item_registry_proxy_t;
  static item_registry_proxy_t registry;
endclass

module tb;
  
initial begin;
  $display("hello");
end
  
endmodule

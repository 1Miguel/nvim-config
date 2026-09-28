// A simple Direct Map Cache implementatin
//
// Author: Miguel Ugsimar
//
// Some notes:
// * A Direct Mapped cache has one cache block in each set. It is organized
//   in 'S=B' which means the number of 'Set' matches the number of memory
//   block.
// * 'N-way' associative cache for example will have a relationship
//   of 'S=B/N' , since a set might refer to N number of blocks, which
//   attempts to resolve conflicts wherein several map address maps to the
//   same `set`.
// * The first cache request is a 'compulsory miss', since at first request
//   cache is in invalid state and will always fetch data.
// * A 'capacity miss' occurs when the cache size is too small to cache the
//   requested data.
// * A 'conflict miss' is when several map address is mapped to the same set,
//   access to these addresses will cause 'eviction'.

typedef enum {
  DM_CACHE_IDLE,
  DM_CACHE_CHECK,
  DM_CACHE_FETCH,
} dm_cache_state_t;

module dm_cache #(
  parameter int N=32,
  parameter int N_DATA_BITS=N,
  parameter int N_BYTE_OFFSET_BITS=2,
  parameter int N_VALID_BITS=1,
  parameter int N_SET_BITS=3,
  parameter int N_TAG_BITS=N - N_SET_BITS - N_BYTE_OFFSET_BITS,
  parameter int N_CACHE_ENTRY_BITS=(N_DATA_BITS + N_TAG_BITS + N_VALID_BITS)
) (
  logic clk_i,
  logic rst_n_i,
  logic rw_i,
  logic valid_i,
  logic [N-1:0] mem_addr_i,
  logic [N-1:0] data_i
);

  typedef struct packed {
    logic valid;
    logic[N_TAG_BITS-1:0] tag;
    logic[N_DATA_BITS-1:0] data;
  } dm_cache_entry_t;

  logic valid, next_valid;
  logic [N_SET_BITS-1:0] set, next_set;
  logic [N_BYTE_OFFSET_BITS-1:0] byte_offset, next_byte_offset;
  logic [N_TAG_BITS-1:0] tag, next_tag;
  dm_cache_entry cache_entries[2**N_SET_BITS];

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin

    end else begin

    end
  end

  // address decoder
  always_comb begin
    next_tag = tag;
    next_byte_offset = byte_offset;
    next_set = set;

    if (valid_i) begin
      // valid request, check if cache entry pointed
      // by the set bits is a hit (if valid is set)
      if (cache_entries[set].valid) begin
        
      end

    end


  end

endmodule : dm_cache

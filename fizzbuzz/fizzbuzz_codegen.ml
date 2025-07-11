(* vim: set sw=2 ts=2 et: *)
open Ctypes
open Foreign
open Unsigned

let prot_read = 1                (* PROT_READ *)
let prot_write = 2               (* PROT_WRITE *)
let prot_exec = 4                (* PROT_EXEC *)
let map_private = 2              (* MAP_PRIVATE *)
let map_anonymous = 0x20         (* MAP_ANONYMOUS - may vary by OS *)
let map_failed = ptr_of_raw_address Nativeint.(neg one)

let fizz_str = "fizz"
let buzz_str = "buzz"
let fizzbuzz_str = "fizzbuzz"
let int_fmt_str = "%i"
let buf_str = Bytes.make 32 ' '

let string_data_address (str:string) =
  let p = (Obj.magic str : int) in
  (p lsl 1) + 1

let bytes_data_address (str:bytes) =
  let p = (Obj.magic str : int) in
  (p lsl 1) + 1

let fizz = string_data_address fizz_str
let buzz = string_data_address buzz_str
let fizzbuzz = string_data_address fizzbuzz_str
let int_fmt = string_data_address int_fmt_str
let buf = bytes_data_address buf_str

let mmap =
  foreign "mmap"
    (ptr void                   (* addr *)
    @-> size_t                  (* length *)
    @-> int                     (* prot *)
    @-> int                     (* flags *)
    @-> int                     (* fd *)
    @-> PosixTypes.off_t        (* offset *)
    @-> returning (ptr void))   (* return *)

let munmap =
  foreign "munmap"
    (ptr void                   (* addr *)
    @-> size_t                  (* length *)
    @-> returning int)          (* return *)

let mprotect =
  foreign "mprotect"
    (ptr void @-> size_t @-> int @-> returning int)

let anon_map bytes =
  let addr = mmap
    null
    (Size_t.of_int bytes)
    (prot_read lor prot_write)
    (map_private lor map_anonymous)
    (-1)
    (PosixTypes.Off.of_int 0)
  in

  if addr = map_failed then
    failwith "mmap failed";

  let char_ptr = coerce (ptr void) (ptr int) addr in
  let carr = CArray.from_ptr char_ptr bytes in
  let bigarr = bigarray_of_array array1 Bigarray.int8_unsigned carr in

  ((bigarr,0), fun () ->
    let _ = munmap (to_voidp addr) (Size_t.of_int bytes) in ())

let make_executable (ba, _) =
  let addr = to_voidp (bigarray_start array1 ba) in
  let len = Unsigned.Size_t.of_int (Bigarray.Array1.dim ba) in
  let result = mprotect addr len (prot_read lor prot_exec) in
  if result < 0 then
    failwith "mprotect failed"

let function_of_memory (ba, _) =
  let fn_type = Foreign.funptr (void @-> returning void) in
  let addr = ptr_of_raw_address @@ Ctypes_bigarray.unsafe_address ba in
  coerce (ptr void) fn_type (addr)

let byte_array_of_int num =
  let bytes_in_int = Sys.word_size / 8 in
  Array.init bytes_in_int (fun i ->
    (num lsr (i * 8)) land 0xFF
  )

module X86_64 = struct
  module Rex = struct
    type t = int

    let base : t = 0b0100

    let w : t = (base lsl 4) lor 0b1000  (* REX.W - 64-bit operand size *)
    let r : t = (base lsl 4) lor 0b0100  (* REX.R - Extension of ModR/M reg field *)
    let x : t = (base lsl 4) lor 0b0010  (* REX.X - Extension of SIB index field *)
    let b : t = (base lsl 4) lor 0b0001  (* REX.B - Extension of ModR/M r/m field, SIB base, or opcode reg *)

    let wb : t = w lor b  (* REX.W + REX.B *)
    let wr : t = w lor r  (* REX.W + REX.R *)
    let wx : t = w lor x  (* REX.W + REX.X *)
    let rb : t = r lor b  (* REX.R + REX.B *)
    let rx : t = r lor x  (* REX.R + REX.X *)
    let xb : t = x lor b  (* REX.X + REX.B *)

    let wrx : t = w lor r lor x  (* REX.W + REX.R + REX.X *)
    let wrb : t = w lor r lor b  (* REX.W + REX.R + REX.B *)
    let wxb : t = w lor x lor b  (* REX.W + REX.X + REX.B *)
    let rxb : t = r lor x lor b  (* REX.R + REX.X + REX.B *)

    let wrxb : t = w lor r lor x lor b  (* REX.W + REX.R + REX.X + REX.B *)
  end

  let mov_r12 v = Array.append [|Rex.wb; 0xBC|] @@ byte_array_of_int v
  let mov_rdi v = Array.append [|Rex.w; 0xBF|] @@ byte_array_of_int v
  let mov_rsi v = Array.append [|Rex.w; 0xBE|] @@ byte_array_of_int v
  let mov_rax v = Array.append [|Rex.w; 0xB8|] @@ byte_array_of_int v
  let mov_rdx v = Array.append [|Rex.w; 0xBA|] @@ byte_array_of_int v

  let ret = [|0xC3|]
  let nop = [|0x90|]

  let mov_rdi_rax = [|Rex.w; 0x89; 0xC7|]
  let call_r12 = [|Rex.b; 0xFF; 0xD4|]
  let call_rax = [|0xFF; 0xD0|]
  let push_r12 = [|0x41; 0x54|]
  let pop_r12 = [|0x41; 0x5C|]
  let endbr64 = [|0xF3; 0x0F; 0x1E; 0xFA|]
end

let lib = Dl.dlopen ~filename:"" ~flags:[RTLD_GLOBAL; RTLD_NOW]
let puts = Nativeint.to_int @@ Dl.dlsym ~handle:lib ~symbol:"puts"
let sprintf = Nativeint.to_int @@ Dl.dlsym ~handle:lib ~symbol:"sprintf"

let blit (dst, off) src =
  let len = Array.length src in
  for i = 0 to len - 1 do
          dst.{off+i} <- src.(i)
  done;
  len

let rec push (mem,off) = function
  | [] -> (mem,off)
  | instr :: instrs ->
    let len = blit (mem,off) instr in
    push (mem,off+len) instrs

let fizzbuzz n =
  let size = 20 + 83 * n + 3 in
  let mem, unmap = anon_map size in

  let open X86_64 in
  let mem = ref mem in
  mem := push !mem [
    endbr64;
    nop; nop; nop; nop;
    push_r12;
    mov_r12 puts];

  for i = 1 to n do
    match (i mod 3 == 0, i mod 5 == 0) with
    | (false, false) -> (
      mem := push !mem [
        nop; nop; nop;
        nop; nop; nop;
        (mov_rax sprintf);
        nop; nop; nop;
        nop; nop; nop;
        (mov_rdx i);
        nop; nop; nop;
        nop; nop; nop;
        (mov_rdi buf);
        nop; nop; nop;
        nop; nop; nop;
        (mov_rsi int_fmt);
        call_rax;
        nop; nop; nop; nop;
        (mov_rdi buf);
        call_r12
      ]
    )
    | (true, false) -> (
      mem := push !mem [
        nop; nop; nop;
        nop; nop; nop;
        (mov_rdi fizz);
        call_r12;
        nop; nop; nop;
        nop; nop;
      ]
    )
    | (false, true) -> (
      mem := push !mem [
        nop; nop; nop;
        nop; nop; nop;
        (mov_rdi buzz);
        call_r12;
        nop; nop; nop;
        nop; nop;
      ]
    )
    | (true, true) -> (
      mem := push !mem [
        nop; nop; nop;
        nop; nop; nop;
        (mov_rdi fizzbuzz);
        call_r12;
        nop; nop; nop;
        nop; nop;
      ]
    )
  done;

  mem := push !mem [pop_r12; ret];

  make_executable !mem;
  let f = function_of_memory !mem in
  f ();
  unmap ()

let () =
  match Sys.argv with
  | [|_|] -> failwith "No arguments provided"
  | [|_; n|] -> fizzbuzz @@ int_of_string n
  | _ -> failwith "Too many arguments provided"

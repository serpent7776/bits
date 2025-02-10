use std::convert::TryInto;

/* https://wiki.osdev.org/X86-64_Instruction_Encoding#REX_prefix */
static REX: u8 = 0b0100;
static REX_W: u8 = REX << 4 | 0b1000;
static REX_R: u8 = REX << 4 | 0b0100;
static REX_X: u8 = REX << 4 | 0b0010;
static REX_B: u8 = REX << 4 | 0b0001;
static REX_WB: u8 = REX_W | REX_B;
static MOV_R12: u8 = 0xBC;
static MOV_RDI: u8 = 0xBF;
static MOV_RSI: u8 = 0xBE;
static MOV_RAX: u8 = 0xB8;
static MOV_RDI_RAX: [u8; 2] = [0x89, 0xC7];
static MOV_RSI_RAX_REF: [u8; 2] = [0x8B, 0x30]; // mov RSI, [RAX]
static CALL_R12: [u8; 2] = [0xFF, 0xD4];
static CALL_RAX: [u8; 2] = [0xFF, 0xD0];
static PUSH_R12: [u8; 2] = [0x41, 0x54];
static POP_R12: [u8; 2] = [0x41, 0x5c];
static RET: u8 = 0xC3;

static FIZZ: &str = "fizz";
static BUZZ: &str = "buzz";
static FIZZBUZZ: &str = "fizzbuzz";

fn usage() {
    println!("./fizzbuzz N");
    println!("Prints fizzbuzz for numbers 1-N by generating x86 code at runtime.");
}

static mut NUMBUF: [u8; 21] = [0; 21];
extern "C"
fn itoa(mut n: u64, len: *mut u64) -> *const u8 {
    if n == 0 {
        unsafe {
            NUMBUF[0] = '0' as u8;
            NUMBUF[1] = 0;
            *len = 1;
            return &NUMBUF[0];
        }
    }
    else {
            let mut i: i64 = 20;
            while n > 0 {
                unsafe { NUMBUF[i as usize] = ('0' as u8) + (n % 10) as u8; }
                n /= 10;
                i -= 1;
            }
            unsafe {
                *len = (20 - i) as u64;
                return &NUMBUF[(i+1) as usize];
            }
    }
}

extern "C"
fn puts(p: *const u8, sz: usize) {
    let slice = unsafe { std::slice::from_raw_parts(p, sz) };
    println!("{}", std::str::from_utf8(slice).unwrap());
}

type off_t = isize;
extern "C" {
    fn sysconf(name: i32) -> i64;
    // static _SC_PAGESIZE: i32;
    fn mmap(addr: *mut std::ffi::c_void,
        len: usize,
        prot: i32,
        flags: i32,
        fd: i32,
        offset: off_t) -> *mut std::ffi::c_void;
    fn mprotect(addr: *mut std::ffi::c_void, len: usize, prot: i32);
}
const _SC_PAGESIZE: i32 = 30;
const PROT_READ: i32 = 0x01;
const PROT_WRITE: i32 = 0x02;
const PROT_EXEC: i32 = 0x04;
const MAP_PRIVATE: i32 = 0x02;
const MAP_ANONYMOUS: i32 = 0x20;

pub fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        usage();
        std::process::exit(1);
    }

    let n: i32 = args[1].parse().unwrap();
    if n == 0 {
        std::process::exit(0);
    }
    if n < 0 {
        std::process::exit(1);
    }

    let pagesize = unsafe { sysconf(_SC_PAGESIZE) };
    if pagesize == -1 {
        eprintln!("sysconf error");
        std::process::exit(1);
    }

    let required_bytes: i64 = (12 + 50 * n + 3).into();
    let num_pages = required_bytes / pagesize + 1;

    let size:usize = (pagesize * num_pages).try_into()?;

    let page = unsafe {
        mmap(std::ptr::null_mut(),
            size,
            PROT_READ | PROT_WRITE | PROT_EXEC,
            MAP_PRIVATE | MAP_ANONYMOUS,
            -1,
            0)
    };

    fn byte(m: *mut u8, b: u8) -> *mut u8 {
        unsafe {
            *m = b;
            m.offset(1)
        }
    }
    fn bytes<const N: usize>(m: *mut u8, b: [u8; N]) -> *mut u8 {
        unsafe {
            for (i, byte) in b.iter().enumerate() {
                *m.offset(i as isize) = *byte;
            }
            m.offset(b.len() as isize)
        }
    }
    fn qword(m: *mut u8, b: u64) -> *mut u8 {
        unsafe {
            let bytes = b.to_le_bytes();
            for i in 0..8 {
                *m.offset(i as isize) = bytes[i];
            }
            m.offset(8)
        }
    }

    let mut m = page as *mut u8;
    let mut len:u64 = 0;

    m = bytes(m, PUSH_R12);
    m = byte(m, REX_WB); m = byte(m, MOV_R12); m = qword(m, puts as usize as u64);
    for i in 1..=n {
        let f:i32 = (i % 3 == 0).into();
        let b:i32 = (i % 5 == 0).into();
        match (b << 1) | f {
            0b00 => {
                m = byte(m, REX_W); m = byte(m, MOV_RAX); m = qword(m, itoa as usize as u64);
                m = byte(m, REX_W); m = byte(m, MOV_RDI); m = qword(m, i as u64);
                m = byte(m, REX_W); m = byte(m, MOV_RSI); m = qword(m, &mut len as *mut u64 as usize as u64);
                m = bytes(m, CALL_RAX);
                m = byte(m, REX_W); m = bytes(m, MOV_RDI_RAX);
                m = byte(m, REX_W); m = byte(m, MOV_RAX); m = qword(m, &mut len as *mut u64 as usize as u64);
                m = byte(m, REX_W); m = bytes(m, MOV_RSI_RAX_REF);
                m = byte(m, REX_B); m = bytes(m, CALL_R12);
            },
            0b01 => {
                m = byte(m, REX_W); m = byte(m, MOV_RDI); m = qword(m, FIZZ.as_ptr() as usize as u64);
                m = byte(m, REX_W); m = byte(m, MOV_RSI); m = qword(m, FIZZ.len() as u64);
                m = byte(m, REX_B); m = bytes(m, CALL_R12);
            },
            0b10 => {
                m = byte(m, REX_W); m = byte(m, MOV_RDI); m = qword(m, BUZZ.as_ptr() as usize as u64);
                m = byte(m, REX_W); m = byte(m, MOV_RSI); m = qword(m, BUZZ.len() as u64);
                m = byte(m, REX_B); m = bytes(m, CALL_R12);
            },
            0b11 => {
                m = byte(m, REX_W); m = byte(m, MOV_RDI); m = qword(m, FIZZBUZZ.as_ptr() as usize as u64);
                m = byte(m, REX_W); m = byte(m, MOV_RSI); m = qword(m, FIZZBUZZ.len() as u64);
                m = byte(m, REX_B); m = bytes(m, CALL_R12);
            },
            _ => panic!(),
        }
    }
    m = bytes(m, POP_R12);
    byte(m, RET);

    unsafe { mprotect(page, size, PROT_READ|PROT_EXEC) }

    let pf: fn() = unsafe { std::mem::transmute(page) };
    pf();

    Ok(())
}

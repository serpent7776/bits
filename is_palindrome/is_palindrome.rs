use std::env;
use std::process;

pub fn is_palindrome(s: &str) -> bool {
    let f = s.chars();
    let b = s.chars().rev();

    f.zip(b).take(s.len() / 2).all(|(a, b)| a==b)
}

pub fn main() {
    let first_arg = env::args_os()
        .nth(1)
        .expect("Expected at least one argument")
        .to_str()
        .unwrap_or("")
        .to_string();

    if is_palindrome(&first_arg) {
        process::exit(0);
    } else {
        process::exit(1);
    }
}

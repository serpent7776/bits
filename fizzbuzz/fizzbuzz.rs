pub fn main() {
    for n in 1..=100 {
        print!("{}\n", fizzbuzz(n));
    }
}

fn fizzbuzz(n: u32) -> String {
    match (n % 3, n % 5) {
        (0, 0) => "fizzbuzz".to_string(),
        (0, _) => "fizz".to_string(),
        (_, 0) => "buzz".to_string(),
        (_, _) => n.to_string(),
    }
}

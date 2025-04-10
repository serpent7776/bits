// Rust Bytes Challenge Issue #60 The Word Ladder

fn dist(a: &str, b: &str) -> u32 {
    a.chars().zip(b.chars()).fold(0, |d, (a, b)| d+(a!=b) as u32)
}

fn converge<T:Eq+Copy, F:Fn(T)->T>(mut val:T, f:F) -> T {
    let prev:T = val;
    loop {
        val = f(prev);
        if val == prev {break;}
    }
    val
}

fn find_word_ladder(start: String, end: String, dictionary: Vec<String>) -> Option<Vec<String>> {
    let mut g: Vec<(&str,&str)> = vec![];
    for i in 0..dictionary.len() {
        for j in (i+1)..dictionary.len() {
            if dist(&dictionary[i], &dictionary[j]) == 1 {
                g.push((&dictionary[i], &dictionary[j]));
            }
        }
    }
    let mut paths: Vec<Vec<&str>> = vec![vec![&start]];
    let mut results: Vec<Vec<&str>> = vec![];
    while paths.len() > 0 {
        let p = paths.pop().unwrap();
        let t = p.last().unwrap();
        for (x,y) in g.iter() {
            if x == t {
                let mut pc = p.clone();
                pc.push(y);
                paths.push(pc);
            }
        }
        if t == &end {
            results.push(p);
        }
    }
    results.into_iter().max_by(|a,b| a.len().cmp(&b.len())).map(|v| v.into_iter().map(|s| s.to_owned()).collect())
}

#[cfg(test)]
mod tests {
    use super::*;

    // Test Case 1: Basic ladder
    #[test]
    fn test_short_ladder() {
        let start = String::from("hit");
        let end = String::from("cog");
        let dictionary = vec![
            String::from("hit"),
            String::from("hot"),
            String::from("dot"),
            String::from("dog"),
            String::from("cog"),
        ];
        let result = find_word_ladder(start, end, dictionary);
        assert!(result.is_some());
        let ladder = result.unwrap();
        assert_eq!(
            ladder,
            vec![
                String::from("hit"),
                String::from("hot"),
                String::from("dot"),
                String::from("dog"),
                String::from("cog"),
            ]
        );
    }

    // Test Case 2: No ladder possible
    #[test]
    fn test_no_ladder() {
        let start = String::from("cat");
        let end = String::from("zip");
        let dictionary = vec![
            String::from("cat"),
            String::from("cot"),
            String::from("cog"),
        ];
        let result = find_word_ladder(start, end, dictionary);
        assert!(result.is_none());
    }

    // Test Case 3: Start and end are the same
    #[test]
    fn test_same_word() {
        let start = String::from("cat");
        let end = String::from("cat");
        let dictionary = vec![
            String::from("cat"),
            String::from("cot"),
            String::from("cog"),
        ];
        let result = find_word_ladder(start, end, dictionary);
        assert!(result.is_some());
        let ladder = result.unwrap();
        assert_eq!(ladder, vec![String::from("cat")]);
    }

    // Test Case 4: Longer ladder with multiple paths
    #[test]
    fn test_longer_ladder() {
        let start = String::from("lead");
        let end = String::from("gold");
        let dictionary = vec![
            String::from("lead"),
            String::from("load"),
            String::from("goad"),
            String::from("gold"),
            String::from("lewd"), // Extra word, not in shortest path
        ];
        let result = find_word_ladder(start, end, dictionary);
        assert!(result.is_some());
        let ladder = result.unwrap();
        assert_eq!(
            ladder,
            vec![
                String::from("lead"),
                String::from("load"),
                String::from("goad"),
                String::from("gold"),
            ]
        );
    }
}

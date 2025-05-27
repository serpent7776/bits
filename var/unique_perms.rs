// Rust Bytes Issue 67: Generate All String Permutations
pub fn generate_permutations(s: &str) -> Vec<String> {
    let mut p = vec![];
    let mut b = s.bytes().collect::<Vec<u8>>();
    b.sort();
    p.push(std::str::from_utf8(&b).unwrap().into());
    while let Some ((i, x)) = b.windows(2).enumerate().rfind(|&(_, w)| w[0] < w[1]) {
            let (j, _) = b.iter().enumerate().skip(i+1).rfind(|(_,y)| **y > x[0]).unwrap();
            b.swap(i, j);
            b[i+1..].reverse();
            p.push(std::str::from_utf8(&b).unwrap().into());
    }
    p
}

#[cfg(test)]
mod tests {
    use super::*;

    fn run_test(input: &str, expected: Vec<&str>, test_name: &str) {
        let mut result = generate_permutations(input);
        let mut expected_vec: Vec<String> = expected.iter().map(|&s| s.to_string()).collect();

        result.sort();
        expected_vec.sort();

        assert_eq!(
            result, expected_vec,
            "Test case '{}' failed: input={}, expected={:?}, got={:?}",
            test_name, input, expected_vec, result
        );
        println!(
            "Test case '{}' passed: input={}, output={:?}",
            test_name, input, result
        );
    }

    #[test]
    fn test_basic_aabb() {
        run_test(
            "aabb",
            vec!["aabb", "abab", "abba", "baab", "baba", "bbaa"],
            "basic_aabb",
        );
    }

    #[test]
    fn test_basic_xyz() {
        run_test(
            "xyz",
            vec!["xyz", "xzy", "yxz", "yzx", "zxy", "zyx"],
            "basic_xyz",
        );
    }

    #[test]
    fn test_basic_aabc() {
        run_test(
            "aabc",
            vec![
                "aabc", "aacb", "abac", "abca", "acab", "acba", "baac", "baca", "bcaa", "caab",
                "caba", "cbaa",
            ],
            "basic_aabc",
        );
    }

    #[test]
    fn test_edge_empty() {
        run_test("", vec![""], "edge_empty");
    }

    #[test]
    fn test_edge_single_char() {
        run_test("a", vec!["a"], "edge_single_char");
    }

    #[test]
    fn test_edge_all_same() {
        run_test("aaa", vec!["aaa"], "edge_all_same");
    }

    #[test]
    fn test_edge_unique_chars() {
        run_test(
            "abc",
            vec!["abc", "acb", "bac", "bca", "cab", "cba"],
            "edge_unique_chars",
        );
    }

    #[test]
    fn test_repeated_two() {
        run_test("aba", vec!["aab", "aba", "baa"], "repeated_two");
    }

    #[test]
    fn test_repeated_three() {
        run_test(
            "abbc",
            vec![
                "abbc", "abcb", "acbb", "babc", "bacb", "bbac", "bbca", "bcab", "bcba", "cabb",
                "cbab", "cbba",
            ],
            "repeated_three",
        );
    }

    #[test]
    fn test_repeated_multiple() {
        run_test(
            "aabbc",
            vec![
                "aabbc", "aabcb", "aacbb", "ababc", "abacb", "abbac", "abbca", "abcab", "abcba",
                "acabb", "acbab", "acbba", "baabc", "baacb", "babac", "babca", "bacab", "bacba",
                "bbaac", "bbaca", "bbcaa", "bcaab", "bcaba", "bcbaa", "caabb", "cabab", "cabba",
                "cbaab", "cbaba", "cbbaa",
            ],
            "repeated_multiple",
        );
    }

    #[test]
    fn test_digits() {
        run_test("121", vec!["112", "121", "211"], "digits");
    }

    #[test]
    fn test_special_chars() {
        run_test(
            "!@#",
            vec!["!@#", "!#@", "@!#", "@#!", "#!@", "#@!"],
            "special_chars",
        );
    }
}

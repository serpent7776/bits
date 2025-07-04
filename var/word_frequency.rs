// Rust Bytes Issue 73: Word Frequency Counter

pub fn word_frequency(input: &str) -> Vec<(String, u32)> {
    let mut wf = vec![];
    for w in input.split(|c: char| !(c.is_alphanumeric() || c == '\'' || c == '-')) {
        let mut w = w.to_lowercase();
        if w == "" || w == "-" || w.starts_with(&['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
            continue
        }
        w.retain(|c: char| !(c == '-' || c == '\'' || ('0'..='9').contains(&c)));
        match wf.binary_search_by_key(&&w, |(s,_): &(String,u32)| s) {
            Ok(idx) => {wf[idx].1 += 1}
            Err(idx) => {wf.insert(idx, (w, 1))}
        }
    }
    wf
}

#[cfg(test)]
mod tests {
    use super::word_frequency;

    #[test]
    fn basic_case() {
        let input = "The quick brown fox, the quick Brown FOX!";
        let expected = vec![
            ("brown".to_string(), 2),
            ("fox".to_string(), 2),
            ("quick".to_string(), 2),
            ("the".to_string(), 2),
        ];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn empty_string() {
        let input = "";
        let expected: Vec<(String, u32)> = vec![];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn only_punctuation() {
        let input = ".,!?;:-";
        let expected: Vec<(String, u32)> = vec![];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn single_word() {
        let input = "hello";
        let expected = vec![("hello".to_string(), 1)];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn multiple_spaces_and_punctuation() {
        let input = "hello,,,   world!!!   HELLO.";
        let expected = vec![("hello".to_string(), 2), ("world".to_string(), 1)];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn numbers_and_mixed_chars() {
        let input = "test123 test 123test TEST!";
        let expected = vec![("test".to_string(), 3)];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn hyphenated_words() {
        let input = "well-known well-Known WELL-KNOWN";
        let expected = vec![("wellknown".to_string(), 3)];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn apostrophes_in_words() {
        let input = "don't Don'T cant can't";
        let expected = vec![("cant".to_string(), 2), ("dont".to_string(), 2)];
        assert_eq!(word_frequency(input), expected);
    }

    #[test]
    fn unicode_words() {
        let input = "café CAFÉ résumé Résumé";
        let expected = vec![("café".to_string(), 2), ("résumé".to_string(), 2)];
        assert_eq!(word_frequency(input), expected)
    }
}

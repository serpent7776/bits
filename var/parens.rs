// Rust Bytes Challenge Issue #56 Ensure Valid Parentheses

pub fn is_valid(s: String) -> bool {
    s.chars().
        fold(("".to_string(), true), |(mut p,r), c| match c {
            '(' => {p.push(c); (p, r)}
            ')' => {let x = p.pop(); (p, r && x.unwrap_or(' ') == '(')}
            '[' => {p.push(c); (p, r)}
            ']' => {let x = p.pop(); (p, r && x.unwrap_or(' ') == '[')}
            '{' => {p.push(c); (p, r)}
            '}' => {let x = p.pop(); (p, r && x.unwrap_or(' ') == '{')}
            _ => panic!(),
        }) == ("".to_string(), true)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_case_1() {
        assert_eq!(is_valid("()[]{}".to_string()), true);
    }

    #[test]
    fn test_valid_case_2() {
        assert_eq!(is_valid("{[()]}".to_string()), true);
    }

    #[test]
    fn test_valid_case_3() {
        assert_eq!(is_valid("{[({})]}".to_string()), true);
    }

    #[test]
    fn test_invalid_case_1() {
        assert_eq!(is_valid("([)]".to_string()), false);
    }

    #[test]
    fn test_invalid_case_1b() {
        assert_eq!(is_valid("[(])".to_string()), false);
    }

    #[test]
    fn test_invalid_case_2() {
        assert_eq!(is_valid("((()".to_string()), false);
    }

    #[test]
    fn test_invalid_case_3() {
        assert_eq!(is_valid("{[}".to_string()), false);
    }

    #[test]
    fn test_invalid_case_4() {
        assert_eq!(is_valid("({()}".to_string()), false);
    }

    #[test]
    fn test_invalid_case_5() {
        assert_eq!(is_valid("{(((((((((())))))))))]".to_string()), false);
    }
}

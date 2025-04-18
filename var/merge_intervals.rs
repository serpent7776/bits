// Rust Bytes Challenge Issue #62: Merge Intervals
use std::cmp::max;

pub fn merge_intervals(mut intervals: Vec<(i32, i32)>) -> Vec<(i32, i32)> {
    if intervals.len() == 0 {
        return intervals;
    }
    intervals.sort();
    let cross = |(_, b), (x, _)| { x <= b };
    let merge = |(a, x), (_, y)| { (a, max(x, y)) };
    let mut w = 0;
    for r in 1..intervals.len() {
        if cross(intervals[w], intervals[r]) {
            intervals[w] = merge(intervals[w], intervals[r]);
        } else {
            w += 1;
            intervals[w] = intervals[r];
        }
    }
    intervals.resize(w+1, (0, 0));
    intervals
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_overlap() {
        assert_eq!(
            merge_intervals(vec![(1, 3), (2, 6), (8, 10), (15, 18)]),
            vec![(1, 6), (8, 10), (15, 18)]
        );
    }

    #[test]
    fn test_empty_vector() {
        assert_eq!(merge_intervals(vec![]), vec![]);
    }

    #[test]
    fn test_no_overlap() {
        assert_eq!(
            merge_intervals(vec![(1, 2), (3, 4), (5, 6)]),
            vec![(1, 2), (3, 4), (5, 6)]
        );
    }

    #[test]
    fn test_all_overlapping() {
        assert_eq!(merge_intervals(vec![(1, 4), (2, 5), (3, 6)]), vec![(1, 6)]);
    }

    #[test]
    fn test_single_interval() {
        assert_eq!(merge_intervals(vec![(5, 10)]), vec![(5, 10)]);
    }

    #[test]
    fn test_negative_intervals() {
        assert_eq!(
            merge_intervals(vec![(-5, -2), (-3, 0), (1, 3)]),
            vec![(-5, 0), (1, 3)]
        );
    }

    #[test]
    fn test_overlapping_with_same_start() {
        assert_eq!(
            merge_intervals(vec![(1, 5), (1, 3), (6, 8)]),
            vec![(1, 5), (6, 8)]
        );
    }

    #[test]
    fn test_large_gaps() {
        assert_eq!(
            merge_intervals(vec![(1, 2), (10, 11), (20, 21)]),
            vec![(1, 2), (10, 11), (20, 21)]
        );
    }

    #[test]
    fn test_nested_intervals() {
        assert_eq!(
            merge_intervals(vec![(1, 10), (2, 3), (4, 5), (7, 8)]),
            vec![(1, 10)]
        );
    }

    #[test]
    fn test_adjacent_intervals() {
        assert_eq!(merge_intervals(vec![(1, 2), (2, 3), (3, 4)]), vec![(1, 4)]);
    }

    #[test]
    fn test_unsorted_input() {
        assert_eq!(
            merge_intervals(vec![(15, 18), (1, 3), (8, 10), (2, 6)]),
            vec![(1, 6), (8, 10), (15, 18)]
        );
    }

    #[test]
    fn test_zero_length_intervals() {
        assert_eq!(merge_intervals(vec![(1, 1), (2, 2), (1, 3)]), vec![(1, 3)]);
    }
}

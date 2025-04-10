// Rust Bytes Challenge Issue #61 Rotate a Matrix 90 Degrees
pub fn rotate_matrix(matrix: &mut Vec<Vec<i32>>) {
    let n = matrix.len();
    let square = matrix.iter().all(|m| m.len() == n);
    if square {
        return rotate_square_matrix(matrix)
    }
    let rect = matrix.iter().is_sorted_by(|x, y| x.len() == y.len());
    if rect {
        return rotate_rect_matrix(matrix, n, matrix[1].len())
    }
    panic!("Matrix is neither square nor rectangular");
}

fn rotate_square_matrix(matrix: &mut Vec<Vec<i32>>) {
    let n = matrix.len() as i32;
    let h = n / 2;
    let even = (n % 2 == 0) as i32;
    let rot =  |matrix: &mut Vec<Vec<i32>>, x:i32,y:i32, val: i32| {
        let x2 = - (y - h) + h + -1 * even;
        let y2 = (x - h) + h;
        let val2 = std::mem::replace(&mut matrix[y2 as usize][x2 as usize], val);
        (x2, y2, val2)
    };
    for i in 0..(n/2) {
        for j in i..(n-i-1) {
            let x = i+j;
            let y = i;
            let val = matrix[y as usize][x as usize];
            let (x, y, val) = rot(matrix, x, y, val);
            let (x, y, val) = rot(matrix, x, y, val);
            let (x, y, val) = rot(matrix, x, y, val);
            let (_, _, _) = rot(matrix, x, y, val);
        }
    }
}

fn rotate_rect_matrix(matrix: &mut Vec<Vec<i32>>, n:usize, k:usize) {
    let mut m: Vec<Vec<i32>> = vec![];
    m.resize(k, vec![]);
    for i in 0..k {
        m[i].resize(n, 0);
    }
    for i in 0..k {
        for j in 0..n {
            m[i][n-j-1] = matrix[j][i];
        }
    }
    *matrix = m;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rotate_matrix_3x3() {
        let mut matrix = vec![vec![1, 2, 3], vec![4, 5, 6], vec![7, 8, 9]];
        rotate_matrix(&mut matrix);
        assert_eq!(matrix, vec![vec![7, 4, 1], vec![8, 5, 2], vec![9, 6, 3]]);
    }

    #[test]
    fn test_rotate_matrix_2x2() {
        let mut matrix = vec![vec![1, 2], vec![3, 4]];
        rotate_matrix(&mut matrix);
        assert_eq!(matrix, vec![vec![3, 1], vec![4, 2]]);
    }

    #[test]
    fn test_rotate_matrix_1x1() {
        let mut matrix = vec![vec![5]];
        rotate_matrix(&mut matrix);
        assert_eq!(matrix, vec![vec![5]]);
    }

    #[test]
    fn test_rotate_matrix_4x4() {
        let mut matrix = vec![
            vec![1, 2, 3, 4],
            vec![5, 6, 7, 8],
            vec![9, 10, 11, 12],
            vec![13, 14, 15, 16],
        ];
        rotate_matrix(&mut matrix);
        assert_eq!(
            matrix,
            vec![
                vec![13, 9, 5, 1],
                vec![14, 10, 6, 2],
                vec![15, 11, 7, 3],
                vec![16, 12, 8, 4]
            ]
        );
    }

    #[test]
    fn test_rotate_matrix_empty() {
        let mut matrix: Vec<Vec<i32>> = Vec::new();
        rotate_matrix(&mut matrix);
        assert_eq!(matrix, Vec::<Vec<i32>>::new());
    }

    #[test]
    fn test_rotate_matrix_single_column() {
        let mut matrix = vec![vec![1], vec![2], vec![3], vec![4]];
        rotate_matrix(&mut matrix);
        assert_eq!(matrix, vec![vec![4, 3, 2, 1]]);
    }

    #[test]
    fn test_rotate_matrix_rect_matrix() {
        let mut matrix = vec![vec![1, 2], vec![2, 3], vec![3, 4], vec![4, 5]];
        rotate_matrix(&mut matrix);
        assert_eq!(matrix, vec![vec![4, 3, 2, 1], vec![5, 4, 3, 2]]);
    }

    #[test]
    fn test_rotate_matrix_large() {
        let mut matrix = vec![
            vec![1, 2, 3, 4, 5],
            vec![6, 7, 8, 9, 10],
            vec![11, 12, 13, 14, 15],
            vec![16, 17, 18, 19, 20],
            vec![21, 22, 23, 24, 25],
        ];
        rotate_matrix(&mut matrix);
        assert_eq!(
            matrix,
            vec![
                vec![21, 16, 11, 6, 1],
                vec![22, 17, 12, 7, 2],
                vec![23, 18, 13, 8, 3],
                vec![24, 19, 14, 9, 4],
                vec![25, 20, 15, 10, 5]
            ]
        );
    }
}

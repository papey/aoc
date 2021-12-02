use std::fs;
use std::io;

#[allow(dead_code)]
pub struct Input {
    lines: Vec<String>,
    day: u32,
    year: u32,
}

#[allow(dead_code)]
impl Input {
    pub fn new(path: String, day: u32, year: u32) -> Result<Input, io::Error> {
        let raw_input = fs::read_to_string(path)?;
        Ok(Input {
            lines: raw_input
                .trim()
                .split("\n")
                .map(|s| s.trim().to_string())
                .collect(),
            day: day,
            year: year,
        })
    }

    pub fn transform<T>(&self, f: fn(input: String) -> T) -> Vec<T> {
        self.lines.clone().into_iter().map(|line| f(line)).collect()
    }

    pub fn lines(&self) -> Vec<String> {
        self.lines.clone()
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn new_input() {
        let result = super::Input::new("./inputs/test".to_string(), 1, 2021);
        assert!(result.is_ok());
        let input = result.unwrap();
        assert_eq!(input.year, 2021);
        assert_eq!(input.lines.len(), 10);
    }
}

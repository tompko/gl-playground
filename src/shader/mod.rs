use std::path::Path;
use std::fs::File;
use std::io::{self, BufReader, BufRead};
use regex::Regex;

pub struct Shader {
    buffer: String
}

impl Shader {
    pub fn load<P: AsRef<Path>>(path: P) -> io::Result<Shader> {
        lazy_static! {
            static ref RE: Regex = Regex::new(r#"\w*#\w*include "(.*)""#).unwrap();
        };

        let mut contents = String::new();

        let file = File::open(path)?;
        let reader = BufReader::new(file);

        for line in reader.lines() {
            let line = line?;
            if let Some(caps) = RE.captures(&line) {
                let sub_shader = Shader::load(caps.get(1).unwrap().as_str())?;
                contents += sub_shader.as_source();
            } else {
                contents += &line;
            }
            contents += "\n";
        }

        Ok(Shader{buffer: contents})
    }

    pub fn as_source(&self) -> &str {
        &self.buffer
    }
}

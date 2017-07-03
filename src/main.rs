#[macro_use]
extern crate glium;
#[macro_use]
extern crate lazy_static;
extern crate notify;
extern crate regex;
extern crate time;

mod shader;

use std::sync::mpsc::{channel, TryRecvError};
use std::time::Duration;
use glium::{DisplayBuild, Surface};
use glium::glutin::VirtualKeyCode;
use notify::{RecommendedWatcher, Watcher, RecursiveMode};
use time::precise_time_s;
use shader::Shader;

#[derive(Copy, Clone)]
struct Vertex {
    position: [f32; 2],
}

implement_vertex!(Vertex, position);

fn load_shaders(display: &glium::Display) -> Result<glium::Program, glium::program::ProgramCreationError> {
    let vertex_shader = Shader::load("shaders/norm.vert").unwrap();
    let fragment_shader = Shader::load("shaders/est.frag").unwrap();

    glium::Program::from_source(
        display,
        vertex_shader.as_source(),
        fragment_shader.as_source(),
        None,
    )
}

fn main() {
    let (ntx, nrx) = channel();
    let mut watcher: RecommendedWatcher = Watcher::new(ntx, Duration::from_secs(2)).unwrap();

    watcher.watch("shaders", RecursiveMode::Recursive).unwrap();

    let display = glium::glutin::WindowBuilder::new().build_glium().unwrap();

    let vertex1 = Vertex { position: [-1.0, -1.0] };
    let vertex2 = Vertex { position: [ -1.0,  1.0] };
    let vertex3 = Vertex { position: [ 1.0, -1.0] };
    let vertex4 = Vertex { position: [1.0, 1.0] };
    let shape = vec![vertex1, vertex2, vertex3, vertex4];

    let vertex_buffer = glium::VertexBuffer::new(&display, &shape).unwrap();

    let indices = glium::index::NoIndices(glium::index::PrimitiveType::TriangleStrip);

    let mut program = load_shaders(&display).unwrap();
    // let vertex_shader = Shader::load("shaders/norm.vert").unwrap();
    // let fragment_shader = Shader::load("shaders/est.frag").unwrap();

    // let program = glium::Program::from_source(
    //     &display,
    //     vertex_shader.as_source(),
    //     fragment_shader.as_source(),
    //     None,
    // ).unwrap();

    let start = precise_time_s();

    loop {
        let t = (precise_time_s() - start) as f32;

        let mut target = display.draw();
        let uniforms = uniform! {
            iGlobalTime: t,
            iResolution: (1, 1),
            iMouse: (0, 0),
        };

        target.clear_color(0.0, 1.0, 1.0, 1.0);
        target.draw(&vertex_buffer, &indices, &program, &uniforms,
                                &Default::default()).unwrap();
        target.finish().unwrap();

        for ev in display.poll_events() {
            match ev {
                glium::glutin::Event::Closed => return,
                glium::glutin::Event::KeyboardInput(_, _, Some(VirtualKeyCode::Escape)) => return,
                _ => (),
            }
        }

        match nrx.try_recv() {
            Ok(event) => {
                println!("Event: {:?}", event);
                println!("Reloading shaders");
                match load_shaders(&display) {
                    Ok(p) => program = p,
                    Err(e) => println!("Error compiling shaders: {:?}", e),
                }
            }
            Err(TryRecvError::Empty) => {},
            Err(TryRecvError::Disconnected) => panic!("Watch channel disconnected"),
        }
    }

}

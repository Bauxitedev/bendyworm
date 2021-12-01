use gdnative::prelude::*;

use crate::path_rasterizer::PathRasterizer;

pub mod path_rasterizer;

godot_init!(init);

fn init(handle: InitHandle) {
    println!("Rust library loaded, registering classes...");
    handle.add_class::<PathRasterizer>();
}

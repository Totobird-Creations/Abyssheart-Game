#![feature(let_chains)]
#![allow(unused_parens)]

use gdnative::prelude::*;

mod generator;
mod tool;



fn init(handle : InitHandle) -> () {
    generator::init(handle);
}



godot_init!(init);


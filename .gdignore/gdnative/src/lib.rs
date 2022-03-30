#![feature(let_chains)]
#![allow(unused_parens)]

use gdnative::prelude::*;

mod entity;
mod tool;



fn init(handle : InitHandle) -> () {
    entity::init(handle);
}



godot_init!(init);


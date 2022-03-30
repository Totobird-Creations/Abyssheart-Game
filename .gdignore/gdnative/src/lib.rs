#![feature(let_chains)]
#![allow(unused_parens)]

use gdnative::prelude::*;

mod tool;
mod generator;



fn init(handle : InitHandle) -> () {
    handle.add_class::<generator::FeatureGenerator>();
}



godot_init!(init);


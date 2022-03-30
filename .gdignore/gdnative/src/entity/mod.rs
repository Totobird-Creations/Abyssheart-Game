use gdnative::prelude::*;

mod player;



pub fn init(handle : InitHandle) -> () {
    handle.add_class::<player::PlayerEntity>();
}

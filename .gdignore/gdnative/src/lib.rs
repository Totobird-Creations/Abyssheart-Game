use gdnative::prelude::*;

mod example;



fn init(handle : InitHandle) {
    handle.add_class::<example::HelloWorld>();
}



godot_init!(init);


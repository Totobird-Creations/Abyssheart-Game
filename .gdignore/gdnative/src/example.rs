use gdnative::prelude::*;



#[derive(NativeClass)]
#[inherit(Node)]
pub struct HelloWorld {
}
impl HelloWorld {
    fn new(_owner : &Node) -> Self {
        HelloWorld {}
    }
}



#[methods]
impl HelloWorld {

    #[export]
    fn _ready(&self, _owner : &Node) {
        godot_print!("Hello World!");
    }

}


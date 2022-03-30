use gdnative::prelude::*;



pub trait GetNodeTRef {
    fn get_node_tref<R : SubClass<Node>>(&self, path : &str) -> Option<TRef<R>>;
}

macro_rules! implGetNodeTRef {
    ($($t:ty),+) => {
        $(
            
            impl GetNodeTRef for $t {

                fn get_node_tref<R : SubClass<Node>>(&self, path : &str) -> Option<TRef<R>> {
                    if (let Some(node) = self.get_node(path)) {
                        return Some(unsafe {
                            node.assume_safe().cast::<R>().unwrap()
                        });
                    }
                    return None;
                }

            }

        )*
    }
}
implGetNodeTRef!(Node);

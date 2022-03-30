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



pub fn merge_dictionary(a : Dictionary<Unique>, b : Dictionary<Unique>) -> Dictionary<Unique> {
    let mut result = Dictionary::new();
    for key in a.keys() {
        result.insert(key.clone(), a.get(key));
    }
    for key in b.keys() {
        if (! result.contains(key.clone())) {
            result.insert(key.clone(), b.get(key));
        }
    }
    return result;
}



pub fn random(seed : i32) -> i32 {
    return ((seed as f32).sin() * 43758.5453123).fract().floor() as i32;
}

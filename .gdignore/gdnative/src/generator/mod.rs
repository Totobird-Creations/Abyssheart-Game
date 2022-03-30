use gdnative::prelude::*;

mod feature;



pub fn init(handle : InitHandle) -> () {
    handle.add_class::<feature::FeatureGenerator>();
}

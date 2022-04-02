use gdnative::prelude::*;



pub fn merge_dictionary(a : Dictionary<Unique>, b : Dictionary<Unique>) -> Dictionary<Unique> {
    let result = Dictionary::new();
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



pub fn max(a : f32, b : f32) -> f32 {
    if (a >= b) {
        return a;
    } else {
        return b;
    }
}

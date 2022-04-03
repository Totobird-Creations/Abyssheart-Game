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



pub fn position_to_coordinates(position : Vector3) -> Vector2 {
    return Vector2::new(position.x, position.z);
}

pub fn coordinates_to_position(coordinates : Vector2, owner : &Node) -> Vector3 {
    return Vector3::new(
        coordinates.x,
        unsafe {
            owner.get_parent().unwrap().assume_safe()
                .call("get_elevation_at_coordinates", &[
                    Variant::new(coordinates)
                ])
                .try_to::<f32>().unwrap()
        },
        coordinates.y
    );
}

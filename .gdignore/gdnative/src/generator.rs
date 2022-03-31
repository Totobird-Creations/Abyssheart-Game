use gdnative::prelude::*;
use gdnative::api::{
    RandomNumberGenerator,
    StaticBody
};

use crate::tool::*;



#[derive(NativeClass, Default)]
#[inherit(Node)]
pub struct FeatureGenerator {
    #[property(path="seed",default=0)]
    seed : i32,
    #[property(path="features/max_fails",default=25)]
    feature_max_fails : i32,
    #[property(path="features/scenes")]
    features : StringArray
}
impl FeatureGenerator {
    fn new(_owner : &Node) -> Self {
        return Self {
            seed              : 0,
            feature_max_fails : 25,
            features          : StringArray::new()
        };
    }
}



#[methods]
impl FeatureGenerator {


    #[export]
    fn get_features_in_chunk(&self, owner : &Node, chunk_coordinates : Vector2, chunk_size : i32) -> Dictionary<Unique> {
        return unsafe {
            self._get_features_in_chunk(owner, chunk_coordinates, chunk_size, true)
        };
    }

    unsafe fn _get_features_in_chunk(&self, owner : &Node, chunk_coordinates : Vector2, chunk_size : i32, check_neighbors : bool) -> Dictionary<Unique> {
        let other_features  = if (check_neighbors) {
            merge_dictionary(merge_dictionary(
                self._get_features_in_chunk( owner, chunk_coordinates + Vector2::UP                 , chunk_size, false ),
                self._get_features_in_chunk( owner, chunk_coordinates + Vector2::LEFT               , chunk_size, false )),
                self._get_features_in_chunk( owner, chunk_coordinates + Vector2::UP + Vector2::LEFT , chunk_size, false )
            )
        } else {
            Dictionary::new()
        };

        let rng = RandomNumberGenerator::new();
        rng.set_seed((random(chunk_coordinates.x as i32) + random(chunk_coordinates.y as i32) + self.seed) as i64);

        let     features        = Dictionary::new();
        let mut tries_remaining = self.feature_max_fails;

        while (tries_remaining >= 1) {
            let feature_coordinates : Vector2 = (chunk_coordinates + Vector2::new(
                rng.randf_range(0.0, 1.0) as f32,
                rng.randf_range(0.0, 1.0) as f32
            )) * Vector2::new(chunk_size as f32, chunk_size as f32);
            let elevation = owner.get_parent().unwrap().assume_safe().call("get_elevation_at_coordinates", &[Variant::new(feature_coordinates)]).try_to::<f32>().unwrap();
            let feature_position : Vector3 = Vector3::new(
                feature_coordinates.x,
                elevation + 0.1,
                feature_coordinates.y
            );
            let feature_path = self.features.get(rng.randi_range(0, (self.features.len() - 1) as i64) as i32);
            let feature      = owner.get_parent().unwrap().assume_safe().call("load_scene", &[Variant::new(feature_path)]).to_object::<PackedScene>().unwrap().assume_safe().instance(0).unwrap();
            let success      = self.check_spawn_allowed(owner, feature, feature_position, merge_dictionary(features.duplicate(), other_features.duplicate()));

            if (success) {
                features.insert(Variant::new(feature_position), feature);

            } else {
                feature.assume_safe().queue_free();
            }
            tries_remaining -= 1;
        }

        return features;
    }


    unsafe fn check_spawn_allowed(&self, owner : &Node, feature : Ref<Node>, feature_position : Vector3, all_features : Dictionary<Unique>) -> bool {
        let mut success = true;
        if (success) {
            let height = owner.get_parent().unwrap().assume_safe().call("get_height_at_coordinates", &[
                Variant::new(Vector2::new(feature_position.x, feature_position.z))
            ]).try_to::<f32>().unwrap();
            if (let Ok(required_height) = feature.assume_safe().call("get_required_height", &[]).try_to::<f32>()) {
                success = height > required_height;
            } else {
                success = false;
            }
        }
        if (success) {
            for other_position in all_features.keys() {
                let other_feature = all_features.get(other_position.clone()).unwrap().to_object::<StaticBody>().unwrap();
                if (
                    other_feature.assume_safe().translation().distance_to(feature_position)
                    <=
                    max(
                        other_feature.assume_safe().call("get_required_radius", &[]).try_to::<f32>().unwrap(),
                        feature.assume_safe().call("get_required_radius", &[]).try_to::<f32>().unwrap()
                    )
                ) {
                    success = false;
                    break;
                }
            }
        }
        return success
    }

}


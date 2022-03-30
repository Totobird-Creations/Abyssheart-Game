use std::{
    collections::HashMap,
    hash::Hash
};

use gdnative::prelude::*;
use gdnative::api::RandomNumberGenerator;

use crate::tool::*;



#[derive(NativeClass, Default)]
#[inherit(Node)]
pub struct FeatureGenerator {
    #[property(path="seed",default=0)]
    seed : i32,
    #[property(path="features/max_fails",default=25)]
    feature_max_fails : i32,
    #[property(path="features/scenes")]
    features : VariantArray
}
impl FeatureGenerator {
    fn new(_owner : &Node) -> Self {
        return Self::default();
    }
}



#[methods]
impl FeatureGenerator {


    #[export]
    fn get_features_in_chunk(&self, owner : &Node, chunk_coordinates : Vector2, chunk_size : f32) -> Dictionary<Unique> {
        return self._get_features_in_chunk(owner, chunk_coordinates, chunk_size, true)
    }

    fn _get_features_in_chunk(&self, owner : &Node, chunk_coordinates : Vector2, chunk_size : f32, check_neighbors : bool) -> Dictionary<Unique> {
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
            let feature_coordinates : Vector2 = chunk_coordinates * Vector2::new(chunk_size, chunk_size) + Vector2::new(
                rng.randf_range(0.0, chunk_size as f64) as f32, rng.randf_range(0.0, chunk_size as f64) as f32
            );
            let feature_position : Vector3 = Vector3::new(
                feature_coordinates.x,
                unsafe {
                    owner.get_parent().unwrap().assume_safe().call("get_elevation_at_coordinates", &[Variant::new(feature_coordinates)]).try_to::<f32>().unwrap()
                },
                feature_coordinates.y
            );
            let feature = unsafe {
                self.features.get(rng.randi_range(0, self.features.len() as i64) as i32).to_object::<PackedScene>().unwrap().assume_safe().instance(0).unwrap()
            };
            let success = self.check_spawn_allowed(owner, feature, feature_position, merge_dictionary(features.duplicate(), other_features.duplicate()));

            if (success) {
                features.insert(Variant::new(feature_position), feature);
                for i in 0..rng.randi_range(0, unsafe {feature.assume_safe().call("get_spread_count", &[]).try_to::<i64>().unwrap()}) {
                    let angle              = rng.randf_range(-3.1415, 3.1415) as f32;
                    let spread_distance    = rng.randf_range(0.0, unsafe {
                        feature.assume_safe().call("get_spread_range", &[]).try_to::<f64>().unwrap()
                    }) as f32;
                    let spread_coordinates = feature_coordinates + Vector2::new(angle.cos(), angle.sin()) * Vector2::new(spread_distance, spread_distance);
                    let spread_position    = Vector3::new(
                        spread_coordinates.x,
                        unsafe {owner.get_parent().unwrap().assume_safe().call("get_elevation_at_coordinates", &[Variant::new(spread_coordinates)]).try_to::<f32>().unwrap()},
                        spread_coordinates.y
                    );
                    let spread_feature = feature.clone();
                    let spread_success = self.check_spawn_allowed(owner, spread_feature, spread_position, merge_dictionary(features.duplicate(), other_features.duplicate()));
                    if (spread_success) {
                        features.insert(Variant::new(spread_position), spread_feature);
                    } else {
                        unsafe {
                            spread_feature.assume_safe().queue_free();
                        }
                    }
                }

            } else {
                unsafe {
                    feature.assume_safe().queue_free();
                }
                tries_remaining -= 1;
            }
        }

        return features;
    }


    fn check_spawn_allowed(&self, owner : &Node, feature : Ref<Node>, feature_position : Vector3, all_features : Dictionary<Unique>) -> bool {
        unimplemented!();
    }

}


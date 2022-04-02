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
        return Self::default();
    }
}



#[methods]
impl FeatureGenerator {


    #[export]
    fn get_features_in_chunk(&self, owner : &Node, chunk_coordinates : Vector2, chunk_size : i32) -> Dictionary<Unique> {
        // Call base get features method wrapped in unsafe.
        return unsafe {
            self._get_features_in_chunk(owner, chunk_coordinates, chunk_size, true)
        };
    }

    unsafe fn _get_features_in_chunk(&self, owner : &Node, chunk_coordinates : Vector2, chunk_size : i32, check_neighbors : bool) -> Dictionary<Unique> {
        // Get features in negative direction chunks if check neighbors required.
        let other_features = if (check_neighbors) {
            merge_dictionary(merge_dictionary(
                self._get_features_in_chunk( owner, chunk_coordinates + Vector2::UP                 , chunk_size, false ),
                self._get_features_in_chunk( owner, chunk_coordinates + Vector2::LEFT               , chunk_size, false )),
                self._get_features_in_chunk( owner, chunk_coordinates + Vector2::UP + Vector2::LEFT , chunk_size, false )
            )
        } else {
            Dictionary::new()
        };

        // Create random number generator with seed.
        let rng = RandomNumberGenerator::new();
        rng.set_seed((random(chunk_coordinates.x as i32) + random(chunk_coordinates.y as i32) + self.seed) as i64);

        let     features        = Dictionary::new();
        let mut tries_remaining = self.feature_max_fails;

        while (tries_remaining >= 1) {
            // Get feature position.
            let feature_coordinates : Vector2 = (chunk_coordinates + Vector2::new(
                rng.randf_range(0.0, 1.0) as f32,
                rng.randf_range(0.0, 1.0) as f32
            )) * Vector2::new(chunk_size as f32, chunk_size as f32);
            let elevation = owner.get_parent().unwrap().assume_safe().call("get_elevation_at_coordinates", &[Variant::new(feature_coordinates)]).try_to::<f32>().unwrap();
            let feature_position : Vector3 = Vector3::new(
                feature_coordinates.x,
                elevation,
                feature_coordinates.y
            );
            // Load a random feature and instance.
            // TODO : Use static functions to remove need for instancing and destrutcion.
            let feature_path = self.features.get(rng.randi_range(0, (self.features.len() - 1) as i64) as i32);
            let feature      = owner.get_parent().unwrap().assume_safe().call("load_scene", &[Variant::new(feature_path)]).to_object::<PackedScene>().unwrap().assume_safe().instance(0).unwrap();
    
            // Check random chance.
            if (rng.randf_range(0.0, 1.0) <= feature.assume_safe().call("get_spawn_chance", &[
                Variant::new(owner.get_parent().unwrap()),
                Variant::new(feature_position)
            ]).to::<f64>().unwrap()) {

                let success = self.check_spawn_allowed(owner, feature, feature_position, merge_dictionary(features.duplicate(), other_features.duplicate()));
                if (success) {
                    // Can place feature, add to to-be-placed list.
                    features.insert(Variant::new(feature_position), feature);
                    continue;
                }

            }

            //Failed to place feature, reduce chances left.
            tries_remaining -= 1;
            // Failed to place feature, destroy object.
            feature.assume_safe().queue_free();
        }

        return features;
    }


    unsafe fn check_spawn_allowed(&self, owner : &Node, feature : Ref<Node>, feature_position : Vector3, all_features : Dictionary<Unique>) -> bool {
        let mut success = true;
        if (success) {
            // Check if ceiling is high enough.
            let height = owner.get_parent().unwrap().assume_safe().call("get_height_at_coordinates", &[
                Variant::new(Vector2::new(feature_position.x, feature_position.z))
            ]).try_to::<f32>().unwrap();
            let required_height = feature.assume_safe().call("get_required_height", &[]).to::<f32>().unwrap();
            success = height > required_height;
        }
        if (success) {
            // Check if far enough from nearby features.
            for other_position in all_features.keys() {
                let other_feature = all_features.get(other_position.clone()).unwrap().to_object::<StaticBody>().unwrap();
                if (
                    other_feature.assume_safe().translation().distance_to(feature_position)
                    <=
                    max(
                        other_feature.assume_safe().call("get_required_radius", &[]).to::<f32>().unwrap(),
                        feature.assume_safe().call("get_required_radius", &[]).to::<f32>().unwrap()
                    )
                ) {
                    success = false;
                    break;
                }
            }
        }
        return success;
    }

}


use gdnative::prelude::*;
use gdnative::{
    api::{
        RandomNumberGenerator,
        StaticBody
    },
    export::user_data::MutexData
};

use crate::tool::*;



struct FeatureGeneratorData {
    pub rng             : Ref<RandomNumberGenerator, Unique>,
    pub other_features  : Dictionary<Unique>,
    pub features        : Dictionary<Unique>,
    pub tries_remaining : i32
}



#[derive(NativeClass, Default)]
#[inherit(Node)]
#[user_data(MutexData<FeatureGenerator>)]
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
    fn get_features_in_chunk(&self, owner : &Node, data : Dictionary) -> () {
        // Unwrap arguments.
        let chunk_coordinates = data.get("chunk_coordinates").unwrap().to::<Vector2>().unwrap();
        let chunk_size        = data.get("chunk_size").unwrap().to::<i32>().unwrap();

        // Call base get features method wrapped in unsafe.
        unsafe {
            let features = self._get_features_in_chunk(owner, chunk_coordinates, chunk_size, true);
            owner.get_parent().unwrap().assume_safe()
                .call_deferred("chunk_generated", &[
                    Variant::new(features),
                    Variant::new(chunk_coordinates)
                ]);
        }
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
        rng.set_seed((
              random(chunk_coordinates.x as i32)
            + random(chunk_coordinates.y as i32)
            + self.seed
        ) as i64);

        let mut data = FeatureGeneratorData {
            rng             : rng,
            other_features  : other_features,
            features        : Dictionary::new(),
            tries_remaining : self.feature_max_fails
        };

        while (data.tries_remaining >= 1) {

            // Get feature position.
            let feature_coordinates = (chunk_coordinates + Vector2::new(
                data.rng.randf_range(0.0, 1.0) as f32,
                data.rng.randf_range(0.0, 1.0) as f32
            )) * Vector2::new(chunk_size as f32, chunk_size as f32);
            let feature_position = coordinates_to_position(feature_coordinates, owner);

            // Pick a random feature.
            let feature_path  = self.features.get(
                data.rng.randi_range(0, (self.features.len() - 1) as i64) as i32
            );
            let feature_scene = owner.get_parent().unwrap().assume_safe()
                .call("load_scene", &[
                    Variant::new(feature_path)
                ])
                .to_object::<PackedScene>().unwrap();

            // Attempt to spawn feature.
            self.spawn_feature(
                owner,
                &mut data,
                feature_scene,
                feature_position,
                true
            );

        }

        return data.features;
    }


    unsafe fn spawn_feature(&self, owner : &Node, data : &mut FeatureGeneratorData, feature_scene : Ref<PackedScene>, feature_position : Vector3, spread_allowed : bool) -> () {
        
        // TODO : Use static functions to remove need for instancing and destrutcion.
        let feature = feature_scene.assume_safe().instance(0).unwrap();
    
        // Check random chance.
        if (data.rng.randf_range(0.0, 1.0) <= feature.assume_safe()
            .call("get_spawn_chance", &[
                Variant::new(owner.get_parent().unwrap()),
                Variant::new(feature_position)
            ])
            .to::<f64>().unwrap()
        ) {

            let success = self.check_spawn_allowed(
                owner,
                feature,
                feature_position,
                merge_dictionary(data.features.duplicate(), data.other_features.duplicate())
            );
            if (success) {
                // Can place feature, add to to-be-placed list.
                data.features.insert(Variant::new(feature_position), feature);

                // Get spreads.
                if (spread_allowed) {
                    for _i in 0..(
                        data.rng.randi_range(
                            0,
                            feature.assume_safe()
                                .call("get_spread_count", &[])
                                .to::<i64>().unwrap()
                        ) + 1
                    ) {

                        // Get spread position
                        let spread_angle = data.rng.randf_range(-3.1415, 3.1415);
                        let spread_range = data.rng.randf_range(
                            0.0,
                            feature.assume_safe()
                                .call("get_spread_range", &[])
                                .to::<f64>().unwrap()
                        );
                        let spread_coordinates = (
                              position_to_coordinates(feature_position)
                            + Vector2::new(spread_angle.cos() as f32, spread_angle.sin() as f32)
                            * Vector2::new(spread_range as f32, spread_range as f32
                        ));
                        let spread_position = Vector3::new(
                            spread_coordinates.x,
                            owner.get_parent().unwrap().assume_safe()
                                .call("get_elevation_at_coordinates", &[
                                    Variant::new(spread_coordinates)
                                ])
                                .try_to::<f32>().unwrap(),
                            spread_coordinates.y
                        );

                        // Atempt to spawn spread.
                        self.spawn_feature(
                            owner,
                            data,
                            feature_scene.clone(),
                            spread_position,
                            false
                        );

                    }
                }

                return;

            } else {

                //Failed to place feature, reduce chances left.
                data.tries_remaining -= 1;

            }

            // Failed to place feature, destroy object.
            feature.assume_safe().queue_free();

        }

    }


    unsafe fn check_spawn_allowed(&self, owner : &Node, feature : Ref<Node>, feature_position : Vector3, all_features : Dictionary<Unique>) -> bool {
        let mut success = true;
        if (success) {
            // Check if ceiling is high enough.
            let height = owner.get_parent().unwrap().assume_safe()
                .call("get_height_at_coordinates", &[
                    Variant::new(Vector2::new(feature_position.x, feature_position.z))
                ])
                .try_to::<f32>().unwrap();
            let required_height = feature.assume_safe()
                .call("get_required_height", &[])
                .to::<f32>().unwrap();
            success = height > required_height;
        }
        if (success) {
            // Check if far enough from nearby features.
            for other_position_variant in all_features.keys() {
                let other_feature = all_features.get(other_position_variant.clone())
                    .unwrap().to_object::<StaticBody>().unwrap();
                let other_position = other_position_variant
                    .to::<Vector3>().unwrap();
                if (
                    feature_position.distance_to(other_position)
                    <=
                    max(
                        other_feature.assume_safe()
                            .call("get_required_radius", &[])
                            .to::<f32>().unwrap(),
                        feature.assume_safe()
                            .call("get_required_radius", &[])
                            .to::<f32>().unwrap()
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


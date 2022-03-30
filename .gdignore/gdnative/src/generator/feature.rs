use std::collections::HashMap;

use gdnative::prelude::*;

use crate::tool::*;



#[derive(NativeClass)]
#[inherit(Node)]
pub struct FeatureGenerator {
    #[property(path="feature_placement/max_fails",default=25)]
    max_feature_placement_fails : i32,
    #[property(path="feature_placement/features_count")]
    feature_count : i32,

    chunks : HashMap<(i32, i32), Vec<i32>>
}
impl FeatureGenerator {
    fn new(_owner : &Node) -> Self {
        return Self {
            max_feature_placement_fails : 0,
            features                    : VariantArray::new(),
            chunk                       : PackedScene::new(),
            chunks                      : HashMap::new()
        };
    }
}



#[methods]
impl FeatureGenerator {

    fn chunk_loaded(&self, owner : &Node, chunk_position : Vector3) -> () {
        let chunk_coordinate = Vector2::new(chunk_position.x, chunk_position.z);

        let key = (chunk_coordinate.x as i32, chunk_coordinate.y as i32);
        if (! self.chunks.contains_key(&key)) {
            self.chunks.insert(key, Vec::new());
        }
        if (self.chunks[&key].contains(&(chunk_position.y as i32))) {return;}
        self.chunks[&key].push(chunk_position.y as i32);

        let terrain : TRef<Node> = if (let Some(node) = owner.get_node_tref("../terrain")) {node} else {panic!("Terrain node access failed.")};
        let chunks  : TRef<Node> = if (let Some(node) = owner.get_node_tref("../chunks"))  {node} else {panic!("Chunks node access failed.")};

        let chunk_size : f32 = terrain.call("get_mesh_block_size", &[Variant::new(Dictionary::new())]).to::<f32>().unwrap();

        let position = chunk_coordinate * chunk_size;
        let name     = (chunk_position.x as i32).to_string() + "_" + &(chunk_position.z as i32).to_string();

        if (let Some(node) = chunks.get_node_tref(&name)) {} else {
            let chunk = Spatial::new();
            chunk.set_name(name);
            chunk.position       = chunk_coordinate;
            chunk.size           = chunk_size;
            chunk.world_position = position;

            let features = self.get_features_in_chunk(chunk, true);
            for feature_position in features.keys() {
                let feature = features.get(feature_position);
                chunk.add_child(feature, false);
                feature.translation = feature_position;
            }

            chunks.add_child(chunk, false)
        }
    }



    fn get_features_in_chunk(&self, chunk : Spatial, check_neighbors : bool) -> HashMap<(f32, f32, f32), Spatial> {
        panic!("Unimplemented.");
    }

}


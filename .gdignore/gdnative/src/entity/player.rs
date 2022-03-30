use gdnative::prelude::*;
use gdnative::api::{
    Camera,
    InputEventMouseMotion
};

use crate::tool::*;



#[derive(NativeClass, Default)]
#[inherit(KinematicBody)]
pub struct PlayerEntity {

// Controlling

    #[property(path="controlling/active", default=false)]
    controlling : bool,

    #[property(path="controlling/mouse_sensitivity", default=0.002)]
    mouse_sensitivity : f32,

// Motion

    #[property(path="motion/max_floor_angle", default=0.8028515)]
    max_floor_angle : f32,

    #[property(path="motion/gravity", default=40.0)]
    gravity : f32,

    #[property(path="motion/jump_strength", default=40.0)]
    jump_strength : f32,

    #[property(path="motion/walk_speed", default=10.0)]
    walk_speed : f32,

    #[property(path="motion/sprint_speed", default=16.0)]
    sprint_speed : f32,

    #[property(path="motion/acceleration", default=8.0)]
    acceleration : f32,

    #[property(path="motion/deceleration", default=10.0)]
    deceleration : f32,

    #[property(path="motion/air_control", default=0.5)]
    air_control : f32,

// Health

    #[property(path="health/max", default=100.0)]
    max_health : f32,

    // Fall Damage
    
        #[property(path="health/fall_damage/threshold", default=25.0)]
        fall_damage_threshold : f32,
    
        #[property(path="health/fall_damage/power", default=2.0)]
        fall_damage_power : f32,
    
        #[property(path="health/fall_damage/scale", default=10.0)]
        fall_damage_scale : f32,

// Stamina

    #[property(path="stamina/max", default=100.0)]
    max_stamina : f32,

    #[property(path="stamina/cooldown", default=1.0)]
    stamina_cooldown : f32,

    #[property(path="stamina/regeneration", default=10.0)]
    stamina_regeneration : f32,

    // Usage

        #[property(path="stamina/usage/sprint", default=1.0)]
        sprint_stamina : f32,

        #[property(path="stamina/usage/jump", default=15.0)]
        jump_stamina : f32,

    // Exhaust

        #[property(path="stamina/exhaust/debuff_multiplier", default=15.0)]
        exhaust_debuff_multiplier : f32,

// Other Properties

    health          : f32,

    stamina         : f32,
    stamina_timer   : f32,
    stamina_exhaust : bool,

    velocity        : Vector3,
    snap            : Vector3

}
impl PlayerEntity {
    fn new(_owner : &KinematicBody) -> Self {
        return Self::default();
    }
}



#[methods]
impl PlayerEntity {

    #[export]
    fn _ready(&mut self, owner : &KinematicBody) -> () {
        self.health          = self.max_health;
        self.stamina         = self.max_stamina;
        self.stamina_timer   = 0.0;
        self.stamina_exhaust = false;
        self.velocity        = Vector3::ZERO;
        self.snap            = Vector3::ZERO;

        if (let Some(node) = owner.get_node_tref::<Camera>("pivot/camera/camera")) {
            node.set_current(self.controlling);
        }
    }



    #[export]
    fn _physics_process(&mut self, owner : &KinematicBody, delta : f32) -> () {
        let input = Input::godot_singleton();

        // Exhaust Modifier
        let modifier = if (self.stamina_exhaust) {self.exhaust_debuff_multiplier} else {1.0};

        // Input
        let input_axis = Vector2::new(
            (input.get_action_strength("player_move_forward" , false) - input.get_action_strength("player_move_backward" , false)) as f32,
            (input.get_action_strength("player_move_right"   , false) - input.get_action_strength("player_move_left"     , false)) as f32
        );
        let jump   = input.is_action_just_pressed("player_move_jump", false);
        let sprint = input.is_action_pressed("player_move_sprint", false);

        // Input Direction
        let mut direction = Vector3::ZERO;
        let     aim       = owner.global_transform().basis;
        if (input_axis.x >= 0.5)  {direction -= aim.elements[2];}
        if (input_axis.x <= -0.5) {direction += aim.elements[2];}
        if (input_axis.y >= 0.5)  {direction += aim.elements[0];}
        if (input_axis.y <= -0.5) {direction -= aim.elements[0];}
        direction.y = 0.0;
        if (direction.length() > 0.0) {
            direction = direction.normalized();
        }

        // Snapping
        if (owner.is_on_floor()) {
            self.snap       = -owner.get_floor_normal() - owner.get_floor_velocity() * delta;
            if (self.velocity.y < 0.0) {
                self.velocity.y = 0.0;
            }

            // Jump
            if (jump && self.has_stamina(self.jump_stamina)) {
                self.velocity.y = self.jump_strength;
                self.snap       = Vector3::ZERO;
                self.add_stamina(owner, - self.jump_stamina);
            }
        } else {
            if (self.snap != Vector3::ZERO && self.velocity.y != 0.0) {
                self.velocity.y = 0.0;
            }
            self.snap      = Vector3::ZERO;
            self.velocity += Vector3::DOWN * self.gravity * delta;
        }

        // Walk / Sprint
        let mut speed = self.walk_speed * modifier;
        if (owner.is_on_floor() && sprint && input_axis.x >= 0.5 && self.has_stamina(0.0)) {
            speed         = self.sprint_speed * modifier;
            self.stamina -= self.sprint_stamina * delta;
        }

        // Acceleration
        let mut temp_velocity     = self.velocity.clone();
        let     target            = direction * speed;
        let mut temp_acceleration = if (direction.dot(temp_velocity) > 0.0) {self.acceleration} else {self.deceleration};
        if (! owner.is_on_floor()) {
            temp_acceleration *= self.air_control;
        }
        temp_velocity = temp_velocity.linear_interpolate(target, temp_acceleration * delta);
        self.velocity.x = temp_velocity.x;
        self.velocity.z = temp_velocity.z;
        if (direction.dot(self.velocity) == 0.0) {
            let velocity_clamp = 0.01;
            if (self.velocity.x.abs() < velocity_clamp) {self.velocity.x = 0.0;}
            if (self.velocity.z.abs() < velocity_clamp) {self.velocity.z = 0.0;}
        }

        // Move Character
        self.velocity = owner.move_and_slide_with_snap(self.velocity, self.snap, Vector3::UP, true, 4, self.max_floor_angle as f64, true);

        // Stamina Regeneration
        if (self.stamina_timer <= 0.0) {
            self.stamina += self.stamina_regeneration * delta
        }
        self.stamina_timer = (self.stamina_timer - delta).clamp(0.0, self.stamina_cooldown);

    }



    #[export]
    fn _input(&mut self, owner : &KinematicBody, event : Variant) -> () {
        if (self.controlling) {
            if (let Some(event) = event.to_object::<InputEventMouseMotion>()) {
                if (let Some(node) = owner.get_node_tref::<Spatial>("pivot/camera")) {
                    unsafe {
                        node.set_rotation(Vector3::new(
                            node.rotation().x - (event.assume_safe().relative().y * self.mouse_sensitivity).clamp(-3.1415 / 2.0, 3.1415 / 2.0),
                        0.0, 0.0));
                        owner.set_rotation(owner.rotation() - Vector3::new(0.0,
                            event.assume_safe().relative().x * self.mouse_sensitivity,
                        0.0));
                    }
                }
            }
        }
    }



    fn add_stamina(&mut self, _owner : &KinematicBody, amount : f32) -> () {
        let new_stamina = (self.stamina + amount).clamp(0.0, self.max_stamina);
        if (new_stamina < self.stamina) {
            self.stamina_timer = self.stamina_cooldown;
        }
        self.stamina = new_stamina;
        if (self.stamina <= 0.0) {
            self.stamina_exhaust = true;
        } else if (self.stamina >= self.max_stamina) {
            self.stamina_exhaust = false;
        }
        if (self.controlling) {
            /*if (let Some(node) = owner.get_node_tref::<CanvasLayer>("../../canvas")) {
                node.call("set_stamina_target", self.stamina / self.max_stamina);
            }*/
            // Add message to canvas.
        }
    }

    fn has_stamina(&self, _amount : f32) -> bool {
        return ! self.stamina_exhaust;
    }

}


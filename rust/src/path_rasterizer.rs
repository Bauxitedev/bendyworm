use gdnative::api::{CollisionShape, ConcavePolygonShape};
use rayon::prelude::*;
use std::collections::HashMap;

use std::time::{Duration, Instant};

use gdnative::{
    api::{ArrayMesh, Curve2D, Mesh, StaticBody, SurfaceTool, TileMap},
    prelude::*,
};

type Base = Node;

#[derive(NativeClass)]
#[inherit(Base)]
pub struct PathRasterizer {
    rasterized: Option<Vec<Quad>>,

    #[property]
    uv_contraction: f32,
    //Tuple is (position, tangent)
    cell_lookup_table: HashMap<(i32, i32), (Vector2, Vector2)>, //TODO 2d array may be faster here but less flexible
}

fn tri_indices() -> [usize; 6] {
    [0, 1, 2, 2, 1, 3]
}

#[methods]
impl PathRasterizer {
    fn new(_owner: &Base) -> Self {
        PathRasterizer {
            rasterized: None,
            cell_lookup_table: HashMap::new(),
            uv_contraction: 0.4, //This is in pixels, 0.25 is not enough, 0.4 is not enough for smaller resolutions
        }
    }

    #[export]
    fn _ready(&self, _owner: &Base) {}

    #[export]
    fn lookup_cell_pos_and_tangent(
        &self,
        _owner: &Base,
        x: i32,
        y: i32,
    ) -> Option<(Vector2, Vector2)> {
        self.cell_lookup_table.get(&(x, y)).cloned()
    }

    #[export]
    fn rasterize_to_mesh_instance(&self, _owner: &Base) -> Ref<ArrayMesh> {
        let st = SurfaceTool::new();

        st.begin(Mesh::PRIMITIVE_TRIANGLES);

        for quad in self
            .rasterized
            .as_ref()
            .expect("please call update_rasterization() first")
        {
            for i in tri_indices() {
                //Quad decomposed into 2 triangles
                let pos = quad.positions[i];
                st.add_uv(quad.uvs[i]);
                st.add_vertex(Vector3::new(pos.x, pos.y, 0.0));
            }
        }

        let arraymesh = st
            .commit(Null::null(), 97280)
            .expect("failed to commit mesh");

        arraymesh
    }

    #[export]
    fn rasterize_to_collision(&self, _owner: &Base, collision: Ref<StaticBody>) {
        //TODO this is really slow!
        let start = Instant::now();

        let collision = unsafe { collision.assume_safe() };
        let children = collision.upcast::<Node>().get_children();
        let first_run = children.len() == 0;

        let quads = self
            .rasterized
            .as_ref()
            .expect("please call update_rasterization() first");

        let shapeholder = if first_run {
            let shapeholder = CollisionShape::new();
            let shapeholder = unsafe { shapeholder.assume_shared() };
            collision.add_child(shapeholder, false);
            shapeholder
        } else {
            children
                .get(0)
                .try_to_object::<CollisionShape>()
                .expect("collision has non-CollisionShape child")
        };

        let shapeholder = unsafe { shapeholder.assume_safe() };

        let should_set_shapeholders_shape = shapeholder.shape().is_none();
        let polyshape = match shapeholder.shape() {
            Some(current_shape) => unsafe {
                current_shape
                    .assume_safe()
                    .cast::<ConcavePolygonShape>()
                    .expect("shapeholder's shape wasn't a ConcavePolygonShape")
                    .claim()
            },
            None => {
                println!("shapeholder's shape was null, creating a new one",);

                unsafe { ConcavePolygonShape::new().assume_shared() }
            }
        };
        let polyshape = unsafe { polyshape.assume_safe() };
        let mut tris = vec![];

        let extrusion_depth = 4.0; //TODO extrude the rtiangles
        for quad in quads {
            if !quad.tile_has_collision {
                continue;
            }

            let mut quad_positions_sorted = quad.positions.to_vec();
            quad_positions_sorted.swap(0, 1); //To get a consistent order
            quad_positions_sorted.push(quad_positions_sorted[0]); //Add first pos to the end to loop it

            for pair in quad_positions_sorted.windows(2) {
                let corner1 = pair[0];
                let corner2 = pair[1];

                let pos3d_1 = Vector3::new(corner2.x, corner2.y, extrusion_depth);
                let pos3d_2 = Vector3::new(corner1.x, corner1.y, extrusion_depth);
                let pos3d_3 = Vector3::new(corner2.x, corner2.y, -extrusion_depth);
                let pos3d_4 = Vector3::new(corner1.x, corner1.y, -extrusion_depth);

                let pos3ds = [pos3d_1, pos3d_2, pos3d_3, pos3d_4];

                for i in tri_indices() {
                    let pos = pos3ds[i];
                    tris.push(pos);
                }
            }
        }

        polyshape.set_faces(Vector3Array::from_vec(tris));

        if should_set_shapeholders_shape {
            //Only needed if the shape is null
            println!("shapeholder's shape set");
            shapeholder.set_shape(polyshape);
        }

        let duration = start.elapsed();

        //println!("Time elapsed in set_points() is: {:?}", duration);
    }

    #[export]
    fn update_rasterization(
        &mut self,
        owner: &Base,
        curve: Ref<Curve2D>,
        flow_offset: f64,
        tilemap: Ref<TileMap>,
    ) {
        let tilemap = unsafe { tilemap.assume_safe() };
        let curve = unsafe { curve.assume_safe() };

        //Store later for caching reasons (so rasterize_to_mesh_instance and rasterize_to_collision can use the same quads)
        self.rasterized = Some(self.rasterize_inner(owner, curve, flow_offset, tilemap));
    }

    fn rasterize_inner(
        &mut self,
        _owner: &Base,
        curve: TRef<Curve2D>,
        flow_offset: f64,
        tilemap: TRef<TileMap>,
    ) -> Vec<Quad> {
        self.cell_lookup_table.clear();
        let baked_length = curve.get_baked_length();

        let tileset = tilemap.tileset().expect("tilemap has no tileset");
        let tileset = unsafe { tileset.assume_safe() };

        let tileset_ids = tileset.get_tiles_ids();
        let tile_tex = tileset
            .tile_get_texture(
                tileset_ids
                    .get(0)
                    .try_to_i64()
                    .expect("tileset has no tiles"),
            )
            .expect("tileset has no texture");
        let tile_tex = unsafe { tile_tex.assume_safe() };

        let tile_size = tilemap.cell_size().x.round() as i32;
        let tiles_w = tilemap.get_used_rect().size.width.round() as i32;
        let tiles_h = tilemap.get_used_rect().size.height.round() as i32;

        let mut quads = vec![];

        for x in 0..tiles_w {
            let x_pixels = x * tile_size;

            let sample_pos1 = flow_offset + x_pixels as f64;
            let sample_pos2 = flow_offset + x_pixels as f64 + tile_size as f64;
            let sample_pos3 = flow_offset + x_pixels as f64 + tile_size as f64 * 2.;

            let pos = curve.interpolate_baked(sample_pos1, true);
            let pos_next = curve.interpolate_baked(sample_pos2, true);
            let pos_next2 = curve.interpolate_baked(sample_pos3, true);

            if sample_pos3 >= baked_length {
                println!("warning - level is longer than curve, causes artifacts");
                break;
            }

            let perp_vec = (pos_next - pos).normalize().tangent();
            let perp_vec2 = (pos_next2 - pos_next).normalize().tangent();

            for y in 0..tiles_h {
                let tile_id = tilemap.get_cell(x as i64, y as i64);

                let pos0 = pos + perp_vec * tile_size as f32 * (y as f32 - tiles_h as f32 / 2.0);
                let pos1 =
                    pos + perp_vec * tile_size as f32 * (y as f32 + 1. - tiles_h as f32 / 2.0);
                let pos2 =
                    pos_next + perp_vec2 * tile_size as f32 * (y as f32 - tiles_h as f32 / 2.0);
                let pos3 = pos_next
                    + perp_vec2 * tile_size as f32 * (y as f32 + 1. - tiles_h as f32 / 2.0);

                let pos_avg = (pos0 + pos1 + pos2 + pos3) / 4.0;
                self.cell_lookup_table.insert((x, y), (pos_avg, -perp_vec));

                if tile_id == -1 {
                    continue;
                }
                let tile_has_collision = tileset.tile_get_shape_count(tile_id) > 0;

                let uv_subregion = tileset.tile_get_region(tile_id);
                let uv_contraction = self.uv_contraction;

                //TODO maybe use the tileset with the 1 pixel border between the tiles? To avoid need for uv_contraction

                let uv0 = uv_subregion.origin + Vector2::new(uv_contraction, uv_contraction);
                let uv1 = uv_subregion.origin
                    + Vector2::new(uv_subregion.size.width - uv_contraction, uv_contraction);
                let uv2 = uv_subregion.origin
                    + Vector2::new(uv_contraction, uv_subregion.size.height - uv_contraction);
                let uv3 = uv_subregion.origin
                    + Vector2::new(
                        uv_subregion.size.width - uv_contraction,
                        uv_subregion.size.height - uv_contraction,
                    );

                let mut uvs = [
                    //Weird order because we need to flip vertically
                    uv2.to_vector(),
                    uv3.to_vector(),
                    uv0.to_vector(),
                    uv1.to_vector(),
                ];

                for uv in &mut uvs {
                    (*uv).x /= tile_tex.get_width() as f32;
                    (*uv).y /= tile_tex.get_height() as f32;
                    //Divide by texture size
                }

                let quad = Quad {
                    positions: [pos1, pos3, pos0, pos2], //Weird order here because we need to rotate the tiles 90 degrees
                    uvs,
                    tile_has_collision,
                };

                quads.push(quad);
            }
        }

        quads
    }
}

struct Quad {
    positions: [Vector2; 4],
    uvs: [Vector2; 4],
    tile_has_collision: bool,
}

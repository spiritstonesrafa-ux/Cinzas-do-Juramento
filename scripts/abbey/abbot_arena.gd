extends Node2D
signal boss_defeated
const BOSS: PackedScene=preload("res://scenes/abbey/abbot.tscn")
const BACKDROP: Texture2D=preload("res://assets/art/m5b/choir.png")
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
var boss: CharacterBody2D
var hero: KnightController
var already_defeated: bool=false
var right_wall: StaticBody2D
func configure(player: KnightController, cleared: bool=false) -> void:
 hero=player
 already_defeated=cleared
func _ready() -> void:
 _body(Vector2(160,238),Vector2(320,164))
 _body(Vector2(-8,60),Vector2(16,240))
 right_wall=_body(Vector2(328,60),Vector2(16,240))
 boss=BOSS.instantiate()
 boss.position=Vector2(240,156)
 boss.target=hero
 add_child(boss)
 if already_defeated:
  boss.health=0
  boss._state(boss.State.DEFEATED,0.0)
  boss.get_node("SwordReceiver/CollisionShape2D").set_deferred("disabled",true)
  if boss.has_node("Conclusion"):
   boss.get_node("Conclusion").settle(true)
  if is_instance_valid(right_wall):
   for c in right_wall.get_children():
    if c is CollisionShape2D:
     c.set_deferred("disabled",true)
 boss.defeated.connect(func():
  boss_defeated.emit()
  if is_instance_valid(right_wall):
   for c in right_wall.get_children():
    if c is CollisionShape2D:
     c.set_deferred("disabled",true)
 )
func _body(pos: Vector2,size: Vector2) -> StaticBody2D:
 var body: StaticBody2D=StaticBody2D.new()
 body.position=pos
 body.collision_layer=1
 body.collision_mask=258
 var cs: CollisionShape2D=CollisionShape2D.new()
 cs.name="CollisionShape2D"
 var shape: RectangleShape2D=RectangleShape2D.new()
 shape.size=size
 cs.shape=shape
 body.add_child(cs)
 add_child(body)
 return body
func snapshot() -> Dictionary: return {}
func disarm() -> void:
 if is_instance_valid(boss): boss.disarm()
func reset_encounters() -> void: disarm()
func _draw() -> void:
 draw_texture_rect(BACKDROP,Rect2(0,0,320,180),false,Color(0.52,0.53,0.56))
 for x: int in range(0,320,48):
  draw_texture_rect_region(STONE,Rect2(x,156,48,24),Rect2(18,194,364,186),Color(0.65,0.65,0.63))

extends SceneTree
var fails: int=0
func _initialize() -> void: run.call_deferred()
func check(x: bool, label: String) -> void:
 print(("PASS " if x else "FAIL ")+label)
 if not x: fails+=1
func tick(n: int=1) -> void:
 for i: int in range(n): await physics_frame; await process_frame
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 var hero: KnightController=chapter.hero
 var expected: bool=OS.get_environment("M5G_EXPECT") == "1"
 check(hero.dash_unlocked==expected,"progresso esperado após reinício de processo")
 var start: Vector2=hero.global_position
 var event: InputEventKey=InputEventKey.new()
 event.keycode=KEY_SHIFT;event.pressed=true
 Input.parse_input_event(event)
 await tick(2)
 event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=false;Input.parse_input_event(event)
 await tick(15)
 check((hero.global_position.x-start.x>20)==expected,"dash bloqueado antes da vitória e ativo após")
 if expected:
  var previous: float=hero.global_position.x
  event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=true;Input.parse_input_event(event)
  await tick(2)
  check(hero.global_position.x-previous<12,"cooldown impede ativação imediata")
  event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=false;Input.parse_input_event(event)
  var wall: StaticBody2D=StaticBody2D.new()
  wall.position=AbbeyChapterLayout.origin(0)+Vector2(140,285)
  wall.collision_layer=1
  var shape: CollisionShape2D=CollisionShape2D.new()
  var rect: RectangleShape2D=RectangleShape2D.new();rect.size=Vector2(8,60);shape.shape=rect;wall.add_child(shape)
  chapter.add_child(wall)
  hero.reset_to(AbbeyChapterLayout.origin(0)+Vector2(100,300))
  await tick(60)
  event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=true;Input.parse_input_event(event)
  await tick(20)
  check(hero.global_position.x<=130.1,"dash bloqueado por parede sólida")
  event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=false;Input.parse_input_event(event)
  hero.reset_to(AbbeyChapterLayout.origin(0)+Vector2(100,300))
  await tick(60)
  event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=true;Input.parse_input_event(event)
  await tick(2)
  var hp_before: int=hero.survival.current_health
  var damage_accepted: bool=hero.receive_damage(1)
  check(damage_accepted and hero.survival.current_health==hp_before-1,"dash não concede invulnerabilidade")

 print("M5G persistence probe failures=",fails)
 chapter.queue_free();await tick(90)
 quit(1 if fails else 0)

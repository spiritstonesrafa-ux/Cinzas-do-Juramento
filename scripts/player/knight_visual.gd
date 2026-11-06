extends PixelCanvas
## FIX02 original raster poses. Only observes homologated state; no physics writes.
const POSES: Texture2D = preload("res://assets/art/fix02/aren_poses.png")
# Authored sheet regions measured from alpha >= 96; fixed metadata avoids GPU readback.
const FRAME_RECTS: Array[Rect2] = [
 Rect2(86,18,230,386), Rect2(472,39,333,364),
 Rect2(935,38,283,366), Rect2(1387,38,343,362),
 Rect2(27,464,309,282), Rect2(472,460,305,387),
 Rect2(903,496,337,353), Rect2(1355,464,304,385)
]
var _time: float = 0.0
var _was_dead: bool = false
var _revive: float = 0.0
var _dash_ghosts: Array[Dictionary] = []
var _dash_sample: float = 0.0
var _dash_previous: bool = false
var _dash_impact: float = 0.0

func _process(delta: float) -> void:
 _time += delta
 var hero: KnightController = get_parent() as KnightController
 var dashing: bool = hero.dash_remaining > 0.0 and not hero.survival.is_dead
 _dash_sample -= delta
 if _dash_previous != dashing: _dash_impact = 0.16
 _dash_previous = dashing
 _dash_impact = maxf(0.0,_dash_impact-delta)
 for i: int in range(_dash_ghosts.size()-1,-1,-1):
  _dash_ghosts[i].age += delta
  if _dash_ghosts[i].age>=0.18: _dash_ghosts.remove_at(i)
 if hero.survival.is_dead:
  _dash_ghosts.clear()
  _dash_impact=0.0
 elif dashing and _dash_sample<=0.0:
  _dash_ghosts.push_back({"position":global_position,"age":0.0})
  if _dash_ghosts.size()>5: _dash_ghosts.pop_front()
  _dash_sample=0.035
 if _was_dead and not hero.survival.is_dead: _revive = 0.55
 _was_dead = hero.survival.is_dead
 _revive = maxf(0,_revive-delta)
 queue_redraw()

func _draw() -> void:
 var hero: KnightController = get_parent() as KnightController
 var ghost_region: Rect2=FRAME_RECTS[4]
 var ghost_size: Vector2=(ghost_region.size*Vector2(1.2,1)*36.0/386.0).round()
 for ghost: Dictionary in _dash_ghosts:
  var offset: Vector2=to_local(ghost.position)
  draw_texture_rect_region(POSES,Rect2(offset+Vector2(-roundf(ghost_size.x*0.76),-30),ghost_size),ghost_region,Color(0.48,0.36,0.63,0.25*(1.0-ghost.age/0.18)))
 if _dash_impact>0.0:
  for i: int in range(4):
   draw_rect(Rect2(-8-i*4,-2-(i%2)*3,2,2),Color(0.64,0.58,0.59,_dash_impact/0.16))
 if hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL and not hero.survival.is_dead:
  _draw_attack(hero)
  return
 var frame: int = 0 if int(_time*3)%2==0 else 7
 match hero.state:
  KnightController.MovementState.RUN: frame = [1,2,3,2][int(_time*11)%4]
  KnightController.MovementState.JUMP: frame = 4
  KnightController.MovementState.FALL: frame = 5
 if hero.dash_remaining > 0.0: frame = 4
 if hero.survival.invulnerability_remaining>0.63: frame = 6
 if hero.survival.is_dead: frame = 0
 var region: Rect2 = FRAME_RECTS[frame]
 var dimensions: Vector2 = (region.size*Vector2(1.2,1)*36.0/386.0).round()
 var destination: Rect2 = Rect2(Vector2(-roundf(dimensions.x*0.76),-36),dimensions)
 draw_texture_rect_region(POSES,destination,region,Color(1.4,1.43,1.38,1))
 if _revive>0:
  l(Vector2(-10,-1),Vector2(10,-1),Color(TEAL,_revive))
  r(-8,-16-int((0.55-_revive)*20),1,3,TEAL)
 if hero.survival.invulnerability_remaining>0.63:
  l(Vector2(-12,-23),Vector2(-16,-27),AMBER)
  l(Vector2(9,-14),Vector2(13,-17),LIGHT)

func _draw_attack(hero: KnightController) -> void:
 var attack: SwordAttack = hero.sword_attack
 var frame: int = ArenAttackArt.pose(attack)
 ArenAttackArt.draw_pose(self,frame)
 if attack.phase==SwordAttack.Phase.ACTIVE:
  # Horizontal, short and inside the original x=6..28/y=-21..-7 corridor.
  l(Vector2(10,-20),Vector2(27,-20),Color("c8d6d1",0.4))
  l(Vector2(12,-13),Vector2(25,-13),Color("f6ce94",0.32))
  if not attack._hit_targets.is_empty():
   r(24,-19,2,2,LIGHT)
   l(Vector2(24,-16),Vector2(27,-13),AMBER)
 if hero.survival.invulnerability_remaining>0.63:
  l(Vector2(-12,-23),Vector2(-16,-27),AMBER)

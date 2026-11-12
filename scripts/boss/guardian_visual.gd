extends Node2D
## Original atlas; visual segments are registered to the boss's new attack only.
const ART: Texture2D=preload("res://assets/art/m4a/guardian_poses.png")
const ATTACK_SCRIPT: GDScript=preload("res://scripts/boss/guardian_attack.gd")
const ROOTS: Array[Vector2]=[Vector2(330,555),Vector2(1025,555),Vector2(330,1180),Vector2(1010,1180)]
const REGIONS: Array[Rect2]=[Rect2(0,0,632,622),Rect2(632,0,632,622),Rect2(0,622,632,622),Rect2(632,622,632,622)]
const BLADE: Rect2=Rect2(450,875,286,65)
# Continuous deformation keeps the greaves, knees and cloth connected.
var stride_phase: float=0.0
var stride_weight: float=0.0
var last_world_position: Vector2
var position_initialized: bool=false
var walk_texture: Texture2D
var attack_texture: Texture2D
var low_attack_texture: Texture2D
func _ready() -> void:
 var path: String="res://assets/art/m4a/guardian_walk_v2.png"
 if ResourceLoader.exists(path):
  walk_texture=load(path) as Texture2D
 else:
  var source: Image=Image.load_from_file(ProjectSettings.globalize_path(path))
  if source!=null and not source.is_empty():walk_texture=ImageTexture.create_from_image(source)
 var attack_path: String="res://assets/art/m4a/guardian_attacks_v3.png"
 if ResourceLoader.exists(attack_path):attack_texture=load(attack_path) as Texture2D
 else:
  var attacks: Image=Image.load_from_file(ProjectSettings.globalize_path(attack_path))
  if attacks!=null and not attacks.is_empty():attack_texture=ImageTexture.create_from_image(attacks)
 var low_path: String="res://assets/art/m4a/guardian_low_attacks_v4.png"
 if ResourceLoader.exists(low_path):low_attack_texture=load(low_path) as Texture2D
 else:
  var low_image: Image=Image.load_from_file(ProjectSettings.globalize_path(low_path))
  if low_image!=null and not low_image.is_empty():low_attack_texture=ImageTexture.create_from_image(low_image)
func _low_attack_pose(tint: Color) -> void:
 # Remove the short generated blade; draw the actual collision-aligned blade below.
 var parts: Array[Rect2]=[Rect2(0,0,512,300),Rect2(0,380,512,132),Rect2(0,300,350,80)]
 for part: Rect2 in parts:
  var destination_size: Vector2=part.size*(87.0/512.0)
  if part.position.y>=380:destination_size.y*=0.65
  draw_texture_rect_region(low_attack_texture,Rect2(Vector2(-45,-74)+part.position*(87.0/512.0),destination_size),Rect2(Vector2(512,0)+part.position,part.size),tint)
func _attack_pose(cell: Vector2i,tint: Color,cut_blade: bool=false) -> void:
 var base: Vector2=Vector2(cell)*512.0
 var dst: Rect2=Rect2(-45,-74,87,87)
 var scale_factor: float=87.0/512.0
 var parts: Array[Rect2]=[Rect2(0,0,512,512)]
 if cut_blade:
  # Generated blade is replaced with the exact blade used by the collision box.
  parts=[Rect2(0,0,512,150),Rect2(0,250,512,262),Rect2(0,150,365,100)]
 for part: Rect2 in parts:
  draw_texture_rect_region(attack_texture,Rect2(dst.position+part.position*scale_factor,part.size*scale_factor),Rect2(base+part.position,part.size),tint)
func _process(delta: float) -> void:
 var boss: OathGuardian=get_parent() as OathGuardian
 if not position_initialized:
  last_world_position=boss.global_position
  position_initialized=true
 var distance: float=absf(boss.global_position.x-last_world_position.x)
 last_world_position=boss.global_position
 var moving: bool=distance>0.015 and boss.state in [boss.State.PURSUIT,boss.State.TELEGRAPH,boss.State.ATTACK]
 stride_weight=move_toward(stride_weight,1.0 if moving else 0.0,delta*7.0)
 if moving: stride_phase+=distance*0.21
 queue_redraw()
func _stride_vertex(point: Vector2) -> Vector2:
 var lower: float=smoothstep(-27.0,-4.0,point.y)*smoothstep(-24.0,-9.0,point.x)*stride_weight
 var swing: float=sin(stride_phase+point.x*0.18)
 return point+Vector2(swing*2.4*lower,-maxf(0.0,swing)*1.5*lower)
func _piece(rect: Rect2,anchor: Vector2,tint: Color) -> void:
 if not rect.has_area():return
 if stride_weight<0.01:
  draw_texture_rect_region(ART,Rect2(((rect.position-anchor)*0.125).round(),(rect.size*0.125).round()),rect,tint)
  return
 var image_size: Vector2=ART.get_size()
 var nx: int=maxi(1,ceili(rect.size.x/48.0))
 var ny: int=maxi(1,ceili(rect.size.y/48.0))
 for iy: int in range(ny):
  for ix: int in range(nx):
   var a: Vector2=rect.position+Vector2(rect.size.x*ix/nx,rect.size.y*iy/ny)
   var b: Vector2=rect.position+Vector2(rect.size.x*(ix+1)/nx,rect.size.y*(iy+1)/ny)
   var corners: PackedVector2Array=PackedVector2Array([a,Vector2(b.x,a.y),b,Vector2(a.x,b.y)])
   var vertices: PackedVector2Array=PackedVector2Array()
   var uv: PackedVector2Array=PackedVector2Array()
   for corner: Vector2 in corners:
    vertices.append(_stride_vertex((corner-anchor)*0.125))
    uv.append(corner/image_size)
   draw_polygon(vertices,PackedColorArray([tint,tint,tint,tint]),uv,ART)
func _without(rect: Rect2,cuts: Array[Rect2],anchor: Vector2,tint: Color) -> void:
 var pieces: Array[Rect2]=[rect]
 for omission: Rect2 in cuts:
  var next: Array[Rect2]=[]
  for piece: Rect2 in pieces:
   var cut: Rect2=piece.intersection(omission)
   if not cut.has_area():next.append(piece);continue
   next.append(Rect2(piece.position,Vector2(piece.size.x,cut.position.y-piece.position.y)))
   next.append(Rect2(Vector2(piece.position.x,cut.end.y),Vector2(piece.size.x,piece.end.y-cut.end.y)))
   next.append(Rect2(Vector2(piece.position.x,cut.position.y),Vector2(cut.position.x-piece.position.x,cut.size.y)))
   next.append(Rect2(Vector2(cut.end.x,cut.position.y),Vector2(piece.end.x-cut.end.x,cut.size.y)))
  pieces=next
 for piece: Rect2 in pieces:_piece(piece,anchor,tint)
func _arm(start: Vector2,finish: Vector2,region: Rect2,tint: Color) -> void:
 var delta: Vector2=finish-start
 draw_set_transform(start,delta.angle())
 draw_texture_rect_region(ART,Rect2(0,-4,delta.length(),8),region,tint)
 draw_set_transform(Vector2.ZERO)
func _draw() -> void:
 var boss: OathGuardian=get_parent() as OathGuardian
 if boss.state==OathGuardian.State.DEFEATED and boss.get_node("Conclusion").played:return
 var frame: int=0
 if boss.state in [OathGuardian.State.TELEGRAPH,OathGuardian.State.PHASE_TRANSITION,OathGuardian.State.SUPER_WARN]:frame=1
 elif boss.state in [OathGuardian.State.ATTACK,OathGuardian.State.SUPER_ACTIVE]:frame=2
 elif boss.state in [OathGuardian.State.PUNISH,OathGuardian.State.HURT,OathGuardian.State.DEFEATED,OathGuardian.State.SUPER_RECOVER]:frame=3
 var tint: Color=Color(1.35,1.35,1.4)
 if boss.flash>0:tint=Color(2,1.3,1.2)
 if boss.state==OathGuardian.State.DEFEATED:tint=Color(0.55,0.62,0.65,0.85)
 if boss.phase==2 and boss.state!=OathGuardian.State.DEFEATED:tint*=Color(0.94,1.12,1.1)
 var articulation: bool=boss.pattern!=OathGuardian.Pattern.HEAVY and boss.state in [OathGuardian.State.TELEGRAPH,OathGuardian.State.ATTACK]
 if articulation:frame=2
 # Ease into the warning while no hitbox is active; the active blade stays exact.
 if boss.state==OathGuardian.State.TELEGRAPH:
  var blend: float=clampf((boss.warning_seconds()-boss.remaining)/0.16,0.0,1.0)
  if blend<1.0:
   var previous: Color=tint
   previous.a*=1.0-blend
   _piece(REGIONS[0],ROOTS[0],previous)
   tint.a*=blend
 var rect: Rect2=REGIONS[frame]
 var anchor: Vector2=ROOTS[frame]
 var use_walk: bool=frame==0 and boss.state==boss.State.PURSUIT and stride_weight>0.15 and walk_texture!=null
 if use_walk:
  var walk_index: int=[0,1,2,1][int(fposmod(stride_phase,TAU)/TAU*4.0)]
  var walk_tint: Color=tint
  draw_texture_rect_region(walk_texture,Rect2(-45.0,-76.0,87.0,87.0),Rect2(walk_index*512,0,512,512),walk_tint)
 # Full, connected poses for the heavy attack's anticipation and recovery.
 # Active frames retain the original sword geometry shared with the hitbox.
 var use_warning: bool=walk_texture!=null and ((boss.state==boss.State.TELEGRAPH and boss.pattern==boss.Pattern.HEAVY) or boss.state==boss.State.SUPER_WARN)
 var use_recover: bool=walk_texture!=null and boss.state==boss.State.PUNISH and boss.pattern==boss.Pattern.HEAVY
 if use_warning or use_recover:
  var cell_x: int=0 if use_warning else 2
  draw_texture_rect_region(walk_texture,Rect2(-45.0,-74.0,87.0,87.0),Rect2(cell_x*512,512,512,512),tint)
 var use_low_active: bool=low_attack_texture!=null and boss.state==boss.State.ATTACK and boss.pattern in [boss.Pattern.CHARGE,boss.Pattern.SWEEP]
 if use_low_active:_low_attack_pose(tint)
 var use_super_art: bool=attack_texture!=null and boss.state in [boss.State.SUPER_ACTIVE,boss.State.SUPER_RECOVER]
 if use_super_art:_attack_pose(Vector2i(2,1),tint)
 var use_attack_art: bool=attack_texture!=null and boss.pattern!=boss.Pattern.HEAVY and (boss.state in [boss.State.TELEGRAPH,boss.State.PUNISH] or (boss.state==boss.State.ATTACK and boss.pattern==boss.Pattern.WAVE))
 if use_attack_art:
  var art_cell: Vector2i
  if boss.state==boss.State.PUNISH:art_cell=Vector2i(2,1)
  elif boss.state==boss.State.TELEGRAPH:art_cell=Vector2i(0,0) if boss.pattern==boss.Pattern.CHARGE else Vector2i(0,1)
  elif boss.pattern==boss.Pattern.WAVE:art_cell=Vector2i(2,1)
  else:art_cell=Vector2i(1,0) if boss.pattern==boss.Pattern.CHARGE else Vector2i(1,1)
  _attack_pose(art_cell,tint,boss.state==boss.State.ATTACK and boss.pattern in [boss.Pattern.CHARGE,boss.Pattern.SWEEP])
 var cuts: Array[Rect2]=[]
 if frame>=2:cuts.append(BLADE)
 if articulation:cuts.append(Rect2(385,835,65,105))
 if not use_walk and not use_warning and not use_recover and not use_attack_art and not use_super_art and not use_low_active:
  if cuts.is_empty():_piece(rect,anchor,tint)
  else:_without(rect,cuts,anchor,tint)
 if frame==2 and not use_super_art and not (use_attack_art and (boss.state!=boss.State.ATTACK or boss.pattern==boss.Pattern.WAVE)):
  var progress: float=1-boss.remaining/boss.active_seconds()
  var points: Array[Vector2]=ATTACK_SCRIPT.blade_points(boss.pattern,progress)
  var hilt: Vector2=points[0]
  var delta: Vector2=points[1]-hilt
  if boss.state==OathGuardian.State.ATTACK and boss.pattern==OathGuardian.Pattern.CHARGE:
   delta*=lerpf(1.0,0.35,clampf((progress-0.68)/0.32,0.0,1.0))
  if articulation and boss.state==OathGuardian.State.TELEGRAPH:
   var load_progress: float=1-boss.remaining/boss.warning_seconds()
   if boss.pattern==OathGuardian.Pattern.CHARGE:
    hilt=Vector2(8,-24).lerp(Vector2(15,-14),load_progress);delta=Vector2(62,0).rotated(lerpf(-0.3,0,load_progress))
   elif boss.pattern==OathGuardian.Pattern.SWEEP:
    hilt=Vector2(8,-14);delta=Vector2(78,0).rotated(lerpf(-1.6,-0.08,load_progress))
   else:
    hilt=Vector2(12,-30);delta=Vector2(32,0).rotated(lerpf(-1.8,-1.2,load_progress))
  if articulation and not use_attack_art and not use_low_active:
   # Reuse the original steel arm fragments; gauntlet stays at the weapon grip.
   var elbow: Vector2=Vector2(8,-30).lerp(hilt,0.4)
   _arm(Vector2(5,-42),elbow,Rect2(355,835,64,62),tint)
   _arm(elbow,hilt,Rect2(390,855,56,58),tint)
   draw_texture_rect_region(ART,Rect2(hilt-Vector2(3,4),Vector2(6,7)),Rect2(415,869,33,42),tint)
  draw_set_transform(hilt,delta.angle())
  draw_texture_rect_region(ART,Rect2(0,-5,delta.length(),10),BLADE,tint)
  draw_set_transform(Vector2.ZERO)
 if boss.state==OathGuardian.State.TELEGRAPH:
  draw_circle(Vector2(0,-70),3,Color("f3ce8e"))
  draw_line(Vector2(-3,-76),Vector2(3,-76),Color("f3ce8e"),1)
 if boss.state==OathGuardian.State.SUPER_WARN:
  var buildup: float=1.0-boss.remaining/1.3
  draw_arc(Vector2(0,-2),14+buildup*18,PI,TAU,24,Color(0.45,0.9,0.82,0.45+buildup*0.5),1.5)
  for side: int in [-1,1]:
   draw_line(Vector2(side*18,0),Vector2(side*(30+buildup*25),0),Color(0.6,1.0,0.88,0.6),1.5)
 if boss.state==OathGuardian.State.SUPER_ACTIVE:
  var pulse: float=1.0 if boss.remaining>2.55 or (boss.remaining<1.7 and boss.remaining>1.45) else 0.3
  draw_arc(Vector2(0,-2),24,PI,TAU,24,Color(0.5,1.0,0.86,pulse),2)
  if boss.remaining<2.15 and boss.remaining>1.7:
   var second_cue: float=1.0-(boss.remaining-1.7)/0.45
   draw_arc(Vector2(0,-2),12+second_cue*17,PI,TAU,24,Color(0.65,1.0,0.88,0.85),1.5)
 if boss.state==OathGuardian.State.WAKE:
  draw_arc(Vector2(0,-26),34,0,TAU,24,Color("72b9b3"),1)

 if boss.phase==2 and boss.state!=OathGuardian.State.DEFEATED:
  # Oath fissures cling to the approved armor.
  draw_polyline(PackedVector2Array([Vector2(-3,-53),Vector2(0,-49),Vector2(-2,-44),Vector2(2,-39)]),Color("9de6d4"),1)
  draw_polyline(PackedVector2Array([Vector2(-10,-31),Vector2(-6,-28),Vector2(-7,-23)]),Color("77bcb9"),1)
 if boss.state==OathGuardian.State.PHASE_TRANSITION:
  var charge: float=1-boss.remaining/boss.transition_duration
  for i: int in range(7):
   var x: float=-22+i*7
   var height: float=8+fmod(i*11+charge*42,38)
   draw_polyline(PackedVector2Array([Vector2(x,0),Vector2(x-3,-height*0.4),Vector2(x+2,-height*0.7),Vector2(x,-height)]),Color(0.4,0.8,0.75,charge),1)
 if boss.state==OathGuardian.State.TELEGRAPH and boss.pattern!=OathGuardian.Pattern.HEAVY:
  var color: Color=Color("d1b5e1") if boss.pattern==OathGuardian.Pattern.SWEEP else Color("8fd6d1")
  if boss.pattern==OathGuardian.Pattern.CHARGE:
   for i: int in range(3):draw_polyline(PackedVector2Array([Vector2(22+i*8,-5),Vector2(26+i*8,-2),Vector2(22+i*8,1)]),color,1)
  elif boss.pattern==OathGuardian.Pattern.SWEEP:
   draw_arc(Vector2(8,-24),44,-1.4,0.15,12,color,1)
  else:
   draw_polyline(PackedVector2Array([Vector2(20,0),Vector2(24,-5),Vector2(28,0),Vector2(32,-5),Vector2(36,0)]),color,1)

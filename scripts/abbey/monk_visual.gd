extends Node2D
const ART: Texture2D = preload("res://assets/art/m5a/monk.png")
func _draw() -> void:
 var monk: ChainedMonk = get_parent() as ChainedMonk
 var frame: int = 0
 match monk.state:
  ChainedMonk.State.PATROL,ChainedMonk.State.CHASE: frame = 1+int(monk.age*8)%2
  ChainedMonk.State.WARNING: frame = 3
  ChainedMonk.State.ACTIVE: frame = 4
  ChainedMonk.State.RECOVER: frame = 5
  ChainedMonk.State.HURT: frame = 6
  ChainedMonk.State.DEAD: frame = 7
 var cell: Vector2 = ART.get_size()/Vector2(4,2)
 draw_set_transform(Vector2.ZERO,0,Vector2(monk.facing,1))
 var tint: Color = Color(1.7,1.6,1.45) if monk.flash>0 else Color.WHITE
 var destination := Rect2(-25,-40,64,44)
 var source := Rect2(Vector2(frame%4,floori(frame/4.0))*cell,cell)
 if monk.state == ChainedMonk.State.RECOVER:
  # The attack's weight extends into the left edge of this atlas cell.
  # Omit that spill without shifting or stretching the recovery pose.
  var inset := 38.0
  source.position.x += inset
  source.size.x -= inset
  destination.position.x += 64.0 * inset / cell.x
  destination.size.x -= 64.0 * inset / cell.x
 draw_texture_rect_region(ART,destination,source,tint)
 if monk.state == ChainedMonk.State.ACTIVE:
  # Recover the end of the illustrated chain from the neighbouring cell;
  # the narrow vertical slice excludes the neighbouring character's pose.
  var extension := Rect2(cell.x,cell.y+160.0,38.0,60.0)
  var extension_dest := Rect2(39.0,-40.0+44.0*160.0/cell.y,64.0*38.0/cell.x,44.0*60.0/cell.y)
  draw_texture_rect_region(ART,extension_dest,extension,tint)

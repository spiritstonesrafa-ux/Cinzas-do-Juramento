class_name AbbeyChapterLayout
extends RefCounted
## Authored structural spine. Coordinates are local; room links are doors, not distance.
const NAMES: Array[String] = ["Átrio dos Votos", "Claustro Fraturado", "Escadaria dos Contrapesos", "Dormitório das Vigílias", "Cisternas Votivas", "Galeria dos Turíbulos", "Fundição dos Sinos", "Ponte dos Penitentes", "Arquivo dos Juramentos", "Jardim Suspenso", "Campanário Exterior", "Coro das Correntes"]
const KEYS: Array[String] = ["atrium","cloister","stair","dormitory","cistern","gallery","foundry","bridge","archive","garden","belfry","choir"]
const WIDTHS: Array[int] = [1024,1280,1216,1216,1344,1280,1472,1216,1344,1216,1280,1408]
const CP_SECTORS: Array[int] = [1,2,4,6,8,10,11]
const FEATURES: Array[String] = ["Portal partido · terraços de recepção", "Claustro das Sombras · Votos sem Nome", "Ascensão do poço de correntes", "Alcovas em galeria descendente", "Reservatório baixo · canais minerais", "Galeria dos Penitentes · Monge e Contrapeso", "Duas oficinas · moldes e descanso central", "Travessas separadas · abrigos sobre o vazio", "Estantes em galerias ascendentes", "Aqueduto · terraços de vegetação", "Contrafortes em ascensão ao sino", "Bancadas do coro · últimos 240 px seguros"]
static func direction(_id: int) -> int:
 # Consecutive rooms share an eastbound spine. Reverse travel is westbound.
 # Keep profile order/heights/lengths; S4/S10 no longer reverse the arrival input.
 return 1
static func origin(id: int) -> Vector2:
 return Vector2(id*4096,0)
static func pilot_id(id: int) -> int:
 return 0 if id==1 else (1 if id==5 else -1)
static func main_surfaces(id: int) -> Array[Rect2]:
 var result: Array[Rect2] = []
 if id==1:
  result.assign(AbbeyPilotLayout.MAIN)
  result.append(Rect2(960,228,320,192))
  return result
 if id==5:
  result.append(Rect2(0,300,1280,120))
  return result
 # Each profile is an authored sequence of floor elevations. Long plateaus are
 # intentional observation/encounter reserves; rises never exceed 24 px.
 var heights: Array = [
  [300,300,284,268,268,284,300,300], [],
  [588,588,564,540,516,492,468,444,420,396,372,348,324,300,276,252],
  [252,252,276,300,324,324,348,372,396,420,444,444],
  [300,300,324,348,372,396,420,444,468,492,516,516,492,468,444,444], [],
  [348,348,324,300,300,324,348,348,348,324,300,276,276,300,324,348],
  [300,300,284,284,300,300,316,316,300,300,284,300],
  [444,444,420,396,372,372,348,324,300,300,276,252,228,228],
  [300,300,276,252,252,276,300,324,324,300,276,276],
  [612,612,588,564,540,516,492,468,444,420,396,372,348,324,300,276,252],
  [300,300,276,252,228,228,252,276,300,300,300,300]
 ][id]
 var w: float = float(WIDTHS[id])/heights.size()
 for i: int in range(heights.size()):
  var x: float = roundf(i*w)
  var end: float = roundf((i+1)*w)
  var gap: float = 24 if id==7 and i in [3,6,9] else 0
  var rect: Rect2 = Rect2(x+gap,float(heights[i]),end-x-gap,220)
  if direction(id)<0: rect.position.x=WIDTHS[id]-rect.end.x
  result.append(rect)
 return result
static func surfaces(id: int) -> Array[Rect2]:
 var r: Array[Rect2] = main_surfaces(id)
 if id==1: r.append_array(AbbeyPilotLayout.OPTIONAL)
 if id==5:
  r.append(Rect2(80,276,96,12))
  r.append(Rect2(648,276,80,12))
 return r
static func ceilings(id: int) -> Array[Rect2]:
 var result: Array[Rect2]=[]
 var chosen: Array=[]
 if id==3: chosen=[2,3,4,7,8,9]
 elif id==4: chosen=[3,4,5,6]
 elif id==8: chosen=[4,5,6,9,10,11]
 var route: Array[Rect2]=main_surfaces(id)
 for i: int in chosen:
  var floor_rect: Rect2=route[i]
  result.append(Rect2(floor_rect.position+Vector2(0,-92),Vector2(floor_rect.size.x,12)))
 return result
static func entry(id: int, backwards: bool = false) -> Vector2:
 var route: Array[Rect2] = main_surfaces(id)
 var rect: Rect2 = route[-1] if backwards else route[0]
 var side: int = direction(id)*(-1 if backwards else 1)
 return Vector2(rect.position.x+48 if side>0 else rect.end.x-48,rect.position.y)
static func exit_point(id: int, backwards: bool = false) -> Vector2:
 var route: Array[Rect2] = main_surfaces(id)
 var rect: Rect2 = route[0] if backwards else route[-1]
 var side: int = direction(id)*(-1 if backwards else 1)
 return Vector2(16 if side<0 else WIDTHS[id]-16,rect.position.y)
static func bounds(id: int) -> Rect2:
 var top: float = INF
 var bottom: float = -INF
 for r: Rect2 in surfaces(id):
  top=minf(top,r.position.y-112)
  bottom=maxf(bottom,r.position.y+96)
 return Rect2(0,top,WIDTHS[id],maxf(180,bottom-top))
static func checkpoint_position(id: int) -> Vector2:
 var r: Rect2 = main_surfaces(id)[-1]
 var x: float = r.get_center().x
 if id==11: x=WIDTHS[id]-240
 return Vector2(x,r.position.y)
static func room_path(id: int) -> String:
 return "res://scenes/abbey/sectors/sector_%02d.tscn" % (id+1)

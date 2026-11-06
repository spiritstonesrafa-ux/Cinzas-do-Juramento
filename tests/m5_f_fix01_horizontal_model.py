"""Reproducible horizontal-projection model; not a physical shortest-path proof."""
from heapq import heappush,heappop
W=[1024,1280,1216,1216,1344,1280,1472,1216,1344,1216,1280,1408]
# sector indices, exact center positions, passage width; transition zones not modeled
links=[(2,1040,3,250,192),(6,1360,7,280,208),(8,1270,10,270,1056)]
pos=[sorted({16,48,w-48,w-16}|{x for a,x,b,y,_ in links if a==i}|{y for a,x,b,y,_ in links if b==i}) for i,w in enumerate(W)]
def solve(initial):
 # state room, x, unlocked flags, completed advanced-sector flags, 12-sector visited bitmask
 start=(0,48,7 if initial else 0,7 if initial else 0, (1<<12)-1 if initial else 1)
 distances={start:0}; prev={}; heap=[(0,start)]
 while heap:
  cost,s=heappop(heap)
  if cost!=distances[s]:continue
  room,x,opened,completed,visited=s
  if room==11 and x==W[11]-16:
   path=[]
   while s!=start:
    before,kind=prev[s];path.append((kind,s,distances[s]));s=before
   return cost,list(reversed(path))
  neighbors=[]
  for nx in pos[room]:
   if nx!=x:neighbors.append(((room,nx,opened,completed,visited),abs(nx-x),f'walk S{room+1} {x}->{nx}'))
  if x==W[room]-16 and room<11:
   nc=completed
   for i,(_,_,b,_,_) in enumerate(links):
    if b==room:nc|=1<<i
   neighbors.append(((room+1,48,opened,nc,visited | (1<<(room+1))),0,f'normal S{room+1}->S{room+2}'))
  if x==16 and room>0: neighbors.append(((room-1,W[room-1]-48,opened,completed,visited),0,f'return S{room+1}->S{room}'))
  for i,(a,xa,b,xb,w) in enumerate(links):
   if room==b and x==xb and not opened>>i&1 and completed>>i&1 and visited & (1<<a) and visited & (1<<b) and (i!=2 or visited & (1<<9)): neighbors.append(((room,x,opened|1<<i,completed,visited),0,f'unlock A{i+1}'))
   if opened>>i&1:
    if room==a and x==xa: neighbors.append(((b,xb,opened,completed,visited | (1<<b)),w-32,f'A{i+1} forward'))
    if room==b and x==xb: neighbors.append(((a,xa,opened,completed,visited | (1<<a)),w-32,f'A{i+1} reverse'))
  for nxt,weight,kind in neighbors:
   new=cost+weight
   if new<distances.get(nxt,10**18): distances[nxt]=new;prev[nxt]=(s,kind);heappush(heap,(new,nxt))
for label,initial in [('A fresh',False),('B open',True)]:
 value,path=solve(initial);print(label,'horizontal_model_px',value)
 for kind,state,cost in path:print(cost,kind)

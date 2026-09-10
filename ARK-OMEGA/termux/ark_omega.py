#!/data/data/com.termux/files/usr/bin/env python
from __future__ import annotations
import json, shutil, socket, subprocess, time
from pathlib import Path
from textual.app import App, ComposeResult
from textual.containers import Horizontal, Vertical
from textual.screen import ModalScreen
from textual.widgets import Header, Footer, Static, Label, ListView, ListItem

HOME=Path.home(); STATE=HOME/'.local/state/ghost-atlas'; CONFIG=HOME/'.config/ghost-atlas/odin.json'

SECTIONS=['OVERVIEW','NODES','RESOURCES','MISSIONS','PACKETS','PROOF','EVENTS','DOCTOR']

def sh(cmd):
    try: return subprocess.check_output(cmd,stderr=subprocess.DEVNULL,text=True,timeout=2).strip()
    except Exception: return None

def cfg():
    d={'vessel':'ODIN','peer':'AUTO','protocol':'ark-omega/0.1'}
    try: d.update(json.loads(CONFIG.read_text()))
    except Exception: pass
    return d

def save(d):
    CONFIG.parent.mkdir(parents=True,exist_ok=True); CONFIG.write_text(json.dumps(d,indent=2))

def battery():
    raw=sh(['termux-battery-status'])
    if not raw: return 'UNAVAILABLE'
    try:
        j=json.loads(raw); return f"{j.get('percentage','?')}% {j.get('status','UNKNOWN')}"
    except Exception: return 'UNAVAILABLE'

def mem():
    try:
        x={}
        for line in Path('/proc/meminfo').read_text().splitlines():
            k,v=line.split(':',1); x[k]=int(v.strip().split()[0])
        used=x['MemTotal']-x['MemAvailable']; return f"{used/1048576:.1f}/{x['MemTotal']/1048576:.1f} GB"
    except Exception: return 'UNAVAILABLE'

def disk():
    u=shutil.disk_usage(HOME); return f"{(u.total-u.free)/2**30:.1f}/{u.total/2**30:.1f} GB"

def tailscale(): return sh(['tailscale','ip','-4']) or 'UNBOUND'

class Menu(ModalScreen[str|None]):
    def __init__(self,title,items): super().__init__(); self.menu_title=title; self.items=items
    def compose(self)->ComposeResult:
        with Vertical(id='modal'):
            yield Static(self.menu_title,id='modal-title')
            yield ListView(*[ListItem(Label(x),id=f'i{n}') for n,x in enumerate(self.items)],id='modal-list')
            yield Static('ENTER select   ESC cancel',id='modal-help')
    def on_list_view_selected(self,event:ListView.Selected):
        self.dismiss(self.items[int(event.item.id[1:])])
    def on_key(self,event):
        if event.key=='escape': self.dismiss(None)

class Ark(App):
    CSS_PATH='ark_omega.tcss'; TITLE='GHOST ATLAS // ARK OMEGA'; SUB_TITLE='ODIN FIELD COMMAND'
    BINDINGS=[
      ('f1','help','Help'),('f2','peer_menu','Peer'),('f3','nodes','Nodes'),('f4','resources','Resources'),('f5','missions','Missions'),('f6','packets','Packets'),('f7','proof','Proof'),('f8','events','Events'),('f9','doctor','Doctor'),('f10','palette','Command'),
      ('ctrl+r','refresh','Refresh'),('ctrl+q','quit','Quit'),('1','peer_auto','AUTO'),('2','peer_janus','JANUS'),('3','peer_eden','EDEN'),('4','peer_hypernet','HYPERNET')]
    current='OVERVIEW'
    def compose(self)->ComposeResult:
        yield Header(show_clock=True)
        with Horizontal(id='statusbar'):
            yield Label('ARK OMEGA',id='brand'); yield Label(id='peer'); yield Label(id='trust'); yield Label(id='proto')
        with Horizontal(id='workspace'):
            with Vertical(id='nav'):
                yield Static('SYSTEM MENU',classes='section-title')
                for i,s in enumerate(SECTIONS,1): yield Static(f'{i:02}  {s}',classes='nav-item')
            with Vertical(id='content'):
                yield Static(id='screen-title'); yield Static(id='screen-body')
        with Horizontal(id='commandbar'):
            yield Static('F1 HELP  F2 PEER  F3 NODES  F4 RES  F5 MISSIONS  F7 PROOF  F9 DOCTOR  F10 CMD',id='hotkeys')
        yield Footer()
    def on_mount(self): self.set_interval(3,self.refresh_view); self.show('OVERVIEW')
    def set_peer(self,p):
        d=cfg(); d['peer']=p; save(d); self.refresh_view()
    def action_peer_auto(self): self.set_peer('AUTO')
    def action_peer_janus(self): self.set_peer('JANUS')
    def action_peer_eden(self): self.set_peer('EDEN')
    def action_peer_hypernet(self): self.set_peer('HYPERNET')
    def action_nodes(self): self.show('NODES')
    def action_resources(self): self.show('RESOURCES')
    def action_missions(self): self.show('MISSIONS')
    def action_packets(self): self.show('PACKETS')
    def action_proof(self): self.show('PROOF')
    def action_events(self): self.show('EVENTS')
    def action_doctor(self): self.show('DOCTOR')
    def action_refresh(self): self.refresh_view()
    def action_help(self):
        self.push_screen(Menu('ARK OMEGA // HELP',['Hotkeys','Routing Modes','Trust States','Exit']))
    def action_peer_menu(self):
        self.push_screen(Menu('SELECT ACTIVE PEER',['AUTO','JANUS','EDEN','HYPERNET']),lambda x: self.set_peer(x) if x else None)
    def action_palette(self):
        self.push_screen(Menu('COMMAND PALETTE',['Status','Nodes','Resources','Missions','Packets','Proof','Events','Doctor']))
    def show(self,s): self.current=s; self.refresh_view()
    def render_body(self):
        d=cfg(); p=d['peer']; now=time.strftime('%Y-%m-%d %H:%M:%S')
        common=f'VESSEL        ODIN\nACTIVE PEER   {p}\nROUTING       {"CAPABILITY" if p=="AUTO" else "DIRECT"}\nHYPERNET IP   {tailscale()}\nTIME          {now}'
        if self.current=='OVERVIEW': return common+'\n\nMISSION       IDLE\nAUTHORITY     JANUS PRIME\nMUTATIONS     LOCKED UNTIL ADAPTER BIND\nPROOF MODE    STRICT\nUI SOURCE     EVENT-BACKED ONLY'
        if self.current=='NODES': return 'NODE REGISTRY\n\nODIN     LOCAL      READY\nJANUS    REMOTE     UNBOUND\nEDEN     REMOTE     UNBOUND\nHYPERNET FABRIC     '+('BOUND' if tailscale()!='UNBOUND' else 'UNBOUND')
        if self.current=='RESOURCES': return f'LOCAL RESOURCE PLANE\n\nBATTERY       {battery()}\nMEMORY        {mem()}\nSTORAGE       {disk()}\nREMOTE POOL   UNBOUND\nSCHEDULER     SAFE-HOLD'
        if self.current=='MISSIONS': return 'MISSION CONTROL\n\nNO ACTIVE MISSION\n\nRemote mission execution remains disabled until authenticated HYPERNET adapters, policy gates, and receipt path are bound.'
        if self.current=='PACKETS': return 'PACKET OS\n\nLOCAL OUTBOX  '+str(len(list((STATE/'outbox').glob('*'))) if (STATE/'outbox').exists() else 0)+'\nREMOTE QUEUE  UNBOUND'
        if self.current=='PROOF': return 'PROOFGRID\n\nLOCAL RECEIPTS  '+str(len(list((STATE/'receipts').glob('*.json'))) if (STATE/'receipts').exists() else 0)+'\nREMOTE PROOF    UNBOUND'
        if self.current=='EVENTS':
            ep=STATE/'events.jsonl'; n=sum(1 for _ in ep.open()) if ep.exists() else 0; return f'EVENT PLANE\n\nLOCAL EVENTS   {n}\nREMOTE STREAM  UNBOUND\nREPLAY         LOCAL ONLY'
        if self.current=='DOCTOR':
            checks=[('GIT',['git','--version']),('SSH',['ssh','-V']),('GH',['gh','--version']),('TAILSCALE',['tailscale','version']),('TERMUX API',['termux-battery-status'])]
            return 'SYSTEM DOCTOR\n\n'+'\n'.join(f'{n:12} {"PASS" if sh(c) else "UNBOUND"}' for n,c in checks)
        return 'UNKNOWN SCREEN'
    def refresh_view(self):
        d=cfg(); self.query_one('#peer',Label).update(f'PEER {d["peer"]}'); self.query_one('#trust',Label).update('TRUST LOCAL'); self.query_one('#proto',Label).update(d['protocol']); self.query_one('#screen-title',Static).update(f'[{self.current}]'); self.query_one('#screen-body',Static).update(self.render_body())

if __name__=='__main__': Ark().run()

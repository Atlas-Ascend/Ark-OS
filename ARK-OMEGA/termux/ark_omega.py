#!/data/data/com.termux/files/usr/bin/python
from __future__ import annotations

import json
import os
import platform
import shutil
import socket
import subprocess
from datetime import datetime
from pathlib import Path

import psutil
from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.reactive import reactive
from textual.widgets import Footer, Static

STATE = Path.home() / ".local/state/ghost-atlas"
CONF = Path.home() / ".config/ghost-atlas/odin.env"
PEERS = ["AUTO", "ODIN", "JANUS", "EDEN", "HYPERNET", "GAIA", "CLOUD"]
DOMAINS = ["SYSTEM", "FABRIC", "RESOURCES", "MISSIONS", "COGNITION", "PROOF", "SECURITY"]


def load_env(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.exists():
        return out
    for raw in path.read_text(errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        out[k.strip()] = os.path.expandvars(v.strip())
    return out


def local_snapshot() -> dict:
    vm = psutil.virtual_memory()
    disk = shutil.disk_usage(str(Path.home()))
    return {
        "hostname": socket.gethostname(),
        "model": platform.machine(),
        "kernel": platform.release(),
        "python": platform.python_version(),
        "uptime_s": int(datetime.now().timestamp() - psutil.boot_time()),
        "cpu": psutil.cpu_percent(interval=0.15),
        "ram_used_gb": round((vm.total - vm.available) / 1024**3, 2),
        "ram_total_gb": round(vm.total / 1024**3, 2),
        "disk_used_gb": round((disk.total - disk.free) / 1024**3, 1),
        "disk_total_gb": round(disk.total / 1024**3, 1),
    }


def peer_state() -> dict:
    p = STATE / "peer-state.json"
    if not p.exists():
        return {name: "UNBOUND" for name in ["JANUS", "EDEN", "GAIA", "CLOUD"]}
    try:
        data = json.loads(p.read_text())
        return {name: str(data.get(name, "UNBOUND")) for name in ["JANUS", "EDEN", "GAIA", "CLOUD"]}
    except Exception:
        return {name: "STATE_ERROR" for name in ["JANUS", "EDEN", "GAIA", "CLOUD"]}


def latest_receipt() -> str:
    rdir = STATE / "receipts"
    if not rdir.exists():
        return "NONE"
    files = sorted(rdir.glob("*.receipt"), key=lambda p: p.stat().st_mtime, reverse=True)
    return files[0].name if files else "NONE"


def fmt_uptime(seconds: int) -> str:
    h, rem = divmod(seconds, 3600)
    m, _ = divmod(rem, 60)
    return f"{h}h {m:02d}m"


class ArkOmega(App):
    CSS = """
    Screen { background: #030607; color: #d5e2e6; }
    #rail { height: 5; border: round #18d6d9; padding: 0 2; }
    #brand { width: 1fr; content-align: left middle; }
    #trust { width: 28; content-align: right middle; color: #8dff9b; }
    #body { height: 1fr; }
    #nav { width: 22; border: round #1f5960; padding: 1; }
    #main { width: 1fr; border: round #1f5960; padding: 1 2; }
    #side { width: 34; border: round #1f5960; padding: 1 2; }
    .dim { color: #607278; }
    .cyan { color: #25e0e4; }
    .ok { color: #7dff91; }
    .warn { color: #ffe56e; }
    .bad { color: #ff5b63; }
    Footer { background: #071114; color: #a9cdd1; }
    """

    BINDINGS = [
        ("f1", "help", "Help"),
        ("f2", "cycle_peer", "Peer"),
        ("f3", "domain('RESOURCES')", "Resources"),
        ("f5", "domain('MISSIONS')", "Mission"),
        ("f7", "domain('PROOF')", "Proof"),
        ("f9", "recovery", "Recovery"),
        ("f10", "command", "Command"),
        ("ctrl+r", "refresh_now", "Refresh"),
        ("ctrl+q", "quit", "Quit"),
        ("1", "domain('SYSTEM')", "System"),
        ("2", "domain('FABRIC')", "Fabric"),
        ("3", "domain('RESOURCES')", "Resources"),
        ("4", "domain('MISSIONS')", "Missions"),
        ("5", "domain('COGNITION')", "Cognition"),
        ("6", "domain('PROOF')", "Proof"),
        ("7", "domain('SECURITY')", "Security"),
    ]

    domain_name = reactive("SYSTEM")
    peer = reactive("AUTO")

    def compose(self) -> ComposeResult:
        with Horizontal(id="rail"):
            yield Static("GHOST ATLAS // ODIN ARK Ω\nUNIFIED ESTATE OPERATOR", id="brand")
            yield Static("TRUST: LOCAL\nSTATE: ACCESSION", id="trust")
        with Horizontal(id="body"):
            yield Static(id="nav")
            yield Static(id="main")
            yield Static(id="side")
        yield Footer()

    def on_mount(self) -> None:
        env = load_env(CONF)
        self.peer = env.get("GA_PRIMARY_PEER", "AUTO").upper()
        if self.peer not in PEERS:
            self.peer = "AUTO"
        self.refresh_panels()
        self.set_interval(5, self.refresh_panels)

    def watch_domain_name(self) -> None:
        if self.is_mounted:
            self.refresh_panels()

    def watch_peer(self) -> None:
        if self.is_mounted:
            self.refresh_panels()

    def action_domain(self, name: str) -> None:
        self.domain_name = name

    def action_cycle_peer(self) -> None:
        i = PEERS.index(self.peer) if self.peer in PEERS else 0
        self.peer = PEERS[(i + 1) % len(PEERS)]
        self._persist_peer()

    def _persist_peer(self) -> None:
        CONF.parent.mkdir(parents=True, exist_ok=True)
        env = load_env(CONF)
        env["GA_VESSEL"] = env.get("GA_VESSEL", "ODIN")
        env["GA_PEER_MODE"] = self.peer
        env["GA_PRIMARY_PEER"] = self.peer
        CONF.write_text("\n".join(f"{k}={v}" for k, v in env.items()) + "\n")

    def action_refresh_now(self) -> None:
        self.refresh_panels()

    def action_help(self) -> None:
        self.domain_name = "SYSTEM"
        self.notify("1-7 domains • F2 peer • F5 mission • F7 proof • F9 recovery • F10 command • Ctrl-R refresh")

    def action_recovery(self) -> None:
        self.domain_name = "SECURITY"
        self.notify("Recovery mode is read-only until an explicit recovery action is selected.", severity="warning")

    def action_command(self) -> None:
        self.notify("Command palette binding staged. Mutating remote commands remain fail-closed.", severity="warning")

    def refresh_panels(self) -> None:
        snap = local_snapshot()
        peers = peer_state()
        nav = "[b cyan]FIRMWARE DOMAINS[/b cyan]\n\n" + "\n".join(
            f"[{'b cyan' if d == self.domain_name else 'dim'}]{'▶' if d == self.domain_name else ' '} {i+1:02d} {d}[/]"
            for i, d in enumerate(DOMAINS)
        ) + f"\n\n[b cyan]EXECUTION CONTEXT[/b cyan]\n\nPEER  [b]{self.peer}[/b]\n\nF2 cycles peer context."
        self.query_one("#nav", Static).update(nav)

        if self.domain_name == "SYSTEM":
            body = f"""[b cyan]SYSTEM[/b cyan]\n\nVESSEL       ODIN\nHOST         {snap['hostname']}\nARCH         {snap['model']}\nKERNEL       {snap['kernel']}\nPYTHON       {snap['python']}\nUPTIME       {fmt_uptime(snap['uptime_s'])}\n\nCPU          {snap['cpu']:.0f}%\nRAM          {snap['ram_used_gb']} / {snap['ram_total_gb']} GB\nSTORAGE      {snap['disk_used_gb']} / {snap['disk_total_gb']} GB\n\n[b ok]LOCAL TELEMETRY VERIFIED[/b ok]"""
        elif self.domain_name == "FABRIC":
            body = "[b cyan]HYPERNET FABRIC[/b cyan]\n\n" + "\n".join(f"{n:<10} {s}" for n, s in peers.items()) + f"\n\nROUTE MODE   {self.peer}\n\nRemote state is rendered only from local authenticated state files. Missing evidence = UNBOUND."
        elif self.domain_name == "RESOURCES":
            body = f"[b cyan]RESOURCE PLANE[/b cyan]\n\nLOCAL CPU    {snap['cpu']:.0f}%\nLOCAL RAM    {snap['ram_used_gb']} / {snap['ram_total_gb']} GB\nLOCAL DISK   {snap['disk_used_gb']} / {snap['disk_total_gb']} GB\n\nREMOTE POOL  UNBOUND\nGPU POOL     UNBOUND\nMODEL POOL   UNBOUND"
        elif self.domain_name == "MISSIONS":
            body = "[b cyan]MISSION CONTROL[/b cyan]\n\nCANARY       ARK-OMEGA-RUNTIME-CANARY-001\nSTATE        RECEIPT-DRIVEN\nMUTATION     LOCKED UNLESS AUTHORIZED\n\nRun [b]ark-canary[/b] from a shell to generate a real correlated receipt."
        elif self.domain_name == "COGNITION":
            body = "[b cyan]COGNITION[/b cyan]\n\nATLAS MIND   BOUND BY ESTATE CONTRACT\nGARI         BOUND BY ESTATE CONTRACT\nTHOTH        RECEIPT-BOUND\nCASEGRAPH    CONTRACTED\n\nNo private chain-of-thought is exposed. Only operational events and receipts are displayed."
        elif self.domain_name == "PROOF":
            body = f"[b cyan]PROOFGRID / THOTH[/b cyan]\n\nLATEST LOCAL RECEIPT\n{latest_receipt()}\n\nSEALED state requires correlated JANUS authority, route evidence, execution, SECA, DEVOS, ProofGrid, and Thoth acknowledgement."
        else:
            body = "[b cyan]SECURITY / RECOVERY[/b cyan]\n\nPOLICY       FAIL-CLOSED\nREMOTE MUT.  LOCKED BY DEFAULT\nREPLAY       DENIED BY NONCE POLICY\nRECOVERY     READ-ONLY ENTRY\nVISHVARUPA   COMPATIBILITY / SUCCESSION\n\nF9 enters recovery context; destructive repair is never automatic."
        self.query_one("#main", Static).update(body)

        side = f"""[b cyan]ESTATE STATE[/b cyan]\n\nPEER          {self.peer}\nJANUS         {peers['JANUS']}\nEDEN          {peers['EDEN']}\nGAIA          {peers['GAIA']}\nCLOUD         {peers['CLOUD']}\n\n[b cyan]PROOF[/b cyan]\n{latest_receipt()}\n\n[b cyan]TRUTH LAW[/b cyan]\nNo visual state is promoted beyond available evidence.\n\n[b warn]F9 RECOVERY[/b warn]\n[b]F10 COMMAND[/b]"""
        self.query_one("#side", Static).update(side)


if __name__ == "__main__":
    ArkOmega().run()

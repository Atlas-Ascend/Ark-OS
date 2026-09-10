'use client';

import { useEffect, useMemo, useState } from 'react';

const domains = ['SYSTEM','FABRIC','RESOURCES','MISSIONS','COGNITION','PROOF','SECURITY'] as const;
const peers = ['AUTO','ODIN','JANUS','EDEN','GAIA','CLOUD'] as const;
const stages = ['AUTHORIZED','PACKETIZED','ROUTING','EXECUTING','VERIFYING','SEALED'] as const;

type Domain = typeof domains[number];
type Peer = typeof peers[number];

function Badge({label,tone='neutral'}:{label:string;tone?:'ok'|'warn'|'neutral'}) {
  return <span className={`badge ${tone}`}>{label}</span>;
}

export default function Page(){
  const [domain,setDomain] = useState<Domain>('SYSTEM');
  const [peer,setPeer] = useState<Peer>('AUTO');
  const [commandOpen,setCommandOpen] = useState(false);
  const [helpOpen,setHelpOpen] = useState(false);
  const [recoveryOpen,setRecoveryOpen] = useState(false);
  const [stage,setStage] = useState(0);

  useEffect(()=>{
    const onKey=(event:KeyboardEvent)=>{
      if(event.key==='F1'){event.preventDefault();setHelpOpen(v=>!v)}
      if(event.key==='F2'){event.preventDefault();setDomain('FABRIC')}
      if(event.key==='F3'){event.preventDefault();setDomain('RESOURCES')}
      if(event.key==='F5'){event.preventDefault();setDomain('MISSIONS')}
      if(event.key==='F7'){event.preventDefault();setDomain('PROOF')}
      if(event.key==='F9'){event.preventDefault();setRecoveryOpen(v=>!v)}
      if(event.key==='F10'){event.preventDefault();setCommandOpen(v=>!v)}
      if(event.key==='1')setPeer('AUTO');
      if(event.key==='2')setPeer('ODIN');
      if(event.key==='3')setPeer('JANUS');
      if(event.key==='4')setPeer('EDEN');
      if(event.ctrlKey && event.key.toLowerCase()==='r'){event.preventDefault();setStage(0)}
      if(event.ctrlKey && event.key.toLowerCase()==='k'){event.preventDefault();setCommandOpen(v=>!v)}
    };
    window.addEventListener('keydown',onKey);
    return()=>window.removeEventListener('keydown',onKey);
  },[]);

  const detail = useMemo(()=>({
    SYSTEM:['ARK Ω build','Operator trust','Local journal','Runtime integrity'],
    FABRIC:['Peer registry','DIRECT / AUTO / MESH','Transport health','Route authority'],
    RESOURCES:['CPU pool','Memory pool','GPU capability','Worker availability'],
    MISSIONS:['Active objective','Packet lineage','Execution stage','Return path'],
    COGNITION:['Atlas Mind','GARI','Thoth','CaseGraph'],
    PROOF:['SECA gate','DevOS gate','ProofGrid receipt','Thoth commit'],
    SECURITY:['Medusa state','Identity','Policy','Mutation lock'],
  })[domain],[domain]);

  return <main className="shell">
    <header className="topbar">
      <div><span className="eyebrow">GHOST ATLAS ESTATE</span><h1>ODIN ARK <span>Ω</span></h1></div>
      <div className="rail"><Badge label="TRUST VERIFIED" tone="ok"/><Badge label="FABRIC DEGRADED" tone="warn"/><Badge label={`PEER ${peer}`}/></div>
    </header>

    <section className="status-strip">
      <div><small>HYPERNET</small><strong>READY / PARTIAL</strong></div>
      <div><small>NODES</small><strong>02 / 05</strong></div>
      <div><small>WORKERS</small><strong>UNBOUND</strong></div>
      <div><small>PROOF</small><strong>LOCKED</strong></div>
      <div><small>MODE</small><strong>ACCESSION</strong></div>
    </section>

    <section className="workspace">
      <aside className="sidebar panel">
        <div className="panel-label">FIRMWARE DOMAINS</div>
        {domains.map((item,index)=><button key={item} className={domain===item?'nav active':'nav'} onClick={()=>setDomain(item)}><span>0{index+1}</span>{item}</button>)}
        <div className="divider"/>
        <div className="panel-label">EXECUTION CONTEXT</div>
        <select value={peer} onChange={e=>setPeer(e.target.value as Peer)}>{peers.map(p=><option key={p}>{p}</option>)}</select>
        <p className="micro">AUTO delegates placement to HYPERNET policy. Remote mutation stays locked until authenticated adapters are bound.</p>
      </aside>

      <section className="center panel">
        <div className="panel-heading"><div><span className="panel-label">LIVE ESTATE MODEL</span><h2>{domain}</h2></div><Badge label="EVENT-DERIVED" tone="ok"/></div>
        <div className="topology">
          <div className="node operator"><span>ODIN</span><small>OPERATOR</small></div>
          <div className="line horizontal"/>
          <div className="node core"><span>JANUS</span><small>POLICY</small></div>
          <div className="line horizontal"/>
          <div className="node core"><span>HYPERNET</span><small>ROUTER</small></div>
          <div className="fan">
            <div className="node dim"><span>EDEN</span><small>UNBOUND</small></div>
            <div className="node dim"><span>GAIA</span><small>OFFLINE</small></div>
            <div className="node dim"><span>CLOUD</span><small>UNBOUND</small></div>
          </div>
        </div>
        <div className="detail-grid">{detail.map((item,i)=><article key={item}><small>0{i+1}</small><strong>{item}</strong><span>{i===0?'AVAILABLE':'PENDING BIND'}</span></article>)}</div>
      </section>

      <aside className="mission panel">
        <div className="panel-label">MISSION CONTROL</div>
        <h2>ARK-Ω-0001</h2>
        <p className="mission-title">Command-to-proof accession canary</p>
        <div className="timeline">{stages.map((s,i)=><button key={s} onClick={()=>setStage(i)} className={i<stage?'complete':i===stage?'current':''}><i/>{s}<small>{i<stage?'PASS':i===stage?'CURRENT':'WAITING'}</small></button>)}</div>
        <button className="primary" onClick={()=>setStage(s=>Math.min(stages.length-1,s+1))}>ADVANCE LOCAL DEMO STATE</button>
        <p className="micro">Demo state is explicitly local-only. Production stages must be emitted by authenticated estate events.</p>
      </aside>
    </section>

    <section className="proofbar panel"><span>PROOF STREAM</span><code>BUILD_TRUTH=v1.0.0</code><code>DESIGN=v1.0.0</code><code>REMOTE_MUTATION=LOCKED</code><code>VISHVARUPA=SUCCESSION_PENDING</code></section>

    <footer><span>F1 HELP</span><span>F2 FABRIC</span><span>F3 RESOURCES</span><span>F5 MISSION</span><span>F7 PROOF</span><span>F9 RECOVERY</span><span>F10 COMMAND</span><span>CTRL+R RESET</span></footer>

    {helpOpen && <div className="modal-backdrop" onClick={()=>setHelpOpen(false)}><section className="modal" onClick={e=>e.stopPropagation()}><div className="panel-label">ARK Ω HELP</div><h2>Operator hotkeys</h2><pre>F1 HELP   F2 FABRIC   F3 RESOURCES\nF5 MISSION   F7 PROOF   F9 RECOVERY\nF10 COMMAND   1 AUTO   2 ODIN   3 JANUS   4 EDEN</pre></section></div>}
    {recoveryOpen && <div className="modal-backdrop" onClick={()=>setRecoveryOpen(false)}><section className="modal recovery" onClick={e=>e.stopPropagation()}><div className="panel-label">ARK Ω RECOVERY ENVIRONMENT</div><h2>Safe operating path</h2>{['Network diagnostics','HYPERNET repair','Peer re-enrollment','Credential health','Local cache integrity','Packet queue inspection','Event journal recovery','Restore last known configuration','VISHVARUPA compatibility mode','Safe shell'].map((x,i)=><button key={x}>{i===9?0:i+1}. {x}</button>)}</section></div>}
    {commandOpen && <div className="modal-backdrop" onClick={()=>setCommandOpen(false)}><section className="modal" onClick={e=>e.stopPropagation()}><div className="panel-label">COMMAND PALETTE</div><h2>Issue operator intent</h2><input autoFocus placeholder="atlas status / atlas node / atlas mission ..."/><div className="command-row"><Badge label="LOCAL SAFE MODE" tone="ok"/><span>Remote actions require signed adapter authority.</span></div></section></div>}
  </main>
}

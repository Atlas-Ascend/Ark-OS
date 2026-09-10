const APK_WORKFLOW = 'https://github.com/Atlas-Ascend/Ark-OS/actions/workflows/atlas-android-apk.yml';
const REPO = 'https://github.com/Atlas-Ascend/Ark-OS';

export default function HomePage() {
  return (
    <main className="wrap">
      <div className="eyebrow">Ghost Atlas // ARK-OS</div>
      <section className="card">
        <h1>Atlas Assistant</h1>
        <p className="sub">
          The Alexa-style Android operator assistant for ARK-OS — voice-first,
          command-to-proof, and wired into the Ghost Atlas runtime fabric.
        </p>

        <div className="grid">
          <div className="pill"><strong>Android</strong><br />Native APK lineage</div>
          <div className="pill"><strong>Voice</strong><br />Atlas assistant surface</div>
          <div className="pill"><strong>Proof</strong><br />Command-to-proof CI</div>
        </div>

        <div className="actions">
          <a className="btn" href={APK_WORKFLOW}>APK Build</a>
          <a className="btn alt" href={REPO}>ARK-OS Repo</a>
        </div>

        <div className="meta">
          Canonical repo: Atlas-Ascend/Ark-OS<br />
          Workflow: atlas-android-apk.yml<br />
          Surface: Atlas Assistant install portal<br />
          Runtime: Vercel / Next.js / TypeScript
        </div>
      </section>
    </main>
  );
}

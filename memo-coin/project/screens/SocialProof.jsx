// SocialProof.jsx — Stats + avatars

function StatBlock({ value, label, sub, accent }) {
  return (
    <div style={{
      flex: 1, padding: '20px 16px',
      background: 'rgba(255,255,255,0.04)',
      border: '1px solid rgba(255,255,255,0.07)',
      borderRadius: 20,
    }}>
      <div style={{
        fontSize: 28, fontWeight: 800, color: accent,
        letterSpacing: -1, lineHeight: 1, fontFamily: '-apple-system, system-ui',
      }}>{value}</div>
      <div style={{ fontSize: 13, fontWeight: 600, color: '#fff', marginTop: 8 }}>{label}</div>
      <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', marginTop: 2 }}>{sub}</div>
    </div>
  );
}

const AVATARS = [
  ['#fbbf24','#f97316'], ['#22c55e','#06b6d4'], ['#a855f7','#ec4899'],
  ['#ef4444','#f97316'], ['#06b6d4','#3b82f6'], ['#22c55e','#84cc16'],
];

function SocialProofScreen({ onContinue, onBack, accent = '#22c55e' }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'flex-end',
        marginBottom: 40,
      }}>
        <div style={{ flex: 1, height: 4, background: 'rgba(255,255,255,0.08)', borderRadius: 99 }}>
          <div style={{ width: '15%', height: '100%', background: accent, borderRadius: 99 }} />
        </div>
      </div>

      {/* Avatar stack */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 0, marginBottom: 22 }}>
        {AVATARS.map(([a, b], i) => (
          <div key={i} style={{
            width: 38, height: 38, borderRadius: 999,
            background: `linear-gradient(135deg, ${a}, ${b})`,
            border: '2px solid #0a0a0b',
            marginLeft: i === 0 ? 0 : -10,
            zIndex: AVATARS.length - i,
          }} />
        ))}
        <div style={{
          marginLeft: -10, height: 38, padding: '0 12px',
          borderRadius: 999, background: 'rgba(255,255,255,0.08)',
          border: '2px solid #0a0a0b', display: 'flex', alignItems: 'center',
          fontSize: 12, fontWeight: 700, color: '#fff', zIndex: 0,
        }}>+247K</div>
      </div>

      <h1 style={{
        fontSize: 36, fontWeight: 800, lineHeight: 1.05,
        letterSpacing: -1.2, margin: 0,
      }}>
        You're in good<br/>company.
      </h1>
      <p style={{
        fontSize: 15, color: 'rgba(255,255,255,0.55)',
        margin: '12px 0 28px', lineHeight: 1.45, maxWidth: 320,
      }}>
        Traders are using memo to find their next 100x — every minute of the day.
      </p>

      <div style={{ display: 'flex', gap: 10, marginBottom: 10 }}>
        <StatBlock value="247K+" label="Active traders" sub="Across 84 countries" accent={accent} />
        <StatBlock value="$1.2B" label="Tracked daily" sub="In meme volume" accent="#a855f7" />
      </div>
      <div style={{ display: 'flex', gap: 10 }}>
        <StatBlock value="4.8★" label="App Store" sub="12,400 reviews" accent="#fbbf24" />
        <StatBlock value="12.8K" label="Coins tracked" sub="6 chains, real-time" accent={accent} />
      </div>

      <div style={{ flex: 1 }} />

      <button onClick={onContinue} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: '#fff', color: '#0a0a0b', border: 'none',
        fontSize: 17, fontWeight: 700, letterSpacing: -0.3, cursor: 'pointer',
      }}>
        Continue
      </button>
    </div>
  );
}

window.SocialProofScreen = SocialProofScreen;

// Welcome.jsx — Hero screen with animated ticker tape

const COINS_HERO = [
  { sym: 'PEPE',  pct: '+247%', color: '#22c55e' },
  { sym: 'WIF',   pct: '+89%',  color: '#22c55e' },
  { sym: 'BONK',  pct: '+412%', color: '#22c55e' },
  { sym: 'POPCAT',pct: '+33%',  color: '#22c55e' },
  { sym: 'MOG',   pct: '−12%',  color: '#ef4444' },
  { sym: 'BRETT', pct: '+76%',  color: '#22c55e' },
  { sym: 'TURBO', pct: '+158%', color: '#22c55e' },
  { sym: 'MEW',   pct: '+44%',  color: '#22c55e' },
  { sym: 'SHIB',  pct: '+19%',  color: '#22c55e' },
  { sym: 'FLOKI', pct: '−5%',   color: '#ef4444' },
];

function CoinChip({ sym, pct, color, accent }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 8,
      padding: '8px 14px 8px 8px',
      background: 'rgba(255,255,255,0.04)',
      border: '1px solid rgba(255,255,255,0.07)',
      borderRadius: 999, flexShrink: 0,
    }}>
      <div style={{
        width: 28, height: 28, borderRadius: 999,
        background: `linear-gradient(135deg, ${accent}, rgba(255,255,255,0.05))`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 11, fontWeight: 700, color: '#fff',
        boxShadow: 'inset 0 0 0 1px rgba(255,255,255,0.12)',
      }}>{sym.slice(0,2)}</div>
      <div style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.1 }}>
        <span style={{ fontSize: 12, fontWeight: 600, color: '#fff', letterSpacing: 0.2 }}>{sym}</span>
        <span style={{ fontSize: 11, fontWeight: 600, color }}>{pct}</span>
      </div>
    </div>
  );
}

function TickerRow({ reverse = false, speed = 60, accent }) {
  const items = [...COINS_HERO, ...COINS_HERO];
  return (
    <div style={{ overflow: 'hidden', maskImage: 'linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent)' }}>
      <div style={{
        display: 'flex', gap: 8,
        animation: `${reverse ? 'tickerR' : 'tickerL'} ${speed}s linear infinite`,
        width: 'max-content',
      }}>
        {items.map((c, i) => <CoinChip key={i} {...c} accent={accent} />)}
      </div>
    </div>
  );
}

function WelcomeScreen({ onContinue, accent = '#22c55e', appName = 'memo' }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', position: 'relative', overflow: 'hidden',
    }}>
      <style>{`
        @keyframes tickerL { from { transform: translateX(0); } to { transform: translateX(-50%); } }
        @keyframes tickerR { from { transform: translateX(-50%); } to { transform: translateX(0); } }
        @keyframes pulse {
          0%, 100% { opacity: 0.8; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.05); }
        }
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(8px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>

      {/* glow */}
      <div style={{
        position: 'absolute', top: -120, left: '50%', transform: 'translateX(-50%)',
        width: 480, height: 480, borderRadius: 999,
        background: `radial-gradient(circle, ${accent}33 0%, transparent 60%)`,
        pointerEvents: 'none',
      }} />

      <div style={{ height: 100 }} />

      {/* Tickers */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 12 }}>
        <TickerRow speed={50} accent={accent} />
        <TickerRow reverse speed={40} accent="#a855f7" />
        <TickerRow speed={60} accent={accent} />
      </div>

      <div style={{ flex: 1 }} />

      {/* Hero copy */}
      <div style={{ padding: '0 28px', animation: 'fadeUp 0.6s ease' }}>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 6,
          padding: '6px 12px', borderRadius: 999,
          background: `${accent}1f`, border: `1px solid ${accent}40`,
          marginBottom: 16,
        }}>
          <div style={{
            width: 6, height: 6, borderRadius: 999, background: accent,
            animation: 'pulse 1.6s ease infinite',
          }} />
          <span style={{ fontSize: 12, fontWeight: 600, color: accent, letterSpacing: 0.4 }}>
            LIVE · 12,847 COINS TRACKED
          </span>
        </div>
        <h1 style={{
          fontSize: 44, fontWeight: 800, lineHeight: 1.02,
          letterSpacing: -1.5, margin: 0,
          fontFamily: '-apple-system, system-ui',
        }}>
          Catch memes<br/>
          <span style={{
            background: `linear-gradient(120deg, ${accent}, #a855f7)`,
            WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
          }}>before the pump.</span>
        </h1>
        <p style={{
          fontSize: 16, lineHeight: 1.45, color: 'rgba(255,255,255,0.6)',
          margin: '14px 0 0', fontWeight: 400, maxWidth: 320,
        }}>
          Real-time alerts, top mover feeds and wallet tracking — all in one app.
        </p>
      </div>

      <div style={{ padding: '24px 20px 30px' }}>
        <button onClick={onContinue} style={{
          width: '100%', height: 56, borderRadius: 18,
          background: '#fff', color: '#0a0a0b', border: 'none',
          fontSize: 17, fontWeight: 700, letterSpacing: -0.3,
          boxShadow: `0 0 0 1px rgba(255,255,255,0.08), 0 12px 28px ${accent}40`,
          cursor: 'pointer',
        }}>
          Get started
        </button>
        <div style={{
          textAlign: 'center', fontSize: 13,
          color: 'rgba(255,255,255,0.4)', marginTop: 14,
        }}>
          Already have an account? <span style={{ color: '#fff', fontWeight: 600 }}>Sign in</span>
        </div>
      </div>
    </div>
  );
}

window.WelcomeScreen = WelcomeScreen;

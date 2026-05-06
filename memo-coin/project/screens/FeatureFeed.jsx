// FeatureFeed.jsx — Top mover feed + chart

function Sparkline({ color, up = true }) {
  const path = up
    ? 'M0,30 L8,28 L16,32 L24,22 L32,24 L40,16 L48,18 L56,8 L64,4'
    : 'M0,8 L8,12 L16,10 L24,18 L32,16 L40,22 L48,20 L56,28 L64,30';
  return (
    <svg width="64" height="36" viewBox="0 0 64 36">
      <defs>
        <linearGradient id={`spark-${color}`} x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.3"/>
          <stop offset="100%" stopColor={color} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={`${path} L64,36 L0,36 Z`} fill={`url(#spark-${color})`}/>
      <path d={path} stroke={color} strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function CoinRow({ rank, sym, name, price, pct, color, accent, glyph }) {
  const up = !pct.startsWith('−');
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 16px',
      background: 'rgba(255,255,255,0.04)',
      border: '1px solid rgba(255,255,255,0.06)',
      borderRadius: 14,
    }}>
      <div style={{
        fontSize: 12, fontWeight: 700, color: 'rgba(255,255,255,0.4)',
        width: 16,
      }}>{rank}</div>
      <div style={{
        width: 32, height: 32, borderRadius: 999,
        background: `linear-gradient(135deg, ${color}, ${color}66)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 14, fontWeight: 700, color: '#fff',
      }}>{glyph}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: '#fff' }}>{sym}</div>
        <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.45)' }}>{name}</div>
      </div>
      <Sparkline color={up ? '#22c55e' : '#ef4444'} up={up} />
      <div style={{ textAlign: 'right' }}>
        <div style={{ fontSize: 13, fontWeight: 600, color: '#fff' }}>{price}</div>
        <div style={{
          fontSize: 12, fontWeight: 700,
          color: up ? '#22c55e' : '#ef4444',
        }}>{pct}</div>
      </div>
    </div>
  );
}

function FeatureFeedScreen({ onContinue, accent = '#22c55e' }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
    }}>
      <div style={{ display: 'flex', gap: 6, marginBottom: 30 }}>
        {[1,1,1,1,0.3,0.15].map((w, i) => (
          <div key={i} style={{
            flex: 1, height: 4, borderRadius: 99,
            background: i < 3 ? accent : 'rgba(255,255,255,0.08)',
            opacity: i < 3 ? 1 : 0.4,
          }} />
        ))}
      </div>

      <h1 style={{
        fontSize: 36, fontWeight: 800, lineHeight: 1.05,
        letterSpacing: -1.2, margin: 0,
      }}>
        Top movers,<br/>updated <span style={{ color: accent }}>live.</span>
      </h1>
      <p style={{
        fontSize: 15, color: 'rgba(255,255,255,0.55)',
        margin: '12px 0 22px', lineHeight: 1.45, maxWidth: 320,
      }}>
        See what's pumping right now. Sort by volume, holders, age, or social heat.
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <CoinRow rank="01" sym="PEPE" name="Pepe"   price="$0.0000142" pct="+247%" color="#22c55e" glyph="🐸" />
        <CoinRow rank="02" sym="WIF"  name="dogwifhat" price="$3.42"   pct="+89%"  color="#a855f7" glyph="🐶" />
        <CoinRow rank="03" sym="BONK" name="Bonk"   price="$0.0000341" pct="+412%" color="#f97316" glyph="🔥" />
        <CoinRow rank="04" sym="MOG"  name="Mog Coin" price="$0.00184"  pct="−12%"  color="#ef4444" glyph="🐱" />
        <CoinRow rank="05" sym="BRETT" name="Brett" price="$0.176"     pct="+76%"  color="#06b6d4" glyph="🐸" />
      </div>

      <div style={{ flex: 1 }} />

      <button onClick={onContinue} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: '#fff', color: '#0a0a0b', border: 'none',
        fontSize: 17, fontWeight: 700, letterSpacing: -0.3, cursor: 'pointer',
        marginTop: 16,
      }}>
        Continue
      </button>
    </div>
  );
}

window.FeatureFeedScreen = FeatureFeedScreen;

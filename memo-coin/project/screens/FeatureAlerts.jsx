// FeatureAlerts.jsx — Real-time alerts feature carousel

function AlertCard({ time, title, body, color, delay = 0 }) {
  return (
    <div style={{
      padding: '14px 16px',
      background: 'rgba(255,255,255,0.06)',
      backdropFilter: 'blur(20px)',
      border: '1px solid rgba(255,255,255,0.1)',
      borderRadius: 18,
      animation: `slideIn 0.5s ease ${delay}s both`,
      display: 'flex', gap: 12, alignItems: 'flex-start',
    }}>
      <div style={{
        width: 38, height: 38, borderRadius: 9,
        background: `linear-gradient(135deg, ${color}, ${color}88)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M10 2v6l4 2-4 2v6M3 10h14" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ fontSize: 13, fontWeight: 700, color: '#fff' }}>memo</span>
          <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.45)' }}>{time}</span>
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, color: '#fff', marginTop: 2 }}>{title}</div>
        <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.6)', marginTop: 1, lineHeight: 1.35 }}>{body}</div>
      </div>
    </div>
  );
}

function FeatureAlertsScreen({ onContinue, accent = '#22c55e' }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
      position: 'relative', overflow: 'hidden',
    }}>
      <style>{`
        @keyframes slideIn {
          from { opacity: 0; transform: translateY(12px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>

      {/* progress */}
      <div style={{ display: 'flex', gap: 6, marginBottom: 30 }}>
        {[1,1,1,0.3,0.15,0.15].map((w, i) => (
          <div key={i} style={{
            flex: 1, height: 4, borderRadius: 99,
            background: i < 2 ? accent : 'rgba(255,255,255,0.08)',
            opacity: i < 2 ? 1 : 0.4,
          }} />
        ))}
      </div>

      <h1 style={{
        fontSize: 36, fontWeight: 800, lineHeight: 1.05,
        letterSpacing: -1.2, margin: 0,
      }}>
        Never miss<br/>a <span style={{ color: accent }}>pump</span> again.
      </h1>
      <p style={{
        fontSize: 15, color: 'rgba(255,255,255,0.55)',
        margin: '12px 0 24px', lineHeight: 1.45, maxWidth: 320,
      }}>
        Get alerts the second a coin spikes, whales buy, or a token gets listed.
      </p>

      {/* Mock alerts */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        <AlertCard
          time="now"
          title="🚀 PEPE up 47% in 1h"
          body="Vol +$24M. 3 whale wallets bought in last 4 min."
          color="#22c55e"
          delay={0.1}
        />
        <AlertCard
          time="2m"
          title="🐋 Whale alert: WIF"
          body="Wallet 0x9a..3f bought $1.2M of WIF."
          color="#a855f7"
          delay={0.3}
        />
        <AlertCard
          time="6m"
          title="🆕 New token trending"
          body="$BANANA listed 2h ago, vol up 8x. 184 holders."
          color="#fbbf24"
          delay={0.5}
        />
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

window.FeatureAlertsScreen = FeatureAlertsScreen;

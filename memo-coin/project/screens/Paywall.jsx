// Paywall.jsx + Done

function FeatureCheck({ children, accent }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '6px 0',
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: 999,
        background: accent,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        <svg width="12" height="12" viewBox="0 0 12 12">
          <path d="M2 6l3 3 5-6" stroke="#0a0a0b" strokeWidth="2.4" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
      <span style={{ fontSize: 15, color: '#fff', fontWeight: 500 }}>{children}</span>
    </div>
  );
}

function PaywallScreen({ onContinue, onSkip, accent = '#22c55e' }) {
  const [plan, setPlan] = React.useState('yearly');
  const plans = {
    yearly:  { price: '$3.33', sub: '/wk', total: '$49.99/yr', save: 'SAVE 67%', trial: '3-day free trial' },
    weekly:  { price: '$9.99', sub: '/wk', total: 'Billed weekly', save: null, trial: 'No trial' },
  };
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff',
      position: 'relative', overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', top: -100, left: '50%', transform: 'translateX(-50%)',
        width: 500, height: 400, borderRadius: '50%',
        background: `radial-gradient(ellipse, ${accent}33, transparent 65%)`,
      }} />

      {/* Close */}
      <button onClick={onSkip} style={{
        position: 'absolute', top: 64, right: 20, zIndex: 10,
        width: 32, height: 32, borderRadius: 999,
        background: 'rgba(255,255,255,0.08)',
        border: 'none', color: 'rgba(255,255,255,0.5)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
      }}>
        <svg width="14" height="14" viewBox="0 0 14 14"><path d="M2 2l10 10M12 2L2 12" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/></svg>
      </button>

      <div style={{ padding: '90px 24px 0', position: 'relative' }}>
        <div style={{
          display: 'inline-flex', padding: '5px 12px', borderRadius: 999,
          background: `linear-gradient(120deg, ${accent}, #a855f7)`,
          fontSize: 11, fontWeight: 800, letterSpacing: 0.6, color: '#0a0a0b',
          marginBottom: 16,
        }}>memo PRO</div>
        <h1 style={{
          fontSize: 36, fontWeight: 800, lineHeight: 1.02, letterSpacing: -1.3, margin: 0,
        }}>
          Unlock the<br/>full edge.
        </h1>
        <p style={{
          fontSize: 14, color: 'rgba(255,255,255,0.55)',
          margin: '10px 0 0', lineHeight: 1.45,
        }}>
          Try free for 3 days. Cancel anytime, keep what you've made.
        </p>
      </div>

      <div style={{ padding: '20px 24px 0' }}>
        <FeatureCheck accent={accent}>Unlimited real-time alerts</FeatureCheck>
        <FeatureCheck accent={accent}>Whale wallet tracking (50 wallets)</FeatureCheck>
        <FeatureCheck accent={accent}>Early-launch discovery feed</FeatureCheck>
        <FeatureCheck accent={accent}>Advanced charts & on-chain data</FeatureCheck>
        <FeatureCheck accent={accent}>Priority support</FeatureCheck>
      </div>

      <div style={{ flex: 1 }} />

      {/* Plans */}
      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {/* Yearly */}
        <button onClick={() => setPlan('yearly')} style={{
          padding: '14px 16px', textAlign: 'left',
          background: plan === 'yearly' ? `${accent}15` : 'rgba(255,255,255,0.04)',
          border: `2px solid ${plan === 'yearly' ? accent : 'rgba(255,255,255,0.08)'}`,
          borderRadius: 18, cursor: 'pointer', position: 'relative',
          color: '#fff',
        }}>
          {plans.yearly.save && (
            <div style={{
              position: 'absolute', top: -10, right: 12,
              padding: '4px 10px', borderRadius: 999,
              background: accent, color: '#0a0a0b',
              fontSize: 10, fontWeight: 800, letterSpacing: 0.5,
            }}>{plans.yearly.save}</div>
          )}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: 14, fontWeight: 700 }}>Yearly</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.55)', marginTop: 2 }}>
                {plans.yearly.trial}, then {plans.yearly.total}
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <span style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.6 }}>{plans.yearly.price}</span>
              <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)' }}>{plans.yearly.sub}</span>
            </div>
          </div>
        </button>

        {/* Weekly */}
        <button onClick={() => setPlan('weekly')} style={{
          padding: '14px 16px', textAlign: 'left',
          background: plan === 'weekly' ? `${accent}15` : 'rgba(255,255,255,0.04)',
          border: `2px solid ${plan === 'weekly' ? accent : 'rgba(255,255,255,0.08)'}`,
          borderRadius: 18, cursor: 'pointer', color: '#fff',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: 14, fontWeight: 700 }}>Weekly</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.55)', marginTop: 2 }}>
                {plans.weekly.trial}, billed weekly
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <span style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.6 }}>{plans.weekly.price}</span>
              <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)' }}>{plans.weekly.sub}</span>
            </div>
          </div>
        </button>
      </div>

      <div style={{ padding: '16px 20px 30px' }}>
        <button onClick={onContinue} style={{
          width: '100%', height: 56, borderRadius: 18,
          background: accent, color: '#0a0a0b', border: 'none',
          fontSize: 17, fontWeight: 800, letterSpacing: -0.3, cursor: 'pointer',
          boxShadow: `0 12px 28px ${accent}66`,
        }}>
          Start 3-day free trial
        </button>
        <div style={{
          textAlign: 'center', fontSize: 11,
          color: 'rgba(255,255,255,0.4)', marginTop: 12, lineHeight: 1.5,
        }}>
          No payment now. We'll remind you 2 days before trial ends.<br/>
          <span style={{ textDecoration: 'underline' }}>Restore</span> · <span style={{ textDecoration: 'underline' }}>Terms</span> · <span style={{ textDecoration: 'underline' }}>Privacy</span>
        </div>
      </div>
    </div>
  );
}

function DoneScreen({ onContinue, accent = '#22c55e' }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
      alignItems: 'center', justifyContent: 'center', textAlign: 'center',
      position: 'relative', overflow: 'hidden',
    }}>
      <style>{`
        @keyframes pop { 0% { transform: scale(0.5); opacity: 0; } 70% { transform: scale(1.1); } 100% { transform: scale(1); opacity: 1; } }
      `}</style>
      <div style={{
        width: 100, height: 100, borderRadius: 999,
        background: `linear-gradient(135deg, ${accent}, #a855f7)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        marginBottom: 28, animation: 'pop 0.5s ease',
        boxShadow: `0 20px 60px ${accent}88`,
      }}>
        <svg width="48" height="48" viewBox="0 0 48 48">
          <path d="M12 24l8 8 16-18" stroke="#0a0a0b" strokeWidth="5" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
      <h1 style={{ fontSize: 36, fontWeight: 800, letterSpacing: -1.2, margin: 0 }}>
        You're in.
      </h1>
      <p style={{
        fontSize: 16, color: 'rgba(255,255,255,0.6)',
        margin: '12px 0 0', maxWidth: 280, lineHeight: 1.45,
      }}>
        Your feed's ready. Time to find that 100x.
      </p>

      <div style={{ position: 'absolute', bottom: 30, left: 20, right: 20 }}>
        <button onClick={onContinue} style={{
          width: '100%', height: 56, borderRadius: 18,
          background: '#fff', color: '#0a0a0b', border: 'none',
          fontSize: 17, fontWeight: 700, letterSpacing: -0.3, cursor: 'pointer',
        }}>Open memo</button>
      </div>
    </div>
  );
}

Object.assign(window, { PaywallScreen, DoneScreen });

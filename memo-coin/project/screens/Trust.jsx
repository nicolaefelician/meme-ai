// Trust.jsx — notifications permission + analyzing loader + reviews

function NotifyScreen({ onContinue, onSkip, accent = '#22c55e' }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
      position: 'relative', overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', top: 60, left: '50%', transform: 'translateX(-50%)',
        width: 360, height: 360, borderRadius: 999,
        background: `radial-gradient(circle, ${accent}33, transparent 60%)`,
        pointerEvents: 'none',
      }} />

      {/* Mock notification preview */}
      <div style={{ position: 'relative', display: 'flex', justifyContent: 'center', marginTop: 40, marginBottom: 30 }}>
        <div style={{
          width: 320, padding: '12px 14px', borderRadius: 22,
          background: 'rgba(40,40,42,0.85)',
          backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.1)',
          display: 'flex', gap: 12, alignItems: 'flex-start',
          boxShadow: `0 24px 48px ${accent}55`,
          transform: 'rotate(-2deg)',
        }}>
          <div style={{
            width: 38, height: 38, borderRadius: 9,
            background: `linear-gradient(135deg, ${accent}, #a855f7)`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 16, fontWeight: 800, color: '#fff', flexShrink: 0,
          }}>m</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ fontSize: 13, fontWeight: 700, color: '#fff' }}>memo</span>
              <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.45)' }}>now</span>
            </div>
            <div style={{ fontSize: 14, fontWeight: 600, color: '#fff', marginTop: 1 }}>
              🚀 PEPE breaking out
            </div>
            <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.65)', lineHeight: 1.3 }}>
              Up 18% in 5 minutes. Volume 4x avg.
            </div>
          </div>
        </div>
      </div>

      <h1 style={{ fontSize: 34, fontWeight: 800, lineHeight: 1.05, letterSpacing: -1.1, margin: 0, textAlign: 'center' }}>
        Don't sleep<br/>on the next 100x.
      </h1>
      <p style={{
        fontSize: 15, color: 'rgba(255,255,255,0.6)',
        margin: '14px auto 0', lineHeight: 1.45, maxWidth: 320, textAlign: 'center',
      }}>
        Turn on alerts and we'll ping you the second something moves. You can fine-tune what wakes you.
      </p>

      <div style={{ flex: 1 }} />

      <button onClick={onContinue} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: accent, color: '#0a0a0b', border: 'none',
        fontSize: 17, fontWeight: 700, letterSpacing: -0.3, cursor: 'pointer',
        boxShadow: `0 12px 28px ${accent}66`,
      }}>
        Turn on alerts
      </button>
      <button onClick={onSkip} style={{
        background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.4)',
        fontSize: 14, fontWeight: 600, marginTop: 14, cursor: 'pointer',
      }}>
        Maybe later
      </button>
    </div>
  );
}

function AnalyzingScreen({ onComplete, accent = '#22c55e' }) {
  const [progress, setProgress] = React.useState(0);
  const [step, setStep] = React.useState(0);
  const steps = [
    'Scanning 12,847 coins…',
    'Cross-referencing top wallets…',
    'Tuning alerts to your goals…',
    'Building your personal feed…',
  ];
  React.useEffect(() => {
    const t = setInterval(() => {
      setProgress(p => {
        const n = p + 1.4;
        if (n >= 100) {
          clearInterval(t);
          setTimeout(onComplete, 400);
          return 100;
        }
        setStep(Math.min(steps.length - 1, Math.floor(n / 25)));
        return n;
      });
    }, 50);
    return () => clearInterval(t);
  }, []);

  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
      alignItems: 'center', justifyContent: 'center', position: 'relative', overflow: 'hidden',
    }}>
      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes coinFloat {
          0%, 100% { transform: translateY(0) rotate(0); opacity: 0.4; }
          50% { transform: translateY(-20px) rotate(8deg); opacity: 0.9; }
        }
      `}</style>

      {/* Floating coins bg */}
      {['🐸','🚀','💎','🔥','🐋','✨'].map((e, i) => (
        <div key={i} style={{
          position: 'absolute',
          fontSize: 28,
          left: `${10 + (i * 14) % 80}%`,
          top: `${15 + (i * 23) % 70}%`,
          animation: `coinFloat ${3 + i * 0.4}s ease-in-out infinite ${i * 0.3}s`,
          opacity: 0.5,
        }}>{e}</div>
      ))}

      {/* Ring */}
      <div style={{ position: 'relative', width: 180, height: 180 }}>
        <svg width="180" height="180" viewBox="0 0 180 180">
          <circle cx="90" cy="90" r="80" stroke="rgba(255,255,255,0.06)" strokeWidth="6" fill="none"/>
          <circle cx="90" cy="90" r="80" stroke={accent} strokeWidth="6" fill="none"
            strokeLinecap="round" strokeDasharray={`${(progress/100)*502} 502`}
            transform="rotate(-90 90 90)"
            style={{ transition: 'stroke-dasharray 0.1s' }}
          />
        </svg>
        <div style={{
          position: 'absolute', inset: 0, display: 'flex',
          alignItems: 'center', justifyContent: 'center',
          fontSize: 36, fontWeight: 800, letterSpacing: -1,
        }}>{Math.floor(progress)}%</div>
      </div>

      <h2 style={{
        fontSize: 24, fontWeight: 800, letterSpacing: -0.6,
        margin: '32px 0 8px', textAlign: 'center',
      }}>Building your feed…</h2>
      <p style={{
        fontSize: 14, color: 'rgba(255,255,255,0.55)',
        margin: 0, textAlign: 'center', minHeight: 22,
        transition: 'opacity 0.3s',
      }}>{steps[step]}</p>
    </div>
  );
}

function ReviewsScreen({ onContinue, accent = '#22c55e' }) {
  const reviews = [
    { name: 'Marcus T.', handle: '@degenmarc', stars: 5,
      title: 'Caught a 40x because of this',
      body: "memo alerted me the second BONK started moving. I would've been asleep. This app literally pays for itself." },
    { name: 'Lina K.', handle: '@linatrades', stars: 5,
      title: 'Replaced 4 other apps',
      body: "Whale tracking + alerts + portfolio in one place. The signal quality is unreal compared to anything else I've tried." },
    { name: 'Jay R.', handle: '@jaybonks', stars: 5,
      title: 'Best app on the App Store',
      body: "I'm up 12k this month from alerts alone. UI is clean, data is fast. No notes." },
  ];
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
    }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 4 }}>
        <span style={{ fontSize: 44, fontWeight: 800, letterSpacing: -1.5 }}>4.8</span>
        <div style={{ display: 'flex', gap: 2 }}>
          {[1,2,3,4,5].map(i => (
            <svg key={i} width="18" height="18" viewBox="0 0 24 24" fill={i <= 4 ? '#fbbf24' : '#fbbf24'}>
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          ))}
        </div>
      </div>
      <div style={{ fontSize: 14, color: 'rgba(255,255,255,0.5)', marginBottom: 24 }}>
        Based on 12,400+ App Store reviews
      </div>

      <h1 style={{ fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -1, margin: 0 }}>
        Traders are<br/>making bank.
      </h1>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 20 }}>
        {reviews.map((r, i) => (
          <div key={i} style={{
            padding: '16px 16px',
            background: 'rgba(255,255,255,0.04)',
            border: '1px solid rgba(255,255,255,0.07)',
            borderRadius: 18,
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: 14, fontWeight: 700 }}>{r.title}</div>
                <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.45)', marginTop: 1 }}>
                  {r.name} · {r.handle}
                </div>
              </div>
              <div style={{ display: 'flex', gap: 1 }}>
                {Array.from({length: r.stars}).map((_, j) => (
                  <svg key={j} width="12" height="12" viewBox="0 0 24 24" fill="#fbbf24">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                  </svg>
                ))}
              </div>
            </div>
            <p style={{
              fontSize: 13, color: 'rgba(255,255,255,0.7)',
              margin: '8px 0 0', lineHeight: 1.4,
            }}>"{r.body}"</p>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />

      <button onClick={onContinue} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: '#fff', color: '#0a0a0b', border: 'none',
        fontSize: 17, fontWeight: 700, letterSpacing: -0.3, cursor: 'pointer',
        marginTop: 20,
      }}>Continue</button>
    </div>
  );
}

Object.assign(window, { NotifyScreen, AnalyzingScreen, ReviewsScreen });

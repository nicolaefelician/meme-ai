// Personalize.jsx — Three personalization screens

function OptionCard({ icon, title, sub, selected, onClick, accent }) {
  return (
    <button onClick={onClick} style={{
      width: '100%', padding: '16px 16px',
      display: 'flex', alignItems: 'center', gap: 14,
      background: selected ? `${accent}15` : 'rgba(255,255,255,0.04)',
      border: `1.5px solid ${selected ? accent : 'rgba(255,255,255,0.08)'}`,
      borderRadius: 18, cursor: 'pointer', textAlign: 'left',
      transition: 'all 0.15s ease', color: '#fff',
    }}>
      <div style={{
        width: 44, height: 44, borderRadius: 12, flexShrink: 0,
        background: selected ? accent : 'rgba(255,255,255,0.06)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 22,
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, fontWeight: 700, color: '#fff' }}>{title}</div>
        <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)', marginTop: 2, lineHeight: 1.35 }}>{sub}</div>
      </div>
      <div style={{
        width: 22, height: 22, borderRadius: 999,
        background: selected ? accent : 'transparent',
        border: `2px solid ${selected ? accent : 'rgba(255,255,255,0.2)'}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        {selected && (
          <svg width="12" height="12" viewBox="0 0 12 12">
            <path d="M2 6l3 3 5-6" stroke="#0a0a0b" strokeWidth="2.2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </div>
    </button>
  );
}

function ProgressBar({ step, total = 6, accent }) {
  return (
    <div style={{ display: 'flex', gap: 6, marginBottom: 30 }}>
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} style={{
          flex: 1, height: 4, borderRadius: 99,
          background: i < step ? accent : 'rgba(255,255,255,0.08)',
          opacity: i < step ? 1 : 0.5,
        }} />
      ))}
    </div>
  );
}

function ExperienceScreen({ onContinue, accent = '#22c55e', step = 4, total = 6, value, setValue }) {
  const opts = [
    { id: 'newbie',  icon: '🌱', title: 'Just curious',     sub: 'New to memes — show me the ropes' },
    { id: 'casual',  icon: '🎯', title: 'Casual trader',    sub: 'I hold a few coins, want better signals' },
    { id: 'degen',   icon: '🔥', title: 'Full degen',       sub: 'Aping daily, give me the edge' },
    { id: 'whale',   icon: '🐋', title: 'Whale / pro',      sub: 'Multi-wallet, advanced data' },
  ];
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
    }}>
      <ProgressBar step={step} total={total} accent={accent} />
      <h1 style={{ fontSize: 32, fontWeight: 800, lineHeight: 1.05, letterSpacing: -1, margin: 0 }}>
        How deep are you<br/>in the game?
      </h1>
      <p style={{ fontSize: 15, color: 'rgba(255,255,255,0.55)', margin: '10px 0 26px', lineHeight: 1.45 }}>
        We'll tune the feed to your level.
      </p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {opts.map(o => (
          <OptionCard key={o.id} {...o}
            selected={value === o.id} onClick={() => setValue(o.id)} accent={accent}
          />
        ))}
      </div>
      <div style={{ flex: 1 }} />
      <button onClick={onContinue} disabled={!value} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: value ? '#fff' : 'rgba(255,255,255,0.1)',
        color: value ? '#0a0a0b' : 'rgba(255,255,255,0.3)',
        border: 'none', fontSize: 17, fontWeight: 700, letterSpacing: -0.3,
        cursor: value ? 'pointer' : 'default', marginTop: 16,
      }}>Continue</button>
    </div>
  );
}

function ChainsScreen({ onContinue, accent = '#22c55e', step = 5, total = 6, values, toggle }) {
  const chains = [
    { id: 'sol',   icon: '◎', title: 'Solana',     sub: 'Pump.fun, Raydium' , color: '#9945ff'},
    { id: 'base',  icon: 'B', title: 'Base',       sub: 'Coinbase L2', color: '#0052ff' },
    { id: 'eth',   icon: 'Ξ', title: 'Ethereum',   sub: 'Uniswap, ERC-20', color: '#627eea' },
    { id: 'bsc',   icon: '◈', title: 'BNB Chain',  sub: 'PancakeSwap', color: '#f3ba2f' },
    { id: 'tron',  icon: 'T', title: 'Tron',       sub: 'SunPump', color: '#ef4444' },
    { id: 'all',   icon: '✦', title: 'Track all chains', sub: 'Recommended', color: accent },
  ];
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
    }}>
      <ProgressBar step={step} total={total} accent={accent} />
      <h1 style={{ fontSize: 32, fontWeight: 800, lineHeight: 1.05, letterSpacing: -1, margin: 0 }}>
        Which chains<br/>do you trade?
      </h1>
      <p style={{ fontSize: 15, color: 'rgba(255,255,255,0.55)', margin: '10px 0 22px', lineHeight: 1.45 }}>
        Pick all that apply.
      </p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {chains.map(c => (
          <OptionCard key={c.id}
            icon={<span style={{ color: c.color, fontSize: 22, fontWeight: 800 }}>{c.icon}</span>}
            title={c.title} sub={c.sub}
            selected={values.includes(c.id)} onClick={() => toggle(c.id)} accent={accent}
          />
        ))}
      </div>
      <div style={{ flex: 1 }} />
      <button onClick={onContinue} disabled={values.length === 0} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: values.length ? '#fff' : 'rgba(255,255,255,0.1)',
        color: values.length ? '#0a0a0b' : 'rgba(255,255,255,0.3)',
        border: 'none', fontSize: 17, fontWeight: 700, letterSpacing: -0.3,
        cursor: values.length ? 'pointer' : 'default', marginTop: 16,
      }}>Continue</button>
    </div>
  );
}

function GoalsScreen({ onContinue, accent = '#22c55e', step = 6, total = 6, values, toggle }) {
  const goals = [
    { id: 'pumps',   icon: '🚀', title: 'Catch pumps early', sub: 'Real-time spike alerts' },
    { id: 'whales',  icon: '🐋', title: 'Track whale wallets', sub: 'See what smart money buys' },
    { id: 'new',     icon: '✨', title: 'Discover new launches', sub: 'Trending coins under 24h old' },
    { id: 'social',  icon: '📈', title: 'Follow social heat', sub: 'X mentions, dev activity' },
    { id: 'pnl',     icon: '💼', title: 'Track my portfolio', sub: 'P&L across wallets' },
  ];
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0a0b', color: '#fff', padding: '80px 24px 30px',
    }}>
      <ProgressBar step={step} total={total} accent={accent} />
      <h1 style={{ fontSize: 32, fontWeight: 800, lineHeight: 1.05, letterSpacing: -1, margin: 0 }}>
        What's your<br/>edge gonna be?
      </h1>
      <p style={{ fontSize: 15, color: 'rgba(255,255,255,0.55)', margin: '10px 0 22px', lineHeight: 1.45 }}>
        Pick your top priorities — we'll surface them first.
      </p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {goals.map(g => (
          <OptionCard key={g.id} {...g}
            selected={values.includes(g.id)} onClick={() => toggle(g.id)} accent={accent}
          />
        ))}
      </div>
      <div style={{ flex: 1 }} />
      <button onClick={onContinue} disabled={values.length === 0} style={{
        width: '100%', height: 56, borderRadius: 18,
        background: values.length ? '#fff' : 'rgba(255,255,255,0.1)',
        color: values.length ? '#0a0a0b' : 'rgba(255,255,255,0.3)',
        border: 'none', fontSize: 17, fontWeight: 700, letterSpacing: -0.3,
        cursor: values.length ? 'pointer' : 'default', marginTop: 16,
      }}>Build my feed</button>
    </div>
  );
}

Object.assign(window, { ExperienceScreen, ChainsScreen, GoalsScreen });

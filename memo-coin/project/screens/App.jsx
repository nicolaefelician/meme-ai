// App.jsx — Onboarding flow controller

const { useState } = React;

const SCREENS = [
  'welcome', 'social', 'alerts', 'feed',
  'experience', 'chains', 'goals',
  'notify', 'analyzing', 'reviews', 'paywall', 'done',
];

function OnboardingFlow({ accent = '#22c55e', startAt = 0 }) {
  const [idx, setIdx] = useState(startAt);
  const [exp, setExp] = useState(null);
  const [chains, setChains] = useState([]);
  const [goals, setGoals] = useState([]);

  const next = () => setIdx(i => Math.min(SCREENS.length - 1, i + 1));
  const reset = () => setIdx(0);
  const toggleChain = id => setChains(c => c.includes(id) ? c.filter(x => x !== id) : [...c, id]);
  const toggleGoal = id => setGoals(g => g.includes(id) ? g.filter(x => x !== id) : [...g, id]);

  const screen = SCREENS[idx];

  let content;
  switch (screen) {
    case 'welcome':    content = <WelcomeScreen onContinue={next} accent={accent} />; break;
    case 'social':     content = <SocialProofScreen onContinue={next} accent={accent} />; break;
    case 'alerts':     content = <FeatureAlertsScreen onContinue={next} accent={accent} />; break;
    case 'feed':       content = <FeatureFeedScreen onContinue={next} accent={accent} />; break;
    case 'experience': content = <ExperienceScreen onContinue={next} accent={accent} value={exp} setValue={setExp} step={1} total={3} />; break;
    case 'chains':     content = <ChainsScreen onContinue={next} accent={accent} values={chains} toggle={toggleChain} step={2} total={3} />; break;
    case 'goals':      content = <GoalsScreen onContinue={next} accent={accent} values={goals} toggle={toggleGoal} step={3} total={3} />; break;
    case 'notify':     content = <NotifyScreen onContinue={next} onSkip={next} accent={accent} />; break;
    case 'analyzing':  content = <AnalyzingScreen onComplete={next} accent={accent} />; break;
    case 'reviews':    content = <ReviewsScreen onContinue={next} accent={accent} />; break;
    case 'paywall':    content = <PaywallScreen onContinue={next} onSkip={next} accent={accent} />; break;
    case 'done':       content = <DoneScreen onContinue={reset} accent={accent} />; break;
    default:           content = null;
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {content}
    </div>
  );
}

window.OnboardingFlow = OnboardingFlow;
window.SCREENS = SCREENS;

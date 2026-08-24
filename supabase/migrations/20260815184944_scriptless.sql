-- ═══════════════════════════════════════════════════════════════════════════════
-- REHEARSAL / SCRIPTLESS — Schéma SQL Supabase Complet v2.0
-- Stack: Flutter + Supabase + PowerSync + Mastra + LiveKit + RevenueCat
-- AJOUTS v2: custom_personalities, conversation.custom_personality_id
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 0. EXTENSIONS
-- =============================================================================
-- v3 FIX: uuid_generate_v4() (uuid-ossp) failed on Supabase with
-- "function uuid_generate_v4() does not exist" — Supabase installs extensions into
-- the "extensions" schema, not "public", so the function isn't visible without
-- schema-qualifying it. gen_random_uuid() is built into Postgres 13+ core (pg_catalog),
-- needs no extension, and is Supabase's own recommended default. Neither uuid-ossp
-- nor pgcrypto is used anywhere else in this schema, so both extensions are dropped.

-- =============================================================================
-- 1. ENUM TYPES
-- =============================================================================

CREATE TYPE user_role AS ENUM (
  'first_time_manager',
  'team_manager',
  'cross_functional_manager',
  'director'
);

CREATE TYPE industry AS ENUM (
  'tech',
  'retail',
  'finance',
  'healthcare',
  'consulting',
  'education',
  'manufacturing',
  'other'
);

CREATE TYPE difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced');

CREATE TYPE conversation_status AS ENUM (
  'connecting',
  'in_progress',
  'paused',
  'completed',
  'aborted',
  'error'
);

CREATE TYPE message_speaker AS ENUM ('user', 'interlocutor', 'system');

CREATE TYPE subscription_tier AS ENUM ('free', 'pro_monthly', 'pro_annual', 'ultra');

CREATE TYPE subscription_status AS ENUM (
  'active',
  'cancelled',
  'expired',
  'in_trial',
  'grace_period'
);

CREATE TYPE notification_type AS ENUM (
  'daily_reminder',
  'streak_at_risk',
  'new_scenario',
  'feedback_ready',
  'weekly_recap',
  're_engagement',
  'trial_ending',
  'achievement_unlocked'
);

-- v3 FIX: was a free-form TEXT DEFAULT 'Novice' on profiles — an ENUM prevents typos/garbage
-- values from calculate_user_level() or any future manual UPDATE, and keeps get_leaderboard()'s
-- return type in sync with the actual column type.
CREATE TYPE user_level AS ENUM ('Novice', 'Apprentice', 'Confident', 'Expert', 'Master');

-- v3 NEW: constrains user_activity_logs.activity_type so client/backend code can't silently
-- log a typo'd event name that the streak/stats triggers (which match on exact strings) would
-- then just silently ignore. Add new values here as you add new activity types.
CREATE TYPE activity_type AS ENUM (
  'conversation_started',
  'conversation_completed',
  'conversation_abandoned',
  'scenario_created',
  'personality_created',
  'achievement_unlocked',
  'streak_saved',
  'subscription_started',
  'subscription_cancelled'
);

CREATE TYPE personality_type AS ENUM (
  'defensive',
  'passive_aggressive',
  'evasive',
  'collaborative',
  'emotional',
  'dominant',
  'passive',
  'custom'
);

-- =============================================================================
-- 2. PROFILES (Extension de auth.users)
-- =============================================================================

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Informations de base
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,

  -- Persona / Onboarding
  role user_role,
  industry industry,
  confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 10),
  objectives TEXT[] DEFAULT '{}',

  -- Préférences
  preferred_language TEXT DEFAULT 'en',
  daily_reminder_time TIME DEFAULT '09:00',
  push_notifications_enabled BOOLEAN DEFAULT true,
  email_notifications_enabled BOOLEAN DEFAULT true,

  -- Audio settings
  ia_volume INTEGER DEFAULT 80 CHECK (ia_volume BETWEEN 0 AND 100),
  ia_speech_rate NUMERIC(2,1) DEFAULT 1.0 CHECK (ia_speech_rate BETWEEN 0.5 AND 2.0),
  push_to_talk_enabled BOOLEAN DEFAULT true,

  -- Accessibility
  text_size_level INTEGER DEFAULT 1 CHECK (text_size_level BETWEEN 1 AND 3),
  reduce_animations BOOLEAN DEFAULT false,
  always_show_transcription BOOLEAN DEFAULT false,

  -- Gamification
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_conversations INTEGER DEFAULT 0,
  total_training_minutes INTEGER DEFAULT 0,
  overall_score NUMERIC(3,1) DEFAULT 0.0 CHECK (overall_score BETWEEN 0 AND 10),
  level user_level DEFAULT 'Novice',

  -- Metadata
  onboarding_completed BOOLEAN DEFAULT false,
  trial_start_date TIMESTAMPTZ,
  subscription_tier subscription_tier DEFAULT 'free',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE profiles IS 'Profil utilisateur etendu, lie a auth.users';
COMMENT ON COLUMN profiles.objectives IS 'Objectifs selectionnes lors du onboarding';
COMMENT ON COLUMN profiles.level IS 'Niveau calcule: Novice, Apprentice, Confident, Expert, Master';

-- =============================================================================
-- 3. SCENARIO CATEGORIES
-- =============================================================================

CREATE TABLE scenario_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  name_fr TEXT,
  description TEXT,
  description_fr TEXT,
  icon_name TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 4. SCENARIOS (Prédéfinis + Personnalisés)
-- =============================================================================

CREATE TABLE scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  category_id UUID REFERENCES scenario_categories(id) ON DELETE SET NULL,
  slug TEXT UNIQUE NOT NULL,

  title TEXT NOT NULL,
  title_fr TEXT,
  description TEXT NOT NULL,
  description_fr TEXT,
  context TEXT NOT NULL,
  context_fr TEXT,
  user_goal TEXT NOT NULL,
  user_goal_fr TEXT,

  interlocutor_name TEXT NOT NULL DEFAULT 'Alex',
  interlocutor_role TEXT,
  interlocutor_personality personality_type NOT NULL DEFAULT 'defensive',
  interlocutor_traits TEXT[],

  difficulty difficulty_level NOT NULL DEFAULT 'beginner',
  estimated_duration_minutes INTEGER DEFAULT 5,
  skills_practiced TEXT[] DEFAULT '{}',

  thumbnail_url TEXT,
  illustration_url TEXT,
  example_audio_url TEXT,

  points_reward INTEGER DEFAULT 10,

  is_predefined BOOLEAN DEFAULT true,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  is_public BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,

  completion_count INTEGER DEFAULT 0,
  average_score NUMERIC(3,1) DEFAULT 0.0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE scenarios IS 'Scenarios de conversation: predefinis ou crees par les utilisateurs Pro';

-- =============================================================================
-- 5. CUSTOM PERSONALITIES (NOUVEAU v2)
-- =============================================================================

CREATE TABLE custom_personalities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Identite
  name TEXT NOT NULL,
  role TEXT NOT NULL,

  -- Personnalite
  base_type personality_type DEFAULT 'custom',
  traits TEXT[] NOT NULL DEFAULT '{}',

  -- Style de communication (JSON structure)
  communication_style JSONB NOT NULL DEFAULT '{
    "pace": "normal",
    "formality": "professional",
    "verbosity": "normal",
    "emotional_expression": "moderate"
  }',

  -- Dynamique comportementale
  triggers TEXT[] DEFAULT '{}',
  weaknesses TEXT[] DEFAULT '{}',
  goals TEXT[] DEFAULT '{}',
  background TEXT,

  -- Voix
  voice_tone JSONB DEFAULT '{
    "pitch": "medium",
    "energy": "moderate"
  }',

  -- Metadonnees
  is_favorite BOOLEAN DEFAULT false,
  usage_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE custom_personalities IS 'Personnalites d''interlocuteur creees par les utilisateurs Pro';

-- =============================================================================
-- 6. USER SCENARIO CUSTOMIZATIONS
-- =============================================================================

CREATE TABLE user_scenario_customizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,

  custom_interlocutor_name TEXT,
  custom_relationship TEXT,
  custom_context TEXT,

  is_favorite BOOLEAN DEFAULT false,
  notes TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, scenario_id)
);

-- =============================================================================
-- 7. CONVERSATIONS (MODIFIE v2: ajout custom_personality_id)
-- =============================================================================

CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  customization_id UUID REFERENCES user_scenario_customizations(id) ON DELETE SET NULL,

  -- NOUVEAU v2: reference vers custom_personality
  custom_personality_id UUID REFERENCES custom_personalities(id) ON DELETE SET NULL,

  livekit_room_name TEXT,

  status conversation_status NOT NULL DEFAULT 'connecting',
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  duration_seconds INTEGER,

  mode TEXT DEFAULT 'voice' CHECK (mode IN ('voice', 'text')),

  is_aborted BOOLEAN DEFAULT false,
  abort_reason TEXT,

  -- v3 NOTE: keep this to non-identifying diagnostics (OS, app version, model name, network type).
  -- Do NOT populate with IDFA/IDFV or any advertising/tracking identifier unless you've implemented
  -- App Tracking Transparency consent — storing them without it is an App Store rejection risk
  -- and a privacy-policy/GDPR issue independent of Apple's review.
  device_info JSONB DEFAULT '{}',
  network_quality TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE conversations IS 'Session de conversation entre utilisateur et IA interlocuteur';
COMMENT ON COLUMN conversations.custom_personality_id IS 'Reference vers une personnalite custom creee par l''utilisateur (Pro only)';

-- =============================================================================
-- 8. CONVERSATION MESSAGES
-- =============================================================================

CREATE TABLE conversation_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,

  speaker message_speaker NOT NULL,
  content TEXT NOT NULL,

  timestamp_seconds NUMERIC(6,2) NOT NULL,

  audio_url TEXT,
  audio_duration_ms INTEGER,

  sentiment_score NUMERIC(3,2),
  tone_tags TEXT[],

  sequence_number INTEGER NOT NULL,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 9. FEEDBACKS
-- =============================================================================

CREATE TABLE feedbacks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  clarity_score NUMERIC(3,1) NOT NULL CHECK (clarity_score BETWEEN 1 AND 10),
  assertiveness_score NUMERIC(3,1) NOT NULL CHECK (assertiveness_score BETWEEN 1 AND 10),
  empathy_score NUMERIC(3,1) NOT NULL CHECK (empathy_score BETWEEN 1 AND 10),
  structure_score NUMERIC(3,1) NOT NULL CHECK (structure_score BETWEEN 1 AND 10),
  confidence_score NUMERIC(3,1) NOT NULL CHECK (confidence_score BETWEEN 1 AND 10),
  overall_score NUMERIC(3,1) NOT NULL CHECK (overall_score BETWEEN 1 AND 10),

  summary TEXT NOT NULL,
  summary_fr TEXT,
  strengths JSONB NOT NULL DEFAULT '[]',
  improvements JSONB NOT NULL DEFAULT '[]',
  key_moments JSONB NOT NULL DEFAULT '[]',
  confidence_boost TEXT,
  confidence_boost_fr TEXT,

  detected_skills TEXT[],
  missed_opportunities TEXT[],

  previous_attempt_score NUMERIC(3,1),
  improvement_delta NUMERIC(3,1),

  is_read BOOLEAN DEFAULT false,

  generated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 10. USER PROGRESS
-- =============================================================================

CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  skill_name TEXT NOT NULL CHECK (skill_name IN ('clarity', 'assertiveness', 'empathy', 'structure', 'confidence')),
  score NUMERIC(3,1) NOT NULL CHECK (score BETWEEN 1 AND 10),

  conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,

  recorded_at TIMESTAMPTZ DEFAULT NOW(),
  -- v3 FIX: original UNIQUE(user_id, skill_name, recorded_at) never deduped anything because
  -- recorded_at is a full timestamp (always unique to the microsecond). Use a generated DATE
  -- column so "one data point per skill per day" is actually enforced.
  recorded_date DATE GENERATED ALWAYS AS ((recorded_at AT TIME ZONE 'UTC')::date) STORED,

  UNIQUE(user_id, skill_name, recorded_date)
);

-- =============================================================================
-- 11. ACHIEVEMENTS
-- =============================================================================

CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,

  name TEXT NOT NULL,
  name_fr TEXT,
  description TEXT NOT NULL,
  description_fr TEXT,

  icon_url TEXT,
  icon_name TEXT,
  color_hex TEXT DEFAULT '#6366F1',

  unlock_condition TEXT NOT NULL,
  unlock_threshold INTEGER DEFAULT 1,

  points INTEGER DEFAULT 0,
  is_hidden BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 12. USER ACHIEVEMENTS
-- =============================================================================

CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,

  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  is_new BOOLEAN DEFAULT true,

  UNIQUE(user_id, achievement_id)
);

-- =============================================================================
-- 13. SUBSCRIPTIONS
-- =============================================================================

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  revenuecat_app_user_id TEXT,
  revenuecat_original_transaction_id TEXT,

  tier subscription_tier NOT NULL DEFAULT 'free',
  status subscription_status NOT NULL DEFAULT 'active',

  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  trial_ends_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,

  store TEXT CHECK (store IN ('app_store', 'play_store', 'stripe')),
  product_id TEXT,

  will_renew BOOLEAN DEFAULT true,
  is_in_grace_period BOOLEAN DEFAULT false,

  raw_revenuecat_data JSONB DEFAULT '{}',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, revenuecat_original_transaction_id)
);

-- =============================================================================
-- 14. NOTIFICATIONS
-- =============================================================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  type notification_type NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,

  action_route TEXT,
  action_params JSONB DEFAULT '{}',

  is_read BOOLEAN DEFAULT false,
  is_pushed BOOLEAN DEFAULT false,

  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 15. DAILY TIPS
-- =============================================================================

CREATE TABLE daily_tips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  content TEXT NOT NULL,
  content_fr TEXT,

  category TEXT,
  author TEXT DEFAULT 'Heather',

  active_from DATE,
  active_until DATE,
  sort_order INTEGER DEFAULT 0,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 16. USER ACTIVITY LOG
-- =============================================================================

CREATE TABLE user_activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  activity_type activity_type NOT NULL,
  activity_date DATE NOT NULL,

  metadata JSONB DEFAULT '{}',

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Profiles
CREATE INDEX idx_profiles_subscription ON profiles(subscription_tier);
CREATE INDEX idx_profiles_onboarding ON profiles(onboarding_completed);

-- Custom Personalities (NOUVEAU v2)
CREATE INDEX idx_custom_personalities_user ON custom_personalities(user_id);
CREATE INDEX idx_custom_personalities_favorite ON custom_personalities(user_id, is_favorite);

-- Scenarios
CREATE INDEX idx_scenarios_category ON scenarios(category_id);
CREATE INDEX idx_scenarios_difficulty ON scenarios(difficulty);
CREATE INDEX idx_scenarios_predefined ON scenarios(is_predefined) WHERE is_predefined = true;
CREATE INDEX idx_scenarios_active ON scenarios(is_active) WHERE is_active = true;
CREATE INDEX idx_scenarios_created_by ON scenarios(created_by);

-- User Scenario Customizations
CREATE INDEX idx_usc_user ON user_scenario_customizations(user_id);
CREATE INDEX idx_usc_scenario ON user_scenario_customizations(scenario_id);
CREATE INDEX idx_usc_favorite ON user_scenario_customizations(user_id, is_favorite) WHERE is_favorite = true;

-- Conversations
CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_scenario ON conversations(scenario_id);
CREATE INDEX idx_conversations_status ON conversations(status);
CREATE INDEX idx_conversations_user_status ON conversations(user_id, status);
CREATE INDEX idx_conversations_dates ON conversations(user_id, started_at DESC);
CREATE INDEX idx_conversations_livekit ON conversations(livekit_room_name);
CREATE INDEX idx_conversations_custom_personality ON conversations(custom_personality_id);

-- Messages
CREATE INDEX idx_messages_conversation ON conversation_messages(conversation_id);
CREATE INDEX idx_messages_sequence ON conversation_messages(conversation_id, sequence_number);
CREATE INDEX idx_messages_timestamp ON conversation_messages(conversation_id, timestamp_seconds);

-- Feedbacks
CREATE INDEX idx_feedbacks_user ON feedbacks(user_id);
CREATE INDEX idx_feedbacks_conversation ON feedbacks(conversation_id);
CREATE INDEX idx_feedbacks_user_read ON feedbacks(user_id, is_read);
CREATE INDEX idx_feedbacks_overall ON feedbacks(user_id, overall_score DESC);

-- User Progress
CREATE INDEX idx_progress_user_skill ON user_progress(user_id, skill_name);
CREATE INDEX idx_progress_user_date ON user_progress(user_id, recorded_at DESC);

-- Achievements
CREATE INDEX idx_achievements_condition ON achievements(unlock_condition);

-- User Achievements
CREATE INDEX idx_ua_user ON user_achievements(user_id);
CREATE INDEX idx_ua_new ON user_achievements(user_id, is_new) WHERE is_new = true;

-- Subscriptions
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_expires ON subscriptions(expires_at);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_scheduled ON notifications(scheduled_at) WHERE is_pushed = false;

-- Activity Logs
CREATE INDEX idx_activity_user_date ON user_activity_logs(user_id, activity_date DESC);
CREATE INDEX idx_activity_type ON user_activity_logs(activity_type);

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_personalities ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_scenario_customizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity_logs ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Service role full access" ON profiles
  FOR ALL USING (auth.role() = 'service_role');

-- SCENARIOS
CREATE POLICY "Anyone can view predefined active scenarios" ON scenarios
  FOR SELECT USING (is_predefined = true AND is_active = true);
CREATE POLICY "Users can view their own custom scenarios" ON scenarios
  FOR SELECT USING (created_by = auth.uid());
-- v3 FIX: is_public existed as a column but had no policy exposing it — community scenarios were unreachable
CREATE POLICY "Anyone can view public active custom scenarios" ON scenarios
  FOR SELECT USING (is_public = true AND is_active = true);
-- v3 FIX: custom scenario creation is a Pro feature; gate it at the DB layer, not just in the client
CREATE POLICY "Pro users can create custom scenarios" ON scenarios
  FOR INSERT WITH CHECK (
    created_by = auth.uid()
    AND is_predefined = false
    AND EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.subscription_tier <> 'free'
    )
  );
CREATE POLICY "Users can update own custom scenarios" ON scenarios
  FOR UPDATE USING (created_by = auth.uid()) WITH CHECK (created_by = auth.uid() AND is_predefined = false);
CREATE POLICY "Users can delete own custom scenarios" ON scenarios
  FOR DELETE USING (created_by = auth.uid());

-- CUSTOM PERSONALITIES (NOUVEAU v2)
CREATE POLICY "Users can view own personalities" ON custom_personalities
  FOR SELECT USING (user_id = auth.uid());
-- v3 FIX: custom personalities are a Pro feature; gate it at the DB layer too
CREATE POLICY "Pro users can create own personalities" ON custom_personalities
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.subscription_tier <> 'free'
    )
  );
CREATE POLICY "Users can update own personalities" ON custom_personalities
  FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete own personalities" ON custom_personalities
  FOR DELETE USING (user_id = auth.uid());

-- USER SCENARIO CUSTOMIZATIONS
CREATE POLICY "Users can view own customizations" ON user_scenario_customizations
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can manage own customizations" ON user_scenario_customizations
  FOR ALL USING (user_id = auth.uid());

-- CONVERSATIONS
CREATE POLICY "Users can view own conversations" ON conversations
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can create own conversations" ON conversations
  FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update own conversations" ON conversations
  FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete own conversations" ON conversations
  FOR DELETE USING (user_id = auth.uid());

-- CONVERSATION MESSAGES
CREATE POLICY "Users can view messages from own conversations" ON conversation_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversations c 
      WHERE c.id = conversation_messages.conversation_id 
      AND c.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can insert messages to own conversations" ON conversation_messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM conversations c 
      WHERE c.id = conversation_messages.conversation_id 
      AND c.user_id = auth.uid()
    )
  );

-- FEEDBACKS
-- v3 FIX: scores are the product's core trust signal. Clients must NEVER be able to write them directly
-- (the original policies let any authenticated user INSERT/UPDATE their own scores at will).
-- Only the backend (service_role, called from your Mastra evaluation pipeline / Edge Function) may write.
-- Users get a narrow SECURITY DEFINER RPC (mark_feedback_read below) for the one field they legitimately need to touch.
CREATE POLICY "Users can view own feedbacks" ON feedbacks
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Service role can insert feedbacks" ON feedbacks
  FOR INSERT WITH CHECK (auth.role() = 'service_role');
CREATE POLICY "Service role can update feedbacks" ON feedbacks
  FOR UPDATE USING (auth.role() = 'service_role');

-- USER PROGRESS
-- v3 FIX: same reasoning — progress scores must be written by the backend only, never spoofable by the client.
CREATE POLICY "Users can view own progress" ON user_progress
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Service role can insert progress" ON user_progress
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- ACHIEVEMENTS
CREATE POLICY "Anyone can view achievements" ON achievements
  FOR SELECT USING (true);

-- USER ACHIEVEMENTS
-- v3 FIX: unlocking an achievement must be a backend decision (based on real activity), not a free client INSERT.
-- Users only get to flip "is_new" to false once they've seen the unlock toast — via the RPC below.
CREATE POLICY "Users can view own achievements" ON user_achievements
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Service role can insert achievements" ON user_achievements
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- SUBSCRIPTIONS
CREATE POLICY "Users can view own subscriptions" ON subscriptions
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Service role can manage subscriptions" ON subscriptions
  FOR ALL USING (auth.role() = 'service_role');

-- NOTIFICATIONS
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete own notifications" ON notifications
  FOR DELETE USING (user_id = auth.uid());
CREATE POLICY "Service role can insert notifications" ON notifications
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- ACTIVITY LOGS
CREATE POLICY "Users can view own activity" ON user_activity_logs
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert own activity" ON user_activity_logs
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- DAILY TIPS
CREATE POLICY "Anyone can view active tips" ON daily_tips
  FOR SELECT USING (is_active = true);

-- ═══════════════════════════════════════════════════════════════════════════════
-- FUNCTIONS & TRIGGERS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_scenarios_updated_at
  BEFORE UPDATE ON scenarios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_custom_personalities_updated_at
  BEFORE UPDATE ON custom_personalities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_usc_updated_at
  BEFORE UPDATE ON user_scenario_customizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_conversations_updated_at
  BEFORE UPDATE ON conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-calculate conversation duration
CREATE OR REPLACE FUNCTION calculate_conversation_duration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.ended_at IS NOT NULL AND NEW.started_at IS NOT NULL THEN
    NEW.duration_seconds := EXTRACT(EPOCH FROM (NEW.ended_at - NEW.started_at))::INTEGER;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_duration
  BEFORE UPDATE ON conversations
  FOR EACH ROW WHEN (OLD.ended_at IS DISTINCT FROM NEW.ended_at)
  EXECUTE FUNCTION calculate_conversation_duration();

-- Auto-update profile stats after conversation
CREATE OR REPLACE FUNCTION update_profile_stats_after_conversation()
RETURNS TRIGGER AS $$
DECLARE
  v_total_conversations INTEGER;
  v_total_minutes INTEGER;
  v_avg_score NUMERIC;
BEGIN
  IF NEW.status = 'completed' THEN
    SELECT COUNT(*) INTO v_total_conversations
    FROM conversations WHERE user_id = NEW.user_id AND status = 'completed';

    SELECT COALESCE(SUM(duration_seconds), 0) / 60 INTO v_total_minutes
    FROM conversations WHERE user_id = NEW.user_id AND status = 'completed';

    SELECT COALESCE(AVG(overall_score), 0) INTO v_avg_score
    FROM feedbacks WHERE user_id = NEW.user_id;

    UPDATE profiles SET 
      total_conversations = v_total_conversations,
      total_training_minutes = v_total_minutes,
      overall_score = v_avg_score,
      updated_at = NOW()
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_profile_stats
  AFTER UPDATE ON conversations
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION update_profile_stats_after_conversation();

-- Auto-update scenario stats
CREATE OR REPLACE FUNCTION update_scenario_stats()
RETURNS TRIGGER AS $$
DECLARE
  v_completion_count INTEGER;
  v_avg_score NUMERIC;
BEGIN
  IF NEW.status = 'completed' THEN
    SELECT COUNT(*) INTO v_completion_count
    FROM conversations WHERE scenario_id = NEW.scenario_id AND status = 'completed';

    SELECT COALESCE(AVG(f.overall_score), 0) INTO v_avg_score
    FROM feedbacks f
    JOIN conversations c ON c.id = f.conversation_id
    WHERE c.scenario_id = NEW.scenario_id AND c.status = 'completed';

    UPDATE scenarios SET 
      completion_count = v_completion_count,
      average_score = v_avg_score,
      updated_at = NOW()
    WHERE id = NEW.scenario_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_scenario_stats
  AFTER UPDATE ON conversations
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION update_scenario_stats();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    first_name,
    last_name,
    avatar_url,
    email_notifications_enabled
  )
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'given_name',
      NEW.raw_user_meta_data->>'first_name',
      SPLIT_PART(NEW.email, '@', 1),
      'User'
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'family_name',
      NEW.raw_user_meta_data->>'last_name',
      ''
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'avatar_url',
      NEW.raw_user_meta_data->>'picture',
      NULL
    ),
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url),
    first_name = COALESCE(profiles.first_name, EXCLUDED.first_name);
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Streak calculation
CREATE OR REPLACE FUNCTION calculate_streak(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_current_streak INTEGER := 0;
  v_check_date DATE := CURRENT_DATE;
  v_has_activity BOOLEAN;
BEGIN
  LOOP
    SELECT EXISTS(
      SELECT 1 FROM user_activity_logs
      WHERE user_id = p_user_id AND activity_date = v_check_date
      AND activity_type = 'conversation_completed'
    ) INTO v_has_activity;

    IF v_has_activity THEN
      v_current_streak := v_current_streak + 1;
      v_check_date := v_check_date - INTERVAL '1 day';
    ELSE
      EXIT;
    END IF;
  END LOOP;
  RETURN v_current_streak;
END;
$$ LANGUAGE plpgsql;

-- Update streak after activity
CREATE OR REPLACE FUNCTION update_streak_after_activity()
RETURNS TRIGGER AS $$
DECLARE
  v_new_streak INTEGER;
BEGIN
  IF NEW.activity_type = 'conversation_completed' THEN
    v_new_streak := calculate_streak(NEW.user_id);
    UPDATE profiles SET 
      current_streak = v_new_streak,
      longest_streak = GREATEST(longest_streak, v_new_streak),
      updated_at = NOW()
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_streak
  AFTER INSERT ON user_activity_logs FOR EACH ROW EXECUTE FUNCTION update_streak_after_activity();

-- Level calculation
-- v3 FIX: return type changed from TEXT to user_level to match the (now-enum) profiles.level column.
CREATE OR REPLACE FUNCTION calculate_user_level(p_overall_score NUMERIC, p_total_conversations INTEGER)
RETURNS user_level AS $$
BEGIN
  IF p_total_conversations >= 50 AND p_overall_score >= 8.0 THEN RETURN 'Master';
  ELSIF p_total_conversations >= 30 AND p_overall_score >= 7.0 THEN RETURN 'Expert';
  ELSIF p_total_conversations >= 10 AND p_overall_score >= 6.0 THEN RETURN 'Confident';
  ELSIF p_total_conversations >= 3 THEN RETURN 'Apprentice';
  ELSE RETURN 'Novice';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_user_level()
RETURNS TRIGGER AS $$
BEGIN
  NEW.level := calculate_user_level(NEW.overall_score, NEW.total_conversations);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_level
  BEFORE UPDATE OF overall_score, total_conversations ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_user_level();

-- ═══════════════════════════════════════════════════════════════════════════════
-- SAFE CLIENT-FACING RPCs (v3 NEW)
-- Narrow SECURITY DEFINER functions so the client can flip exactly one boolean
-- it legitimately owns, without ever getting write access to scores/unlocks.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION mark_feedback_read(p_feedback_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE feedbacks
  SET is_read = true
  WHERE id = p_feedback_id AND user_id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION mark_feedback_read(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION mark_feedback_read(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION mark_achievement_seen(p_user_achievement_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE user_achievements
  SET is_new = false
  WHERE id = p_user_achievement_id AND user_id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION mark_achievement_seen(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION mark_achievement_seen(UUID) TO authenticated;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SEED DATA
-- ═══════════════════════════════════════════════════════════════════════════════

-- Categories
INSERT INTO scenario_categories (slug, name, name_fr, description, description_fr, icon_name, sort_order) VALUES
  ('feedback', 'Feedback', 'Feedback', 'Giving and receiving constructive feedback', 'Donner et recevoir du feedback constructif', 'message-circle', 1),
  ('boundaries', 'Boundaries', 'Limites', 'Setting and maintaining professional boundaries', 'Etablir et maintenir des limites professionnelles', 'shield', 2),
  ('saying_no', 'Saying No', 'Dire Non', 'Declining requests and managing expectations', 'Refuser des demandes et gerer les attentes', 'x-circle', 3),
  ('conflict', 'Conflict Resolution', 'Resolution de Conflits', 'Managing interpersonal conflicts at work', 'Gerer les conflits interpersonnels au travail', 'alert-triangle', 4),
  ('change', 'Managing Change', 'Gerer le Changement', 'Announcing and navigating organizational changes', 'Annoncer et naviguer les changements organisationnels', 'refresh-cw', 5),
  ('negotiation', 'Negotiation', 'Negociation', 'Negotiating salary, resources, and terms', 'Negocier salaire, ressources et conditions', 'trending-up', 6);

-- Scenarios
INSERT INTO scenarios (
  category_id, slug, title, title_fr, description, description_fr, 
  context, context_fr, user_goal, user_goal_fr,
  interlocutor_name, interlocutor_role, interlocutor_personality, interlocutor_traits,
  difficulty, estimated_duration_minutes, skills_practiced, points_reward
) VALUES
(
  (SELECT id FROM scenario_categories WHERE slug = 'feedback'),
  'negative-feedback-peer', 'Giving Negative Feedback to a Former Peer', 'Donner un feedback negatif a un ancien collegue',
  'You were recently promoted and now manage your former teammate who is consistently missing deadlines.',
  'Vous avez ete recemment promu et managez desormais votre ancien collegue qui manque regulierement ses deadlines.',
  'You need to address declining performance without damaging the relationship you built as peers.',
  'Vous devez aborder la baisse de performance sans abimer la relation que vous avez construite en tant que pairs.',
  'Deliver clear, constructive feedback while maintaining trust and setting clear expectations.',
  'Donner un feedback clair et constructif tout en maintenant la confiance et en fixant des attentes claires.',
  'Jordan', 'Senior Developer', 'defensive', ARRAY['prideful', 'detail-oriented', 'sensitive to criticism'],
  'intermediate', 5, ARRAY['clarity', 'empathy', 'assertiveness'], 15
),
(
  (SELECT id FROM scenario_categories WHERE slug = 'boundaries'),
  'scope-creep-manager', 'Pushing Back on Scope Creep', 'Refuser un depassement de perimetre',
  'Your manager keeps adding tasks to your plate without adjusting deadlines or resources.',
  'Votre manager continue d''ajouter des taches sans ajuster les deadlines ou les ressources.',
  'You need to protect your team capacity while maintaining a positive relationship with your manager.',
  'Vous devez proteger la capacite de votre equipe tout en maintenant une relation positive avec votre manager.',
  'Firmly but respectfully push back on unrealistic expectations and propose alternatives.',
  'Refuser fermement mais respectueusement des attentes irrealistes et proposer des alternatives.',
  'Sarah', 'Director of Engineering', 'dominant', ARRAY['ambitious', 'results-driven', 'impatient'],
  'advanced', 7, ARRAY['assertiveness', 'structure', 'confidence'], 20
),
(
  (SELECT id FROM scenario_categories WHERE slug = 'saying_no'),
  'decline-extra-project', 'Declining an Additional Project', 'Refuser un projet supplementaire',
  'You are at full capacity but a senior leader asks you to take on a high-visibility project.',
  'Vous etes a pleine capacite mais un leader senior vous demande de prendre un projet tres visible.',
  'You need to say no without burning bridges or appearing uncommitted.',
  'Vous devez dire non sans bruler les ponts ni paraitre peu investi.',
  'Decline gracefully while offering alternatives and demonstrating your current value.',
  'Refuser avec elegance tout en offrant des alternatives et en demontrant votre valeur actuelle.',
  'Michael', 'VP of Product', 'collaborative', ARRAY['understanding', 'strategic', 'respectful of boundaries'],
  'beginner', 4, ARRAY['assertiveness', 'clarity', 'empathy'], 10
),
(
  (SELECT id FROM scenario_categories WHERE slug = 'conflict'),
  'team-conflict-mediation', 'Mediating a Team Conflict', 'Medier un conflit d''equipe',
  'Two of your direct reports are in open conflict, affecting team morale and productivity.',
  'Deux de vos collaborateurs directs sont en conflit ouvert, affectant le moral et la productivite.',
  'You need to address the conflict directly, hear both sides, and facilitate a resolution.',
  'Vous devez aborder le conflit directement, entendre les deux cotes et faciliter une resolution.',
  'Facilitate a constructive conversation that leads to mutual understanding and actionable next steps.',
  'Faciliter une conversation constructive menant a une comprehension mutuelle et des prochaines etapes actionnables.',
  'Alex', 'Team Lead', 'emotional', ARRAY['passionate', 'opinionated', 'defensive'],
  'advanced', 8, ARRAY['empathy', 'structure', 'confidence'], 25
),
(
  (SELECT id FROM scenario_categories WHERE slug = 'change'),
  'announce-restructuring', 'Announcing a Team Restructuring', 'Annoncer une restructuration d''equipe',
  'Leadership has decided to restructure your team. You need to communicate this to your reports.',
  'La direction a decide de restructurer votre equipe. Vous devez communiquer cela a vos collaborateurs.',
  'Your team will be anxious and may push back. You need to be transparent while maintaining morale.',
  'Votre equipe sera anxieuse et pourrait resister. Vous devez etre transparent tout en maintenant le moral.',
  'Communicate the change clearly, address concerns empathetically, and outline the path forward.',
  'Communiquer le changement clairement, aborder les preoccupations avec empathie et decrire la voie a suivre.',
  'The Team', 'Direct Reports', 'passive_aggressive', ARRAY['anxious', 'skeptical', 'loyal but worried'],
  'intermediate', 6, ARRAY['clarity', 'empathy', 'structure'], 18
),
(
  (SELECT id FROM scenario_categories WHERE slug = 'negotiation'),
  'negotiate-salary', 'Negotiating a Salary Raise', 'Negocier une augmentation',
  'You believe you are underpaid compared to market rates and want to discuss a raise with your manager.',
  'Vous pensez etre sous-paye par rapport au marche et voulez discuter d''une augmentation avec votre manager.',
  'You need to make a compelling case without appearing entitled or threatening to leave.',
  'Vous devez presenter un argument convaincant sans paraitre pretentieux ou menacer de partir.',
  'Present your case with data, demonstrate your value, and negotiate confidently.',
  'Presenter votre cas avec des donnees, demontrer votre valeur et negocier avec confiance.',
  'David', 'Engineering Manager', 'evasive', ARRAY['budget-conscious', 'risk-averse', 'appreciates data'],
  'intermediate', 6, ARRAY['assertiveness', 'structure', 'confidence'], 18
);

-- Achievements
INSERT INTO achievements (slug, name, name_fr, description, description_fr, icon_name, color_hex, unlock_condition, unlock_threshold, points) VALUES
  ('first_conversation', 'First Step', 'Premier Pas', 'Complete your first conversation', 'Terminez votre premiere conversation', 'footprints', '#10B981', 'first_conversation', 1, 10),
  ('streak_7', 'On Fire', 'En Feu', 'Practice 7 days in a row', 'Pratiquez 7 jours de suite', 'flame', '#F59E0B', 'streak_7', 7, 50),
  ('streak_30', 'Unstoppable', 'Inarretable', 'Practice 30 days in a row', 'Pratiquez 30 jours de suite', 'zap', '#EF4444', 'streak_30', 30, 200),
  ('score_clarity_8', 'Crystal Clear', 'Clair comme du Cristal', 'Achieve a clarity score of 8 or higher', 'Atteignez un score de clarte de 8 ou plus', 'eye', '#3B82F6', 'score_clarity_8', 8, 25),
  ('score_assertiveness_8', 'Assertive Leader', 'Leader Assertif', 'Achieve an assertiveness score of 8 or higher', 'Atteignez un score d''assertivite de 8 ou plus', 'shield-check', '#8B5CF6', 'score_assertiveness_8', 8, 25),
  ('score_empathy_8', 'Empathy Master', 'Maitre de l''Empathie', 'Achieve an empathy score of 8 or higher', 'Atteignez un score d''empathie de 8 ou plus', 'heart', '#EC4899', 'score_empathy_8', 8, 25),
  ('score_overall_9', 'Perfect Score', 'Score Parfait', 'Achieve an overall score of 9 or higher', 'Atteignez un score global de 9 ou plus', 'star', '#FBBF24', 'score_overall_9', 9, 100),
  ('ten_conversations', 'Dedicated', 'Devoue', 'Complete 10 conversations', 'Terminez 10 conversations', 'award', '#6366F1', 'conversation_count', 10, 30),
  ('fifty_conversations', 'Veteran', 'Veteran', 'Complete 50 conversations', 'Terminez 50 conversations', 'crown', '#7C3AED', 'conversation_count', 50, 150),
  ('retry_master', 'Persistent', 'Perseverant', 'Retry the same scenario 5 times', 'Reessayez le meme scenario 5 fois', 'repeat', '#14B8A6', 'retry_same_scenario', 5, 40),
  ('all_categories', 'Well-Rounded', 'Polyvalent', 'Complete a scenario in every category', 'Terminez un scenario dans chaque categorie', 'grid', '#0EA5E9', 'all_categories', 6, 75),
  ('night_owl', 'Night Owl', 'Couche-tard', 'Practice after 10 PM', 'Pratiquez apres 22h', 'moon', '#4F46E5', 'night_practice', 1, 15);

-- Daily Tips
INSERT INTO daily_tips (content, content_fr, category, sort_order) VALUES
  ('The best feedback is specific, timely, and focused on behavior, not personality.', 'Le meilleur feedback est specifique, opportun et centre sur le comportement, pas la personnalite.', 'feedback', 1),
  ('Saying no is not selfish—it is a necessary boundary that protects your capacity to deliver quality work.', 'Dire non n''est pas egoiste — c''est une limite necessaire qui protege votre capacite a livrer un travail de qualite.', 'boundaries', 2),
  ('Before a difficult conversation, write down your three key points. Clarity comes from preparation.', 'Avant une conversation difficile, notez vos trois points cles. La clarte vient de la preparation.', 'communication', 3),
  ('Empathy does not mean agreement. You can understand someone''s perspective while holding your ground.', 'L''empathie ne signifie pas l''accord. Vous pouvez comprendre le point de vue de quelqu''un tout en tenant bon.', 'empathy', 4),
  ('When giving negative feedback, start with what you value about the person before addressing the issue.', 'Quand vous donnez un feedback negatif, commencez par ce que vous appreciez chez la personne avant d''aborder le probleme.', 'feedback', 5),
  ('Your tone matters more than your words. A calm, steady voice signals confidence and control.', 'Votre ton compte plus que vos mots. Une voix calme et stable signale la confiance et le controle.', 'communication', 6),
  ('If you feel yourself getting emotional, pause. A 3-second silence is more powerful than a reactive response.', 'Si vous sentez que vous devenez emotionnel, faites une pause. Un silence de 3 secondes est plus puissant qu''une reaction impulsive.', 'emotional_intelligence', 7),
  ('The most effective leaders do not avoid conflict—they address it early, directly, and with respect.', 'Les leaders les plus efficaces n''evitent pas le conflit — ils l''abordent tot, directement et avec respect.', 'conflict', 8),
  ('When negotiating, always have a BATNA (Best Alternative to a Negotiated Agreement) in mind.', 'En negociation, ayez toujours une BATNA (Meilleure Alternative a un Accord Negocie) en tete.', 'negotiation', 9),
  ('Boundaries are not walls—they are gates. They let the right things in and keep the wrong things out.', 'Les limites ne sont pas des murs — ce sont des portes. Elles laissent entrer ce qui est bon et gardent dehors ce qui ne l''est pas.', 'boundaries', 10);

-- ═══════════════════════════════════════════════════════════════════════════════
-- VIEWS
-- v3 FIX: Postgres views run with the *owner's* privileges by default, which can
-- silently bypass the RLS you just spent 40 policies building. security_invoker
-- forces the view to run as the querying role, so RLS on the underlying tables
-- (conversations, feedbacks, scenarios, custom_personalities) is actually enforced.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE VIEW v_conversations_full
WITH (security_invoker = true) AS
SELECT 
  c.id, c.user_id, c.scenario_id, c.custom_personality_id,
  c.status, c.started_at, c.ended_at, c.duration_seconds, c.mode,
  s.title AS scenario_title, s.difficulty, s.category_id, sc.name AS category_name,
  cp.name AS custom_personality_name,
  f.overall_score, f.is_read AS feedback_read
FROM conversations c
LEFT JOIN scenarios s ON s.id = c.scenario_id
LEFT JOIN scenario_categories sc ON sc.id = s.category_id
LEFT JOIN custom_personalities cp ON cp.id = c.custom_personality_id
LEFT JOIN feedbacks f ON f.conversation_id = c.id;

REVOKE ALL ON v_conversations_full FROM PUBLIC;
GRANT SELECT ON v_conversations_full TO authenticated;

-- v3 FIX: the leaderboard is deliberately public across users, which "profiles" RLS
-- (own-row-only) does not allow. Rather than relying on a security-definer *view*
-- (which would silently re-expose every column of profiles, including anything
-- added to that table later), expose only the few safe columns via a
-- SECURITY DEFINER function with an explicit, reviewable column list.
-- v3 FIX: level was declared INT here but profiles.level is TEXT/now user_level ENUM —
-- this mismatch would have raised "structure of query does not match function result type"
-- the first time the function ran. Now correctly typed as user_level.
CREATE OR REPLACE FUNCTION get_leaderboard(p_limit INT DEFAULT 50)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  level user_level,
  total_conversations INT,
  overall_score NUMERIC,
  current_streak INT,
  rank BIGINT
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT
    p.id AS user_id, p.first_name, p.level,
    p.total_conversations, p.overall_score, p.current_streak,
    RANK() OVER (ORDER BY p.overall_score DESC, p.total_conversations DESC) AS rank
  FROM profiles p
  WHERE p.total_conversations > 0
  ORDER BY p.overall_score DESC, p.total_conversations DESC
  LIMIT p_limit;
$$;

REVOKE ALL ON FUNCTION get_leaderboard(INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_leaderboard(INT) TO authenticated;

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF SCHEMA v3.0 — production-hardening pass (RLS write-locks, apostrophe
-- escaping in seed data, view security_invoker, Pro-tier gating, safe RPCs)
-- ═══════════════════════════════════════════════════════════════════════════════
-- ============================================================
-- FashionTrend AI — Supabase SQL Schema
-- Run this in your Supabase SQL editor (supabase.com/dashboard)
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT,
  email TEXT,
  avatar_url TEXT,
  age INTEGER,
  gender TEXT CHECK (gender IN ('Male', 'Female', 'Non-binary', 'Prefer not to say')),
  height_cm INTEGER,
  weight_kg INTEGER,
  skin_tone TEXT,
  body_type TEXT,
  fashion_style TEXT,
  favorite_colors TEXT[],
  budget_range TEXT,
  style_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- AI ANALYSES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_analyses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT,
  face_shape TEXT,
  skin_tone TEXT,
  body_type TEXT,
  hair_texture TEXT,
  outfit_colors TEXT[],
  style_score INTEGER,
  analysis_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RECOMMENDATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.recommendations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  analysis_id UUID REFERENCES public.ai_analyses(id) ON DELETE SET NULL,
  type TEXT CHECK (type IN ('outfit', 'shoe', 'watch', 'perfume', 'hairstyle', 'accessory')),
  title TEXT NOT NULL,
  description TEXT,
  items TEXT[],
  occasion TEXT,
  season TEXT,
  score INTEGER,
  tags TEXT[],
  metadata JSONB,
  is_saved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CLOSET ITEMS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.closet_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT CHECK (category IN ('Tops', 'Bottoms', 'Shoes', 'Accessories', 'Outerwear', 'Dress', 'Other')),
  color TEXT,
  brand TEXT,
  image_url TEXT,
  tags TEXT[],
  times_worn INTEGER DEFAULT 0,
  last_worn TIMESTAMPTZ,
  is_favourite BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SAVED LOOKS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.saved_looks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recommendation_id UUID REFERENCES public.recommendations(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  occasion TEXT,
  score INTEGER,
  items TEXT[],
  image_url TEXT,
  notes TEXT,
  is_shared BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CHAT MESSAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role TEXT CHECK (role IN ('user', 'assistant')) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT CHECK (type IN ('style_tip', 'weather', 'trend', 'reminder', 'system')),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.closet_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_looks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- AI Analyses policies
CREATE POLICY "Users can view own analyses" ON public.ai_analyses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own analyses" ON public.ai_analyses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own analyses" ON public.ai_analyses
  FOR DELETE USING (auth.uid() = user_id);

-- Recommendations policies
CREATE POLICY "Users can view own recommendations" ON public.recommendations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recommendations" ON public.recommendations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recommendations" ON public.recommendations
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recommendations" ON public.recommendations
  FOR DELETE USING (auth.uid() = user_id);

-- Closet items policies
CREATE POLICY "Users can view own closet" ON public.closet_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own closet items" ON public.closet_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own closet items" ON public.closet_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own closet items" ON public.closet_items
  FOR DELETE USING (auth.uid() = user_id);

-- Saved looks policies
CREATE POLICY "Users can view own saved looks" ON public.saved_looks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own saved looks" ON public.saved_looks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own saved looks" ON public.saved_looks
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own saved looks" ON public.saved_looks
  FOR DELETE USING (auth.uid() = user_id);

-- Chat messages policies
CREATE POLICY "Users can view own chat messages" ON public.chat_messages
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages" ON public.chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- STORAGE BUCKETS
-- Run these in Supabase Dashboard → Storage → Create bucket
-- OR use the Supabase CLI
-- ============================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('analysis-images', 'analysis-images', false) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('closet-images', 'closet-images', false) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('saved-looks', 'saved-looks', false) ON CONFLICT DO NOTHING;

-- Storage policies for avatars (public)
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Storage policies for private buckets
CREATE POLICY "Users can access own analysis images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'analysis-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can upload own analysis images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'analysis-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can access own closet images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'closet-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can upload own closet images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'closet-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_analyses_user_id ON public.ai_analyses(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_user_id ON public.recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_closet_items_user_id ON public.closet_items(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_looks_user_id ON public.saved_looks(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON public.chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE 'FashionTrend AI database setup complete! ✅';
  RAISE NOTICE 'Tables created: profiles, ai_analyses, recommendations, closet_items, saved_looks, chat_messages, notifications';
  RAISE NOTICE 'RLS enabled on all tables';
  RAISE NOTICE 'Storage buckets configured';
END $$;

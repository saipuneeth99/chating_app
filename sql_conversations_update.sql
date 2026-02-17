-- Add missing RLS policy to allow updating conversations
DROP POLICY IF EXISTS "Users can update conversations" ON conversations;

CREATE POLICY "Users can update conversations"
ON conversations FOR UPDATE USING (true);

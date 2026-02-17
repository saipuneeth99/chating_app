-- FIXED: Allow users to see all participants in conversations they're part of
DROP POLICY IF EXISTS "Users can view participants of their conversations" ON conversation_participants;

CREATE POLICY "Users can view participants of their conversations"
ON conversation_participants
FOR SELECT USING (
  conversation_id IN (
    SELECT conversation_id 
    FROM conversation_participants 
    WHERE user_id = auth.uid()
  )
);

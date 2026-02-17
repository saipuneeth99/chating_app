-- Step 1: Drop the restrictive policy
DROP POLICY IF EXISTS "Users can view participants of their conversations" ON conversation_participants;

-- Step 2: Create the fixed policy that allows viewing all participants in their conversations
CREATE POLICY "Users can view participants of their conversations"
ON conversation_participants
FOR SELECT USING (
  conversation_id IN (
    SELECT conversation_id 
    FROM conversation_participants 
    WHERE user_id = auth.uid()
  )
);

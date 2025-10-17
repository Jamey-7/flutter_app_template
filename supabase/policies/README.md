# Supabase Row-Level Security (RLS) Policies

This document outlines the required RLS policies for the application.

## Overview

Row-Level Security (RLS) ensures that users can only access data they're authorized to see. All tables should have RLS enabled and appropriate policies configured.

## Required Policies

### Subscription Tables

**Policy**: Users can only view their own subscription data.

```sql
-- Enable RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions"
ON subscriptions FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Service role can manage all subscriptions (for webhooks)
CREATE POLICY "Service role can manage subscriptions"
ON subscriptions FOR ALL
USING (auth.role() = 'service_role');
```

### Shared Resources

**Policy**: Content may be publicly readable but only modifiable by owner.

```sql
-- Example for a shared content table
ALTER TABLE content ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view published content
CREATE POLICY "Anyone can view published content"
ON content FOR SELECT
USING (is_published = true);

-- Policy: Users can view their own content
CREATE POLICY "Users can view own content"
ON content FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can manage their own content
CREATE POLICY "Users can manage own content"
ON content FOR ALL
USING (auth.uid() = user_id);
```

## Testing RLS Policies

Always test your RLS policies to ensure they work as expected:

```sql
-- Test as a specific user
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'user-id-here';

-- Run your query to verify access
SELECT * FROM subscriptions;

-- Reset
RESET ROLE;
```

## Common Patterns

### auth.uid()
- Returns the ID of the currently authenticated user
- Use this to restrict access to user's own data

### auth.role()
- Returns the role of the current user
- Common roles: `anon`, `authenticated`, `service_role`

### Best Practices
1. Always enable RLS on tables containing user data
2. Start with restrictive policies and expand as needed
3. Test policies thoroughly before deploying
4. Document any custom policies here
5. Use `service_role` carefully - it bypasses RLS

## Migration Workflow

```bash
# Start local Supabase
supabase start

# Reset database (applies all migrations)
supabase db reset

# Create new migration
supabase migration new migration_name

# Push changes to remote
supabase db push
```

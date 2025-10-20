# RevenueCat Setup Guide

Complete guide for setting up RevenueCat subscriptions across all supported platforms.

---

## 🧪 Development Testing Mode (Start Here!)

Before setting up RevenueCat, you can **test your paywall UI immediately** using built-in test mode:

### Quick Start

1. In your `.env` file, enable test mode:
   ```env
   SUBSCRIPTION_TEST_MODE=true
   ```

2. Hot restart your app:
   ```bash
   flutter run
   ```

3. Navigate to the paywall screen - you'll see:
   - ✅ Mock subscription products ($2.99/month, $9.99/year)
   - ✅ "TEST MODE" badge in the app bar
   - ✅ Instant paywall loading (no network calls)
   - ✅ Functional "Subscribe" buttons for UI testing

### What Test Mode Does

- **Bypasses RevenueCat entirely** - No API keys needed
- **Shows mock products** - $2.99/month and $9.99/year subscriptions
- **Simulates purchases** - "Buy" buttons work and show success dialogs
- **Perfect for development** - Design your paywall without backend setup

### When to Use Test Mode

✅ **Use test mode when:**
- Designing and testing your paywall UI
- Working on app features without RevenueCat setup
- Creating app templates for reuse
- Developing on multiple machines without sharing keys

❌ **Disable test mode for:**
- Production builds (will error if enabled!)
- Testing real payment flows
- Testing subscription renewals/cancellations
- Integration with actual App Store/Play Store

### Disable Test Mode

When ready for production RevenueCat setup:

```env
SUBSCRIPTION_TEST_MODE=false
```

**⚠️ Important:** Release builds will **throw an error** if test mode is accidentally enabled, preventing you from shipping mock subscriptions to production users.

---

## 📋 Overview

**RevenueCat** is a subscription infrastructure that simplifies in-app purchases and subscriptions across platforms.

### Platform Support

- ✅ **iOS** - Full support
- ✅ **Android** - Full support
- ✅ **macOS** - Full support (uses iOS SDK)
- ❌ **Web** - Not supported (template uses free tier fallback)
- ❌ **Windows** - Not supported (template uses free tier fallback)
- ❌ **Linux** - Not supported (template uses free tier fallback)

### Why RevenueCat?

- **Cross-platform** - One SDK for iOS, Android, macOS
- **Server-side receipt validation** - Secure
- **Subscription analytics** - Built-in dashboard
- **A/B testing** - Test different pricing
- **Webhooks** - Real-time subscription events
- **Customer support** - Built-in tools

---

## 1️⃣ Create RevenueCat Account

1. Go to [RevenueCat](https://www.revenuecat.com/)
2. Sign up for free account
3. Create a new project
4. Choose a project name

**Pricing:**
- Free tier: Up to $10k monthly tracked revenue
- Paid tiers: Scale with your revenue

---

## 2️⃣ Get API Keys

### Platform-Specific Public SDK Keys

**You need SEPARATE API keys for iOS and Android platforms.**

1. In RevenueCat dashboard, go to **Project Settings** → **API Keys**
2. Under **App specific keys**, you'll see separate keys for each app:
   - **iOS/macOS app**: Key starts with `appl_`
   - **Android app**: Key starts with `goog_`
3. Copy both keys and add to your `.env` file:
   ```env
   REVENUECAT_IOS_API_KEY=appl_xxxxxxxxxx
   REVENUECAT_ANDROID_API_KEY=goog_xxxxxxxxxx
   ```

**Important:**
- Use the **public** SDK keys (safe to include in app)
- Never use the secret API key in your app
- iOS and macOS use the **same** `appl_` key
- Each platform needs its own key for proper product/subscription handling

---

## 3️⃣ iOS / macOS Setup

### Prerequisites

- Apple Developer Account ($99/year)
- App created in App Store Connect
- Paid Apps Agreement signed

### Step 1: Create App in RevenueCat

1. In RevenueCat dashboard, click **Projects** → **Your Project**
2. Click **Apps** → **+ New**
3. Select **Apple App Store**
4. Enter your **Bundle ID** (e.g., `com.yourcompany.yourapp`)
5. Enter **App Name**
6. Click **Create**

### Step 2: Connect App Store Connect

RevenueCat needs access to App Store Connect to validate receipts and sync subscriptions.

**Option A: App Store Connect API Key (Recommended)**

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys** (under Integrations)
3. Click **+** to generate a new key
4. Give it a name (e.g., "RevenueCat")
5. Select **Access**: App Manager or Admin
6. Click **Generate**
7. Download the `.p8` file (you can only download once!)
8. Note the **Key ID** and **Issuer ID**

9. In RevenueCat dashboard:
   - Go to your iOS app settings
   - Click **App Store Connect API**
   - Upload the `.p8` file
   - Enter **Key ID**
   - Enter **Issuer ID**
   - Click **Save**

**Option B: Shared Secret (Legacy)**

1. In App Store Connect, go to **My Apps** → **Your App**
2. Click **App Information**
3. Scroll to **App-Specific Shared Secret**
4. Click **Generate** (or use Master Shared Secret)
5. Copy the secret
6. In RevenueCat dashboard, paste it in **Shared Secret** field

**Recommendation:** Use App Store Connect API Key (Option A) for better security and features.

### Step 3: Create Subscription Products in App Store Connect

1. In App Store Connect, go to **My Apps** → **Your App**
2. Click **Subscriptions** (or **In-App Purchases** for non-subscriptions)
3. Click **+** to create a new subscription group
4. Name it (e.g., "Premium Subscriptions")
5. Click **Create**

6. Add subscription products:
   - Click **+** to add a subscription
   - **Reference Name**: Internal name (e.g., "Monthly Premium")
   - **Product ID**: Unique identifier (e.g., `monthly_premium`)
     - Use format: `{app}_{duration}_{tier}` (e.g., `myapp_monthly_premium`)
   - **Subscription Duration**: Monthly, Yearly, etc.
   - **Price**: Set your price
   - **Localization**: Add title and description for each language
   - Click **Save**

7. Repeat for each subscription tier (e.g., monthly, yearly)

**Common Product IDs:**
- `myapp_monthly_premium` - Monthly subscription
- `myapp_yearly_premium` - Yearly subscription
- `myapp_lifetime_premium` - Lifetime purchase (non-renewing)

### Step 4: Configure Products in RevenueCat

1. In RevenueCat dashboard, go to **Products**
2. Click **+ New**
3. Select your iOS app
4. Enter **Product ID** (must match App Store Connect exactly)
5. Enter **Display Name** (shown in your app)
6. Select **Type**: Subscription or Non-subscription
7. Select **Duration**: Monthly, Yearly, etc.
8. Click **Save**

9. Repeat for all products

### Step 5: Create Entitlements

Entitlements represent access levels in your app.

1. In RevenueCat dashboard, go to **Entitlements**
2. Click **+ New**
3. Enter **Identifier**: `premium` (matches your `.env` file)
4. Enter **Display Name**: "Premium Access"
5. Click **Save**

6. Link products to entitlement:
   - Click on the `premium` entitlement
   - Click **Attach Products**
   - Select all premium products (monthly, yearly, etc.)
   - Click **Attach**

**Result:** Any user with an active subscription to any of these products will have the `premium` entitlement.

### Step 6: Create Offerings

Offerings group products for display in your paywall.

1. In RevenueCat dashboard, go to **Offerings**
2. Click **+ New**
3. Enter **Identifier**: `default` (or custom name)
4. Enter **Display Name**: "Default Offering"
5. Click **Save**

6. Add packages to offering:
   - Click **+ Add Package**
   - Select **Package Type**: Monthly, Annual, etc.
   - Select **Product**: Choose the product
   - Set as **Default** (optional)
   - Click **Add**

7. Repeat for all packages

**Package Types:**
- `$rc_monthly` - Monthly subscription
- `$rc_annual` - Annual subscription
- `$rc_lifetime` - Lifetime purchase
- Custom - Any custom identifier

8. Set as **Current Offering** (click the star icon)

### Step 7: Test with Sandbox Account

1. Create a sandbox tester in App Store Connect:
   - Go to **Users and Access** → **Sandbox Testers**
   - Click **+**
   - Fill in details (use a fake email)
   - Click **Create**

2. On your iOS device:
   - Settings → App Store → Sandbox Account
   - Sign in with sandbox tester credentials

3. Run your app and test subscription flow

**Sandbox Testing Notes:**
- Subscriptions renew much faster (e.g., 1 month = 5 minutes)
- You can purchase unlimited times
- Receipts are validated against sandbox environment

---

## 4️⃣ Android Setup

### Prerequisites

- Google Play Console account ($25 one-time fee)
- App created in Google Play Console
- Closed testing track set up (required for testing subscriptions)

### Step 1: Create App in RevenueCat

1. In RevenueCat dashboard, click **Projects** → **Your Project**
2. Click **Apps** → **+ New**
3. Select **Google Play Store**
4. Enter your **Package Name** (e.g., `com.yourcompany.yourapp`)
5. Enter **App Name**
6. Click **Create**

### Step 2: Connect Google Play Console

RevenueCat needs access to Google Play to validate purchases.

**Create Service Account:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select existing)
3. Enable **Google Play Android Developer API**:
   - Go to **APIs & Services** → **Library**
   - Search for "Google Play Android Developer API"
   - Click **Enable**

4. Create Service Account:
   - Go to **IAM & Admin** → **Service Accounts**
   - Click **+ Create Service Account**
   - Name: "RevenueCat"
   - Click **Create and Continue**
   - Skip optional steps
   - Click **Done**

5. Create Key:
   - Click on the service account you just created
   - Go to **Keys** tab
   - Click **Add Key** → **Create new key**
   - Select **JSON**
   - Click **Create**
   - Save the JSON file

6. Grant Access in Google Play Console:
   - Go to [Google Play Console](https://play.google.com/console/)
   - Go to **Users and Permissions**
   - Click **Invite new users**
   - Enter the service account email (from step 4)
   - Grant **Financial data** permission (required for subscriptions)
   - Grant **View app information and download bulk reports** permission
   - Click **Invite user**
   - Accept the invitation (check the service account email)

7. Upload to RevenueCat:
   - In RevenueCat dashboard, go to your Android app settings
   - Click **Service Account Credentials**
   - Upload the JSON file
   - Click **Save**

### Step 3: Create Subscription Products in Google Play Console

1. In Google Play Console, go to **Your App** → **Monetize** → **Subscriptions**
2. Click **Create subscription**
3. Fill in details:
   - **Product ID**: Unique identifier (e.g., `monthly_premium`)
     - Use format: `{duration}_{tier}` (e.g., `monthly_premium`)
   - **Name**: Display name (e.g., "Monthly Premium")
   - **Description**: What users get
   - **Billing period**: Monthly, Yearly, etc.
   - **Price**: Set your price
   - **Free trial**: Optional (e.g., 7 days)
   - **Grace period**: Optional (e.g., 3 days)
4. Click **Save**

5. Repeat for each subscription tier

**Common Product IDs:**
- `monthly_premium` - Monthly subscription
- `yearly_premium` - Yearly subscription
- `lifetime_premium` - One-time purchase (use "In-app products" instead)

**Important:** Activate the subscription by clicking **Activate** after creation.

### Step 4: Configure Products in RevenueCat

1. In RevenueCat dashboard, go to **Products**
2. Click **+ New**
3. Select your Android app
4. Enter **Product ID** (must match Google Play Console exactly)
5. Enter **Display Name**
6. Select **Type**: Subscription
7. Select **Duration**: Monthly, Yearly, etc.
8. Click **Save**

9. Repeat for all products

### Step 5: Link to Entitlements & Offerings

Follow the same steps as iOS (Step 5 & 6 above):
- Link products to `premium` entitlement
- Add products to `default` offering

### Step 6: Test with Test Account

**Important:** You must publish your app to a closed testing track to test subscriptions.

1. Create a closed testing track:
   - In Google Play Console, go to **Testing** → **Closed testing**
   - Click **Create new release**
   - Upload your app bundle (.aab)
   - Add release notes
   - Click **Save** and **Review release**
   - Click **Start rollout to Closed testing**

2. Add test users:
   - Go to **Testing** → **Closed testing**
   - Click **Testers** tab
   - Add email addresses of testers
   - Click **Save changes**

3. Share opt-in link with testers:
   - Copy the opt-in URL
   - Testers must visit this URL and opt in
   - Then download the app from Play Store

4. Test subscription flow in the app

**Testing Notes:**
- Test purchases are free (no actual charge)
- Subscriptions renew faster (e.g., 1 month = 5 minutes)
- Use license testing accounts for unlimited testing

---

## 5️⃣ Entitlements Configuration

### What are Entitlements?

Entitlements represent **what users have access to** in your app, regardless of which product they purchased.

**Example:**
- Products: `monthly_premium`, `yearly_premium`, `lifetime_premium`
- Entitlement: `premium`
- Result: All three products grant the same `premium` access

### Default Entitlement

The template uses `premium` as the default entitlement identifier.

**File:** `.env`
```
REVENUECAT_ENTITLEMENT_ID=premium
```

**Code:** `lib/providers/subscription_provider.dart`
```dart
final entitlement = customerInfo.entitlements.all[entitlementId];
if (entitlement != null && entitlement.isActive) {
  // User has premium access
}
```

### Multiple Entitlements (Advanced)

For apps with multiple tiers:

**Entitlements:**
- `basic` - Basic features
- `premium` - Premium features
- `pro` - Pro features

**Products:**
- `monthly_basic` → `basic` entitlement
- `monthly_premium` → `premium` entitlement
- `monthly_pro` → `pro` entitlement

**Check in app:**
```dart
final basicActive = customerInfo.entitlements.all['basic']?.isActive ?? false;
final premiumActive = customerInfo.entitlements.all['premium']?.isActive ?? false;
final proActive = customerInfo.entitlements.all['pro']?.isActive ?? false;
```

---

## 6️⃣ Offerings & Packages

### What are Offerings?

Offerings group products for display in your paywall. You can have multiple offerings for A/B testing.

**Example Offerings:**
- `default` - Standard pricing
- `sale` - Discounted pricing
- `new_user` - Special offer for new users

### Package Types

RevenueCat provides standard package identifiers:

- `$rc_monthly` - Monthly subscription
- `$rc_two_month` - Two-month subscription
- `$rc_three_month` - Three-month subscription
- `$rc_six_month` - Six-month subscription
- `$rc_annual` - Annual subscription
- `$rc_lifetime` - Lifetime purchase
- Custom - Any custom identifier

### Fetching Offerings in App

**Code:** `lib/providers/offerings_provider.dart`

```dart
@riverpod
Future<Offerings?> offerings(OfferingsRef ref) async {
  final offerings = await SubscriptionService.getOfferings();
  return offerings;
}
```

**Usage:** `lib/features/subscriptions/screens/paywall_screen.dart`

```dart
final offeringsAsync = ref.watch(offeringsProvider);

offeringsAsync.when(
  data: (offerings) {
    if (offerings == null || offerings.current == null) {
      return EmptyState(message: 'No plans available');
    }
    
    final packages = offerings.current!.availablePackages;
    // Display packages in UI
  },
  loading: () => AppLoadingIndicator(),
  error: (error, stack) => ErrorState(message: error.toString()),
);
```

---

## 7️⃣ Testing Subscriptions

### iOS Sandbox Testing

1. Create sandbox tester in App Store Connect
2. Sign in on device: Settings → App Store → Sandbox Account
3. Run app and purchase subscription
4. Verify in RevenueCat dashboard: **Customers** tab

**Sandbox Subscription Durations:**
- 1 week = 3 minutes
- 1 month = 5 minutes
- 2 months = 10 minutes
- 3 months = 15 minutes
- 6 months = 30 minutes
- 1 year = 1 hour

**Sandbox Renewal Limit:**
- Subscriptions auto-renew up to 6 times
- Then they expire (to test expiration flow)

### Android Testing

1. Publish to closed testing track
2. Add testers via email
3. Testers opt in and download from Play Store
4. Test purchases are free
5. Verify in RevenueCat dashboard

**Testing Subscription Durations:**
- 1 week = 5 minutes
- 1 month = 5 minutes
- 3 months = 10 minutes
- 6 months = 15 minutes
- 1 year = 30 minutes

### Testing Checklist

- [ ] Purchase subscription
- [ ] Verify entitlement is active
- [ ] Verify access to premium features
- [ ] Test restore purchases
- [ ] Test subscription expiration
- [ ] Test subscription renewal
- [ ] Test cancellation
- [ ] Test grace period (Android)
- [ ] Test free trial (if applicable)
- [ ] Verify in RevenueCat dashboard

---

## 8️⃣ Production Checklist

### Before Launch

- [ ] All products created in App Store Connect / Google Play Console
- [ ] All products configured in RevenueCat
- [ ] Products linked to entitlements
- [ ] Offerings configured with packages
- [ ] Current offering set
- [ ] API keys added to `.env` file
- [ ] Tested with sandbox/test accounts
- [ ] Paywall UI tested and polished
- [ ] Restore purchases tested
- [ ] Subscription status displayed correctly
- [ ] Error handling implemented
- [ ] Privacy policy includes subscription terms
- [ ] Terms of service includes subscription terms

### App Store Connect (iOS)

- [ ] Paid Apps Agreement signed
- [ ] Bank account information added
- [ ] Tax forms completed
- [ ] Subscription pricing set
- [ ] Subscription localization added
- [ ] Subscription group created
- [ ] App Store Connect API key linked to RevenueCat

### Google Play Console (Android)

- [ ] Merchant account set up
- [ ] Bank account information added
- [ ] Tax information completed
- [ ] Subscription pricing set
- [ ] Subscription activated
- [ ] Service account linked to RevenueCat
- [ ] Closed testing completed

---

## 9️⃣ Webhooks (Optional)

Webhooks notify your backend of subscription events in real-time.

### Setup Webhooks

1. In RevenueCat dashboard, go to **Integrations** → **Webhooks**
2. Click **+ New Webhook**
3. Enter your webhook URL (e.g., `https://yourapi.com/webhooks/revenuecat`)
4. Select events to receive:
   - Initial purchase
   - Renewal
   - Cancellation
   - Expiration
   - Billing issue
   - Product change
5. Click **Save**

### Webhook Events

RevenueCat sends JSON payloads for events:

```json
{
  "event": {
    "type": "INITIAL_PURCHASE",
    "app_user_id": "user123",
    "product_id": "monthly_premium",
    "entitlement_ids": ["premium"],
    "price": 9.99,
    "currency": "USD"
  }
}
```

### Use Cases

- Sync subscription status with your database
- Send confirmation emails
- Grant access to web dashboard
- Update user permissions
- Trigger analytics events

---

## 🔟 Analytics & Insights

### RevenueCat Dashboard

View metrics in the RevenueCat dashboard:

- **Revenue** - Total revenue, MRR, ARR
- **Active Subscriptions** - Current subscribers
- **Churn Rate** - Cancellation rate
- **Trials** - Trial conversions
- **Refunds** - Refund rate
- **Charts** - Revenue over time, cohort analysis

### Customer View

View individual customer data:

1. Go to **Customers** tab
2. Search by App User ID or email
3. View:
   - Active subscriptions
   - Purchase history
   - Entitlements
   - Transactions
   - Device info

### Integrations

Connect RevenueCat to other tools:

- **Analytics**: Amplitude, Mixpanel, Firebase
- **Attribution**: Adjust, AppsFlyer, Branch
- **CRM**: Intercom, Customer.io
- **Data**: Segment, mParticle

---

## 1️⃣1️⃣ Common Issues & Solutions

### Issue: "Invalid product identifier"

**Solution:**
- Verify product ID matches exactly between store and RevenueCat
- Check for typos, spaces, or case differences
- Ensure product is activated in store

### Issue: "Unable to connect to iTunes Store" (iOS)

**Solution:**
- Check sandbox account is signed in
- Verify internet connection
- Try signing out and back in to sandbox account
- Restart device

### Issue: "No offerings available"

**Solution:**
- Verify offerings are configured in RevenueCat
- Check that current offering is set (star icon)
- Verify products are linked to offering
- Check API key is correct in `.env`

### Issue: "Purchase succeeds but entitlement not active"

**Solution:**
- Verify product is linked to entitlement in RevenueCat
- Check entitlement identifier matches code
- Wait a few seconds for receipt validation
- Check RevenueCat dashboard for customer status

### Issue: "Restore purchases doesn't work"

**Solution:**
- Ensure user is signed in with same Apple ID / Google account
- Check that `restorePurchases()` is called correctly
- Verify receipt validation is working
- Check RevenueCat dashboard for purchase history

### Issue: "Subscription not renewing in sandbox"

**Solution:**
- Sandbox subscriptions renew up to 6 times, then expire
- This is expected behavior for testing expiration
- Create a new sandbox account to test renewals again

---

## 1️⃣2️⃣ Best Practices

### User Experience

- **Clear Pricing** - Show price, billing cycle, and what's included
- **Free Trial** - Offer 7-day free trial to increase conversions
- **Restore Purchases** - Always provide a restore button
- **Manage Subscription** - Link to App Store / Play Store settings
- **Cancel Anytime** - Clearly state users can cancel anytime
- **Privacy** - Explain how subscription data is used

### Technical

- **Cache Offerings** - Don't fetch on every paywall view
- **Handle Errors** - Show user-friendly error messages
- **Loading States** - Show loading indicators during purchase
- **Offline Support** - Handle offline scenarios gracefully
- **Receipt Validation** - Let RevenueCat handle server-side validation
- **User IDs** - Use consistent user IDs across devices

### Business

- **A/B Testing** - Test different pricing with offerings
- **Localized Pricing** - Use App Store / Play Store localized prices
- **Annual Plans** - Offer annual plans with discount (e.g., 40% off)
- **Lifetime Plans** - Consider one-time lifetime purchase option
- **Grace Period** - Enable grace period for billing issues (Android)
- **Introductory Offers** - Use intro pricing for new users

---

## 📚 Additional Resources

- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [RevenueCat Flutter SDK](https://docs.revenuecat.com/docs/flutter)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [RevenueCat Community](https://community.revenuecat.com/)

---

## ✅ RevenueCat Setup Complete!

Your subscription system is ready for:
- ✅ iOS subscriptions
- ✅ Android subscriptions
- ✅ macOS subscriptions
- ✅ Cross-platform user management
- ✅ Production deployment

**Next Steps:**
- Test thoroughly with sandbox/test accounts
- Polish your paywall UI
- Set up analytics and webhooks
- Launch and monitor metrics
- Iterate based on data

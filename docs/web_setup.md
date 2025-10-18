# Web Platform Setup Guide

This guide covers all web-specific configuration needed to deploy your Flutter app to the web.

---

## 📋 Prerequisites

- Flutter web support enabled (`flutter config --enable-web`)
- Web browser (Chrome, Firefox, Safari, Edge)
- Web hosting service (Firebase Hosting, Netlify, Vercel, etc.)
- Domain name (optional but recommended)

---

## 1️⃣ Web Configuration

### Enable Web Support

If not already enabled:

```bash
flutter config --enable-web
flutter create .
```

### Verify Web Support

```bash
flutter devices
```

You should see Chrome or Edge listed as available devices.

---

## 2️⃣ Meta Tags & SEO Configuration

Meta tags are configured in `web/index.html`. The template includes basic tags that should be customized.

### Update Basic Meta Tags

**File:** `web/index.html`

```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- Basic Meta Tags -->
  <title>Your App Name - Short Description</title>
  <meta name="description" content="Your app description for search engines (150-160 characters)">
  <meta name="keywords" content="flutter, app, subscription, your, keywords">
  <meta name="author" content="Your Company Name">
  
  <!-- Theme Color (Browser UI) -->
  <meta name="theme-color" content="#000000">
  
  <!-- iOS Meta Tags -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Your App Name">
  
  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://yourapp.com/">
  <meta property="og:title" content="Your App Name - Short Description">
  <meta property="og:description" content="Your app description for social media sharing">
  <meta property="og:image" content="https://yourapp.com/og-image.png">
  
  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content="https://yourapp.com/">
  <meta property="twitter:title" content="Your App Name - Short Description">
  <meta property="twitter:description" content="Your app description for Twitter sharing">
  <meta property="twitter:image" content="https://yourapp.com/twitter-image.png">
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  
  <!-- Manifest -->
  <link rel="manifest" href="manifest.json">
</head>
```

### Create Social Media Images

**Open Graph Image (og-image.png):**
- Size: 1200x630 pixels
- Format: PNG or JPG
- Place in: `web/og-image.png`

**Twitter Image (twitter-image.png):**
- Size: 1200x675 pixels (or use same as OG image)
- Format: PNG or JPG
- Place in: `web/twitter-image.png`

---

## 3️⃣ PWA Configuration (Progressive Web App)

### Update manifest.json

**File:** `web/manifest.json`

```json
{
  "name": "Your App Full Name",
  "short_name": "Your App",
  "description": "Your app description",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

**Display Modes:**
- `standalone` - Looks like a native app (recommended)
- `fullscreen` - Full screen, no browser UI
- `minimal-ui` - Minimal browser UI
- `browser` - Normal browser tab

### Create PWA Icons

**Required Sizes:**
- 192x192 pixels (minimum)
- 512x512 pixels (recommended)

Place in: `web/icons/`

**Tool:** Use [PWA Asset Generator](https://www.pwabuilder.com/imageGenerator)

---

## 4️⃣ Favicon Configuration

### Create Favicon

1. Create a 512x512 PNG icon
2. Use [Favicon Generator](https://realfavicongenerator.net/)
3. Download generated files
4. Place in `web/` directory

**Files to include:**
- `favicon.ico` (multi-size ICO)
- `favicon-16x16.png`
- `favicon-32x32.png`
- `apple-touch-icon.png` (180x180)

---

## 5️⃣ Build Configuration

### Development Build

```bash
flutter run -d chrome
```

**With specific port:**
```bash
flutter run -d chrome --web-port=8080
```

### Production Build

```bash
flutter build web --release
```

**Output:** `build/web/`

### Build with Custom Base Href

If deploying to a subdirectory:

```bash
flutter build web --release --base-href /myapp/
```

### Build Optimization

**Enable CanvasKit (Better Performance):**
```bash
flutter build web --release --web-renderer canvaskit
```

**Enable HTML Renderer (Smaller Size):**
```bash
flutter build web --release --web-renderer html
```

**Auto Renderer (Recommended):**
```bash
flutter build web --release --web-renderer auto
```

---

## 6️⃣ RevenueCat on Web

**Important:** RevenueCat SDK does not support web platforms.

### Web Fallback Behavior

The template automatically handles this:

**File:** `lib/providers/subscription_provider.dart`

```dart
// Web users automatically get free tier
if (kIsWeb) {
  return SubscriptionInfo.free();
}
```

### Alternative Solutions for Web

1. **Stripe Integration:**
   - Use Stripe Checkout for web subscriptions
   - Sync subscription status with your backend
   - Update Supabase user metadata

2. **PayPal Integration:**
   - Use PayPal subscription buttons
   - Handle webhooks on backend
   - Update user subscription status

3. **Backend API:**
   - Create custom subscription API
   - Handle payments via Stripe/PayPal
   - Return subscription status to Flutter app

**Recommendation:** For production web apps with subscriptions, implement a backend API that integrates with Stripe or PayPal.

---

## 7️⃣ Hosting & Deployment

### Firebase Hosting (Recommended)

**Setup:**
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
```

**Configure:**
- Public directory: `build/web`
- Single-page app: Yes
- Overwrite index.html: No

**Deploy:**
```bash
flutter build web --release
firebase deploy --only hosting
```

### Netlify

**Option 1: Drag & Drop**
1. Build: `flutter build web --release`
2. Go to [Netlify](https://app.netlify.com/)
3. Drag `build/web` folder

**Option 2: Git Integration**
1. Connect GitHub repository
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`

### Vercel

**Setup:**
```bash
npm i -g vercel
vercel login
```

**Deploy:**
```bash
flutter build web --release
cd build/web
vercel
```

### GitHub Pages

**Setup:**
1. Build: `flutter build web --release --base-href /repository-name/`
2. Copy `build/web` contents to `docs/` folder
3. Push to GitHub
4. Enable GitHub Pages in repository settings
5. Set source to `docs/` folder

### Custom Server (Apache/Nginx)

**Apache (.htaccess):**
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

**Nginx:**
```nginx
server {
  listen 80;
  server_name yourapp.com;
  root /var/www/yourapp;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }
}
```

---

## 8️⃣ Environment Variables for Web

### Build-Time Variables

Flutter web doesn't support `.env` files at runtime. Use build-time environment variables:

**Build with environment variables:**
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

**Access in code:**
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
```

### Alternative: Config File

Create a config file that's not gitignored:

**File:** `web/config.js`

```javascript
window.appConfig = {
  supabaseUrl: 'your_supabase_url',
  supabaseAnonKey: 'your_supabase_anon_key',
  // Don't include sensitive keys here!
};
```

**Load in index.html:**
```html
<script src="config.js"></script>
```

**Access in Dart:**
```dart
import 'dart:js' as js;

final config = js.context['appConfig'];
final supabaseUrl = config['supabaseUrl'];
```

---

## 9️⃣ CORS Configuration

### Supabase CORS

Supabase automatically allows all origins. For production, configure allowed origins:

1. Go to Supabase Dashboard
2. Settings → API
3. Add your domain to allowed origins

### Custom API CORS

If you have a custom backend, enable CORS:

**Express.js:**
```javascript
const cors = require('cors');
app.use(cors({
  origin: 'https://yourapp.com'
}));
```

**Django:**
```python
CORS_ALLOWED_ORIGINS = [
    "https://yourapp.com",
]
```

---

## 🔟 Performance Optimization

### Enable Caching

**Service Worker (Automatic):**
Flutter web includes a service worker for caching. It's automatically generated.

**Cache Headers (Server-Side):**

**Apache:**
```apache
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

**Nginx:**
```nginx
location ~* \.(png|jpg|jpeg|gif|ico|svg)$ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}
```

### Lazy Loading

Use deferred loading for large features:

```dart
import 'package:flutter/widgets.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _loadHeavyFeature(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
  
  Future<Widget> _loadHeavyFeature() async {
    // Load heavy feature
    return MyHeavyWidget();
  }
}
```

### Image Optimization

1. Use WebP format for images
2. Compress images before adding to assets
3. Use responsive images with different sizes
4. Lazy load images below the fold

---

## 1️⃣1️⃣ Testing on Web

### Local Testing

```bash
flutter run -d chrome
```

**Test on different browsers:**
```bash
flutter run -d chrome
flutter run -d edge
flutter run -d firefox  # If configured
```

### Testing Checklist

- [ ] Authentication flows work
- [ ] Deep linking (auth callbacks)
- [ ] Navigation (browser back/forward buttons)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] PWA installation
- [ ] Offline functionality (if applicable)
- [ ] CORS (API calls work)
- [ ] Performance (load time < 3 seconds)
- [ ] SEO (meta tags, social sharing)
- [ ] Browser compatibility (Chrome, Firefox, Safari, Edge)

### Browser Compatibility

**Supported Browsers:**
- Chrome 84+
- Firefox 79+
- Safari 14+
- Edge 84+

**Check compatibility:**
```bash
flutter doctor -v
```

---

## 1️⃣2️⃣ SEO Best Practices

### Server-Side Rendering (SSR)

Flutter web is a single-page app (SPA), which can be challenging for SEO. Consider:

1. **Pre-rendering:**
   - Use [prerender.io](https://prerender.io/)
   - Or [rendertron](https://github.com/GoogleChrome/rendertron)

2. **Static Site Generation:**
   - Generate static HTML for key pages
   - Use meta tags for social sharing

### Sitemap

Create `web/sitemap.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://yourapp.com/</loc>
    <lastmod>2024-01-01</lastmod>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://yourapp.com/about</loc>
    <lastmod>2024-01-01</lastmod>
    <priority>0.8</priority>
  </url>
</urlset>
```

### robots.txt

Create `web/robots.txt`:

```
User-agent: *
Allow: /
Sitemap: https://yourapp.com/sitemap.xml
```

---

## 1️⃣3️⃣ Analytics & Monitoring

### Google Analytics

Add to `web/index.html`:

```html
<head>
  <!-- Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-XXXXXXXXXX');
  </script>
</head>
```

### Firebase Analytics

Use `firebase_analytics` package:

```yaml
dependencies:
  firebase_analytics: ^10.7.0
```

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;
await analytics.logEvent(name: 'page_view');
```

---

## 1️⃣4️⃣ Security Considerations

### HTTPS Only

Always use HTTPS in production:
- Most hosting providers offer free SSL (Let's Encrypt)
- Firebase Hosting includes SSL automatically

### Content Security Policy (CSP)

Add to `web/index.html`:

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' 'unsafe-eval'; 
               style-src 'self' 'unsafe-inline';">
```

**Note:** Flutter web requires `unsafe-inline` and `unsafe-eval` for now.

### Environment Variables

Never expose sensitive keys in web builds:
- ✅ Supabase anon key (safe to expose)
- ❌ Supabase service role key (never expose)
- ❌ Private API keys (never expose)

---

## 1️⃣5️⃣ Common Issues & Solutions

### Issue: "Failed to load network image"

**Solution:**
- Check CORS configuration
- Ensure image URLs are accessible
- Use `NetworkImage` with error handling

### Issue: "Service worker registration failed"

**Solution:**
- Ensure HTTPS is enabled
- Check browser console for errors
- Clear browser cache and reload

### Issue: "App doesn't work offline"

**Solution:**
- Service worker is automatically included
- Test in Chrome DevTools → Application → Service Workers
- Ensure assets are properly cached

### Issue: "Deep links not working"

**Solution:**
- Configure server to redirect all routes to `index.html`
- Use hash routing: `GoRouter(routingConfig: RoutingConfig.hash)`
- Or configure server rewrites (see Hosting section)

### Issue: "Large bundle size"

**Solution:**
- Use `--web-renderer html` for smaller size
- Enable tree shaking (automatic in release mode)
- Remove unused dependencies
- Compress assets

---

## 📚 Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [PWA Documentation](https://web.dev/progressive-web-apps/)
- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Netlify Docs](https://docs.netlify.com/)
- [Web Performance Best Practices](https://web.dev/fast/)

---

## ✅ Web Setup Complete!

Once you've completed all steps above, your web app is ready for:
- ✅ Local testing
- ✅ Production deployment
- ✅ PWA installation
- ✅ SEO optimization

**Next Steps:**
- Configure iOS/Android (see platform-specific guides)
- Set up hosting and deploy
- Monitor analytics and performance
- Implement backend for subscriptions (if needed)

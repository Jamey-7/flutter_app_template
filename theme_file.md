# 🎨 **Complete Deep-Dive: Your Flutter Theme System**

## **File Structure Overview**

Your theme file (`lib/core/theme/app_theme.dart`) contains **424 lines** of carefully organized design system code with 7 main classes:

1. `AppTheme` - Theme configuration (light & dark)
2. `AppColors` - Color palette
3. `AppGradients` - Gradient definitions
4. `AppTypography` - Text styles
5. `AppSpacing` - Spacing constants
6. `AppRadius` - Border radius constants
7. `AppElevation` - Shadow elevation constants
8. **Extensions** - Convenience helpers

---

## **1. AppTheme Class** (Lines 3-191)

This is the **heart** of your theme system. It generates the complete `ThemeData` object that Flutter uses throughout your app.

### **A. Material 3 Support** (Line 6, 97)
```dart
useMaterial3: true
```
**What this does:**
- Enables Material Design 3 (latest design system from Google)
- Gives you modern components like filled buttons, tonal surfaces
- Better accessibility and color contrast handling
- Dynamic color support (can adapt to system colors on Android 12+)

### **B. ColorScheme** (Lines 7-17 Light, 98-108 Dark)

This is **crucial** - it defines the semantic color roles that Flutter widgets automatically use.

#### **Light Mode ColorScheme:**
```dart
ColorScheme.light(
  primary: AppColors.primary,           // Black (0xFF000000)
  onPrimary: AppColors.white,           // White text on primary
  secondary: AppColors.secondary,       // Purple (0xFF7C3AED)
  onSecondary: AppColors.white,         // White text on secondary
  error: AppColors.error,               // Red (0xFFEF4444)
  onError: AppColors.white,             // White text on error
  surface: AppColors.white,             // White surfaces
  onSurface: AppColors.textPrimary,     // Grey900 text on surfaces
  surfaceContainerHighest: AppColors.grey100, // Elevated surfaces
)
```

**What each role means:**
- **primary**: Your main brand color (used for FABs, prominent buttons, active states)
- **onPrimary**: Text/icons that appear ON primary color (ensures contrast)
- **secondary**: Accent color (used for less prominent buttons, chips, selections)
- **onSecondary**: Text/icons on secondary color
- **error**: Error states (validation, alerts)
- **surface**: Background of components (cards, sheets, dialogs)
- **onSurface**: Text on surface backgrounds
- **surfaceContainerHighest**: Highest elevation surface (like elevated cards)

#### **Dark Mode ColorScheme:**
```dart
primary: AppColors.white,     // ← Inverted! White primary in dark mode
onPrimary: AppColors.black,   // ← Black text on white
```

**Why this matters:**
- Your app **automatically adapts** when user switches to dark mode
- Widgets use these colors by default, so you get consistency for free
- Accessibility is built-in (contrast ratios are maintained)

### **C. Component Themes**

Your theme pre-styles **all** Material widgets. Here's what each does:

#### **ElevatedButton Theme** (Lines 20-29, 114-123)

**Light Mode:**
```dart
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(88, 48),    // Material Design minimum touch target
    backgroundColor: AppColors.primary, // Black background
    foregroundColor: AppColors.white,   // White text
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium), // 8px rounded
    ),
  ),
)
```

**What this does:**
Every `ElevatedButton` in your app automatically gets:
- Black background with white text (light mode)
- White background with black text (dark mode)
- 8px rounded corners
- 48px minimum height (accessibility)

**Usage example:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Click me'),
)
// ↑ Automatically styled! No need to specify colors/shape
```

#### **OutlinedButton Theme** (Lines 30-36, 124-130)
```dart
minimumSize: const Size(88, 48),
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppRadius.medium),
)
```

**What's different:**
- Only defines size and shape
- Colors come from `ColorScheme` automatically
- Light mode: Black border + black text
- Dark mode: White border + white text

#### **TextButton Theme** (Lines 38-44, 132-138)
Same as OutlinedButton - just size and shape.

#### **InputDecoration Theme** (Lines 46-73, 140-167)

This is **super important** - it styles ALL text fields in your app.

**Light Mode:**
```dart
inputDecorationTheme: InputDecorationTheme(
  filled: true,                    // Filled background
  fillColor: AppColors.grey50,     // Very light grey fill
  contentPadding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.md,     // 16px horizontal
    vertical: AppSpacing.md,       // 16px vertical
  ),
  border: OutlineInputBorder(...),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.grey300), // Light grey border
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.primary, width: 2), // Black when focused
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.error), // Red on error
  ),
)
```

**What this achieves:**
- All text fields have consistent padding (16px)
- Light grey background with grey border (resting state)
- Black border when focused (2px thick)
- Red border on validation errors
- Automatically rounded corners (8px)

**Dark Mode differences:**
```dart
fillColor: AppColors.grey800,    // Dark grey fill
borderSide: BorderSide(color: AppColors.grey700), // Darker grey border
```

#### **Card Theme** (Lines 74-80, 168-175)
```dart
cardTheme: CardThemeData(
  elevation: AppElevation.small,  // 2.0 shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.large), // 12px corners
  ),
  clipBehavior: Clip.antiAlias,   // Clips content to rounded corners
)
```

**Usage:**
```dart
Card(
  child: ListTile(title: Text('Item')),
)
// ↑ Automatically gets 12px rounded corners + 2px shadow
```

#### **Dialog Theme** (Lines 81-85, 176-181)
```dart
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppRadius.large), // 12px rounded
)
```

All `showDialog()` calls get rounded corners automatically.

#### **SnackBar Theme** (Lines 86-91, 182-188)
```dart
snackBarTheme: SnackBarThemeData(
  behavior: SnackBarBehavior.floating, // Floats above content (not full-width)
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.medium), // 8px rounded
  ),
)
```

**Result:** Modern floating snackbars with rounded corners.

---

## **2. AppColors Class** (Lines 193-246)

Your **complete color palette** - 46 color constants organized by purpose.

### **A. Primary Colors** (Lines 194-197)
```dart
static const Color primary = Color(0xFF000000);        // Pure black
static const Color primaryDark = Color(0xFF1E40AF);    // Blue 700
static const Color primaryLight = Color(0xFF3B82F6);   // Blue 500
```

**Current setup:** Black primary with blue variants (though you're using black primarily)

**Note:** `primaryDark` and `primaryLight` aren't used in your current ColorScheme - they're available for future use or custom components.

### **B. Secondary Colors** (Lines 199-202)
```dart
static const Color secondary = Color(0xFF7C3AED);      // Purple 600
static const Color secondaryDark = Color(0xFF6D28D9);  // Purple 700
static const Color secondaryLight = Color(0xFF8B5CF6); // Purple 500
```

**What this is:** Beautiful purple accent color family. Used for:
- Secondary actions
- Highlights
- Decorative elements
- Less prominent CTAs

### **C. Status Colors** (Lines 204-208)
```dart
static const Color success = Color(0xFF10B981);  // Green (Emerald 500)
static const Color error = Color(0xFFEF4444);    // Red (Red 500)
static const Color warning = Color(0xFFF59E0B);  // Amber 500
static const Color info = Color(0xFF3B82F6);     // Blue 500
```

**Usage examples:**
- Success: Confirmation messages, completed states
- Error: Validation errors, failed operations
- Warning: Caution messages, alerts
- Info: Informational messages, tips

### **D. Grey Scale** (Lines 214-224)

**Complete 10-step grey palette** from Tailwind CSS:

| Color | Hex | RGB | Use Case |
|-------|-----|-----|----------|
| grey50 | #F9FAFB | (249, 250, 251) | Lightest backgrounds |
| grey100 | #F3F4F6 | (243, 244, 246) | Subtle backgrounds |
| grey200 | #E5E7EB | (229, 231, 235) | Dividers |
| grey300 | #D1D5DB | (209, 213, 219) | Borders (default) |
| grey400 | #9CA3AF | (156, 163, 175) | Disabled text |
| grey500 | #6B7280 | (107, 114, 128) | Placeholder text |
| grey600 | #4B5563 | (75, 85, 99) | Secondary text |
| grey700 | #374151 | (55, 65, 81) | Dark borders |
| grey800 | #1F2937 | (31, 41, 55) | Dark surfaces |
| grey900 | #111827 | (17, 24, 39) | Primary text (dark) |

**Why this is excellent:**
- Consistent 50-900 naming (industry standard)
- Carefully calibrated contrast ratios
- Works in both light and dark modes
- Matches Tailwind CSS (easy reference)

### **E. Semantic Text Colors** (Lines 226-229)
```dart
static const Color textPrimary = grey900;    // Darkest text (headlines, body)
static const Color textSecondary = grey600;  // Less prominent text (captions, labels)
static const Color textDisabled = grey400;   // Disabled state text
```

**Why semantic names matter:**
Instead of `Text(style: TextStyle(color: AppColors.grey900))`, you write:
```dart
Text(style: TextStyle(color: AppColors.textPrimary))
```
Much more readable and intentional!

### **F. Gradient Colors** (Lines 237-239)
```dart
static const Color gradientStart = Color(0xFFFA6464); // Red (#FA6464)
static const Color gradientEnd = Color(0xFF19A2E6);   // Blue (#19A2E6)
```

**What we use this for:** Brand accent gradient (red → blue) on buttons and CTAs

### **G. Overlay Colors** (Lines 241-245)
```dart
static const Color overlayLight = Color(0x33000000);   // Black 20% opacity
static const Color overlayMedium = Color(0x66000000);  // Black 40% opacity
static const Color overlayDark = Color(0x99000000);    // Black 60% opacity
static const Color overlayDarker = Color(0xE6000000);  // Black 90% opacity
```

**What these do:** Create image overlays with varying darkness for text readability

**Hex opacity guide:**
- `0x33` = 20% (51/255)
- `0x66` = 40% (102/255)
- `0x99` = 60% (153/255)
- `0xE6` = 90% (230/255)

---

## **3. AppGradients Class** (Lines 248-292)

**Ready-to-use gradient definitions** for consistent design.

### **A. Brand Accent Gradient** (Lines 250-253)
```dart
static const LinearGradient brandAccent = LinearGradient(
  colors: [AppColors.gradientStart, AppColors.gradientEnd],
);
```

**Where it's used:**
- `AuthButton.primary()` gradient border
- CTAs and prominent actions
- Decorative elements

**Visual:** Red (#FA6464) → Blue (#19A2E6)

### **B. Dark Overlay Gradient** (Lines 255-266)
```dart
static const LinearGradient darkOverlay = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    AppColors.overlayMedium,   // 40% black
    AppColors.overlayDark,     // 60% black
    AppColors.overlayDarker,   // 90% black
    AppColors.black,           // 100% black
  ],
  stops: [0.0, 0.3, 0.7, 1.0],
);
```

**What this creates:**
- Top: 40% transparent black
- At 30%: 60% transparent black
- At 70%: 90% transparent black
- Bottom: Solid black

**Use case:** Background images with white text overlay (like your auth screens)

**Visualization:**
```
┌─────────────────┐
│  40% opacity    │  ← Top: slightly dark
│  60% opacity    │  ← Middle: darker
│  90% opacity    │  ← Lower: very dark
│ 100% black      │  ← Bottom: solid black
└─────────────────┘
```

### **C. Light Overlay Gradient** (Lines 268-279)
Same concept but with white for light mode images.

### **D. Shimmer Gradient** (Lines 281-291)
```dart
static const LinearGradient shimmer = LinearGradient(
  begin: Alignment(-1.0, 0.0),    // Left
  end: Alignment(1.0, 0.0),       // Right
  colors: [
    Color(0xFFE0E0E0),            // Grey
    Color(0xFFF5F5F5),            // Light grey
    Color(0xFFE0E0E0),            // Grey
  ],
  stops: [0.0, 0.5, 1.0],
);
```

**What this does:** Horizontal shimmer effect for loading skeleton screens

**Usage example:**
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return AppGradients.shimmer.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Container(...), // Your skeleton UI
    );
  },
)
```

---

## **4. AppTypography Class** (Lines 294-383)

**Complete Material 3 text hierarchy** - 13 predefined text styles.

### **Font Family** (Line 295)
```dart
static const String fontFamily = 'System';
```
Uses the system default font (San Francisco on iOS, Roboto on Android).

### **Text Styles Breakdown**

Your typography follows **Material 3 type scale** with 3 categories:

#### **Display Styles** - Hero text, marketing
| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| displayLarge | 57px | 700 (Bold) | Largest headlines, hero sections |
| displayMedium | 45px | 700 (Bold) | Large headlines, auth screen titles |
| displaySmall | 36px | 700 (Bold) | Section headers |

**Example from your app:**
```dart
Text(
  'Hello,',
  style: context.textTheme.displayMedium?.copyWith(
    fontSize: context.responsive<double>(...), // Auth screens use this
  ),
)
```

#### **Headline Styles** - Page titles, prominent labels
| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| headlineLarge | 32px | 700 (Bold) | Page titles |
| headlineMedium | 28px | 600 (Semi-bold) | Card titles |
| headlineSmall | 24px | 600 (Semi-bold) | Section titles |

#### **Title Styles** - Subtitles, list headers
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| titleLarge | 22px | 600 (Semi-bold) | 0 |
| titleMedium | 16px | 600 (Semi-bold) | 0.15px |
| titleSmall | 14px | 600 (Semi-bold) | 0.1px |

#### **Body Styles** - Main content text
| Style | Size | Weight | Line Height | Use Case |
|-------|------|--------|-------------|----------|
| bodyLarge | 16px | 400 (Regular) | 1.5 | Main body text |
| bodyMedium | 14px | 400 (Regular) | 1.42 | Secondary content |
| bodySmall | 12px | 400 (Regular) | 1.33 | Captions, disclaimers |

**Line height explained:**
- `height: 1.5` means line height is 1.5x the font size
- 16px font × 1.5 = 24px line height
- Ensures readability and breathing room

#### **Label Styles** - Buttons, chips, tags
| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| labelLarge | 14px | 500 (Medium) | Button text |
| labelMedium | 12px | 500 (Medium) | Small buttons, chips |
| labelSmall | 11px | 500 (Medium) | Tiny labels, badges |

### **Why This Hierarchy Matters**

**Consistency:** Every screen uses the same text styles
**Accessibility:** Proper contrast ratios and line heights
**Maintainability:** Change font sizes in one place, updates everywhere
**Responsive:** Can override fontSize while keeping other properties

**Usage:**
```dart
// ❌ Bad - hardcoded
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
)

// ✅ Good - uses theme
Text(
  'Title',
  style: context.textTheme.headlineSmall,
)
```

---

## **5. AppSpacing Class** (Lines 385-394)

**8-step spacing scale** - consistent margins and padding throughout your app.

| Constant | Value | Use Case |
|----------|-------|----------|
| xxs | 2px | Tiny gaps, fine-tuning |
| xs | 4px | Minimal spacing |
| sm | 8px | Small padding, tight layouts |
| md | 16px | **Default spacing** (most common) |
| lg | 24px | Section spacing |
| xl | 32px | Large gaps between sections |
| xxl | 48px | Extra large spacing |
| xxxl | 64px | Maximum spacing, hero sections |

**Why 8px base grid?**
- Material Design standard
- Divisible by 2 (easy scaling)
- Works well on all screen densities
- Creates visual rhythm

**Usage:**
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.md), // 16px all sides
  child: Column(
    children: [
      Text('Item 1'),
      SizedBox(height: AppSpacing.lg), // 24px vertical gap
      Text('Item 2'),
    ],
  ),
)
```

**Design Pattern:** Use multiples of 8 for consistency:
- Small: 8px, 16px, 24px
- Large: 32px, 48px, 64px

---

## **6. AppRadius Class** (Lines 396-403)

**Border radius constants** for rounded corners.

| Constant | Value | Use Case | Example |
|----------|-------|----------|---------|
| small | 4px | Subtle rounding | Chips, tags |
| medium | 8px | **Default** | Buttons, inputs, cards |
| large | 12px | Prominent rounding | Cards, dialogs |
| xlarge | 16px | Extra rounded | Large cards |
| xxlarge | 24px | Very rounded | Hero cards |
| circular | 9999px | **Pill shape** | Fully rounded buttons, avatars |

**Visual examples:**

```
small (4px):    ╭──────╮
                │      │
                ╰──────╯

medium (8px):   ╭────────╮
                │        │
                ╰────────╯

circular:       ╭──────────────╮
                │   Button     │
                ╰──────────────╯
```

**Usage:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.medium), // 8px
    color: Colors.blue,
  ),
  child: Text('Rounded container'),
)
```

**Why `circular = 9999`?**
- Creates perfect pill shape regardless of size
- Works for circles and fully rounded rectangles
- Industry standard trick

---

## **7. AppElevation Class** (Lines 405-411)

**Shadow elevation values** for Material Design depth.

| Constant | Value | Shadow | Use Case |
|----------|-------|--------|----------|
| none | 0.0 | No shadow | Flat surfaces |
| small | 2.0 | Subtle | Cards (default) |
| medium | 4.0 | Noticeable | Raised buttons |
| large | 8.0 | Prominent | Dialogs, sheets |
| xlarge | 16.0 | Dramatic | Floating elements, tooltips |

**What elevation does:**
Creates depth perception with shadows:
```
elevation: 0  →  No shadow (flat)
elevation: 2  →  Subtle shadow
elevation: 8  →  Noticeable shadow
elevation: 16 →  Dramatic shadow (floats above)
```

**Usage:**
```dart
Card(
  elevation: AppElevation.medium, // 4.0
  child: Text('Elevated card'),
)
```

**Material Design principle:**
Higher elevation = closer to user = more important

---

## **8. Theme Extensions** (Lines 413-423)

**Convenience helpers** to access theme values easily.

### **A. ThemeExtensions** (Lines 413-417)
```dart
extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
```

**What this enables:**
```dart
// ❌ Verbose
final primaryColor = Theme.of(context).colorScheme.primary;
final textStyle = Theme.of(context).textTheme.bodyLarge;

// ✅ Clean
final primaryColor = context.colors.primary;
final textStyle = context.textTheme.bodyLarge;
```

**Behind the scenes:**
- Extension methods add functionality to `BuildContext`
- No inheritance needed
- Syntactic sugar for cleaner code

### **B. GradientExtensions** (Lines 419-423)
```dart
extension GradientExtensions on BuildContext {
  Type get gradients => AppGradients;
}
```

**Usage:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppGradients.brandAccent, // Direct access
  ),
)
```

---

## **How Everything Works Together**

### **Theme Application Flow**

```
1. app.dart loads theme:
   MaterialApp(
     theme: AppTheme.light(),        ← Loads light theme
     darkTheme: AppTheme.dark(),     ← Loads dark theme
     themeMode: ThemeMode.system,    ← Respects system setting
   )

2. AppTheme.light() returns ThemeData:
   - ColorScheme (primary, secondary, etc.)
   - Component themes (buttons, inputs, cards)
   - Typography (text styles)

3. Every widget inherits theme:
   - ElevatedButton uses elevatedButtonTheme
   - TextField uses inputDecorationTheme
   - Card uses cardTheme

4. Widgets access theme via context:
   context.colors.primary    ← Gets black (light) or white (dark)
   context.textTheme.bodyLarge  ← Gets 16px text style
```

### **Real Example from Your App**

**Login Screen Button:**
```dart
AuthButton.primary(
  text: 'Sign In',
  onPressed: _handleSignIn,
  isLoading: _isLoading,
)
```

**What happens behind the scenes:**
1. `AuthButton` uses `AppGradients.brandAccent` (red → blue gradient)
2. Button background uses `const Color(0xFF0C0C0C)` (near-black)
3. Text color is `AppColors.white`
4. Border radius is `AppRadius.circular` (9999 = pill shape)
5. Shadow uses values from theme

**AuthTextField:**
```dart
AuthTextField.email(
  controller: _emailController,
  validator: Validators.email,
)
```

**What it applies:**
1. Fill color: `AppColors.black.withValues(alpha: 0.6)` (60% transparent black)
2. Border color: `AppColors.white.withValues(alpha: 0.3)` (30% white)
3. Text color: `AppColors.white`
4. Border radius: `AppRadius.medium` (8px)
5. Padding: 16px vertical, 12px horizontal
6. Icon color: `AppColors.white.withValues(alpha: 0.7)`

---

## **Summary: What Your Theme Provides**

### **✅ Color System**
- 46 predefined colors
- Semantic naming (primary, secondary, success, etc.)
- Complete grey scale (50-900)
- Brand gradients (red → blue)
- Overlay colors for images

### **✅ Typography**
- 13 text styles (display, headline, title, body, label)
- Material 3 compliant
- Proper line heights and letter spacing
- Accessible contrast ratios

### **✅ Spacing & Layout**
- 8-step spacing scale (2px - 64px)
- Consistent padding/margins
- 8px base grid system

### **✅ Visual Effects**
- 6 border radius values
- 5 elevation levels
- 4 gradient definitions

### **✅ Component Themes**
- Buttons (elevated, outlined, text)
- Text fields (with all states)
- Cards
- Dialogs
- Snackbars

### **✅ Convenience**
- Context extensions for easy access
- Automatic light/dark mode support
- Material 3 modern design

---

## **Best Practices You're Following**

1. ✅ **Single source of truth** - All design tokens in one file
2. ✅ **Semantic naming** - `textPrimary` not `grey900`
3. ✅ **Material 3 compliant** - Modern design system
4. ✅ **Accessibility** - Proper contrast ratios and touch targets
5. ✅ **Responsive** - Can override sizes while maintaining theme
6. ✅ **Maintainable** - Change once, updates everywhere
7. ✅ **Reusable** - Components inherit theme automatically
8. ✅ **Documented** - Comments explain purpose of each gradient

---

## **Quick Reference Cheat Sheet**

### **Colors**
```dart
AppColors.primary          // Black
AppColors.secondary        // Purple
AppColors.success          // Green
AppColors.error            // Red
AppColors.warning          // Amber
AppColors.textPrimary      // Grey900
AppColors.textSecondary    // Grey600
AppColors.grey[50-900]     // Grey scale
```

### **Gradients**
```dart
AppGradients.brandAccent   // Red → Blue
AppGradients.darkOverlay   // Transparent → Black
AppGradients.lightOverlay  // Transparent → White
AppGradients.shimmer       // Loading shimmer
```

### **Typography**
```dart
context.textTheme.displayLarge    // 57px bold
context.textTheme.displayMedium   // 45px bold
context.textTheme.headlineLarge   // 32px bold
context.textTheme.bodyLarge       // 16px regular
context.textTheme.labelLarge      // 14px medium
```

### **Spacing**
```dart
AppSpacing.xxs   // 2px
AppSpacing.xs    // 4px
AppSpacing.sm    // 8px
AppSpacing.md    // 16px (default)
AppSpacing.lg    // 24px
AppSpacing.xl    // 32px
AppSpacing.xxl   // 48px
AppSpacing.xxxl  // 64px
```

### **Border Radius**
```dart
AppRadius.small      // 4px
AppRadius.medium     // 8px (default)
AppRadius.large      // 12px
AppRadius.xlarge     // 16px
AppRadius.xxlarge    // 24px
AppRadius.circular   // 9999px (pill)
```

### **Elevation**
```dart
AppElevation.none     // 0
AppElevation.small    // 2 (default)
AppElevation.medium   // 4
AppElevation.large    // 8
AppElevation.xlarge   // 16
```

### **Context Extensions**
```dart
context.colors.primary       // Access ColorScheme
context.textTheme.bodyLarge  // Access TextTheme
context.theme                // Access full ThemeData
```

---

**Your theme system is production-ready and professional!** 🎨✨

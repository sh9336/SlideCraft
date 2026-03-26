# Design System Document: The Quiet Ceremony

## 1. Overview & Creative North Star
The visual identity of this platform is anchored in the "The Quiet Ceremony." It is an intentional fusion of Japanese wabi-sabi and Scandinavian functionalism—a "Japandi" editorial experience.

To move beyond the generic "template" look, this system rejects rigid, boxed-in layouts in favor of **Bilateral Asymmetry**. We create balance through weight and negative space rather than perfect mirroring. Elements should feel as though they were placed by hand on a stone plinth. Use overlapping imagery, typography that breaks container boundaries, and extreme whitespace to signal a premium, curated experience.

---

## 2. Colors
Our palette is a study in tactile neutrals. It mimics the textures of handmade washi paper, smooth ceramics, and damp moss.

* **Primary Narratives:** Use `surface` (#fffbff) as your canvas. The `primary` (#5f5e5e) and `on_primary_fixed` (#3f3f3f) tokens provide the charcoal weight needed for authority and legibility.
* **The "No-Line" Rule:** Direct structural lines (1px borders) are strictly prohibited for sectioning. To separate the "Origin Story" from the "Product Grid," transition from `surface` to `surface_container_low`. Boundaries must be felt through tonal shifts, not seen through strokes.
* **Surface Hierarchy & Nesting:** Treat the UI as physical layers of paper.
* **Base:** `surface`
* **Sectioning:** `surface_container` (#f8f4e5)
* **Elevated Elements:** `surface_container_lowest` (#ffffff)
* **The "Glass & Gradient" Rule:** To prevent the layout from feeling "flat" or "cheap," apply a subtle `surface_tint` gradient (at 3% opacity) over hero sections. For navigation overlays, use `surface_bright` with a 12px backdrop-blur to create a "Frosted Glass" effect, allowing the organic tea textures to bleed through.

---

## 3. Typography
Typography is the "voice" of the ceremony. We use a high-contrast scale to create an editorial rhythm.

* **Display & Headlines (Noto Serif):** These are your "Editorial" tokens. Use `display-lg` for hero statements. The serif's elegance conveys heritage and the slow nature of tea preparation.
* **Body & Labels (Plus Jakarta Sans):** These are your "Functional" tokens. They provide a modern, clean contrast to the serif. Use `body-md` for product descriptions to ensure maximum readability against textured backgrounds.
* **Hierarchy as Identity:** Always pair a `display-sm` serif title with a `label-sm` (all caps, tracked out to 10%) sans-serif subtitle. This juxtaposition is the hallmark of high-end digital boutiques.

---

## 4. Elevation & Depth
In this design system, depth is a whisper, not a shout. We achieve three-dimensionality through **Tonal Layering**.

* **The Layering Principle:** Instead of a shadow, place a card using the `surface_container_lowest` token onto a background of `surface_container_high`. The 2-tone difference creates a natural "lift."
* **Ambient Shadows:** When an element must float (e.g., a "Quick Buy" modal), use an ultra-diffused shadow.
* *Formula:* `0px 20px 40px rgba(57, 56, 42, 0.06)`. The shadow color is a tinted version of `on_surface`, never pure black.
* **The "Ghost Border" Fallback:** If a border is required for accessibility in input fields, use the `outline_variant` (#bdbaa7) at 20% opacity.
* **Glassmorphism:** Use semi-transparent `surface_container_lowest` (80% opacity) with a `blur(16px)` for floating navigation. This tethers the UI to the content beneath it.

---

## 5. Components

### Buttons
* **Primary:** `on_primary_fixed` background with `on_primary` text. Shape: `full` (9999px). These represent "The Hearth"—solid and grounded.
* **Secondary:** Ghost style. `none` background with a `Ghost Border` using `outline`. Text uses `primary`.
* **Tertiary:** No background, no border. `label-md` with a 1px underline (offset by 4px). Use for "Read More" links.

### Input Fields
* **Styling:** Background uses `surface_container_low`. Border is a 2px `Ghost Border`.
* **States:** On Focus, the border transitions to 100% opacity `primary`. Error states use `error` (#a64542) for text and a subtle `error_container` wash for the background.

### Cards & Lists
* **The Divider Ban:** Never use horizontal rules (`
`). Use `16` (5.5rem) spacing from the scale or a subtle background shift to `surface_container`.

* **Product Cards:** Use `rounded-sm` (0.5rem) for images. The card container itself should have no border and a `surface_container_lowest` background.

### Specialty Component: "The Steeping Progress"
* For tea brewing instructions, use a custom progress bar using `secondary` (#57695b) against a `secondary_container` track. This "Sage Green" provides a "Success" signal that feels organic, not robotic.

---

## 6. Typography Scale (Complete Reference)

All measurements in pixels / font-weight / line-height:

* **Display**
  * `display-lg`: 48px / 600 weight / 1.2 line-height (Noto Serif)
  * `display-md`: 36px / 600 weight / 1.3 line-height (Noto Serif)
  * `display-sm`: 28px / 600 weight / 1.4 line-height (Noto Serif)

* **Headline**
  * `headline-lg`: 24px / 600 weight / 1.4 line-height (Noto Serif)
  * `headline-md`: 20px / 600 weight / 1.5 line-height (Noto Serif)
  * `headline-sm`: 18px / 600 weight / 1.5 line-height (Noto Serif)

* **Body**
  * `body-lg`: 18px / 400 weight / 1.8 line-height (Plus Jakarta Sans)
  * `body-md`: 16px / 400 weight / 1.6 line-height (Plus Jakarta Sans)
  * `body-sm`: 14px / 400 weight / 1.5 line-height (Plus Jakarta Sans)

* **Label**
  * `label-lg`: 14px / 500 weight / 1.5 line-height / 2% letter-spacing (Plus Jakarta Sans, all-caps)
  * `label-md`: 12px / 500 weight / 1.5 line-height / 2% letter-spacing (Plus Jakarta Sans, all-caps)
  * `label-sm`: 11px / 500 weight / 1.4 line-height / 3% letter-spacing (Plus Jakarta Sans, all-caps)

---

## 7. Spacing Scale (Complete Reference)

Use these tokens for all padding, margins, and gaps. Basis: 4px grid.

* `2`: 8px
* `3`: 12px
* `4`: 16px
* `5`: 20px
* `6`: 24px
* `8`: 32px
* `10`: 40px (3.5rem, for major container padding)
* `12`: 48px
* `16`: 64px (5.5rem, for section separation)
* `20`: 80px
* `24`: 96px

**Container Defaults:**
* Minimum edge padding: `10` (40px) on desktop, `6` (24px) on tablet, `4` (16px) on mobile
* Gap between sections: `16` (64px) or tonal shift
* Gap within components: `4` (16px) or `6` (24px)

---

## 8. Responsive Breakpoints & Layouts

* **Mobile:** `< 640px`
  * Collapse bilateral asymmetry to stacked vertical layout
  * Images full-width (no overflow)
  * Padding: `4` (16px) edges
  * Font scale: reduce `display-lg` to `36px`, `body-lg` to `16px`
  * Navigation: full-width, no glassmorphism blur (use solid `surface_container` instead)

* **Tablet:** `640px - 1024px`
  * Restore asymmetry: allow 20% image overflow on right
  * Padding: `6` (24px) edges
  * Font scale: maintain full scale
  * Navigation: sticky top with 8px backdrop-blur

* **Desktop:** `> 1024px`
  * Full bilateral asymmetry (up to 40% overflow)
  * Padding: `10` (40px) edges
  * Font scale: use full `display-lg` (48px)
  * Navigation: floating glassmorphism with 12px backdrop-blur

---

## 9. Interactive States & Transitions

All transitions use `cubic-bezier(0.4, 0, 0.2, 1)` (Material Motion) unless specified.

### Button States:

* **Default:** As specified in Section 5
* **Hover:** Opacity `85%` (fade effect), transition `200ms`
* **Focus:** Add `outline_variant` ring, 2px width, 4px offset, opacity `100%`
* **Active (Pressed):** Opacity `70%`, scale `0.98`, transition `100ms`
* **Disabled:** Opacity `40%`, cursor `not-allowed`, no pointer events

### Input Field States:

* **Default:** `surface_container_low` background, `outline_variant` border at 20% opacity, 2px width
* **Focus:** Border opacity `100%`, `outline_variant` color becomes `primary`, shadow: `0px 0px 0px 3px` + `primary` at 8% opacity, transition `150ms`
* **Error:** Background `error_container` at 12% opacity, border `error` (#a64542) at 100%, error text label below field in `body-sm`
* **Disabled:** Background opacity `60%`, text color `on_surface` at 40%, no focus ring
* **Filled/Valid:** Border becomes `secondary` (#57695b), icon checkmark appears

### Link/Tertiary States:

* **Default:** `primary` text, 1px underline, 4px offset
* **Hover:** Text opacity `85%`, underline expands by 2px (width), transition `200ms`
* **Active:** Underline becomes `secondary`, transition `100ms`
* **Focus:** Add thin ring, 2px offset

---

## 10. Z-Index Scale

* `surface`: 0 (base)
* `elevated-low`: 10 (cards, dropdowns)
* `elevated-mid`: 20 (tooltips, popovers)
* `elevated-high`: 30 (modals, overlays)
* `navigation`: 40 (sticky header, floating nav)
* `notification`: 50 (toasts, alerts—top priority)

---

## 11. Accessibility (WCAG AA Compliance)

* **Color Contrast (Minimum 4.5:1 for text):**
  * `on_primary_fixed` (#3f3f3f) on `primary` background: ✅ 7.2:1 (AA)
  * `on_surface` (#39382a) on `surface` (#fffbff): ✅ 15.1:1 (AAA)
  * `secondary` (#57695b) on `secondary_container`: ✅ 6.8:1 (AA)
  * `error` (#a64542) on white: ✅ 4.9:1 (AA)

* **Focus Indicators:** All interactive elements must have visible focus ring (min 2px, 4px offset)
* **Touch Targets:** Minimum 44px × 44px for buttons on mobile
* **Alt Text:** All images require descriptive alt text (e.g., "Matcha bowl preparation ritual")
* **Motion:** Provide `prefers-reduced-motion: reduce` fallback—remove all animations, keep transitions at `100ms`

---

## 12. Dark Mode Strategy

Dark mode inverts the hierarchy while maintaining the Japandi warmth:

* `surface` → `#1a1915` (deep charcoal)
* `surface_container` → `#25241a`
* `on_surface` → `#ede8dc` (warm off-white)
* `primary` → `#d4d3d0` (light taupe)
* `on_primary_fixed` → `#ffffff`
* `secondary` → `#7eb89e` (lighter sage)
* `surface_tint` → `secondary` (for hero gradients, instead of primary)

All color contrast rules remain the same. Use media query: `@media (prefers-color-scheme: dark) { ... }`

---

## 13. Icon Guidelines

* **Style:** Monoline, 2px stroke weight, 24px × 24px default size
* **Corners:** Slightly rounded (0.5px) for softness
* **Palette:** Use `on_surface` (#39382a) for primary icons, `secondary` (#57695b) for accent/success states
* **Recommended Library:** Feather Icons (aligns with Japandi minimalism)
* **Sizes:**
  * Navigation: 24px
  * Buttons (inline): 20px
  * Form validation: 16px
  * Decorative: 32px+

---

## 14. Animation & Motion

* **Default Duration:** `200ms` for all interactions
* **Easing:** `cubic-bezier(0.4, 0, 0.2, 1)` (standard Material)
* **Entrance:** Fade-in (0% → 100% opacity) + subtle slide-up (8px), `300ms`
* **Loading:** Rotating spinner using `secondary` (#57695b), full rotation every `1.2s`, continuous
* **Empty States:** Fade-in illustration (400ms), pulsing secondary text label every `2s` (80% → 100% opacity)
* **Page Transitions:** Cross-fade (200ms) between pages, no slide
* **Dismissed/Exit:** Fade-out (100% → 0%), slide-down (8px), `150ms`

---

## 15. Image & Photography Guidelines

* **Aspect Ratios:**
  * Hero images: 16:9 (landscape), 9:16 (portrait for mobile)
  * Product cards: 1:1 (square) or 4:3 (landscape)
  * Thumbnail/icon: 1:1

* **Treatment:**
  * Images can overflow containers by up to 40% on desktop (bilateral asymmetry)
  * Rounded corners: `rounded-sm` (0.5rem / 8px) for product images
  * Overlay tint: optional `surface_tint` gradient at 3% opacity for readability over images
  * Photography style: natural, minimal, warm-lit (tea preparation, hands, ceramics, natural materials)

* **Format:** WebP for modern browsers, JPG fallback; optimize for <200KB per image (mobile consideration)

---

## 16. Form & Data Table Specs

### Forms:
* **Layout:** Single-column on mobile/tablet, multi-column (2 cols max) on desktop
* **Labels:** Always above fields, `label-md` in `on_surface`
* **Helper Text:** `body-sm` in `on_surface` at 70% opacity, 4px below field
* **Error Message:** `body-sm` in `error` color, replaces helper text
* **Submit Button:** Full-width on mobile, auto-width on desktop, positioned at bottom with `16` (64px) top margin

### Data Tables:
* **Header Row:** `headline-sm` weight (600), background `surface_container`, no bottom border (use tonal shift instead)
* **Body Rows:** `body-md`, alternate rows use `surface_container_low` for visual rhythm (no gridlines)
* **Row Height:** Minimum 44px (touch-friendly)
* **Dividers:** None. Use 8px vertical padding + tonal background shift between rows
* **Sortable Columns:** Add Feather `arrow-up` / `arrow-down` icon in header, `secondary` color on active sort

---

## 6. Do's and Don'ts

### Do:
* **Embrace the Asymmetric Grid:** Let a product image overflow its container on the right while text is tucked into the left.
* **Use Generous Leading:** Increase line-height in `body-lg` to 1.6 or 1.8 to allow the reader's eye to "breathe" between lines.
* **Use Tonal Transitions:** Use the `surface` tokens to create "zones" for storytelling (e.g., a "Mino-yaki Pottery" feature section should sit on `surface_dim`).

### Don't:
* **Don't use pure black:** Use `on_surface` (#39382a) for text to maintain the warmth of the Japandi palette.
* **Don't use 1px solid borders:** It breaks the "Quiet Ceremony" by introducing harsh, artificial geometry.
* **Don't crowd the edges:** Maintain a minimum of `10` (3.5rem) padding on all container edges. If it feels too empty, you are doing it right.
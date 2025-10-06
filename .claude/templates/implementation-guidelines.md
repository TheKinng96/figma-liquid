# HTML/CSS/JS Implementation Guidelines

## Purpose
Best practices for implementing Figma designs as semantic, accessible, performant HTML/CSS/JavaScript.

---

## HTML Guidelines

### Semantic HTML Structure
Use meaningful HTML5 elements that convey structure and purpose.

#### ✅ DO: Use Semantic Elements
```html
<header class="site-header">
  <nav class="site-header__nav">
    <ul class="site-header__menu">
      <li><a href="/products">Products</a></li>
    </ul>
  </nav>
</header>

<main class="main-content">
  <section class="hero">
    <h1>Welcome</h1>
  </section>

  <article class="product-card">
    <h2>Product Title</h2>
  </article>
</main>

<footer class="site-footer">
  <p>&copy; 2025 Store</p>
</footer>
```

#### ❌ DON'T: Use Generic Divs
```html
<div class="header">
  <div class="nav">
    <div class="menu">
      <div><a href="/products">Products</a></div>
    </div>
  </div>
</div>
```

### Heading Hierarchy
Follow proper h1 → h2 → h3 structure.

#### ✅ DO: Logical Hierarchy
```html
<h1>Main Page Title</h1>
  <h2>Section Heading</h2>
    <h3>Subsection</h3>
  <h2>Another Section</h2>
```

#### ❌ DON'T: Skip Levels
```html
<h1>Title</h1>
  <h4>Skipped h2 and h3!</h4>
```

### Accessibility

#### ARIA Labels
Add labels for interactive elements without visible text.

```html
<button aria-label="Add to cart">
  <svg aria-hidden="true"><!-- cart icon --></svg>
</button>

<a href="/cart" aria-label="View cart (3 items)">
  <span aria-hidden="true">🛒</span>
  <span class="cart-count">3</span>
</a>
```

#### Form Labels
Every input needs an associated label.

```html
<!-- Visible label -->
<label for="email">Email Address</label>
<input type="email" id="email" name="email">

<!-- Visually hidden label -->
<label for="search" class="sr-only">Search products</label>
<input type="search" id="search" placeholder="Search...">
```

#### Keyboard Navigation
Ensure all interactive elements are keyboard accessible.

```html
<!-- Good: Native button is keyboard accessible -->
<button>Click me</button>

<!-- Bad: Div click requires extra work -->
<div onclick="handleClick()">Click me</div>

<!-- If using div, add role and tabindex -->
<div role="button" tabindex="0" onclick="handleClick()" onkeypress="handleKey(event)">
  Click me
</div>
```

### Images

#### Alt Text
Always provide meaningful alt text.

```html
<!-- Decorative image -->
<img src="pattern.svg" alt="" role="presentation">

<!-- Meaningful image -->
<img src="product.jpg" alt="Blue cotton t-shirt, front view">

<!-- Logo -->
<img src="logo.svg" alt="Company Name">
```

#### Responsive Images
Use srcset for different screen sizes.

```html
<img
  src="product-medium.jpg"
  srcset="
    product-small.jpg 375w,
    product-medium.jpg 768w,
    product-large.jpg 1920w
  "
  sizes="(max-width: 768px) 100vw, 50vw"
  alt="Product name"
  loading="lazy"
>
```

### No Inline Styles or Content
Keep HTML clean and semantic.

#### ✅ DO: Use Classes
```html
<div class="product-card">
  <h2 class="product-card__title">Product Title</h2>
</div>
```

#### ❌ DON'T: Inline Styles
```html
<div style="display: flex; padding: 20px;">
  <h2 style="color: #333; font-size: 24px;">Product Title</h2>
</div>
```

---

## CSS Guidelines

### BEM Naming Convention
Use Block__Element--Modifier pattern.

```css
/* Block */
.product-card { }

/* Element */
.product-card__image { }
.product-card__title { }
.product-card__price { }

/* Modifier */
.product-card--featured { }
.product-card__price--sale { }
```

#### BEM Examples

```html
<!-- Product card -->
<article class="product-card product-card--featured">
  <img class="product-card__image" src="product.jpg" alt="Product">
  <h2 class="product-card__title">Product Name</h2>
  <p class="product-card__price product-card__price--sale">$19.99</p>
  <button class="product-card__button">Add to Cart</button>
</article>

<!-- Navigation -->
<nav class="main-nav">
  <ul class="main-nav__list">
    <li class="main-nav__item main-nav__item--active">
      <a class="main-nav__link" href="/">Home</a>
    </li>
  </ul>
</nav>
```

### CSS Variables
Use custom properties for reusable values.

```css
:root {
  /* Colors */
  --color-primary: #007bff;
  --color-secondary: #6c757d;
  --color-text: #212529;
  --color-background: #ffffff;
  --color-border: #dee2e6;

  /* Typography */
  --font-primary: 'Inter', -apple-system, sans-serif;
  --font-size-base: 16px;
  --font-weight-normal: 400;
  --font-weight-bold: 700;
  --line-height-base: 1.5;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;

  /* Breakpoints */
  --breakpoint-mobile: 768px;
  --breakpoint-desktop: 1024px;
}

/* Use in components */
.product-card {
  background: var(--color-background);
  border: 1px solid var(--color-border);
  padding: var(--spacing-md);
  color: var(--color-text);
  font-family: var(--font-primary);
}
```

### Mobile-First Responsive Design
Start with mobile styles, enhance for larger screens.

```css
/* Mobile first (default) */
.product-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--spacing-md);
}

/* Tablet */
@media (min-width: 768px) {
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--spacing-lg);
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .product-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: var(--spacing-xl);
  }
}
```

### No Magic Numbers
Always use variables or commented values.

#### ✅ DO: Use Variables
```css
.header {
  padding: var(--spacing-md);
  max-width: 1200px; /* Container max-width */
}
```

#### ❌ DON'T: Magic Numbers
```css
.header {
  padding: 16px; /* Why 16? */
  max-width: 1200px; /* Why 1200? */
}
```

### Flexbox and Grid
Use modern layout techniques.

```css
/* Flexbox for one-dimensional layouts */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-md);
}

/* Grid for two-dimensional layouts */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: var(--spacing-lg);
}
```

### Performance
Optimize for rendering performance.

```css
/* Use transform for animations (GPU accelerated) */
.button {
  transition: transform 0.2s ease;
}

.button:hover {
  transform: translateY(-2px);
}

/* Avoid triggering layout recalculation */
/* ❌ Bad: changes layout */
.element {
  transition: width 0.3s;
}

/* ✅ Good: uses transform */
.element {
  transition: transform 0.3s;
}
```

---

## JavaScript Guidelines

### Vanilla JavaScript Preferred
Avoid jQuery and heavy libraries unless absolutely necessary.

#### ✅ DO: Modern JavaScript
```javascript
// Select elements
const buttons = document.querySelectorAll('.product-card__button');

// Event delegation
document.addEventListener('click', (e) => {
  if (e.target.matches('.product-card__button')) {
    handleAddToCart(e.target);
  }
});

// Fetch API
fetch('/cart/add.js', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ id: productId, quantity: 1 })
})
  .then(res => res.json())
  .then(data => updateCart(data));
```

#### ❌ DON'T: Use jQuery
```javascript
$('.product-card__button').click(function() {
  // jQuery is heavy and unnecessary
});
```

### Progressive Enhancement
Start with working HTML, enhance with JavaScript.

```javascript
// Form works without JS (submits normally)
<form action="/cart/add" method="post">
  <button type="submit">Add to Cart</button>
</form>

// Enhance with JS for better UX
document.querySelector('form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const formData = new FormData(e.target);

  try {
    const response = await fetch('/cart/add.js', {
      method: 'POST',
      body: formData
    });
    const data = await response.json();
    updateCartUI(data);
  } catch (error) {
    // Fallback: let form submit normally
    e.target.submit();
  }
});
```

### Event Delegation
For dynamic elements, use delegation on parent.

```javascript
// ✅ Good: One listener for all products
document.querySelector('.product-grid').addEventListener('click', (e) => {
  if (e.target.matches('.product-card__button')) {
    handleAddToCart(e.target.closest('.product-card'));
  }
});

// ❌ Bad: Listener on each product
document.querySelectorAll('.product-card__button').forEach(button => {
  button.addEventListener('click', handleAddToCart);
});
```

### No Global Variables
Use modules or IIFE to avoid polluting global scope.

```javascript
// ✅ Good: Module pattern
const ProductCard = (() => {
  const handleClick = (e) => {
    // private function
  };

  const init = () => {
    // public function
    document.addEventListener('click', handleClick);
  };

  return { init };
})();

ProductCard.init();

// ❌ Bad: Global variables
let productData = [];
function handleClick() { }
```

### Accessibility in JavaScript
Ensure keyboard and screen reader support.

```javascript
// Toggle element visibility
const toggleMenu = (button) => {
  const menu = document.getElementById(button.getAttribute('aria-controls'));
  const isExpanded = button.getAttribute('aria-expanded') === 'true';

  // Update ARIA
  button.setAttribute('aria-expanded', !isExpanded);

  // Update visibility
  menu.hidden = isExpanded;

  // Manage focus
  if (!isExpanded) {
    menu.querySelector('a').focus();
  }
};

// Keyboard support
element.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    handleClick(e.target);
  }
});
```

---

## File Organization

### Component Structure
Each component should have dedicated files.

```
product-card/
├── product-card.html       # HTML structure
├── product-card.css        # BEM styles
└── product-card.js         # (optional) Behavior
```

### CSS Organization
Structure CSS logically within each file.

```css
/* product-card.css */

/* 1. Block */
.product-card {
  /* Layout */
  display: flex;
  flex-direction: column;

  /* Box model */
  padding: var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: 8px;

  /* Visual */
  background: var(--color-background);
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);

  /* Typography */
  font-family: var(--font-primary);

  /* Misc */
  transition: box-shadow 0.2s ease;
}

/* 2. Elements */
.product-card__image { }
.product-card__title { }
.product-card__price { }
.product-card__button { }

/* 3. Modifiers */
.product-card--featured { }
.product-card__price--sale { }

/* 4. States */
.product-card:hover { }
.product-card__button:disabled { }

/* 5. Responsive */
@media (min-width: 768px) {
  .product-card { }
}
```

---

## Testing Checklist

### Visual Testing
- [ ] Component matches Figma design ≥98%
- [ ] All colors match exactly (use CSS variables)
- [ ] Spacing matches (±5px tolerance)
- [ ] Typography matches (font, size, weight, line-height)
- [ ] Layout structure correct (flexbox/grid)

### Responsive Testing
- [ ] Mobile (375px): Layout works, no horizontal scroll
- [ ] Tablet (768px): Layout adapts appropriately
- [ ] Desktop (1920px): Layout centered or full-width as designed
- [ ] Between breakpoints: No broken layouts

### Accessibility Testing
- [ ] Semantic HTML used
- [ ] Heading hierarchy correct (h1 → h2 → h3)
- [ ] All images have alt text
- [ ] All form inputs have labels
- [ ] Color contrast passes WCAG AA (4.5:1 text, 3:1 UI)
- [ ] Keyboard navigation works (tab through all interactive elements)
- [ ] Focus states visible
- [ ] Screen reader friendly (test with VoiceOver/NVDA)

### Browser Testing
- [ ] Chrome/Edge (Chromium)
- [ ] Safari (WebKit)
- [ ] Firefox (Gecko)

### Performance
- [ ] No layout shifts (CLS)
- [ ] Images lazy-loaded
- [ ] Minimal JavaScript
- [ ] No render-blocking resources
- [ ] CSS optimized (no unused styles)

---

## Common Patterns

### Card Component
```html
<article class="card">
  <img class="card__image" src="image.jpg" alt="Description" loading="lazy">
  <div class="card__content">
    <h2 class="card__title">Title</h2>
    <p class="card__description">Description text</p>
    <a href="/link" class="card__button">Learn More</a>
  </div>
</article>
```

### Navigation Menu
```html
<nav class="main-nav" aria-label="Main navigation">
  <ul class="main-nav__list">
    <li class="main-nav__item">
      <a class="main-nav__link" href="/" aria-current="page">Home</a>
    </li>
  </ul>
</nav>
```

### Form
```html
<form class="contact-form" action="/contact" method="post">
  <div class="form-group">
    <label class="form-group__label" for="name">Name</label>
    <input
      class="form-group__input"
      type="text"
      id="name"
      name="name"
      required
      aria-required="true"
    >
  </div>

  <button class="form__submit" type="submit">Submit</button>
</form>
```

---

## References

- MDN Web Docs: https://developer.mozilla.org/
- BEM Methodology: https://getbem.com/
- WCAG Guidelines: https://www.w3.org/WAI/WCAG21/quickref/
- CSS-Tricks: https://css-tricks.com/

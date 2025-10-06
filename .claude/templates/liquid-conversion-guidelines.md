# Shopify Liquid Conversion Guidelines

## Purpose
Convert working HTML/CSS/JS into Shopify Liquid theme files with proper object integration and dynamic content.

---

## Conversion Process

### Step 1: Choose File Type

**Section** (`theme/sections/*.liquid`)
- Full-width layout components
- Theme editor customizable
- Can be added/removed/reordered by merchants
- Examples: header, hero, featured-collection, footer

**Snippet** (`theme/snippets/*.liquid`)
- Reusable components
- Called by sections or other snippets
- Not directly customizable in theme editor
- Examples: product-card, icon, breadcrumbs

### Step 2: Convert Static to Dynamic

Replace hard-coded content with Liquid variables.

---

## Common Conversion Patterns

### Product Content

#### ❌ Static HTML
```html
<div class="product-card">
  <img src="product.jpg" alt="Blue T-Shirt">
  <h2>Blue Cotton T-Shirt</h2>
  <p class="price">$29.99</p>
  <button>Add to Cart</button>
</div>
```

#### ✅ Liquid Conversion
```liquid
<div class="product-card">
  <img
    src="{{ product.featured_image | img_url: 'large' }}"
    alt="{{ product.featured_image.alt | escape }}"
    loading="lazy"
  >
  <h2>{{ product.title }}</h2>
  <p class="price">
    {% if product.compare_at_price > product.price %}
      <span class="price--sale">{{ product.price | money }}</span>
      <span class="price--compare">{{ product.compare_at_price | money }}</span>
    {% else %}
      {{ product.price | money }}
    {% endif %}
  </p>
  <button
    type="button"
    onclick="addToCart({{ product.selected_or_first_available_variant.id }})"
  >
    {% if product.available %}
      Add to Cart
    {% else %}
      Sold Out
    {% endif %}
  </button>
</div>
```

### Collection Grid

#### ❌ Static HTML
```html
<div class="product-grid">
  <div class="product-card">Product 1</div>
  <div class="product-card">Product 2</div>
  <div class="product-card">Product 3</div>
</div>
```

#### ✅ Liquid Conversion
```liquid
<div class="product-grid">
  {% for product in collection.products %}
    {% render 'product-card', product: product %}
  {% else %}
    <p>No products found.</p>
  {% endfor %}
</div>
```

### Navigation Menu

#### ❌ Static HTML
```html
<nav>
  <a href="/products">Products</a>
  <a href="/about">About</a>
  <a href="/contact">Contact</a>
</nav>
```

#### ✅ Liquid Conversion
```liquid
<nav aria-label="Main navigation">
  {% for link in linklists.main-menu.links %}
    <a
      href="{{ link.url }}"
      {% if link.active %}aria-current="page"{% endif %}
    >
      {{ link.title }}
    </a>
  {% endfor %}
</nav>
```

### Hero Banner

#### ❌ Static HTML
```html
<section class="hero">
  <img src="hero.jpg" alt="Summer Sale">
  <h1>Summer Sale - 50% Off</h1>
  <a href="/collections/sale">Shop Now</a>
</section>
```

#### ✅ Liquid Conversion (with schema)
```liquid
<section class="hero">
  {% if section.settings.image %}
    <img
      src="{{ section.settings.image | img_url: '1920x' }}"
      alt="{{ section.settings.image.alt | escape }}"
      loading="lazy"
    >
  {% endif %}

  <h1>{{ section.settings.heading }}</h1>

  {% if section.settings.button_text %}
    <a href="{{ section.settings.button_link }}" class="button">
      {{ section.settings.button_text }}
    </a>
  {% endif %}
</section>

{% schema %}
{
  "name": "Hero Banner",
  "settings": [
    {
      "type": "image_picker",
      "id": "image",
      "label": "Background Image"
    },
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Welcome"
    },
    {
      "type": "text",
      "id": "button_text",
      "label": "Button Text",
      "default": "Shop Now"
    },
    {
      "type": "url",
      "id": "button_link",
      "label": "Button Link"
    }
  ],
  "presets": [
    {
      "name": "Hero Banner"
    }
  ]
}
{% endschema %}
```

---

## CSS Conversion

### Move to Stylesheet Block

#### ❌ Separate CSS File
```html
<!-- html/product-card.html -->
<link rel="stylesheet" href="css/product-card.css">
```

#### ✅ Liquid Stylesheet Block
```liquid
<!-- theme/snippets/product-card.liquid -->
<div class="product-card">
  <!-- HTML here -->
</div>

{% stylesheet %}
  .product-card {
    display: flex;
    flex-direction: column;
    padding: var(--spacing-md);
  }

  .product-card__image {
    width: 100%;
    aspect-ratio: 1/1;
    object-fit: cover;
  }
{% endstylesheet %}
```

### Or Use Theme Assets

```liquid
<!-- theme/sections/product-grid.liquid -->
{{ 'product-card.css' | asset_url | stylesheet_tag }}

<!-- File: theme/assets/product-card.css -->
```

---

## JavaScript Conversion

### Move to JavaScript Block

#### ❌ Separate JS File
```html
<script src="js/product-card.js"></script>
```

#### ✅ Liquid JavaScript Block
```liquid
<div class="product-card" data-product-id="{{ product.id }}">
  <button class="add-to-cart">Add to Cart</button>
</div>

{% javascript %}
  document.querySelectorAll('.add-to-cart').forEach(button => {
    button.addEventListener('click', async (e) => {
      const card = e.target.closest('.product-card');
      const productId = card.dataset.productId;

      const response = await fetch('/cart/add.js', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          id: productId,
          quantity: 1
        })
      });

      if (response.ok) {
        updateCartCount();
      }
    });
  });
{% endjavascript %}
```

---

## Section Schema

### Schema Types

#### Text Input
```json
{
  "type": "text",
  "id": "heading",
  "label": "Heading",
  "default": "Default Heading"
}
```

#### Textarea
```json
{
  "type": "textarea",
  "id": "description",
  "label": "Description"
}
```

#### Rich Text
```json
{
  "type": "richtext",
  "id": "content",
  "label": "Content"
}
```

#### Image Picker
```json
{
  "type": "image_picker",
  "id": "image",
  "label": "Image"
}
```

#### URL
```json
{
  "type": "url",
  "id": "link",
  "label": "Link"
}
```

#### Color
```json
{
  "type": "color",
  "id": "background_color",
  "label": "Background Color",
  "default": "#ffffff"
}
```

#### Select Dropdown
```json
{
  "type": "select",
  "id": "layout",
  "label": "Layout",
  "options": [
    { "value": "grid", "label": "Grid" },
    { "value": "list", "label": "List" }
  ],
  "default": "grid"
}
```

#### Range Slider
```json
{
  "type": "range",
  "id": "columns",
  "label": "Columns",
  "min": 2,
  "max": 6,
  "step": 1,
  "default": 4
}
```

#### Checkbox
```json
{
  "type": "checkbox",
  "id": "show_vendor",
  "label": "Show vendor",
  "default": true
}
```

### Complete Section Example

```liquid
<!-- theme/sections/featured-collection.liquid -->
<section class="featured-collection">
  <div class="container">
    {% if section.settings.heading %}
      <h2>{{ section.settings.heading }}</h2>
    {% endif %}

    <div class="product-grid product-grid--{{ section.settings.columns }}-col">
      {% assign collection = collections[section.settings.collection] %}

      {% for product in collection.products limit: section.settings.products_to_show %}
        {% render 'product-card', product: product %}
      {% endfor %}
    </div>

    {% if section.settings.show_view_all %}
      <a href="{{ collection.url }}" class="button">
        {{ section.settings.button_text }}
      </a>
    {% endif %}
  </div>
</section>

{% schema %}
{
  "name": "Featured Collection",
  "settings": [
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Featured Products"
    },
    {
      "type": "collection",
      "id": "collection",
      "label": "Collection"
    },
    {
      "type": "range",
      "id": "products_to_show",
      "label": "Products to show",
      "min": 2,
      "max": 12,
      "step": 1,
      "default": 4
    },
    {
      "type": "range",
      "id": "columns",
      "label": "Columns",
      "min": 2,
      "max": 6,
      "step": 1,
      "default": 4
    },
    {
      "type": "checkbox",
      "id": "show_view_all",
      "label": "Show 'View All' button",
      "default": true
    },
    {
      "type": "text",
      "id": "button_text",
      "label": "Button text",
      "default": "View All"
    }
  ],
  "presets": [
    {
      "name": "Featured Collection"
    }
  ]
}
{% endschema %}
```

---

## Shopify Objects Reference

### Product Object
```liquid
{{ product.title }}
{{ product.description }}
{{ product.price | money }}
{{ product.compare_at_price | money }}
{{ product.vendor }}
{{ product.type }}
{{ product.available }}
{{ product.featured_image | img_url: 'large' }}
{{ product.url }}
{{ product.id }}

{% for image in product.images %}
  <img src="{{ image | img_url: 'large' }}" alt="{{ image.alt }}">
{% endfor %}

{% for variant in product.variants %}
  {{ variant.title }}
  {{ variant.price | money }}
  {{ variant.available }}
{% endfor %}
```

### Collection Object
```liquid
{{ collection.title }}
{{ collection.description }}
{{ collection.image | img_url: 'large' }}
{{ collection.products_count }}
{{ collection.url }}

{% for product in collection.products %}
  {{ product.title }}
{% endfor %}
```

### Cart Object
```liquid
{{ cart.item_count }}
{{ cart.total_price | money }}

{% for item in cart.items %}
  {{ item.product.title }}
  {{ item.quantity }}
  {{ item.line_price | money }}
{% endfor %}
```

### Shop Object
```liquid
{{ shop.name }}
{{ shop.email }}
{{ shop.domain }}
{{ shop.currency }}
```

### Customer Object
```liquid
{% if customer %}
  {{ customer.name }}
  {{ customer.email }}
  {{ customer.orders_count }}
{% else %}
  <a href="/account/login">Login</a>
{% endif %}
```

---

## Common Liquid Filters

### Money
```liquid
{{ 2999 | money }}  <!-- $29.99 -->
```

### Image URL
```liquid
{{ product.featured_image | img_url: 'large' }}
{{ product.featured_image | img_url: '1920x' }}  <!-- width -->
{{ product.featured_image | img_url: 'x1080' }}  <!-- height -->
{{ product.featured_image | img_url: '500x500', crop: 'center' }}
```

### Escape
```liquid
{{ product.title | escape }}  <!-- Escape HTML -->
```

### Truncate
```liquid
{{ product.description | strip_html | truncate: 100 }}
```

### Default
```liquid
{{ section.settings.heading | default: 'Default Heading' }}
```

### URL Filters
```liquid
{{ 'image.jpg' | asset_url }}
{{ 'style.css' | asset_url | stylesheet_tag }}
{{ 'script.js' | asset_url | script_tag }}
```

---

## Validation Checklist

### Before Converting
- [ ] HTML implementation complete and tested
- [ ] All Playwright tests passing
- [ ] Visual validation ≥98%
- [ ] No hard-coded content that should be dynamic
- [ ] CSS uses variables (easy to convert to Liquid settings)

### During Conversion
- [ ] Identify all dynamic content (product info, collection data, etc)
- [ ] Choose appropriate Shopify objects
- [ ] Add section schema for customizable content
- [ ] Move CSS to {% stylesheet %} or assets/
- [ ] Move JS to {% javascript %} or assets/
- [ ] Use Liquid filters appropriately (money, img_url, escape)

### After Conversion
- [ ] Liquid syntax validates (no errors)
- [ ] Preview in Shopify dev server
- [ ] All settings in schema work correctly
- [ ] Dynamic content renders properly
- [ ] Images load from Shopify CDN
- [ ] Forms submit to correct endpoints
- [ ] No JavaScript errors
- [ ] Visual output matches HTML version

---

## File Naming Conventions

### Sections
- kebab-case
- Descriptive names
- Examples: `hero-banner.liquid`, `featured-collection.liquid`, `product-recommendations.liquid`

### Snippets
- kebab-case
- Component-focused names
- Examples: `product-card.liquid`, `icon.liquid`, `breadcrumbs.liquid`

### Assets
- kebab-case
- Match section/snippet name
- Examples: `product-card.css`, `hero-banner.js`

---

## Common Pitfalls

### ❌ Don't use HTML entities in Liquid
```liquid
<!-- Bad -->
<h1>{{ product.title | escape }}</h1> &rarr; More

<!-- Good -->
<h1>{{ product.title | escape }}</h1> → More
```

### ❌ Don't forget to escape user content
```liquid
<!-- Bad: XSS risk -->
<h1>{{ product.title }}</h1>

<!-- Good -->
<h1>{{ product.title | escape }}</h1>
```

### ❌ Don't use complex logic in templates
```liquid
<!-- Bad: Too complex -->
{% assign filtered = products | where: "available", true | where: "price", < 5000 %}

<!-- Good: Use metafields or collections -->
{% for product in collection.products %}
  {% if product.available %}
    {{ product.title }}
  {% endif %}
{% endfor %}
```

### ❌ Don't hard-code URLs
```liquid
<!-- Bad -->
<a href="/collections/all">Shop</a>

<!-- Good -->
<a href="{{ routes.all_products_collection_url }}">Shop</a>
```

---

## Testing in Shopify

### Start Dev Server
```bash
shopify theme dev
```

### Preview URL
```
http://127.0.0.1:9292
```

### Test Checklist
- [ ] Section appears in theme editor
- [ ] All settings work
- [ ] Dynamic content renders
- [ ] Styling matches HTML version
- [ ] JavaScript functionality works
- [ ] Forms submit correctly
- [ ] No console errors
- [ ] Mobile responsive
- [ ] Fast load time

---

## References

- Shopify Liquid: https://shopify.dev/docs/api/liquid
- Liquid Objects: https://shopify.dev/docs/api/liquid/objects
- Liquid Filters: https://shopify.dev/docs/api/liquid/filters
- Theme Architecture: https://shopify.dev/docs/themes/architecture
- Section Schema: https://shopify.dev/docs/themes/architecture/sections/section-schema

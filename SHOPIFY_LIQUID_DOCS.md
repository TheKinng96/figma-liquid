# Shopify Liquid Documentation Summary

## Overview
Liquid is a template language created by Shopify for dynamic content rendering in themes. It extends the open-source Liquid template engine with Shopify-specific objects, tags, and filters for e-commerce functionality.

## Core Syntax

### Basic Structure
- **Objects**: `{{ product.title }}` - Output dynamic content
- **Tags**: `{% if condition %}` - Control logic and flow
- **Filters**: `{{ product.title | upcase }}` - Transform output

### Key Principles
- Server-side rendering (SSR) is primary method
- Use semantic HTML structure
- Follow BEM naming conventions for CSS

## Essential Liquid Tags

### Assignment & Variables
```liquid
{% assign my_variable = 'Hello' %}
{% assign computed = 10 | plus: 5 %}
```

### Control Flow
```liquid
{% if product.available %}
  Available!
{% else %}
  Sold out
{% endif %}

{% for product in collections.all.products %}
  {{ product.title }}
{% endfor %}

{% case product.type %}
  {% when 'clothing' %}
    Fashion item
  {% when 'electronics' %}
    Tech product
{% endcase %}
```

### Loops with Ranges
```liquid
{% for i in (1..5) %}
  Item {{ i }}
{% endfor %}
```

### Content Blocks
```liquid
{% capture my_content %}
  This text will be captured.
{% endcapture %}

{% comment %}
  This is a comment block
{% endcomment %}

{% raw %}
  {{ handlebars_syntax }} won't be processed
{% endraw %}
```

### Advanced Tags
```liquid
{% liquid
  assign my_var = 'Hello'
  echo my_var
%}

{% break %}    <!-- Exit loop -->
{% continue %} <!-- Skip iteration -->
```

## Common Filters

### String Manipulation
```liquid
{{ 'hello' | capitalize }}        <!-- Hello -->
{{ 'HELLO' | downcase }}          <!-- hello -->
{{ 'hello' | upcase }}            <!-- HELLO -->
{{ 'hello world' | replace: 'world', 'there' }} <!-- hello there -->
{{ 'hello' | append: ' world' }}  <!-- hello world -->
{{ 'hello world' | truncate: 8 }} <!-- hello... -->
```

### Number Operations
```liquid
{{ 4.6 | ceil }}           <!-- 5 -->
{{ 4.6 | floor }}          <!-- 4 -->
{{ 4 | plus: 2 }}          <!-- 6 -->
{{ 10 | minus: 3 }}        <!-- 7 -->
{{ 5 | times: 4 }}         <!-- 20 -->
{{ 10 | divided_by: 3 }}   <!-- 3 -->
{{ 7 | modulo: 3 }}        <!-- 1 -->
```

### Array Operations
```liquid
{{ products | first }}                    <!-- First item -->
{{ products | last }}                     <!-- Last item -->
{{ products | size }}                     <!-- Array length -->
{{ products | reverse }}                  <!-- Reverse order -->
{{ products | sort: 'title' }}            <!-- Sort by property -->
{{ products | map: 'title' }}             <!-- Extract property -->
{{ categories | uniq }}                   <!-- Remove duplicates -->
{{ products | join: ', ' }}               <!-- Join with separator -->
```

### Utility Filters
```liquid
{{ undefined_var | default: 'fallback' }} <!-- Default value -->
{{ product.description | strip_html }}    <!-- Remove HTML -->
{{ text | newline_to_br }}                <!-- Convert \n to <br> -->
{{ url_string | url_encode }}             <!-- URL encoding -->
```

## Theme Architecture

### Folder Structure
```
theme/
├── sections/          # Theme sections (.liquid)
├── blocks/            # Section blocks
├── layout/            # Layout templates
├── snippets/          # Reusable code snippets
├── templates/         # Page templates
├── config/            # Theme settings
├── assets/            # CSS, JS, images
└── locales/           # Translation files
```

### Common Shopify Objects

#### Product Objects
```liquid
{{ product.title }}
{{ product.description }}
{{ product.price }}
{{ product.available }}
{{ product.variants }}
{{ product.images }}
{{ product.vendor }}
{{ product.type }}
{{ product.tags }}
```

#### Collection Objects
```liquid
{{ collection.title }}
{{ collection.description }}
{{ collection.products }}
{{ collection.url }}
```

#### Shop Objects
```liquid
{{ shop.name }}
{{ shop.email }}
{{ shop.address1 }}
{{ shop.city }}
{{ shop.province }}
{{ shop.country }}
```

#### Cart Objects
```liquid
{{ cart.total_price }}
{{ cart.item_count }}
{{ cart.items }}
```

## CSS Guidelines for Shopify Themes

### Specificity Rules
- Use single class selectors (0,1,0 specificity)
- Avoid IDs, element selectors, and !important
- Maximum 0,4,0 specificity for parent/child relationships

### BEM Naming Convention
```css
.block {}
.block__element {}
.block--modifier {}
.block__element--modifier {}
```

### CSS Variables
```css
:root {
  --touch-target-size: 45px;
  --primary-color: #000;
}

.component {
  --local-variable: var(--global-variable);
}
```

### Styling Structure
```liquid
{% stylesheet %}
  .product-card {
    padding: var(--spacing-medium);
  }

  .product-card__title {
    font-size: var(--font-size-large);
  }
{% endstylesheet %}
```

### Media Queries
```css
/* Mobile first approach */
@media screen and (min-width: 768px) {
  .component {
    display: flex;
  }
}
```

## Component Patterns for Figma Conversion

### Product Card Component
```liquid
{% comment %} figma-component: product-card {% endcomment %}
<div class="product-card">
  <div class="product-card__image">
    <img src="{{ product.featured_image | img_url: '300x300' }}"
         alt="{{ product.title }}">
  </div>
  <div class="product-card__content">
    <h3 class="product-card__title">{{ product.title }}</h3>
    <p class="product-card__price">{{ product.price | money }}</p>
  </div>
</div>
```

### Carousel/Slider Component
```liquid
{% comment %} figma-component: carousel {% endcomment %}
<div class="carousel" data-component="carousel">
  <div class="carousel__track">
    {% for product in collection.products limit: 6 %}
      <div class="carousel__slide">
        {% render 'product-card', product: product %}
      </div>
    {% endfor %}
  </div>
  <button class="carousel__nav carousel__nav--prev">Previous</button>
  <button class="carousel__nav carousel__nav--next">Next</button>
</div>
```

### Header Component
```liquid
{% comment %} figma-component: header {% endcomment %}
<header class="site-header">
  <div class="site-header__container">
    <div class="site-header__logo">
      <a href="/" class="logo">{{ shop.name }}</a>
    </div>
    <nav class="site-header__nav">
      {% for link in linklists.main-menu.links %}
        <a href="{{ link.url }}" class="nav-link">{{ link.title }}</a>
      {% endfor %}
    </nav>
  </div>
</header>
```

## Theme Settings Integration

### Section Settings
```json
{
  "name": "Featured Collection",
  "settings": [
    {
      "type": "collection",
      "id": "collection",
      "label": "Collection"
    },
    {
      "type": "range",
      "id": "products_to_show",
      "min": 2,
      "max": 12,
      "step": 2,
      "default": 6,
      "label": "Products to show"
    }
  ]
}
```

### Using Settings in Liquid
```liquid
{% assign collection = sections.settings.collection %}
{% assign limit = section.settings.products_to_show %}

{% for product in collection.products limit: limit %}
  <!-- Product display -->
{% endfor %}
```

## Best Practices for Figma-to-Liquid Conversion

### Component Identification
1. **Naming Conventions**: Use descriptive layer names in Figma
   - `header-main`, `carousel-products`, `footer-links`
   - `product-card`, `collection-grid`, `hero-banner`

2. **Figma Annotations**: Add component metadata in descriptions
   - `liquid-component: carousel`
   - `liquid-section: featured-collection`

3. **Layout Detection**: Analyze patterns for automatic detection
   - Horizontal scrolling → carousel
   - Repeated card layouts → product grids
   - Top positioning → headers/navigation

### Conversion Mapping
```javascript
// Example mapping for conversion
const componentMap = {
  'header': 'sections/header.liquid',
  'carousel': 'sections/featured-collection.liquid',
  'product-card': 'snippets/product-card.liquid',
  'footer': 'sections/footer.liquid'
};
```

### Template Structure
```liquid
<!-- Section wrapper -->
<div class="section section--{{ section.id }}">
  <div class="container">
    <!-- Section content -->
    {% if section.settings.heading != blank %}
      <h2 class="section__heading">{{ section.settings.heading }}</h2>
    {% endif %}

    <!-- Dynamic content based on component type -->
    {% render 'component-content', section: section %}
  </div>
</div>

{% schema %}
{
  "name": "Section Name",
  "settings": [
    // Section settings
  ]
}
{% endschema %}
```

This documentation provides the foundation for converting Figma designs to functional Shopify Liquid themes, with patterns and conventions that support automated conversion tools.
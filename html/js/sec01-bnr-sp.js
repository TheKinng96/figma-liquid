/**
 * sec01-bnr-sp Component JavaScript
 * Spring Sale Banner - Interactive Functionality
 *
 * This component is primarily static, but includes:
 * - Click tracking for analytics
 * - Accessibility enhancements
 */

(function() {
  'use strict';

  // Wait for DOM to be ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  function init() {
    const banner = document.querySelector('.sec01-bnr-sp');

    if (!banner) {
      console.warn('sec01-bnr-sp: Component not found');
      return;
    }

    // Make banner clickable if needed (can be wrapped in <a> tag in production)
    banner.setAttribute('role', 'banner');
    banner.setAttribute('tabindex', '0');

    // Add click handler for analytics tracking
    banner.addEventListener('click', handleBannerClick);

    // Keyboard accessibility
    banner.addEventListener('keydown', handleKeydown);

    // Log component initialization
    console.log('sec01-bnr-sp: Component initialized');
  }

  /**
   * Handle banner click for analytics
   */
  function handleBannerClick(event) {
    // Track analytics event (placeholder for actual analytics)
    if (window.dataLayer) {
      window.dataLayer.push({
        event: 'banner_click',
        banner_name: 'spring_sale_2025',
        banner_location: 'sec01_bnr_sp'
      });
    }

    console.log('sec01-bnr-sp: Banner clicked');
  }

  /**
   * Handle keyboard navigation
   */
  function handleKeydown(event) {
    // Allow Enter or Space to trigger click
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      event.currentTarget.click();
    }
  }

})();

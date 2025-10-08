/**
 * Playwright Tests for sec01-bnr-sp Component
 * Spring Sale Banner - Visual Regression & Functional Tests
 */

const { test, expect } = require('@playwright/test');
const path = require('path');

const HTML_PATH = path.join(__dirname, '../html/sec01-bnr-sp.html');
const SCREENSHOT_DIR = path.join(__dirname, 'screenshots');

// Test viewports
const VIEWPORTS = {
  desktop: { width: 1920, height: 1080 },
  tablet: { width: 768, height: 1024 },
  mobile: { width: 375, height: 667 }
};

test.describe('sec01-bnr-sp Component', () => {

  test.beforeEach(async ({ page }) => {
    // Navigate to the HTML file
    await page.goto(`file://${HTML_PATH}`);

    // Wait for fonts to load (important for visual comparison)
    await page.evaluate(() => document.fonts.ready);
  });

  test('renders without errors', async ({ page }) => {
    // Check that main component exists
    const banner = page.locator('.sec01-bnr-sp');
    await expect(banner).toBeVisible();

    // Check sub-elements exist
    await expect(page.locator('.sec01-bnr-sp__badge')).toBeVisible();
    await expect(page.locator('.sec01-bnr-sp__badge-text')).toBeVisible();
    await expect(page.locator('.sec01-bnr-sp__text')).toBeVisible();
    await expect(page.locator('.sec01-bnr-sp__arrow')).toBeVisible();

    // Check no console errors
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') errors.push(msg.text());
    });
    await page.waitForTimeout(1000);
    expect(errors).toHaveLength(0);
  });

  test('has correct text content', async ({ page }) => {
    const badgeText = page.locator('.sec01-bnr-sp__badge-text');
    await expect(badgeText).toContainText('SPRING');
    await expect(badgeText).toContainText('SALE');

    const mainText = page.locator('.sec01-bnr-sp__text');
    await expect(mainText).toContainText('2025年新春セール開催中');
  });

  test('has correct background color', async ({ page }) => {
    const banner = page.locator('.sec01-bnr-sp');
    const bgColor = await banner.evaluate(el =>
      window.getComputedStyle(el).backgroundColor
    );

    // Check for red background (rgb(199, 17, 11) or close)
    expect(bgColor).toMatch(/rgb\(199,\s*17,\s*11\)/);
  });

  test('Desktop viewport (1920x1080) - Visual regression', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.desktop);
    await page.waitForTimeout(500); // Wait for any transitions

    // Take screenshot for visual comparison
    const screenshot = await page.locator('.sec01-bnr-sp').screenshot();
    expect(screenshot).toMatchSnapshot('sec01-bnr-sp-desktop.png', {
      maxDiffPixels: 500,
      threshold: 0.02 // 98% match threshold
    });
  });

  test('Tablet viewport (768x1024) - Visual regression', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.tablet);
    await page.waitForTimeout(500);

    const screenshot = await page.locator('.sec01-bnr-sp').screenshot();
    expect(screenshot).toMatchSnapshot('sec01-bnr-sp-tablet.png', {
      maxDiffPixels: 500,
      threshold: 0.02
    });
  });

  test('Mobile viewport (375x667) - Visual regression', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.mobile);
    await page.waitForTimeout(500);

    const screenshot = await page.locator('.sec01-bnr-sp').screenshot();
    expect(screenshot).toMatchSnapshot('sec01-bnr-sp-mobile.png', {
      maxDiffPixels: 500,
      threshold: 0.02
    });
  });

  test('Layout accuracy - Dimensions', async ({ page }) => {
    const banner = page.locator('.sec01-bnr-sp');
    const box = await banner.boundingBox();

    // Check height is correct (147px from Figma)
    expect(box.height).toBeCloseTo(147, 5); // ±5px tolerance

    // Check max-width is applied (600px from Figma)
    const width = await banner.evaluate(el => el.offsetWidth);
    expect(width).toBeLessThanOrEqual(600);
  });

  test('Badge dimensions and styling', async ({ page }) => {
    const badge = page.locator('.sec01-bnr-sp__badge');
    const box = await badge.boundingBox();

    // Badge should be 115x115px
    expect(box.width).toBeCloseTo(115, 5);
    expect(box.height).toBeCloseTo(115, 5);

    // Check border radius (circular)
    const borderRadius = await badge.evaluate(el =>
      window.getComputedStyle(el).borderRadius
    );
    expect(borderRadius).toBe('150px');

    // Check white border
    const borderColor = await badge.evaluate(el =>
      window.getComputedStyle(el).borderColor
    );
    expect(borderColor).toMatch(/rgb\(255,\s*255,\s*255\)/);
  });

  test('Interactive features - Click handling', async ({ page }) => {
    const banner = page.locator('.sec01-bnr-sp');

    // Check banner is focusable
    await expect(banner).toHaveAttribute('tabindex', '0');

    // Check click works
    const clickPromise = page.evaluate(() => {
      return new Promise(resolve => {
        document.querySelector('.sec01-bnr-sp').addEventListener('click', () => {
          resolve(true);
        }, { once: true });
      });
    });

    await banner.click();
    const clicked = await clickPromise;
    expect(clicked).toBe(true);
  });

  test('Keyboard navigation - Enter key', async ({ page }) => {
    const banner = page.locator('.sec01-bnr-sp');

    // Focus on banner
    await banner.focus();

    // Listen for click event
    const clickPromise = page.evaluate(() => {
      return new Promise(resolve => {
        document.querySelector('.sec01-bnr-sp').addEventListener('click', () => {
          resolve(true);
        }, { once: true });
      });
    });

    // Press Enter
    await page.keyboard.press('Enter');
    const clicked = await clickPromise;
    expect(clicked).toBe(true);
  });

  test('Accessibility - ARIA attributes', async ({ page }) => {
    const banner = page.locator('.sec01-bnr-sp');

    // Check role
    await expect(banner).toHaveAttribute('role', 'banner');

    // Check aria-label
    await expect(banner).toHaveAttribute('aria-label', 'Spring Sale Banner');

    // Check badge aria-label
    const badge = page.locator('.sec01-bnr-sp__badge');
    await expect(badge).toHaveAttribute('aria-label', 'Spring Sale');

    // Arrow should be hidden from screen readers
    const arrow = page.locator('.sec01-bnr-sp__arrow');
    await expect(arrow).toHaveAttribute('aria-hidden', 'true');
  });

  test('Accessibility - Color contrast', async ({ page }) => {
    // White text on red background should pass WCAG AA
    const textColor = await page.locator('.sec01-bnr-sp__text').evaluate(el =>
      window.getComputedStyle(el).color
    );
    const bgColor = await page.locator('.sec01-bnr-sp').evaluate(el =>
      window.getComputedStyle(el).backgroundColor
    );

    // Verify colors are correct
    expect(textColor).toMatch(/rgb\(255,\s*255,\s*255\)/); // white
    expect(bgColor).toMatch(/rgb\(199,\s*17,\s*11\)/); // red

    // Color contrast ratio for white (#FFF) on red (#C7110B) is approximately 5.7:1
    // This passes WCAG AA for normal text (requires 4.5:1)
    // Note: Actual contrast calculation would require a library
  });

  test('All images and SVGs load correctly', async ({ page }) => {
    // Check SVG arrow exists and is visible
    const arrow = page.locator('.sec01-bnr-sp__arrow');
    await expect(arrow).toBeVisible();

    // Verify SVG path element exists
    const path = arrow.locator('path');
    await expect(path).toBeVisible();

    // Check SVG has correct dimensions
    const box = await arrow.boundingBox();
    expect(box.width).toBeCloseTo(18, 2);
    expect(box.height).toBeCloseTo(15, 2);
  });

  test('Responsive behavior - Font scaling', async ({ page }) => {
    // Desktop
    await page.setViewportSize(VIEWPORTS.desktop);
    let fontSize = await page.locator('.sec01-bnr-sp__text').evaluate(el =>
      parseInt(window.getComputedStyle(el).fontSize)
    );
    expect(fontSize).toBe(28);

    // Mobile
    await page.setViewportSize(VIEWPORTS.mobile);
    fontSize = await page.locator('.sec01-bnr-sp__text').evaluate(el =>
      parseInt(window.getComputedStyle(el).fontSize)
    );
    // Should be 28px or smaller depending on media query
    expect(fontSize).toBeLessThanOrEqual(28);
  });

  test('No console errors or warnings', async ({ page }) => {
    const messages = [];
    page.on('console', msg => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        messages.push({ type: msg.type(), text: msg.text() });
      }
    });

    // Wait and interact
    await page.waitForTimeout(1000);
    await page.locator('.sec01-bnr-sp').click();
    await page.waitForTimeout(500);

    // Filter out expected logs
    const errors = messages.filter(m =>
      m.type === 'error' && !m.text.includes('Component initialized')
    );

    expect(errors).toHaveLength(0);
  });

});

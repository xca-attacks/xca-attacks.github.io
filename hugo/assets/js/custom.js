// Put your custom JS code here

(function() {
  let lastTheme = document.documentElement.getAttribute('data-bs-theme');

  function syncVideos(fromTheme, toTheme) {
    // Determine which video was likely visible
    // In this site, light is the default if not dark.
    const wasDark = fromTheme === 'dark';
    const isDark = toTheme === 'dark';

    if (wasDark === isDark) return;

    document.querySelectorAll('.theme-video').forEach(container => {
      const light = container.querySelector('.video-light');
      const dark = container.querySelector('.video-dark');
      
      if (light && dark) {
        try {
          if (isDark) {
            // Switching to dark, sync from light
            dark.currentTime = light.currentTime;
            if (light.paused) dark.pause(); else dark.play();
          } else {
            // Switching to light, sync from dark
            light.currentTime = dark.currentTime;
            if (dark.paused) light.pause(); else light.play();
          }
        } catch (e) {
          console.error("Failed to sync video progress:", e);
        }
      }
    });
  }

  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.attributeName === 'data-bs-theme') {
        const newTheme = document.documentElement.getAttribute('data-bs-theme');
        syncVideos(lastTheme, newTheme);
        lastTheme = newTheme;
      }
    });
  });

  observer.observe(document.documentElement, { attributes: true });

  // --- Robust TOC Highlighting ---
  function initTocObserver() {
    const tocLinks = document.querySelectorAll('#toc a');
    const headings = Array.from(document.querySelectorAll('.docs-content h2[id], .docs-content h3[id], .docs-content h4[id], .docs-content h5[id], .docs-content h6[id]'));
    
    if (tocLinks.length === 0 || headings.length === 0) return;

    // Use a custom scroll listener to determine the "active" heading
    // because Bootstrap's ScrollSpy often loses track in large gaps (figures).
    function updateActiveHeading() {
      const scrollPos = window.scrollY + 120; // Offset for navbar + buffer
      let activeId = null;

      // Find the heading that is closest to the top but above the scroll position
      for (let i = headings.length - 1; i >= 0; i--) {
        if (headings[i].offsetTop <= scrollPos) {
          activeId = headings[i].getAttribute('id');
          break;
        }
      }

      if (activeId) {
        tocLinks.forEach(link => {
          const href = link.getAttribute('href');
          if (href === '#' + activeId || href === activeId) {
            link.classList.add('active');
            // Ensure parent elements (like .nav-link) are also handled if needed
            let parent = link.parentElement;
            while (parent && parent !== tocContainer) {
               if (parent.tagName === 'LI') {
                 // Doks might use specific classes
               }
               parent = parent.parentElement;
            }
          } else {
            link.classList.remove('active');
          }
        });
      }
    }

    const tocContainer = document.querySelector('#toc');
    window.addEventListener('scroll', updateActiveHeading, { passive: true });
    // Run once on init
    setTimeout(updateActiveHeading, 100);
  }

  // Initialize after content is likely loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initTocObserver);
  } else {
    initTocObserver();
  }
})();

// Counts visits on benbirt.io with PostHog, without cookies. posthog.js is
// imported lazily so it is not fetched when a visit will not be counted.

const mayCount =
  location.hostname === "benbirt.io" &&
  !navigator.webdriver &&
  navigator.doNotTrack !== "1" &&
  navigator.globalPrivacyControl !== true;

if (mayCount) {
  try {
    const { default: posthog } = await import(new URL("posthog.js", import.meta.url).href);
    // Public project token: it can only send events. The project is shared
    // with eavesbard.com and tlog.benbirt.io, told apart by host.
    posthog.init("phc_CsD5BihrYmNJRWUcFcugc5npamyPnW8666Y4bVGeYYDw", {
      api_host: "https://eu.i.posthog.com",
      // Stores nothing in the browser: PostHog's servers count daily visitors
      // from a hash of IP address and user agent with a salt discarded each
      // day. Requires "Cookieless server hash mode" in the PostHog project.
      cookieless_mode: "always",
      person_profiles: "never",
      // Only the page view below: nothing automatic.
      autocapture: false,
      capture_pageview: false,
      capture_pageleave: false,
      rageclick: false,
      capture_dead_clicks: false,
      capture_heatmaps: false,
      capture_performance: false,
      capture_exceptions: false,
      disable_session_recording: true,
      disable_surveys: true,
      disable_product_tours: true,
      disable_conversations: true,
      disable_web_experiments: true,
      advanced_disable_flags: true,
      // No scripts from PostHog's servers.
      disable_external_dependency_loading: true,
      mask_personal_data_properties: true,
    });
    posthog.capture("$pageview");
  } catch {
    // Blocked or offline: count nothing.
  }
}

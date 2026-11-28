# PostHog dashboards for benbirt.io and tlog.benbirt.io, so that they are
# reviewed and changed here and not in PostHog's UI. Both sites send to one
# PostHog project, shared with eavesbard.com, whose dashboard is in
# github.com/benbirt/eavesbard. Every insight filters on $host, so each
# dashboard shows one site only.
#
# Both sites use PostHog's cookieless mode, so unique visitors are known per
# day only: PostHog cannot count unique visitors across a week or month.

provider "posthog" {
  host       = "https://eu.posthog.com"
  project_id = "306168"
}

locals {
  # Tile positions use PostHog's 12-column grid. Map keys name the resources, so
  # renaming one replaces its dashboard or insight.
  posthog_dashboards = {
    site = {
      name        = "benbirt.io visits"
      description = "Visits to benbirt.io."
      host        = "benbirt.io"
      insights = {
        visitors = {
          name        = "Visitors per day"
          description = "Unique visitors each day. Cookieless, so visitors can't be told apart across days: don't add days up."
          tile        = { x = 0, y = 0, w = 12, h = 5 }
          series      = [{ event = "$pageview", math = "dau" }]
          interval    = "day"
        }
        pages = {
          name        = "Page views, by page"
          description = "Page views in the last 90 days, by path."
          tile        = { x = 0, y = 5, w = 6, h = 6 }
          series      = [{ event = "$pageview", math = "total" }]
          breakdown   = "$pathname"
          bars        = true
        }
        referrers = {
          name        = "Page views, by referrer"
          description = "Page views in the last 90 days, by the site that linked here ($direct: none)."
          tile        = { x = 6, y = 5, w = 6, h = 6 }
          series      = [{ event = "$pageview", math = "total" }]
          breakdown   = "$referring_domain"
          bars        = true
        }
      }
    }
    tlog = {
      name        = "tlog-viewer usage"
      description = "How tlog.benbirt.io is used. Its events are listed in github.com/benbirt/tlog-viewer (web/js/analytics_events.ts)."
      host        = "tlog.benbirt.io"
      insights = {
        visitors = {
          name        = "Visitors per day"
          description = "Unique visitors each day. Cookieless, so visitors can't be told apart across days: don't add days up."
          tile        = { x = 0, y = 0, w = 6, h = 5 }
          series      = [{ event = "$pageview", math = "dau" }]
          interval    = "day"
        }
        referrers = {
          name        = "Page views, by referrer"
          description = "Page views in the last 90 days, by the site that linked here ($direct: none)."
          tile        = { x = 6, y = 0, w = 6, h = 5 }
          series      = [{ event = "$pageview", math = "total" }]
          breakdown   = "$referring_domain"
          bars        = true
        }
        logs = {
          name        = "Logs checked, by log"
          description = "Times a log finished loading each week, by log. Loads under a simulated failure are left out."
          tile        = { x = 0, y = 5, w = 6, h = 5 }
          series      = [{ event = "log_checked", math = "total" }]
          breakdown   = "log"
          interval    = "week"
          real_only   = true
        }
        actions = {
          name        = "Entries opened and proofs downloaded"
          description = "Entry drawers opened and tlog-proofs downloaded, each week."
          tile        = { x = 6, y = 5, w = 6, h = 5 }
          series = [
            { event = "entry_opened", math = "total" },
            { event = "proof_downloaded", math = "total" },
          ]
          interval = "week"
        }
        log_signature = {
          name        = "Log signature"
          description = "How the log signature step ended, last 90 days, simulated failures left out."
          tile        = { x = 0, y = 10, w = 3, h = 5 }
          series      = [{ event = "log_checked", math = "total" }]
          breakdown   = "log_signature"
          bars        = true
          real_only   = true
        }
        witness_quorum = {
          name        = "Witness quorum"
          description = "How the witness quorum step ended, last 90 days, simulated failures left out."
          tile        = { x = 3, y = 10, w = 3, h = 5 }
          series      = [{ event = "log_checked", math = "total" }]
          breakdown   = "witness_quorum"
          bars        = true
          real_only   = true
        }
        merkle_root = {
          name        = "Merkle root"
          description = "How the Merkle root step ended, last 90 days, simulated failures left out."
          tile        = { x = 6, y = 10, w = 3, h = 5 }
          series      = [{ event = "log_checked", math = "total" }]
          breakdown   = "merkle_root"
          bars        = true
          real_only   = true
        }
        entry_checks = {
          name        = "Entries"
          description = "How the entries step ended, last 90 days, simulated failures left out."
          tile        = { x = 9, y = 10, w = 3, h = 5 }
          series      = [{ event = "log_checked", math = "total" }]
          breakdown   = "entry_checks"
          bars        = true
          real_only   = true
        }
        faults = {
          name        = "Simulated failures"
          description = "Times a simulated failure was turned on from the debug menu or a link, last 90 days, by failure."
          tile        = { x = 0, y = 15, w = 12, h = 5 }
          series      = [{ event = "fault_simulated", math = "total" }]
          breakdown   = "fault"
          bars        = true
        }
      }
    }
  }

  # Every insight as "dashboard/insight", with its PostHog query: a trend over
  # the last 90 days of its site's events.
  posthog_insights = merge([
    for d, dashboard in local.posthog_dashboards : {
      for i, insight in dashboard.insights : "${d}/${i}" => merge(insight, {
        dashboard = d
        query = {
          kind = "InsightVizNode"
          source = merge(
            {
              kind      = "TrendsQuery"
              dateRange = { date_from = "-90d" }
              interval  = try(insight.interval, "day")
              properties = concat(
                [{ type = "event", key = "$host", operator = "exact", value = dashboard.host }],
                try(insight.real_only, false) ? [{ type = "event", key = "simulated_fault", operator = "is_not_set" }] : [],
              )
              series = [for s in insight.series : { kind = "EventsNode", event = s.event, math = s.math }]
            },
            can(insight.breakdown) ? { breakdownFilter = { breakdown = insight.breakdown, breakdown_type = "event" } } : {},
            # Totals as bars, one per breakdown value, not lines over time.
            try(insight.bars, false) ? { trendsFilter = { display = "ActionsBarValue" } } : {},
          )
        }
      })
    }
  ]...)
}

resource "posthog_dashboard" "this" {
  for_each = local.posthog_dashboards

  name        = each.value.name
  description = "${each.value.description} Managed in github.com/benbirt/benbirt.io (infra/posthog.tf): change it there, not here."
}

# bazel build //infra (tofu validate) checks the configuration's shape, not
# whether PostHog accepts query_json. A bad query shows when the insight is
# opened in PostHog.
resource "posthog_insight" "this" {
  for_each = local.posthog_insights

  name          = each.value.name
  description   = each.value.description
  query_json    = jsonencode(each.value.query)
  dashboard_ids = [posthog_dashboard.this[each.value.dashboard].id]
}

resource "posthog_dashboard_layout" "this" {
  for_each = local.posthog_dashboards

  dashboard_id = posthog_dashboard.this[each.key].id

  # Each tile carries its own position, so the order here does not matter.
  tiles = [for i, insight in each.value.insights : {
    insight_id       = posthog_insight.this["${each.key}/${i}"].id
    layouts_json     = jsonencode({ sm = insight.tile })
    show_description = true
  }]
}


# The PostHog dashboard for the visits benbirt.io counts, so that it is
# reviewed and changed here and not in PostHog's UI. The site sends to a
# PostHog project shared with eavesbard.com and tlog.benbirt.io, whose
# dashboards are in their own repositories. Every insight filters on $host, so
# the dashboard shows this site only.
#
# The site uses PostHog's cookieless mode, so unique visitors are known per
# day only: PostHog cannot count unique visitors across a week or month.

provider "posthog" {
  host       = "https://eu.posthog.com"
  project_id = "306168"
}

locals {
  # Tile positions use PostHog's 12-column grid. Map keys name the resources, so
  # renaming one replaces its insight.
  posthog_insights = {
    visitors = {
      name        = "Visitors per day"
      description = "Unique visitors each day. Cookieless, so visitors can't be told apart across days: don't add days up."
      tile        = { x = 0, y = 0, w = 12, h = 5 }
      math        = "dau"
      breakdown   = null
    }
    pages = {
      name        = "Page views, by page"
      description = "Page views in the last 90 days, by path."
      tile        = { x = 0, y = 5, w = 6, h = 6 }
      math        = "total"
      breakdown   = "$pathname"
    }
    referrers = {
      name        = "Page views, by referrer"
      description = "Page views in the last 90 days, by the site that linked here ($direct: none)."
      tile        = { x = 6, y = 5, w = 6, h = 6 }
      math        = "total"
      breakdown   = "$referring_domain"
    }
  }
}

resource "posthog_dashboard" "visits" {
  name        = "benbirt.io visits"
  description = "Visits to benbirt.io. Managed in github.com/benbirt/benbirt.io (infra/posthog.tf): change it there, not here."
}

# bazel build //infra (tofu validate) checks the configuration's shape, not
# whether PostHog accepts query_json. A bad query shows when the insight is
# opened in PostHog.
resource "posthog_insight" "visits" {
  for_each = local.posthog_insights

  name        = each.value.name
  description = each.value.description
  # Page views from the site over the last 90 days: by day, or with a
  # breakdown as one bar for each of its values.
  query_json = jsonencode({
    kind = "InsightVizNode"
    source = merge(
      {
        kind       = "TrendsQuery"
        dateRange  = { date_from = "-90d" }
        interval   = "day"
        properties = [{ type = "event", key = "$host", operator = "exact", value = local.domain }]
        series     = [{ kind = "EventsNode", event = "$pageview", math = each.value.math }]
      },
      each.value.breakdown == null ? {} : {
        breakdownFilter = { breakdown = each.value.breakdown, breakdown_type = "event" }
        trendsFilter    = { display = "ActionsBarValue" }
      },
    )
  })
  dashboard_ids = [posthog_dashboard.visits.id]
}

resource "posthog_dashboard_layout" "visits" {
  dashboard_id = posthog_dashboard.visits.id

  # Each tile carries its own position, so the order here does not matter.
  tiles = [for key, insight in local.posthog_insights : {
    insight_id       = posthog_insight.visits[key].id
    layouts_json     = jsonencode({ sm = insight.tile })
    show_description = true
  }]
}

# Supabase SQL

## `get_prayers_by_date_groups`

Deploy: `migrations/20260613000000_fix_get_prayers_by_date_groups.sql`

### Composable `date_group` model

You do **not** need one row per `(weekday, hour)` combination.

Example: prayer said **Monday at 6:00**

| date_group row | Fields |
|----------------|--------|
| Monday | `day_of_week = 1` |
| Hour VI | `hour = 6` |

Both are linked in `prayer_date_group`. The RPC treats linked constraints as **AND**:

- Monday link → must be Monday
- Hour link → must match `hour_param` when filtering by hour

So the same hour-6 group can be reused for every weekday; each prayer picks its weekday link + the shared hour link.

### Parameters

| Param | Meaning |
|-------|---------|
| `day_of_week_param` 1–7 | Mon–Sun (same as Dart `DateTime.weekday`) |
| `hour_param` 0–23 | Only prayers that also have this hour link |
| `hour_param < 0` | Ignore hour (e.g. `-1`) |
| `month_param` / `day_param` | Optional feast-day constraints (AND with other links) |

### App usage

- **Calendar**: weekday/feast sections only — hour slots are not separate headers; those prayers are merged into the day group (e.g. Rugăciunile din ziuă)
- **Home “Pentru astăzi”**: first hour slot from midnight, last until end of day, hand-off 15 min before each next hour; day-only cards skip hour-linked prayers

After deploy: hot-restart the Flutter app.

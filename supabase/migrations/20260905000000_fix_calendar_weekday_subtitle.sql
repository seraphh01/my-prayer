create or replace function public.get_prayers_from_date_groups(
  day_of_week_param integer default null,
  specific_date_param text default null,
  month_param integer default null,
  day_param integer default null,
  hour_param integer default null
)
returns jsonb
language plpgsql
as $$
declare
  combined_results jsonb;
  v_specific_date text;
begin
  if specific_date_param is not null
     and specific_date_param not in ('', 'null') then
    v_specific_date := specific_date_param;
  end if;

  with prayer_links as (
    select
      p.id as prayer_id,
      p.title,
      p.subtitle,
      min(pdg.sequence) as sequence,
      coalesce(array_agg(distinct dg.day_of_week) filter (where dg.day_of_week is not null), '{}'::integer[]) as days_of_week,
      coalesce(array_agg(distinct dg.hour) filter (where dg.hour is not null), '{}'::integer[]) as hours,
      coalesce(array_agg(distinct dg.month) filter (where dg.month is not null), '{}'::integer[]) as months,
      coalesce(array_agg(distinct dg.day) filter (where dg.day is not null), '{}'::integer[]) as days,
      coalesce(array_agg(distinct dg.specific_date) filter (where dg.specific_date is not null and dg.specific_date <> ''), '{}'::text[]) as specific_dates
    from prayers p
    join prayer_date_group pdg on p.id = pdg.prayer_id
    join date_group dg on pdg.date_group_id = dg.id
    group by p.id, p.title, p.subtitle
  ),
  prayer_display as (
    select distinct on (pdg.prayer_id)
      pdg.prayer_id,
      dgt.name as date_group_name,
      dg.title as description
    from prayer_date_group pdg
    join date_group dg on pdg.date_group_id = dg.id
    join date_group_type dgt on dg.date_group_type_id = dgt.id
    order by
      pdg.prayer_id,
      case
        when v_specific_date is not null and dg.specific_date = v_specific_date then 0
        when dg.month = month_param and dg.day = day_param then 1
        when dg.day_of_week = day_of_week_param then 2
        when dg.day_of_week is not null then 3
        when dg.hour is null then 4
        else 5
      end,
      pdg.sequence,
      dg.id
  ),
  matching_prayers as (
    select
      pl.prayer_id,
      pl.title,
      pl.subtitle,
      pl.sequence,
      pd.date_group_name,
      pd.description,
      case
        when cardinality(pl.hours) = 1 then pl.hours[1]
        when cardinality(pl.hours) > 1 then (select min(h) from unnest(pl.hours) as h)
        else null
      end as hour
    from prayer_links pl
    join prayer_display pd on pd.prayer_id = pl.prayer_id
    where (cardinality(pl.specific_dates) = 0 or (v_specific_date is not null and v_specific_date = any (pl.specific_dates)))
      and (cardinality(pl.days_of_week) = 0 or (day_of_week_param between 1 and 7 and day_of_week_param = any (pl.days_of_week)))
      and (cardinality(pl.months) = 0 or (month_param between 1 and 12 and month_param = any (pl.months)))
      and (cardinality(pl.days) = 0 or (day_param between 1 and 31 and day_param = any (pl.days)))
      and (hour_param is null or hour_param < 0 or (cardinality(pl.hours) > 0 and hour_param = any (pl.hours)))
  ),
  grouped_prayers as (
    select
      date_group_name,
      description,
      hour,
      jsonb_agg(jsonb_build_object('id', prayer_id, 'title', title, 'subtitle', subtitle, 'sequence', sequence) order by sequence, subtitle) as prayers
    from matching_prayers
    group by date_group_name, description, hour
  )
  select jsonb_agg(
    jsonb_build_object('name', date_group_name, 'description', description, 'hour', hour, 'prayers', prayers)
    order by hour nulls first, date_group_name
  )
  into combined_results
  from grouped_prayers;

  return coalesce(combined_results, '[]'::jsonb);
end;
$$;
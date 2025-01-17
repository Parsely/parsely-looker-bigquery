view: user_facts {
  derived_table: {
    sql: SELECT
        rawdata.visitor_site_id AS visitor_site_id,
        MIN(rawdata.ts_action) AS first_action_date,
        COUNT(DISTINCT CONCAT(STRING(rawdata.session_id), '-', rawdata.visitor_site_id), 1000) AS rawdata_session_count
      FROM parsely.rawdata AS rawdata

      GROUP BY 1
       ;;
  }

  dimension: visitor_site_id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.visitor_site_id ;;
  }

  dimension_group: first_action {
    type: time
    sql: TIMESTAMP(${TABLE}.first_action_date) ;;
    timeframes: [date, week, month, year]
  }

  dimension: session_count {
    type: number
    sql: ${TABLE}.rawdata_session_count ;;
  }

  dimension: session_count_tier {
    type: tier
    sql: ${session_count} ;;
    tiers: [1, 2, 3]
    style: integer
  }

  measure: return_count {
    type: count_distinct
    sql: ${visitor_site_id} ;;

    filters: {
      field: session_count
      value: ">=2"
    }

    description: "Have returned to the site at least once"
    drill_fields: [visitor_site_id, user_facts.first_action_date, session_count]
  }

  measure: frequent_count {
    type: count_distinct
    sql: ${visitor_site_id} ;;

    filters: {
      field: session_count
      value: ">=3"
    }

    description: "Have returned to the site more than twice"
    drill_fields: [visitor_site_id, user_facts.first_action_date, session_count]
  }

  set: detail {
    fields: [visitor_site_id, first_action_date, rawdata.session_count]
  }
}

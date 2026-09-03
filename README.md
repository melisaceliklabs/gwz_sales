# gwz_sales

## About the Project

As part of a scenario where I build a dashboard for the GreenWeez sales team, I
write SQL queries against the `gwz_sales` table. I develop the queries in
VS Code and test them in BigQuery.

Instead of saving different versions of a query inside BigQuery, I track the
changes to the SQL files with Git.

This project was built as part of the Workintech Data Analytics program.

## Data Source

The data is hosted in BigQuery; there is no data file in the repo.

**Table:** `data-analytics-469406.course14.gwz_sales`
(Provided in the Workintech training environment; console access requires
permissions.)

**Size:** 1,486,388 rows

**Period:** 2021-03-01 – 2021-08-31 (184 days)

I verified that every day in the date range is present in the data by comparing
it against a calendar I generated with `GENERATE_DATE_ARRAY`; there are no
missing days. Since the dataset does not cover a full year, no conclusions can
be drawn about seasonality or yearly trends.

### Columns

| Column | Type | Description |
|---|---|---|
| `date_date` | DATE | Order date (no time component) |
| `orders_id` | INTEGER | Order number |
| `products_id` | INTEGER | Product number |
| `customers_id` | INTEGER | Customer number |
| `category_1`, `category_2`, `category_3` | STRING | Product category (3 levels) |
| `code` | STRING | Product code |
| `promo_name` | STRING | Name of the promotion applied |
| `turnover_before_promo` | FLOAT | Amount before promotion (gross) |
| `turnover` | FLOAT | Amount after promotion (net) |
| `purchase_cost` | FLOAT | Purchase cost of the product |
| `qty` | INTEGER | Quantity |

### A note on the table structure

A row does not represent an order, but **a product line within an order**.
Against a total of 1,486,388 rows there are 178,974 distinct `orders_id`
values, which works out to roughly 8.3 product lines per order. Any
order-level analysis needs to group by `orders_id` first.

## Analysis Questions

- **How does daily turnover change?**
  A daily net turnover series was produced by summing `turnover` by
  `date_date`.

- **What is the daily purchase cost?**
  At the sales manager's request, the sum of `purchase_cost` was added to the
  query as well. Since turnover and cost sit side by side, daily gross profit
  can be calculated from the difference.

## Findings

- `turnover` (the net amount after promotions) was used for the turnover
  calculation. `turnover_before_promo` gives the gross amount, so it does not
  reflect the money that actually comes in. The difference between the two
  shows the cost of the promotions — a separate topic for analysis.

- Because `turnover` is a FLOAT, floating point errors accumulate across a sum
  of 1.4 million rows (e.g. `90202.789999999528`). `ROUND` was applied **after**
  the sum; rounding row by row would have made the error larger.

## Files

| File | Contents |
|---|---|
| `gwz_sales.sql` | Daily turnover and purchase cost (by `date_date`, newest date first) |

## Way of Working

Changes were not made directly on `main`; feature branches were opened instead:

- `main` — the working version
- `develop` — the staging branch where changes accumulate
- Feature branches (`add_purchase_cost`, `sort_dates`) — one change each

Flow: open a feature branch → edit → commit → push → pull request → merge.
After merging, the feature branches were deleted both locally and remotely.

The project instructions suggest using GitHub Desktop; since I work on Linux, I
did all Git operations with the Git CLI and VS Code's Source Control panel.

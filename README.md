# Superstore Sales SQL Exploratory Analysis (Learning Project)
My first SQL portfolio project, created to practise data validation, joins, aggregation, and exploratory sales analysis using MySQL.

## Project Overview

This project is an exploratory SQL analysis of a Superstore sales dataset. The goal is to build a holistic understanding of business performance by analyzing revenue across four key dimensions:

- Time
- Product category and product performance
- Region and geography
- Customer segment and customer concentration

The project is designed as the kind of initial business analysis a data analyst might perform when joining a company or receiving a new sales dataset. Rather than focusing on one narrow question, the analysis builds a broad business profile: when revenue is generated, what products drive revenue, where sales are strongest, and which customer groups contribute the most.

While the project is primarily exploratory, the findings can support business decisions around seasonal planning, product focus, regional strategy, and customer targeting.

## Business Objective

The main objective of this project is to use SQL to answer:

> What does the sales data reveal about the business's revenue patterns, strongest markets, product drivers, and customer base?

To answer this, the analysis is organized around four business questions:

1. When does the business generate revenue?
2. What products and categories drive revenue?
3. Where does revenue come from geographically?
4. Who generates the revenue?

Together, these questions create a high-level map of business performance.

## Dataset

The dataset used is a Superstore sales dataset containing order-level sales records. The original data includes information such as:

- Order details
- Order dates
- Customer details
- Customer segments
- Product categories and sub-categories
- Product names
- Sales revenue
- City, state, and region

For the SQL project, the data was structured into separate relational tables:

| Table | Description |
|---|---|
| `fact_sales` | Sales transactions, including order IDs, product IDs, and sales revenue |
| `orders` | Order-level information such as order date, customer ID, state, and region |
| `products` | Product details such as category, sub-category, and product name |
| `customers` | Customer information such as customer name and segment |

This structure allowed the analysis to practice realistic SQL workflows using joins, aggregations, CTEs, and window functions.

## Tools Used

- SQL
- MySQL / MySQL Workbench
- Superstore sales dataset

## SQL Skills Demonstrated

This project demonstrates the following SQL skills:

- `JOIN`s across fact and dimension tables
- Aggregation using `SUM()` and `COUNT()`
- Grouping with `GROUP BY`
- Filtering with `WHERE`
- Common Table Expressions / CTEs
- Window functions such as `LAG()` and `RANK()`
- Percentage-of-total calculations
- Year-over-year growth calculations
- Conditional aggregation using `CASE WHEN`
- Ranking within groups using `PARTITION BY`
- Business-focused query organization and documentation

## Analysis Structure

The analysis is divided into four main sections:

1. Time Analysis
2. Category and Product Analysis
3. Region Analysis
4. Customer and Segment Analysis

Each section begins with broad questions and then drills deeper where needed.

---

# 1. Time Analysis

## Purpose

The time analysis section explores how revenue changes over time. This helps identify growth patterns, strong sales periods, and possible seasonal behavior.

This section answers:

- How has total revenue changed by year?
- What is the year-over-year revenue growth?
- How does revenue change month by month?
- Which individual months generated the highest revenue?
- Which calendar months tend to perform best across all years?

## Key Questions

### 1.1 How has total revenue changed by year?

This query summarizes annual revenue to understand whether the business is growing or declining over time.

The output helps establish the overall revenue trend before drilling into months or categories.

### 1.2 What is the year-over-year revenue growth?

This query uses `LAG()` to compare each year's revenue with the previous year.

The purpose is to measure how much revenue increased or decreased from one year to the next.

### 1.3 How does revenue change month by month within each year?

This query breaks revenue down by year and month.

It helps identify monthly patterns and highlights unusually strong or weak sales periods.

### 1.4 Which year-month combinations generated the highest revenue?

This query identifies the top five individual sales months across the dataset.

The strongest months were concentrated toward the later part of the year, especially:

- November
- December
- September

### 1.5 Which calendar months generate the most revenue across all years?

This query aggregates the same calendar month across multiple years.

For example, it combines all January revenue, all February revenue, and so on.

This helps identify recurring seasonal patterns rather than one-off strong months.

## Time Analysis Insights

- Revenue shows meaningful variation across years and months.
- Several of the highest-revenue months occur in the later part of the year.
- November, December, and September appear to be especially strong revenue months.
- Late-year demand may be an important seasonal pattern for the business.

## Business Interpretation

The business should pay close attention to late-year sales periods. If September, November, and December consistently generate strong revenue, the company may benefit from preparing inventory, marketing campaigns, and staffing ahead of those months.

---

# 2. Category and Product Analysis

## Purpose

The category and product analysis section explores what the business sells and which products or product groups generate the most revenue.

This section answers:

- Which product categories generate the most revenue?
- What share of total revenue does each category represent?
- How has category performance changed by year?
- Which sub-categories drive revenue within each category?
- Which Technology sub-categories explain Technology performance?
- Which individual Technology products contribute the most revenue?

## Key Questions

### 2.1 Which product categories generate the most revenue?

This query compares total revenue across the three main product categories:

- Technology
- Furniture
- Office Supplies

The result showed:

| Category | Share of Total Revenue |
|---|---:|
| Technology | 36.59% |
| Furniture | 32.22% |
| Office Supplies | 31.19% |

## Insight

Technology is the highest-revenue category, but revenue is fairly balanced across all three categories.

This is important because the business is not entirely dependent on one broad product category.

### 2.2 What share of each year's revenue came from each product category?

This query compares category revenue by year.

It helps determine whether the category mix stayed stable over time or whether one category became more dominant in certain years.

## Insight

Category performance varies by year, but the three main categories remain meaningful contributors to revenue.

### 2.3 Which sub-categories generate the most revenue within each product category?

This query drills below broad categories to identify specific product groups.

This is important because broad categories can hide the actual drivers of revenue.

## Insight

Sub-category analysis provides a more useful view of what is driving category performance.

### 2.4 What share of Technology revenue comes from each Technology sub-category?

Because Technology was the highest-revenue category, the analysis drilled into Technology sub-categories.

The result showed:

| Technology Sub-Category | Share of Technology Revenue |
|---|---:|
| Phones | 39.61% |
| Machines | 22.87% |
| Accessories | 19.84% |
| Copiers | 17.67% |

## Insight

Phones are the largest driver of Technology revenue, contributing almost 40% of Technology sales.

However, Technology revenue is not entirely dependent on Phones. Machines, Accessories, and Copiers also contribute meaningful shares.

### 2.5 Which individual Technology products contribute the most to Technology revenue?

This query identifies the highest-revenue Technology products.

The top Technology product contributed about 7.44% of Technology revenue.

## Insight

Even the top Technology product does not dominate the entire Technology category. This suggests that Technology revenue is spread across multiple products rather than being overly dependent on one item.

## Business Interpretation

Technology is the strongest category, and Phones are the leading Technology sub-category. However, revenue is still diversified across multiple categories and products.

The business could continue prioritizing Technology, especially Phones, while also maintaining support for Furniture and Office Supplies because both contribute substantial revenue.

---

# 3. Region Analysis

## Purpose

The region analysis section explores where revenue comes from geographically.

This section answers:

- Which regions generate the most revenue?
- What share of total revenue does each region represent?
- Which regions lead in each year?
- Which states generate the most revenue within each region?
- Is the West region's performance broadly distributed or concentrated in one state?
- Which categories and sub-categories drive California revenue?

## Key Questions

### 3.1 Which regions generate the most revenue?

This query compares revenue and share of total revenue by region.

The result showed:

| Region | Share of Total Revenue |
|---|---:|
| West | 31.40% |
| East | 29.60% |
| Central | 21.78% |
| South | 17.21% |

## Insight

West is the highest-revenue region, followed closely by East.

Together, West and East account for about 61% of total revenue.

### 3.2 Which regions generated the most revenue in each year?

This query compares annual revenue by region.

It checks whether West was consistently the strongest region or whether its overall lead was driven by one unusually strong year.

## Insight

Regional leadership can vary by year. This adds nuance to the overall regional ranking.

### 3.3 Which states generate the most revenue within each region?

This query ranks states within each region using `RANK()` and `PARTITION BY region`.

It identifies which states are driving each region's performance.

## Insight

State-level analysis revealed that some regions are strongly influenced by a few major states.

### 3.4 How concentrated is West region revenue across its states?

Because West was the top region, the analysis drilled deeper into Western states.

The result showed:

| State | Share of West Revenue |
|---|---:|
| California | 62.84% |
| Washington | 19.04% |
| Arizona | 4.97% |
| Colorado | 4.48% |

## Insight

California alone contributes 62.84% of West revenue.

This means the West region's strong performance is heavily concentrated in California rather than evenly distributed across Western states.

### 3.5 Which product categories drive California revenue?

Since California dominates West revenue, the analysis examined California's category mix.

The result showed:

| Category | Share of California Revenue |
|---|---:|
| Technology | 34.66% |
| Furniture | 34.11% |
| Office Supplies | 31.24% |

## Insight

California revenue is fairly balanced across all three product categories.

This means California's strength is not driven by one broad category. Instead, California appears to be broadly strong across the product mix.

### 3.6 Which sub-categories drive revenue within each California category?

Because California revenue was balanced across broad categories, the analysis drilled deeper into sub-categories.

Key sub-category drivers included:

- Furniture: Chairs
- Office Supplies: Storage
- Technology: Phones

## Insight

Although California is balanced at the category level, each category has clear sub-category drivers.

## Business Interpretation

West is the top-performing region, but its performance is highly dependent on California. This creates both an opportunity and a risk.

The business should continue protecting and growing its California customer base while also investigating opportunities to grow underperforming Western states. California's balanced category mix suggests that the state is broadly strong and not dependent on a single product category.

---

# 4. Customer and Segment Analysis

## Purpose

The customer and segment analysis section explores who generates revenue.

This section answers:

- Which customer segments generate the most revenue?
- How has segment revenue changed over time?
- Which segments grew the most from 2015 to 2018?
- Which product categories does each segment spend the most on?
- Which customers generate the most revenue?
- Is revenue concentrated among a small number of customers?

## Key Questions

### 4.1 Which customer segments generate the most revenue?

This query compares revenue and share of total revenue by customer segment.

The result showed:

| Segment | Share of Total Revenue |
|---|---:|
| Consumer | 50.76% |
| Corporate | 30.44% |
| Home Office | 18.79% |

## Insight

Consumer is the largest customer segment, generating just over half of total revenue.

Corporate is the second-largest segment, while Home Office is the smallest by total revenue.

### 4.2 Which customer segments grew the most from 2015 to 2018?

This query compares each segment's revenue in 2015 with its revenue in 2018.

The result showed:

| Segment | Total Growth from 2015 to 2018 |
|---|---:|
| Corporate | 84.70% |
| Home Office | 76.66% |
| Consumer | 24.97% |

## Insight

Although Consumer is the largest segment overall, Corporate and Home Office grew much faster between 2015 and 2018.

This suggests that smaller segments may represent stronger growth opportunities.

### 4.3 How has revenue changed year over year for each customer segment?

This query uses `LAG()` partitioned by segment to compare each segment's revenue with the previous year.

## Insight

Consumer revenue shows steadier growth, while Corporate and Home Office show more volatility but stronger later-stage growth.

### 4.4 Which product categories does each customer segment spend the most on?

This query compares category preferences across Consumer, Corporate, and Home Office customers.

Approximate pattern:

| Segment | Category Pattern |
|---|---|
| Consumer | Fairly balanced across Technology, Furniture, and Office Supplies |
| Corporate | Technology leads slightly |
| Home Office | More Technology-heavy than the other segments |

## Insight

All segments buy across all three categories, but Home Office appears more Technology-focused.

This can support more tailored marketing and product strategies by segment.

### 4.5 Which individual customers generate the most revenue?

This query ranks customers by total revenue.

The top customer contributed only about 1.11% of total revenue.

## Insight

No single customer dominates revenue.

This suggests the business is not overly dependent on one individual customer.

### 4.6 How concentrated is revenue among the top customers?

This query summarizes the revenue share contributed by the top customers.

The top 10 customers together account for only a small percentage of total revenue.

## Insight

Customer concentration is low. Revenue is spread across many customers rather than depending heavily on a small number of buyers.

## Business Interpretation

Consumer is currently the largest segment, but Corporate and Home Office show stronger growth over the full period.

The business should continue retaining Consumer customers while exploring growth opportunities in Corporate and Home Office. Since customer concentration is low, the business has a diversified customer base and is not highly exposed to losing a single major customer.

---

# Key Findings

## 1. Revenue is strongest in late-year months

Several of the highest-revenue months occur in September, November, and December.

This suggests that the business may experience seasonal demand peaks toward the end of the year.

## 2. Technology is the leading product category

Technology contributes the largest share of total revenue at 36.59%.

However, Furniture and Office Supplies also contribute substantial revenue, meaning the business is not dependent on Technology alone.

## 3. Phones are the largest Technology sub-category

Phones contribute 39.61% of Technology revenue.

This makes Phones an important product group within the strongest category.

## 4. West is the highest-revenue region

West contributes 31.40% of total revenue, followed closely by East at 29.60%.

Together, West and East account for about 61% of total revenue.

## 5. West revenue is heavily concentrated in California

California contributes 62.84% of West revenue.

This shows that West's performance is not evenly distributed across the region.

## 6. California revenue is balanced across categories

California's revenue is split fairly evenly across Technology, Furniture, and Office Supplies.

This suggests California is broadly strong across the business rather than dependent on one category.

## 7. Consumer is the largest customer segment

Consumer customers generate 50.76% of total revenue.

This makes Consumer the core revenue segment.

## 8. Corporate and Home Office grew faster than Consumer

From 2015 to 2018, Corporate and Home Office grew much faster than Consumer.

This suggests that while Consumer is the largest segment, Corporate and Home Office may represent important growth opportunities.

## 9. Customer concentration is low

The top customer contributes only about 1.11% of total revenue.

This indicates that the business is not overly dependent on any single customer.

---

# Business Recommendations

## 1. Prepare for late-year demand peaks

Since September, November, and December are strong revenue months, the business should prepare inventory, marketing, and staffing ahead of these periods.

## 2. Continue prioritizing Technology, especially Phones

Technology is the strongest product category, and Phones are the largest Technology sub-category.

The business should continue monitoring Phone demand and consider targeted promotions or inventory planning around high-performing Technology products.

## 3. Protect and grow the California market

California is the main driver of West region revenue.

The business should prioritize customer retention and marketing in California while also identifying why California performs so strongly.

## 4. Investigate growth opportunities in underperforming Western states

Because California dominates West revenue, other Western states may represent possible growth opportunities.

The business could investigate whether lower revenue in those states is due to fewer customers, weaker demand, limited product mix, or other market factors.

## 5. Maintain the Consumer segment while exploring Corporate and Home Office growth

Consumer is the largest segment, but Corporate and Home Office grew faster over the full period.

The business should continue serving Consumer customers while testing targeted strategies for Corporate and Home Office customers.

## 6. Tailor category promotions by customer segment

Since category preferences differ slightly by segment, the business can use segment-specific messaging.

For example, Technology-focused campaigns may be especially relevant for Home Office customers.

## 7. Continue benefiting from a diversified customer base

Customer concentration is low, which reduces dependency risk.

The business should continue broad customer acquisition and retention efforts rather than relying on a few large accounts.

---

# Conclusion

This project used SQL to perform an exploratory business analysis of Superstore sales data.

The analysis built a broad understanding of revenue performance across time, products, regions, and customer segments. It identified key revenue drivers, seasonal patterns, geographic concentration, segment growth trends, and customer concentration levels.

Overall, the business appears to have a diversified revenue base across product categories and customers, but it also shows important concentration in certain areas, especially California's role in West region performance and Technology's role as the leading product category.

This type of exploratory analysis provides useful business context and creates a foundation for deeper future analysis, such as profitability, customer retention, marketing effectiveness, or regional expansion strategy.

## Possible Next Steps

Future analysis could explore:

- Profitability by category, region, and segment
- Discount impact on sales and profit
- Customer retention and repeat purchasing
- Shipping performance and delivery delays
- Product-level profitability
- Regional market expansion opportunities
- Forecasting future revenue trends


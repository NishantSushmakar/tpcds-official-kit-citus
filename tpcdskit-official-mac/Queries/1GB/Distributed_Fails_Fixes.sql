
-- Query 32 -- Added with clause and compared with it later 00:00:00.810
-- result verified from postgres

With AvgDisc30 As
(
 select i_item_sk , 
	1.3 * avg(cs_ext_discount_amt) as avg30
 from 
	catalog_sales 
	,item 
    ,date_dim
 where 
	  cs_item_sk = i_item_sk 
  and d_date between '2001-03-09' and
					 (cast('2001-03-09' as date) + interval '90 days')
  and d_date_sk = cs_sold_date_sk 
  Group by i_item_sk
)
select  sum(cs_ext_discount_amt)  as "excess discount amount" 
from 
   catalog_sales 
   ,item i
   ,date_dim
where
i.i_manufact_id = 722
and i.i_item_sk = cs_item_sk 
and d_date between '2001-03-09' and 
        (cast('2001-03-09' as date) + interval '90 days')
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( select avg30 from AvgDisc30 A where A.i_item_sk = i.i_item_sk ) 
limit 100;





-- Query 16 --  fan gets high a little bit 00:00:57.737
-- result verified from postgres

With CS2 AS
(
  select cs_order_number,cs_warehouse_sk
  from catalog_sales
),
CR1 AS (
  select cr_order_number
  from catalog_returns 
)
select  
   count(distinct cs1.cs_order_number) as "order count"
  ,sum(cs1.cs_ext_ship_cost) as "total shipping cost"
  ,sum(cs1.cs_net_profit) as "total net profit"
from
   catalog_sales cs1
  ,date_dim
  ,customer_address
  ,call_center
where
    d_date between '2002-4-01' and 
           (cast('2002-4-01' as date) + interval '60 days')
and cs1.cs_ship_date_sk = d_date_sk
and cs1.cs_ship_addr_sk = ca_address_sk
and ca_state = 'PA'
and cs1.cs_call_center_sk = cc_call_center_sk
and cc_county in ('Williamson County','Williamson County','Williamson County','Williamson County',
                  'Williamson County'
)
and Exists (SELECT * FROM CS2 Where cs1.cs_order_number = CS2.cs_order_number and cs1.cs_warehouse_sk <> CS2.cs_warehouse_sk)
and Not Exists (SELECT Distinct CR1.cr_order_number FROM CR1 Where cs1.cs_order_number= CR1.cr_order_number)
order by count(distinct cs1.cs_order_number)
limit 100;


-- Query 10 - replaced subquery joins with with caluses and IN check  00:04:06.125
-- result verified from postgres


-- Filter store_sales for the relevant date range and county
WITH store_sales_filtered AS (
  SELECT ss_customer_sk
  FROM store_sales ss
  JOIN date_dim dd ON ss.ss_sold_date_sk = dd.d_date_sk
  WHERE d_year = 2001 AND d_moy BETWEEN 3 AND 3+3
),
-- Filter web_sales for the relevant date range and county
web_sales_filtered AS (
  SELECT ws_bill_customer_sk
  FROM web_sales ws
  JOIN date_dim dd ON ws.ws_sold_date_sk = dd.d_date_sk
  WHERE d_year = 2001 AND d_moy BETWEEN 3 AND 3+3
),
-- Filter catalog_sales for the relevant date range and county
catalog_sales_filtered AS (
  SELECT cs_ship_customer_sk
  FROM catalog_sales cs
  JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk
  WHERE d_year = 2001 AND d_moy BETWEEN 3 AND 3+3
)
-- Main query that pulls customer details
SELECT  
  cd_gender,
  cd_marital_status,
  cd_education_status,
  COUNT(*) cnt1,
  cd_purchase_estimate,
  COUNT(*) cnt2,
  cd_credit_rating,
  COUNT(*) cnt3,
  cd_dep_count,
  COUNT(*) cnt4,
  cd_dep_employed_count,
  COUNT(*) cnt5,
  cd_dep_college_count,
  COUNT(*) cnt6
FROM customer c,customer_address ca,customer_demographics 
WHERE c.c_current_addr_sk = ca.ca_address_sk
AND c.c_current_cdemo_sk = cd_demo_sk
AND ca.ca_county IN ('Fairfield County', 'Campbell County', 'Washtenaw County', 'Escambia County', 'Cleburne County')
AND EXISTS (SELECT * FROM store_sales_filtered Where ss_customer_sk=c.c_customer_sk )
AND (EXISTS (SELECT * FROM web_sales_filtered Where ws_bill_customer_sk=c.c_customer_sk )
OR EXISTS (SELECT * FROM catalog_sales_filtered Where cs_ship_customer_sk=c.c_customer_sk ))
GROUP BY cd_gender, 
	     cd_marital_status, 
		 cd_education_status, 
		 cd_purchase_estimate, 
		 cd_credit_rating,
		 cd_dep_count, 
		 cd_dep_employed_count, 
		 cd_dep_college_count
ORDER BY cd_gender, 
	     cd_marital_status, 
		 cd_education_status, 
		 cd_purchase_estimate, 
         cd_credit_rating, 
		 cd_dep_count, 
		 cd_dep_employed_count, 
		 cd_dep_college_count
LIMIT 100;

-- Query 35  Added with clause execution time : 00:03:26.372
-- results verified 

WITH store_sales_filtered AS(
  SELECT ss_customer_sk
  FROM store_sales ss
  JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
  WHERE d_year = 1999 and d_qoy < 4
),
web_sales_filtered AS(
  SELECT ws_bill_customer_sk
  FROM web_sales ws
  JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
  WHERE d_year = 1999 and d_qoy < 4
),
catalog_sales_filtered AS(
	SELECT cs_ship_customer_sk
	FROM catalog_sales cs
	JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
	WHERE d_year = 1999 and d_qoy < 4
)
SELECT  
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  COUNT(*) cnt1,
  AVG(cd_dep_count),
  STDDEV_SAMP(cd_dep_count),
  SUM(cd_dep_count),
  cd_dep_employed_count,
  COUNT(*) cnt2,
  AVG(cd_dep_employed_count),
  STDDEV_SAMP(cd_dep_employed_count),
  SUM(cd_dep_employed_count),
  cd_dep_college_count,
  COUNT(*) cnt3,
  AVG(cd_dep_college_count),
  STDDEV_SAMP(cd_dep_college_count),
  SUM(cd_dep_college_count)
FROM 
  customer c,customer_address ca,customer_demographics
WHERE
  c.c_current_addr_sk = ca.ca_address_sk AND
  cd_demo_sk = c.c_current_cdemo_sk AND
  EXISTS(SELECT * FROM store_sales_filtered WHERE  c.c_customer_sk = ss_customer_sk) AND
  (EXISTS(SELECT * FROM web_sales_filtered WHERE  c.c_customer_sk = ws_bill_customer_sk) OR 
    EXISTS(SELECT * FROM catalog_sales_filtered WHERE c.c_customer_sk = cs_ship_customer_sk))
GROUP BY ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
ORDER BY ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
LIMIT 100;

-- Query 69 Added with clause execution time: 00:00:00.719
-- results verified 

WITH store_sales_filtered AS(
  SELECT ss_customer_sk
  FROM store_sales ss
  JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
  WHERE d_year = 2002 AND d_moy BETWEEN 1 AND 1+2
),
web_sales_filtered AS(
  SELECT ws_bill_customer_sk
  FROM web_sales ws
  JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
  WHERE d_year = 2002 AND d_moy BETWEEN 1 AND 1+2
),
catalog_sales_filtered AS(
	SELECT cs_ship_customer_sk
	FROM catalog_sales cs
	JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
	WHERE d_year = 2002 AND d_moy BETWEEN 1 AND 1+2
)
SELECT  
cd_gender,cd_marital_status,cd_education_status,
COUNT(*) cnt1,cd_purchase_estimate,COUNT(*) cnt2,
cd_credit_rating,COUNT(*) cnt3
FROM
customer c,customer_address ca,customer_demographics
WHERE
c.c_current_addr_sk = ca.ca_address_sk AND
ca_state IN ('IL','TX','ME') AND
cd_demo_sk = c.c_current_cdemo_sk 
AND EXISTS (SELECT * FROM store_sales_filtered WHERE  c.c_customer_sk = ss_customer_sk) 
AND(NOT EXISTS (SELECT * FROM web_sales_filtered WHERE  c.c_customer_sk = ws_bill_customer_sk) 
AND NOT EXISTS (SELECT * FROM catalog_sales_filtered WHERE c.c_customer_sk = cs_ship_customer_sk))
GROUP BY cd_gender,
	  cd_marital_status,
	  cd_education_status,
	  cd_purchase_estimate,
	  cd_credit_rating
ORDER BY cd_gender,
	  cd_marital_status,
	  cd_education_status,
	  cd_purchase_estimate,
	  cd_credit_rating
LIMIT 100;

-- Query 70 Rollup function substitued with union all and changes made accordingly Execution time : 00:00:00.510

WITH temp_filter AS (
	SELECT s_state
    FROM  (SELECT s_state as s_state,
 		   RANK() OVER ( PARTITION BY s_state ORDER BY SUM(ss_net_profit) DESC) AS ranking
           FROM store_sales, store, date_dim
           WHERE d_month_seq BETWEEN 1220 AND 1220+11
 		   AND d_date_sk = ss_sold_date_sk
 		   AND s_store_sk  = ss_store_sk
           GROUP BY s_state) tmp1 
    WHERE ranking <= 5
),
sales_aggregation as (

	SELECT sum(ss_net_profit) AS agg_sum,s_state,s_county
	FROM store_sales,date_dim d1,store
	WHERE
    d1.d_month_seq BETWEEN 1220 AND 1220+11 AND d1.d_date_sk = ss_sold_date_sk
    AND s_store_sk  = ss_store_sk AND s_state IN (SELECT s_state FROM temp_filter)
	GROUP BY s_state,s_county
),
rollup_results as(

	-- State + County
	SELECT agg_sum AS total_sum ,s_state,s_county, 0 as lochierarchy,  
	RANK() OVER (PARTITION BY s_state ORDER BY agg_sum DESC) as rank_within_parent
	FROM sales_aggregation
	UNION ALL 
	-- State
	SELECT SUM(agg_sum) AS total_sum , s_state , NULL AS s_county, 1 as lochierarchy ,
	RANK() OVER (ORDER BY SUM(agg_sum) DESC) as rank_within_parent
	FROM sales_aggregation
	GROUP BY s_state
	UNION ALL
	-- Grand Total
	SELECT SUM(agg_sum) AS total_sum , NULL AS s_state , NULL AS s_county, 2 AS lochierarchy,
	1 as rank_within_parent
	FROM sales_aggregation 
)
SELECT *
FROM rollup_results
ORDER BY lochierarchy desc,CASE WHEN lochierarchy = 0 THEN s_state END,rank_within_parent
LIMIT 100;

-- Query 86  Rollup function substitued with union all and changes made accordingly  execution time : 00:00:00.210

WITH sales_aggregation AS (
  SELECT 
    SUM(ws_net_paid) AS category_class_sum,
    i_category,
    i_class
    
  FROM web_sales
  JOIN date_dim d1 ON d1.d_date_sk = ws_sold_date_sk
  JOIN item ON i_item_sk = ws_item_sk
  WHERE d1.d_month_seq BETWEEN 1186 AND 1186+11
  GROUP BY i_category, i_class
),
rollup_results AS (
  -- Category + Class level
  SELECT
  	category_class_sum AS total_sum,
    i_category,
    i_class,
    0 as lochierarchy,
    RANK() OVER (PARTITION BY i_category ORDER BY category_class_sum DESC) as rank_within_parent
  FROM sales_aggregation
  
  UNION ALL
  
  -- Category level
  SELECT SUM(category_class_sum) as total_sum, i_category, NULL as i_class,1 as lochierarchy,
    RANK() OVER (ORDER BY SUM(category_class_sum) DESC) as rank_within_parent
  FROM sales_aggregation
  GROUP BY i_category
  
  UNION ALL
  
  -- Grand total level
  SELECT
  	SUM(category_class_sum) as total_sum,
    NULL as i_category,
    NULL as i_class, 2 as lochierarchy, 1 as rank_within_parent
  FROM sales_aggregation
   )
SELECT *
FROM rollup_results
ORDER BY 
  lochierarchy DESC,
  CASE WHEN lochierarchy = 0 THEN i_category END,
  rank_within_parent
LIMIT 100;



-- Query 92 - Just added the same kind of filters and table in subquery  Execution time - 00:00:00.121
-- result verified 
select  
   sum(ws_ext_discount_amt)  as "Excess Discount Amount" 
from 
    web_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 714
and i_item_sk = ws_item_sk 
and d_date between '2000-02-01' and 
        (cast('2000-02-01' as date) + interval '90 days')
and d_date_sk = ws_sold_date_sk 
and ws_ext_discount_amt  
     > ( 
         SELECT 
            1.3 * avg(ws_ext_discount_amt) 
         FROM 
            web_sales 
           ,date_dim,item
         WHERE 
              i_manufact_id = 714
          and i_item_sk = ws_item_sk 
              ws_item_sk = i_item_sk 
          and d_date between '2000-02-01' and
                             (cast('2000-02-01' as date) + interval '90 days')
          and d_date_sk = ws_sold_date_sk 
      ) 
order by sum(ws_ext_discount_amt)
limit 100;





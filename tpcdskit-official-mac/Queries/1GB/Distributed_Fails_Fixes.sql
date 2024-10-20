
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


-- Query 10 - replaced subquery joins with with caluses and IN check  00:00:02.412
-- result still not verified from postgres

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
FROM customer c
JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
WHERE ca.ca_county IN ('Fairfield County', 'Campbell County', 'Washtenaw County', 'Escambia County', 'Cleburne County')
AND c.c_customer_sk IN (
  -- Combine the results of the filtered distributed tables
  SELECT ss_customer_sk FROM store_sales_filtered
  UNION
  SELECT ws_bill_customer_sk FROM web_sales_filtered
  UNION
  SELECT cs_ship_customer_sk FROM catalog_sales_filtered
)
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



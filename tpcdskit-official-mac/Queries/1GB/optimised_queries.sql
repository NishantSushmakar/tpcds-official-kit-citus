-- start query 1 in stream 0 using template query1.tpl
with customer_total_return as
(select sr_customer_sk as ctr_customer_sk
,sr_store_sk as ctr_store_sk
,sum(SR_FEE) as ctr_total_return
from store_returns
,date_dim
where sr_returned_date_sk = d_date_sk
and d_year =2000
group by sr_customer_sk
,sr_store_sk),
store_average as (
	select ctr_store_sk, avg(ctr_total_return)*1.2 as store_threshold
	from customer_total_return
	group by ctr_store_sk
)
select c_customer_id
from customer_total_return ctr1,store,customer,store_average sa
where ctr1.ctr_store_sk = sa.ctr_store_sk
and ctr1.ctr_total_return > sa.store_threshold
and s_store_sk = ctr1.ctr_store_sk
and s_state = 'TN'
and ctr1.ctr_customer_sk = c_customer_sk
order by c_customer_id
limit 100;
-- end query 1 in stream 0 using template query1.tpl
-- start query 4 in stream 0 using template query4.tpl
set local citus.max_intermediate_result_size = '5GB';
with year_total_s as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year),

year_total_c as(
select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2) ) year_total
       ,'c' sale_type
 from customer
     ,catalog_sales
     ,date_dim
 where c_customer_sk = cs_bill_customer_sk
   and cs_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year),
year_total_w as(
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2) ) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
  select  
                  t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_birth_country
 from year_total_s t_s_firstyear
     ,year_total_s t_s_secyear
     ,year_total_c t_c_firstyear
     ,year_total_c t_c_secyear
     ,year_total_w t_w_firstyear
     ,year_total_w t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
   and t_s_firstyear.customer_id = t_c_secyear.customer_id
   and t_s_firstyear.customer_id = t_c_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_secyear.customer_id
   and t_s_firstyear.dyear =  1999
   and t_s_secyear.dyear = 1999+1
   and t_c_firstyear.dyear =  1999
   and t_c_secyear.dyear =  1999+1
   and t_w_firstyear.dyear = 1999
   and t_w_secyear.dyear = 1999+1
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_birth_country
limit 100;

-- end query 4 in stream 0 using template query4.tpl
-- start query 11 in stream 0 using template query11.tpl
set local citus.max_intermediate_result_size = '5GB';
with year_total_s as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ss_ext_list_price-ss_ext_discount_amt) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag 
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year ),
year_total_w as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ws_ext_list_price-ws_ext_discount_amt) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag 
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
  select  
                  t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_email_address
 from year_total_s t_s_firstyear
     ,year_total_s t_s_secyear
     ,year_total_w t_w_firstyear
     ,year_total_w t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.dyear = 1998
         and t_s_secyear.dyear = 1998+1
         and t_w_firstyear.dyear = 1998
         and t_w_secyear.dyear = 1998+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else 0.0 end
             > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else 0.0 end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_email_address
limit 100;

-- end query 11 in stream 0 using template query11.tpl
-- start query 74 in stream 0 using template query74.tpl
with year_total_s as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,max(ss_net_paid) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
   and d_year in (1999,1999+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year),
year_total_w as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,max(ws_net_paid) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
   and d_year in (1999,1999+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
         )
  select 
        t_s_secyear.customer_id, t_s_secyear.customer_first_name, t_s_secyear.customer_last_name
 from year_total_s t_s_firstyear
     ,year_total_s t_s_secyear
     ,year_total_w t_w_firstyear
     ,year_total_w t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.year = 1999
         and t_s_secyear.year = 1999+1
         and t_w_firstyear.year = 1999
         and t_w_secyear.year = 1999+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
 order by 1,3,2
limit 100;

-- end query 74 in stream 0 using template query74.tpl

-- start query 35 in stream 0 using template query35.tpl
with store_sales_tmp as (
    select ss_customer_sk
    from store_sales ss
    join date_dim d on ss.ss_sold_date_sk = d.d_date_sk
    where d_year = 1999 and d_qoy < 4
    group by ss_customer_sk
),
web_catalog_sales_tmp as (
    select c_customer_sk
    from (
        select ws_bill_customer_sk as c_customer_sk
        from web_sales ws
        join date_dim d on ws.ws_sold_date_sk = d.d_date_sk
        where d_year = 1999 and d_qoy < 4
        union
        select cs_ship_customer_sk as c_customer_sk
        from catalog_sales cs
        join date_dim d on cs.cs_sold_date_sk = d.d_date_sk
        where d_year = 1999 and d_qoy < 4
    ) sub
)
select
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    count(*) cnt1,
    avg(cd_dep_count),
    stddev_samp(cd_dep_count),
    sum(cd_dep_count),
    cd_dep_employed_count,
    count(*) cnt2,
    avg(cd_dep_employed_count),
    stddev_samp(cd_dep_employed_count),
    sum(cd_dep_employed_count),
    cd_dep_college_count,
    count(*) cnt3,
    avg(cd_dep_college_count),
    stddev_samp(cd_dep_college_count),
    sum(cd_dep_college_count)
from
    customer c
    join customer_address ca on c.c_current_addr_sk = ca.ca_address_sk
    join customer_demographics cd on cd.cd_demo_sk = c.c_current_cdemo_sk
    join store_sales_tmp ss_tmp on c.c_customer_sk = ss_tmp.ss_customer_sk
    join web_catalog_sales_tmp wcs_tmp on c.c_customer_sk = wcs_tmp.c_customer_sk
group by
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
order by
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
limit 100;
-- end query 35 in stream 0 using template query35.tpl
-- start query 95 in stream 0 using template query95.tpl
set local citus.enable_repartition_joins to 'on';
set local citus.multi_shard_modify_mode to 'sequential';

with ws_wh as (
    select ws_order_number
    from web_sales
    group by ws_order_number
    having count(distinct ws_warehouse_sk) > 1
)
select
    count(distinct ws1.ws_order_number) as "order count",
    sum(ws1.ws_ext_ship_cost) as "total shipping cost",
    sum(ws1.ws_net_profit) as "total net profit"
from
    web_sales ws1
    join date_dim on ws1.ws_ship_date_sk = date_dim.d_date_sk
    join customer_address on ws1.ws_ship_addr_sk = customer_address.ca_address_sk
    join web_site on ws1.ws_web_site_sk = web_site.web_site_sk
where
    date_dim.d_date BETWEEN '2001-04-01' AND (cast('2001-4-01' as date) + interval '60 days')
    and customer_address.ca_state = 'VA'
    and web_site.web_company_name = 'pri'
	and exists (
        select ws_order_number
        from ws_wh
        where ws_wh.ws_order_number = ws1.ws_order_number
    )
    and exists (
        select wr_order_number
        from web_returns wr
        join ws_wh on wr.wr_order_number = ws_wh.ws_order_number
        where wr.wr_order_number = ws1.ws_order_number
    );
-- end query 95 in stream 0 using template query95.tpl

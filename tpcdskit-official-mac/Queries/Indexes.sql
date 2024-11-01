-- Custom Indexes
CREATE INDEX ON "customer" ("c_current_addr_sk");
CREATE INDEX ON "date_dim" ("d_year");
CREATE INDEX ON "store_sales" ("ss_customer_sk");
CREATE INDEX ON "store_sales" ("ss_sold_date_sk");
CREATE INDEX ON "web_sales" ("ws_bill_customer_sk");
CREATE INDEX ON "web_sales" ("ws_sold_date_sk");
CREATE INDEX ON "catalog_sales" ("cs_bill_customer_sk");
CREATE INDEX ON "catalog_sales" ("cs_sold_date_sk");
CREATE INDEX ON "customer" ("c_current_cdemo_sk");
CREATE INDEX ON "store_returns" ("sr_returned_date_sk");

-- Dexter Indexes
CREATE INDEX ON "store_sales" ("ss_customer_sk");
CREATE INDEX ON "store_sales" ("ss_item_sk", "ss_wholesale_cost");
CREATE INDEX ON "store_sales" ("ss_quantity");
CREATE INDEX ON "web_sales" ("ws_bill_customer_sk");
CREATE INDEX ON "store_returns" ("sr_cdemo_sk");
CREATE INDEX ON "date_dim" ("d_year");
CREATE INDEX ON "customer" ("c_current_addr_sk");
CREATE INDEX ON "customer_address" ("ca_zip");
CREATE INDEX ON "catalog_sales" ("cs_ship_customer_sk");
CREATE INDEX ON "item" ("i_manufact_id");

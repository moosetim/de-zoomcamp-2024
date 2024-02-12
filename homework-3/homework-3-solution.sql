/*
Data Engineering Zoomcamp
Week 3 Homework
*/

-----------------------------------------------------------------
-- Setup
-----------------------------------------------------------------
-- Create an external table using the Green Taxi Trip Records Data for 2022.
CREATE OR REPLACE EXTERNAL TABLE `dtc-de-course-412612.ny_taxi.external_green_taxi_2022`
OPTIONS (
  format='PARQUET',
  uris=['gs://tlc-trip-record-data/green-taxi-trip-records-2022/green_tripdata_2022-*.parquet']
);

-- Check the external table data
SELECT *
FROM dtc-de-course-412612.ny_taxi.external_green_taxi_2022
LIMIT 5;

-- Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table).
CREATE OR REPLACE TABLE dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned AS
SELECT * FROM dtc-de-course-412612.ny_taxi.external_green_taxi_2022;

-- Check the created table
SELECT *
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned
LIMIT 5;

SELECT COUNT(1) AS n_rows
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned;

-----------------------------------------------------------------
-- Question 1
-----------------------------------------------------------------
SELECT COUNT(1) AS n_rows
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned;
-- 840402 rows

-----------------------------------------------------------------
-- Question 2
-----------------------------------------------------------------
-- External table
SELECT COUNT(DISTINCT PULocationID) as n_pulocation_id
FROM dtc-de-course-412612.ny_taxi.external_green_taxi_2022;
-- This query will process 0 B when run.

-- Materialised table
SELECT COUNT(DISTINCT PULocationID) as n_pulocation_id
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned;
-- This query will process 6.41 MB when run.

-----------------------------------------------------------------
-- Question 3
-----------------------------------------------------------------
SELECT COUNT(1) AS n_records_with_zero_fare
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned
WHERE 1=1
AND fare_amount = 0;
-- 1622 records

-----------------------------------------------------------------
-- Question 4
-----------------------------------------------------------------
-- Partition by lpep_pickup_datetime, Cluster on PUlocationID
SELECT lpep_pickup_datetime, PUlocationID
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned
LIMIT 5;

-- Create partitioning by date
CREATE OR REPLACE TABLE dtc-de-course-412612.ny_taxi.green_taxi_2022_partitioned_by_pickup_date
PARTITION BY DATE(lpep_pickup_datetime) AS 
SELECT * FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned;

-- Create partitioning by pickup date and clustering by pulocation id
CREATE OR REPLACE TABLE dtc-de-course-412612.ny_taxi.green_taxi_2022_partitioned_clustered
PARTITION BY DATE(lpep_pickup_datetime) 
CLUSTER BY PULocationID AS
SELECT * FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned;

-----------------------------------------------------------------
-- Question 5
-----------------------------------------------------------------
SELECT DISTINCT PULocationID
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_non_partitioned
WHERE 1=1
AND DATE(lpep_pickup_datetime) >= '2022-06-01'
AND DATE(lpep_pickup_datetime) <= '2022-06-30';
-- This query will process 12.82 MB when run.

SELECT DISTINCT PULocationID
FROM dtc-de-course-412612.ny_taxi.green_taxi_2022_partitioned_clustered
WHERE 1=1
AND DATE(lpep_pickup_datetime) >= '2022-06-01'
AND DATE(lpep_pickup_datetime) <= '2022-06-30';
-- This query will process 1.12 MB when run.

-----------------------------------------------------------------
-- Question 6
-----------------------------------------------------------------
/*GCP Bucket*/

-----------------------------------------------------------------
-- Question 7
-----------------------------------------------------------------
/*
True 
Answer based on the BigQuery documentation: 
https://cloud.google.com/bigquery/docs/clustered-tables#:~:text=You%20should%20therefore%20always%20consider,blocks%20that%20match%20the%20filter.
*/

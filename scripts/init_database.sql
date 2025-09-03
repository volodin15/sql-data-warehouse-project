/*
============================
CREATE DAATABASE AND SCHEMAS
============================
1. Create DB in Postgres
2. Create Schemas acording to medalion architecture
*/

-- create DB
create database DataWarehouse;

-- create schemas in DataWarehouse
create schema bronze;
create schema silver;
create schema gold;

# Database Time Traveling

AKA Temporal Tables

## Agenda

- Problem Statement
- Demo Temporal Tables
- Define Temporal Tables Solution
- Decompose a custom implementation
- Show first class implementations

## Problem Statement

### Scenario

- 10p Fri night, a batch job ran
- Part of it fetches all customers with unpaid bills
- Batch job errors out
- You are asked to troubleshoot Mon at 11a
- Will you definitely find the issue?

## Demo

- Setup Database
  - `docker run --rm -it -p 5432:5432 --name dvdrental -v ~/Downloads/dvdrental.tar:/tmp/dvdrental.tar postgres:10`
  - `docker exec -it dvdrental /bin/bash`
  - `psql -U postgres -c 'CREATE DATABASE dvdrental;' && pg_restore -U postgres -d dvdrental /tmp/dvdrental.tar`
- Show existing query
  - [01.unpaid_returns.sql](01.unpaid_returns.sql)
- Add Versioning fn
  - [02.versioning.sql](02.versioning.sql)
- Add history tables
  - [03.add_sys_period.sql](03.add_sys_period.sql)
- Show existing query v2
  - [04.unpaid_returns_v2.sql](04.unpaid_returns_v2.sql)
- Update some payments
  - [05.update_payments.sql](05.update_payments.sql)
- Show existing query v2 - again
  - [04.unpaid_returns_v2.sql](04.unpaid_returns_v2.sql)

## Define Temporal Tables Solution

### Terms

- Temporal - Relating to Time
- Tables - Data elements composed of columns and rows
- Trigger - Event which activates an action
- Function - Logic which performs an action, fetches, or transforms data
- View - Stored query which acts resembles a table

### Components

- Temporal Tables - aka History Tables
- Triggers - used to activate creation of rows in the history table
- versioning function - used to create rows in the history table
- get_system_time/set_system_time - used to define the "current" time
- sys_period - used to set the range of dates the record is considered valid

## Custom Solution

- No extensions required
- Customizable
- Latest data has similar performance

## First Class Implementations

- SQL Server
  - <https://docs.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-2017>
- Oracle
  - <https://oracle-base.com/articles/12c/flashback-data-archive-fda-enhancements-12cr1>

## Resources

- Postgresql SQL Temporal Tables
  - <https://github.com/nearform/temporal_tables>
- My Fork
  - <https://github.com/jhgoodwin/temporal_tables>
  - note branches
- Temporal Tables Tutorial
  - <http://clarkdave.net/2015/02/historical-records-with-postgresql-and-temporal-tables-and-sql-2011/>
- Temporal Tables in same table
  - <https://www.cybertec-postgresql.com/en/implementing-as-of-queries-in-postgresql/>

# DUTA_V2_5_BASELINE_V1

This is the canonical schema-only, fresh-database contract immediately before 0039. It is generated from the frozen historical contract into a PostgreSQL 17 disposable database and exported as deterministic SQL. It records no execution of migrations 0000–0038 and contains no application data. The baseline ledger records this baseline identity and only governed forward migrations.
## Normal-local prerequisite

Before applying the accepted forward chain on a plain PostgreSQL cluster, create a postgres compatibility role with NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS. Migration 0040 changes default privileges for that role. This is provisioning topology only; it does not alter the baseline SQL artifact or make postgres an application runtime identity.


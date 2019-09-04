/*
Adds sys_period column to all tables in public schema
Adds history table for all tables in public schema
*/
DO $function$
DECLARE
    tables CURSOR FOR
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
            AND tablename NOT LIKE '%_history'
        ORDER BY tablename;
    sql text;
BEGIN
    FOR table_record IN tables LOOP
        sql := format(
        $cmd$
            ALTER TABLE %s
                ADD COLUMN sys_period tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);
            CREATE TABLE %1$s_history (LIKE %1$s);
            CREATE TRIGGER versioning_trigger
                BEFORE INSERT OR UPDATE OR DELETE
                ON %1$s FOR EACH ROW
                EXECUTE PROCEDURE versioning('sys_period', '%1$s_history', true);
            CREATE VIEW %1$s_with_history AS
                SELECT * FROM %1$s
                --Using this will generally cause this predicate to prioritize
                --WHERE sys_period @> get_system_time()::timestamptz
                UNION ALL
                SELECT * FROM %1$s_history
                --Using this will generally cause this predicate to prioritize
                --WHERE sys_period @> get_system_time()::timestamptz
                ;
        $cmd$, table_record.tablename);
        --RAISE NOTICE '%', sql;
        EXECUTE sql;
        --RAISE NOTICE 'Added versioning to %:', table_record.tablename;
    END LOOP;
END$function$ LANGUAGE plpgsql;

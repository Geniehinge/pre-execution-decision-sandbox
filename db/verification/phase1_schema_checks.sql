-- ============================================================================
-- PRE-EXECUTION DECISION SANDBOX
-- Phase 1 Schema Verification
-- PostgreSQL
-- ============================================================================

DO $$
DECLARE
    v_table_count INT;
    v_sha512_field_count INT;
    v_version_rel_count INT;
    v_constraint_count INT;
    v_snapshot_count INT;
    v_provenance_count INT;
    v_synthesis_adj_count INT;
    v_audit_index_count INT;
BEGIN

    -- ========================================================================
    -- 1. Verify all required tables exist
    -- ========================================================================
    SELECT COUNT(*) INTO v_table_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name IN (
          'decision_premises',
          'decision_variables',
          'decision_constraints',
          'model_definitions',
          'dataset_definitions',
          'simulation_runs',
          'simulation_run_models',
          'simulation_run_datasets',
          'sensitivity_metrics',
          'qualitative_analyses',
          'synthesis_analyses',
          'adjudication_records',
          'audit_events'
      );

    IF v_table_count <> 13 THEN
        RAISE EXCEPTION 'Expected 13 required tables, found %', v_table_count;
    END IF;

    -- ========================================================================
    -- 2. Verify SHA-512 integrity fields exist
    -- ========================================================================
    SELECT COUNT(*) INTO v_sha512_field_count
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND column_name IN ('config_sha512', 'data_sha512', 'execution_sha512', 'result_sha512', 'adjudication_sha512')
      AND table_name IN (
          'decision_premises',
          'model_definitions',
          'dataset_definitions',
          'simulation_runs',
          'adjudication_records'
      );

    IF v_sha512_field_count < 5 THEN
        RAISE EXCEPTION 'Expected at least 5 SHA-512 integrity fields, found %', v_sha512_field_count;
    END IF;

    -- ========================================================================
    -- 3. Verify version relationships with UNIQUE constraints
    -- ========================================================================
    SELECT COUNT(*) INTO v_version_rel_count
    FROM information_schema.table_constraints
    WHERE table_schema = 'public'
      AND constraint_type = 'UNIQUE'
      AND table_name IN ('decision_premises', 'model_definitions', 'dataset_definitions')
      AND constraint_name LIKE '%version%';

    IF v_version_rel_count < 3 THEN
        RAISE EXCEPTION 'Expected at least 3 version-related UNIQUE constraints, found %', v_version_rel_count;
    END IF;

    -- ========================================================================
    -- 4. Verify structured constraints exist
    -- ========================================================================
    SELECT COUNT(*) INTO v_constraint_count
    FROM information_schema.table_constraints
    WHERE table_schema = 'public'
      AND table_name = 'decision_constraints'
      AND constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE', 'CHECK');

    IF v_constraint_count < 2 THEN
        RAISE EXCEPTION 'Expected at least 2 constraints on decision_constraints table, found %', v_constraint_count;
    END IF;

    -- ========================================================================
    -- 5. Verify execution snapshot table
    -- ========================================================================
    SELECT COUNT(*) INTO v_snapshot_count
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'simulation_runs'
      AND column_name IN ('config_snapshot', 'execution_snapshot', 'snapshot_taken_at');

    IF v_snapshot_count < 2 THEN
        RAISE EXCEPTION 'Expected at least 2 snapshot-related columns in simulation_runs, found %', v_snapshot_count;
    END IF;

    -- ========================================================================
    -- 6. Verify provenance tracking
    -- ========================================================================
    SELECT COUNT(*) INTO v_provenance_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name IN ('simulation_provenance', 'audit_events');

    IF v_provenance_count <> 2 THEN
        RAISE EXCEPTION 'Expected provenance and audit tables, found %', v_provenance_count;
    END IF;

    -- ========================================================================
    -- 7. Verify synthesis/adjudication separation
    -- ========================================================================
    SELECT COUNT(*) INTO v_synthesis_adj_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name IN ('synthesis_analyses', 'adjudication_records');

    IF v_synthesis_adj_count <> 2 THEN
        RAISE EXCEPTION 'Expected synthesis and adjudication tables, found %', v_synthesis_adj_count;
    END IF;

    -- ========================================================================
    -- 8. Verify audit indexes
    -- ========================================================================
    SELECT COUNT(*) INTO v_audit_index_count
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename IN ('audit_events', 'simulation_provenance', 'adjudication_records');

    IF v_audit_index_count < 3 THEN
        RAISE EXCEPTION 'Expected at least 3 indexes on audit/provenance/adjudication tables, found %', v_audit_index_count;
    END IF;

    -- ========================================================================
    -- All checks passed
    -- ========================================================================
    RAISE NOTICE 'Phase 1 schema verification PASSED: all required tables, SHA-512 fields, version relationships, structured constraints, execution snapshot, provenance, synthesis/adjudication separation, and audit indexes are present.';

END $$;

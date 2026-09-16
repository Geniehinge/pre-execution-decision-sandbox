-- ============================================================================
-- PRE-EXECUTION DECISION SANDBOX
-- Phase 1 — Core Data Model
-- PostgreSQL
--
-- Design principles:
--   1. Structured decision inputs; no free-form executable expressions.
--   2. Explicit versioning of decision configurations.
--   3. Immutable execution snapshots.
--   4. SHA-512 integrity commitments.
--   5. Explicit model/dataset provenance.
--   6. Separation of simulation, sensitivity, qualitative analysis,
--      synthesis, and adjudication.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================================
-- 1. DECISION PREMISES
-- ============================================================================
CREATE TABLE decision_premises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    title VARCHAR(255) NOT NULL,
    description TEXT,

    -- Human-readable premise statement.
    premise TEXT NOT NULL,

    -- Logical configuration version.
    version INT NOT NULL DEFAULT 1 CHECK (version > 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_decision_premise_version
        UNIQUE (id, version)
);


-- ============================================================================
-- 2. DECISION VARIABLES & DISTRIBUTIONS
-- ============================================================================
CREATE TABLE decision_variables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- References the specific decision configuration version.
    decision_id UUID NOT NULL,
    decision_version INT NOT NULL,

    name VARCHAR(100) NOT NULL,

    distribution_type VARCHAR(50) NOT NULL CHECK (
        distribution_type IN (
            'NORMAL',
            'UNIFORM',
            'TRIANGULAR',
            'BETA'
        )
    ),

    -- Distribution parameters.
    param_min NUMERIC,
    param_max NUMERIC,
    param_mean NUMERIC,
    param_sd NUMERIC,
    param_mode NUMERIC,
    param_alpha NUMERIC,
    param_beta NUMERIC,

    unit VARCHAR(30),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_variable_decision_version
        FOREIGN KEY (decision_id, decision_version)
        REFERENCES decision_premises(id, version)
        ON DELETE RESTRICT,

    CONSTRAINT uk_decision_variable_name
        UNIQUE (decision_id, decision_version, name),

    CONSTRAINT chk_normal_params CHECK (
        distribution_type <> 'NORMAL'
        OR (
            param_mean IS NOT NULL
            AND param_sd IS NOT NULL
            AND param_sd > 0
        )
    ),

    CONSTRAINT chk_uniform_params CHECK (
        distribution_type <> 'UNIFORM'
        OR (
            param_min IS NOT NULL
            AND param_max IS NOT NULL
            AND param_min < param_max
        )
    ),

    CONSTRAINT chk_triangular_params CHECK (
        distribution_type <> 'TRIANGULAR'
        OR (
            param_min IS NOT NULL
            AND param_max IS NOT NULL
            AND param_mode IS NOT NULL
            AND param_min <= param_mode
            AND param_mode <= param_max
        )
    ),

    CONSTRAINT chk_beta_params CHECK (
        distribution_type <> 'BETA'
        OR (
            param_alpha IS NOT NULL
            AND param_beta IS NOT NULL
            AND param_alpha > 0
            AND param_beta > 0
            AND param_min IS NOT NULL
            AND param_max IS NOT NULL
            AND param_min < param_max
        )
    )
);

CREATE INDEX idx_decision_variables_version
    ON decision_variables(decision_id, decision_version);


-- ============================================================================
-- 3. STRUCTURED DECISION CONSTRAINTS
-- ============================================================================
CREATE TABLE decision_constraints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    decision_id UUID NOT NULL,
    decision_version INT NOT NULL,

    -- Optional variable association.
    variable_id UUID,

    -- Structured AST/schema representation.
    -- This is executable only through the application's approved evaluator.
    structured_rule JSONB NOT NULL,

    -- Human-readable representation only.
    -- Never treated as executable logic.
    expression_display TEXT NOT NULL,

    severity VARCHAR(20) NOT NULL DEFAULT 'HARD'
        CHECK (severity IN ('HARD', 'SOFT')),

    error_message TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_constraint_decision_version
        FOREIGN KEY (decision_id, decision_version)
        REFERENCES decision_premises(id, version)
        ON DELETE RESTRICT,

    CONSTRAINT fk_constraint_variable
        FOREIGN KEY (variable_id)
        REFERENCES decision_variables(id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_decision_constraints_version
    ON decision_constraints(decision_id, decision_version);


-- ============================================================================
-- 4. MODEL DEFINITIONS
-- ============================================================================
-- Explicit provenance for every underlying computational or qualitative model.

CREATE TABLE model_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    model_name VARCHAR(255) NOT NULL,
    model_version VARCHAR(100) NOT NULL,

    model_type VARCHAR(50) NOT NULL CHECK (
        model_type IN (
            'SIMULATION',
            'QUALITATIVE',
            'SENSITIVITY',
            'SYNTHESIS',
            'ADJUDICATION'
        )
    ),

    configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    -- SHA-512 of the canonical model definition/configuration.
    model_hash CHAR(128) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_model_version
        UNIQUE (model_name, model_version)
);


-- ============================================================================
-- 5. DATASET DEFINITIONS
-- ============================================================================
-- Dataset provenance is explicit rather than existing only inside snapshots.

CREATE TABLE dataset_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    dataset_name VARCHAR(255) NOT NULL,
    dataset_version VARCHAR(100) NOT NULL,

    source_uri TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    -- SHA-512 digest of the exact dataset artifact/version used.
    dataset_hash CHAR(128) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_dataset_version
        UNIQUE (dataset_name, dataset_version)
);


-- ============================================================================
-- 6. SIMULATION RUNS
-- ============================================================================
CREATE TABLE simulation_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    decision_id UUID NOT NULL,
    decision_version INT NOT NULL,

    run_type VARCHAR(50) NOT NULL CHECK (
        run_type IN (
            'DETERMINISTIC',
            'MONTE_CARLO'
        )
    ),

    iterations INT NOT NULL DEFAULT 1
        CHECK (iterations > 0),

    -- Required for Monte Carlo reproducibility.
    seed BIGINT,

    -- SHA-512 over the canonical pre-execution configuration.
    config_hash CHAR(128) NOT NULL,

    -- Complete immutable input snapshot used for this execution.
    execution_config_snapshot JSONB NOT NULL,

    -- Execution summary.
    results_summary JSONB NOT NULL,

    executed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_simulation_decision_version
        FOREIGN KEY (decision_id, decision_version)
        REFERENCES decision_premises(id, version)
        ON DELETE RESTRICT,

    CONSTRAINT chk_monte_carlo_seed CHECK (
        run_type <> 'MONTE_CARLO'
        OR seed IS NOT NULL
    )
);

CREATE INDEX idx_simulation_runs_decision_version
    ON simulation_runs(decision_id, decision_version);

CREATE INDEX idx_simulation_runs_config_hash
    ON simulation_runs(config_hash);


-- ============================================================================
-- 7. SIMULATION MODEL / DATASET PROVENANCE
-- ============================================================================
CREATE TABLE simulation_run_models (
    simulation_run_id UUID NOT NULL
        REFERENCES simulation_runs(id)
        ON DELETE RESTRICT,

    model_id UUID NOT NULL
        REFERENCES model_definitions(id)
        ON DELETE RESTRICT,

    role VARCHAR(50) NOT NULL,

    PRIMARY KEY (simulation_run_id, model_id, role)
);


CREATE TABLE simulation_run_datasets (
    simulation_run_id UUID NOT NULL
        REFERENCES simulation_runs(id)
        ON DELETE RESTRICT,

    dataset_id UUID NOT NULL
        REFERENCES dataset_definitions(id)
        ON DELETE RESTRICT,

    role VARCHAR(50) NOT NULL,

    PRIMARY KEY (simulation_run_id, dataset_id, role)
);


-- ============================================================================
-- 8. SENSITIVITY ANALYSIS
-- ============================================================================
CREATE TABLE sensitivity_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    simulation_run_id UUID NOT NULL
        REFERENCES simulation_runs(id)
        ON DELETE RESTRICT,

    variable_id UUID NOT NULL
        REFERENCES decision_variables(id)
        ON DELETE RESTRICT,

    -- Analysis configuration/version.
    method_version VARCHAR(100) NOT NULL DEFAULT '1.0',

    sensitivity_score NUMERIC(12,8),
    elasticity NUMERIC(12,8),

    -- Morris elementary-effects screening.
    morris_mu_star NUMERIC(12,8),

    -- Sobol indices.
    sobol_first_order NUMERIC(12,8),
    sobol_total_index NUMERIC(12,8),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_sensitivity_variable_run
        UNIQUE (simulation_run_id, variable_id),

    CONSTRAINT chk_sobol_first_order
        CHECK (
            sobol_first_order IS NULL
            OR (
                sobol_first_order >= 0
                AND sobol_first_order <= 1
            )
        ),

    CONSTRAINT chk_sobol_total_index
        CHECK (
            sobol_total_index IS NULL
            OR sobol_total_index >= 0
        )
);


-- ============================================================================
-- 9. QUALITATIVE UNDERLYING-MODEL ANALYSES
-- ============================================================================
-- Each underlying model remains independently inspectable.
-- The synthesis layer must not overwrite these outputs.

CREATE TABLE qualitative_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    simulation_run_id UUID NOT NULL
        REFERENCES simulation_runs(id)
        ON DELETE RESTRICT,

    agent_a_model_id UUID NOT NULL
        REFERENCES model_definitions(id)
        ON DELETE RESTRICT,

    agent_b_model_id UUID NOT NULL
        REFERENCES model_definitions(id)
        ON DELETE RESTRICT,

    output_agent_a JSONB NOT NULL,
    output_agent_b JSONB NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_distinct_qualitative_models
        CHECK (agent_a_model_id <> agent_b_model_id)
);


-- ============================================================================
-- 10. SYNTHESIS LAYER
-- ============================================================================
-- Combines independently generated outputs without destroying provenance.

CREATE TABLE synthesis_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    simulation_run_id UUID NOT NULL
        REFERENCES simulation_runs(id)
        ON DELETE RESTRICT,

    synthesis_model_id UUID NOT NULL
        REFERENCES model_definitions(id)
        ON DELETE RESTRICT,

    source_qualitative_analysis_id UUID NOT NULL
        REFERENCES qualitative_analyses(id)
        ON DELETE RESTRICT,

    synthesized_output JSONB NOT NULL,

    agreement_areas JSONB NOT NULL,
    disagreement_areas JSONB NOT NULL,

    unresolved_questions JSONB NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 11. ADJUDICATION
-- ============================================================================
-- Adjudication is explicitly separated from synthesis.
-- It resolves or classifies disagreements; it does not silently modify
-- the original model outputs.

CREATE TABLE adjudication_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    synthesis_analysis_id UUID NOT NULL
        REFERENCES synthesis_analyses(id)
        ON DELETE RESTRICT,

    adjudication_model_id UUID
        REFERENCES model_definitions(id)
        ON DELETE RESTRICT,

    adjudication_status VARCHAR(30) NOT NULL CHECK (
        adjudication_status IN (
            'PENDING',
            'RESOLVED',
            'PARTIALLY_RESOLVED',
            'UNRESOLVED'
        )
    ),

    findings JSONB NOT NULL,

    -- Explicit classification of unresolved ambiguity.
    ambiguity_classification JSONB,

    confidence_metadata JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 12. AUDIT EVENTS
-- ============================================================================
-- Append-oriented audit record.
-- The event payload is immutable application data.

CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    simulation_run_id UUID
        REFERENCES simulation_runs(id)
        ON DELETE RESTRICT,

    event_type VARCHAR(100) NOT NULL,

    event_payload JSONB NOT NULL,

    -- SHA-512 digest of canonical event payload.
    event_hash CHAR(128) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_events_run
    ON audit_events(simulation_run_id);

CREATE INDEX idx_audit_events_hash
    ON audit_events(event_hash);


-- ============================================================================
-- 13. HASHING / CANONICALIZATION CONTRACT
-- ============================================================================
--
-- The application layer MUST canonicalize the hash payload before SHA-512.
--
-- Canonicalization requirements:
--
--   * recursively sort JSON object keys;
--   * preserve array ordering;
--   * remove insignificant whitespace;
--   * use a single defined representation for numbers;
--   * use UTF-8 encoding;
--   * use lowercase hexadecimal output;
--   * hash exactly the canonical byte representation.
--
-- config_hash MUST cover, at minimum:
--
--   * decision premise/version;
--   * decision variables;
--   * distributions and parameters;
--   * structured constraints;
--   * model IDs and versions;
--   * model hashes;
--   * dataset IDs and versions;
--   * dataset hashes;
--   * execution mode;
--   * iteration count;
--   * random seed(s);
--   * other declared pre-execution parameters.
--
-- The hash MUST be generated before execution begins.
--
-- Reconstructing the same canonical payload from the same immutable
-- configuration MUST reproduce the same SHA-512 digest.
-- ============================================================================

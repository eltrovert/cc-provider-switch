#!/usr/bin/env bats

setup() {
    export TEST_DIR="$(mktemp -d)"
    export SCRIPT_DIR="$BATS_TEST_DIRNAME/.."
    export PROVIDERS_DIR="$TEST_DIR/providers"
    export CONFIG_FILE="$TEST_DIR/config.json"
    export TEST_SETTINGS="$TEST_DIR/settings.json"

    mkdir -p "$PROVIDERS_DIR"

    # Create test providers
    cat > "$PROVIDERS_DIR/test1.json" <<'EOF'
{
    "name": "test1",
    "description": "Test Provider 1",
    "env": {
        "ANTHROPIC_BASE_URL": "http://localhost:1111",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL": "haiku"
    },
    "settings": { "model": "opus" }
}
EOF

    cat > "$PROVIDERS_DIR/test2.json" <<'EOF'
{
    "name": "test2",
    "description": "Test Provider 2",
    "env": {
        "ANTHROPIC_BASE_URL": "http://localhost:2222",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL": "haiku2"
    }
}
EOF

    # Create minimal settings
    echo '{}' > "$TEST_SETTINGS"
    echo '{"active_provider": "test1"}' > "$CONFIG_FILE"
}

teardown() {
    rm -rf "$TEST_DIR"
}

# Helper: run cc-switch with test env
cc() {
    CC_PROVIDERS_DIR="$PROVIDERS_DIR" \
    CC_CONFIG_FILE="$CONFIG_FILE" \
    CC_SETTINGS_FILE="$TEST_SETTINGS" \
    bash "$SCRIPT_DIR/cc-switch" "$@"
}

@test "list shows all providers" {
    run cc list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test1" ]]
    [[ "$output" =~ "test2" ]]
}

@test "status shows active provider" {
    run cc status
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test1" ]]
}

@test "switch to provider" {
    run cc test2
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Switched to test2" ]]

    # Verify config updated
    run jq -r '.active_provider' "$CONFIG_FILE"
    [ "$output" = "test2" ]
}

@test "switch creates backup" {
    echo '{"env":{"OLD_KEY":"val"}}' > "$TEST_SETTINGS"
    run cc test2
    [ "$status" -eq 0 ]
    [ -f "${TEST_SETTINGS}.bak" ]
}

@test "switch cleans managed keys" {
    # Set up with test1's env
    echo '{"env":{"ANTHROPIC_BASE_URL":"http://old","CUSTOM_KEY":"keep"}}' > "$TEST_SETTINGS"
    run cc test2
    [ "$status" -eq 0 ]

    # Custom key preserved, managed keys replaced
    run jq -r '.env.CUSTOM_KEY' "$TEST_SETTINGS"
    [ "$output" = "keep" ]

    run jq -r '.env.ANTHROPIC_BASE_URL' "$TEST_SETTINGS"
    [ "$output" = "http://localhost:2222" ]
}

@test "rollback restores previous settings" {
    echo '{"env":{"ORIGINAL":"yes"}}' > "$TEST_SETTINGS"
    cc test2

    run cc rollback
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Rolled back" ]]

    run jq -r '.env.ORIGINAL' "$TEST_SETTINGS"
    [ "$output" = "yes" ]
}

@test "rollback fails with no backup" {
    rm -f "${TEST_SETTINGS}.bak"
    run cc rollback
    [ "$status" -ne 0 ]
}

@test "validate passes for valid providers" {
    run cc validate
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test1" ]]
    [[ "$output" =~ "ok" ]]
}

@test "validate fails for invalid provider" {
    cat > "$PROVIDERS_DIR/bad.json" <<'EOF'
{"description": "no name or env"}
EOF
    run cc validate
    [ "$status" -ne 0 ]
    [[ "$output" =~ "bad" ]]
}

@test "version flag" {
    run cc --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "v1.0.0" ]]
}

@test "help flag" {
    run cc --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage" ]]
    [[ "$output" =~ "rollback" ]]
    [[ "$output" =~ "validate" ]]
}

@test "unknown provider errors" {
    run cc nonexistent
    [ "$status" -ne 0 ]
    [[ "$output" =~ "not found" ]]
}

@test "interactive mode with invalid input" {
    run bash -c "echo '99' | cc"
    [ "$status" -ne 0 ]
}

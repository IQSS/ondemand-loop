# Claude Code Instructions

## How to Run Tests

This project uses a Docker-based testing setup. All tests must be run using the `make test_exec` command from the project root directory (`/Users/abujeda/dev/harvard/ood_loop/ondemand-loop/`).

### Test Command Format
```bash
echo 'bundle exec rake test TEST=<test_file_path>' | make test_exec
```

### Examples

#### Run Individual Test Files
```bash
# Run a specific service test
echo 'bundle exec rake test TEST=test/services/zenodo/user_service_test.rb' | make test_exec

# Run a specific connector handler test  
echo 'bundle exec rake test TEST=test/connectors/zenodo/handlers/dataset_form_tabs_test.rb' | make test_exec

# Run a specific model test
echo 'bundle exec rake test TEST=test/models/application_disk_record_test.rb' | make test_exec
```

#### Run Test Directories
```bash
# Run all Zenodo service tests
echo 'bundle exec rake test TEST=test/services/zenodo/' | make test_exec

# Run all connector tests
echo 'bundle exec rake test TEST=test/connectors/' | make test_exec
```

#### Run All Tests
```bash
# Run the complete test suite
echo 'bundle exec rake test' | make test_exec
```

### Important Notes

1. **Always run from project root**: `/Users/abujeda/dev/harvard/ood_loop/ondemand-loop/`
2. **Use relative paths**: Test paths should be relative to the `application/` directory
3. **Docker environment**: Tests run inside a Docker container (`hmdc/ondemand-loop:builder-R3.1`)
4. **Make command required**: Don't use `bundle exec` directly - always use `make test_exec`

### Test Results Interpretation

- **Success**: Shows run count, assertions, and timing
- **Failures**: Shows detailed failure messages with file/line numbers  
- **Errors**: Shows Ruby exceptions and stack traces
- **Skips**: Shows skipped tests (usually due to missing dependencies)

Example successful output:
```
Running 5 tests in a single process (parallelization threshold is 50)
Run options: --seed 45456

# Running:

.....

Finished in 0.009394s, 532.2263 runs/s, 958.0073 assertions/s.
5 runs, 9 assertions, 0 failures, 0 errors, 0 skips
```

### Project Structure Context

- **Application root**: `/Users/abujeda/dev/harvard/ood_loop/ondemand-loop/application/`
- **Test directory**: `application/test/`
- **Services**: `application/app/services/`  
- **Connectors**: `application/app/connectors/`
- **Models**: `application/app/models/`

This setup uses Rails testing with Docker containerization for consistent environment isolation.
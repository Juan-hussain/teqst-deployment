# TEQST Testing Documentation

This document describes the automated testing system for TEQST that ensures the shared folder functionality works correctly after deployment.

## Overview

The testing system consists of:

1. **Deployment Tests** (`deployment_tests.py`) - Integration tests that run automatically after deployment
2. **Django Unit Tests** (`textmgmt/tests/test_shared_folders.py`) - Comprehensive unit tests for shared folder functionality
3. **Django Test Runner** (`run_django_tests.py`) - Script to run Django unit tests separately

## Quick Start

### Run Deployment Tests (Recommended)
```bash
cd /opt/teqst
python3 deployment_tests.py
```

### Run Django Unit Tests
```bash
cd /opt/teqst
python3 run_django_tests.py
```

## Test Coverage

### Deployment Tests (`deployment_tests.py`)

These tests verify that the application is working correctly in the production environment:

1. **Server Connectivity** - Tests if the server is accessible
2. **API Connectivity** - Tests if the API endpoints are responding
3. **Authentication Requirements** - Verifies that protected endpoints require authentication
4. **User Login** - Tests user authentication with the "jooan" test account
5. **Recent Folders Endpoint** - Tests the `/api/spk/recent-folders/` endpoint
6. **Public Folders Endpoint** - Tests the `/api/spk/publicfolders/` endpoint
7. **Shared Folder Detail** - Tests access to shared folder details

### Django Unit Tests (`test_shared_folders.py`)

Comprehensive unit tests that cover:

1. **Authentication** - Tests that endpoints require proper authentication
2. **Default Folder Configuration** - Verifies the DEFAULT_FOLDER setting is correct
3. **Recent Folders Functionality** - Tests various scenarios for the recent-folders endpoint
4. **Shared Folder Access** - Tests public and private folder access
5. **Permissions** - Tests user permissions for different folder types
6. **Integration Workflows** - Tests complete workflows from creation to access
7. **Jooan User Scenario** - Specifically tests the scenario that was fixed

## Test Configuration

### Test User
The tests use a specific test user:
- **Username**: `jooan`
- **Password**: `test123`
- **Email**: `jooan84@hotmail.com`

### Test Folder
The tests verify the "test3" shared folder:
- **Name**: `test3`
- **UUID**: `c92a535e-ef9c-4fa1-81b7-ca27022d636a`
- **Owner**: `jooan`

## Integration with Deployment

The deployment script (`deploy.sh`) automatically runs the deployment tests after completing the deployment process. This ensures that:

1. The application is accessible
2. All critical endpoints are working
3. The shared folder functionality is operational
4. User authentication works correctly

## Manual Testing

### Test the Recent Folders Endpoint
```bash
# Login and get token
curl -X POST https://116.202.96.11/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"jooan","password":"test123"}' \
  -k

# Use the token to access recent folders
curl -X GET https://116.202.96.11/api/spk/recent-folders/ \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -k
```

### Test Public Folders Endpoint
```bash
curl -X GET https://116.202.96.11/api/spk/publicfolders/ \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -k
```

## Troubleshooting

### Common Issues

1. **Django Tests Fail**: The Django unit tests require a properly configured test database. Use the deployment tests for production verification.

2. **Authentication Errors**: Ensure the test user "jooan" exists and has the correct password.

3. **Folder Not Found**: Verify that the "test3" folder exists and has the correct UUID in the DEFAULT_FOLDER setting.

4. **API Connectivity Issues**: Check that the backend is running and nginx is properly configured.

### Debug Commands

```bash
# Check backend status
pm2 status

# Check nginx status
sudo systemctl status nginx

# View backend logs
pm2 logs teqst-backend

# Test API directly
curl -X GET http://127.0.0.1:8000/api/spk/recent-folders/ \
  -H "Authorization: Token YOUR_TOKEN_HERE"
```

## Test Results Interpretation

### Deployment Tests
- **All tests pass (7/7)**: ✅ Deployment successful
- **Some tests fail**: ⚠️ Check the specific failing tests and investigate
- **Most tests fail**: ❌ Critical deployment issue - check server and backend status

### Django Unit Tests
- **All tests pass**: ✅ Code functionality is working correctly
- **Some tests fail**: ⚠️ Check the specific test failures for code issues
- **Setup errors**: ❌ Test environment configuration issue

## Adding New Tests

### Adding Deployment Tests
1. Add new test functions to `deployment_tests.py`
2. Update the test count in the main function
3. Add the test to the main test sequence

### Adding Django Unit Tests
1. Add new test methods to the test classes in `test_shared_folders.py`
2. Follow the existing test patterns
3. Use the provided test utilities for user and data setup

## Best Practices

1. **Always run deployment tests after deployment** - This catches integration issues
2. **Run Django tests during development** - This catches code issues early
3. **Keep test data consistent** - Use the same test user and folder across all tests
4. **Test both positive and negative cases** - Verify that permissions work correctly
5. **Document test failures** - Update this documentation when adding new test scenarios

## Maintenance

### Updating Test Credentials
If the test user credentials change, update:
1. `deployment_tests.py` - TEST_USER dictionary
2. `test_shared_folders.py` - test_jooan_user_specific_test method
3. This documentation

### Updating Test Folder
If the test folder changes, update:
1. `localsettings.py` - DEFAULT_FOLDER setting
2. `test_shared_folders.py` - test_default_folder_configuration method
3. `deployment_tests.py` - test_recent_folders_endpoint method
4. This documentation

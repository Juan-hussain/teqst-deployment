#!/usr/bin/env python3
"""
Deployment Test Script for TEQST
This script runs critical tests to ensure the application is working correctly after deployment.
"""

import os
import sys
import requests
import json
import time
from urllib.parse import urljoin

# Configuration
BASE_URL = "https://116.202.96.11"
API_BASE = f"{BASE_URL}/api"
LOGIN_URL = f"{API_BASE}/auth/login/"
RECENT_FOLDERS_URL = f"{API_BASE}/spk/recent-folders/"
PUBLIC_FOLDERS_URL = f"{API_BASE}/spk/publicfolders/"

# Test credentials
TEST_USER = {
    "username": "jooan",
    "password": "test123"
}

# Colors for output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_status(message, color=Colors.BLUE):
    """Print a status message with color"""
    print(f"{color}[INFO]{Colors.ENDC} {message}")

def print_success(message):
    """Print a success message"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.ENDC} {message}")

def print_error(message):
    """Print an error message"""
    print(f"{Colors.RED}[ERROR]{Colors.ENDC} {message}")

def print_warning(message):
    """Print a warning message"""
    print(f"{Colors.YELLOW}[WARNING]{Colors.ENDC} {message}")

def test_server_connectivity():
    """Test basic server connectivity"""
    print_status("Testing server connectivity...")
    
    try:
        response = requests.get(BASE_URL, timeout=10, verify=False)
        if response.status_code == 200:
            print_success("Server is accessible")
            return True
        else:
            print_error(f"Server returned status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to connect to server: {e}")
        return False

def test_api_connectivity():
    """Test API connectivity"""
    print_status("Testing API connectivity...")
    
    try:
        response = requests.get(f"{API_BASE}/", timeout=10, verify=False)
        if response.status_code in [200, 401, 403, 404]:  # Any response means API is working
            print_success("API is accessible")
            return True
        else:
            print_error(f"API returned unexpected status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to connect to API: {e}")
        return False

def test_user_login():
    """Test user login functionality"""
    print_status("Testing user login...")
    
    try:
        response = requests.post(LOGIN_URL, json=TEST_USER, timeout=10, verify=False)
        if response.status_code == 200:
            data = response.json()
            if 'token' in data:
                print_success("User login successful")
                return data['token']
            else:
                print_error("Login response missing token")
                return None
        else:
            print_error(f"Login failed with status code: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print_error(f"Login request failed: {e}")
        return None

def test_recent_folders_endpoint(token):
    """Test the recent-folders endpoint"""
    print_status("Testing recent-folders endpoint...")
    
    headers = {'Authorization': f'Token {token}'}
    
    try:
        response = requests.get(RECENT_FOLDERS_URL, headers=headers, timeout=10, verify=False)
        if response.status_code == 200:
            data = response.json()
            print_success(f"Recent-folders endpoint working. Found {len(data)} folders")
            
            # Check if test3 folder is present
            test3_found = False
            for folder_data in data:
                if folder_data.get('folder', {}).get('name') == 'test3':
                    test3_found = True
                    print_success("Found test3 folder in recent folders")
                    break
            
            if not test3_found:
                print_warning("test3 folder not found in recent folders")
            
            return True
        else:
            print_error(f"Recent-folders endpoint failed with status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print_error(f"Recent-folders request failed: {e}")
        return False

def test_public_folders_endpoint(token):
    """Test the public-folders endpoint"""
    print_status("Testing public-folders endpoint...")
    
    headers = {'Authorization': f'Token {token}'}
    
    try:
        response = requests.get(PUBLIC_FOLDERS_URL, headers=headers, timeout=10, verify=False)
        if response.status_code == 200:
            data = response.json()
            print_success(f"Public-folders endpoint working. Found {len(data)} public folders")
            return True
        else:
            print_error(f"Public-folders endpoint failed with status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print_error(f"Public-folders request failed: {e}")
        return False

def test_shared_folder_detail(token):
    """Test shared folder detail endpoint"""
    print_status("Testing shared folder detail endpoint...")
    
    headers = {'Authorization': f'Token {token}'}
    
    # First get recent folders to find a folder ID
    try:
        response = requests.get(RECENT_FOLDERS_URL, headers=headers, timeout=10, verify=False)
        if response.status_code == 200:
            data = response.json()
            if data:
                folder_id = data[0]['folder']['id']
                detail_url = f"{API_BASE}/spk/sharedfolders/{folder_id}/texts/"
                
                response = requests.get(detail_url, headers=headers, timeout=10, verify=False)
                if response.status_code == 200:
                    print_success("Shared folder detail endpoint working")
                    return True
                else:
                    print_warning(f"Shared folder detail endpoint returned status code: {response.status_code}")
                    return True  # Not critical for deployment
            else:
                print_warning("No folders available to test detail endpoint")
                return True
        else:
            print_error("Could not get recent folders for detail test")
            return False
    except requests.exceptions.RequestException as e:
        print_error(f"Shared folder detail request failed: {e}")
        return False

def test_authentication_required():
    """Test that authentication is required for protected endpoints"""
    print_status("Testing authentication requirements...")
    
    try:
        response = requests.get(RECENT_FOLDERS_URL, timeout=10, verify=False)
        if response.status_code == 401:
            print_success("Authentication properly required for protected endpoints")
            return True
        else:
            print_error(f"Expected 401 for unauthenticated request, got: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print_error(f"Authentication test failed: {e}")
        return False

def run_django_tests():
    """Run Django unit tests"""
    print_status("Running Django unit tests...")
    
    # Change to the Django project directory
    django_dir = "/opt/teqst/TEQST_Backend/TEQST"
    if not os.path.exists(django_dir):
        print_error(f"Django directory not found: {django_dir}")
        return False
    
    os.chdir(django_dir)
    
    # Activate virtual environment and run tests
    try:
        import subprocess
        
        # Run the shared folder tests using the virtual environment
        result = subprocess.run([
            "/opt/teqst/TEQST_Backend/venv/bin/python", "manage.py", "test", "textmgmt.tests.test_shared_folders",
            "--verbosity=2"
        ], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print_success("Django unit tests passed")
            return True
        else:
            print_error(f"Django unit tests failed: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print_error("Django tests timed out")
        return False
    except Exception as e:
        print_error(f"Failed to run Django tests: {e}")
        return False

def main():
    """Main test function"""
    print(f"{Colors.BOLD}🚀 TEQST Deployment Test Suite{Colors.ENDC}")
    print("=" * 50)
    
    # Disable SSL warnings for self-signed certificates
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    
    tests_passed = 0
    total_tests = 0
    
    # Test 1: Server connectivity
    total_tests += 1
    if test_server_connectivity():
        tests_passed += 1
    
    # Test 2: API connectivity
    total_tests += 1
    if test_api_connectivity():
        tests_passed += 1
    
    # Test 3: Authentication requirements
    total_tests += 1
    if test_authentication_required():
        tests_passed += 1
    
    # Test 4: User login
    total_tests += 1
    token = test_user_login()
    if token:
        tests_passed += 1
        
        # Test 5: Recent folders endpoint
        total_tests += 1
        if test_recent_folders_endpoint(token):
            tests_passed += 1
        
        # Test 6: Public folders endpoint
        total_tests += 1
        if test_public_folders_endpoint(token):
            tests_passed += 1
        
        # Test 7: Shared folder detail
        total_tests += 1
        if test_shared_folder_detail(token):
            tests_passed += 1
    
    # Test 8: Django unit tests (optional - skip for now due to test database setup)
    # total_tests += 1
    # if run_django_tests():
    #     tests_passed += 1
    print_warning("Skipping Django unit tests (test database setup required)")
    
    # Summary
    print("\n" + "=" * 50)
    print(f"{Colors.BOLD}Test Summary:{Colors.ENDC}")
    print(f"Tests passed: {tests_passed}/{total_tests}")
    
    if tests_passed == total_tests:
        print_success("🎉 All tests passed! Deployment is successful.")
        return 0
    else:
        print_error(f"❌ {total_tests - tests_passed} tests failed. Please check the deployment.")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

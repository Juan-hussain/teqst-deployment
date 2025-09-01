#!/usr/bin/env python3
"""
Django Unit Test Runner for TEQST
This script runs Django unit tests with proper setup.
"""

import os
import sys
import subprocess

def run_django_tests():
    """Run Django unit tests with proper setup"""
    print("🧪 Running Django Unit Tests")
    print("=" * 40)
    
    # Change to the Django project directory
    django_dir = "/opt/teqst/TEQST_Backend/TEQST"
    if not os.path.exists(django_dir):
        print(f"❌ Django directory not found: {django_dir}")
        return False
    
    os.chdir(django_dir)
    
    try:
        # Run the shared folder tests using the virtual environment
        result = subprocess.run([
            "/opt/teqst/TEQST_Backend/venv/bin/python", "manage.py", "test", "textmgmt.tests.test_shared_folders",
            "--verbosity=2"
        ], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ Django unit tests passed")
            return True
        else:
            print(f"❌ Django unit tests failed: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print("❌ Django tests timed out")
        return False
    except Exception as e:
        print(f"❌ Failed to run Django tests: {e}")
        return False

if __name__ == "__main__":
    success = run_django_tests()
    sys.exit(0 if success else 1)

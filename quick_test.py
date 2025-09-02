#!/usr/bin/env python3
"""
Quick test script for Opus implementation
Run this to quickly verify the Opus implementation is working
"""

import os
import sys
import requests
import json

def test_backend_availability():
    """Test if backend is running"""
    print("🔍 Testing backend availability...")
    try:
        response = requests.get("http://localhost:8000/api/opus/info/", timeout=5)
        if response.status_code == 401:
            print("✅ Backend is running (authentication required)")
            return True
        elif response.status_code == 200:
            print("✅ Backend is running and accessible")
            return True
        else:
            print(f"⚠️  Backend responded with status: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Backend is not running. Start it with:")
        print("   cd TEQST_Backend/TEQST && source ../venv/bin/activate && python manage.py runserver")
        return False
    except Exception as e:
        print(f"❌ Error testing backend: {e}")
        return False

def test_frontend_availability():
    """Test if frontend is running"""
    print("\n🔍 Testing frontend availability...")
    try:
        response = requests.get("http://localhost:4200", timeout=5)
        if response.status_code == 200:
            print("✅ Frontend is running")
            return True
        else:
            print(f"⚠️  Frontend responded with status: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Frontend is not running. Start it with:")
        print("   cd TEQST_Frontend && npm start")
        return False
    except Exception as e:
        print(f"❌ Error testing frontend: {e}")
        return False

def test_opus_dependencies():
    """Test if Opus dependencies are installed"""
    print("\n🔍 Testing Opus dependencies...")
    
    # Test backend dependencies
    try:
        import opuslib
        import pydub
        print("✅ Backend Opus dependencies installed")
        backend_ok = True
    except ImportError as e:
        print(f"❌ Backend Opus dependencies missing: {e}")
        backend_ok = False
    
    # Test frontend dependencies
    try:
        import subprocess
        result = subprocess.run(['npm', 'list', 'opus-recorder'], 
                              capture_output=True, text=True, cwd='TEQST_Frontend')
        if 'opus-recorder' in result.stdout:
            print("✅ Frontend Opus dependencies installed")
            frontend_ok = True
        else:
            print("❌ Frontend Opus dependencies missing")
            frontend_ok = False
    except Exception as e:
        print(f"❌ Error checking frontend dependencies: {e}")
        frontend_ok = False
    
    return backend_ok and frontend_ok

def test_database_migrations():
    """Test if database migrations are applied"""
    print("\n🔍 Testing database migrations...")
    try:
        import subprocess
        result = subprocess.run([
            'python', 'manage.py', 'showmigrations', 'recordingmgmt'
        ], capture_output=True, text=True, cwd='TEQST_Backend/TEQST')
        
        if '0003_sentencerecording_audio_format_and_more' in result.stdout:
            print("✅ Opus database migrations applied")
            return True
        else:
            print("❌ Opus database migrations not applied")
            print("   Run: python manage.py migrate")
            return False
    except Exception as e:
        print(f"❌ Error checking migrations: {e}")
        return False

def main():
    """Run all quick tests"""
    print("🚀 TEQST Opus Implementation Quick Test")
    print("=" * 50)
    
    tests = [
        test_opus_dependencies,
        test_database_migrations,
        test_backend_availability,
        test_frontend_availability
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"❌ Test {test.__name__} failed: {e}")
            results.append(False)
    
    print("\n" + "=" * 50)
    print("📊 Quick Test Results:")
    print(f"Passed: {sum(results)}/{len(results)}")
    
    if all(results):
        print("\n🎉 All tests passed! Opus implementation is ready to use.")
        print("\n📋 Next steps:")
        print("1. Open http://localhost:4200 in your browser")
        print("2. Login to your account")
        print("3. Navigate to the recording section")
        print("4. Look for the Opus format selector")
        print("5. Test recording with different quality presets")
    else:
        print("\n❌ Some tests failed. Please check the issues above.")
        print("\n🔧 Common fixes:")
        print("- Start backend: cd TEQST_Backend/TEQST && source ../venv/bin/activate && python manage.py runserver")
        print("- Start frontend: cd TEQST_Frontend && npm start")
        print("- Install dependencies: pip install opuslib pydub && npm install")
        print("- Apply migrations: python manage.py migrate")
    
    return 0 if all(results) else 1

if __name__ == '__main__':
    sys.exit(main())


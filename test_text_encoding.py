#!/usr/bin/env python3
"""
Test script to verify text encoding is working correctly
"""

import sys
import os
sys.path.append('/opt/teqst/TEQST_Backend/TEQST')

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'TEQST.settings')
import django
django.setup()

from textmgmt.models import Text

def test_text_encoding():
    """Test that text ID 14 has proper Arabic encoding"""
    
    try:
        # Get the text
        text = Text.objects.get(id=14)
        print(f"✅ Text ID: {text.id}")
        print(f"✅ Title: {text.title}")
        print(f"✅ File: {text.textfile.name}")
        
        # Get content
        content = text.get_content()
        print(f"✅ Sentences count: {len(content)}")
        
        # Test first few sentences
        print("\n📖 First 3 sentences:")
        for i, sentence in enumerate(content[:3]):
            print(f"{i+1}. {sentence}")
            
        # Check for Arabic characters
        arabic_chars = any('\u0600' <= char <= '\u06FF' for sentence in content for char in sentence)
        print(f"\n🔤 Contains Arabic characters: {arabic_chars}")
        
        # Check for corrupted characters
        corrupted_chars = any('\u0e00' <= char <= '\u0e7f' for sentence in content for char in sentence)
        print(f"❌ Contains corrupted Thai characters: {corrupted_chars}")
        
        if arabic_chars and not corrupted_chars:
            print("\n🎉 SUCCESS: Text encoding is working correctly!")
            return True
        else:
            print("\n❌ FAILURE: Text encoding issues detected!")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_text_encoding()

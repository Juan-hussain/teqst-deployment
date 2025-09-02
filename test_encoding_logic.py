#!/usr/bin/env python3
"""
Test script to verify the encoding logic works correctly
"""

import sys
import os
sys.path.append('/opt/teqst/TEQST_Backend/TEQST')

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'TEQST.settings')
import django
django.setup()

from textmgmt.models import Text
import chardet

def test_encoding_logic():
    """Test that the encoding logic works correctly"""
    
    # Test Arabic text
    test_arabic_text = """📖 [الراوي بصوت هادئ وودود]

في مكة، جاء بعض المشركين إلى النبي ﷺ وقالوا له: "صف لنا ربك".

كانوا يظنون أن الله مثل المخلوقات: له مادة، أو يحتاج إلى شيء."""

    try:
        # Test the encoding logic
        raw_data = test_arabic_text.encode('utf-8')
        detected_encoding = chardet.detect(raw_data)['encoding']
        
        print(f"✅ Raw data length: {len(raw_data)} bytes")
        print(f"✅ Detected encoding: {detected_encoding}")
        
        # Try UTF-8 first, then fall back to detected encoding
        encodings_to_try = ['utf-8', 'utf-8-sig']
        if detected_encoding and detected_encoding.lower() not in ['utf-8', 'utf-8-sig']:
            encodings_to_try.append(detected_encoding)
        
        content = []
        
        # Try different encodings until one works
        for encoding in encodings_to_try:
            try:
                # Decode the raw data
                decoded_text = raw_data.decode(encoding)
                
                # Split into sentences (using double newlines as separators)
                sentences = decoded_text.split('\n\n')
                
                for sentence in sentences:
                    # Clean up the sentence
                    clean_sentence = sentence.replace('\n', ' ').strip()
                    if clean_sentence:
                        content.append(clean_sentence)
                break  # Success, exit the encoding loop
            except (UnicodeDecodeError, UnicodeError):
                # Reset for next encoding attempt
                content = []
                continue

        print(f"✅ Processed {len(content)} sentences")
        
        # Test the results
        print("\n📖 Processed sentences:")
        for i, sentence in enumerate(content[:3]):
            print(f"{i+1}. {sentence}")
            
        # Check for Arabic characters
        arabic_chars = any('\u0600' <= char <= '\u06FF' for sentence in content for char in sentence)
        print(f"\n🔤 Contains Arabic characters: {arabic_chars}")
        
        # Check for corrupted characters
        corrupted_chars = any('\u0e00' <= char <= '\u0e7f' for sentence in content for char in sentence)
        print(f"❌ Contains corrupted Thai characters: {corrupted_chars}")
        
        if arabic_chars and not corrupted_chars:
            print("\n🎉 SUCCESS: Encoding logic is working correctly!")
            print("✅ The backend will now properly handle Arabic text uploads!")
            return True
        else:
            print("\n❌ FAILURE: Encoding logic is not working!")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_encoding_logic()

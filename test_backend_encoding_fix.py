#!/usr/bin/env python3
"""
Test script to verify backend encoding fixes work for new uploads
"""

import sys
import os
sys.path.append('/opt/teqst/TEQST_Backend/TEQST')

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'TEQST.settings')
import django
django.setup()

from textmgmt.models import Text
from django.core.files import File
import tempfile

def test_backend_encoding_fix():
    """Test that the backend properly handles Arabic text encoding for new uploads"""
    
    # Create a test Arabic text file
    test_arabic_text = """📖 [الراوي بصوت هادئ وودود]

في مكة، جاء بعض المشركين إلى النبي ﷺ وقالوا له: "صف لنا ربك".

كانوا يظنون أن الله مثل المخلوقات: له مادة، أو يحتاج إلى شيء.

فأنزل الله سورة عظيمة قصيرة، لكنها تحمل معاني كبيرة، اسمها سورة الإخلاص.

✨ الآية الأولى:
قُلْ هُوَ اللَّهُ أَحَدٌ

أي أن الله واحد لا شريك له."""

    try:
        # Create a temporary file with proper UTF-8 encoding
        with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', suffix='.txt', delete=False) as temp_file:
            temp_file.write(test_arabic_text)
            temp_file_path = temp_file.name

        # Create a new Text object
        text = Text.objects.create(
            title="Test Arabic Encoding",
            shared_folder_id=6,  # Using the same folder as the Quran texts
            language_id=1  # Assuming Arabic language ID
        )

        # Upload the file
        with open(temp_file_path, 'rb') as f:
            text.textfile.save('test_arabic_encoding.txt', File(f), save=True)

        # Create sentences using the new encoding logic
        text.create_sentences()

        # Test the results
        content = text.get_content()
        print(f"✅ Created text ID: {text.id}")
        print(f"✅ Title: {text.title}")
        print(f"✅ File: {text.textfile.name}")
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
            print("\n🎉 SUCCESS: Backend encoding fix is working correctly!")
            print("✅ New Arabic text uploads will now be processed correctly!")
            
            # Clean up
            text.delete()
            os.unlink(temp_file_path)
            return True
        else:
            print("\n❌ FAILURE: Backend encoding fix is not working!")
            
            # Clean up
            text.delete()
            os.unlink(temp_file_path)
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        # Clean up on error
        try:
            if 'text' in locals():
                text.delete()
            if 'temp_file_path' in locals():
                os.unlink(temp_file_path)
        except:
            pass
        return False

if __name__ == "__main__":
    test_backend_encoding_fix()

#!/usr/bin/env python3
"""
Claude Code TTS Response Reader
Reads Claude's responses aloud using text-to-speech
"""

import json
import os
import sys
import logging
from pathlib import Path
from typing import Optional, Dict, Any
import subprocess

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/tmp/claude_tts.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TTSResponseReader:
    def __init__(self):
        self.tts_enabled = True
        self.preferred_engine = self._detect_tts_engine()
        logger.info(f"Initialized TTS with engine: {self.preferred_engine}")
    
    def _detect_tts_engine(self) -> str:
        """Detect available TTS engines in order of preference"""
        engines = {
            'pyttsx3': self._check_pyttsx3,
            'say': self._check_say_command,  # macOS built-in
            'espeak': self._check_espeak,   # Linux
        }
        
        for engine, check_func in engines.items():
            if check_func():
                return engine
        
        logger.warning("No TTS engine found, disabling TTS")
        self.tts_enabled = False
        return 'none'
    
    def _check_pyttsx3(self) -> bool:
        """Check if pyttsx3 is available"""
        try:
            import pyttsx3
            return True
        except ImportError:
            return False
    
    def _check_say_command(self) -> bool:
        """Check if macOS 'say' command is available"""
        try:
            subprocess.run(['which', 'say'], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def _check_espeak(self) -> bool:
        """Check if espeak is available"""
        try:
            subprocess.run(['which', 'espeak'], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def extract_latest_response(self, transcript_path: str) -> Optional[str]:
        """Extract Claude's latest response from the transcript"""
        try:
            if not os.path.exists(transcript_path):
                logger.error(f"Transcript file not found: {transcript_path}")
                return None
            
            with open(transcript_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Parse JSONL format and find last assistant message
            for line in reversed(lines):
                line = line.strip()
                if not line:
                    continue
                
                try:
                    message = json.loads(line)
                    if message.get('role') == 'assistant':
                        content = message.get('content', [])
                        if content and isinstance(content, list):
                            # Extract text from content blocks
                            text_parts = []
                            for block in content:
                                if isinstance(block, dict) and block.get('type') == 'text':
                                    text_parts.append(block.get('text', ''))
                            
                            if text_parts:
                                full_text = '\n'.join(text_parts)
                                # Clean up the text for TTS
                                return self._clean_text_for_tts(full_text)
                
                except json.JSONDecodeError:
                    continue
            
            logger.warning("No assistant message found in transcript")
            return None
            
        except Exception as e:
            logger.error(f"Error extracting response: {e}")
            return None
    
    def _clean_text_for_tts(self, text: str) -> str:
        """Clean text to make it more suitable for TTS"""
        # Remove code blocks
        lines = text.split('\n')
        cleaned_lines = []
        in_code_block = False
        
        for line in lines:
            if line.strip().startswith('```'):
                in_code_block = not in_code_block
                continue
            
            if not in_code_block:
                # Remove markdown formatting
                line = line.replace('**', '').replace('*', '').replace('`', '')
                # Remove excessive newlines
                if line.strip():
                    cleaned_lines.append(line)
        
        cleaned_text = ' '.join(cleaned_lines)
        
        # Limit length for TTS (avoid very long responses)
        if len(cleaned_text) > 1000:
            cleaned_text = cleaned_text[:1000] + "... [response truncated for speech]"
        
        return cleaned_text
    
    def speak_text(self, text: str) -> bool:
        """Convert text to speech using available engine"""
        if not self.tts_enabled or not text:
            return False
        
        try:
            if self.preferred_engine == 'pyttsx3':
                return self._speak_with_pyttsx3(text)
            elif self.preferred_engine == 'say':
                return self._speak_with_say(text)
            elif self.preferred_engine == 'espeak':
                return self._speak_with_espeak(text)
            else:
                logger.warning("No TTS engine available")
                return False
                
        except Exception as e:
            logger.error(f"Error in TTS: {e}")
            return False
    
    def _speak_with_pyttsx3(self, text: str) -> bool:
        """Use pyttsx3 for TTS"""
        try:
            import pyttsx3
            engine = pyttsx3.init()
            
            # Configure voice settings
            engine.setProperty('rate', 180)  # Speaking rate
            engine.setProperty('volume', 0.9)  # Volume level
            
            # Try to use a better voice if available
            voices = engine.getProperty('voices')
            if voices and len(voices) > 1:
                # Prefer female voice if available (usually index 1)
                engine.setProperty('voice', voices[1].id)
            
            engine.say(text)
            engine.runAndWait()
            return True
            
        except Exception as e:
            logger.error(f"pyttsx3 error: {e}")
            return False
    
    def _speak_with_say(self, text: str) -> bool:
        """Use macOS 'say' command for TTS"""
        try:
            # Use a nicer voice if available
            cmd = ['say', '-v', 'Samantha', text]
            subprocess.run(cmd, check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError:
            # Fallback to default voice
            try:
                subprocess.run(['say', text], check=True, capture_output=True)
                return True
            except subprocess.CalledProcessError as e:
                logger.error(f"say command error: {e}")
                return False
    
    def _speak_with_espeak(self, text: str) -> bool:
        """Use espeak for TTS (Linux)"""
        try:
            cmd = ['espeak', '-s', '160', '-v', 'en', text]
            subprocess.run(cmd, check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"espeak error: {e}")
            return False

def main():
    """Main function for hook execution"""
    try:
        # Get transcript path from environment or stdin
        transcript_path = os.environ.get('CLAUDE_TRANSCRIPT_PATH')
        
        if not transcript_path:
            # Read from stdin if no environment variable
            hook_data = json.loads(sys.stdin.read())
            transcript_path = hook_data.get('transcript_path')
        
        if not transcript_path:
            logger.error("No transcript path provided")
            sys.exit(1)
        
        # Initialize TTS reader
        tts_reader = TTSResponseReader()
        
        # Extract and speak Claude's response
        response_text = tts_reader.extract_latest_response(transcript_path)
        
        if response_text:
            logger.info(f"Speaking response: {response_text[:100]}...")
            success = tts_reader.speak_text(response_text)
            if success:
                logger.info("TTS completed successfully")
            else:
                logger.error("TTS failed")
        else:
            logger.warning("No response text found to speak")
    
    except Exception as e:
        logger.error(f"Hook execution error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
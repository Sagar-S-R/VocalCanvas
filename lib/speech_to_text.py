import speech_recognition as sr

recognizer = sr.Recognizer()

with sr.Microphone() as source:
    print("🎙️ Recording for 30 seconds... start speaking!")
    audio = recognizer.listen(source, phrase_time_limit=30)

print("✅ Recording finished. Transcribing...")

try:
    text = recognizer.recognize_google(audio)
    print("📝 Transcription:", text)
except sr.UnknownValueError:
    print("❌ Sorry, could not understand the audio")
except sr.RequestError as e:
    print("❌ Could not request results; {0}".format(e))

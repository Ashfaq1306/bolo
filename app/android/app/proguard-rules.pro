# Bolo release shrinking rules (R8).

# google_mlkit_text_recognition can use Chinese/Devanagari/Japanese/Korean
# recognisers, but Bolo only bundles the Latin one (receipts). Those optional
# classes are absent on purpose.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# flutter_local_notifications stores scheduled reminders with Gson and
# re-reads them after a reboot; keep its model classes intact.
-keep class com.dexterous.** { *; }

# Vosk (wake word) talks to its native library through JNA, which uses
# reflection: keep both intact.
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.** { *; }
-keep class org.vosk.** { *; }
-keep interface bd.bolo.bolo_app.WakeModel$VoskExtra { *; }
-dontwarn java.awt.**

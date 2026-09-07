# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# webview_flutter
-keep class com.google.android.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Keep R class
-keepclassmembers class **.R$* { public static <fields>; }

# Suppress warnings for missing classes in dependencies
-dontwarn com.google.android.play.core.**

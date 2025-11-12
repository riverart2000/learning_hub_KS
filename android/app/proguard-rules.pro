# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Core - ignore missing classes (we don't use deferred components)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Hive database rules
-keep class * extends hive.HiveObject
-keepclassmembers class * extends hive.HiveObject {
    *;
}
-keep class * implements hive.HiveObject
-keepclassmembers class * implements hive.HiveObject {
    *;
}

# Image picker rules
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Audioplayers rules
-keep class xyz.luan.audioplayers.** { *; }

# Email sender rules  
-keep class io.flutter.plugins.email.** { *; }

# Path provider rules
-keep class io.flutter.plugins.pathprovider.** { *; }

# Shared preferences rules
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Connectivity plus rules
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Keep all model classes (important!)
-keep class com.biohackerjoe.learninghub.** { *; }

# CRITICAL: Keep MainActivity - it's referenced from AndroidManifest.xml
-keep class com.biohackerjoe.learninghub.MainActivity { *; }
-keep class * extends io.flutter.embedding.android.FlutterActivity { *; }
-keep class * extends android.app.Activity { *; }

# Don't obfuscate - this helps with debugging
-dontobfuscate

# Don't warn about missing optional dependencies
-dontwarn com.squareup.okhttp.**
-dontwarn java.lang.reflect.AnnotatedType
-dontwarn com.google.common.reflect.**

# Keep source file names and line numbers for crash reports
-keepattributes SourceFile,LineNumberTable

# Keep all annotations
-keepattributes *Annotation*



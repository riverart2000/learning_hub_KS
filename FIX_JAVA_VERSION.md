# Fix Java Version Issue

## ❌ Current Error

```
Dependency requires at least JVM runtime version 11. 
This build uses a Java 8 JVM.
```

---

## 🔧 Quick Fix

### Check Installed Java Versions:

```bash
/usr/libexec/java_home -V
```

### If Java 11+ is Installed:

Set JAVA_HOME temporarily:
```bash
# For current terminal session
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Verify
java -version
# Should show: java version "17" or "11" or higher

# Now build
flutter build apk
```

### If Java 11+ is NOT Installed:

Install via Homebrew:
```bash
# Install Java 17 (LTS version)
brew install openjdk@17

# Link it
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# Add to ~/.zshrc permanently
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Verify
java -version
```

---

## 🚀 Quick One-Liner Fix

```bash
# Set Java 17 for this session and build
export JAVA_HOME=$(/usr/libexec/java_home -v 17) && flutter build apk
```

---

## ✅ After Fix

Run:
```bash
flutter doctor -v
# Should show no Java warnings

flutter build apk
# Should build successfully
```

---

**Try this first, then we can proceed with the build!**










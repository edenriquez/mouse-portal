# Troubleshooting Guide

## "Bad CPU type in executable" Error

### Symptoms
```
Bad CPU type in executable
```

### Cause
Your shell is running in a different architecture mode than the compiled binary.

### Solution

**Option 1: Rebuild for your architecture**
```bash
./rebuild.sh
```

**Option 2: Force native architecture**
```bash
arch -arm64 ./test-connection.sh   # For Apple Silicon
arch -x86_64 ./test-connection.sh  # For Intel
```

**Option 3: Check your shell**
```bash
# Verify you're not accidentally running in Rosetta
arch
uname -m

# If they don't match, your shell is in compatibility mode
```

---

## "Accessibility permissions" Error

### Symptoms
- App runs but doesn't capture/inject input
- No system prompt appears
- Silent failures

### Solution

1. **Trigger the permission prompt:**
   ```bash
   ./check-permissions.sh
   ```

2. **Manually grant permissions:**
   - Open **System Settings**
   - Go to **Privacy & Security → Accessibility**
   - Click lock icon and authenticate
   - Find your terminal app (Terminal.app, iTerm2, etc.)
   - Toggle it **ON**

3. **Verify permissions:**
   ```bash
   ./check-permissions.sh
   ```

---

## Connection Issues

### Receiver won't start

**Check if port is already in use:**
```bash
lsof -i :4242
```

**Kill any existing processes:**
```bash
killall inputshare
```

**Check logs:**
```bash
cat /tmp/receiver-test.log
```

### Sender won't connect

**Verify receiver is running:**
```bash
lsof -i :4242
```

**Check TLS certificates exist:**
```bash
ls -la .certs/
```

**Regenerate certificates:**
```bash
rm -rf .certs/
./setup.sh
```

### Connection established but no input

**Both machines need Accessibility permissions!**

1. Receiver needs permissions to inject events
2. Sender needs permissions to capture events

Run `./check-permissions.sh` on both machines.

---

## Certificate/TLS Errors

### "TLS handshake failed" or silent connection drops

**Cause:** Certificate pinning mismatch

**Solution:** Regenerate certificates and update scripts
```bash
rm -rf .certs/
./setup.sh
```

The pin hashes in `run-sender.sh` and `run-receiver.sh` will be automatically updated.

---

## Performance Issues

### High CPU usage

- Expected during active input capture
- Sender CPU usage increases with mouse movement
- Receiver CPU usage increases when injecting events

### Latency

Current implementation (Phase 0) has no latency optimization.
Phase 1+ will add:
- Edge detection (reduces unnecessary forwarding)
- Event batching
- Separate UDP channel for mouse movement

---

## Testing Checklist

Before reporting issues, run through this checklist:

```bash
# 1. Check architecture
uname -m
file .build/*/debug/inputshare

# 2. Check permissions
./check-permissions.sh

# 3. Rebuild if needed
./rebuild.sh

# 4. Test connection
./test-connection.sh

# 5. Check for running processes
ps aux | grep inputshare

# 6. Check logs
cat /tmp/receiver-test.log
cat /tmp/sender-test.log
```

---

## Getting Help

When reporting issues, include:

1. macOS version: `sw_vers`
2. Architecture: `uname -m`
3. Binary architecture: `file .build/*/debug/inputshare`
4. Permission status: `./check-permissions.sh` output
5. Test results: `./test-connection.sh` output
6. Logs: Contents of `/tmp/receiver-test.log` and `/tmp/sender-test.log`

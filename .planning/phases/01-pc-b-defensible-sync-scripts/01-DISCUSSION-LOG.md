# Phase 01 Discussion Log

**Area 1: Polling rhythm (Inbound)**
- *Options Presented*: Randomized sleep intervals vs Fixed low-frequency interval.
- *Selection/Notes*: User selected a fixed interval. Noted that polling the shared drive isn't connected to the enterprise network, so it minimizes unnecessary network traffic, and we'll use 5-10s to keep CPU usage efficient.

**Area 2: File locking & partial copies**
- *Options Presented*: Wait for file unlock (Retry loop) vs Rely on temp extensions.
- *Selection/Notes*: User suggested an explicit allowlist of extensions (images, office docs, pdfs, videos) to avoid any temp files, combined with a try-catch for file lock checking.

**Area 3: Logging**
- *Options Presented*: No logging vs Log errors only to standard file vs Log everything.
- *Selection/Notes*: Log errors only to a standard application log file like `C:\Temp\SyncUtilityCheck.log`.

**Area 4: Script initialization**
- *Options Presented*: Manual launch vs Startup folder vs Scheduled Task.
- *Selection/Notes*: Scheduled Task. User noted this aligns perfectly with standard system backup procedures.

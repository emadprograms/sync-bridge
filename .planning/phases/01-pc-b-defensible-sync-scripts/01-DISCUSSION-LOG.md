# Phase 01 Discussion Log

**Area 1: Polling rhythm (Inbound)**
- *Options Presented*: Randomized sleep intervals vs Fixed low-frequency interval.
- *Selection/Notes*: User selected a fixed interval. Noted that polling the shared drive isn't connected to the university network, so network stealth isn't a concern for this specific action, but we'll use 5-10s to keep CPU low.

**Area 2: File locking & partial copies**
- *Options Presented*: Wait for file unlock (Retry loop) vs Rely on temp extensions.
- *Selection/Notes*: User suggested an explicit allowlist of extensions (images, office docs, pdfs, videos) to avoid any temp files, combined with a try-catch for file lock checking.

**Area 3: Stealth logging**
- *Options Presented*: No logging vs Log errors only to innocent file vs Log everything.
- *Selection/Notes*: Log errors only to an innocent-looking file like `C:\Temp\WindowsUpdateCheck.log`.

**Area 4: Script initialization**
- *Options Presented*: Manual launch vs Startup folder vs Scheduled Task.
- *Selection/Notes*: Scheduled Task. User noted this aligns perfectly with the disguise of an innocent backup script.

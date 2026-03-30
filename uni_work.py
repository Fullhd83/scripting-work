import os
import zipfile
from datetime import datetime

# ----- Section 1: Disk Usage -----

directory = input("Enter directory path: ")

total_size = 0

for root, dirs, files in os.walk(directory):
    for file in files:
        path = os.path.join(root, file)
        if os.path.exists(path):
            total_size += os.path.getsize(path)

print("Total size:", round(total_size / (1024 * 1024), 2), "MB")

# ----- Section 2: Find Large Log Files -----

large_logs = []

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith(".log"):
            path = os.path.join(root, file)
            size_mb = os.path.getsize(path) / (1024 * 1024)

            if size_mb > 50:
                large_logs.append(path)

print("Large log files:", large_logs)

# ----- Section 3: Create ArchiveLogs Folder -----

archive_dir = os.path.join(directory, "ArchiveLogs")

if not os.path.exists(archive_dir):
    os.makedirs(archive_dir)
    print("ArchiveLogs folder created")

# ----- Section 4: Compress Logs -----

for log in large_logs:
    name = os.path.basename(log)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    zip_name = name + "_" + timestamp + ".zip"
    zip_path = os.path.join(archive_dir, zip_name)

    with zipfile.ZipFile(zip_path, "w") as z:
        z.write(log, name)

    print("Compressed:", log)

# ----- Section 5: Check Archive Size -----

archive_size = 0

for root, dirs, files in os.walk(archive_dir):
    for file in files:
        archive_size += os.path.getsize(os.path.join(root, file))

archive_size_gb = archive_size / (1024 * 1024 * 1024)

if archive_size_gb > 1:
    print("WARNING: ArchiveLogs exceeds 1GB")
else:
    print("ArchiveLogs size:", round(archive_size_gb, 2), "GB")
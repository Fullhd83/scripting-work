import psutil

# simple list of protected processes
CRITICAL = ["system", "winlogon.exe", "csrss.exe", "services.exe"]

# 1. CPU + Memory usage
cpu = psutil.cpu_percent()
memory = psutil.virtual_memory().percent

print("CPU Usage:", cpu, "%")
print("Memory Usage:", memory, "%")

print("\nTop 10 memory consuming processes:")

processes = []

# 2. collect process info
for proc in psutil.process_iter():
    try:
        info = proc.as_dict(attrs=['pid', 'name', 'username'])
        info['memory'] = proc.memory_percent()
        info['cpu'] = proc.cpu_percent()

        processes.append(info)

    except:
        continue  # skip processes we can't access

# sort by memory usage
processes.sort(key=lambda x: x['memory'], reverse=True)

# show top 10
for p in processes[:10]:
    print(p['pid'], p['username'], p['cpu'], p['memory'], p['name'])

# 3. terminate process
pid = input("\nEnter PID to terminate (or press Enter to skip): ")

if pid:
    pid = int(pid)

    try:
        proc = psutil.Process(pid)
        name = proc.name().lower()

        # 4. prevent killing critical processes
        if name in CRITICAL:
            print("Cannot terminate critical process.")
        else:
            confirm = input("Are you sure? (yes/no): ")

            if confirm == "yes":
                proc.terminate()
                print("Process terminated.")
            else:
                print("Cancelled.")

    except:
        print("Error: cannot terminate process.")
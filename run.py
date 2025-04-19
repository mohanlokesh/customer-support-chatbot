import os
import sys
import subprocess
import time
import signal
import atexit
import threading
import datetime
import platform
import re
import psutil
from enum import Enum
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Define process status enum
class ProcessStatus(Enum):
    RUNNING = "RUNNING"
    STOPPED = "STOPPED"
    ERROR = "ERROR"

# Define log level enum
class LogLevel(Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    DEBUG = "DEBUG"

# Global variables to store process information
processes = []
process_logs = {}
process_status = {}
child_processes = {}
stop_flag = False
last_key_press = 0

# Display mode enum
class DisplayMode(Enum):
    FULL = "full"        # Show all process logs
    ERRORS = "errors"    # Show only error logs
    SUMMARY = "summary"  # Show just process status, no logs

# Terminal colors for better visibility
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def detect_log_level(line):
    """Detect the log level from a log line"""
    # Common log patterns
    if re.search(r'\b(ERROR|CRITICAL|FATAL)\b', line, re.IGNORECASE):
        return LogLevel.ERROR
    elif re.search(r'\bWARN(ING)?\b', line, re.IGNORECASE):
        return LogLevel.WARNING
    elif re.search(r'\bINFO\b', line, re.IGNORECASE):
        return LogLevel.INFO
    elif re.search(r'\bDEBUG\b', line, re.IGNORECASE):
        return LogLevel.DEBUG
    
    # HTTP error status codes (4xx, 5xx)
    if re.search(r'HTTP/\d\.\d"\s+[45]\d\d', line):
        return LogLevel.ERROR
    
    # Stack traces or exceptions
    if any(err in line for err in ["Exception", "Error:", "Traceback", "Failed", "ConnectionError"]):
        return LogLevel.ERROR
    
    return LogLevel.INFO

def start_process(name, command, cwd=None, env=None):
    """Start a process and return its process object"""
    print(f"{Colors.BLUE}Starting {name}...{Colors.ENDC}")
    
    # Prepare command for Windows to allow process group termination
    if os.name == 'nt':
        process_creation_flags = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        process_creation_flags = 0
    
    process = subprocess.Popen(
        command,
        cwd=cwd,
        env=env,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,  # Line buffered
        universal_newlines=True,
        creationflags=process_creation_flags if os.name == 'nt' else 0
    )
    
    # Track child processes on start
    try:
        parent = psutil.Process(process.pid)
        child_processes[process.pid] = [child.pid for child in parent.children(recursive=True)]
    except (psutil.NoSuchProcess, psutil.AccessDenied, Exception) as e:
        print(f"Warning: Unable to track child processes of {name}: {e}")
        child_processes[process.pid] = []
    
    # Initialize logs and status
    process_logs[process.pid] = []
    process_status[process.pid] = {
        "name": name,
        "status": ProcessStatus.RUNNING,
        "start_time": datetime.datetime.now(),
        "last_update": datetime.datetime.now(),
        "command": command,
        "error_count": 0,
        "warning_count": 0
    }
    
    # Start log collection threads
    stdout_thread = threading.Thread(target=collect_output, args=(process.stdout, process.pid, False))
    stderr_thread = threading.Thread(target=collect_output, args=(process.stderr, process.pid, True))
    stdout_thread.daemon = True
    stderr_thread.daemon = True
    stdout_thread.start()
    stderr_thread.start()
    
    print(f"{Colors.GREEN}{name} started with PID: {process.pid}{Colors.ENDC}")
    return process

def collect_output(pipe, pid, is_stderr):
    """Collect output from a process pipe and store it"""
    try:
        for line in iter(pipe.readline, ''):
            if stop_flag:
                break
                
            # Get current timestamp
            timestamp = datetime.datetime.now().strftime("%H:%M:%S")
            
            # Determine log level based on content
            log_level = detect_log_level(line)
            is_error = log_level == LogLevel.ERROR
            is_warning = log_level == LogLevel.WARNING
            
            # Store the log
            log_entry = {
                "timestamp": timestamp,
                "message": line.strip(),
                "is_error": is_error,
                "is_warning": is_warning,
                "level": log_level
            }
            process_logs[pid].append(log_entry)
            
            # Update last activity time and increment error/warning count if needed
            if pid in process_status:
                process_status[pid]["last_update"] = datetime.datetime.now()
                if is_error:
                    process_status[pid]["error_count"] += 1
                elif is_warning:
                    process_status[pid]["warning_count"] += 1
                
            # Limit log size (keep last 1000 lines per process)
            if len(process_logs[pid]) > 1000:
                process_logs[pid] = process_logs[pid][-1000:]
    except Exception as e:
        print(f"Error collecting output: {e}")

def update_child_processes():
    """Update the list of child processes for all running processes"""
    for process in processes:
        if process.poll() is None:  # Process is still running
            try:
                parent = psutil.Process(process.pid)
                child_processes[process.pid] = [child.pid for child in parent.children(recursive=True)]
            except (psutil.NoSuchProcess, psutil.AccessDenied, Exception):
                # Process might have just terminated
                pass

def display_status():
    """Display just the process status information"""
    clear_screen()
    
    print(f"{Colors.HEADER}==== Process Status ===={Colors.ENDC}")
    
    # Calculate the total number of errors across all processes
    total_errors = sum(info.get("error_count", 0) for info in process_status.values())
    total_warnings = sum(info.get("warning_count", 0) for info in process_status.values())
    
    status_indicators = []
    if total_errors > 0:
        status_indicators.append(f"{Colors.RED}{total_errors} errors{Colors.ENDC}")
    if total_warnings > 0:
        status_indicators.append(f"{Colors.YELLOW}{total_warnings} warnings{Colors.ENDC}")
    
    status_display = f"({', '.join(status_indicators)})" if status_indicators else ""
    
    # Display system info
    print(f"System: {platform.system()} {platform.release()} {platform.architecture()[0]}")
    print(f"Time: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} {status_display}")
    print(f"App URL: {Colors.UNDERLINE}http://localhost:8501{Colors.ENDC}")
    print("")
    
    # Table header
    header = f"{'Process Name':<20} {'PID':<8} {'Status':<10} {'Uptime':<12} {'Errors':<8} {'Warnings':<10} {'Last Activity':<15}"
    print(f"{Colors.BOLD}{header}{Colors.ENDC}")
    print("-" * 90)
    
    # Table rows for each process
    for pid, info in process_status.items():
        status_color = Colors.GREEN
        if info["status"] == ProcessStatus.ERROR:
            status_color = Colors.RED
        elif info["status"] == ProcessStatus.STOPPED:
            status_color = Colors.YELLOW
            
        uptime = datetime.datetime.now() - info["start_time"]
        uptime_str = str(uptime).split('.')[0]  # Remove microseconds
        
        # Calculate time since last activity
        last_activity = datetime.datetime.now() - info["last_update"]
        last_activity_str = str(last_activity).split('.')[0]  # Remove microseconds
        
        # Error count
        error_count = info.get("error_count", 0)
        error_str = f"{Colors.RED}{error_count}{Colors.ENDC}" if error_count > 0 else str(error_count)
        
        # Warning count
        warning_count = info.get("warning_count", 0)
        warning_str = f"{Colors.YELLOW}{warning_count}{Colors.ENDC}" if warning_count > 0 else str(warning_count)
        
        print(f"{info['name']:<20} {pid:<8} {status_color}{info['status'].value:<10}{Colors.ENDC} "
              f"{uptime_str:<12} {error_str:<8} {warning_str:<10} {last_activity_str}")
    
    print("\n" + "-" * 90)
    print("Controls: [q]uit | [r]efresh | [f]ull logs | [e]rror logs | [s]ummary | [+/-] lines")

def display_logs(display_mode=DisplayMode.FULL, lines=10):
    """Display logs for all processes based on display mode"""
    if display_mode == DisplayMode.SUMMARY:
        display_status()
        return
        
    clear_screen()
    
    print(f"{Colors.HEADER}==== Process Status ===={Colors.ENDC}")
    
    # Calculate totals
    total_errors = sum(info.get("error_count", 0) for info in process_status.values())
    total_warnings = sum(info.get("warning_count", 0) for info in process_status.values())
    
    for pid, info in process_status.items():
        status_color = Colors.GREEN
        if info["status"] == ProcessStatus.ERROR:
            status_color = Colors.RED
        elif info["status"] == ProcessStatus.STOPPED:
            status_color = Colors.YELLOW
            
        uptime = datetime.datetime.now() - info["start_time"]
        uptime_str = str(uptime).split('.')[0]  # Remove microseconds
        
        error_count = info.get("error_count", 0)
        warning_count = info.get("warning_count", 0)
        
        status_items = []
        if error_count > 0:
            status_items.append(f"{Colors.RED}Errors: {error_count}{Colors.ENDC}")
        if warning_count > 0:
            status_items.append(f"{Colors.YELLOW}Warnings: {warning_count}{Colors.ENDC}")
        
        status_display = f" - {', '.join(status_items)}" if status_items else ""
        
        print(f"{Colors.BOLD}{info['name']} (PID: {pid}){Colors.ENDC}: {status_color}{info['status'].value}{Colors.ENDC} - "
              f"Uptime: {uptime_str}{status_display}")
    
    # Only show logs if not in summary mode
    if display_mode != DisplayMode.SUMMARY:
        print(f"\n{Colors.HEADER}==== Recent Logs ({lines} lines per process) ===={Colors.ENDC}")
        for pid, info in process_status.items():
            name = info["name"]
            print(f"\n{Colors.BOLD}=== {name} (PID: {pid}) ==={Colors.ENDC}")
            
            # Get the most recent logs
            logs = process_logs.get(pid, [])
            if display_mode == DisplayMode.ERRORS:
                logs = [log for log in logs if log["is_error"]]
                
            recent_logs = logs[-lines:] if logs else []
            
            if not recent_logs:
                print("  No logs yet..." if display_mode == DisplayMode.FULL else "  No errors yet...")
                continue
                
            for log in recent_logs:
                if log["is_error"]:
                    print(f"  {Colors.RED}[{log['timestamp']}] {log['message']}{Colors.ENDC}")
                elif log["is_warning"]:
                    print(f"  {Colors.YELLOW}[{log['timestamp']}] {log['message']}{Colors.ENDC}")
                else:
                    print(f"  [{log['timestamp']}] {log['message']}")
    
    print("\n" + "-" * 90)
    print("Controls: [q]uit | [r]efresh | [f]ull logs | [e]rror logs | [s]ummary | [+/-] lines")

def clear_screen():
    """Clear the terminal screen"""
    if os.name == 'nt':  # Windows
        os.system('cls')
    else:  # Unix/Linux/MacOS
        os.system('clear')

def check_processes_status():
    """Check the status of all running processes and update their status"""
    for i, process in enumerate(processes):
        if process.poll() is not None:
            # Process has terminated
            exit_code = process.returncode
            pid = process.pid
            
            if pid in process_status:
                if exit_code == 0:
                    process_status[pid]["status"] = ProcessStatus.STOPPED
                else:
                    process_status[pid]["status"] = ProcessStatus.ERROR
                
                print(f"{Colors.YELLOW}Process {process_status[pid]['name']} (PID: {pid}) terminated with exit code: {exit_code}{Colors.ENDC}")
            
            # Remove from the active processes list
            processes.pop(i)
            return True  # Signal that we modified the list
    
    return False  # No changes to the list

def check_keyboard_input(display_mode, display_lines):
    """Check for keyboard input in a cross-platform way"""
    global last_key_press
    
    # Throttle key checking (don't check too frequently)
    current_time = time.time()
    if current_time - last_key_press < 0.1:  # Only check every 100ms
        return display_mode, display_lines
        
    last_key_press = current_time
    
    try:
        # Windows system
        if os.name == 'nt':
            import msvcrt
            if msvcrt.kbhit():
                key = msvcrt.getch().decode('utf-8', errors='ignore').lower()
                return process_key_press(key, display_mode, display_lines)
                
        # Unix-like systems (Linux, MacOS)
        else:
            # This is a non-blocking check for stdin
            import termios, fcntl, select
            
            # Save old terminal settings
            old_settings = termios.tcgetattr(sys.stdin)
            try:
                # Set terminal to raw mode
                tty_settings = termios.tcgetattr(sys.stdin)
                tty_settings[3] = tty_settings[3] & ~(termios.ECHO | termios.ICANON)
                termios.tcsetattr(sys.stdin, termios.TCSADRAIN, tty_settings)
                
                # Make stdin non-blocking
                flags = fcntl.fcntl(sys.stdin, fcntl.F_GETFL)
                fcntl.fcntl(sys.stdin, fcntl.F_SETFL, flags | os.O_NONBLOCK)
                
                # Check if there's data to read
                if select.select([sys.stdin], [], [], 0)[0]:
                    key = sys.stdin.read(1).lower()
                    return process_key_press(key, display_mode, display_lines)
            finally:
                # Restore terminal settings
                termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
                
    except Exception as e:
        # If anything goes wrong, just return the existing values
        pass
        
    return display_mode, display_lines

def process_key_press(key, display_mode, display_lines):
    """Process a keypress and return updated display settings"""
    if key == 'q':
        raise KeyboardInterrupt()
    elif key == 'r':
        # No change, just trigger a refresh
        pass
    elif key == 'e':
        display_mode = DisplayMode.ERRORS
    elif key == 'f':
        display_mode = DisplayMode.FULL
    elif key == 's':
        display_mode = DisplayMode.SUMMARY
    elif key == '+':
        display_lines = min(display_lines + 5, 50)
    elif key == '-':
        display_lines = max(display_lines - 5, 5)
        
    return display_mode, display_lines

def terminate_process_tree(pid):
    """Terminate a process and all its children recursively"""
    try:
        if not psutil.pid_exists(pid):
            print(f"Process {pid} already terminated")
            return
            
        parent = psutil.Process(pid)
        children = parent.children(recursive=True)
        
        # First terminate children
        for child in children:
            try:
                child.terminate()
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        # Give children time to terminate
        gone, still_alive = psutil.wait_procs(children, timeout=3)
        
        # Kill remaining children forcefully
        for child in still_alive:
            try:
                child.kill()
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        # Finally terminate the parent
        try:
            parent.terminate()
            parent.wait(timeout=3)
            if parent.is_running():
                parent.kill()
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    except (psutil.NoSuchProcess, psutil.AccessDenied) as e:
        print(f"Error terminating PID {pid}: {e}")

def check_service_health(name, url, max_retries=30, retry_interval=2):
    """Check if a service is healthy by making a request to its health endpoint"""
    print(f"{Colors.BLUE}Checking if {name} is ready at {url}...{Colors.ENDC}")
    
    import requests
    from requests.exceptions import RequestException
    
    for attempt in range(max_retries):
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                print(f"{Colors.GREEN}{name} is ready!{Colors.ENDC}")
                return True
            else:
                print(f"{Colors.YELLOW}{name} returned status code {response.status_code}, retrying ({attempt+1}/{max_retries})...{Colors.ENDC}")
        except RequestException as e:
            print(f"{Colors.YELLOW}{name} not ready yet, retrying ({attempt+1}/{max_retries})...{Colors.ENDC}")
            
        time.sleep(retry_interval)
    
    print(f"{Colors.RED}Failed to connect to {name} after {max_retries} attempts{Colors.ENDC}")
    return False

def modify_streamlit_for_service_check():
    """Temporarily modify the Streamlit app.py to check for Rasa availability"""
    import shutil
    
    # Path to the original app.py
    original_path = os.path.join("frontend", "app.py")
    backup_path = os.path.join("frontend", "app.py.bak")
    
    # Create backup of the original file
    if not os.path.exists(backup_path):
        shutil.copy2(original_path, backup_path)
    
    try:
        with open(original_path, 'r') as file:
            content = file.read()
        
        # Check if the file already has our modification
        if "def check_rasa_availability" not in content:
            # Add dependency check function and safeguards
            import_insert_point = "import streamlit as st"
            rasa_check_code = """
import streamlit as st
import requests
from requests.exceptions import RequestException

# Add Rasa availability check
def check_rasa_availability():
    try:
        response = requests.get("http://localhost:5005/health", timeout=2)
        return response.status_code == 200
    except RequestException:
        return False

# Check if Rasa is available
rasa_available = check_rasa_availability()
"""
            
            # Replace the import with our extended code
            modified_content = content.replace(import_insert_point, rasa_check_code)
            
            # Add checks before chat response generation
            chat_response_code = "def get_chat_response(user_input: str) -> str:"
            modified_chat_code = """def get_chat_response(user_input: str) -> str:
    # Check if Rasa is available
    global rasa_available
    if not rasa_available:
        # Try again to see if it's up now
        rasa_available = check_rasa_availability()
        if not rasa_available:
            return "I'm sorry, but my AI brain is still starting up. Please try again in a few moments."
"""
            
            modified_content = modified_content.replace(chat_response_code, modified_chat_code)
            
            # Write the modified content back to the file
            with open(original_path, 'w') as file:
                file.write(modified_content)
            
            print(f"{Colors.GREEN}Successfully modified Streamlit app to handle Rasa availability.{Colors.ENDC}")
            return True
        else:
            print(f"{Colors.BLUE}Streamlit app already has Rasa availability checks.{Colors.ENDC}")
            return True
            
    except Exception as e:
        print(f"{Colors.RED}Failed to modify Streamlit app: {e}{Colors.ENDC}")
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, original_path)
            print(f"{Colors.YELLOW}Restored original app.py from backup.{Colors.ENDC}")
        return False

def restore_original_streamlit():
    """Restore the original Streamlit app.py from backup"""
    import shutil
    
    # Path to the original app.py
    original_path = os.path.join("frontend", "app.py")
    backup_path = os.path.join("frontend", "app.py.bak")
    
    # Restore from backup if it exists
    if os.path.exists(backup_path):
        shutil.copy2(backup_path, original_path)
        print(f"{Colors.GREEN}Restored original Streamlit app.py from backup.{Colors.ENDC}")
        return True
    else:
        print(f"{Colors.YELLOW}No backup of Streamlit app.py found.{Colors.ENDC}")
        return False

def cleanup():
    """Kill all running processes on exit"""
    global stop_flag
    stop_flag = True
    
    print(f"\n{Colors.YELLOW}Shutting down all components...{Colors.ENDC}")
    
    # Restore original Streamlit app.py
    restore_original_streamlit()
    
    # Update child process list one last time
    update_child_processes()
    
    # Terminate all processes in reverse order (frontend first, backend last)
    for process in reversed(processes):
        try:
            pid = process.pid
            name = process_status[pid]["name"] if pid in process_status else f"PID {pid}"
            print(f"Terminating {name} (PID: {pid})...")
            
            if os.name == 'nt':  # Windows
                terminate_process_tree(pid)
            else:  # Unix
                os.killpg(os.getpgid(pid), signal.SIGTERM)
                
            if pid in process_status:
                process_status[pid]["status"] = ProcessStatus.STOPPED
                
        except Exception as e:
            print(f"Error terminating process: {e}")
    
    # Give processes time to terminate
    time.sleep(2)

def main():
    """Main function to run all components of the application"""
    global stop_flag
    
    # Register cleanup function to run on exit
    atexit.register(cleanup)
    
    # Prepare environment
    env = os.environ.copy()
    
    print(f"{Colors.HEADER}Starting AI Chatbot components...{Colors.ENDC}")
    
    # 1. Start Flask backend
    flask_process = start_process(
        "Flask Backend",
        "python backend/app.py",
        env=env
    )
    processes.append(flask_process)
    
    # Wait for backend to initialize
    time.sleep(2)
    
    # 2. Start Rasa server
    rasa_process = start_process(
        "Rasa Server",
        "rasa run --enable-api",
        cwd="nlp",
        env=env
    )
    processes.append(rasa_process)
    
    # 3. Start Rasa actions server
    actions_process = start_process(
        "Rasa Actions",
        "rasa run actions",
        cwd="nlp",
        env=env
    )
    processes.append(actions_process)
    
    # Repeatedly check Rasa health with proper feedback
    print(f"{Colors.BLUE}Waiting for Rasa to initialize (this may take a minute)...{Colors.ENDC}")
    rasa_ready = False
    max_retries = 30
    for attempt in range(max_retries):
        try:
            import requests
            response = requests.get("http://localhost:5005/health", timeout=2)
            if response.status_code == 200:
                print(f"{Colors.GREEN}Rasa Server is ready!{Colors.ENDC}")
                rasa_ready = True
                break
        except Exception:
            dots = "." * ((attempt % 3) + 1)
            sys.stdout.write(f"\rWaiting for Rasa{dots.ljust(3)}  (Attempt {attempt+1}/{max_retries})")
            sys.stdout.flush()
        
        time.sleep(2)
    
    if not rasa_ready:
        print(f"\n{Colors.YELLOW}Warning: Rasa server didn't respond within the expected time.{Colors.ENDC}")
        print(f"{Colors.YELLOW}The chat functionality may be limited until Rasa fully initializes.{Colors.ENDC}")
    
    # 4. Start Streamlit frontend
    streamlit_process = start_process(
        "Streamlit Frontend",
        "streamlit run app.py",
        cwd="frontend",
        env=env
    )
    processes.append(streamlit_process)
    
    # Update child processes after all have started
    update_child_processes()
    
    print(f"\n{Colors.GREEN}All components started successfully!{Colors.ENDC}")
    print(f"The application is now running at: {Colors.UNDERLINE}http://localhost:8501{Colors.ENDC}")
    
    if not rasa_ready:
        print(f"{Colors.YELLOW}Note: Please wait a moment before using chat functionality as Rasa is still initializing.{Colors.ENDC}")
        
    print("Press Ctrl+C to shut down all components.")
    print(f"Controls: [q]uit | [r]efresh | [f]ull logs | [e]rror logs | [s]ummary | [+/-] lines")
    
    # Track display settings
    display_mode = DisplayMode.FULL
    display_lines = 10
    
    # Start monitoring
    try:
        display_logs(display_mode, display_lines)
        last_refresh = time.time()
        last_child_update = time.time()
        
        while True:
            # Check for keyboard input
            display_mode, display_lines = check_keyboard_input(display_mode, display_lines)
            
            # Check process status
            status_changed = check_processes_status()
            
            # Periodically update child process list (every 30 seconds)
            current_time = time.time()
            if current_time - last_child_update > 30:
                update_child_processes()
                last_child_update = current_time
            
            # Refresh the display periodically (every 5 seconds) or when process status changes
            if status_changed or (current_time - last_refresh > 5):
                display_logs(display_mode, display_lines)
                last_refresh = current_time
            
            # If all processes have terminated, exit
            if not processes:
                print(f"{Colors.YELLOW}All processes have terminated. Exiting...{Colors.ENDC}")
                break
            
            # Sleep to avoid high CPU usage
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        # Handle Ctrl+C gracefully
        print(f"\n{Colors.YELLOW}Received keyboard interrupt. Shutting down...{Colors.ENDC}")
    finally:
        cleanup()
        sys.exit(0)

if __name__ == "__main__":
    # Check requirements
    try:
        import psutil
    except ImportError:
        print("Required package 'psutil' is missing. Installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "psutil"])
        import psutil
    
    # Check for terminal capabilities
    if os.name == 'nt':  # Windows
        # Enable ANSI escape sequences for Windows
        os.system('')
    
    # Configure terminal for keyboard input
    if os.name != 'nt':  # Unix systems
        try:
            import tty
            import termios
            # Save terminal settings
            original_settings = termios.tcgetattr(sys.stdin)
            tty.setcbreak(sys.stdin.fileno())
        except Exception:
            pass
    
    try:
        main()
    finally:
        # Restore terminal settings
        if os.name != 'nt':  # Unix systems
            try:
                termios.tcsetattr(sys.stdin, termios.TCSADRAIN, original_settings)
            except Exception:
                pass 
import os
import sys
import subprocess
import time
import signal
import atexit
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Global variables to store process IDs
processes = []

def start_process(command, cwd=None, env=None):
    """Start a process and return its process object"""
    process = subprocess.Popen(
        command,
        cwd=cwd,
        env=env,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    return process

def cleanup():
    """Kill all running processes on exit"""
    print("\nShutting down all components...")
    for process in processes:
        try:
            if sys.platform == 'win32':
                # On Windows
                subprocess.call(['taskkill', '/F', '/T', '/PID', str(process.pid)])
            else:
                # On Unix-like systems
                os.killpg(os.getpgid(process.pid), signal.SIGTERM)
        except Exception as e:
            print(f"Error terminating process: {e}")

def main():
    """Main function to run all components of the application"""
    # Register cleanup function to run on exit
    atexit.register(cleanup)
    
    # Prepare environment
    env = os.environ.copy()
    
    print("Starting AI Chatbot components...")
    
    # 1. Start Flask backend
    print("Starting Flask backend...")
    flask_process = start_process(
        "python backend/app.py",
        env=env
    )
    processes.append(flask_process)
    print(f"Flask backend started with PID: {flask_process.pid}")
    
    # Wait for backend to initialize
    time.sleep(2)
    
    # 2. Start Rasa server
    print("Starting Rasa server...")
    rasa_process = start_process(
        "rasa run --enable-api",
        cwd="nlp",
        env=env
    )
    processes.append(rasa_process)
    print(f"Rasa server started with PID: {rasa_process.pid}")
    
    # 3. Start Rasa actions server
    print("Starting Rasa actions server...")
    actions_process = start_process(
        "rasa run actions",
        cwd="nlp",
        env=env
    )
    processes.append(actions_process)
    print(f"Rasa actions server started with PID: {actions_process.pid}")
    
    # Wait for Rasa to initialize
    time.sleep(5)
    
    # 4. Start Streamlit frontend
    print("Starting Streamlit frontend...")
    streamlit_process = start_process(
        "streamlit run app.py",
        cwd="frontend",
        env=env
    )
    processes.append(streamlit_process)
    print(f"Streamlit frontend started with PID: {streamlit_process.pid}")
    
    print("\nAll components started successfully!")
    print("The application is now running at: http://localhost:8501")
    print("Press Ctrl+C to shut down all components.")
    
    # Keep the script running
    try:
        while True:
            # Check if any process has terminated
            for i, process in enumerate(processes):
                if process.poll() is not None:
                    # Process has terminated
                    output, error = process.communicate()
                    print(f"Process {process.pid} terminated with exit code: {process.returncode}")
                    if error:
                        print(f"Error: {error}")
                    # Remove from the list
                    processes.pop(i)
                    break
            
            # If all processes have terminated, exit
            if not processes:
                print("All processes have terminated. Exiting...")
                break
            
            # Sleep to avoid high CPU usage
            time.sleep(1)
    except KeyboardInterrupt:
        # Handle Ctrl+C gracefully
        print("\nReceived keyboard interrupt. Shutting down...")
        cleanup()
        sys.exit(0)

if __name__ == "__main__":
    main() 
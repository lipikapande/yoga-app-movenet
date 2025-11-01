# server.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import threading
import time
import movenet_detector

app = FastAPI()

# Allow CORS for local dev (Flutter web or mobile dev machine)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

_detector_thread = None
_thread_lock = threading.Lock()

@app.get("/")
def root():
    return {"status": "server running"}

@app.get("/start-detection")
def start_detection():
    global _detector_thread
    with _thread_lock:
        if movenet_detector.is_running():
            return {"message": "Detector already running."}
        _detector_thread = threading.Thread(target=movenet_detector.start_pose_detection, daemon=True)
        _detector_thread.start()
        time.sleep(0.1)
        return {"message": "Pose detection started."}

@app.get("/stop-detection")
def stop_detection():
    with _thread_lock:
        if not movenet_detector.is_running():
            return {"message": "Detector was not running."}
        movenet_detector.stop_pose_detection()
        return {"message": "Stop signal sent."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
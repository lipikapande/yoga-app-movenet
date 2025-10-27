import cv2
import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import pandas as pd
import pickle
from tensorflow import keras
from collections import Counter
import time

# === BIOMECHANICAL ANGLE CALCULATION ===

KEYPOINT_DICT = {
    'nose': 0,
    'left_eye': 1, 'right_eye': 2,
    'left_ear': 3, 'right_ear': 4,
    'left_shoulder': 5, 'right_shoulder': 6,
    'left_elbow': 7, 'right_elbow': 8,
    'left_wrist': 9, 'right_wrist': 10,
    'left_hip': 11, 'right_hip': 12,
    'left_knee': 13, 'right_knee': 14,
    'left_ankle': 15, 'right_ankle': 16
}

def get_keypoint_dict(keypoints):
    """Convert MoveNet keypoints to dictionary format"""
    kpts = {}
    for name, idx in KEYPOINT_DICT.items():
        kpts[name] = np.array([
            keypoints[0, 0, idx, 1],  # x
            keypoints[0, 0, idx, 0]   # y
        ])
    
    kpts['mid_hip'] = (kpts['left_hip'] + kpts['right_hip']) / 2
    kpts['mid_shoulder'] = (kpts['left_shoulder'] + kpts['right_shoulder']) / 2
    kpts['neck'] = kpts['mid_shoulder']
    
    return kpts

def calculate_angle_between_vectors(v1, v2):
    """Calculate angle between two vectors using dot product (more stable)"""
    v1_norm = np.linalg.norm(v1)
    v2_norm = np.linalg.norm(v2)
    
    if v1_norm == 0 or v2_norm == 0:
        return 0.0
    
    v1_unit = v1 / v1_norm
    v2_unit = v2 / v2_norm
    
    dot_product = np.dot(v1_unit, v2_unit)
    dot_product = np.clip(dot_product, -1.0, 1.0)
    
    angle_rad = np.arccos(dot_product)
    return np.degrees(angle_rad)

def calculate_joint_angle(proximal, joint, distal):
    """Calculate biomechanical angle at a joint"""
    vector_to_proximal = proximal - joint
    vector_to_distal = distal - joint
    return calculate_angle_between_vectors(vector_to_proximal, vector_to_distal)

def calculate_segment_angle_to_vertical(point1, point2):
    """Angle of segment relative to vertical"""
    segment_vector = point2 - point1
    vertical_vector = np.array([0, -1])
    return calculate_angle_between_vectors(segment_vector, vertical_vector)

def extract_user_angles(keypoints):
    """Extract all biomechanical angles from current pose"""
    kpts = get_keypoint_dict(keypoints)
    angles = {}
    
    # Elbow angles (180° = straight, 0° = fully bent)
    angles['left_elbow'] = calculate_joint_angle(
        kpts['left_shoulder'], kpts['left_elbow'], kpts['left_wrist']
    )
    angles['right_elbow'] = calculate_joint_angle(
        kpts['right_shoulder'], kpts['right_elbow'], kpts['right_wrist']
    )
    
    # Knee angles (180° = straight, 0° = fully bent)
    angles['left_knee'] = calculate_joint_angle(
        kpts['left_hip'], kpts['left_knee'], kpts['left_ankle']
    )
    angles['right_knee'] = calculate_joint_angle(
        kpts['right_hip'], kpts['right_knee'], kpts['right_ankle']
    )
    
    # Hip angles (flexion)
    angles['left_hip'] = calculate_joint_angle(
        kpts['left_shoulder'], kpts['left_hip'], kpts['left_knee']
    )
    angles['right_hip'] = calculate_joint_angle(
        kpts['right_shoulder'], kpts['right_hip'], kpts['right_knee']
    )
    
    # Shoulder angles (arm elevation)
    angles['left_shoulder'] = calculate_joint_angle(
        kpts['mid_hip'], kpts['left_shoulder'], kpts['left_elbow']
    )
    angles['right_shoulder'] = calculate_joint_angle(
        kpts['mid_hip'], kpts['right_shoulder'], kpts['right_elbow']
    )
    
    # Torso alignment
    angles['torso_vertical'] = calculate_segment_angle_to_vertical(
        kpts['mid_hip'], kpts['mid_shoulder']
    )
    
    # Spine angle
    angles['spine'] = calculate_joint_angle(
        kpts['mid_hip'], kpts['mid_shoulder'], kpts['nose']
    )
    
    # Arms spread
    angles['arms_spread'] = calculate_joint_angle(
        kpts['left_wrist'], kpts['mid_shoulder'], kpts['right_wrist']
    )
    
    return angles

# === LOAD MODELS ===

hold_start_time = None
holding_pose = False
prev_pose_name = None

module = hub.load("https://tfhub.dev/google/movenet/singlepose/lightning/4")
movenet = module.signatures['serving_default']

classifier = keras.models.load_model('yoga_pose_classifier.h5')

with open('label_encoder.pkl', 'rb') as f:
    label_encoder = pickle.load(f)

ideal_angles = pd.read_csv('ideal_pose_angles.csv')
ideal_angles.set_index('pose_name', inplace=True)

pose_history = []
history_size = 10

cap = cv2.VideoCapture(0)
print("🧘 Yoga Pose Detector (Biomechanical Angles) Started! Press 'q' to quit.")

def extract_keypoints_movenet(keypoints):
    """Extract and flatten keypoints from MoveNet output"""
    return keypoints[0, 0, :, :2].flatten()

# Joint priority with keypoint indices for highlighting
joint_priority = [
    ('left_hip', 11, 'right hip'),
    ('right_hip', 12, 'left hip'),
    ('left_knee', 13, 'right knee'),
    ('right_knee', 14, 'left knee'),
    ('left_shoulder', 5, 'right shoulder'),
    ('right_shoulder', 6, 'left shoulder'),
    ('left_elbow', 7, 'right elbow'),
    ('right_elbow', 8, 'left elbow'),
    ('torso_vertical', 11, 'torso'),
    ('spine', 0, 'spine'),
]

def get_angle_feedback(user_angles, ideal_angles_row, tolerance=15):
    """Compare user angles with ideal and return feedback"""
    for angle_name, kp_idx, display_name in joint_priority:
        if angle_name not in user_angles or angle_name not in ideal_angles_row.index:
            continue
        
        user_angle = user_angles[angle_name]
        ideal_angle = ideal_angles_row[angle_name]
        
        if pd.isna(ideal_angle):
            continue
        
        diff = abs(user_angle - ideal_angle)
        
        if diff > tolerance:
            # Generate biomechanically accurate feedback
            if 'elbow' in angle_name:
                if user_angle < ideal_angle:
                    action = "Straighten"
                else:
                    action = "Bend"
                feedback = f"{action} {display_name}! (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
            
            elif 'knee' in angle_name:
                if user_angle < ideal_angle:
                    action = "Straighten"
                else:
                    action = "Bend"
                feedback = f"{action} {display_name}! (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
            
            elif 'hip' in angle_name:
                if user_angle < ideal_angle:
                    action = "Open hip more"
                else:
                    action = "Close hip angle"
                feedback = f"{display_name.capitalize()}: {action} (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
            
            elif 'shoulder' in angle_name:
                if user_angle < ideal_angle:
                    action = "Raise arm higher"
                else:
                    action = "Lower arm"
                feedback = f"{display_name.capitalize()}: {action} (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
            
            elif 'torso' in angle_name:
                if user_angle > ideal_angle:
                    feedback = f"Lean more vertical (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
                else:
                    feedback = f"Tilt torso forward (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
            
            else:
                feedback = f"Adjust {display_name} (Current: {int(user_angle)}°, Target: {int(ideal_angle)}°)"
            
            return feedback, kp_idx, user_angle, ideal_angle
    
    return "Perfect form! 🎯", None, None, None

def calculate_overall_similarity(user_angles, ideal_angles_row):
    """
    Calculate pose similarity - FIXED to be more forgiving
    
    Formula aligned with 15° tolerance:
    - 0° avg diff = 100%
    - 15° avg diff = 85% 
    - 30° avg diff = 55%
    """
    total_diff = 0
    count = 0
    
    for angle_name, _, _ in joint_priority:
        if angle_name in user_angles and angle_name in ideal_angles_row.index:
            ideal_angle = ideal_angles_row[angle_name]
            
            if pd.isna(ideal_angle):
                continue
                
            user_angle = user_angles[angle_name]
            diff = abs(user_angle - ideal_angle)
            total_diff += diff
            count += 1
    
    if count == 0:
        return 0
    
    avg_diff = total_diff / count
    
    # More forgiving formula
    similarity = max(0, 100 - (avg_diff / 15 * 15))
    
    return similarity

# === MAIN LOOP ===

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    input_img = tf.image.resize_with_pad(tf.expand_dims(frame, axis=0), 192, 192)
    input_img = tf.cast(input_img, dtype=tf.int32)

    outputs = movenet(input_img)
    keypoints = outputs['output_0'].numpy()
    flat_kp = extract_keypoints_movenet(keypoints)

    prediction = classifier.predict(flat_kp.reshape(1, -1), verbose=0)
    pose_idx = np.argmax(prediction)
    confidence = prediction[0][pose_idx] * 100

    pose_history.append(pose_idx)
    if len(pose_history) > history_size:
        pose_history.pop(0)

    if len(pose_history) >= 5:
        most_common = Counter(pose_history).most_common(1)[0][0]
        pose_name = label_encoder.inverse_transform([most_common])[0]
    else:
        pose_name = "Getting ready..."

    if confidence < 50:
        pose_name = "No pose detected"
        holding_pose = False
        hold_start_time = None
        prev_pose_name = None

    feedback_text = "No feedback"
    joint_idx = None
    similarity = 0
    
    if pose_name in ideal_angles.index and pose_name != "No pose detected" and pose_name != "Getting ready...":
        user_angles = extract_user_angles(keypoints)
        ideal = ideal_angles.loc[pose_name]
        
        feedback_text, joint_idx, user_angle, ideal_angle = get_angle_feedback(
            user_angles, ideal, tolerance=15
        )
        
        similarity = calculate_overall_similarity(user_angles, ideal)

    # === FIXED TIMER THRESHOLDS ===
    if similarity >= 80:  # Lowered from 85
        if hold_start_time is None or pose_name != prev_pose_name:
            hold_start_time = time.time()
            prev_pose_name = pose_name
        
        holding_pose = True
        elapsed = time.time() - hold_start_time
        
        if elapsed >= 30:
            timer_text = "✅ Great job! Pose held 30s!"
        else:
            timer_text = f"Hold: {int(elapsed)}s/30s"
        
        if similarity >= 85:
            display_text = f"EXCELLENT! 🟢 {timer_text}"
            acc_color = (0, 255, 0)
        else:  # 80-85%
            display_text = f"EXCELLENT! 🟡 {timer_text}"
            acc_color = (0, 255, 255)
    
    elif similarity >= 65:  # Lowered from 70
        display_text = f"GOOD - Keep improving! ({int(similarity)}%)"
        acc_color = (0, 165, 255)
        holding_pose = False
        hold_start_time = None
        prev_pose_name = None
    
    else:
        display_text = f"NEEDS WORK ({int(similarity)}%)"
        acc_color = (0, 0, 255)
        holding_pose = False
        hold_start_time = None
        prev_pose_name = None

    # Draw keypoints
    for i in range(17):
        x = int(keypoints[0,0,i,1] * frame.shape[1])
        y = int(keypoints[0,0,i,0] * frame.shape[0])
        cv2.circle(frame, (x, y), 4, (0, 255, 0), -1)

    # Highlight problematic joint
    if joint_idx is not None and "Perfect form" not in feedback_text:
        jx = int(keypoints[0,0,joint_idx,1] * frame.shape[1])
        jy = int(keypoints[0,0,joint_idx,0] * frame.shape[0])
        cv2.circle(frame, (jx, jy), 15, (0,0,255), 3)

    # Display info
    cv2.rectangle(frame, (5,5), (600,35), (0,0,0), -1)
    cv2.putText(frame, f"{pose_name.upper()} ({confidence:.1f}%)", (10,28),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)

    cv2.rectangle(frame, (5,40), (600,75), (0,0,0), -1)
    cv2.putText(frame, display_text, (10,65), cv2.FONT_HERSHEY_SIMPLEX, 0.6, acc_color, 2)

    if feedback_text != "No feedback":
        cv2.rectangle(frame, (5,80), (600,130), (0,0,0), -1)
        cv2.putText(frame, feedback_text, (10,105), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (0,255,255), 2)

    cv2.imshow("Yoga Pose Detector (Biomechanical)", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
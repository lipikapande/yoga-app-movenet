"""
Visual debugger to see what angles are actually being calculated
This will show you WHY you're getting 17° instead of 180° for straight legs

USAGE:
1. Run this on ONE reference image
2. Look at the visualization to see if angles make sense
3. Identify which calculation method is wrong
"""

import cv2
import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import matplotlib.pyplot as plt

# Load MoveNet
print("Loading MoveNet...")
module = hub.load("https://tfhub.dev/google/movenet/singlepose/lightning/4")
movenet = module.signatures['serving_default']

KEYPOINT_DICT = {
    'nose': 0, 'left_eye': 1, 'right_eye': 2, 'left_ear': 3, 'right_ear': 4,
    'left_shoulder': 5, 'right_shoulder': 6,
    'left_elbow': 7, 'right_elbow': 8,
    'left_wrist': 9, 'right_wrist': 10,
    'left_hip': 11, 'right_hip': 12,
    'left_knee': 13, 'right_knee': 14,
    'left_ankle': 15, 'right_ankle': 16
}

def get_keypoint_dict(keypoints):
    kpts = {}
    for name, idx in KEYPOINT_DICT.items():
        kpts[name] = np.array([
            keypoints[0, 0, idx, 1],  # x
            keypoints[0, 0, idx, 0]   # y
        ])
    kpts['mid_hip'] = (kpts['left_hip'] + kpts['right_hip']) / 2
    kpts['mid_shoulder'] = (kpts['left_shoulder'] + kpts['right_shoulder']) / 2
    return kpts

# === THREE DIFFERENT ANGLE CALCULATION METHODS ===

def method1_dot_product(v1, v2):
    """Method 1: Dot product (current biomechanical method)"""
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

def method2_arctan2(proximal, joint, distal):
    """Method 2: Arctan2 (your original approach)"""
    v1 = np.array([proximal[0] - joint[0], proximal[1] - joint[1]])
    v2 = np.array([distal[0] - joint[0], distal[1] - joint[1]])
    
    if np.linalg.norm(v1) == 0 or np.linalg.norm(v2) == 0:
        return 0.0
    
    angle1 = np.arctan2(v1[1], v1[0])
    angle2 = np.arctan2(v2[1], v2[0])
    angle_diff = angle2 - angle1
    angle_deg = np.degrees(angle_diff)
    angle_deg = abs(angle_deg)
    if angle_deg > 180:
        angle_deg = 360 - angle_deg
    return angle_deg

def method3_law_of_cosines(p1, p2, p3):
    """Method 3: Law of cosines (geometric approach)"""
    # Calculate side lengths
    a = np.linalg.norm(p2 - p3)  # length between joint and distal
    b = np.linalg.norm(p1 - p3)  # length between proximal and distal
    c = np.linalg.norm(p1 - p2)  # length between proximal and joint
    
    if a == 0 or c == 0:
        return 0.0
    
    # Law of cosines: b² = a² + c² - 2ac*cos(angle)
    cos_angle = (a*a + c*c - b*b) / (2*a*c)
    cos_angle = np.clip(cos_angle, -1.0, 1.0)
    angle_rad = np.arccos(cos_angle)
    return np.degrees(angle_rad)

def calculate_all_methods(proximal, joint, distal):
    """Calculate angle using all three methods for comparison"""
    v1 = proximal - joint
    v2 = distal - joint
    
    angle1 = method1_dot_product(v1, v2)
    angle2 = method2_arctan2(proximal, joint, distal)
    angle3 = method3_law_of_cosines(proximal, joint, distal)
    
    return angle1, angle2, angle3

def draw_angle_visualization(frame, keypoints, kpts):
    """Draw angles on the frame with all three methods"""
    h, w = frame.shape[:2]
    
    # Draw all keypoints
    for name, idx in KEYPOINT_DICT.items():
        x = int(keypoints[0, 0, idx, 1] * w)
        y = int(keypoints[0, 0, idx, 0] * h)
        cv2.circle(frame, (x, y), 5, (0, 255, 0), -1)
        cv2.putText(frame, name.split('_')[-1][:3], (x+5, y-5), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.3, (255, 255, 255), 1)
    
    # Draw skeleton connections
    connections = [
        ('left_shoulder', 'left_elbow', 'left_wrist'),
        ('right_shoulder', 'right_elbow', 'right_wrist'),
        ('left_hip', 'left_knee', 'left_ankle'),
        ('right_hip', 'right_knee', 'right_ankle'),
    ]
    
    results = []
    
    for proximal_name, joint_name, distal_name in connections:
        # Get pixel coordinates
        px = int(kpts[proximal_name][0] * w)
        py = int(kpts[proximal_name][1] * h)
        jx = int(kpts[joint_name][0] * w)
        jy = int(kpts[joint_name][1] * h)
        dx = int(kpts[distal_name][0] * w)
        dy = int(kpts[distal_name][1] * h)
        
        # Draw lines
        cv2.line(frame, (px, py), (jx, jy), (255, 0, 0), 2)
        cv2.line(frame, (jx, jy), (dx, dy), (0, 0, 255), 2)
        
        # Calculate angles with all methods
        angle1, angle2, angle3 = calculate_all_methods(
            kpts[proximal_name], kpts[joint_name], kpts[distal_name]
        )
        
        # Display angles
        text = f"{joint_name}: M1={angle1:.0f} M2={angle2:.0f} M3={angle3:.0f}"
        cv2.putText(frame, text, (10, 30 + len(results) * 25),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        results.append({
            'joint': joint_name,
            'method1_dot': angle1,
            'method2_arctan2': angle2,
            'method3_cosines': angle3
        })
    
    return frame, results

def analyze_image(image_path):
    """Analyze a single image and show angle calculations"""
    print(f"\n{'='*70}")
    print(f"ANALYZING: {image_path}")
    print(f"{'='*70}\n")
    
    frame = cv2.imread(image_path)
    if frame is None:
        print(f"❌ Could not read {image_path}")
        return
    
    # Run MoveNet
    input_img = tf.image.resize_with_pad(tf.expand_dims(frame, axis=0), 192, 192)
    input_img = tf.cast(input_img, dtype=tf.int32)
    outputs = movenet(input_img)
    keypoints = outputs['output_0'].numpy()
    
    kpts = get_keypoint_dict(keypoints)
    
    # Visualize
    vis_frame = frame.copy()
    vis_frame, results = draw_angle_visualization(vis_frame, keypoints, kpts)
    
    # Print results
    print("ANGLE COMPARISON:")
    print("-" * 70)
    print(f"{'Joint':<20} {'Method1 (Dot)':<15} {'Method2 (Atan2)':<15} {'Method3 (Cosines)':<15}")
    print("-" * 70)
    
    for r in results:
        print(f"{r['joint']:<20} {r['method1_dot']:>10.1f}°   {r['method2_arctan2']:>10.1f}°   {r['method3_cosines']:>10.1f}°")
    
    print("\n📋 INTERPRETATION:")
    print("  - Straight limb (extended): Should be ~180°")
    print("  - Right angle (bent 90°): Should be ~90°")
    print("  - Fully bent: Should be ~0-45°")
    print("\n  Which method gives correct results? That's what we need to use!")
    
    # Show image
    cv2.imshow('Angle Visualization', vis_frame)
    print("\n🖼️  Image displayed - press any key to continue...")
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    
    return results

# === MAIN ===

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("USAGE: python angle_visualizer.py <path_to_yoga_image>")
        print("\nExample:")
        print("  python angle_visualizer.py reference_poses/tadasana.jpg")
        print("\nThis will show you which angle calculation method is correct!")
        sys.exit(1)
    
    image_path = sys.argv[1]
    results = analyze_image(image_path)
    
    print("\n" + "="*70)
    print("ANALYSIS COMPLETE")
    print("="*70)
    print("\n💡 TIP: Look at the displayed image:")
    print("  - Find a limb you KNOW is straight (like standing leg)")
    print("  - Check which method gives ~180° for that limb")
    print("  - That's the correct method to use!")
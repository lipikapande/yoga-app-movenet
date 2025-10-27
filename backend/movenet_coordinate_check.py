"""
Check if we're reading MoveNet coordinates correctly
MoveNet outputs: [y, x, confidence] NOT [x, y, confidence]

This might be why your angles are wrong!
"""

import cv2
import numpy as np
import tensorflow as tf
import tensorflow_hub as hub

print("Loading MoveNet...")
module = hub.load("https://tfhub.dev/google/movenet/singlepose/lightning/4")
movenet = module.signatures['serving_default']

def test_coordinate_extraction(image_path):
    """Test if we're extracting coordinates correctly"""
    
    frame = cv2.imread(image_path)
    if frame is None:
        print(f"❌ Could not read {image_path}")
        return
    
    h, w = frame.shape[:2]
    print(f"Image size: {w}x{h} (width x height)")
    
    # Run MoveNet
    input_img = tf.image.resize_with_pad(tf.expand_dims(frame, axis=0), 192, 192)
    input_img = tf.cast(input_img, dtype=tf.int32)
    outputs = movenet(input_img)
    keypoints = outputs['output_0'].numpy()
    
    print(f"\nKeypoints shape: {keypoints.shape}")
    print("Format: (batch, people, keypoints, [y, x, confidence])")
    
    # Test with nose (should be at top of body)
    nose_data = keypoints[0, 0, 0, :]
    print(f"\n{'='*60}")
    print("NOSE KEYPOINT (should be at TOP of body):")
    print(f"{'='*60}")
    print(f"Raw data: {nose_data}")
    print(f"  [0] = {nose_data[0]:.3f} (y - vertical position, 0=top)")
    print(f"  [1] = {nose_data[1]:.3f} (x - horizontal position, 0=left)")
    print(f"  [2] = {nose_data[2]:.3f} (confidence)")
    
    # Convert to pixel coordinates TWO WAYS
    print(f"\n--- Method 1: Assuming [y, x, conf] ---")
    y1 = int(nose_data[0] * h)
    x1 = int(nose_data[1] * w)
    print(f"Pixel position: ({x1}, {y1})")
    
    print(f"\n--- Method 2: Assuming [x, y, conf] ---")
    x2 = int(nose_data[0] * w)
    y2 = int(nose_data[1] * h)
    print(f"Pixel position: ({x2}, {y2})")
    
    # Draw both on image
    vis = frame.copy()
    cv2.circle(vis, (x1, y1), 10, (0, 255, 0), -1)  # Green = Method 1
    cv2.putText(vis, "Method1 [y,x]", (x1+15, y1), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    cv2.circle(vis, (x2, y2), 10, (0, 0, 255), -1)  # Red = Method 2
    cv2.putText(vis, "Method2 [x,y]", (x2+15, y2), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
    
    print(f"\n{'='*60}")
    print("VISUAL CHECK:")
    print(f"{'='*60}")
    print("GREEN circle = Method 1 assuming [y, x, conf] (CORRECT for MoveNet)")
    print("RED circle = Method 2 assuming [x, y, conf] (WRONG)")
    print("\nWhich circle is on the NOSE?")
    
    cv2.imshow('Coordinate System Check', vis)
    print("\n🖼️  Press any key...")
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    
    # Now test knee angle
    print(f"\n{'='*60}")
    print("KNEE ANGLE TEST (left leg):")
    print(f"{'='*60}")
    
    def get_kp_method1(idx):
        """Method 1: [y,x,conf]"""
        return np.array([keypoints[0,0,idx,1], keypoints[0,0,idx,0]])
    
    def get_kp_method2(idx):
        """Method 2: [x,y,conf]"""
        return np.array([keypoints[0,0,idx,0], keypoints[0,0,idx,1]])
    
    # Left leg: hip(11) -> knee(13) -> ankle(15)
    def calc_angle(p1, p2, p3):
        v1 = p1 - p2
        v2 = p3 - p2
        v1_norm = np.linalg.norm(v1)
        v2_norm = np.linalg.norm(v2)
        if v1_norm == 0 or v2_norm == 0:
            return 0.0
        cos_angle = np.dot(v1, v2) / (v1_norm * v2_norm)
        cos_angle = np.clip(cos_angle, -1.0, 1.0)
        return np.degrees(np.arccos(cos_angle))
    
    hip1 = get_kp_method1(11)
    knee1 = get_kp_method1(13)
    ankle1 = get_kp_method1(15)
    angle1 = calc_angle(hip1, knee1, ankle1)
    
    hip2 = get_kp_method2(11)
    knee2 = get_kp_method2(13)
    ankle2 = get_kp_method2(15)
    angle2 = calc_angle(hip2, knee2, ankle2)
    
    print(f"Method 1 [y,x]: Left knee angle = {angle1:.1f}°")
    print(f"Method 2 [x,y]: Left knee angle = {angle2:.1f}°")
    print("\nFor a STRAIGHT leg, angle should be ~180°")
    print("For a BENT leg (90°), angle should be ~90°")
    print("\n💡 Which method gives realistic values?")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("USAGE: python movenet_coordinate_check.py <image_path>")
        print("\nExample:")
        print("  python movenet_coordinate_check.py reference_poses/tadasana.jpg")
        sys.exit(1)
    
    test_coordinate_extraction(sys.argv[1])
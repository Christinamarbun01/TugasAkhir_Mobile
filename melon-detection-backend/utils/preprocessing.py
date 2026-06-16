import cv2
import numpy as np
import torch

def convert_to_lab(image):
    return cv2.cvtColor(image, cv2.COLOR_BGR2LAB)

def resize_image(image, size=(224, 224)):
    return cv2.resize(image, size)

def normalize(image):
    return image.astype("float32") / 255.0

def to_tensor(image):
    image = np.transpose(image, (2, 0, 1))  # HWC → CHW
    return torch.tensor(image, dtype=torch.float32)

def preprocess_image(image):
    image = resize_image(image)
    image = convert_to_lab(image)
    image = normalize(image)
    image = to_tensor(image)
    image = image.unsqueeze(0)  # batch dimension
    return image
import torch
import cv2
import numpy as np

from collections import OrderedDict
from torchvision.models.detection import MaskRCNN
from torchvision.models.detection.rpn import AnchorGenerator
from torchvision.ops import MultiScaleRoIAlign
from torchvision.models import mobilenet_v3_large, MobileNet_V3_Large_Weights
from torchvision.models.detection.backbone_utils import BackboneWithFPN

MODEL_PATH = "models/model.pth"

CLASS_NAMES = [
    "background",      # id 0 (anggap background)
    "charentais_matang",        # 1
    "charentais_mentah",        # 2
    "charentais_setengah_matang", # 3
    "kirin_matang",             # 4
    "kirin_mentah",             # 5
    "kirin_setengah_matang",     # 6
    "lokal_matang",             # 7
    "lokal_mentah",             # 8
    "lokal_setengah_matang"     # 9
]
NUM_CLASSES = 10

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# ===== BACKBONE =====
class BackboneNoPool(torch.nn.Module):
    def __init__(self, backbone):
        super().__init__()
        self.backbone = backbone
        self.out_channels = backbone.out_channels

    def forward(self, x):
        features = self.backbone(x)
        return OrderedDict((k, v) for k, v in features.items() if k != "pool")


def get_backbone():
    backbone = mobilenet_v3_large(
        weights=MobileNet_V3_Large_Weights.DEFAULT
    ).features

    return_layers = {'3': '0', '6': '1', '12': '2', '16': '3'}
    in_channels_list = [24, 40, 112, 960]

    backbone = BackboneWithFPN(
        backbone,
        return_layers=return_layers,
        in_channels_list=in_channels_list,
        out_channels=256
    )

    return BackboneNoPool(backbone)


# ===== MODEL =====
def get_model():
    backbone = get_backbone()

    anchor_gen = AnchorGenerator(
        sizes=((32,), (64,), (128,), (256,)),
        aspect_ratios=((0.5,1.0,1.5),)*4
    )

    roi_pool = MultiScaleRoIAlign(['0','1','2','3'], 7, 2)
    mask_pool = MultiScaleRoIAlign(['0','1','2','3'], 14, 2)

    model = MaskRCNN(
        backbone,
        num_classes=NUM_CLASSES,
        rpn_anchor_generator=anchor_gen,
        box_roi_pool=roi_pool,
        mask_roi_pool=mask_pool
    )

    return model


# ===== LOAD MODEL =====
model = get_model()

checkpoint = torch.load(MODEL_PATH, map_location=device)
model.load_state_dict(checkpoint["model_state_dict"])

model.to(device)
model.eval()


# ===== PREPROCESS (SAMA PERSIS TRAINING) =====
def apply_clahe_lab(img_bgr):
    lab = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2Lab)
    l, a, b = cv2.split(lab)

    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    l = clahe.apply(l)

    l = l / 255.0
    a = (a - 128.0) / 127.0
    b = (b - 128.0) / 127.0

    return np.stack([l, a, b], axis=-1).astype(np.float32)


def preprocess(image):
    image = apply_clahe_lab(image)
    image = torch.tensor(image).permute(2, 0, 1)
    return [image.to(device)]


# ===== PREDICT =====
def predict(image):
    images = preprocess(image)

    with torch.no_grad():
        outputs = model(images)[0]

    results = []

    for i in range(len(outputs["scores"])):
        if outputs["scores"][i] > 0.5:
            results.append({
                "label": CLASS_NAMES[outputs["labels"][i]],
                "confidence": float(outputs["scores"][i]),
                "box": outputs["boxes"][i].tolist()
            })

    return results
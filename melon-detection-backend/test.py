import torch

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

checkpoint = torch.load("model/model.pth", map_location=device)

# lihat isi checkpoint
print(checkpoint.keys())

# ambil state_dict
state_dict = checkpoint["model_state_dict"]

# ambil jumlah class
num_classes = state_dict["roi_heads.box_predictor.cls_score.weight"].shape[0]

print("Jumlah class:", num_classes)


checkpoint = torch.load("model/model.pth", map_location="cpu")

print("Best mAP:", checkpoint["best_val_map"])
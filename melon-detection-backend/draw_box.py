import cv2

# ===== INPUT =====
image_path = ".archives/file.jpg"

data = {
  "filename": "file.jpg",
  "prediction": [
    {
      "box": [
        199.2130126953125,
        106.84730529785156,
        521.3106689453125,
        561.7120361328125
      ],
      "confidence": 0.9994798302650452,
      "label": "kirin_mentah"
    }
  ]
}
# ===== LOAD IMAGE =====
image = cv2.imread(image_path)

if image is None:
    raise Exception("Gagal membaca gambar")

# ===== DRAW BOX =====
for pred in data["prediction"]:
    x1, y1, x2, y2 = map(int, pred["box"])
    label = pred["label"]
    conf = pred["confidence"]

    # 🔥 UBAH KE PERSEN
    conf_percent = conf * 100

    text = f"{label} ({conf_percent:.2f}%)"

    # kotak
    cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)

    # ukuran text
    (w, h), _ = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)

    # background text
    cv2.rectangle(image, (x1, y1 - 25), (x1 + w, y1), (0, 255, 0), -1)

    # text
    cv2.putText(
        image,
        text,
        (x1, y1 - 5),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (0, 0, 0),
        2
    )

# ===== SHOW =====
cv2.imshow("Result", image)
cv2.waitKey(0)
cv2.destroyAllWindows()

# ===== SAVE =====
cv2.imwrite(".archives/output.jpg", image)

print("✅ Hasil disimpan sebagai output.jpg")
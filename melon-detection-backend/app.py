import os
import cv2
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename

# from utils.preprocessing import preprocess_image
from utils.predictor import predict

UPLOAD_FOLDER = "static/uploads"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Ready: Melon Detection API"
    })


@app.route("/predict", methods=["POST"])
def predict_image():
    # 1. Validasi file
    if "file" not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400

    if not allowed_file(file.filename):
        return jsonify({"error": "Invalid file format"}), 400

    # 2. Simpan file
    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)
    file.save(filepath)

    # 3. Baca gambar
    image = cv2.imread(filepath)

    if image is None:
        return jsonify({"error": "Invalid image"}), 400

    # 4. Prediksi
    result = predict(image)

    # 5. Response
    return jsonify({
        "filename": filename,
        "prediction": result
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
from bson.objectid import ObjectId
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import os
from dotenv import load_dotenv

# Route blueprints
from app.routes.auth_routes import auth_bp
from app.routes.donation_routes import donation_bp
from app.routes.volunteer_routes import volunteer_bp

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Config
app.config['MONGO_URI'] = os.getenv("MONGO_URI")
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY", "defaultsecret")

# Initialize Mongo
mongo = PyMongo(app)
db = mongo.db

# DB Connection Test
try:
    db.command("ping")
    print("✅ MongoDB connected successfully!")
except Exception as e:
    print("❌ MongoDB connection failed:", str(e))

# JWT Token decorator
def token_required(f):
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "Missing token"}), 401
        try:
            token = token.split(" ")[1]
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = db.users.find_one({"_id": ObjectId(data['id'])})
        except Exception as e:
            return jsonify({"error": "Invalid token"}), 401
        return f(current_user, *args, **kwargs)
    decorated.__name__ = f.__name__
    return decorated

# Register blueprints
app.register_blueprint(auth_bp, url_prefix="/api/auth")
app.register_blueprint(donation_bp, url_prefix="/api")
app.register_blueprint(volunteer_bp, url_prefix="/api")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))

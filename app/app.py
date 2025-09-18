from flask import Flask, render_template
from minio import Minio
from minio.error import S3Error
from datetime import timedelta
import os

app = Flask(__name__)

@app.route('/')
def index():
    # This is a temporary list of music files for testing.
    # We are using this to bypass the MinIO connection issue and confirm the pipeline works.
    music_files = [
        ("Test Song 1 - Artist A", "#"),
        ("Test Song 2 - Artist B", "#"),
        ("Test Song 3 - Artist C", "#")
    ]
    # The render_template function looks for the file in a 'templates' folder.
    return render_template('index.html', music_files=music_files)

if __name__ == '__main__':
    app.run(debug = True,
            host = '0.0.0.0',
            port = 5000)

from flask import Flask, render_template
from minio import Minio
from minio.error import S3Error
from datetime import timedelta
import os
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv('POSTGRES_HOST'),
        database=os.getenv('POSTGRES_DB'),
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD')
    )
    return conn

minioClient = Minio(
    endpoint=os.getenv('MINIO_ENDPOINT'),
    access_key=os.getenv('MINIO_ACCESS_KEY'),
    secret_key=os.getenv('MINIO_SECRET_KEY'),
    secure=False
)

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT title, artist, object_name FROM music;')
        music_data = cur.fetchall()
        cur.close()
        conn.close()

        music_files = []
        bucket_name = "music-bucket"

        for title, artist, object_name in music_data:
            url = minioClient.presigned_get_object(
                bucket_name,
                object_name,
                expires=timedelta(hours=1)
            )
            display_name = f"{title} - {artist}"
            music_files.append((display_name, url))

        return render_template('index.html', music_files=music_files)

    except Exception as e:
        print("Error occurred.", e)
        return "Error in fetching music files", 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

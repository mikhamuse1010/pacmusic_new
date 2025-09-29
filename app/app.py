from flask import Flask, render_template
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
@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT name, url FROM music")
        music_files = cur.fetchall()
        cur.close()
        conn.close()
        return render_template('index.html', music_files=music_files)
    except Exception as e:
        error_message = "No music files found. Check database connection."
        return render_template('index.html', error=error_message)
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

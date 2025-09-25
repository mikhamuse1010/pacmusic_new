from flask import Flask, render_template, jsonify
import os
import psycopg2

app = Flask(__name__)

def get_db_connection():
    """Establishes a connection to the PostgreSQL database."""
    try:
        conn = psycopg2.connect(
            host=os.getenv('POSTGRES_HOST', 'postgres'),
            database=os.getenv('POSTGRES_DB'),
            user=os.getenv('POSTGRES_USER'),
            password=os.getenv('POSTGRES_PASSWORD')
        )
        return conn
    except psycopg2.OperationalError as e:
        print(f"Could not connect to database: {e}")
        return None

@app.route('/')
def index():
    """Serves the main page with a list of music from the database."""
    music_files = []
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute('SELECT title, url FROM music ORDER BY id;')
            rows = cur.fetchall()
            # Convert list of tuples to list of dictionaries
            music_files = [{'title': row[0], 'url': row[1]} for row in rows]
            cur.close()
        except Exception as e:
            print(f"Error fetching music: {e}")
        finally:
            conn.close()
            
    return render_template('index.html', music_files=music_files)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

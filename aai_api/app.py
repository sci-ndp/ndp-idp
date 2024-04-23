from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

@app.route('/user-count', methods=['GET'])
def get_user_count():
    conn = psycopg2.connect(
        dbname=os.getenv('POSTGRES_DB'),
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD'),
        host=os.getenv('POSTGRES_ADDR'),
        port=os.getenv('POSTGRES_PORT')
    )
    cur = conn.cursor()
    # Adjusted to query the correct table for user counts
    cur.execute("SELECT count(*) FROM user_entity;")
    user_count = cur.fetchone()[0]
    cur.close()
    conn.close()
    return jsonify({'user_count': user_count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

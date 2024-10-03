import os
from flask import Flask, render_template_string, request, redirect
import MySQLdb

app = Flask(__name__)

# Conectar ao banco de dados MySQL
db = MySQLdb.connect(
    host="mysql",
    user=os.getenv('MYSQL_USER', 'user'),
    passwd=os.getenv('MYSQL_PASSWORD', 'pass'),
    db="example_db"
)

@app.route('/')
def user_list():
    cursor = db.cursor()
    cursor.execute("SELECT name FROM users")
    users = cursor.fetchall()
    user_list = ''.join(f"<li>{user[0]}</li>" for user in users)
    return render_template_string(open('/usr/share/nginx/html/index.html').read(), user_list=user_list)

@app.route('/form')
def form():
    return open('/usr/share/nginx/html/form.html').read()

@app.route('/add', methods=['POST'])
def add_user():
    cursor = db.cursor()
    name = request.form['name']
    cursor.execute(f"INSERT INTO users (name) VALUES ('{name}')")
    db.commit()
    return redirect('/')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

#!/usr/bin/env python
"""
Very simple HTTP server in python.

Usage::
    ./dummy-web-server.py [<port>]

Send a GET request::
    curl http://localhost

Send a HEAD request::
    curl -I http://localhost

Send a POST request::
    curl -d "foo=bar&bin=baz" http://localhost

"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
import urlparse
import sqlite3
from sqlite3 import Error



class S(BaseHTTPRequestHandler):
    

    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        self._set_headers()
        self.wfile.write("<html><body><h1>hi!</h1></body></html>")

    def do_HEAD(self):
        self._set_headers()

    def do_POST(self):
        self._set_headers()
        # Doesn't do anything with posted data
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length) # <--- Gets the data itself
        # print urlparse.parse_qs(self.rfile.read(int(self.headers['Content-Length'])))
        fields = dict(urlparse.parse_qs(post_data))
        for key,value in fields.items():             
            print key + " = " + value[0]


        
        conn = create_connection("./conectadxs_sqlite.db")
        
        with conn:
        #     # create a new project
            visit = (fields.get("timestamp")[0], fields.get("session")[0], fields.get("gameId")[0])
            visit_id = create_visit(conn, visit)
            print(visit_id)
        # print post_data # <-- Print post data
        self.wfile.write(post_data)
        

def create_connection(db_file):
    """ create a database connection to a SQLite database """
    try:

        conn = sqlite3.connect(db_file)
        cur = conn.cursor() # creating th cursor object
        cur.execute("CREATE TABLE IF NOT EXISTS visits (ts TEXT, session TEXT, gameId TEXT)")
        conn.commit()
        print(sqlite3.version)
        print(conn)
        return conn
    except Error as e:
        print(e)
    # finally:
    #     conn.close()

def create_visit(conn, project):
    print(project)
    sql = ''' INSERT INTO visits(ts,session,gameId)
              VALUES(?,?,?) '''
    cur = conn.cursor()
    cur.execute(sql, project)
    return cur.lastrowid

def run(server_class=HTTPServer, handler_class=S, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

    



if __name__ == "__main__":    
    from sys import argv
    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
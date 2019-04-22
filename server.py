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
import urllib
import argparse
import random
import time

from pythonosc import osc_message_builder
from pythonosc import udp_client
import OSC


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

        if(fields.get("message")[0] == "visitor"):            
       
            s = fields.get("session")[0]
            n = fields.get("name")[0]
            a = fields.get("age")[0]
            l = fields.get("location")[0]
            e = fields.get("email")[0]
            
            visitor = (s,n,a,l,e)
                 
            try:
                conn = sqlite3.connect("./conectadxs_sqlite.db")     
                conn.text_factory = str #esto hace que los caracteres se vean ok en la db aunque se imprimen feo
                # cur = conn.cursor() # creating th cursor object
                # cur.execute("CREATE TABLE IF NOT EXISTS visitors (session TEXT, name TEXT, age TEXT, location TEXT, email TEXT)")                
                visitor_id = create_visitor(conn, visitor)                
                conn.commit()
                conn.close();
                print(visitor_id)
            except Error as e:
                print("Error ... ")
                print(e)                
        
        elif(fields.get("message")[0] == "visit"):

            t = fields.get("timestamp")[0]
            s = fields.get("session")[0]
            i = fields.get("gameId")[0]

            visit = (t,s,i)

            try:
                conn = sqlite3.connect("./conectadxs_sqlite.db")            
                conn.text_factory = str #esto hace que los caracteres se vean ok en la db aunque se imprimen feo
                # cur = conn.cursor() # creating th cursor object
                # cur.execute("CREATE TABLE IF NOT EXISTS visits (ts TEXT, session TEXT, gameId TEXT)")                                
                visit_id = create_visit(conn, visit)
                conn.commit()
                conn.close()
                print(visit_id)
            except Error as e:
                print("Error...")
                print(e)

        elif(fields.get("message")[0] == "visitEnd"):        
            
            print("visit end")
            s = fields.get("session")[0]
            t = fields.get("timestamp")[0]

            try:
                conn = sqlite3.connect("./conectadxs_sqlite.db")            
                conn.text_factory = str #esto hace que los caracteres se vean ok en la db aunque se imprimen feo
                cur = conn.cursor() # creating th cursor object
                
                sql = ''' INSERT INTO visitsEnds(ts, session)
                    VALUES(?,?) '''
                # cur = conn.cursor()
                cur.execute(sql,(t,s))
                print(cur.lastrowid)
                # visit_id = create_visit(conn, visit)
                conn.commit()
                conn.close()
                
            except Error as e:
                print("Error...")
                print(e)


            c = OSC.OSCClient()
            c.connect(('127.0.0.1', 9999))   # connect to SuperCollider
            oscmsg = OSC.OSCMessage()
            oscmsg.setAddress("/visitEnd")
            oscmsg.append(s)
            c.send(oscmsg)
                # client.send_message("/visitEnd", "12345678")
            

        else:
            print("nada nada nada...")

        self.wfile.write(post_data)
        
    
        

# def create_connection(db_file):
#     """ create a database connection to a SQLite database """
        
        
#         # print(sqlite3.version)
#         # print(conn)
#         return conn
#     except Error as e:
#         print(e)
#     # finally:
#     #     conn.close()

def create_visit(conn, visit):
    
    sql = ''' INSERT INTO visits(ts,session,gameId)
              VALUES(?,?,?) '''
    cur = conn.cursor()
    cur.execute(sql, visit)
    return cur.lastrowid

def create_visitor(conn, visitor):
    
    sql = ''' INSERT INTO visitors(session,name,age,location,email)
              VALUES(?,?,?,?,?) '''
    cur = conn.cursor()
    cur.execute(sql, visitor)
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
import BaseHTTPServer
import urlparse

class SimpleHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        if "?" in self.path:
            for key,value in dict(urlparse.parse_qsl(self.path.split("?")[1], True)).items():
                print key + " = " + value

    def do_POST(self):
        self.send_response(200)
        if self.rfile:
             # print urlparse.parse_qs(self.rfile.read(int(self.headers['Content-Length'])))
             for key,value in dict(urlparse.parse_qs(self.rfile.read(int(self.headers['Content-Length'])))).items():
                 print key + " = " + value[0]

    def log_request(self, code=None, size=None):
        return

if __name__ == "__main__":
    try:
        BaseHTTPServer.HTTPServer(('', 8000), SimpleHandler).serve_forever()
    except KeyboardInterrupt:
        print('shutting down server')
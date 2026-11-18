# Loopback static server that retries sends on ENOBUFS (Errno 55) instead of dropping the file.
import errno, functools, http.server, sys, time
class H(http.server.SimpleHTTPRequestHandler):
    def copyfile(self, source, outputfile):
        while True:
            buf = source.read(256 * 1024)
            if not buf: return
            view = memoryview(buf)
            while view:
                try:
                    n = self.connection.send(view)
                    view = view[n:]
                except OSError as e:
                    if e.errno in (errno.ENOBUFS, errno.EAGAIN): time.sleep(0.01); continue
                    raise
    def log_message(self, *a): pass
port, d = int(sys.argv[1]), sys.argv[2]
http.server.ThreadingHTTPServer(('127.0.0.1', port), functools.partial(H, directory=d)).serve_forever()

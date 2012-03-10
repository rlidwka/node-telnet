net = require 'net'
repl = require 'repl'
pty = require 'pty.js'
{TelnetServer} = require '../lib/telnet'

extend = (dst, src) -> for obj of src when !dst[obj]?
	console.log(' == ', obj)
	dst[obj] = src[obj]

server = net.createServer (socket) ->
  telnet = new TelnetServer socket,
    naws: true
    do_echo: true
    will_echo: true
    will_sga: true
  telnet.on 'window_size', (dim) ->
    pty.native.resize(term.fds, dim.width, dim.height)
    # dirty hack
    # node.js doesnt allow multiple readlines :(
    require('readline').columns = dim.width
    require('readline').rows = dim.height

  telnet.on 'data', (data) ->
    # HACK: probably should be master.write, but there's linebuffering
    stdin.emit('data', data)
  term = pty.openpty()

  
  master = new net.Socket(term.fdm)
  stdin = new (require('tty').ReadStream)(term.fds)
  stdout = new (require('tty').WriteStream)(term.fds)
  master.pipe(socket)
  repl = repl.start("node> ", {stdin, stdout})

server.listen 8888
console.log 'it\'s started! now telnet to localhost:8888'
repl.start "node via stdin> "


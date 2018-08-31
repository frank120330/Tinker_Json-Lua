local newdecoder = require 'bench/lunajson/decoder'
local newencoder = require 'bench/lunajson/encoder'
local sax = require 'bench/lunajson/sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}

require 'openssl'

# Create an RSA key
key = OpenSSL::PKey::RSA.new 3072

# Save its public key to disc
File.open('public_key.pem', 'w') {|io| io.write key.public_key.to_pem}

# Encrypt its private key and write to disc
cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
pass_phrase = 'my secure pass phrase goes here'
key_secure = key.export cipher, pass_phrase
File.open('private.secure.pem', 'w') {|io| io.write key_secure}

# Load pub key from file
pubkey = OpenSSL::PKey::RSA.new File.read 'public_key.pem'

# Load priv key from file
privkey_pem = File.read 'private.secure.pem'
privkey = OpenSSL::PKey::RSA.new privkey_pem, pass_phrase

# Now encrypt!
public_encrypted = pubkey.public_encrypt 'top secret document'
private_encrypted = privkey.private_encrypt 'much more secret document'

# Now decrypt!
more_secret = pubkey.public_decrypt private_encrypted
puts "Privkey encrypted then pubkey decrypted: #{more_secret}"

top_secret = privkey.private_decrypt public_encrypted
puts "Pubkey encrypted then privkey decrypted: #{top_secret}"

# If we try the other way around, it fails!
begin
  top_secret = pubkey.private_decrypt public_encrypted
  puts "Pubkey encrypted then pubkey decrypted: #{top_secret}"
rescue Exception => e
  puts "Pubkey encrypted then pubkey decrypted: FAILED! since"
  puts e.inspect
end

# Now sign some data
data = "A small brown fox."

digest = OpenSSL::Digest::SHA512.new

signature = privkey.sign(digest, data)
p signature

p pubkey.verify(digest, signature, data)
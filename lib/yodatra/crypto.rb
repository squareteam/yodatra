module Yodatra
  class Crypto

    class << self
      # Computes the PBKDF2-SHA256 digest of a password using 10000 iterations and
      # the given salt, and return a 32-byte output. If no salt is given, a random
      # 8-byte salt is generated. The salt is also returned.
      def generate_pbkdf(password, salt = nil)
        new_salt = salt
        iter = 1000

        if salt.nil?
          new_salt = SecureRandom.random_bytes(8)
        end

        digest = OpenSSL::Digest::SHA256.new
        len = digest.digest_length
        value = OpenSSL::PKCS5.pbkdf2_hmac(password, new_salt, iter, len, digest)

        [new_salt, value]
      end

    end

  end
end
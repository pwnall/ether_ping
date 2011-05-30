require 'timeout'

require 'ethernet'

# :nodoc: namespace
module EtherPing

# Responder for ping utility using raw Ethernet sockets.
class Server
  def run
    loop do
      packet = @socket.recv 65536
      # Respond afap: exchange the source and destination MAC addresses.
      packet[0, 6], packet[6, 6] = packet[6, 6], packet[0, 6]
      @socket.send packet, 0
  
      if @verbose
        # The MAC addresses were switched above, before responding.
        dest_mac = packet[6, 6].unpack('H*').first
        source_mac = packet[0, 6].unpack('H*').first
        ether_type = packet[12, 2].unpack('H*').first
          
        puts "Src: #{source_mac} Dst: #{dest_mac} Eth: #{ether_type} Data:\n"
        puts packet[14..-1].unpack('H*').first
      end
    end
  end
  
  def initialize(eth_device, ether_type, verbose = true)
    @socket = Ethernet.raw_socket eth_device, ether_type
    @verbose = verbose
  end
end  # module EtherPing::Server
  
end  # namespace EtherPing

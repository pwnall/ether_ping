require 'ethernet'

# :nodoc: namespace
module EtherPing

# Responder for ping utility using raw Ethernet sockets.
class Server
  module Connection
    def receive_data(packet)
      source_mac = packet[0, 6].unpack('H*')
      dest_mac = packet[6, 6].unpack('H*')
      ether_type = packet[12, 2].unpack('H*')
      
      puts "Src: #{source_mac} Dst: #{dest_mac} Eth: #{ether_type}\n"
      puts packet[14..-1].unpack('H*')
      
      # Exchange the source and destination ARP addresses.
      packet[0, 6], packet[6, 6] = packet[6, 6], packet[0, 6]
      send_data packet
    end
  end

  class ConnectionWrapper
    include Connection
    
    def initialize(socket)
      @socket = socket
    end
    
    def send_data(data)
      @socket.send data, 0
    end
  end
  
  def run
    connection = ConnectionWrapper.new @socket
    loop do
      packet = @socket.recv 65536
      connection.receive_data packet
    end
  end
  
  def initialize(eth_device, ether_type)
    @socket = Ethernet.raw_socket eth_device, ether_type
  end
end  # module EtherPing::Server
  
end  # namespace EtherPing

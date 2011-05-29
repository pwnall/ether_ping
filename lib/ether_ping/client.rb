require 'ethernet'

# :nodoc: namespace
module EtherPing
  
# ether_ping implementation.
class Client
  def initialize(eth_device, ether_type, destination_mac)
    @socket = Ethernet.raw_socket eth_device, ether_type
    @source_mac = Ethernet::Devices.mac eth_device
    @dest_mac = [destination_mac].pack('H*')[0, 6]
    @ether_type = [ether_type].pack('n')    
  end
  
  attr_reader :socket
  attr_reader :source_mac
  attr_reader :dest_mac
  
  # Pings over raw Ethernet sockets.
  #
  # Returns true if the ping response matches, an array of [expected,
  # received] strings if it doesn't match, and false if the ping times out.
  def ping(data, timeout = 1)
    data = data.clone
    # Pad data to have at least 64 bytes.
    data += "\0" * (64 - data.length) if data.length < 64
 
    ping_packet = @dest_mac + @source_mac + @ether_type + data
    @socket.send ping_packet, 0

    response_packet = @source_mac + @dest_mac + @ether_type + data
    
    response = nil
    begin
      Timeout.timeout timeout do
        response = @socket.recv response_packet.length * 2
      end
    rescue Timeout::Error
      response = nil
    end
    return false unless response
    response == response_packet || [response, response_packet]
  end
end  # module EtherPing::Client

end  # namespace EtherPing

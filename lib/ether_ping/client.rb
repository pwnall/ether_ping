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
  # Returns a Number representing the ping latency (in seconds) if the ping
  # response matches, an array of [expected, received] strings if it doesn't
  # match, and false if the ping times out.
  def ping(data, timeout = 1)
    if data.kind_of? Numeric
      data = "\0" * data
    end
    # Pad data to have at least 64 bytes.
    data += "\0" * (64 - data.length) if data.length < 64
 
    ping_packet = [@dest_mac, @source_mac, @ether_type, data].join

    response = nil
    receive_ts = nil
    send_ts = nil
    begin
      Timeout.timeout timeout do
        send_ts = Time.now
        @socket.send ping_packet, 0
        response = @socket.recv ping_packet.length * 2
        receive_ts = Time.now
      end
    rescue Timeout::Error
      response = nil
    end
    return false unless response

    response_packet = [@source_mac, @dest_mac, @ether_type, data].join
    response == response_packet ? receive_ts - send_ts :
                                  [response, response_packet]
  end
end  # module EtherPing::Client

end  # namespace EtherPing

require_relative 'test_helper'
require_relative '../lib/kademlia/node_socket'

describe NodeSocket do
  it "can send and receive packets" do
    server_socket = NodeSocket.open
    port = server_socket.address[1]
    
    client_socket = UDPSocket.new
    send_data = 'I sent this'
    client_socket.send(send_data, 0, '127.0.0.1', port)
    client_socket.close

    recv_data, addr = server_socket.read
    send_data.must_equal recv_data
  end
end
 

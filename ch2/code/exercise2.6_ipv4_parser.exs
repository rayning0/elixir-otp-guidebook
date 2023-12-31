# Parser for IPv4 packet header: https://en.wikipedia.org/wiki/Internet_Protocol_version_4#Packet_structure
defmodule IP do
  def parse(filename) do
    case File.read(filename) do
      {:ok, data} ->
        <<_::binary-size(40), packet::binary>> = data
        parse_frame(packet, 1)

      _ ->
        IO.puts("Couldn't open #{filename}")
    end
  end

  def parse_frame(frame, count) do
    <<_::binary-size(14), ipv4_header::binary>> = frame

    <<version::4, ihl::4, dscp::6, ecn::2, total_length::16, identification::binary-size(2),
      flags::3, fragment_offset::13, ttl::8, protocol::8, header_checksum::binary-size(2),
      source_ip::binary-size(4), destination_ip::binary-size(4),
      _rest::binary>> =
      ipv4_header

    ihl = ihl * 4
    dscp = Integer.to_string(dscp, 2) |> String.pad_leading(6, "0")
    ecn = Integer.to_string(ecn, 2) |> String.pad_leading(2, "0")
    identification = identification |> bytes_to_hex() |> Enum.join()
    flags = fragment_flag(flags)
    header_checksum = header_checksum |> bytes_to_hex() |> Enum.join()
    source_ip = source_ip |> ip_to_string
    destination_ip = destination_ip |> ip_to_string

    IO.puts("Frame #{count} IPv4 Header:")
    IO.inspect(ipv4_header |> bytes_to_hex |> Enum.take(ihl) |> Enum.join(" "))
    IO.puts("")

    IO.puts("Internet Protocol Version: #{version}")
    IO.puts("Internet Header Length: #{ihl} bytes (#{round(ihl / 4)})")
    IO.puts("Differentiated Services Field: 0x#{(dscp <> ecn) |> IP.binary_to_hex()}")
    IO.puts("  #{dscp}.. = Differentiated Services Code Point")
    IO.puts("  ......#{ecn} = Explicit Congestion Notification")
    IO.puts("Total Length: #{total_length} bytes")
    IO.puts("Identification: 0x#{identification}")
    IO.puts("Flags: #{flags}")
    IO.puts("Fragment Offset: #{fragment_offset}")
    IO.puts("Time to Live: #{ttl} secs")
    IO.puts("Protocol: #{protocol_map(protocol)} (#{protocol})")
    IO.puts("Header Checksum: 0x#{header_checksum}")
    IO.puts("Source IP Address: #{source_ip}")
    IO.puts("Destination IP Address: #{destination_ip}\n")

    bytes_to_next_packet = 14 + total_length + 16
    <<_::binary-size(bytes_to_next_packet), packet::binary>> = frame

    # only continue loop for IPv4 packets
    <<_::binary-size(14), version::4, _ihl::4, _rest::binary>> = packet
    if version == 4, do: parse_frame(packet, count + 1)

    # Since we finished recursive loop, this only returns values for frame #1
    %{
      version: version,
      ihl: ihl,
      dscp: dscp,
      ecn: ecn,
      total_length: total_length,
      identification: identification,
      flags: flags,
      fragment_offset: fragment_offset,
      ttl: ttl,
      protocol: protocol_map(protocol),
      header_checksum: header_checksum,
      source_ip: source_ip,
      destination_ip: destination_ip
    }
  end

  def fragment_flag(flags) do
    # 3 digit binary
    binary = Integer.to_string(flags, 2) |> String.pad_leading(3, "0")

    case binary do
      "010" -> "Don't Fragment"
      "001" -> "More Fragments"
      "000" -> "Last Fragment"
      _ -> "Error in fragment flag"
    end
  end

  def ip_to_string(ip_binary) do
    ip_binary |> :binary.bin_to_list() |> Enum.join(".")
  end

  # Converts decimal to 8-digit binary
  def base2(decimal) do
    Integer.to_string(decimal, 2) |> String.pad_leading(8, "0")
  end

  # Converts "01011100" to "5C", "00000110" to "06"
  def binary_to_hex(bin) do
    bin
    |> Integer.parse(2)
    |> elem(0)
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(2, "0")
  end

  # Converts <<92, 6>> to ["01011100", "00000110"] to ["5C", "06"]
  def bytes_to_hex(bytes) do
    bytes
    |> :binary.bin_to_list()
    |> Enum.map(fn x -> x |> base2 |> binary_to_hex end)
  end

  # Converts <<0, 145>> to 0000000010010001 to 145. Could use for total_length::binary-size(2)
  def bytes_to_dec(bytes) do
    bytes
    |> :binary.bin_to_list()
    |> Enum.map(fn x -> x |> base2 end)
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end

  # https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers
  def protocol_map(protocol) do
    pmap = %{
      1 => "ICMP",
      6 => "TCP",
      17 => "UDP",
      54 => "NARP",
      91 => "LARP",
      92 => "MTP",
      103 => "PIM"
    }

    pmap[protocol]
  end
end

ExUnit.start()

defmodule IPParseTest do
  use ExUnit.Case, async: true
  @moduletag timeout: :infinity

  test "IP.parse() IPv4 packet headers in .pcap file" do
    parsed_ip = %{
      version: 4,
      ihl: 20,
      dscp: "000000",
      ecn: "00",
      total_length: 145,
      identification: "0000",
      flags: "Don't Fragment",
      fragment_offset: 0,
      ttl: 64,
      protocol: "UDP",
      header_checksum: "5c06",
      source_ip: "10.15.140.9",
      destination_ip: "142.250.185.67"
    }

    assert Map.equal?(IP.parse("ip.pcap"), parsed_ip)
  end
end

# OUTPUT on "ip.pcap":

# Frame 1 IPv4 Header:
# "45 00 00 91 00 00 40 00 40 11 5c 06 0a 0f 8c 09 8e fa b9 43"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 145 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 64 secs
# Protocol: UDP (17)
# Header Checksum: 0x5c06
# Source IP Address: 10.15.140.9
# Destination IP Address: 142.250.185.67

# Frame 2 IPv4 Header:
# "45 00 00 37 00 00 40 00 3a 11 62 60 8e fa b9 43 0a 0f 8c 09"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 55 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 58 secs
# Protocol: UDP (17)
# Header Checksum: 0x6260
# Source IP Address: 142.250.185.67
# Destination IP Address: 10.15.140.9

# Frame 3 IPv4 Header:
# "45 00 00 a9 00 00 40 00 3a 11 61 ee 8e fa b9 43 0a 0f 8c 09"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 169 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 58 secs
# Protocol: UDP (17)
# Header Checksum: 0x61ee
# Source IP Address: 142.250.185.67
# Destination IP Address: 10.15.140.9

# Frame 4 IPv4 Header:
# "45 00 00 33 00 00 40 00 3a 11 62 64 8e fa b9 43 0a 0f 8c 09"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 51 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 58 secs
# Protocol: UDP (17)
# Header Checksum: 0x6264
# Source IP Address: 142.250.185.67
# Destination IP Address: 10.15.140.9

# Frame 5 IPv4 Header:
# "45 00 00 40 00 00 40 00 40 11 5c 57 0a 0f 8c 09 8e fa b9 43"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 64 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 64 secs
# Protocol: UDP (17)
# Header Checksum: 0x5c57
# Source IP Address: 10.15.140.9
# Destination IP Address: 142.250.185.67

# Frame 6 IPv4 Header:
# "45 00 00 3d 00 00 40 00 40 11 5c 5a 0a 0f 8c 09 8e fa b9 43"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 61 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 64 secs
# Protocol: UDP (17)
# Header Checksum: 0x5c5a
# Source IP Address: 10.15.140.9
# Destination IP Address: 142.250.185.67

# Frame 7 IPv4 Header:
# "45 00 00 34 00 00 40 00 3a 11 62 63 8e fa b9 43 0a 0f 8c 09"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 52 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 58 secs
# Protocol: UDP (17)
# Header Checksum: 0x6263
# Source IP Address: 142.250.185.67
# Destination IP Address: 10.15.140.9

# Frame 8 IPv4 Header:
# "45 00 00 39 00 00 40 00 40 11 5b b3 0a 0f 8c 09 8e fa b9 ee"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 57 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 64 secs
# Protocol: UDP (17)
# Header Checksum: 0x5bb3
# Source IP Address: 10.15.140.9
# Destination IP Address: 142.250.185.238

# Frame 9 IPv4 Header:
# "45 00 00 36 00 00 40 00 3a 11 61 b6 8e fa b9 ee 0a 0f 8c 09"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 54 bytes
# Identification: 0x0000
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 58 secs
# Protocol: UDP (17)
# Header Checksum: 0x61b6
# Source IP Address: 142.250.185.238
# Destination IP Address: 10.15.140.9

# Frame 10 IPv4 Header:
# "45 00 01 7e 00 14 40 00 ff 11 03 b5 0a 0f 8b 9b e0 00 00 fb"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 382 bytes
# Identification: 0x0014
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 255 secs
# Protocol: UDP (17)
# Header Checksum: 0x03b5
# Source IP Address: 10.15.139.155
# Destination IP Address: 224.0.0.251

# Frame 11 IPv4 Header:
# "45 00 01 8d 00 15 40 00 ff 11 03 a5 0a 0f 8b 9b e0 00 00 fb"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 397 bytes
# Identification: 0x0015
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 255 secs
# Protocol: UDP (17)
# Header Checksum: 0x03a5
# Source IP Address: 10.15.139.155
# Destination IP Address: 224.0.0.251

# Frame 12 IPv4 Header:
# "45 00 01 8a c1 1f 40 00 ff 11 41 9e 0a 0f 8c 9a e0 00 00 fb"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 394 bytes
# Identification: 0xc11f
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 255 secs
# Protocol: UDP (17)
# Header Checksum: 0x419e
# Source IP Address: 10.15.140.154
# Destination IP Address: 224.0.0.251

# Frame 13 IPv4 Header:
# "45 00 01 99 c1 20 40 00 ff 11 41 8e 0a 0f 8c 9a e0 00 00 fb"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 409 bytes
# Identification: 0xc120
# Flags: Don't Fragment
# Fragment Offset: 0
# Time to Live: 255 secs
# Protocol: UDP (17)
# Header Checksum: 0x418e
# Source IP Address: 10.15.140.154
# Destination IP Address: 224.0.0.251

# Frame 14 IPv4 Header:
# "45 00 00 f0 6d f1 00 00 ff 11 ce 1f 0a 0f 93 e1 e0 00 00 fb"

# Internet Protocol Version: 4
# Internet Header Length: 20 bytes (5)
# Differentiated Services Field: 0x00
#   000000.. = Differentiated Services Code Point
#   ......00 = Explicit Congestion Notification
# Total Length: 240 bytes
# Identification: 0x6df1
# Flags: Last Fragment
# Fragment Offset: 0
# Time to Live: 255 secs
# Protocol: UDP (17)
# Header Checksum: 0xce1f
# Source IP Address: 10.15.147.225
# Destination IP Address: 224.0.0.251

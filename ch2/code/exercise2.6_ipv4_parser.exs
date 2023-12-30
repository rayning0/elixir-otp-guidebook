# Parser for IPv4 packet header: https://en.wikipedia.org/wiki/Internet_Protocol_version_4#Packet_structure
defmodule IP do
  def parse(filename) do
    case File.read(filename) do
      {:ok, data} ->
        <<_::binary-size(54), ipv4_header::binary>> = data

        <<version::4, ihl::4, dscp::6, ecn::2, total_length::16, identification::binary-size(2),
          flags::3, fragment_offset::13, ttl::8, protocol::8, header_checksum::binary-size(2),
          source_ip::binary-size(4), destination_ip::binary-size(4),
          rest::binary>> =
          ipv4_header

        dscp = Integer.to_string(dscp, 2) |> String.pad_leading(6, "0")
        ecn = Integer.to_string(ecn, 2) |> String.pad_leading(2, "0")
        identification = identification |> bytes_to_hex()
        flags = fragment_flag(flags)
        header_checksum = header_checksum |> bytes_to_hex()
        source_ip = source_ip |> ip_to_string
        destination_ip = destination_ip |> ip_to_string

        IO.puts("Internet Protocol Version: #{version}")
        IO.puts("Internet Header Length: #{ihl * 4} bytes (#{ihl})")
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
        IO.puts("Destination IP Address: #{destination_ip}")

        %{
          version: version,
          ihl: ihl * 4,
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

      # require IEx
      # IEx.pry()

      _ ->
        IO.puts("Couldn't open #{filename}")
    end
  end

  def fragment_flag(flags) do
    # 3 digit binary
    binary = Integer.to_string(flags, 2) |> String.pad_leading(3, "0")

    case binary do
      "010" -> "Don't Fragment"
      "001" -> "More Fragments"
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
    |> String.pad_leading(2, "0")
  end

  # Converts <<92, 6>> to ["01011100", "00000110"] to "5C06"
  def bytes_to_hex(bytes) do
    bytes
    |> :binary.bin_to_list()
    |> Enum.map(fn x -> x |> base2 |> binary_to_hex end)
    |> Enum.join()
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
      header_checksum: "5C06",
      source_ip: "10.15.140.9",
      destination_ip: "142.250.185.67"
    }

    assert Map.equal?(IP.parse("ip.pcap"), parsed_ip)
  end
end

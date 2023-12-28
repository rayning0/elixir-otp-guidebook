# Parser for IPv4 packet header: https://en.wikipedia.org/wiki/Internet_Protocol_version_4#Packet_structure
defmodule IPv4 do
  def parse(filename) do
    case File.read(filename) do
      {:ok, data} ->
        <<_::binary-size(54), ipv4_header::binary>> = data

        <<version::size(4), ihl::size(4), dscp::size(6), ecn::size(2),
          total_length::binary-size(2), identification::binary-size(2), flags::size(3),
          fragment_offset::size(13), ttl::binary-size(1), protocol::binary-size(1),
          header_checksum::binary-size(2), source_ip::binary-size(4),
          destination_ip::binary-size(4),
          rest::binary>> =
          ipv4_header

        # IHL = # of 32 bit (4 byte) words in the IPv4 header. Times 4 gives # of bytes.
        # ihl = ihl * 4

        # IO.puts(
        #   "version: #{version}, IHL: #{ihl}, DSCP: #{dscp}, ECN: #{ecn}, Total Length: #{total_length}, Identification: #{identification}"

        # Flags: #{flags}, Fragment Offset: #{fragment_offset}, TTL: #{ttl}, Protocol: #{protocol}, Header Checksum: #{header_checksum}, Source IP Address: #{}, Destination IP Address: #{destination_ip}"
        # )

        require IEx
        IEx.pry()

      # <<_::binary-size(audio_data_byte_size), id3_tag::binary>> = mp3

      # <<"TAG", song::binary-size(30), artist::binary-size(30), album::binary-size(30),
      #   year::binary-size(4), _rest::binary>> = id3_tag

      # # Extract printable part of each binary string. Exclude null bytes <<0>>
      # [song2, _null_bytes] = String.chunk(song, :printable)

      # IO.puts("Song: #{song2}, Artist: #{artist2}, Album: #{album2}, Year: #{year}")

      _ ->
        IO.puts("Couldn't open #{filename}")
    end
  end

  def base2(decimal) do
    Integer.to_string(decimal, 2) |> String.pad_leading(8, "0")
  end

  def binary_to_hex(bin) do
    bin
    |> Integer.parse(2)
    |> elem(0)
    |> Integer.to_string(16)
  end
end

ExUnit.start()

defmodule IPv4ParseTest do
  use ExUnit.Case, async: true
  @moduletag timeout: :infinity

  test "transform() a list with pipe operator" do
    assert IPv4.parse("ip.pcap") == 5
  end
end

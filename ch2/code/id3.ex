defmodule ID3Parser do
  def parse(file_name) do
    case File.read(file_name) do
      {:ok, mp3} ->
        audio_data_byte_size = byte_size(mp3) - 128
        <<_::binary-size(audio_data_byte_size), id3_tag::binary>> = mp3

        <<"TAG", song::binary-size(30), artist::binary-size(30), album::binary-size(30),
          year::binary-size(4), _rest::binary>> = id3_tag

        # Extract printable part of each binary string. Exclude null bytes <<0>>
        [song2, _null_bytes] = String.chunk(song, :printable)
        [artist2, _null_bytes] = String.chunk(artist, :printable)
        [album2, _null_bytes] = String.chunk(album, :printable)

        IO.puts("Song: #{song2}, Artist: #{artist2}, Album: #{album2}, Year: #{year}")

      _ ->
        IO.puts("Couldn't open #{file_name}")
    end
  end
end

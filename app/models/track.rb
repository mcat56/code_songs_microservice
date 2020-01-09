class Track < ActiveRecord::Base

  validates_presence_of :title
  validates_presence_of :mm_track_id
  validates_presence_of :mm_artist_id
  validates_presence_of :artist_name

  has_many :sentiments

  def lyrics
    service = MusixMatchService.new(nil, mm_track_id)
    response = service.get_lyrics
    lyrics = response[:message][:body][:lyrics][:lyrics_body]
    lyric_sanitizer(lyrics)
  end

  def make_sentiments(lyrics_text)
    service = WatsonService.new(lyrics_text)
    sentiment_response = service.sentiment[:sentences_tone]

    tones_hash(sentiment_response).each do |k,v|
      sentiments.create(name: k.to_s, value: v)
    end

  end

  private

  def tones_hash(sentiments_data)
    return {} if sentiments_data.nil?
    tones_hash = {}
    sentiments_data.each do |sentences|
      sentences[:tones].each do |tone|
        if tones_hash[tone[:tone_id].to_sym]
          tones_hash[tone[:tone_id].to_sym] += tone[:score]
        else
          tones_hash[tone[:tone_id].to_sym] = tone[:score]
        end
      end
    end

    tones_hash
  end

  def lyric_sanitizer(song_lyrics)
    song_lyrics.gsub("\n\n******* This Lyrics is NOT for Commercial use *******\n", "")
  end
end

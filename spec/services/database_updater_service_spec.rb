require 'spec_helper'

describe DatabaseUpdaterService do
  it 'it adds tracks to the database, with a default of 100', :vcr do
    expect{DatabaseUpdaterService.update_database}.to change{Track.count}.by(100)
  end

  it 'it only adds tracks to the database if they do not exist already', :vcr do
    Track.create(
      title: 'Dance Monkey',
      mm_track_id: 177501051,
      mm_artist_id: 37843472,
      artist_name: 'Tones and I'
    )
    expect{DatabaseUpdaterService.update_database}.to change{Track.count}.by(99)
  end

  it 'creates tracks with their sentiments', :vcr do
    expect{DatabaseUpdaterService.update_database(1)}.to change{Sentiment.count}.by(2)
  end

  it 'can seed a database with more than the top 100 songs', :vcr do 
    expect{DatabaseUpdaterService.seed_database(1)}.to change{Track.count}.by(1)
      .and change{DatabaseUpdaterService.current_page}.by(1)
  end
end

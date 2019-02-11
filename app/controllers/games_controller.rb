# frozen_string_literal: true

class GamesController < ApplicationController
  require 'open-uri'
  require 'json'

  def new
    @letters = generate_grid(10)
  end

  def score
    @word = params[:word]
    @letters = params[:letters].split(' ')
    @result = guess_score(@word, @letters)
    cookies.permanent[:score] = cookies.permanent[:score].to_i + @result[:score]
  end

  def init_score
    cookies.permanent[:score] = 0
    redirect_to :new
  end

  private

  def generate_grid(grid_size)
    grid_to_return = []
    grid_size.times { grid_to_return << ('A'..'Z').to_a.sample }
    grid_to_return
  end

  def letters_within_grid?(attempt, grid)
    attempt.upcase.split('').each do |letter|
      return grid.delete_at(grid.find_index(letter)) if grid.include? letter

      return false
    end
  end

  def guess_score(attempt, grid)
    # json_request
    word_description = fetch_dictionary(attempt)
    # Handle not valid word answered
    return { score: 0, message: 'not an english word' } unless word_description['found']

    # Handle not valid word answered
    unless letters_within_grid?(attempt, grid)
      return { score: 0, message: 'not in the grid' }
    end

    # Success
    score = 1 + attempt.length * 5
    { score: score, message: 'well done' }
  end

  def fetch_dictionary(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_description_serialized = open(url).read
    JSON.parse(word_description_serialized)
  end
end

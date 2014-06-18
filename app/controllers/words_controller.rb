class WordsController < ApplicationController
	include ColorHelper 
	respond_to :json

	def color
		word = params[:word]
		w = Word.find_by(word: word)
		
		if w.nil?
			w = Word.new
			w.word = word
			w.color = find_color(word)
			w.save
		end

		@data = {}
		@data[:word] = word
		@data[:w] = w

		
		respond_to do |format|
  			#format.json
        	format.html { render json: {:data => @data, :status => 200}}
        
	        if params[:callback]
	     	    format.js { render :json => {:data => @data, :status => 200}, :callback => params[:callback] }
	   		else
	   				format.json { render json: {:data => @data, :status => 200}}
	   		end
		end
	end

end
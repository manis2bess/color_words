class WordsController < ApplicationController
	include ColorHelper 
	include CountryHelper
	respond_to :json

	def country_iso
		year = params[:year].to_i
		iso = Country.where(year: year, country: {"$ne" => nil}).map { |c| c.country}

		@data = {}
		@data[:iso] = iso
		
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

	def world
		year = params[:year].to_i
		
		countries = []
		Country.where(year: year, country: {"$ne" => nil}).each do |c|
			w = get_words(c.words)
			e = {}
			e[:country] = c
			e[:words] = w
			countries << e
		end

		@data = {}
		@data[:countries] = countries
		
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

	def country
		year = params[:year].to_i
		country = params[:country]

		c = get_country(year, country)
		w = get_words(c.words)
		@data = {}
		@data[:country] = c
		@data[:words] = w
		
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

	def color
		word = params[:word]
		
		w = find_word(word)

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

	def reset
		Word.all.delete
		Photo.all.delete

		@data = {}

		
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
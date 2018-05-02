#!/usr/bin/ruby

require 'sinatra'
require 'sequel'
require 'erubis'
require 'pg'
require 'date'
# require 'sequel_pg'

helpers do
	include Rack::Utils
  		def protected!

  		#    return if request.remote_ip == "127.0.0.1"

  		return if authorized?
  		headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'

  		halt 401, "Not authorized\n"
	end 
end

DB = Sequel.postgres('geomantic', host: 'localhost')

enable :sessions

#creates one line of odd or even value
def generate_line
	if (rand(9) + 1).even?
    	line_value = 2
  	else 
    	line_value = 1
  	end

 	# puts "line = #{line_value}"
end

def generate_mother (chart_id, fig_position)

	fire_line  = generate_line
	air_line   = generate_line
	water_line = generate_line
	earth_line = generate_line

	# puts fire_line
	# puts air_line
	# puts water_line
	# puts earth_line

	figure_id = DB.fetch('SELECT id FROM figures WHERE fire = ? AND air = ? AND water = ? AND earth = ?', fire_line, air_line, water_line, earth_line).single_value
	# puts "figure id: #{figure_id}"

	c_figures = DB[:c_figures]

	c_figures.insert(:chart_id => chart_id, :figure_id => figure_id, :fig_group => 'Mother', :fig_position => fig_position)

end

def derive_daughter (this_chart_id, d_fig_position)

	if d_fig_position == 1
		element = 'fire' 
	elsif d_fig_position == 2
		element = 'air' 
	elsif d_fig_position == 3
		element = 'water'
	elsif d_fig_position == 4
		element = 'earth' 
	else 
		puts "Error: too many elements"
	end

	puts element

	result_set = DB.fetch("SELECT * FROM figures INNER JOIN c_figures ON figures.id = c_figures.figure_id WHERE c_figures.chart_id = ? AND c_figures.fig_group = 'Mother' ORDER BY c_figures.id;", this_chart_id).all
	puts result_set.inspect

	row = result_set.map{|x| x[:"#{element}"]}
	puts row

	fire_line = row[0]
	air_line = row[1]
	water_line = row[2]
	earth_line = row[3]

	figure_id = DB.fetch('SELECT id FROM figures WHERE fire = ? AND air = ? AND water = ? AND earth = ?', fire_line, air_line, water_line, earth_line).single_value
	puts "figure id: #{figure_id}"

	c_figures = DB[:c_figures]

	c_figures.insert(:chart_id => this_chart_id, :figure_id => figure_id, :fig_group => 'Daughter', :fig_position => d_fig_position)

end

def add_line(line1, line2)

	if (line1 + line2).even?
		line_new = 2
	else
		line_new = 1
	end

end

def add_figure(figure1, figure2)

	figure = Hash.new

	figure[:fire_line] = add_line(figure1[:fire], figure2[:fire])
	figure[:air_line] = add_line(figure1[:air], figure2[:air])
	figure[:water_line] = add_line(figure1[:water], figure2[:water])
	figure[:earth_line] = add_line(figure1[:earth], figure2[:earth])

	return figure
end

def derive_niece (this_chart_id)

	#fetch figures from db

	result_set = DB.fetch('SELECT fire, air, water, earth FROM figures INNER JOIN c_figures on figures.id = c_figures.figure_id WHERE c_figures.chart_id = ? ORDER BY c_figures.id;', this_chart_id).all

	puts "~~~~~~~"
	puts result_set
	puts "~~~~~~~"

	#shift to remove figures from the front of the array, in some kind of loop
	#add lines four times
	#create figure
	#do four times to create nieces

#oops, the array indices are wrong, figure out what the correct indices are

	(1..4).each do |e|

		puts "Niece #{e}"
		figure1 = result_set.shift
		puts figure1
		figure2 = result_set.shift
		puts figure2

		figure = add_figure(figure1, figure2)

		# puts "*****"
		# puts figure
		# puts "*****"

		figure_id = DB.fetch('SELECT id FROM figures WHERE fire = ? AND air = ? AND water = ? AND earth = ?', figure[:fire_line], figure[:air_line], figure[:water_line], figure[:earth_line]).single_value
		puts figure_id

		c_figures = DB[:c_figures]

		c_figures.insert(:chart_id => this_chart_id, :figure_id => figure_id, :fig_group => 'Niece', :fig_position => e)
	end
	
end

def derive_witness(this_chart_id)

	result_set = DB.fetch("SELECT fire, air, water, earth FROM figures INNER JOIN c_figures on figures.id = c_figures.figure_id WHERE c_figures.chart_id = ? AND c_figures.fig_group = 'Niece' ORDER BY c_figures.id;", this_chart_id).all

	(1..2).each do |e|

		puts "Witness #{e}"

		figure1 = result_set.shift
		puts figure1
		figure2 = result_set.shift
		puts figure2

		figure = add_figure(figure1, figure2)

		figure_id = DB.fetch('SELECT id FROM figures WHERE fire = ? AND air = ? AND water = ? AND earth = ?', figure[:fire_line], figure[:air_line], figure[:water_line], figure[:earth_line]).single_value
		puts figure_id

		c_figures = DB[:c_figures]

		c_figures.insert(:chart_id => this_chart_id, :figure_id => figure_id, :fig_group => 'Witness', :fig_position => e)
	end

end

def derive_judge(this_chart_id)

	result_set = DB.fetch("SELECT fire, air, water, earth FROM figures INNER JOIN c_figures on figures.id = c_figures.figure_id WHERE c_figures.chart_id = ? AND c_figures.fig_group = 'Witness' ORDER BY c_figures.id;", this_chart_id).all

	puts "Judge"
	puts result_set

	figure1 = result_set.shift
	puts figure1
	figure2 = result_set.shift
	puts figure2

	figure = add_figure(figure1, figure2)

	if (figure[:fire_line] + figure[:air_line] + figure[:water_line] + figure[:earth_line]).odd?
		puts "error"
	end

	figure_id = DB.fetch('SELECT id FROM figures WHERE fire = ? AND air = ? AND water = ? AND earth = ?', figure[:fire_line], figure[:air_line], figure[:water_line], figure[:earth_line]).single_value
		puts figure_id

	c_figures = DB[:c_figures]

	c_figures.insert(:chart_id => this_chart_id, :figure_id => figure_id, :fig_group => 'Judge', :fig_position => 1)

end

def get_date
	chart_date = Date.today
end

##########################

get '/' do
	erb :index
end

post '/chart' do
	
	chart_name = params[:chart_name]
	chart_by = params[:chart_by]
	chart_for = params[:chart_for]
	chart_subject = params[:chart_subject]
	chart_date = Date.today
	
	puts chart_name

	c_metadata = DB[:c_metadata]

	chart_id = c_metadata.insert(:chart_name => chart_name, :chart_date => chart_date, :chart_for => chart_for, :chart_by => chart_by, :chart_subject => chart_subject)

	session[:chart_id] = chart_id
	session[:message] = "Stored id: #{chart_id}."
	message = session[:message]
	this_chart_id = session[:chart_id]
	# puts message

	(1..4).each do |e|
		generate_mother(this_chart_id, e)
	end

	(1..4).each do |e|
		derive_daughter(this_chart_id, e)
	end

	derive_niece(this_chart_id)

	derive_witness(this_chart_id)

	derive_judge(this_chart_id)

	chart_figures = DB.fetch('SELECT cf.chart_id, cf.figure_id, cf.fig_group, cf.fig_position, f.name, f.translation, f.image
		FROM c_figures as cf
		INNER JOIN figures as f
		ON cf.figure_id = f.id
		WHERE cf.chart_id = ?
		ORDER BY cf.id;', this_chart_id).all
	puts chart_figures

	#note to self: be very careeful of order, subtle errors can creep in here

	slot_names = ['mother1', 'mother2', 'mother3', 'mother4', 'daughter1', 'daughter2', 'daughter3', 'daughter4', 'niece1', 'niece2', 'niece3', 'niece4', 'witness1', 'witness2', 'judge']

	slot_figures = Hash.new

	slot_names.each do |s|
	   slot_figures["#{s}"] = chart_figures.shift
	end

	puts slot_figures

		# figure = result_set.shift
		#grades["Dorothy Doe"] = 9

	erb :chart, :locals => {:chart_date => chart_date, :chart_name => chart_name, :chart_by => chart_by, :chart_for => chart_for, :chart_subject => chart_subject, :this_chart_id => this_chart_id, :slot_figures => slot_figures}

end

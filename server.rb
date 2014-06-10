require 'pg'
require 'shotgun'
require 'pry'
require 'sinatra'


configure :production do

  set :db_connection_info, {
    host: ENV['DB_HOST'],
    dbname: ENV['DB_NAME'],
    user: ENV['USER'],
    password: ENV['PASSWORD']
  }

end

configure :development do
  set :db_connection_info, {dbname: 'yawb'}

end

def db_connection
  begin
    connection = PG.connect(settings.db_connection_info)

    yield(connection)

  ensure
    connection.close
  end
end



def all_teams
  db_connection do |db|
    db.exec('SELECT * FROM teams')
  end
end

def add_team (name,description,point_person,point_person_email)
  db_connection do |conn|
    conn.exec_params('INSERT INTO teams (name, description, point_person,point_person_email) VALUES ($1,$2,$3,$4)',[name,description,point_person,point_person_email])
  end
end

def team_volunteers_info(id)
  db_connection do |conn|
    conn.exec_params('SELECT volunteers.name, volunteers.email FROM teams JOIN volunteer_teams ON teams.id=volunteer_teams.team_id JOIN volunteers ON volunteers.id=volunteer_teams.volunteer_id WHERE teams.id=$1',[id]).values
  end
end

def team(id)
  db_connection do |conn|
    conn.exec_params('SELECT * FROM teams WHERE teams.id=$1',[id]).values
  end
end

def add_volunteer(name,email)
  db_connection do |conn|
    conn.exec_params('INSERT INTO volunteers (name, email) VALUES ($1,$2)',[name, email])
  end
end

def volunteer_in_db(email)
  db_connection do |conn|
    conn.exec_params('SELECT exists (SELECT * FROM volunteers WHERE email=$1 LIMIT 1);',[email]).values.flatten
  end

end


def add_volunteer_team(name,email,suggest,team_id)
  db_connection do |conn|
    if volunteer_in_db(email)[0]=='t'
      volunteer_id = conn.exec_params('SELECT id FROM volunteers WHERE email=$1',[email]).values.flatten[0]
      conn.exec_params('INSERT INTO volunteer_teams (volunteer_id,team_id,suggestion) VALUES ($1,$2,$3)',[volunteer_id,team_id,suggest])
    elsif volunteer_in_db(email)[0]=='f'
      add_volunteer(name,email)
      volunteer_id = conn.exec_params('SELECT id FROM volunteers WHERE email=$1',[email]).values.flatten[0]
      conn.exec_params('INSERT INTO volunteer_teams (volunteer_id,team_id,suggestion) VALUES ($1,$2,$3)',[volunteer_id,team_id,suggest])
    end
  end
end


get '/' do
  @teams = all_teams
  erb :index
end

post '/create-team' do
  name = params['name']
  description = params['description']
  point_person = params['point']
  point_person_email = params['email']

  add_team(name,description,point_person,point_person_email)


  redirect '/'
end

get '/team/:team_id' do
  @team = team(params[:team_id]).flatten
  @team_info = team_volunteers_info(params[:team_id])


  erb :team
end

post '/join-team/:team_id' do
  name = params['name']
  email = params['email']
  team_id = params[:team_id]
  suggest = params['suggest']

  add_volunteer_team(name,email,suggest,team_id)

  redirect "/team/#{team_id}"
end

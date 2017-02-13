#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'pony'
require 'sqlite3'

def get_db
  return SQLite3::Database.new 'barbershop.db'
end 

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS 
  "Users1" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
  "username" TEXT, 
  "phone" TEXT,
  "date_stamp" TEXT, 
  "master" TEXT, 
  "color" TEXT);'
  db.execute 'CREATE TABLE IF NOT EXISTS "Barbers" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "barber" TEXT);'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
      db = get_db

        @barbers=[]
    db.execute 'select * from Barbers' do |row|
      @barbers<<row['barber']
    end
   

	erb :visit
end

post '/visit' do
    @username = params[:username]
    @phone = params[:phone]
    @date_stamp = params[:date_stamp]
    @master = params[:master]
    @color = params[:color]

   hh = { :username => 'Введите имя',
   	:phone => 'Введите телефон',
   	:date_stamp => 'Введите дату и телефон'}

   	#для каждой пары ключ-значение
   	#hh.each do |key, value|
   		#если параметр пуст
   	#	if params[key] == ''
   			#переменной error присвоить value из хеша hh, т.е. сообщение об ошибке
   	#		@error = hh[key]
   	#		return erb  :visit #без return не работало???
   	#	end
   	# end

   	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

   	if @error != '' 
   		return erb :visit

   	end


    db = get_db
    db.execute 'insert into Users1 (username, phone, date_stamp, master, color) values (
    ?,?,?,?,?)', [@username, @phone, @date_stamp, @master, @color]

  


    erb "Dear #{@username}, we'll be waiting for you at #{@date_stamp}, your color: #{@color}"
        
end 

get '/contacts' do
	erb :contacts
end




post '/contacts' do
	@name = params[:name]
	@user_contact = params[:user_contact]
	@user_message = params[:user_message]

	hh1 = {:name => 'Введите имя',
		:user_contact => 'Как с вами связаться?',
		:user_message => 'Пустое сообщение'}

	@error=hh1.select {|key,value|params[key]==""}.values.join", "


	@message_contacts = "Ваше сообщение отправлено"
	f = File.open 'user_messages.txt','a'
    f.write "User: #{@name}, Contact: #{@user_contact}, Message: #{@user_message}\n"
    f.close
	
	Pony.mail({
  :to => 'axenoffruby@gmail.com',
  :via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'axenoffruby',
    :password             => 'qwertyruby',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server

  },
      :subject => 'Message from barbershop',
    :body => "Name: #{@name}, contact: #{@user_contact}, message:#{@user_message}"
})

	erb :contacts

end

get '/admin' do
	erb :admin
end

post '/admin' do
	@login = params[:login]
	@password = params[:password]

	if @login == "admin" && @password == "secret"
		@logfile1 = File.read("users.txt")
		@logfile2 = File.read("user_messages.txt")
        erb :admin_info
    else
    	@a_message = 'Wrong login or password'
		erb :admin
	end

end

get '/showusers' do

    db = get_db
    
    @show_u = ""
    db.execute 'SELECT * from Users order by id' do |row|
      @show_u+="#{row['id']}, #{row['username']}, #{row['phone']}, #{row['date_stamp']}, #{row['master']}, #{row['color']}"+"\n"
      puts @show_u

    end
     erb :showusers

end

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end
    

#!/usr/bin/ruby
require "gtk3"
require "glib2"
require 'devkit'
require 'tiny_tds'

def query_make(type,id=null)
  case type
    when 1
      result_query = "SELECT * FROM LDERC Where ID = #{id}"
    when 2
      result_query = "DECLARE @id_doc int
                      SET @id_doc = #{id}
                      DELETE FROM LDDOCOPERATION WHERE MailID in (
                      SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)
                      DELETE FROM LDOBJECT WHERE ID IN (SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)"
  end
  return result_query
end

def checkRC(client, entry)
  result = client.execute(query_make 1,entry.text)
  return result
end

def deleteRC(client, entry)
  result = client.execute(query_make 2,entry.text)
  return result
end

def client_init (username,password)
  client = TinyTds::Client.new username: username, password: password,
                               host: 'WIN-9655Q11EAT8', port: 1433,
                               database: 'LD', timeout: 180
  return client
end


win = Gtk::Window.new
win.set_title("LD3ADM")
win.set_size_request(400, 400)
win.set_border_width(10)


vbox = Gtk::Box.new(:vertical, 6)
win.add(vbox)

entry = Gtk::Entry.new
entry.set_text("ENTER REG CARD ID")
vbox.pack_start(entry, :expand => false, :fill => true, :padding => 10)

hbox = Gtk::Box.new(:horizontal, 6)
vbox.pack_start(hbox, :expand => true, :fill => true, :padding => 10)


check_button = Gtk::Button.new(:label => "Проверить РК")
check_button.signal_connect "clicked" do |_widget|

  #puts checkRC client, entry
  client = client_init('dba','sql')
  result = checkRC client, entry
  result.each do |row|
    puts row
  end
  client.close

  puts "Check!!"
end
vbox.pack_start(check_button, :expand => false, :fill => true, :padding => 10)

delete_button = Gtk::Button.new(:label => "Удалить все сообщения и отчеты")
delete_button.signal_connect "clicked" do |_widget|
  client = client_init('dba','sql')
  result = deleteRC client, entry
  result.each do |row|
    puts row
  end
  client.close
  puts "Delete!!"
end
vbox.pack_start(delete_button, :expand => false, :fill => true, :padding => 10)

unblock_button = Gtk::Button.new(:label => "Разблокировать РК")
unblock_button.signal_connect "clicked" do |_widget|
  client = client_init('dba','sql')
  result = deleteRC client, entry
  result.each do |row|
    puts row
  end
  client.close
  puts "Delete!!"
end
vbox.pack_start(unblock_button, :expand => false, :fill => true, :padding => 10)


win.signal_connect("destroy") do
  Gtk.main_quit
  #if !client.closed?
  #  client.close
  puts "Client connection close"
  #end
end
win.show_all
Gtk.main
require 'devkit'
require 'tiny_tds'
require './LD3ADM-UI'

#возвращает строку с SQL запросом определенном типа (type), id - идентефикатор РК, ГУИД и т.д.


def query_make(type,id=null)
  case type
    when 1
      result_query = "SELECT DocN FROM LDERC Where ID = #{id}"
    when 2
      result_query = "DECLARE @id_doc int
                      SET @id_doc = #{id}
                      DELETE FROM LDDOCOPERATION WHERE MailID in (
                      SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)
                      DELETE FROM LDOBJECT WHERE ID IN (SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)"
    when 3
      result_query = "update LDOBJECT set EditorID=NULL where ID= #{id}"

    when 4
      result_query = "DECLARE @pUID [uniqueidentifier], @pObjectTypeID INT
                      SET @pUID = 0x#{id}
                      SET @pObjectTypeID = 8 --допустимо 8,19,20
                      INSERT dbo.GRK_LDEA_REJECTEDOBJECT (UID,ObjectTypeID)
                      SELECT @pUID,@pObjectTypeID
                      WHERE NOT EXISTS(SELECT NULL FROM dbo.GRK_LDEA_REJECTEDOBJECT WHERE UID = @pUID)"
    when 5
      result_query = "DECLARE @id_doc int
                      SET @id_doc = #{id}
                      DELETE  FROM LDDOCOPERATION WHERE MailID in (
                      SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)
                      DELETE  FROM LDOBJECT WHERE ID IN (
                      SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)
                      DELETE FROM LDMAILVERSION Where MailID in (
                      SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)"
  end
  return result_query
end

#проверка соединения с бд

def checkConnection
  client = client_init('dba','sql')
  puts "CONNECTION OK"
  client.close
end

#проверка РК
def checkRC(entry)
  client = client_init'dba','sql'
  result = client.execute(query_make 1,entry)
  result.each_with_index do |row|
    puts row["DocN"]
    text = row["DocN"]
  end
  client.close
  return text
end

#удаление РК (?!)

def deleteRC(client, entry)
  result = client.execute(query_make 2,entry.text)
  return result
end

#нажатие кропки CHECK
def checkButtonPress(entry)
  #client = client_init'dba','sql'
  #result = checkRC client, entry
  #result.each do |row|
  # puts row
  #end
  #checkRC client,entry
  #client.close
  #puts "Check!!"
  onCmdShowResultDialog
end

def buttonPress(type,entry)
  client = client_init'dba','sql'
  result = client.execute(query_make type,entry)
  client.close
end


#tiny TDS клиент
def client_init (username,password)
  client = TinyTds::Client.new username: username, password: password,
                               host: 'WIN-9655Q11EAT8', port: 1433,
                               database: 'LD', timeout: 180
  return client
end



def run
  # Make an application
  application = FXApp.new("Dialog", "FoxTest")

  # Construct the application's main window
  MainWindow.new(application)

  # Create the application
  application.create

  # Run the application
  application.run
end

run
require 'fox16'
require 'tiny_tds'
require 'devkit'
include Fox


#####
##### Главное окно
#####

class MainWindow < FXMainWindow

  def initialize(app)
    # Invoke base class initialize first
    super(app, "LD3ADM", :opts => DECOR_ALL, :width => 640, :height => 250)

    # Create a tooltip
    FXToolTip.new(self.getApp())

    menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    filemenu = FXMenuPane.new(self)
    FXMenuCommand.new(filemenu, "&Проверить соединение", nil, getApp(), FXApp::ID_QUIT, 0)
    FXMenuCommand.new(filemenu, "&Выход", nil, getApp(), FXApp::ID_QUIT, 0)
    FXMenuTitle.new(menubar, "&Файл", nil, filemenu)


    # Separator
    FXHorizontalSeparator.new(self,
                              LAYOUT_SIDE_TOP|LAYOUT_FILL_X|SEPARATOR_GROOVE)

    # Controls on the right
    controls = FXVerticalFrame.new(self,
                                   LAYOUT_SIDE_RIGHT|LAYOUT_FILL_Y|PACK_UNIFORM_WIDTH)

    # Separator
    FXVerticalSeparator.new(self,
                            LAYOUT_SIDE_RIGHT|LAYOUT_FILL_Y|SEPARATOR_GROOVE)

    # Contents
    contents = FXVerticalFrame.new(self,
                                   LAYOUT_CENTER_X|LAYOUT_FILL_Y|PACK_UNIFORM_WIDTH)
    # Construct icon from a PNG file on disk



    FXLabel.new(contents, "ENTER ID:") do |theLabel|
      theLabel.layoutHints = FRAME_RAISED|FRAME_THICK|LAYOUT_FILL_X
    end

    p = proc { @text.value }


    @text = FXDataTarget.new("")

    textField = FXTextField.new(contents, 20, @text, FXDataTarget::ID_VALUE) do |theTextField|
      theTextField.layoutHints = FRAME_RAISED|FRAME_THICK|LAYOUT_FILL_X
      theTextField.setFocus()
    end

    # Control Buttons

    checkButton = FXButton.new(contents, "Проверить ID",:opts => FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH,
                               :width => 270, :height => 40)


    deleteButton = FXButton.new(controls, "Удалить все сообщения и отчеты",:opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
        LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                 :width => 250, :height => 40)
    deleteButton.connect(SEL_COMMAND) {checkInput(textField.getText) }#{  buttonDML(2, textField.getText) }
    #{onCmdShowDialogModal(getDocNum(textField.getText)) }

    unblockButton = FXButton.new(controls, "Разблокировать РК", :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
        LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                 :width => 250, :height => 40)
    unblockButton.connect(SEL_COMMAND) {  buttonDML(3, textField.getText) }

    #fileButton = FXButton.new(controls, "Удаление файла", :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
    #    LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
    #             :width => 250, :height => 40)
    #fileButton.connect(SEL_COMMAND, method(:onCmdShowDialogModal))

   # psoGuidButton = FXButton.new(controls, "ПСО ошибка с GUID", :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
   #     LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
   #              :width => 250, :height => 40)
   # psoGuidButton.connect(SEL_COMMAND) {exit}#{ buttonDML(4, textField.getText) }


        # Text window
    textBox = FXText.new(contents, nil, 0,
                      TEXT_READONLY|TEXT_WORDWRAP|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                      :width => 300, :height => 90)

    # Set the text
    textBox.text = "Регистрационный номер:\nДата Регистрации:\nЖурнал:\n"

    checkButton.connect(SEL_COMMAND) { checkID(textField.getText, textBox) }

    statusLabel = FXLabel.new(contents, "QueryStatus:none")
  end

#####
##### Диалоговое окно подтверждения
#####

class ConfirmDialog < FXDialogBox

  def initialize(owner, doc_num = "unavalible", query_type = nil)
      # Invoke base class initialize function first
    super(owner, "Are you fucking sure?", DECOR_TITLE|DECOR_BORDER)

    FXLabel.new(self, "Вы действительно хотите провести операцию над документом #{doc_num}?") do |theLabel|
        theLabel.layoutHints = LAYOUT_FILL_X
    end


    # Bottom buttons
    buttons = FXHorizontalFrame.new(self,
                                      LAYOUT_SIDE_BOTTOM|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
                                      :padLeft => 40, :padRight => 40, :padTop => 20, :padBottom => 20)


    # Menu
    menu = FXMenuPane.new(self)
    FXMenuCommand.new(menu, "&Accept", nil, self, ID_ACCEPT)
    FXMenuCommand.new(menu, "&Cancel", nil, self, ID_CANCEL)

    # Accept
    accept = FXButton.new(buttons, "&Accept",
                 :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|
                     LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                   :width => 100, :height => 30)

    accept.connect(SEL_COMMAND) do
      buttonDML(3, doc_num)
      exit
    end

    # Cancel
    cancel = FXButton.new(buttons, "&Cancel", nil, self, ID_CANCEL,
                          :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|
                              LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                            :width => 100, :height => 30)

    cancel.setDefault
    cancel.setFocus
  end
end


#####
##### Окно резальтата
#####

class ResultDialog < FXDialogBox

  def initialize(owner,result)
    # Invoke base class initialize function first
    super(owner, "Result", DECOR_TITLE|DECOR_BORDER)

    FXLabel.new(self, "#{result}") do |theLabel|
      theLabel.layoutHints = LAYOUT_FILL_X
    end

    # Bottom buttons
    buttons = FXHorizontalFrame.new(self,
                                      LAYOUT_SIDE_BOTTOM|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
                                      :padLeft => 40, :padRight => 40, :padTop => 20, :padBottom => 20)



    # Menu
    menu = FXMenuPane.new(self)
    FXMenuCommand.new(menu, "&OK", nil, self, ID_CANCEL)
    # Cancel
    cancel = FXButton.new(buttons, "&OK", nil, self, ID_CANCEL,
                          :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|
                              LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                          :width => 100, :height => 30)
    cancel.setDefault
    cancel.setFocus
  end
end

def onCmdShowDialogModal(docnum)
  ConfirmDialog.new(self, docnum).execute
  return 1
end

def showResultDialog(text)
  ResultDialog.new(self, text).execute
  return 1
end

######### end ui



def create
    super
    show(PLACEMENT_SCREEN)
  end
end


##
##queries/connection
##

def query_make(type,id=null)
  case type
    when 1
      result_query = "SELECT DocN,FORMAT( RegDate, 'd', 'ru-ru' ) as RegDate,JournalName FROM LDERC rec
                      LEFT JOIN FKDTTR_LOGMAPJOURNAL jr on jr.JournalID = rec.JournalID
                      Where ID = #{id}"
    when 2
      result_query = "DECLARE @id_doc int
                      SET @id_doc = #{id}
                      DELETE FROM LDDOCOPERATION WHERE MailID in (
                      SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)
                      DELETE FROM LDOBJECT WHERE ID IN (SELECT ID FROM LDMAIL WHERE ERCID = @id_doc OR BaseERCID = @id_doc)"
    when 3
      result_query = "UPDATE LDOBJECT SET EditorID=NULL where ID = #{id}"

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


#tiny TDS клиент
def client_init (username,password)
  client = TinyTds::Client.new username: username, password: password,
                               host: 'WIN-9655Q11EAT8', port: 1433,
                               database: 'LD', timeout: 180
  return client
end


##
##queries/connection end
##

##
##buttons
##

def checkConnection
end


#def checkRC(entry)
#  +  client = client_init'dba','sql'
#  result = client.execute(query_make 1,entry)
#  result.each_with_index do |row|
 #   puts row["DocN"]
  #  +    text = row["DocN"]
  #end
  #+  client.close
  #+  return text
#end


def checkID(entry, textbox)
  textbox.text = "Регистрационный номер: null\nДата Регистрации: null\nЖурнал: null\n"
  client = client_init('dba','sql')
  #puts "CONNECTION OK"
  result = client.execute(query_make 1,entry)
  result.each_with_index do |row|
    #puts row["DocN"]
    #puts row["RegDate"]
    #puts row["JournalID"]
    textbox.text = "Регистрационный номер: #{row["DocN"]}\nДата Регистрации: #{row["RegDate"]}\nЖурнал: #{row["JournalName"]}\n"
  end
  client.close
end
def getDocNum(entry)
  client = client_init('dba','sql')
  #puts "CONNECTION OK"
  text = ''
  result = client.execute(query_make 1,entry)
  result.each_with_index do |row|
    #puts row["DocN"]
    #puts row["RegDate"]
    #puts row["JournalID"]
    text = row["DocN"]
  end
  client.close
  return text
end

def buttonDML(type,entry)
  client = client_init('dba','sql')
  result = client.execute(query_make type,entry)
  result.each_with_index do |row|
    #puts row["DocN"]
    #puts row["RegDate"]
    #puts row["JournalID"]
  end
  #puts query_make type,entry
  client.close
end

def checkInput(entry)
  client = client_init('dba','sql')
  test = 'failed'
  result = client.execute(query_make 1,entry)
  result.each_with_index do |row|
    #puts row["DocN"]
    #puts row["RegDate"]
    #puts row["JournalID"]
    test = 'OK'
  end
  client.close
  if test == 'OK'
    puts 1
  else
    puts 0
    showResultDialog("Не верный ID")
  end
end


##
##buttons end
##




if __FILE__ == $0
  # Construct an application
  application = FXApp.new("Button", "FoxTest")

  # Construct the main window
  MainWindow.new(application)

  # Create the application
  application.create

  # Run it
  application.run
end
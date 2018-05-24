require 'fox16'
include Fox


#####
##### Главное окно
#####

class MainWindow < FXMainWindow

  def initialize(app)
    # Invoke base class initialize first
    super(app, "LD3ADM Rise of the Kozlovskiy EDITION", :opts => DECOR_ALL, :width => 640, :height => 250)

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
    checkButton.connect(SEL_COMMAND) { exit }

    deleteButton = FXButton.new(controls, "Удалить все сообщения и отчеты",:opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
        LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                 :width => 250, :height => 40)
    deleteButton.connect(SEL_COMMAND, method(:onCmdShowDialogModal))

    unblockButton = FXButton.new(controls, "Разблокировать РК", :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
        LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                 :width => 250, :height => 40)
    unblockButton.connect(SEL_COMMAND) { exit }

    fileButton = FXButton.new(controls, "Удаление файла", :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
        LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                 :width => 250, :height => 40)
    fileButton.connect(SEL_COMMAND, method(:onCmdShowDialogModal))

    psoGuidButton = FXButton.new(controls, "ПСО ошибка с GUID", :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|
        LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                 :width => 250, :height => 40)
    psoGuidButton.connect(SEL_COMMAND) { exit }


        # Text window
    textBox = FXText.new(contents, nil, 0,
                      TEXT_READONLY|TEXT_WORDWRAP|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                      :width => 300, :height => 90)

    # Set the text
    textBox.text = "Регистрационный номер:\nДата Регистрации:\nЖурнал:\n"

    statusLabel = FXLabel.new(contents, "QueryStatus:none")



  end

#####
##### Диалоговое окно подтверждения
#####

class ConfirmDialog < FXDialogBox

  def initialize(owner, doc_num = "unavalible")
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
    FXButton.new(buttons, "&Accept", nil, self, ID_ACCEPT,
                 :opts => FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|
                     LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,
                   :width => 100, :height => 30)

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

def onCmdShowDialogModal(sender=nil, sel=nil, ptr=nil)
  ConfirmDialog.new(self).execute
  return 1
end

def create
    super
    show(PLACEMENT_SCREEN)
  end
end

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
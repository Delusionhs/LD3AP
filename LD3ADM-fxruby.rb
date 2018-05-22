#!/usr/bin/env ruby

require 'fox16'

include Fox

#application = FXApp.new("Hello", "FoxTest")
#main = FXMainWindow.new(application, "LD3ADM", nil, nil, DECOR_ALL)
#FXButton.new(main, "&Hello, World!", nil, application, FXApp::ID_QUIT)
#application.create()
#main.show(PLACEMENT_SCREEN)
#"#{a}"pplication.run()


class MainWindows < FXMainWindow

  def initialize(app)
    # Invoke base class initialize first
    super(app, "LD3ADM Kozlovskiy EDITION", :opts => DECOR_ALL, :width => 400, :height => 200)

    # Tooltip
    FXToolTip.new(getApp())

    # Menubar
    menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    # Separator
    FXHorizontalSeparator.new(self,
                              LAYOUT_SIDE_TOP|LAYOUT_FILL_X|SEPARATOR_GROOVE)

    # File Menu
    filemenu = FXMenuPane.new(self)
    FXMenuCommand.new(filemenu, "&Проверить соединение", nil, getApp(), FXApp::ID_QUIT, 0)
    FXMenuCommand.new(filemenu, "&Выход", nil, getApp(), FXApp::ID_QUIT, 0)
    FXMenuTitle.new(menubar, "&Файл", nil, filemenu)

    top = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y) do |theFrame|
      theFrame.padLeft = 10
      theFrame.padRight = 10
      theFrame.padBottom = 10
      theFrame.padTop = 10
      theFrame.vSpacing = 20
    end
    FXLabel.new(top, 'Enter Text:') do |theLabel|
      theLabel.layoutHints = LAYOUT_FILL_X
    end

    FXTextField.new(top, 20, @text, FXDataTarget::ID_VALUE) do |theTextField|
      theTextField.layoutHints = LAYOUT_FILL_X
      theTextField.setFocus()
    end

    FXButton.new(top, 'Pig It') do |pigButton|
      pigButton.connect(SEL_COMMAND, p)
      pigButton.layoutHints = LAYOUT_CENTER_X
    end

    FXButton.new(top, 'Exit') do |exitButton|
      exitButton.connect(SEL_COMMAND) { exit }
      exitButton.layoutHints = LAYOUT_CENTER_X
    end




  end

  # Start
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

def run
  # Make an application
  application = FXApp.new("Dialog", "FoxTest")

  # Construct the application's main window
  MainWindows.new(application)

  # Create the application
  application.create

  # Run the application
  application.run
end

run
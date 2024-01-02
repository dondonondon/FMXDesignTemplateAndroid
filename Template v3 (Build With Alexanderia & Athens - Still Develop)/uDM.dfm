object DM: TDM
  Height = 348
  Width = 537
  object Conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\LENOVO\Documents\Blangkon\Aplikasi\Android Dat' +
        'a Tamu\Guest\assets\database\db_tamu.db'
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 16
    Top = 8
  end
  object QTemp1: TFDQuery
    Connection = Conn
    FetchOptions.AssignedValues = [evRowsetSize]
    FetchOptions.RowsetSize = 5000
    Left = 16
    Top = 64
  end
  object QTemp2: TFDQuery
    Connection = Conn
    FetchOptions.AssignedValues = [evRowsetSize]
    FetchOptions.RowsetSize = 5000
    Left = 72
    Top = 64
  end
  object QTemp3: TFDQuery
    Connection = Conn
    FetchOptions.AssignedValues = [evRowsetSize]
    FetchOptions.RowsetSize = 5000
    Left = 120
    Top = 64
  end
  object QTemp4: TFDQuery
    Connection = Conn
    FetchOptions.AssignedValues = [evRowsetSize]
    FetchOptions.RowsetSize = 5000
    Left = 176
    Top = 64
  end
  object img: TImageList
    Source = <>
    Destination = <>
    Left = 496
    Top = 8
  end
end

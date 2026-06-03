{*******************************************************************************
  Copyright (c) 2026 Fajar Donny Bachtiar (Blangkon FA)
  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for license details.
*******************************************************************************}

unit BFA.App.Types;

interface

type
  TView = class
  public const
    HOME = 'HOME';
    LOADING = 'LOADING';
    LOGIN = 'LOGIN';
    ACCOUNT = 'ACCOUNT';
    FAVORITE = 'FAVORITE';
    DETAIL = 'DETAIL';

    {SAMPLE DEMO FRAME VIEW}
    DEMOPERMISSION = 'DEMOPERMISSION';
    DEMOLOADJSONDATASET = 'DEMOLOADJSONDATASET';
    DEMORESTAPI = 'DEMORESTAPI';
    DEMOPUSHNOTIF = 'DEMOPUSHNOTIF';
    DEMOSAF = 'DEMOSAF';
  end;

implementation

end.

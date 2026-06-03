unit BFA.App.Func;

interface

uses
  System.IOUtils,
  System.SysUtils;

type
  TAppAssetKind = (
    akImage,
    akDocument,
    akVideo,
    akAudio,
    akOther
  );

  TAppPath = class
  private const
    ASSET_ROOT_DIRECTORY = 'assets';
    IMAGE_DIRECTORY = 'image';
    DOCUMENT_DIRECTORY = 'doc';
    VIDEO_DIRECTORY = 'video';
    AUDIO_DIRECTORY = 'music';
    OTHER_DIRECTORY = 'other';
  private
    class function BuildDesktopAssetPath(const AFileName: string): string; static;
    class function DirectoryNameForKind(const AKind: TAppAssetKind): string; static;
    class function GetFileAssetKind(const AFileName: string): TAppAssetKind; static;
    class procedure EnsureDirectory(const ADirectory: string); static;
  public
    class function AppBaseDirectory: string; static;
    class function AssetDirectory(const AKind: TAppAssetKind): string; static;
    class function AssetRootDirectory: string; static;
    class procedure EnsureBaseDirectories; static;
    class function LoadFile(const AFileName: string): string; static;
    class function NewUUIDCompact: string; static;
  end;

  TGlobalFunction = class(TAppPath)
  public
    class procedure CreateBaseDirectory; static; deprecated 'Use TAppPath.EnsureBaseDirectories.';
    class function GetBaseDirectory: string; static; deprecated 'Use TAppPath.AppBaseDirectory.';
  end;

  GlobalFunction = TGlobalFunction deprecated 'Use TAppPath or TGlobalFunction.';

implementation

{ TAppPath }

class function TAppPath.AppBaseDirectory: string;
begin
  {$IF DEFINED(IOS) OR DEFINED(ANDROID)}
  Result := TPath.GetDocumentsPath;
  {$ELSEIF DEFINED(MSWINDOWS) OR DEFINED(MACOS) OR DEFINED(OSX) OR DEFINED(LINUX)}
  Result := TPath.GetFullPath(GetCurrentDir);
  {$ELSE}
  Result := TPath.GetDocumentsPath;
  {$ENDIF}

  EnsureDirectory(Result);
end;

class function TAppPath.AssetDirectory(const AKind: TAppAssetKind): string;
begin
  Result := TPath.Combine(AssetRootDirectory, DirectoryNameForKind(AKind));
  EnsureDirectory(Result);
end;

class function TAppPath.AssetRootDirectory: string;
begin
  Result := TPath.Combine(AppBaseDirectory, ASSET_ROOT_DIRECTORY);
  EnsureDirectory(Result);
end;

class function TAppPath.BuildDesktopAssetPath(const AFileName: string): string;
var
  LRootAssetPath: string;
begin
  LRootAssetPath := TPath.Combine(AssetRootDirectory, AFileName);
  if TFile.Exists(LRootAssetPath) then begin
    Result := LRootAssetPath;
    exit;
  end;

  Result := TPath.Combine(AssetDirectory(GetFileAssetKind(AFileName)), AFileName);
end;

class function TAppPath.DirectoryNameForKind(
  const AKind: TAppAssetKind): string;
begin
  case AKind of
    TAppAssetKind.akImage:
      Result := IMAGE_DIRECTORY;
    TAppAssetKind.akDocument:
      Result := DOCUMENT_DIRECTORY;
    TAppAssetKind.akVideo:
      Result := VIDEO_DIRECTORY;
    TAppAssetKind.akAudio:
      Result := AUDIO_DIRECTORY;
  else
    Result := OTHER_DIRECTORY;
  end;
end;

class procedure TAppPath.EnsureBaseDirectories;
begin
  EnsureDirectory(AppBaseDirectory);

  {$IF DEFINED(MSWINDOWS) OR DEFINED(MACOS) OR DEFINED(OSX) OR DEFINED(LINUX)}
  EnsureDirectory(AssetRootDirectory);
  EnsureDirectory(AssetDirectory(TAppAssetKind.akImage));
  EnsureDirectory(AssetDirectory(TAppAssetKind.akDocument));
  EnsureDirectory(AssetDirectory(TAppAssetKind.akVideo));
  EnsureDirectory(AssetDirectory(TAppAssetKind.akAudio));
  EnsureDirectory(AssetDirectory(TAppAssetKind.akOther));
  {$ENDIF}
end;

class procedure TAppPath.EnsureDirectory(const ADirectory: string);
begin
  if ADirectory.Trim.IsEmpty then exit;

  if not TDirectory.Exists(ADirectory) then begin
    TDirectory.CreateDirectory(ADirectory);
  end;
end;

class function TAppPath.GetFileAssetKind(const AFileName: string): TAppAssetKind;
var
  LExtension: string;
begin
  LExtension := TPath.GetExtension(AFileName).ToLower;

  if (LExtension = '.jpg') or (LExtension = '.jpeg') or
    (LExtension = '.png') or (LExtension = '.bmp') or
    (LExtension = '.gif') or (LExtension = '.webp') or
    (LExtension = '.svg') then begin
    Result := TAppAssetKind.akImage;
  end else if (LExtension = '.doc') or (LExtension = '.docx') or
    (LExtension = '.pdf') or (LExtension = '.csv') or
    (LExtension = '.txt') or (LExtension = '.xls') or
    (LExtension = '.xlsx') or (LExtension = '.rtf') or
    (LExtension = '.xml') or (LExtension = '.json') then begin
    Result := TAppAssetKind.akDocument;
  end else if (LExtension = '.mp4') or (LExtension = '.avi') or
    (LExtension = '.wmv') or (LExtension = '.flv') or
    (LExtension = '.mov') or (LExtension = '.mkv') or
    (LExtension = '.3gp') or (LExtension = '.webm') then begin
    Result := TAppAssetKind.akVideo;
  end else if (LExtension = '.mp3') or (LExtension = '.wav') or
    (LExtension = '.wma') or (LExtension = '.aac') or
    (LExtension = '.flac') or (LExtension = '.m4a') or
    (LExtension = '.ogg') then begin
    Result := TAppAssetKind.akAudio;
  end else begin
    Result := TAppAssetKind.akOther;
  end;
end;

class function TAppPath.LoadFile(const AFileName: string): string;
begin
  if AFileName.Trim.IsEmpty then
    raise EArgumentException.Create('File name is required.');

  if TPath.IsPathRooted(AFileName) then begin
    Result := AFileName;
    EnsureDirectory(TPath.GetDirectoryName(Result));
    exit;
  end;

  {$IF DEFINED(IOS) OR DEFINED(ANDROID)}
  Result := TPath.Combine(AppBaseDirectory, AFileName);
  {$ELSEIF DEFINED(MSWINDOWS) OR DEFINED(MACOS) OR DEFINED(OSX) OR DEFINED(LINUX)}
  Result := BuildDesktopAssetPath(AFileName);
  {$ELSE}
  Result := TPath.Combine(AppBaseDirectory, AFileName);
  {$ENDIF}

  EnsureDirectory(TPath.GetDirectoryName(Result));
end;

class function TAppPath.NewUUIDCompact: string;
begin
  Result := TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '');
end;

{ TGlobalFunction }

class procedure TGlobalFunction.CreateBaseDirectory;
begin
  TAppPath.EnsureBaseDirectories;
end;

class function TGlobalFunction.GetBaseDirectory: string;
begin
  Result := IncludeTrailingPathDelimiter(TAppPath.AppBaseDirectory);
end;

end.

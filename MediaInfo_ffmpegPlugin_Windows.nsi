#NSIS: encoding=UTF-8

!ifdef PORTABLE
  RequestExecutionLevel user
!else
  RequestExecutionLevel admin
!endif

; Some defines
!define PRODUCT_NAME "MediaInfo FFmpeg Plugin"
!define PRODUCT_PUBLISHER "MediaArea.net"
!define PRODUCT_VERSION "8.0"
!define PRODUCT_VERSION4 "${PRODUCT_VERSION}.0.0"
!define PRODUCT_WEB_SITE "http://MediaArea.net/MediaInfo"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; Compression
SetCompressor /FINAL /SOLID lzma

; x64 stuff
!include "x64.nsh"

; File size
!include FileFunc.nsh
!include WinVer.nsh

; Modern UI
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "MediaInfo.ico"

; Uninstaller signing
!ifdef EXPORT_UNINST
!uninstfinalize 'copy /Y "%1" "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows-uninst.exe"'
!endif

; Installer pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Info
VIProductVersion "${PRODUCT_VERSION4}"
VIAddVersionKey "CompanyName"      "${PRODUCT_PUBLISHER}"
VIAddVersionKey "ProductName"      "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion"   "${PRODUCT_VERSION4}"
VIAddVersionKey "FileDescription"  "FFmpeg helper for MediaInfo"
VIAddVersionKey "FileVersion"      "${PRODUCT_VERSION4}"
VIAddVersionKey "LegalCopyright"   "${PRODUCT_PUBLISHER}"
!ifdef PORTABLE
VIAddVersionKey "OriginalFilename" "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows_Portable.exe"
!else
VIAddVersionKey "OriginalFilename" "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows.exe"
!endif
BrandingText " "

; Modern UI end

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
!ifdef PORTABLE
OutFile "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows_Portable.exe"
!else
OutFile "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows.exe"
!endif
InstallDir "$PROGRAMFILES64\MediaInfo"
ShowInstDetails nevershow
ShowUnInstDetails nevershow

Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
FunctionEnd

Section "SectionPrincipale" SEC01
  SetOverwrite on
  SetOutPath "$INSTDIR"
  File "ffmpeg.exe"
  SetOverwrite try
  SetOutPath "$INSTDIR\Plugin\FFmpeg"
  File "version.txt"
SectionEnd

Section -Post
  !ifndef PORTABLE
  Section -Post
  !if /FileExists "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows-uninst.exe"
    File "/oname=$INSTDIR\ffmpeg_plugin_uninst.exe" "MediaInfo_FFmpegPlugin_${PRODUCT_VERSION}_Windows-uninst.exe"
  !else
    WriteUninstaller "$INSTDIR\ffmpeg_plugin_uninst.exe"
  !endif
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName"     "$(^Name)"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon"     "$INSTDIR\MediaInfo.exe"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher"       "${PRODUCT_PUBLISHER}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\ffmpeg_plugin_uninst.exe"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion"  "${PRODUCT_VERSION}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout"    "${PRODUCT_WEB_SITE}"
    ${If} ${AtLeastWin7}
        WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "EstimatedSize" "0x000051d7" ; Create/Write the reg key with the dword value
    ${EndIf}
  !endif
SectionEnd


Section Uninstall
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}

  Delete "$INSTDIR\ffmpeg.exe"
  Delete "$INSTDIR\Plugin\FFmpeg\version.txt"
  Delete "$INSTDIR\ffmpeg_plugin_uninst.exe"

  RMDir "$INSTDIR\Plugin\FFmpeg"
  RMDir "$INSTDIR\Plugin"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd

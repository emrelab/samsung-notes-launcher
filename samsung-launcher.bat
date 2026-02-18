@echo off
setlocal EnableDelayedExpansion
title Samsung Notes Geliştirilmiş Çalıştırıcı
color 0A

echo =====================================================
echo Samsung Notes Geliştirilmiş Çalıştırıcı
echo =====================================================
echo.

:: Yönetici hakları kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Yönetici hakları gerekiyor. Yükseltme isteniyor...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo Yönetici hakları onaylandı.
echo.

:: Samsung Notes uygulamasının yüklü olup olmadığını kontrol et
echo Samsung Notes uygulaması kontrol ediliyor...
powershell -Command "Get-AppxPackage -Name *Samsung*Notes* | Format-List PackageFullName, PackageFamilyName" > "%temp%\samsung_details.txt"
type "%temp%\samsung_details.txt"

find /i "PackageFullName" "%temp%\samsung_details.txt" >nul
if %errorLevel% neq 0 (
    echo.
    echo Hata: Samsung Notes uygulaması bulunamadı.
    echo Lütfen Microsoft Store'dan Samsung Notes uygulamasını yükleyin.
    echo.
    pause
    exit /b
)

:: Paket bilgilerini al
for /f "tokens=2 delims=:" %%i in ('findstr /i "PackageFullName" "%temp%\samsung_details.txt"') do set "PACKAGE_FULL=%%i"
for /f "tokens=2 delims=:" %%i in ('findstr /i "PackageFamilyName" "%temp%\samsung_details.txt"') do set "PACKAGE_FAMILY=%%i"

:: Boşlukları temizle
set "PACKAGE_FULL=!PACKAGE_FULL: =!"
set "PACKAGE_FAMILY=!PACKAGE_FAMILY: =!"

echo Paket Tam Adı: !PACKAGE_FULL!
echo Paket Aile Adı: !
REM ##################################
REM --- Guidelines: ---
REM
REM Common Environment Variable:
REM 'Package_Publish:boolean:true',
REM 'Clean_Clone:boolean:false',
REM 'is_tag_fetch:boolean:false',
REM 'is_offical_build:boolean:false',
REM 'repo:string',
REM 'base:string',
REM 'arch:string'
REM 'output:string'
REM 'short_version:string'
REM 'release_version:string'
REM 'build_date:string(yyyyMMdd)',
REM 'build_timestamp:string (yyyyMMdd_hhmm)',
REM 'platform: string',
REM 'BUILD_NUMBER: string',
REM 'WORKSPACE: string'
REM
REM --- Test Related: ---
REM For PR build, zip test related to test.zip
REM For Package build, zip package related to package.zip
REM --- Artifactory Related: ---
REM download artifactory:
REM python %WORKSPACE%\\artifactory_utils.py --action=download_file --file=ARTIFACTORY_URL
REM upload file to artifactory:
REM python %WORKSPACE%\\artifactory_utils.py --action=upload_file --file=FILEPATTERN --server_path=SERVERPATH --server_repo=SERVER_REPO --with_pattern
REM for example: python %WORKSPACE%\\artifactory_utils.py --action=upload_file --file=*.zip --server_path=windows/ --server_repo=ACCS_repo --with_pattern
REM upload folder to artifactory
REM python %WORKSPACE%\\artifactory_utils.py --action=upload_file --file=FILEPATTERN --server_path=SERVERPATH --server_repo=SERVER_REPO --with_folder
REM for example: python %WORKSPACE%\\artifactory_utils.py --action=upload_file --file=publish --server_path=windows/ --server_repo=ACCS_repo --with_folder
REM --- Input: ----
REM sourcePath: see jenkins console for details.
REM WORKSPACE: %WORKSPACE%
REM --- Output: ----
REM pr: output test.zip to workspace dir
REM others: Rename the zip package name yourself, But need copy it to workspace dir
REM ##################################

echo Package_Publish: %Package_Publish%
echo is_tag_fetch: %is_tag_fetch%
echo arch: %arch%
echo source_root: %source_root%
echo output: C:\\tmp\\%project%_out
echo build_date: %build_date%
echo build_time: %build_time%
echo release_version: %release_version%
echo short_version: %short_version%
echo pwd: %cd%
echo sdk_url: %sdk_url%

echo off
set zip_name=%sdk_url%
:LOOP
for /f "tokens=1* delims=</>" %%a in ("%zip_name%") do (
    set zip_name=%%a
    set part2=%%b
)
if "%part2%" EQU "" goto END
set zip_name=%part2%
goto LOOP
:END
echo on
echo zip_name: %zip_name%

dir

echo off
REM curl --silent %sdk_url% ./
python %WORKSPACE%\\artifactory_utils.py --action=download_file --file=%sdk_url%
7z x ./%zip_name% -y
echo on

dir

rmdir /S /Q Agora_Native_SDK_for_Windows_FULL\demo
del /F /Q Agora_Native_SDK_for_Windows_FULL\commits
del /F /Q Agora_Native_SDK_for_Windows_FULL\package_size_report.txt
mkdir Agora_Native_SDK_for_Windows_FULL\samples
mkdir Agora_Native_SDK_for_Windows_FULL\samples\API-example
rmdir /S /Q windows\cicd
del /F /Q windows\APIExample\ci.py
xcopy /Y /E windows\APIExample Agora_Native_SDK_for_Windows_FULL\samples\API-example
xcopy /Y /E windows\README.md Agora_Native_SDK_for_Windows_FULL\samples\API-example
xcopy /Y /E windows\README.zh.md Agora_Native_SDK_for_Windows_FULL\samples\API-example
7z a -tzip result.zip -r Agora_Native_SDK_for_Windows_FULL
copy result.zip %WORKSPACE%\\withAPIExample_%zip_name%
del /F result.zip
del /F %WORKSPACE%\\%zip_name%

cd Agora_Native_SDK_for_Windows_FULL\samples\API-example
.\installThirdParty.bat && "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe" "APIExample.sln" /p:platform="Win32" /p:configuration="Release" && 7z a -tzip result.zip -r Release && copy result.zip %WORKSPACE%\\APIExample-windows.zip

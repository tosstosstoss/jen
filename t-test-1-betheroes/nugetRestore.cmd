@echo off

REM This script has been committed in the repo
REM Internal Tools -> jenkins.scripts -> nugetRestore.cmd

echo(
echo Retrieving necessary packages for modules
echo -----------------------------------------

if "%_JENKINS_ENABLE_ECHO%"=="true" echo on

rem enabledelaydexpansion resolved the problem when %errorlevel%
rem wasn't right! but !errorlevel! worked!!!
rem also the check if errorlevel 1062 was working also... 
rem it seems that sometimes the var %errorlevel% isn't already set!
setlocal enabledelayedexpansion

GOTO :Actions

:reset_core_to_dev
SETLOCAL

if exist php.spotprophets/vendor/25-8projects/core/ (
        cd php.spotprophets/vendor/25-8projects/core/
        (start /B git show-branch development > NUL 2>&1) && (git checkout development) || (git checkout -b development)
        git fetch --all
        git reset --hard origin/development
)

ENDLOCAL
GOTO :EOF

:restore_php_packages
SETLOCAL
SET _solution_path=%~1
SET _service_description=%~2
SET _packages_path=%~3

echo(
echo Restoring PHP packages with composer on workspace %_service_description%
rem On Development deployment we want dev packages. So we run --no-dev in all other environments.
if "!_commit_id!"=="development" (
	rem Composer update (with dev dependencies)
	echo Running Composer Update for *%_commit_id%* branch [inlcuding dev]
	CALL composer update --working-dir=%_solution_path% --prefer-source --optimize-autoloader --no-suggest
	echo ErrorLevel: %errorlevel%
	echo(

	rem Since we cannot use else if, we use go to.
	goto endComposerUpdateDev
) 

if "!_commit_id!"=="test" (
	rem Composer update (without dev dependencies)
	echo Running Composer Update for *%_commit_id%* branch [--no-dev]
	CALL composer update --working-dir=%_solution_path% --prefer-source --optimize-autoloader --no-suggest --no-dev
	echo ErrorLevel: %errorlevel%
	echo(
) else (
	rem Composer install (without dev dependencies)
	echo Running Composer Install for *%_commit_id%* branch [--no-dev]
	CALL composer install --working-dir=%_solution_path% --prefer-source --optimize-autoloader --no-suggest --no-dev
	echo ErrorLevel: %errorlevel%
	echo(
)

echo Done.
echo(

:endComposerUpdateDev
CALL :clean_yarn %_packages_path%
CALL :restore_yarn_packages %_solution_path% "%_service_description%" %_packages_path%
CALL :restore_webpack_bundles %_solution_path% "%_service_description%" %_packages_path%

ENDLOCAL
GOTO :EOF

:clean_yarn
SETLOCAL

echo(
echo Cleaning yarn cache and node_modules
if exist %_packages_path%\node_modules rd /s /q %_packages_path%\node_modules
CALL yarn cache clean

echo ErrorLevel: %errorlevel%
echo Done.
echo(

ENDLOCAL
GOTO :EOF

:restore_yarn_packages
SETLOCAL
SET _solution_path=%~1
SET _service_description=%~2
SET _packages_path=%~3

echo(
echo Restoring NodeJs Modules with yarn on workspace %_service_description%
CALL cd %_solution_path%\%_packages_path% && yarn install --non-interactive --ignore-optional

rem If this continues and yarn install has errors the site won't work
echo ErrorLevel: %errorlevel%
echo Done.
echo(

ENDLOCAL
GOTO :EOF

:restore_webpack_bundles
SETLOCAL
SET _solution_path=%~1
SET _service_description=%~2
SET _packages_path=%~3

echo(
echo Install Webpack bundles on workspace %_service_description%
CALL cd %_solution_path%\%_packages_path% && yarn run build:prod

rem If this continues and yarn run build has errors the site won't work
echo ErrorLevel: %errorlevel%
echo Done.
echo(

ENDLOCAL
GOTO :EOF


:restore_nugets
SETLOCAL
SET _solution_path=%~1
SET _service_description=%~2
SET _packages_path=%~3

echo(
echo Restoring nuget packages for %_service_description%
"C:\Program Files (x86)\NuGet\nuget.exe" restore %_solution_path%

echo ErrorLevel: %errorlevel%
echo Done.
echo(

ENDLOCAL
GOTO :EOF

:Actions
SETLOCAL

if "!_configfiles_branch!" == "t-stg" (
	if "!hotfix!" == "yes" (
		echo This is a hotfix. Proceeding with code build
	) else (
		echo No hotfix, so not building code on this branch. Will use TEST's archive
		GOTO :skipPHPbuild
	)
)
if "!_configfiles_branch!" == "t-prod" (
        echo "Not building code on this branch. Will use STG's archive"
        GOTO :skipPHPbuild
)

CALL :reset_core_to_dev

CALL :restore_php_packages "php.spotprophets" "Spotprophets" "assets"

CALL :restore_php_packages "php.spbackoffice" "Spotprophets BackOffice" "public"

:skipPHPbuild
rem CALL :restore_nugets "windows.betslipandprophecyevaluation\BetslipAndProphecyEvaluation.sln" "BetSlip And Prophecy Evaluation"

CALL :restore_nugets "windows.notifications\Notifications.sln" "Notifications"

CALL :restore_nugets "windows.signalr\SignalR.sln" "SignalR"

CALL :restore_nugets "windows.challenges\ChallengesEvaluation.sln" "Challenges"

echo(
ENDLOCAL 

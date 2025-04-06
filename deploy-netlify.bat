@echo off
echo ===================================
echo DEPLOY VISAGINAS SITE TO NETLIFY
echo ===================================
echo.

echo Step 1: Checking required tools...
call npm --version > nul 2>&1
if %errorlevel% neq 0 (
  echo Node.js and npm must be installed!
  exit /b 1
)

call netlify --version > nul 2>&1
if %errorlevel% neq 0 (
  echo Installing Netlify CLI...
  call npm install netlify-cli -g
)

echo.
echo Step 2: Installing project dependencies...
call npm install

echo.
echo Step 3: Installing static adapter...
call npm install @sveltejs/adapter-static --save-dev

echo.
echo Step 4: Creating temporary config for static build...
echo import adapter from '@sveltejs/adapter-static'; > svelte.config.js.temp
echo import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'; >> svelte.config.js.temp
echo. >> svelte.config.js.temp
echo /** @type {import('@sveltejs/kit').Config} */ >> svelte.config.js.temp
echo const config = { >> svelte.config.js.temp
echo   preprocess: vitePreprocess(), >> svelte.config.js.temp
echo   kit: { >> svelte.config.js.temp
echo     adapter: adapter({ >> svelte.config.js.temp
echo       pages: 'build', >> svelte.config.js.temp
echo       assets: 'build', >> svelte.config.js.temp
echo       fallback: 'index.html', >> svelte.config.js.temp
echo       precompress: true >> svelte.config.js.temp
echo     }) >> svelte.config.js.temp
echo   } >> svelte.config.js.temp
echo }; >> svelte.config.js.temp
echo. >> svelte.config.js.temp
echo export default config; >> svelte.config.js.temp

copy svelte.config.js svelte.config.js.bak > nul
copy svelte.config.js.temp svelte.config.js > nul

echo.
echo Step 5: Building the project...
call npm run build

echo.
echo Step 6: Restoring original config...
copy svelte.config.js.bak svelte.config.js > nul
del svelte.config.js.bak
del svelte.config.js.temp

echo.
echo Step 7: Checking Netlify login...
call netlify status
if %errorlevel% neq 0 (
  echo Logging into Netlify...
  call netlify login
)

echo.
echo Step 8: Deploying to Netlify...
echo Select option:
echo 1. Create new site
echo 2. Deploy to existing site
choice /C 12 /N /M "Your choice (1 or 2): "

if %errorlevel% equ 1 (
  echo.
  echo Creating new site on Netlify with name visaginas...
  call netlify sites:create --name visaginas
  call netlify deploy --prod --dir=build --site=visaginas
) else (
  echo.
  echo Selecting existing site for deployment...
  call netlify deploy --prod --dir=build
)

echo.
echo Deployment complete!
echo.

pause
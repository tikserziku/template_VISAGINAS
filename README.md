# VISAGINAS - SvelteKit + Netlify Template

Этот репозиторий содержит шаблон и инструкции для создания и деплоя SvelteKit проекта "VISAGINAS" на платформу Netlify.

## Содержание

- [Структура проекта](#структура-проекта)
- [Настройка проекта](#настройка-проекта)
- [Деплой на Netlify](#деплой-на-netlify)
- [Автоматизация деплоя](#автоматизация-деплоя)
- [Решение проблем](#решение-проблем)

## Структура проекта

Проект VISAGINAS основан на SvelteKit с использованием TailwindCSS:

```
VISAGINAS-WEB/
├── .svelte-kit/          # Сгенерированные файлы SvelteKit (автоматически)
├── node_modules/         # Зависимости проекта (автоматически)
├── src/                  # Исходный код
│   ├── app.css           # Глобальные стили
│   ├── app.html          # HTML шаблон
│   ├── lib/              # Библиотеки и компоненты
│   ├── locales/          # Файлы локализации (i18n)
│   └── routes/           # Маршруты и страницы
│       ├── +layout.svelte # Общий layout
│       └── +page.svelte   # Главная страница
├── static/               # Статические файлы
│   └── visaginas-bg.webp # Фоновое изображение
├── .gitignore            # Игнорируемые Git файлы
├── deploy-netlify.bat    # Скрипт для деплоя на Netlify
├── netlify.toml          # Конфигурация для Netlify
├── package.json          # Зависимости и скрипты
├── package-lock.json     # Точные версии зависимостей
├── postcss.config.js     # Конфигурация PostCSS
├── svelte.config.js      # Конфигурация SvelteKit
├── tailwind.config.js    # Конфигурация TailwindCSS
├── tsconfig.json         # Настройки TypeScript
└── vite.config.js        # Конфигурация Vite
```

## Настройка проекта

### Требования

- Node.js (рекомендуется версия 18+)
- npm или yarn
- Git

### Установка проекта

1. Клонируйте репозиторий:
```bash
git clone https://github.com/tikserziku/VISAGINAS-WEB.git
cd VISAGINAS-WEB
```

2. Установите зависимости:
```bash
npm install
```

3. Запустите проект в режиме разработки:
```bash
npm run dev
```

## Деплой на Netlify

### Подготовка конфигурационных файлов

#### 1. netlify.toml

Этот файл содержит настройки для Netlify:

```toml
[build]
  command = "npm run build"
  publish = "build"

[dev]
  command = "npm run dev"
  port = 5173
  targetPort = 5173
  
[functions]
  directory = "functions"
```

#### 2. svelte.config.js

Настройка SvelteKit для работы с Netlify:

```javascript
import adapter from '@sveltejs/adapter-netlify';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),
  kit: {
    adapter: adapter()
  }
};

export default config;
```

### Деплой с помощью автоматического скрипта

Лучший способ деплоя - использовать скрипт `deploy-netlify.bat`, который автоматизирует весь процесс:

```batch
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
```

#### Как работает скрипт деплоя

1. **Проверяет наличие необходимых инструментов** (Node.js, npm, Netlify CLI)
2. **Устанавливает зависимости проекта**
3. **Временно заменяет адаптер** на `adapter-static` для создания статической сборки
4. **Создает сборку проекта** с помощью `npm run build`
5. **Восстанавливает оригинальную конфигурацию**
6. **Авторизуется в Netlify** если необходимо
7. **Деплоит проект на Netlify** - либо создает новый сайт, либо обновляет существующий

### Использование скрипта деплоя

1. Выполните скрипт двойным кликом или через командную строку:
```bash
./deploy-netlify.bat
```

2. Следуйте инструкциям на экране
3. При первом запуске вам потребуется авторизоваться в Netlify через браузер
4. Выберите, хотите ли вы создать новый сайт или использовать существующий

## Автоматизация деплоя

### Настройка автоматического деплоя через GitHub

Для настройки непрерывного деплоя (CI/CD) через GitHub:

1. Загрузите проект на GitHub:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/ваш-логин/имя-репозитория.git
git push -u origin main
```

2. В Netlify:
   - Войдите в свой аккаунт Netlify
   - Выберите "New site from Git"
   - Выберите GitHub и найдите ваш репозиторий
   - Настройки деплоя:
     - Branch to deploy: `main`
     - Build command: `npm run build`
     - Publish directory: `build`
   - Нажмите "Deploy site"

3. После первого деплоя каждое изменение в репозитории будет автоматически активировать новый деплой.

## Решение проблем

### Распространенные проблемы

#### Проблема: Ошибка "Could not resolve entry module 'index.html'"

**Решение**: Эта ошибка возникает, когда Netlify не может правильно собрать SvelteKit проект. Используйте скрипт `deploy-netlify.bat`, который временно меняет адаптер на `adapter-static` для создания совместимой статической сборки.

#### Проблема: Ошибки кодировки в batch скриптах

**Решение**: Используйте только ASCII символы (английский текст) в batch файлах для Windows или сохраняйте файлы в кодировке CP866.

#### Проблема: Netlify не находит функции SvelteKit

**Решение**: Убедитесь, что вы используете правильный adapter (`@sveltejs/adapter-netlify`) и что директория публикации правильно указана в `netlify.toml`.

### Дополнительные ресурсы

- [Документация SvelteKit](https://kit.svelte.dev/docs)
- [Документация Netlify](https://docs.netlify.com/)
- [Документация по интеграции SvelteKit с Netlify](https://github.com/sveltejs/kit/tree/master/packages/adapter-netlify)

## Лицензия

Этот шаблон распространяется под [MIT License](LICENSE).
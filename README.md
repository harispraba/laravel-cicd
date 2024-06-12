# Laravel CI/CD with Jenkins
This is a simple example of how to use Jenkins to deploy a Laravel application to a server.

## Table of Contents
- [Requirements](#requirements)
- [Setup Jenkins](#setup-jenkins)
- [Setup Laravel Application in Local](#setup-laravel-application-in-local)
- [Setup Laravel Application in Jenkins](#setup-laravel-application-in-jenkins)

## Requirements
- [Jenkins](https://www.jenkins.io/)
- [Laravel](https://laravel.com/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- [Nginx](https://www.nginx.com/)
- [PHP](https://www.php.net/)
- [Composer](https://getcomposer.org/)
- [Node.js](https://nodejs.org/)
- [NPM](https://www.npmjs.com/)
- [Yarn](https://yarnpkg.com/)
- [MySQL](https://www.mysql.com/)

## Setup Jenkins
1. Clone this repository
```bash
git clone https://github.com/jawaracloud/jenkins-casc
```
2. Run docker-compose
```bash
docker compose up -d
```
3. Login to Jenkins
username: admin
password: nimda

## Setup SonarQube

## Setup Laravel Application in Local
1. Clone this repository
```bash
git clone https://github.com/jawaracloud/laravel-cicd
```
2. Install dependencies
```bash
composer install
npm install
```
3. Create .env file
```bash
cp .env.example .env
```
4. Generate application key
```bash
php artisan key:generate
```
5. Running Docker Compose MySQL
```bash
docker compose up -d
```
6. Running Laravel Migration
```bash
php artisan migrate
```
7. Running Laravel Seed
```bash
php artisan db:seed
```
8. Running Laravel Application
```bash
php artisan serve
```
9 Login to Laravel Application
Open browser and go to http://localhost:8000/admin
email: admin@laravel.com
password: 123

## Setup Laravel Application in Jenkins
1. Create a new item
2. Choose Pipeline
3. Configure the pipeline
4. Copy and paste the Jenkinsfile content

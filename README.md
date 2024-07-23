# README

This README would normally document whatever steps are necessary to get the application up and running.

## Ruby version

The application is built using Ruby version 3.0.2.

## System dependencies

The application uses PostgreSQL as the database for Active Record. The pg gem is used to interact with the database. The application also uses Puma as the web server and Importmap-rails for JavaScript with ESM import maps.

## Configuration

The application is configured using environment variables. The database username and password are set using the `ATHENA_DATABASE_USERNAME` and `ATHENA_DATABASE_PASSWORD` environment variables, respectively.

## Gem Installation:

To install gems, run the following command:

```bash
bundle install
```

## Database creation

To create the database, run the following command:

```bash
rails db:create
```

## Database initialization

To initialize the database, run the following command:

```bash
rails db:migrate
```

## Usage

Run the following command to start server and telegram-bot:

```bash
rails server
rails telegram:bot:poller
```


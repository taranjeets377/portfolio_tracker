# Personal Portfolio Tracker

A Ruby on Rails application to track personal stock and mutual fund investments.

## Features

- Track stock purchases and sales
- Record dividend payouts
- Handle stock splits
- Portfolio dashboard
- Portfolio analytics (CAGR, XIRR)
- Monthly investment reports

## Tech Stack

- Ruby 3.2.4
- Rails 7
- PostgreSQL
- Sidekiq (future)
- Redis (future)

## Setup

```bash
bundle install
rails db:create
rails db:migrate
rails s